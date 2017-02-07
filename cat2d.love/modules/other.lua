require 'ecs/ecshelpers'
local Estore = require 'ecs/estore'

require 'flags'
require 'comps'

local timerSystem = require 'systems/timer'
local drawSystem = require 'systems/drawstuff'
local Etree = require 'ecs/entitytree'

local DoUpdate = iterateFuncs({
  timerSystem,
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
      }
    },
  }

  return w, nil
end

M.updateWorld = function(world, action)
  if action.type == 'tick' then
    world.input.dt = action.dt
    local estore = world.scene
    DoUpdate(estore, world.input, world.resources)

    world.input.events = {}

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
      return world, {{type="exit"}}
    end
  end

  return world, nil
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

  buildEntity(mystore, {
    {'label', {text="YOU ARE LOOKING AT SCENE 2!", color={255,255,255}}},
    {'pos', {x=50,y=50}},
    {'parent', {parentEid = otherScene.eid}},
  })

  mystore:updateEntityTree()
  return mystore
end

-- ---------------------------------------------------------------
return M
