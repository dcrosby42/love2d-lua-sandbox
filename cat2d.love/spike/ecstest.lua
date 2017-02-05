-- Framework
require 'helpers'
require 'ecs/ecshelpers'
local Estore = require 'ecs/estore'

-- Game-specific:
require 'flags'
require 'comps'

local controllerSystem = require 'systems/controller'
local posMoverSystem = require 'systems/posmover'
local iconAdderSystem = require 'systems/iconadder'
local timerSystem = require 'systems/timer'
-- local gravitySystem = require 'systems/gravity'
local snowSystem = require 'systems/snow'
local Etree = require 'ecs/entitytree'

local drawSystem = require 'systems/drawstuff'

local adminSystem

-- resource name shortcuts 
-- FIXME is this really the right place for this?
local catIcon = "images/black-cat-icon.png"
local arcticCatTitle = "images/arctic_cat_title.png"

--
-- SETUP
--
local estore -- Entity store, mgmt and retrieval
local input  -- dt and user input events
local output -- ?
local res    -- bag for "static" resources such as sound and image resource objects

local updateWorld -- super-system for updating the game state
local outputWorld -- super-system for generating "output" (audio, video etc.)

local setupSnowscape

function love.load()
  updateWorld = iterateFuncs({
    adminSystem,
    timerSystem,
    snowSystem,
    iconAdderSystem,
    Etree.etreeSystem,
  })

  outputWorld = iterateFuncs({
    drawSystem,
  })

  input = { dt=0, events={} }
  output = {}
  res = {
    images={}
  }
  res.images[catIcon] = love.graphics.newImage(catIcon)
  res.images[arcticCatTitle] = love.graphics.newImage(arcticCatTitle)

  estore = Estore:new()

  setupSnowscape(estore, res)

  setupOtherScene(estore, res)


  estore:updateEntityTree()

end

--
-- UPDATE
--
function love.update(dt)
  input.dt = dt
  updateWorld(estore, input, res)
  input.events = {}
end

--
-- OUTPUT
--
function love.draw()
  love.graphics.setBackgroundColor(0,0,100)
  outputWorld(estore, output, res)
end

--
-- INPUT EVENT HANDLERS
--
function love.mousepressed(x,y, button, istouch)
  if button == 1 then
    addInputEvent(input, {type='tap', id='p1', x=x, y=y})
  elseif button == 2 then
    addInputEvent(input, {type='untap', id='p1', x=x, y=y})
  end
end

function love.keypressed(key, scancode, isrepeat)
  if key == "p" then
    print("============================================================================")
    print(estore:debugString())
  elseif key == "g" then
    if estore.etree then
      print("============================================================================")
      print("-- Entity tree (Estore.etree):")
      print(tdebug(estore.etree.ROOT))
    end
  elseif key == "1" then
    addInputEvent(input, {type='admin', cmd='toSnowScene'})
  elseif key == "2" then
    addInputEvent(input, {type='admin', cmd='toOtherScene'})
  end
end

--
-- -----------------------------------
--


function setupSnowscape(estore,res)
  local group = buildEntity(estore, {
    {'tag', {name='snowScene'}},
    {'filter', {bits = bit32.bor(Flags.Update, Flags.Draw)}},
  })

  buildEntity(estore, {
    {'iconAdder', {id='p1', imgId=catIcon, tagName='cattish'}},
    {'parent', {parentEid=group.eid}},
  })

  buildEntity(estore, {
    {'snowmachine', {large=2,small=1}},
    {'vel', {dx=0, dy=15}},
    {'bounds', {x=0,y=0, w=love.graphics.getWidth(), h=love.graphics.getHeight()}},
    {'timer', {name='flake', reset=0.2, loop=true}},
    {'timer', {name='acc', countDown=false}},
    {'parent', {parentEid=group.eid, order=1}},
  })

  buildEntity(estore, {
    {'snowmachine', {large=3,small=1}},
    {'vel', {dx=0, dy=30}},
    {'bounds', {x=0,y=0, w=love.graphics.getWidth(), h=love.graphics.getHeight()}},
    {'timer', {name='flake', reset=0.2, loop=true}},
    {'timer', {name='acc', countDown=false}},
    {'parent', {parentEid=group.eid, order=2}},
  })

  buildEntity(estore, {
    {'tag', {name='title'}},
    {'img', {imgId=arcticCatTitle}},
    {'pos', {x=20, y=100}},
    -- {'bounds', {x=tap.x, y=tap.y, w=256, h=256}},
    {'parent', {parentEid=group.eid, order=3}}
  })

  buildEntity(estore, {
    {'snowmachine', {large=5, small=3}},
    {'vel', {dx=0, dy=60}},
    {'bounds', {x=0,y=0, w=love.graphics.getWidth(), h=love.graphics.getHeight()}},
    {'timer', {name='flake', reset=0.2, loop=true}},
    {'timer', {name='acc', countDown=false}},
    {'parent', {parentEid=group.eid, order=4}},
  })
  

end

function setupOtherScene(estore, res)
  local otherScene = buildEntity(estore, {
    {'tag', {name='otherScene'}},
    {'filter', {}},
  })

  buildEntity(estore, {
    {'label', {text="YOU ARE LOOKING AT SCENE 2!", color={255,255,255}}},
    {'pos', {x=50,y=50}},
    {'parent', {parentEid = otherScene.eid}},
  })
end


function adminSystem(estore, input, res)
  forEach(input.events.admin, function(i,evt)
    if evt.cmd == 'toSnowScene' then
      local other,snow
      estore:search(hasComps('filter','tag'), function(e)
        if e.tags.otherScene then other = e end
        if e.tags.snowScene then snow = e end
      end)
      if snow then
        snow.filter.bits = bit32.bor(Flags.Draw,Flags.Update)
        -- print("snow: "..entityDebugString(snow,'  '))
      end
      if other then
        other.filter.bits = Flags.None
        -- print("other: "..entityDebugString(other,'  '))
      end

    elseif evt.cmd == 'toOtherScene' then
      local other,snow
      estore:search(hasComps('filter','tag'), function(e)
        if e.tags.otherScene then other = e end
        if e.tags.snowScene then snow = e end
      end)
      if snow then
        snow.filter.bits = Flags.None
        -- print("snow: "..entityDebugString(snow,'  '))
      end
      if other then
        other.filter.bits = bit32.bor(Flags.Draw,Flags.Update)
        -- print("other: "..entityDebugString(other,'  '))
      end
    end
  end)
end
