local sti = require('sti')
local bump = require('bump')

local Map = {}

function Map:new(mapfile)
  local o = {
  }
  setmetatable(o, self)
  self.__index = self

  local map = sti(mapfile, {'bump'})
  for _,layer in ipairs(map.layers) do
    if layer.type == 'objectgroup' then
      layer.visible = false
    end
  end
  -- TODO: 6 is arbitrary based on my first test map.
  -- This value needs to somehow be divined from metadata in the map.
  map:addCustomLayer("CustomSpriteLayer", 6)

  local bumpWorld = bump.newWorld()
  map:bump_init(bumpWorld)

  o.map = map
  o.bumpWorld = bumpWorld
  o.itemList = {} -- where we cache cids that are included in the bump sim
  o.spriteLayer = map.layers.CustomSpriteLayer

  return o
end

function Map:draw(opts, spriteDrawFn)
  function self.spriteLayer:draw() spriteDrawFn() end

  self.map:draw()

  if opts.bounds then
    self.map:bump_draw(self.bumpWorld)
  end
end

return Map
