pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- last stand of the bismarck
-- by @apa64
--  v. 0.3-SNAPSHOT
-- with tinyecs 1.1 by @katrinakitten https://www.lexaloffle.com/bbs/?tid=39021

--[[ MIT License

copyright (c) 2020 antti ollilainen

permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "software"), to deal
in the software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the software, and to permit persons to whom the software is
furnished to do so, subject to the following conditions:

the above copyright notice and this permission notice shall be included in all
copies or substantial portions of the software.

the software is provided "as is", without warranty of any kind, express or
implied, including but not limited to the warranties of merchantability,
fitness for a particular purpose and noninfringement. in no event shall the
authors or copyright holders be liable for any claim, damages or other
liability, whether in an action of contract, tort or otherwise, arising from,
out of or in connection with the software or the use or other dealings in the
software.
--]]
#include tinyecs-1.1.lua

-- master container of entities
ents = {}
-- entity shortcut
e_bm = nil
-- debug mode on/off
debug = false

-- constants

sound_explosion_dstr = 0
sound_explosion_bm = 0
sound_shot_dstr = 1
sound_shot_bm = 1
lives_total = 2197

-- ########### special functions #############################################

-- ######################## menu

function _init() menu_init() end

function menu_init()
  _update = menu_update
  _draw = menu_draw
end

function menu_update()
  if (btnp(5)) game_init() -- change state to play the game
end

function menu_draw()
  cls(0)
  print_xcenter("last stand of the bismarck", 40, 12)  -- menu draw code
  print_xcenter("defend bismarck from the", 60, 13)
  print_xcenter("royal navy destroyers", 66, 13)
  print_xcenter("press ❎ to start", 82, 6)
  print("fire   ❎", 33, 95, 6)
  print("aim", 33, 105, 6)
  print("  ⬆️", 53, 102, 6)
  print("⬅️⬇️➡️", 53, 109, 6)
  print_xcenter("(c) antti ollilainen 2020", 122, 5)
end

-- ######################## game

function game_init()
  ents = {}
  _update = game_update
  _draw = game_draw
  -- todo move in entity or something
  bullet_speed = 0.8
  lives_lost = 0
  bm_gun_ready_t = 0
  bm_gun_rld_delay = 0.7
  -- create and store entities
  e_bm = mk_bm()
  add(ents, e_bm)
  local e_dstr1 = mk_dstr(nil, 80, 70, 55, 80+55, 70, 0, 0.4)
  add(ents, e_dstr1)
  local e_dstr2 = mk_dstr(nil, 50, 50, 60, 50-60, 60, 180, 0.4)
  add(ents, e_dstr2)

  local e_sight = mk_sight()
  add(ents, e_sight)
end

function game_update()
  if (lives_lost > lives_total) then
    gameover_init()
  end
  -- run systems
  s_control(ents)
  s_bmshoot(ents)
  s_mvtrack(ents)
  s_dstrshoot(ents)
  s_mvbullet(ents)
  s_entcoll(ents)
end

