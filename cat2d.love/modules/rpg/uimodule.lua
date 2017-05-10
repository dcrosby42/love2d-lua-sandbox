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

local function checkGameWorlds(world)
  local gw = world.gameWorlds[world.situation.mapId]
  if not gw then
    gw = GameModule.newWorld({situation=world.situation})
    world.gameWorlds[world.situation.mapId] = gw
    return false
  end
  return true
end

M.newWorld = function()
  local res = {} -- Resources.load()
  local estore = buildEstore(res)

  local initialSituation = {
    playerActor="lea",
    mapId="town1",
    playerStartPosition="town-enter-west",
    playerName="dcrosby42",
    controllerId="con1",
  }

  local uiWorld = {
    bgcolor = {0,0,0},
    estore = estore,
    input = { dt=0, events={} },
    resources = res,
    situation=initialSituation,
    screenPad = {}, -- ScreenPad.initialize({controllerId="con1"})
    keyboardController = {}, -- KeyboardController.initialize({controllerId="con1", bindings=DefaultKeybdControls}),
    -- gameWorld = GameModule.newWorld({situation=initialSituation}),
    gameWorlds = {},
    followingAvatar = 'lea',
    followingPlayer = 'dcrosby42',
  }
  checkGameWorlds(uiWorld)

  return uiWorld, nil
end

local Updaters = {}

Updaters.tick = function(world,action)
  -- world.gameWorld, gameFx = GameModule.updateWorld(world.gameWorld, action)
  world.gameWorld, gameFx = GameModule.updateWorld(world.gameWorlds[world.situation.mapId], action)
  if gameFx then
    for i=1,#gameFx do
      print("gameWorldFx after tick update: "..tdebug(gameFx[i]))
      if gameFx[i].type == 'door' then
        local doorLink = gameFx[i].value
        print("door! "..tflatten(doorLink))

        -- local situation = world.gameWorld.situation
        -- situation.mapId = doorLink.mapName
        -- -- situation.playerActor = "lea"
        -- situation.playerStartPosition = doorLink.spawnName
        -- GameModule.updateWorld(world.gameWorld, {type='situationChanged',situation=situation})
        world.situation.mapId = doorLink.mapName
        world.situation.playerStartPosition = doorLink.spawnName
        if checkGameWorlds(world) then
          local gw = world.gameWorlds[world.situation.mapId]
          if not gw then
            print("WTF no gw for "..world.situation.mapId)
          end
          GameModule.updateWorld(gw, {type='situationChanged',situation=world.situation})
        end
      end
    end
  end

  -- Sync the UI ecs world with info from the gameWorld ecs, namely the viewport:
  world.gameWorld.estore:walkEntities(hasComps('player','pos'), function(e)
    if e.player.name == world.followingPlayer then
      -- print("ui viewport tracking "..e.player.name.." "..e.pos.x..","..e.pos.y)
      addInputEvent(world.input, {type='viewportTarget', x=e.pos.x, y=e.pos.y})
    end
  end)

  -- Update the UI ecs world:
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
  if action.state == 'pressed' then
    -- if action.key == '1' then
    --   local situation = world.gameWorld.situation
    --   situation.mapId = "town1"
    --   situation.playerActor = "lea"
    --   situation.playerStartPosition = "town-enter-west"
    --   GameModule.updateWorld(world.gameWorld, {type='situationChanged',situation=situation})
    --   -- respawnSituation(world.situation, world.estore, world.resources)
    -- end
    -- if action.key == '2' then
    --   local situation = world.gameWorld.situation
    --   situation.mapId = "town2"
    --   situation.playerActor = "jeff"
    --   situation.playerStartPosition = "town-enter-west"
    --   GameModule.updateWorld(world.gameWorld, {type='situationChanged',situation=situation})
    --   -- respawnSituation(world.situation, world.estore, world.resources)
    -- end
  end

  -- world.gameWorld, gameWorldFx = GameModule.updateWorld(world.gameWorld, action)
  world.gameWorld, gameWorldFx = GameModule.updateWorld(world.gameWorlds[world.situation.mapId], action)
  if gameWorldFx then
    print("gameWorldFx after keyboard update: "..tdebug(gameWorldFx))
  end

  if action.type == 'keyboard' and action.state == 'pressed' then
    if action.key == 'p' then
      print(world.gameWorld.estore:debugString())
    elseif action.key == 'm' then
      -- print(tdebug(world.gameworld.resources.maps))
      for k,map in pairs(world.gameWorld.resources.maps) do
        print(k)
        print(tdebug1(map().itemList))
      end

      -- world.gameWorld.resources

    end
  end
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

local function drawDebugGrid()
  local t = 0
  local b = 1000
  local l = 0
  local r = 1000
  local size = 100
  for y=t,b,size do
    love.graphics.line(l,y, r,y)
  end
  for x=l,r,size do
    love.graphics.line(x,t, x,b)
  end
end

M.drawWorld = function(world)
  love.graphics.setBackgroundColor(unpack(world.bgcolor))

  -- local pent = world.estore:getEntity(world.localPlayerEid)
  -- love.graphics.translate(512 - math.floor(pent.pos.x), 384 - math.floor(pent.pos.y))

  world.estore:seekEntity(hasComps('viewport'), function(e)
    -- x toggles between -158, -122
    love.graphics.translate(-e.viewport.x, -e.viewport.y)
  end)

  -- drawSystem(world.estore, nil, world.resources)

  GameModule.drawWorld(world.gameWorlds[world.situation.mapId])

  drawDebugGrid()
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
