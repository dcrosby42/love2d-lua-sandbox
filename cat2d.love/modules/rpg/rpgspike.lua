local here = (...):match("(.*/)[^%/]+$")

require 'ecs/ecshelpers'
require 'comps'

local KeyboardController = require 'input/keyboardcontroller'

local Estore = require 'ecs/estore'

local Resources = require(here.."/resources")

local timerSystem = require 'systems/timer'
local selfDestructSystem = require 'systems/selfdestruct'
local outputCleanupSystem = require 'systems/outputcleanup'
local effectsSystem = require 'systems/effects'
local controllerSystem = require 'systems/controller'
local drawSystem = require 'systems/drawstuff'

local M ={}

local buildEstore
local mapSystem

local runSystems = iterateFuncs({
  outputCleanupSystem,
  timerSystem,
  selfDestructSystem,
  -- mapSystem,
  controllerSystem,
  effectsSystem,
})

DefaultKeybdControls = { up='w', left='a', down='s', right='d' }

M.newWorld = function()
  local res = Resources.load()
  local world = {
    bgcolor = {0,0,0},
    estore = buildEstore(res),
    input = { dt=0, events={} },
    resources = res,
    screenPad = {}, -- ScreenPad.initialize({controllerId="con1"})
    keyboardController = KeyboardController.initialize({controllerId="con1", bindings=DefaultKeybdControls}),
  }
  return world, nil
end

local Updaters = {}

Updaters.tick = function(world,action)
  world.input.dt = action.dt

  runSystems(world.estore, world.input, world.resources)

  world.input.events = {} -- clear the events that happened leading up to this tick

  effects = {}
  world.estore:search(hasComps('output'), function(e)
    for _,out in pairs(e.outputs) do
      table.insert(effects,{type=out.kind, value=out.value})
    end
  end)
  return world, effects
end

-- Updaters.mouse = function(world,action)
--   ScreenPad.handleMouse(world.screenPad, action, world.input)
--   return world, nil
-- end

-- Updaters.touch = function(world,action)
--   ScreenPad.handleTouch(world.screenPad, action, world.input)
--   return world, nil
-- end

-- Updaters.joystick = function(world,action)
--   Joystick.handleJoystick(action, world.screenPad.controllerId, world.input)
--   return world, nil
-- end

Updaters.keyboard = function(world,action)
  KeyboardController.handleKeyAction(world.keyboardController, action, world.input)
  if action.state == 'pressed' then
    if action.key == '1' or action.key == '2' then
      world.estore:walkEntities(hasComps('map'),function(e)
        e.map.id = 'town'..action.key
      end)
    end
  end
  return world, nil
end

M.updateWorld = function(world, action)
  local fn = Updaters[action.type]
  if fn then
    return fn(world,action)
  end
  return world, nil
end

M.drawWorld = function(world)
  love.graphics.setBackgroundColor(unpack(world.bgcolor))

  drawSystem(world.estore, nil, world.resources)

  -- ScreenPad.draw(world.screenPad)
end

buildEstore = function(res)
  local estore = Estore:new()

  local mapid = 'town1'
  local map = res.maps[mapid]()
  for _,obj in ipairs(map.objects) do
    print(tdebug1(obj))
  end

  estore:newEntity({
    {'pos', {}},
    {'map', {id=mapid}},
  })

  return estore
  --
  -- estore:newEntity({
  --   {'tag', {name='debug'}},
  --   {'debug', {name='drawBounds',value=false}}
  -- })
  --
  -- local base = estore:newEntity({
  --   {'pos', {}},
  -- })
  --
  -- -- terrain image
  -- base:newChild({
  --   { 'name', {name='name'}},
  --   { 'img', {imgId='snowField'}},
  --   { 'pos', {0,0}},
  -- })
  --
  -- -- Add the field and trees
  -- local field = Field.newFieldEntity(estore, res)
  -- base:addChild(field)
end

mapSystem = defineUpdateSystem({'map'}, function(e,estore,input,res)
end)

return M