function game_draw()
  cls(1)
  map()
  --print_xcenter("last stand of the bismarck", 2, 13)
  print_xcenter(lives_lost.." lives lost", 122, 5)

  -- draw bm
  spr(16, e_bm.pos.x, e_bm.pos.y)
  spr(32, e_bm.pos.x, e_bm.pos.y+8)

  -- run draw systems
  s_draw(ents)

  if (debug) then
    local y = 0
    print("#ents:"..#ents, 0, y, 14)
    y += 6
    for i=1,#ents do
      e = ents[i]
      print("e"..i..":"..tostr(e)..": x="..e.pos.x..", y="..e.pos.y, 0, y, 14)
      y += 6
      for ckey,cval in pairs(e) do
        --print(tostr(ckey)..":"..tostr(cval), 0, y, 14)
        if (ckey == "shooter") then
          print("  shooter: "..tostr(cval), 0, y, 14)
          y += 6
          -- look inside shooter
          for skey,sval in pairs(cval) do
            print("    "..skey..": "..tostr(sval), 0, y, 14)
            y += 6
          end
        end
      end
    end
  end
end

-- ################### game over

function gameover_init()
  ents = {}
  _update = gameover_update
  _draw = gameover_draw
end

function gameover_update()
  if (btnp(5)) menu_init()
end

function gameover_draw()
  print_xcenter("game over", 60, 8)
end

-->8
-- #################### entities #############################################

-- bismarck
function mk_bm()
  local e = ent()
  e += cmp("bm") -- type
  e += c_pos(60, 60)
  e += c_size(8, 16)
  e += c_collidable()
  return e
end

-- a destroyer
function mk_dstr(dstr, x, y, r, posx, posy, angle, speed)
  local e = ent()
  local x = x or 80
  local y = y or 70
  local r = r or 55
  local angle = angle or 0
  local speed = speed or 0.4
  if (dstr) then
    x = dstr.mvtrack.x
    y = dstr.mvtrack.y
    r = dstr.mvtrack.r
    speed = dstr.mvtrack.speed
    angle = dstr.mvtrack.initial_angle
  end
  local posx = posx or (x+r)
  local posy = posy or y

  e += cmp("dstr")
  e += c_sprite(3)
  e += c_size(5, 8)
  if (rnd(100) < 40) speed *= -1
  e += c_mvtrack(x, y, r, angle, speed)
  e += c_pos(posx, posy)
  e += c_collidable()
  e += c_gun()
  return e
end

-- gunsight
function mk_sight()
  local e = ent()
  e += cmp("sight")
  e += c_pos(60, 40)
  e += c_sprite(48)
  e += c_size(7, 7)
  e += c_control(2)
  return e
end

-- gun bullet
-- create animated bullet
function mk_bullet(x0, y0, x1, y1, shooter)
  local e = ent()
  e += cmp("bullet")
  e += c_pos(x0, y0)
  e += c_targetpos(x1, y1)
  e += c_sprite(49)
  e += c_size(3, 3)
  e += c_collidable()
  e += c_shooter(shooter)
  return e
end
-->8
-- ################## components #############################################

-- x,y position.
c_pos = function(x, y)
  return cmp("pos",
    { x = x, y = y })
end

c_size = function(w, h)
  w = w or 8
  h = h or 8
  return cmp("size",
    { w = w, h = h })
end

c_targetpos = function(x, y)
  return cmp("targetpos",
    { x = x, y = y })
end

c_gun = function(rld_delay, rld_rnd)
  rld_delay = rld_delay or 1
  rld_rnd = rld_rnd or 3
  return cmp("gun",
    {
      ready_t = t() + rld_delay + rnd(rld_rnd),
      rld_delay = rld_delay,
      rld_rnd = rld_rnd
   })
end

-- has drawable with size.
c_sprite = function(sprite)
  return cmp("sprite",
    { sprite = sprite })
end

-- controllable tag.
c_control = function(speed)
  speed = speed or 1
  return cmp("control",
    { speed = speed })
end

-- movement track params
-- x, y   origo x,y
-- r      radius
-- angle  initial angle
-- speed  delta angle per tick
c_mvtrack = function(x, y, r, angle, speed)
  return cmp("mvtrack",
    {
      x = x or 63,
      y = y or 63,
      r = r or 55,
      angle = angle or 0,
      speed = speed or 0.4,
      initial_angle = angle
    })
end

c_collidable = function()
  return cmp("collidable")
end

c_shooter = function(shooter)
  return cmp("shooter",
    { shooter = shooter })
end

-->8
-- ##################### systems #############################################

-- move along track
-- see this for anim: https://mboffin.itch.io/pico8-simple-animation
s_mvtrack = sys({"pos", "mvtrack"},
function(e)
  --moves along track
  e.mvtrack.angle += e.mvtrack.speed
  e.pos.x = e.mvtrack.x + e.mvtrack.r * cos(e.mvtrack.angle/360)
  e.pos.y = e.mvtrack.y + e.mvtrack.r * sin(e.mvtrack.angle/360)
  if (e.mvtrack.angle > 360) then
    e.mvtrack.angle = 0
  elseif (e.mvtrack.angle < 0) then
    e.mvtrack.angle = 360
  end
end)

-- move bullet 1 step from start to end
s_mvbullet = sys({"pos", "targetpos"},
function(e)
  -- bullet at target
  if (e.pos.x == e.targetpos.x or e.pos.y == e.targetpos.y) then
    --    or e.pos.x < 0 or e.pos.x > 127 or e.pos.y < 0 or e.pos.y > 127) then
    -- TODO: sfx shwoosh or splash
    del(ents, e)
    return
  end
  -- get next bullet position
  e.pos.x, e.pos.y = bulletvector(e.pos.x, e.pos.y, e.targetpos.x, e.targetpos.y)
end)

-- gunsight control system.
s_control = sys({"control", "pos", "size"},
function(e)
  local newx = e.pos.x
  local newy = e.pos.y
  if (btn(0)) newx -= e.control.speed
  if (btn(1)) newx += e.control.speed
  if (btn(2)) newy -= e.control.speed
  if (btn(3)) newy += e.control.speed
  -- world borders
  e.pos.x = mid(0, newx, 127 - e.size.w + 1)
  e.pos.y = mid(0, newy, 127 - e.size.h + 1)
end)

-- shoot to where the sight is
s_bmshoot = sys({"control", "pos", "size"},
function(e)
  -- x
  -- shoot if cooldown passed
  if (btnp(5) and t() > bm_gun_ready_t) then
    -- sight center
    local tgt_x = e.pos.x + (e.size.w/2)
    local tgt_y = e.pos.y + (e.size.h/2)
    local bm_x, bm_y = 63, 63
    -- bm_x, bm_y = bulletvector(bm_x, bm_y, tgt_x, tgt_y, 8)
    shoot(bm_x, bm_y, tgt_x, tgt_y, e_bm)
    bm_gun_ready_t = t() + bm_gun_rld_delay
  end
  -- z / o
  if (btnp(4)) then
    debug = not debug
  end
end)

