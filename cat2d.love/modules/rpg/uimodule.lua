local here = (...):match("(.*/)[^%/]+$")

require 'ecs/ecshelpers'
require 'comps'

local GameModule = require(here .. '/gamemodule')

local KeyboardController = require 'input/keyboardcontroller'

local Estore = require 'ecs/estore'

local Resources = require(here.."/resources")

local timerSystem = require 'systems/timer'
local selfDestructSystem = require 'systems/selfdestruct'
local outputCleanupSystem = require 'systems/outputcleanup'

local buildEstore

local Comp = require 'ecs/component'
Comp.define("viewport", {'x',0,'y',0,'w',0,'h',0,'target','','offx',0,'offy',0})

local viewportSystem = defineUpdateSystem(hasComps('viewport'), function(e,estore,input,res)
  local vp = e.viewport
  forEach(input.events.viewportTarget, function(_, evt)
    vp.x = evt.x - (vp.w / 2)
    vp.y = evt.y - (vp.h / 2)
  end)
end)


local runSystems = iterateFuncs({
  outputCleanupSystem,
  timerSystem,
  selfDestructSystem,
  viewportSystem,
})

local M ={}

M.newWorld = function()
  local res = {} -- Resources.load()
  local estore = buildEstore(res)

  local uiWorld = {
    bgcolor = {0,0,0},
    estore = estore,
    input = { dt=0, events={} },
    resources = res,
    screenPad = {}, -- ScreenPad.initialize({controllerId="con1"})
    keyboardController = {}, -- KeyboardController.initialize({controllerId="con1", bindings=DefaultKeybdControls}),
    gameWorld = GameModule.newWorld(),

    followingAvatar = 'lea',
    followingPlayer = 'dcrosby42',
  }

  return uiWorld, nil
end

local Updaters = {}

Updaters.tick = function(world,action)
  world.gameWorld, effects = GameModule.updateWorld(world.gameWorld, action)

  -- world.gameWorld.estore:walkEntities(hasComps('avatar','pos'), function(e)
  --   if e.avatar.name == world.followingAvatar then
  --     addInputEvent(world.input, {type='viewportTarget', id=followingAvatar, x=e.pos.x, y=e.pos.y})
  --   end
  -- end)
  world.gameWorld.estore:walkEntities(hasComps('player','pos'), function(e)
    if e.player.name == world.followingPlayer then
      addInputEvent(world.input, {type='viewportTarget', x=e.pos.x, y=e.pos.y})
    end
  end)

  world.input.dt = action.dt
  runSystems(world.estore, world.input, world.resources)
  world.input.events = {} -- clear the events that happened leading up to this tick

  return world --, effects
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
  GameModule.updateWorld(world.gameWorld, action)
end

-- Updaters.keyboard = function(world,action)
--   KeyboardController.handleKeyAction(world.keyboardController, action, world.input)
--   if action.state == 'pressed' then
--     if action.key == '1' or action.key == '2' then
--       world.estore:walkEntities(hasComps('map'),function(e)
--         e.map.id = 'town'..action.key
--       end)
--     end
--   end
--   return world, nil
-- end

M.updateWorld = function(world, action)
  local fn = Updaters[action.type]
  if fn then
    return fn(world,action)
  end
  return world, nil
end

M.drawWorld = function(world)
  love.graphics.setBackgroundColor(unpack(world.bgcolor))

  -- local pent = world.estore:getEntity(world.localPlayerEid)
  -- love.graphics.translate(512 - math.floor(pent.pos.x), 384 - math.floor(pent.pos.y))

  world.estore:seekEntity(hasComps('viewport'), function(e)
    love.graphics.translate(-e.viewport.x, -e.viewport.y)
  end)

  -- drawSystem(world.estore, nil, world.resources)

  GameModule.drawWorld(world.gameWorld)

  -- love.graphics.draw(spritesheet.image, spritesheet.quads.dude, 400,200, 0, 2,2)

  -- ScreenPad.draw(world.screenPad)
end



buildEstore = function(res)
  local estore = Estore:new()

  estore:newEntity({
    {'viewport', {w=1024,h=768,target='dcrosby'}}
  })

  return estore
end

return M
