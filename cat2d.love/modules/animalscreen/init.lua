local Debug = require 'mydebug'
local R = require 'resourceloader'
local A = require 'modules/animalscreen/animalpics'

local M = {}

M.newWorld = function()
  Debug.setup()

  local w = love.graphics.getWidth()
  local h = love.graphics.getHeight()
  -- Debug.println("Bounds w="..w.." h="..h)
  return {
    stamps={},
    selector=0,
  }
end

M.updateWorld = function(w,action)
  if action.type == "touch" or action.type == "mouse" then
    if action.state == "pressed" then
      local animal = A.animals[1+w.selector]
      w.selector = (w.selector + 1) % #A.animals
      local stamp = {x=action.x, y=action.y, animal=animal}
      Debug.println("New ".. animal.name .. " @ " .. stamp.x .. "," .. stamp.y)
      table.insert(w.stamps, stamp)
    end
  elseif action.type == "keyboard" and action.state == "pressed" then
    if action.key == "tab" then
      w.stamps={}
    end
  end

  return w
end

local r=0
M.drawWorld = function(w)
  love.graphics.setBackgroundColor(0,0,0,0)
  for _,stamp in ipairs(w.stamps) do
    local a = stamp.animal
    local img = R.getImage(a.file)
    offx=img:getWidth()*a.centerX
    offy=img:getHeight()*a.centerY
    love.graphics.draw(img, stamp.x, stamp.y, r, a.sizeX, a.sizeY, offx, offy)
  end
  Debug.draw()
end

return M
