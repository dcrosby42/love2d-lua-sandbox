require 'helpers'
require 'ecs/ecshelpers'

local Estore = require 'ecs/estore'

local controllerSystem = require 'systems/controller'
local posMoverSystem = require 'systems/posmover'
local iconAdderSystem = require 'systems/iconadder'

local drawImgSystem = require 'systems/drawimg'

require 'comps'

local updateWorld = iterateFuncs(
  controllerSystem,
  iconAdderSystem,
  posMoverSystem
)

local drawWorld = iterateFuncs(
  drawImgSystem
)

local input, output, estore, res

local catIcon = "images/black-cat-icon.png"

function love.load()
  input = { dt=0, events={} }
  output = {}
  res = {
    images={}
  }
  res.images[catIcon] = love.graphics.newImage(catIcon)

  estore = Estore:new()

  local p1ad = estore:newEntity()
  estore:newComp(p1ad, 'iconAdder', {id='p1', imgId=catIcon, tagName='cattish'})

  local p1 = estore:newEntity()
  estore:newComp(p1, 'pos', {x=50,y=50})
  estore:newComp(p1, 'controller', {id='p1'})
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
  addInputEvent(input, {type='tap', id='p1', x=x, y=y})
end

function love.keypressed(key, scancode, isrepeat)
  if key == "p" then
    print("============================================================================")
    print(estore:debugString())
  end
end
