local sti = require "sti"
local M = {}

local map
local scale = 1 -- 0.5
M.newWorld = function()
  map = sti("maps/town1.lua")
  world = {
    bgcolor={0,0,0},
    map = map,
  }
  return world, nil
end


M.updateWorld = function(world, action)
end

M.drawWorld = function(world)
  love.graphics.setBackgroundColor(unpack(world.bgcolor))

  -- -- love.graphics.push()
  -- love.graphics.scale(math.round(scale,2),math.round(scale,2))
  map:draw()
  -- love.graphics.pop()
end

return M
