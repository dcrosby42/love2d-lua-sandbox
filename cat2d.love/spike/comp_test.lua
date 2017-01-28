package.path = package.path .. ';../?.lua'

require 'helpers'

local ObjPool = require 'objpool'
local Estore = require 'estore'
local Comp = require 'component'


Pos = Comp({t="pos",id=0, x=0,y=0,w=50,h=50,ax=0.5,ay=1,r=0})

print(Pos._pool:debugStringFull())
p1 = Pos.copy()
print(Pos._pool:debugStringFull())
p1.id=1
p2 = Pos.copy(p1)
print(Pos._pool:debugStringFull())
p2.id=2
print("p1: "..flattenTable(p1))
print("p2: "..flattenTable(p2))
p3 = Pos.copy()
p3.id = 3
p4 = Pos.copy()
p4.id = 4
p5 = Pos.copy()
p5.id = 5
p6 = Pos.copy()
p6.id = 6


Pos.release(p1)
print(Pos._pool:debugStringFull())
Pos.release(p2)
print(Pos._pool:debugStringFull())
Pos.release(p3)
Pos.release(p4)
Pos.release(p5)
Pos.release(p6)
print(Pos._pool:debugStringFull())


estore = Estore:new()
--
-- e1 = estore:newEntity()
-- e1.pos = {t="pos",x=0,y=0,w=50,h=50,ax=0.5,ay=1,r=0}
-- e1.pic = {t="pic",name="cat.jpg"}
-- e1.timers = {{t="timer",name="ping"},{t="timer"}}
--
