require 'ecs/ecshelpers'
local Estore = require 'ecs/estore'

require 'flags'
require 'comps'

local timerSystem = require 'systems/timer'
local mouseSystem = require 'systems/button'
local outputCleanupSystem = require 'systems/outputcleanup'
local drawSystem = require 'systems/drawstuff'
local Etree = require 'ecs/entitytree'

local leaveSystem = defineUpdateSystem({'event'},function(e,estore,input,res)
  if e.events.leave then
    estore:newComp(e, 'output', {kind='transition',value='leave'})
    estore:removeComp(e.events.leave)
  end
end)

local DoUpdate = iterateFuncs({
  outputCleanupSystem,
  timerSystem,
  mouseSystem,
  leaveSystem,
  Etree.etreeSystem,
})

local DoDraw = iterateFuncs({
  drawSystem,
})

local M ={}

local newOtherScene

M.newWorld = function()
  local w = {
    bgcolor = {0,0,100},
    scene = newOtherScene(),
    input = { dt=0, events={} },
    resources = {
      images={
      },
      fonts={
        ["narpassword-medium"] = love.graphics.newFont("fonts/narpassword.ttf",30),
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

    estore:search(hasComps('output'), function(e)
      effects = {}
      for _,out in pairs(e.outputs) do
        effects[#effects+1] = {type=out.kind, value=out.value}
      end
    end)

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
    elseif key == "x" and action.state == 'pressed' then
      return world, {{type="transition",value="leave"}}
    end

  elseif action.type == 'mouse' then
    addInputEvent(world.input, action)
  end

  return world, effects
end

M.drawWorld = function(world)
  love.graphics.setBackgroundColor(unpack(world.bgcolor))

  local estore = world.scene
  DoDraw(estore, nil, world.resources)
end

-- ---------------------------------------------------------------

function newOtherScene()
  local mystore = Estore:new()

  local otherScene = buildEntity(mystore, {
    {'tag', {name='otherScene'}},
    {'filter', {bits = bit32.bor(Flags.Update, Flags.Draw)}},
  })

  local button = buildEntity(mystore, {
    {'parent', {parentEid = otherScene.eid}},
  })

  local x = 0
  local y = 0
  local w = 200
  local h = 50

  buildEntity(mystore, {
    {'rect', {w=w,h=h, color={0,180,0}}},
    {'pos', {x=x,y=y}},
    {'tag',{name='leaver'}},
    {'mouse_sensor', {eventName='leave'}},
    {'parent', {parentEid = button.eid}},
  })

  buildEntity(mystore, {
    {'label', {font="narpassword-medium", text="Leave", color={0,0,0}, width=w, align='center', height=h, valign='middle'}},
    {'pos', {x=x,y=y}},
    {'parent', {parentEid = button.eid,order=1}},
  })


  mystore:updateEntityTree()
  return mystore
end

-- ---------------------------------------------------------------
return M
