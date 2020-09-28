pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- last stand of the bismarck
-- by @apa64
--  v. 0.1
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

function _init()
  dstr1 = {}
  dstr1.pos = {}
  dstr1.pos.x = 20
  dstr1.pos.y = 20
  dstr1.drawable = {}
  dstr1.drawable.spr = 3
  dstr1.t = 0
  dstr1.wait = 0.05
  dstr1.speed = 1
  dstr1.r = 55
  dstr1.angle = 0
  originx = 63
  originy = 63

  sight = {}
  sight.drawable = {}
  sight.drawable.spr = 48
  sight.pos = {}
  sight.pos.x = 40
  sight.pos.y = 40
  -- create entities
  -- store ents in master table
end

function _update()
  if (t() - dstr1.t > dstr1.wait) then
    --dstr1.pos.x = (dstr1.pos.x + 1) % 128
    dstr1.t = t()
    --moves along track
    dstr1.angle += dstr1.speed
    dstr1.pos.x = originx + dstr1.r * cos(dstr1.angle/360)
    dstr1.pos.y = originy + dstr1.r * sin(dstr1.angle/360)
    if dstr1.angle>360 then dstr1.angle=0
    elseif dstr1.angle<0 then dstr1.angle=360
    end
  end
  if (btn(0)) sight.pos.x -= 8
  if (btn(1)) sight.pos.x += 8
  if (btn(2)) sight.pos.y -= 8
  if (btn(3)) sight.pos.y += 8

  -- run systems
end

function _draw()
  cls(1)
  map()
  print("last stand of the bismarck",12,2)
  print(flr(t()),0,8)
  spr(dstr1.drawable.spr, dstr1.pos.x, dstr1.pos.y)
  spr(sight.drawable.spr, sight.pos.x, sight.pos.y)
  -- run draw system
end

-->8
-- #################### entities
-->8
-- ################## components
-->8
-- ##################### systems
-->8
-- ##################### helpers

__gfx__
00000000111111111111111100600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001111111111c1111106660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700111111111c1c111166566000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000111111111111111164546000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000111111111111111166666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700111111111111c1c165556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000011111111111c1c1165556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111111111111111166666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000006600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000066660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000646646000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000645546000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006645546600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006655556600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006665566600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006665566600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006665566600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006665566600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006655556600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006655556600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000645546000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000645546000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000046640000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000006600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0101010101010110110101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010120210101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010201010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010102010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010201010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
