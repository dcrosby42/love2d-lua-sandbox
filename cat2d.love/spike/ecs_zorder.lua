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

THE_CHEAT = {}

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
    timerSystem,
    adminSystem,
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

  setupScene1(estore, res)
  setupScene2(estore, res)

  estore:updateEntityTree()
  -- print(estore:debugString())
  -- print(tdebug(estore.etree))
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
  -- love.graphics.setBackgroundColor(0,0,100)
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
  elseif key == "space" then
    addInputEvent(input, {type="admin", cmd='swap'})
  elseif key == "1" then
    -- THE_CHEAT.filter1.bits = bit32.bor(Flags.Draw,Flags.Update)
    -- THE_CHEAT.filter2.bits = Flags.None
  elseif key == "2" then
    -- THE_CHEAT.filter1.bits = Flags.None
    -- THE_CHEAT.filter2.bits = bit32.bor(Flags.Draw,Flags.Update)
  end
end

--
-- -----------------------------------
--


function setupScene1(estore,res)
  local g1 = buildEntity(estore, {
    {'name', {name='Group 1'}},
    {'filter', {bits = bit32.bor(Flags.Update, Flags.Draw)}},
  })
  -- THE_CHEAT.filter1 = group.filter -- XXX

  local w=100
  local h=100

  blues = buildEntity(estore, {
    {'name', {name='Blues'}},
    {'parent', {parentEid = g1.eid, order = 2}},
  })
  print("Blues eid "..blues.eid)
  local bboxes = {}
  for i=0,200,20 do
    local e = buildEntity(estore, {
      {'rect', {w=w,h=h, color={i,i,255}}},
      {'pos', {x=i,y=i}},
      {'parent', {parentEid = blues.eid, order = i}},
    })
    table.insert(bboxes,e)
  end

  local gx = 75
  local gy = 30
  greens = buildEntity(estore, {
    {'name', {name='Greens'}},
    {'parent', {parentEid = g1.eid, order = 1}},
  })
  print("Greens eid "..greens.eid)
  local gboxes = {}
  for i=0,200,20 do
    local e = buildEntity(estore, {
      {'rect', {w=w,h=h, color={i,255,i}}},
      {'pos', {x=gx+i,y=gy+i}},
      {'parent', {parentEid = greens.eid, order = i}},
    })
    table.insert(gboxes,e)
  end

end

adminSystem = function(estore, input, res)
  if input.events.admin then
    for i,evt in ipairs(input.events.admin) do
      if blues.parent.order < greens.parent.order then
        blues.parent.order = greens.parent.order + 1
      else
        greens.parent.order = blues.parent.order + 1
      end
    end
  end
end

function setupScene2(estore,res)
  -- local s2ent = estore:newEntity()
  -- local filter2 = estore:newComp(s2ent, 'filter', {name="filter2", bits=Flags.None})
  --
  -- local l1 = estore:newEntity()
  -- estore:newComp(l1, 'label', {text="YOU ARE LOOKING AT SCENE 2!"})
  -- estore:newComp(l1, 'pos', {x=50,y=50})
  -- estore:newComp(l1, 'parent', {parentEid = s2ent.eid})
  --
  -- local t1 = estore:newEntity()
  -- estore:newComp(t1, 'timer', {countDown=false})
  -- estore:newComp(t1, 'parent', {parentEid = s2ent.eid})
  --
  -- THE_CHEAT.filter2 = filter2
end

