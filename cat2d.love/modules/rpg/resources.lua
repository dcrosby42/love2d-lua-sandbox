require 'helpers'
local sti = require "sti"


local function prepMaps()
  return lazytable({
      'town1',
      'town2',
    },
    function(k) return sti("maps/"..k..".lua") end
  )
end

local function prepSprites(res)
  -- local rpgSheet = buildSpritesheet({file="images/generic-rpg-chars.png", tilew=32, tileh=32})
  local image = love.graphics.newImage("images/generic-rpg-chars.png")
  local imgw,imgh = image:getDimensions()

  res.sprites = {}
  res.sprites.jeff = {
    image = image,
    frames = {
      down_1=love.graphics.newQuad(0,0,32,32, imgw,imgh),
      down_2=love.graphics.newQuad(32,0,32,32, imgw,imgh),
      down_3=love.graphics.newQuad(64,0,32,32, imgw,imgh),
      left_1=love.graphics.newQuad(0,32,32,32, imgw,imgh),
      left_2=love.graphics.newQuad(32,32,32,32, imgw,imgh),
      left_3=love.graphics.newQuad(64,32,32,32, imgw,imgh),
      right_1=love.graphics.newQuad(0,64,32,32, imgw,imgh),
      right_2=love.graphics.newQuad(32,64,32,32, imgw,imgh),
      right_3=love.graphics.newQuad(64,64,32,32, imgw,imgh),
      up_1=love.graphics.newQuad(0,96,32,32, imgw,imgh),
      up_2=love.graphics.newQuad(32,96,32,32, imgw,imgh),
      up_3=love.graphics.newQuad(64,96,32,32, imgw,imgh),
    }
  }
end

local function mkTimeLookupFunc(data)
  return function(t)
    local newVal = nil
    for i=1, #data, 2 do
      if t >= data[i] then
        newVal = data[i+1]
      else
        return newVal
      end
    end
    return newVal
  end
end

local function prepAnims(res)
  res.anims={}

  res.anims['rpg_stand_down'] = function(t) return "down_2" end
  res.anims['rpg_walk_down'] = (function(t)
    local data = {
      0, "down_1",
      0.333, "down_2",
      0.333, "down_3",
    }
    return mkTimeLookupFunc(data)
  end)()
  res.anims['rpg_stand_up'] = function(t) return "up_2" end
  res.anims['rpg_walk_up'] = (function(t)
    local data = {
      0, "up_1",
      0.333, "up_2",
      0.333, "up_3",
    }
    return mkTimeLookupFunc(data)
  end)()
  res.anims['rpg_stand_left'] = function(t) return "left_2" end
  res.anims['rpg_walk_left'] = (function(t)
    local data = {
      0, "left_1",
      0.333, "left_2",
      0.333, "left_3",
    }
    return mkTimeLookupFunc(data)
  end)()
  res.anims['rpg_stand_right'] = function(t) return "right_2" end
  res.anims['rpg_walk_right'] = (function(t)
    local data = {
      0, "right_1",
      0.333, "right_2",
      0.333, "right_3",
    }
    return mkTimeLookupFunc(data)
  end)()
end

-- function buildSpritesheet(opts)
--   -- TODO - err check opts file, tilew, tileh
--   local img = love.graphics.newImage(opts.file)
--   local w = opts.tilew
--   local h = opts.tileh
--   local imgw,imgh = img:getDimensions()
--   for x = 0, imgw, w do
--     print(x)
--   end
--   return {
--   }
-- end

local R = {}

R.load = function()
  local res = {
    images={},
    fonts={},
    anims={},
    maps=prepMaps(),
  }
  prepSprites(res)
  prepAnims(res)

  return res
end

return R
