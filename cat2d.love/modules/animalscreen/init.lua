local Debug = require 'mydebug'
local R = require 'resourceloader'
local A = require 'modules/animalscreen/animalpics'

local M = {}

M.newWorld = function()
  Debug.setup()

  local w = love.graphics.getWidth()
  local h = love.graphics.getHeight()
  Debug.println("Bounds w="..w.." h="..h)
  return {
    stamps={},
  }
end

M.updateWorld = function(w,action)
  if action.type == "touch" or action.type == "mouse" then
    if action.state == "pressed" then
      Debug.println("x")
      local stamp = {x=action.x, y=action.y, animal=A.animals[1]}
      table.insert(w.stamps, stamp)
    end
  end

  return w
end

local h = R.getImage("data/images/hippo.png")
local offx=h:getWidth()/2
local offy=h:getHeight()/2
local sx=0.5
local sy=0.5
local r=0
M.drawWorld = function(w)
  love.graphics.setBackgroundColor(0,0,0,0)
  for _,stamp in ipairs(w.stamps) do
    local a = stamp.animal
    local img = R.getImage(a.file)
    offx=img:getWidth()*a.centerX
    offy=img:getHeight()*a.centerY
    love.graphics.draw(h, stamp.x, stamp.y, r, a.sizeX, a.sizeY, offx, offy)
  end
  Debug.draw()
end

return M
