require 'helpers'
require 'ecs/ecshelpers'

local Estore = require 'ecs/estore'

local controllerSystem = require 'systems/controller'
local posMoverSystem = require 'systems/posmover'
local iconAdderSystem = require 'systems/iconadder'

local drawImgSystem = require 'systems/drawimg'
local drawLabelSystem = require 'systems/drawlabel'

require 'comps'

local updateWorld = iterateFuncs({
  controllerSystem,
  iconAdderSystem,
  posMoverSystem,
})

local drawWorld = iterateFuncs({
  drawImgSystem,
  -- drawLabelSystem,
})

local input, output, estore, res

THE_CHEAT = {}

local catIcon = "images/black-cat-icon.png"

function love.load()
  input = { dt=0, events={} }
  output = {}
  res = {
    images={}
  }
  res.images[catIcon] = love.graphics.newImage(catIcon)
  -- print(catIcon .. ": " .. res.images[catIcon]:getWidth() .. " x " .. res.images[catIcon]:getHeight())

  estore = Estore:new()

  local s1ent = estore:newEntity()
  local scene1 = estore:newComp(s1ent, 'scene', {name="scene1", active=true})
  estore:newComp(s1ent, 'parent', {parentEid="ROOT"})

  local p1ad = estore:newEntity()
  estore:newComp(p1ad, 'iconAdder', {id='p1', imgId=catIcon, tagName='cattish'})
  estore:newComp(p1ad, 'parent', {parentEid = s1ent.eid})

  local p1 = estore:newEntity()
  estore:newComp(p1, 'pos', {x=50,y=50})
  estore:newComp(p1, 'controller', {id='p1'})
  estore:newComp(p1, 'parent', {parentEid = s1ent.eid})

  -- 
  local s2ent = estore:newEntity()
  local scene2 = estore:newComp(s2ent, 'scene', {name="scene2"})
  estore:newComp(s2ent, 'parent', {parentEid="ROOT"})

  local l1 = estore:newEntity()
  estore:newComp(l1, 'label', {text="YOU ARE LOOKING AT SCENE 2!"})
  estore:newComp(l1, 'pos', {x=50,y=50})
  estore:newComp(l1, 'parent', {parentEid = s2ent.eid})

  THE_CHEAT.scene1 = scene1
  THE_CHEAT.scene2 = scene2
end

function love.update(dt)
  updateWorld(estore, input, res)
  input.events = {}
end

function love.draw()
  love.graphics.setBackgroundColor(255,255,255)
  drawWorld(estore, output, res)
end

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
  elseif key == "1" then
    THE_CHEAT.scene1.active = true
    THE_CHEAT.scene2.active = false
  elseif key == "2" then
    THE_CHEAT.scene1.active = false
    THE_CHEAT.scene2.active = true
  end
end
