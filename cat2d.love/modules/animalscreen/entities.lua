local Comps = require 'comps'
local Estore = require 'ecs.estore'

local Entities={}

function Entities.initialEntities()
  local estore = Estore:new()

  local sp = Entities.zooKeeper(estore)
  -- local lion = Entities.animal(sp,"lion")
  -- lion.pos.x = 100
  -- lion.pos.y = 200

  return estore
end

function Entities.zooKeeper(estore)
  return estore:newEntity({
    {'tag',{name="zookeeper"}},
    {'img', {imgId='background1', sx=1, sy=1.05}}, -- zoo_keeper.png is 731px tall, we want to stretch it to 768
    {'pos', {}},
    {'debug', {name='nextAnimal',value=1}},
  })
end

function Entities.animal(estore, kind)
  return estore:newEntity({
    {'img', {imgId=kind, sx=0.5, sy=0.5, centerx=0.5, centery=0.5}}, 
    {'pos', {}},
  })
end


return Entities
