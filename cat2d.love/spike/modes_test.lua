require 'helpers'

-- local Snow = require 'spike/snowmodule'
local Mod = require 'modules/arcticcat'

local world

function love.load()
  world = Mod.newWorld(world)
end


local dtAction = {type="tick", dt=0}

function love.update(dt)
  dtAction.dt = dt
  Mod.updateWorld(world, dtAction)
end

function love.draw()
  Mod.drawWorld(world)
end

--
-- INPUT EVENT HANDLERS
--
local keyboardAction = {type="keyboard", action=nil, key=nil}
function love.keypressed(key, _scancode, _isrepeat)
  keyboardAction.state="pressed"
  keyboardAction.key=key
  Mod.updateWorld(world, keyboardAction)
end

local mouseAction = {type="mouse", state=nil, x=0, y=0, dx=0,dy=0,button=0, isTouch=0}
function toMouseAction(s,x,y,b,it,dx,dy)
  mouseAction.state=s
  mouseAction.x=x
  mouseAction.y=y
  mouseAction.button=b
  mouseAction.isTouch=it
  mouseAction.dx=dx
  mouseAction.dy=dy
  return mouseAction
end

function love.mousepressed(x,y, button, isTouch, dx, dy)
  Mod.updateWorld(world, toMouseAction("pressed",x,y,button,isTouch))
end

function love.mousereleased(x,y, button, isTouch)
  Mod.updateWorld(world, toMouseAction("released",x,y,button,isTouch))
end

-- function love.mousemoved(x,y, dx,dy, isTouch)
--   Mod.updateWorld(world, toMouseAction("moved",x,y,nil,isTouch,dx,dy))
-- end

local touchAction = {type="touch", state=nil, x=0, y=0, dx=0, dy=0}
function love.touchpressed(id, x,y, dx,dy, pressure)
  mouseAction.state="pressed"
  mouseAction.x=x
  mouseAction.y=y
  mouseAction.dx=dx
  mouseAction.dy=dy
  mouseAction.button=button
  mouseAction.isTouch=isTouch
  Mod.updateWorld(world, mouseAction)
end
function love.touchmoved(id, x,y, dx,dy, pressure)
end
function love.touchreleased(id, x,y, dx,dy, pressure)
end
