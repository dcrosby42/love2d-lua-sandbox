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

local drawImgSystem = require 'systems/drawimg'

THE_CHEAT = {}



-- resource name shortcuts 
-- FIXME is this really the right place for this?
local catIcon = "images/black-cat-icon.png"

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
    timerSystem,
    snowSystem,
    iconAdderSystem,
    Etree.etreeSystem,
  })

  outputWorld = iterateFuncs({
    drawImgSystem,
  })

  input = { dt=0, events={} }
  output = {}
  res = {
    images={}
  }
  res.images[catIcon] = love.graphics.newImage(catIcon)

  estore = Estore:new()

  setupSnowscape(estore, res)


  -- 
  local s2ent = estore:newEntity()
  local filter2 = estore:newComp(s2ent, 'filter', {name="filter2", bits=Flags.None})

  local l1 = estore:newEntity()
  estore:newComp(l1, 'label', {text="YOU ARE LOOKING AT SCENE 2!"})
  estore:newComp(l1, 'pos', {x=50,y=50})
  estore:newComp(l1, 'parent', {parentEid = s2ent.eid})

  local t1 = estore:newEntity()
  estore:newComp(t1, 'timer', {countDown=false})
  estore:newComp(t1, 'parent', {parentEid = s2ent.eid})

  estore:updateEntityTree()

  THE_CHEAT.filter2 = filter2
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
    THE_CHEAT.filter1.bits = bit32.bor(Flags.Draw,Flags.Update)
    THE_CHEAT.filter2.bits = Flags.None
  elseif key == "2" then
    THE_CHEAT.filter1.bits = Flags.None
    THE_CHEAT.filter2.bits = bit32.bor(Flags.Draw,Flags.Update)
  end
end

--
-- -----------------------------------
--


function setupSnowscape(estore,res)
  local group = buildEntity(estore, {
    {'tag', {name='snowscape_group'}},
    {'filter', {bits = bit32.bor(Flags.Update, Flags.Draw)}},
  })
  THE_CHEAT.filter1 = group.filter -- XXX

  buildEntity(estore, {
    {'iconAdder', {id='p1', imgId=catIcon, tagName='cattish'}},
  }, {parent=group})

  buildEntity(estore, {
    {'snowmachine', {large=5, small=3}},
    {'vel', {dx=0, dy=60}},
    {'bounds', {x=0,y=0, w=love.graphics.getWidth(), h=love.graphics.getHeight()}},
    {'timer', {name='flake', reset=0.2, loop=true}},
    {'timer', {name='acc', countDown=false}},
  }, {parent=group})

  buildEntity(estore, {
    {'snowmachine', {large=3,small=1}},
    {'vel', {dx=0, dy=30}},
    {'bounds', {x=0,y=0, w=love.graphics.getWidth(), h=love.graphics.getHeight()}},
    {'timer', {name='flake', reset=0.2, loop=true}},
    {'timer', {name='acc', countDown=false}},
  }, {parent=group})

end
