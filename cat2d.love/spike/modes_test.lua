require 'helpers'

-- local Snow = require 'spike/snowmodule'
-- local Mod = require 'modules/arcticcat'
-- local Mod = require 'modules/tiledtest'
local Mod = require 'modules/rpg/uimodule'

local world

function love.load()
  love.window.setMode(1024,768)
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
local keyboardAction = {type="keyboard", state='', key=''}
function toKeyboardAction(state,key)
  keyboardAction.state=state
  keyboardAction.key=key
  return keyboardAction
end
function love.keypressed(key, _scancode, _isrepeat)
  Mod.updateWorld(world, toKeyboardAction("pressed",key))
end
function love.keyreleased(key, _scancode, _isrepeat)
  Mod.updateWorld(world, toKeyboardAction("released",key))
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

function love.mousemoved(x,y, dx,dy, isTouch)
  Mod.updateWorld(world, toMouseAction("moved",x,y,nil,isTouch,dx,dy))
end

local touchAction = {type="touch", state=nil, id='', x=0, y=0, dx=0, dy=0}
function toTouchAction(s,id,x,y,dx,dy)
  touchAction.state= s
  touchAction.id = id
  touchAction.x=x
  touchAction.y=y
  touchAction.dx=dx
  touchAction.dy=dy
  return touchAction
end

function love.touchpressed(id, x,y, dx,dy, pressure)
  Mod.updateWorld(world, toTouchAction("pressed",id,x,y,dx,dy))
end
function love.touchmoved(id, x,y, dx,dy, pressure)
  Mod.updateWorld(world, toTouchAction("moved",id,x,y,dx,dy))
end
function love.touchreleased(id, x,y, dx,dy, pressure)
  Mod.updateWorld(world, toTouchAction("released",id,x,y,dx,dy))
end

local joystickAction = {type="joystick", id='TODO', controlType='', control='', value=0}
function toJoystickAction(controlType, control, value)
  joystickAction.id = 'TODO'
  joystickAction.controlType=controlType
  joystickAction.control=control
  joystickAction.value=(value or 0)
  return joystickAction
end

function love.joystickaxis( joystick, axis, value )
  Mod.updateWorld(world, toJoystickAction("axis", axis, value))
end

function love.joystickpressed( joystick, button )
  Mod.updateWorld(world, toJoystickAction("button",button,1))
end

function love.joystickreleased( joystick, button )
  Mod.updateWorld(world, toJoystickAction("button", button,0))
end
