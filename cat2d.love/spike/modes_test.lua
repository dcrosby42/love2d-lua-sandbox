require 'helpers'

-- local Snow = require 'spike/snowmodule'
local ArcticCat = require 'modules/arcticcat'

local world

function love.load()
  world = ArcticCat.newWorld(world)
end


local dtAction = {type="tick", dt=0}

function love.update(dt)
  dtAction.dt = dt
  ArcticCat.updateWorld(world, dtAction)
end

function love.draw()
  ArcticCat.drawWorld(world)
end

--
-- INPUT EVENT HANDLERS
--
local mouseAction = {type="mouse", action=nil, x=0, y=0, button=0, isTouch=0}
function love.mousepressed(x,y, button, isTouch)
  mouseAction.action="pressed"
  mouseAction.x=x
  mouseAction.y=y
  mouseAction.button=button
  mouseAction.isTouch=isTouch
  ArcticCat.updateWorld(world, mouseAction)
end

local keyboardAction = {type="keyboard", action=nil, key=nil}
function love.keypressed(key, _scancode, _isrepeat)
  keyboardAction.action="pressed"
  keyboardAction.key=key
  ArcticCat.updateWorld(world, keyboardAction)
end

