local sti = require "sti"
local M = {}

local scale = 1 -- 0.5
M.newWorld = function()
  local map = sti("maps/town1.lua")

  for objkey,obj in pairs(map.objects) do
    print("map.objects["..objkey.."]: ")
    print(tdebug1(obj))
  end

  for layerkey,layer in pairs(map.layers) do
    print("map.layers["..layerkey.."]: "..tostring(layer))
    print(tdebug1(layer))
  end

  local player1 = tfindby(map.objects, 'name', 'Player1')

  map.layers.SpawnPoints.visible = false
  -- map:removeLayer('SpawnPoints')

  world = {
    player = player1,
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
  world.map:draw()

  -- love.graphics.setPointSize(5)
  love.graphics.rectangle("line",
    math.floor(world.player.x),
    math.floor(world.player.y),
    math.floor(world.player.width),
    math.floor(world.player.height)
  )

  love.graphics.pop()
end

return M
