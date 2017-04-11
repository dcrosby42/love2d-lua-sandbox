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
local zChildrenSystem = require 'systems/zchildren'
local drawSystem = require 'systems/drawstuff'
local drawViaMap = require(here.."drawviamap")

local avatarControlSystem = require(here.."/avatarcontrolsystem")
local moverSystem = require(here.."/moversystem")
local animSystem = require(here.."/animsystem")
local scriptSystem = require(here.."/scriptsystem")

local M ={}

local initialEstore

local runSystems = iterateFuncs({
  outputCleanupSystem,
  timerSystem,
  selfDestructSystem,
  controllerSystem,
  scriptSystem,
  avatarControlSystem,
  moverSystem,
  animSystem,
  zChildrenSystem,
  effectsSystem,
})

DefaultKeybdControls = { up='w', left='a', down='s', right='d' }



M.newWorld = function()
  local res = Resources.load()
  local estore = initialEstore(res)

  local world = {
    bgcolor = {0,0,0},
    estore = estore,
    input = { dt=0, events={} },
    resources = res,
    screenPad = {}, -- ScreenPad.initialize({controllerId="con1"})
    keyboardController = KeyboardController.initialize({controllerId="con1", bindings=DefaultKeybdControls}),
  }

  estore:walkEntities(hasComps('player'), function(e)
    if e.player.name == 'dcrosby' then
      world.localPlayerEid = e.eid
    end
  end)

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

  -- local pent = world.estore:getEntity(world.localPlayerEid)
  -- love.graphics.translate(512 - math.floor(pent.pos.x), 384 - math.floor(pent.pos.y))

  -- drawSystem(world.estore, world.resources)
  drawViaMap(world.estore, world.resources)



  -- love.graphics.draw(spritesheet.image, spritesheet.quads.dude, 400,200, 0, 2,2)

  -- ScreenPad.draw(world.screenPad)
end

local Comp = require 'ecs/component'
Comp.define("door", {'doorid','','link',''})

local function avatarComps(actorName)
  return {
    {'avatar', {name=actorName}},
    -- {'pos', {x=charStart.x+(charStart.width/2),y=charStart.y+charStart.height}},
    {'vel', {}},
    {'bounds', {offx=9, offy=32, w=18, h=32}},
    {'sprite', {spriteId=actorName, frame="down_2", offx=16, offy=32}},
    {'scale', {sx=2, sy=2}},
    {'timer', {name='animtimer', t=0, reset=1, countDown=false, loop=true}},
    {'effect', {name='anim', timer='animtimer', path={'sprite','frame'}, animFunc='rpg_idle'}},
    {'collidable',{}},
  }
end

local function startPosition(startPos)
  return {
    {'pos', {x=startPos.x+(startPos.width/2),y=startPos.y+startPos.height}}
  }
end

local function playerControl(playerName, controllerId)
  return {
    {'player',{name=playerName}},
    {'controller',{id=controllerId}}
  }
end

local function idlingTownsman()
  return {
    {'script', {scriptId='idlingTownsman', params={timer='mope'}}},
    {'controller',{}},
    {'timer', {name='mope', countDown=false}},
  }
end

initialEstore = function(res)
  local situation = {
    playerActor="lea",
    mapId="town1",
    playerStartPosition="town-enter-west",
    playerName="dcrosby42",
    controllerId="con1",
  }

  local estore = Estore:new()

  -- Find the start position as defined by the map data:
  local map = getMapResourceById(situation.mapId, res)
  local objectsByType = {}
  for _,obj in pairs(map.map.objects) do
    local sub = objectsByType[obj.type]
    if not sub then
      sub = {}
      objectsByType[obj.type] = sub
    end
    sub[obj.name] = obj
  end
  -- print("objectsByType: "..tdebug1(objectsByType))
  -- print("objectsByType.StartPosition: "..tdebug1(objectsByType.StartPosition))
  -- print("objectsByType.Door: "..tdebug1(objectsByType.Door))

  local map = estore:newEntity({
    {'pos', {}},
    {'map', {id=situation.mapId}},
    {'zChildren', {}},
  })

  -- Spawn player character
  local playerComps = avatarComps(situation.playerActor)
  tconcat(playerComps, startPosition(objectsByType.StartPosition[situation.playerStartPosition]))
  tconcat(playerComps, playerControl(situation.playerName, situation.controllerId))
  map:newChild(playerComps)

  -- Spawn NPCs at start positions
  for name,startPos in pairs(objectsByType.StartPosition) do
    if startPos.properties.actor then
      print(tdebug1(startPos))
      local comps = avatarComps(startPos.properties.actor)
      tconcat(comps, startPosition(startPos))
      tconcat(comps, idlingTownsman(startPos))
      map:newChild(comps)
    end
  end

  -- Spawn door entities
  for doorname,door in pairs(objectsByType.Door) do
    local doorEnt = map:newChild({
      {'tag',{name='door'}},
      {'door', {name=door.name, doorid=door.properties.id, link=door.properties.link}},
    })
    door.properties.entityid=doorEnt.eid
  end

  return estore
end

return M