s_dstrshoot = sys({"dstr", "pos", "gun"},
function(e)
  if (t() > e.gun.ready_t) then
    -- target close to bm
    local tgt_x, tgt_y = 54 + rnd(20), 54 + rnd(20)
    -- bullet origin few pixels
    -- towards target not to hit
    -- dstr itself
    --local x, y = bulletvector(e.pos.x, e.pos.y, tgt_x, tgt_y, 8)
    shoot(e.pos.x, e.pos.y, tgt_x, tgt_y, e)
    e.gun.ready_t = t() + e.gun.rld_delay + rnd(e.gun.rld_rnd)
  end
end)

-- detect collisions between collidable entities
s_entcoll = sys({"collidable", "size", "pos"},
function(e)
  for e2 in all(ents) do
    if (e != e2
    and e2.collidable
    and e2.size
    and e2.pos
    and overlap(e, e2)) then
      -- don't die of own bullet
      if ((e.shooter and e.shooter.shooter == e2)
      or (e2.shooter and e2.shooter.shooter == e)) then
        --skip return
      else
        -- collision between e, e2
        handle_collision(e, e2)
      end
    end
  end
end)

-- sprite drawing system.
s_draw = sys({"pos", "sprite"},
function(e)
  spr(e.sprite.sprite, e.pos.x, e.pos.y)
end)

-->8
-- ##################### helpers #############################################

-- shoot a bullet from 0 to 1
function shoot(x0, y0, x1, y1, shooter)
  local e_bullet = mk_bullet(x0, y0, x1, y1, shooter)
  add(ents, e_bullet)
  if (shooter.bm) sfx(sound_shot_bm)
  if (shooter.dstr) sfx(sound_shot_dstr)
end

-- calc next position on vector
-- from current to final pos
function bulletvector(x0, y0, x1, y1, speed)
  -- speed per tick
  speed = speed and speed or bullet_speed
  -- trj = trajectory
  -- trj = end_pos - start_pos
  local dx = x1 - x0
  local dy = y1 - y0
  -- distance to end_pos, c^2 = a^2 + b^2
  local dist = sqrt(dx^2 + dy^2)
  if (dist > speed) then
    local ratio = speed / dist
    local bullet_vx = dx * ratio
    local bullet_vy = dy * ratio
    xnew = bullet_vx + x0
    ynew = bullet_vy + y0
  else
    -- at the target
    xnew = x1
    ynew = y1
  end
  return xnew, ynew
end

-- collision handling
function handle_collision(e1, e2)
  if (e1.bullet) del(ents, e1)
  if (e2.bullet) del(ents, e2)
  local e_dstr = nil
  if (e1.bm or e2.bm) then
    sfx(sound_explosion_bm)
    lives_lost += 200 + flr(rnd(50))
  elseif (e1.dstr) then
    e_dstr = e1
  elseif (e2.dstr) then
    e_dstr = e2
  end

  if (e_dstr) then
    -- hit dstr
    sfx(sound_explosion_dstr)
    del(ents, e_dstr)
    lives_lost += 100 + flr(rnd(50))
    -- create a new dstr
    local e_newdstr = mk_dstr(e_dstr)
    add(ents, e_newdstr)
  end
end

-- detect if box a and b overlap.
-- both a and b must have comps
-- size, pos
-- original: https://mboffin.itch.io/pico8-overlap
function overlap(a,b)
  assert(a.pos)
  assert(b.pos)
  assert(a.size)
  assert(b.size)
  return not (a.pos.x >= b.pos.x + b.size.w
           or a.pos.y >= b.pos.y + b.size.h
           or a.pos.x + a.size.w <= b.pos.x
           or a.pos.y + a.size.h <= b.pos.y)
end

-- print string x-centered
function print_xcenter(string, y, color)
  local x = str_xcenter(string)
  print(string, x, y, color)
end

-- center align string at given x coordinate
-- x defaults to 64 (screen center)
-- support for wide glyphs
-- by @sparr /pico8lib
function str_xcenter(str, x)
  local w = 0
  for i = 1, #str do
   w += (sub(str,i,i) > "\127" and 4 or 2)
  end
  return (x or 64) - w
end

__gfx__
00000000111111111111111100600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001111111111c1111106660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700111111111c1c111166566000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000111111111111111164546000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000111111111111111166666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700111111111111c1c165556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000011111111111c1c1165556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111111111111111166666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06466460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06455460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66455466000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66555566000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66655666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66655666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66655666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66655666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66555566000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66555566000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06455460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06455460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00466400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
006060000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000600a8a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
600000600a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102010101010101010102010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010201010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101020101010101010101010102010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010201010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010102010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010201010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000300001465017650186501a6501b6501c6501a65015650116500a65002650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001a6502265025670176600a650026500165001650006500065000650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
