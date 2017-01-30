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

function love.load()
  updateWorld = iterateFuncs({
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

  local s1ent = estore:newEntity()
  local filter1 = estore:newComp(s1ent, 'filter', {name="filter1", bits=bit32.bor(Flags.Update, Flags.Draw)})

  local p1ad = estore:newEntity()
  estore:newComp(p1ad, 'iconAdder', {id='p1', imgId=catIcon, tagName='cattish'})
  estore:newComp(p1ad, 'parent', {parentEid = s1ent.eid})

  local p1 = estore:newEntity()
  estore:newComp(p1, 'pos', {x=50,y=50})
  estore:newComp(p1, 'controller', {id='p1'})
  estore:newComp(p1, 'parent', {parentEid = s1ent.eid})

  -- 
  local s2ent = estore:newEntity()
  local filter2 = estore:newComp(s2ent, 'filter', {name="filter2", bits=Flags.None})

  local l1 = estore:newEntity()
  estore:newComp(l1, 'label', {text="YOU ARE LOOKING AT SCENE 2!"})
  estore:newComp(l1, 'pos', {x=50,y=50})
  estore:newComp(l1, 'parent', {parentEid = s2ent.eid})

  THE_CHEAT.filter1 = filter1
  THE_CHEAT.filter2 = filter2
end

--
-- UPDATE
--
function love.update(dt)
  updateWorld(estore, input, res)
  input.events = {}
end

--
-- OUTPUT
--
function love.draw()
  love.graphics.setBackgroundColor(255,255,255)
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
    THE_CHEAT.filter1.bits = Flags.Draw
    THE_CHEAT.filter2.bits = Flags.None
  elseif key == "2" then
    THE_CHEAT.filter1.bits = Flags.None
    THE_CHEAT.filter2.bits = Flags.Draw
  end
end
