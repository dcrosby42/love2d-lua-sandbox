package.path = package.path .. ';../?.lua'

require 'helpers'

local Estore = require 'estore'
local Comp = require 'component'

local T = Comp.types

-- print("timer pool A: "..T.timer._pool:debugString())
-- print(estore:debugString())
-- print(Comp.debugString(e1.imgs.dude))

print("----------------------------------------------------------------------------")

Comp.define("trans", {'x',0,'y',0,'w',50,'h',50,'ax',0.5,'ay',1,'r',0}, {initSize=1,incSize=0,mulSize=17})
Comp.define("img", {})
Comp.define("timer",{'event',"", 't',0, 'init',0, 'loop',false}, {initSize=1,incSize=2})

estore = Estore:new()
e1 = estore:newEntity()

estore:newComp(e1, 'trans')
estore:newComp(e1, 'img', {name='dude'})

local beepTimer = estore:newComp(e1, 'timer', {name='beeper',event='beep',loop=true,init=1})
local deathTimer = estore:newComp(e1, 'timer', {name='death',event='remove',init=5})

e1.timers.death.t = 4.2

e2 = estore:newEntity()
estore:transferComp(e1,e2,deathTimer) 
print(estore:debugString())

estore:removeComp(beepTimer)
estore:removeComp(deathTimer)

e1.trans.x = 111
e1.trans.y = 222
e1.trans.w = 333
e1.trans.h = 444
e1.trans.ax = 555
e1.trans.ay = 666
e1.trans.r = 777
print(estore:debugString())


estore:removeComp(e1.trans)
print(estore:debugString())

print("================================================================================")
tpool = T.trans._pool
print("trans pool A: "..tpool:debugString())

tr = T.trans.copy()
print(Comp.debugString(tr))
print("trans pool B: "..tpool:debugString())
Comp.release(tr)
print("trans pool C: "..tpool:debugString())

tr = T.trans.cleanCopy()
print(Comp.debugString(tr))
print("trans pool D: "..tpool:debugString())

tr2 = T.trans.copy()
print(Comp.debugString(tr2))
print("trans pool E: "..tpool:debugString())
Comp.release(tr)
Comp.release(tr2)
print("trans pool F: "..tpool:debugString())
