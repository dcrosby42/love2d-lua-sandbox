local sti = require "sti"
local M = {}

local map
local scale = 2 -- 0.5
M.newWorld = function()
  -- local map = sti("assets/maps/map01.lua", { "box2d" })
  -- map = sti("maps/my_indoor.lua")
  map = sti("maps/sample_indoor.lua")
  world = {
    bgcolor={0,0,0},
    map = map,
  }
  return world, nil
end


M.updateWorld = function(world, action)
  -- if action.type == 'tick' then
  --   if scale < 3 then
  --     scale = scale + (action.dt )
  --   end
  -- end
end

M.drawWorld = function(world)
  love.graphics.setBackgroundColor(unpack(world.bgcolor))

  love.graphics.push()
  love.graphics.scale(math.round(scale,2),math.round(scale,2))
  map:draw()
  love.graphics.pop()
end

return M
