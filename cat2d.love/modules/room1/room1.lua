local here = (...):match("(.*/)[^%/]+$")

require 'ecs/ecshelpers'
require 'comps'

local buildEstore = require(here.."buildestore")
local Resources = require(here.."resources")

local timerSystem = require 'systems/timer'
local selfDestructSystem = require 'systems/selfdestruct'
local outputCleanupSystem = require 'systems/outputcleanup'
local effectsSystem = require 'systems/effects'
local controllerSystem = require 'systems/controller'
local drawSystem = require 'systems/drawstuff'
local zChildrenSystem = require 'systems/zchildren'
local moverSystem = require(here..'/moversystem')


local DoUpdate = iterateFuncs({
  outputCleanupSystem,
  timerSystem,
  selfDestructSystem,
  controllerSystem,
  moverSystem,
  zChildrenSystem,

  effectsSystem,
})

local DoDraw = iterateFuncs({
  drawSystem,
})

local M ={}

local newSnowScene

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

local function kbdDpadInput(world, map, targetId, action)
  local key = action.key
  if key == map.up then
    local mag = -1
    if action.state == 'released' then mag = 0 end
    addInputEvent(world.input, {type='controller', id=targetId, input="lefty", action=mag})
    return true
  elseif key == map.down then
    local mag = 1
    if action.state == 'released' then mag = 0 end
    addInputEvent(world.input, {type='controller', id=targetId, input="lefty", action=mag})
    return true
  elseif key == map.left then
    local mag = -1
    if action.state == 'released' then mag = 0 end
    addInputEvent(world.input, {type='controller', id=targetId, input="leftx", action=mag})
    return true
  elseif key == map.right then
    local mag = 1
    if action.state == 'released' then mag = 0 end
    addInputEvent(world.input, {type='controller', id=targetId, input="leftx", action=mag})
    return true
  end
  return false
end

M.updateWorld = function(world, action)
  local effects = nil

  if action.type == 'tick' then
    world.input.dt = action.dt

    local estore = world.estore
    DoUpdate(estore, world.input, world.resources)

    world.input.events = {}

    estore:search(hasComps('output'), function(e)
      effects = {}
      for _,out in pairs(e.outputs) do
        -- print("Effect: "..out.kind)
        effects[#effects+1] = {type=out.kind, value=out.value}
      end
    end)

  elseif action.type == 'mouse' then
    if action.button == 1 then
      if action.state == "pressed" then
        addInputEvent(world.input, {type='tap', id='p1', x=action.x, y=action.y})
      end
    elseif action.button == 2 then
      if action.state == "pressed" then
        addInputEvent(world.input, {type='untap', id='p1', x=action.x, y=action.y})
      end
    end

  elseif action.type == 'keyboard' then
    addInputEvent(world.input, action)

    local key = action.key
    if key == "p" then
      local estore = world.estore
      print("============================================================================")
      print(estore:debugString())
    elseif key == "g" then
      local estore = world.estore
      if estore.etree then
        print("============================================================================")
        print("-- Entity tree (Estore.etree):")
        print(tdebug(estore.etree.ROOT))
      end
    elseif key == "x" and action.state == 'pressed' then
      print("Manual switchover")
      effects = {
        {type='transition', value='leave'}
      }
    else
      local hit = kbdDpadInput(world, { up='w', left='a', down='s', right='d' }, 'con1', action)
      if not hit then
        kbdDpadInput(world, { up='k', left='h', down='j', right='l' }, 'con2', action)
      end
    end

  end

  return world, effects
end

M.drawWorld = function(world)
  love.graphics.setBackgroundColor(unpack(world.bgcolor))

  DoDraw(world.estore, nil, world.resources)
end



return M
