local here = (...):match("(.*/)[^%/]+$")

require 'ecs/ecshelpers'
require 'comps'

local Snow = require 'systems/snow'
local Estore = require 'ecs/estore'
local Resources = require(here.."resources")
local BoxyCat = require(here..'/boxcat')
local AnimCat = require(here..'/animcat')
local Field = require(here..'/field')

local timerSystem = require 'systems/timer'
local selfDestructSystem = require 'systems/selfdestruct'
local outputCleanupSystem = require 'systems/outputcleanup'
local effectsSystem = require 'systems/effects'
local controllerSystem = require 'systems/controller'
local drawSystem = require 'systems/drawstuff'
local zChildrenSystem = require 'systems/zchildren'
local avatarControlSystem = require(here..'/avatarcontrolsystem')
local moverSystem = require(here..'/moversystem')

local keyboardControllerInput = require(here..'/keyboardcontrollerinput')
-- local ScreenPad = require(here..'/screenpad')
local ScreenPad = require(here..'/screenpad2')
local Joystick = require(here..'/joystick')
local Waypoint = require(here..'/waypoint')

local M ={}

local buildEstore

local runSystems = iterateFuncs({
  outputCleanupSystem,
  timerSystem,
  Snow.System,
  selfDestructSystem,
  Waypoint.System,
  controllerSystem,
  avatarControlSystem,
  moverSystem,
  zChildrenSystem,
  effectsSystem,
})

local estoreCountup, printCountup

M.newWorld = function()
  local res = Resources.load()
  local w = {
    bgcolor = {0,0,0},
    estore = buildEstore(res),
    input = { dt=0, events={} },
    resources = res,
    screenPad = ScreenPad.initialize({controllerId="con1"})
  }

  return w, nil
end

local controllerState = {}

M.updateWorld = function(world, action)
  local effects = nil

  if action.type == 'tick' then
    world.input.dt = action.dt

    local estore = world.estore
    runSystems(estore, world.input, world.resources)

    world.input.events = {}

    estore:search(hasComps('output'), function(e)
      effects = {}
      for _,out in pairs(e.outputs) do
        effects[#effects+1] = {type=out.kind, value=out.value}
      end
    end)


  elseif action.type == 'mouse' then
    if love.keyboard.isDown("lshift") then
      Waypoint.handleMouse(action, world.screenPad.controllerId, world.input)
    end
    ScreenPad.handleMouse(world.screenPad, action, world.input)

  elseif action.type == 'touch' then
    ScreenPad.handleTouch(world.screenPad, action, world.input)
    Waypoint.handleTouch(action, world.screenPad.controllerId, world.input)

  elseif action.type == 'joystick' then
    Joystick.handleJoystick(action, world.screenPad.controllerId, world.input)
  elseif action.type == 'keyboard' then
    addInputEvent(world.input, action)

    local key = action.key
    if key == "c" and action.state == 'pressed' then
      printCountup(estoreCountup(world.estore))
    elseif key == "p" and action.state == 'pressed' then
      print("============================================================================")
      print(world.estore:debugString())
    elseif key == "x" and action.state == 'pressed' then
      print("Manual switchover")
      effects = {
        {type='transition', value='leave'}
      }
    elseif key == "b" and action.state == 'pressed' then
      world.estore:seekEntity(hasTag('debug'), function(e)
        e.debugs.drawBounds.value = not e.debugs.drawBounds.value
      end)
    else
      keyboardControllerInput(world.input, { up='w', left='a', down='s', right='d' }, 'con1', action, controllerState)
      keyboardControllerInput(world.input, { up='k', left='h', down='j', right='l' }, 'con2', action, controllerState)
    end

  end

  return world, effects
end

M.drawWorld = function(world)
  love.graphics.setBackgroundColor(unpack(world.bgcolor))

  drawSystem(world.estore, nil, world.resources)

  ScreenPad.draw(world.screenPad)
end

buildEstore = function(res)
  local estore = Estore:new()

  estore:newEntity({
    {'tag', {name='debug'}},
    {'debug', {name='drawBounds',value=false}}
  })

  local base = estore:newEntity({
    {'pos', {}},
  })

  -- terrain image
  base:newChild({
    { 'name', {name='name'}},
    { 'img', {imgId='snowField'}},
    { 'pos', {0,0}},
  })

  -- Add the field and trees
  local field = Field.newFieldEntity(estore, res)
  base:addChild(field)

  -- Create a cat
  local cat = AnimCat.newEntity(estore, res)
  -- take control of cat
  cat:newComp('controller', {id='con1'})
  field:addChild(cat)

  -- Add snow
  base:addChild(Snow.newSnowMachine(estore, {large=2, small=1, dy=15}))
  base:addChild(Snow.newSnowMachine(estore, {large=3, small=1, dy=30}))
  base:addChild(Snow.newSnowMachine(estore, {large=5, small=3, dy=60}))

  return estore
end

function estoreCountup(estore)
  local compCounts,ccount = tcountby(estore.comps, 'type')
  local ecount = tcount(estore.ents)
  return {
    compCounts = compCounts,
    numComps = ccount,
    numEnts = ecount,
    eid = estore.eidCounter,
    cid = estore.cidCounter,
  }
end
function printCountup(c)
  print("ents="..c.numEnts.." comps="..c.numComps.." eid="..c.eid.." cid="..c.cid..tdebug(c.compCounts,'  '))
end

return M
