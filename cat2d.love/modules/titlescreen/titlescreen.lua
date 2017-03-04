require 'ecs/ecshelpers'
local Estore = require 'ecs/estore'

require 'comps'

local iconAdderSystem = require 'systems/iconadder'
local timerSystem = require 'systems/timer'
local Snow = require 'systems/snow'
local selfDestructSystem = require 'systems/selfdestruct'
local outputCleanupSystem = require 'systems/outputcleanup'
local effectsSystem = require 'systems/effects'
local drawSystem = require 'systems/drawstuff'

-- resource name shortcuts
local catIcon = "images/black-cat-icon.png"
local arcticCatTitle = "images/arctic_cat_title.png"

local Menu = require 'modules/titlescreen/menu'

local DoUpdate = iterateFuncs({
  outputCleanupSystem,
  timerSystem,
  selfDestructSystem,
  Menu.System,
  Snow.System,
  -- iconAdderSystem,
  effectsSystem,
})

local DoDraw = iterateFuncs({
  drawSystem,
})

local M ={}

local newSnowScene

M.newWorld = function()
  local w = {
    bgcolor = {0,0,100},
    estore = newSnowScene(),
    input = { dt=0, events={} },
    resources = {
      images={
        [catIcon] = love.graphics.newImage(catIcon),
        -- [arcticCatTitle] = love.graphics.newImage(arcticCatTitle),
      },
      fonts={
        -- ["Adventure-50"] = love.graphics.newFont("fonts/Adventure.ttf",50),
        -- ["Adventure-100"] = love.graphics.newFont("fonts/Adventure.ttf",100),
        -- ["AdventureOutline-50"] = love.graphics.newFont("fonts/Adventure Outline.ttf",50),
        -- ["narpassword-medium"] = love.graphics.newFont("fonts/narpassword.ttf",30),
      }
    },
  }
  Menu.Setup(w)

  return w, nil
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
        {type='exit'}
      }
    end

  end

  return world, effects
end

M.drawWorld = function(world)
  love.graphics.setBackgroundColor(unpack(world.bgcolor))

  DoDraw(world.estore, nil, world.resources)
end

-- ---------------------------------------------------------------
function newSnowScene()
  local estore = Estore:new()

  local group = estore:buildEntity({
    {'tag', {name='snowScene'}},
    {'pos',{}},
  })

  group:newChild({
    {'pos',{}},
    {'iconAdder', {id='p1', imgId=catIcon, tagName='cattish'}},
  })

  group:addChild(Snow.newSnowMachine(estore, {large=2, small=1, dy=15}))
  group:addChild(Snow.newSnowMachine(estore, {large=3, small=1, dy=30}))

  group:addChild(Menu.BuildMenuEntity(estore))

  group:addChild(Snow.newSnowMachine(estore, {large=5, small=3, dy=60}))

  return estore
end



return M
