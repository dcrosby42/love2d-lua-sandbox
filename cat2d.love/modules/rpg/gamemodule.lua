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

local buildEstore
-- local mapSystem

local runSystems = iterateFuncs({
  outputCleanupSystem,
  timerSystem,
  selfDestructSystem,
  -- mapSystem,
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
  local estore = buildEstore(res)

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

buildEstore = function(res)
  local estore = Estore:new()

  local playerCharName = 'lea'

  -- Find the start position as defined by the map data:
  local mapid = 'town1'

  local map = getMapResourceById(mapid,res)
  -- res.maps[mapid]()
  local starts = {}
  local doors = {}
  for _,obj in pairs(map.map.objects) do
    if obj.type == 'StartPosition' then
      starts[obj.name] = obj
    elseif obj.type == 'Door' then
      print(tdebug1(obj))
      print("properties:"..tdebug1(obj.properties,'  '))
      doors[obj.name] = obj
    end
  end


  local map = estore:newEntity({
    {'pos', {}},
    {'map', {id=mapid}},
    {'zChildren', {}},
  })

  for _,charStart in pairs(starts) do
    local char = map:newChild({
      {'avatar', {name=charStart.name}},
      {'pos', {x=charStart.x+(charStart.width/2),y=charStart.y+charStart.height}},
      {'vel', {}},
      {'bounds', {offx=9, offy=32, w=18, h=32}},
      {'sprite', {spriteId=charStart.name, frame="down_2", offx=16, offy=32}},
      {'scale', {sx=2, sy=2}},
      {'timer', {name='animtimer', t=0, reset=1, countDown=false, loop=true}},
      {'effect', {name='anim', timer='animtimer', path={'sprite','frame'}, animFunc='rpg_idle'}},
      {'collidable',{}},
    })
    if playerCharName == charStart.name then
      char:newComp('player',{name='dcrosby'})
      char:newComp('controller', {id='con1'})
    else
      char:newComp('script', {scriptId='idlingTownsman', params={timer='mope'}})
      char:newComp('controller',{})
      char:newComp('timer', {name='mope', countDown=false})
    end
  end

  for doorname,door in pairs(doors) do
    local doorEnt = map:newChild({
      {'tag',{name='door'}},
      {'door', {name=door.name, doorid=door.properties.id, link=door.properties.link}},
    })
    door.properties.entityid=doorEnt.eid
  end

  return estore
end

-- mapSystem = defineUpdateSystem({'map'}, function(e,estore,input,res)
-- end)

return M
