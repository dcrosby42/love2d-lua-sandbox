require 'ecs/ecshelpers'
local Estore = require 'ecs/estore'

require 'flags'
require 'comps'

local iconAdderSystem = require 'systems/iconadder'
local timerSystem = require 'systems/timer'
local snowSystem = require 'systems/snow'
local drawSystem = require 'systems/drawstuff'
local Etree = require 'ecs/entitytree'

-- resource name shortcuts 
local catIcon = "images/black-cat-icon.png"
local arcticCatTitle = "images/arctic_cat_title.png"

local DoUpdate = iterateFuncs({
  timerSystem,
  snowSystem,
  iconAdderSystem,
  Etree.etreeSystem,
})

local DoDraw = iterateFuncs({
  drawSystem,
})

local M ={}

local newSnowScene

M.newWorld = function()
  local w = {
    bgcolor = {0,0,100}, 
    scene = newSnowScene(),
    input = { dt=0, events={} },
    resources = {
      images={
        [catIcon] = love.graphics.newImage(catIcon),
        [arcticCatTitle] = love.graphics.newImage(arcticCatTitle),
      }
    },
  }

  return w, nil
end

M.updateWorld = function(world, action)
  local effects = nil

  if action.type == 'tick' then
    world.input.dt = action.dt

    local estore = world.scene
    DoUpdate(estore, world.input, world.resources)

    world.input.events = {}

  elseif action.type == 'mouse' then
    if action.button == 1 then
      addInputEvent(world.input, {type='tap', id='p1', x=action.x, y=action.y})
    elseif button == 2 then
      addInputEvent(world.input, {type='untap', id='p1', x=action.x, y=action.y})
    end

  elseif action.type == 'keyboard' then
    local estore = world.scene
    local key = action.key
    if key == "p" then
      print("============================================================================")
      print(estore:debugString())
    elseif key == "g" then
      if estore.etree then
        print("============================================================================")
        print("-- Entity tree (Estore.etree):")
        print(tdebug(estore.etree.ROOT))
      end
    elseif key == "x" then
      effects = {
        {type='exit'}
      }
    end

  end

  return world, effects
end

M.drawWorld = function(world)
  love.graphics.setBackgroundColor(unpack(world.bgcolor))

  DoDraw(world.scene, nil, world.resources)
end

-- ---------------------------------------------------------------
function newSnowScene()
  local estore = Estore:new()
  local group = buildEntity(estore, {
    {'tag', {name='snowScene'}},
    {'filter', {bits = bit32.bor(Flags.Update, Flags.Draw)}},
  })

  buildEntity(estore, {
    {'iconAdder', {id='p1', imgId=catIcon, tagName='cattish'}},
    {'parent', {parentEid=group.eid}},
  })

  buildEntity(estore, {
    {'snowmachine', {large=2,small=1}},
    {'vel', {dx=0, dy=15}},
    {'bounds', {x=0,y=0, w=love.graphics.getWidth(), h=love.graphics.getHeight()}},
    {'timer', {name='flake', reset=0.2, loop=true}},
    {'timer', {name='acc', countDown=false}},
    {'parent', {parentEid=group.eid, order=1}},
  })

  buildEntity(estore, {
    {'snowmachine', {large=3,small=1}},
    {'vel', {dx=0, dy=30}},
    {'bounds', {x=0,y=0, w=love.graphics.getWidth(), h=love.graphics.getHeight()}},
    {'timer', {name='flake', reset=0.2, loop=true}},
    {'timer', {name='acc', countDown=false}},
    {'parent', {parentEid=group.eid, order=2}},
  })

  buildEntity(estore, {
    {'tag', {name='title'}},
    {'img', {imgId=arcticCatTitle}},
    {'pos', {x=20, y=100}},
    -- {'bounds', {x=tap.x, y=tap.y, w=256, h=256}},
    {'parent', {parentEid=group.eid, order=3}}
  })

  buildEntity(estore, {
    {'snowmachine', {large=5, small=3}},
    {'vel', {dx=0, dy=60}},
    {'bounds', {x=0,y=0, w=love.graphics.getWidth(), h=love.graphics.getHeight()}},
    {'timer', {name='flake', reset=0.2, loop=true}},
    {'timer', {name='acc', countDown=false}},
    {'parent', {parentEid=group.eid, order=4}},
  })
  
  estore:updateEntityTree()
  return estore
end

-- ---------------------------------------------------------------
return M
