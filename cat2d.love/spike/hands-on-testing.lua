Estore = require 'ecs/estore'
require 'ecs/ecshelpers'
Comps = require 'comps'

estore = Estore:new()
-- print(estore:debugString())

x = 50
y = 75
w = 10
h = 10

tree = estore:buildEntity({
  {'name', {name='tree'}},
  {'pos', {x=x, y=y}},
  {'bounds', {offx=-w/2,offy=-w, w=w,h=h}},
}, {
  {
    {'name', {name='trunk'}},
    {'pos', {x=0,y=0}},
    {'rect', {offx=-w/2, offy=-h, w=w,h=h,color={0,0,0}}},
  },
  {
    {'name', {name='bush'}},
    {'pos', {x=0,y=-h}},
    {'rect', {offx=-w/2, offy=-h, w=w,h=h,color={0,0,0}}},
  },
})


scene = estore:buildEntity({
  {'name', {name='scene'}},
  {'pos', {x=0, y=0}},
})

scene:addChild(tree)

-- tree:newChild({
--   {'name', {name='bush'}},
--   {'pos', {x=0,y=-h}},
--   {'rect', {offx=-w/2, offy=-h, w=w,h=h,color={0,0,0}}},
-- })
--
-- tree:newChild({
--   {'name', {name='trunk'}},
--   {'pos', {x=0,y=0}},
--   {'rect', {offx=-w/2, offy=-h, w=w,h=h,color={0,0,0}}},
-- })


-- print(entityDebugString(tree))
print(estore:debugString())

bush = tree:getChildren()[1]
-- print(entityDebugString(bush))
trunk = tree:getChildren()[2]
-- print(entityDebugString(trunk))
