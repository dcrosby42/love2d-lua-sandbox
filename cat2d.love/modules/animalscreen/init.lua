local Debug = require 'mydebug'
local R = require 'resourceloader'
local A = require 'modules/animalscreen/animalpics'

local M = {}

local function randint(lo,hi)
  return math.floor(love.math.random() * (hi-lo+1)) + lo
end

function M.newWorld()
  local bounds = {w=love.graphics.getWidth(), h=love.graphics.getHeight()}

  local bg = {file="data/images/zoo_keeper.png"}
  bg.img = R.getImage(bg.file)
  bg.sizeX = bounds.w / bg.img:getWidth()
  bg.sizeY = bounds.h / bg.img:getHeight()

  return {
    bounds=bounds,
    bg=bg,
    stamps={},
    selector=0,
  }
end

function M.updateWorld(w,action)
  if action.type == "touch" or action.type == "mouse" then
    if action.state == "pressed" then
      if action.x < 50 and action.y < 50 then
        w.stamps = {}
        Debug.println("Clear")
      else
        local animal = A.animals[randint(1,#A.animals)]
        local stamp = {x=action.x, y=action.y, animal=animal}
        Debug.println("New ".. animal.name .. " @ " .. stamp.x .. "," .. stamp.y)
        table.insert(w.stamps, stamp)
      end
    end
  elseif action.type == "keyboard" and action.state == "pressed" then
    if action.key == "tab" then
      w.stamps={}
    end
  end

  return w
end

local r=0
function M.drawWorld(w)
  love.graphics.setBackgroundColor(0,0,0,0)

  love.graphics.draw(w.bg.img, 0, 0, 0, w.bg.sizeX, w.bg.sizeY, 0,0)

  for _,stamp in ipairs(w.stamps) do
    local a = stamp.animal
    local img = R.getImage(a.file)
    offx=img:getWidth()*a.centerX
    offy=img:getHeight()*a.centerY
    love.graphics.draw(img, stamp.x, stamp.y, r, a.sizeX, a.sizeY, offx, offy)
  end
end

return M
