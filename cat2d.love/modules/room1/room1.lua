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
local moverSystem = require(here..'/moversystem')

local M ={}

local buildEstore
local kbdDpadInput

local runSystems = iterateFuncs({
  outputCleanupSystem,
  timerSystem,
  Snow.System,
  selfDestructSystem,
  controllerSystem,
  moverSystem,
  zChildrenSystem,
  effectsSystem,
})


M.newWorld = function()
  local res = Resources.load()
  local w = {
    bgcolor = {0,0,0},
    estore = buildEstore(res),
    input = { dt=0, events={} },
    resources = res,
  }

  return w, nil
end

local ControllerState = {
  leftAxes = {
    x = 0,
    y = 0,
  },
  buttons = {
    ['1'] = 0,
    ['2'] = 0,
    ['3'] = 0,
    ['4'] = 0,
    start=0,
    select=0,
    leftBumper=0,
    leftTrigger=0,
    rightBumper=0,
    rightTrigger=0,
  },
}

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
        -- print("Effect: "..out.kind)
        effects[#effects+1] = {type=out.kind, value=out.value}
      end
    end)

  -- elseif action.type == 'mouse' then
  --   if action.button == 1 then
  --     if action.state == "pressed" then
  --       addInputEvent(world.input, {type='tap', id='p1', x=action.x, y=action.y})
  --     end
  --   elseif action.button == 2 then
  --     if action.state == "pressed" then
  --       addInputEvent(world.input, {type='untap', id='p1', x=action.x, y=action.y})
  --     end
  --   end

  elseif action.type == 'keyboard' then
    addInputEvent(world.input, action)

    local key = action.key
    if key == "p" then
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
      local hit = kbdDpadInput(world, { up='w', left='a', down='s', right='d' }, 'con1', action, controllerState)
      if not hit then
        kbdDpadInput(world, { up='k', left='h', down='j', right='l' }, 'con2', action, controllerState)
      end
    end

  end

  return world, effects
end

M.drawWorld = function(world)
  love.graphics.setBackgroundColor(unpack(world.bgcolor))

  drawSystem(world.estore, nil, world.resources)
end

function kbdDpadInput(world, map, targetId, action, controllerState)
  local key = action.key
  if key == map.up then
    local mag = 0
    if action.state == 'pressed' then
      controllerState.up = true
      mag = -1
    else
      controllerState.up = false
      if controllerState.down then mag = 1 end
    end
    addInputEvent(world.input, {type='controller', id=targetId, input="lefty", action=mag})
    return true

  elseif key == map.down then
    local mag = 0
    if action.state == 'pressed' then
      controllerState.down = true
      mag = 1
    else
      controllerState.down = false
      if controllerState.up then mag = -1 end
    end
    addInputEvent(world.input, {type='controller', id=targetId, input="lefty", action=mag})
    return true

  elseif key == map.left then
    local mag = 0
    if action.state == 'pressed' then
      controllerState.left = true
      mag = -1
    else
      controllerState.left = false
      if controllerState.right then mag = 1 end
    end
    addInputEvent(world.input, {type='controller', id=targetId, input="leftx", action=mag})
    return true
  elseif key == map.right then
    local mag = 0
    if action.state == 'pressed' then
      controllerState.right = true
      mag = 1
    else
      controllerState.right = false
      if controllerState.left then mag = -1 end
    end
    addInputEvent(world.input, {type='controller', id=targetId, input="leftx", action=mag})
    return true

  end
  return false
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
  -- local cat = BoxyCat.newCatEntity_boxy(estore, res)
  local cat = AnimCat.newEntity(estore, res)
  -- take control of cat
  cat:newComp('controller', {id='con1'})
  cat:newComp('name', {name='Player1'})
  field:addChild(cat)

  -- Add snow
  base:addChild(Snow.newSnowMachine(estore, {large=2, small=1, dy=15}))
  base:addChild(Snow.newSnowMachine(estore, {large=3, small=1, dy=30}))
  base:addChild(Snow.newSnowMachine(estore, {large=5, small=3, dy=60}))

  return estore
end




return M
