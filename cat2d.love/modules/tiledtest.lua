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

local transx=0
local transy=0
local spd = 64
local Keys = {
  h=function() transx = transx + spd end,
  j=function() transy = transy - spd end,
  k=function() transy = transy + spd end,
  l=function() transx = transx - spd end,
}
M.updateWorld = function(world, action)
  if action.state == 'pressed' then
    local act = Keys[action.key]
    if act then act() end
  end
end

M.drawWorld = function(world)
  love.graphics.setBackgroundColor(unpack(world.bgcolor))

  love.graphics.push()
  -- love.graphics.scale(math.round(scale,2),math.round(scale,2))
  love.graphics.translate(transx,transy)
  map:draw()
  love.graphics.pop()
end

return M
