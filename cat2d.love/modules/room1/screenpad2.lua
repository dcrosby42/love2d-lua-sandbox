local here = (...):match("(.*/)[^%/]+$")
local TouchStick = require(here..'/touchstick')

local M = {}

local h = love.graphics.getHeight() / 2
local w = h

M.initialize = function(opts)
  return {
    controllerId = opts.controllerId,
    leftStick = TouchStick.newStick({radius=opts.stickRadius}),
  }
end

local function generateInputsEvents(evts, worldInput, type, id, prefix)
  if not prefix then prefix = '' end
  if evts then
    for _,evt in ipairs(evts) do
      addInputEvent(worldInput, {type=type, id=id, input=prefix..evt.input, action=evt.action})
    end
  end
end

local function start(sp, id, x, y, worldInput)
  evts = TouchStick.start(sp.leftStick, id, x, y)
  generateInputsEvents(evts, worldInput, "controller", sp.controllerId, "left")
end

local function move(sp, id, x, y, worldInput)
  evts = TouchStick.move(sp.leftStick, id, x, y)
  generateInputsEvents(evts, worldInput, "controller", sp.controllerId, "left")
end

local function done(sp, id, x, y, worldInput)
  evts = TouchStick.done(sp.leftStick, id, x, y)
  generateInputsEvents(evts, worldInput, "controller", sp.controllerId, "left")
end

M.handleMouse = function(sp, action, worldInput)
  local id = "m"
  if action.state == 'pressed' then
    start(sp, id, action.x, action.y, worldInput)
  elseif action.state == 'moved' then
    move(sp, id, action.x, action.y, worldInput)
  elseif action.state == 'released' then
    done(sp, id, action.x, action.y, worldInput)
  end
end

M.handleTouch = function(sp, action, worldInput)
  local id = action.id
  if action.state == 'pressed' then
    start(sp, id, action.x, action.y, worldInput)
  elseif action.state == 'moved' then
    move(sp, id, action.x, action.y, worldInput)
  elseif action.state == 'released' then
    done(sp, id, action.x, action.y, worldInput)
  end
end

M.draw = function(sp)
  TouchStick.draw(sp.leftStick)
end

return M
