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

local rpg_chars_png = "images/generic-rpg-chars.png"

local function prepImages()
  return lazytable({
    rpg_chars_png
  },
  love.graphics.newImage
)
end

local RpgSheetCharacters = {
  {
    name="jeff",
    startAt={row=1,col=1},
  },
  {
    name="lea",
    startAt={row=1,col=4},
  },
}

local function rpgFrames(image, char)
  local imgw,imgh = image:getDimensions()
  local fw = 32
  local fh = 32
  local xstart = fw * (char.startAt.col-1)
  local ystart = fw * (char.startAt.row-1)
  local frames = {}
  for i,dir in ipairs({"down", "left", "right", "up"}) do
    local y = ystart + (fh * (i-1))
    for j,fnum in ipairs({"1","2","3"}) do
      local x = xstart + (fw * (j-1))
      frames[dir..'_'..fnum] = love.graphics.newQuad(x,y,fw,fh, imgw, imgh)
    end
  end
  return frames
end

local function prepSprites(res)
  res.sprites = {}
  -- local rpgSheet = buildSpritesheet({file="images/generic-rpg-chars.png", tilew=32, tileh=32})
  -- local image = love.graphics.newImage("images/generic-rpg-chars.png")
  local image = res.images[rpg_chars_png]()
  local imgw,imgh = image:getDimensions()

  for _,char in ipairs(RpgSheetCharacters) do
    res.sprites[char.name] = {
      image=image,
      frames=rpgFrames(image, char)
    }
  end

  -- local xstart = 0
  -- local ystart = 0
  -- local sname = "jeff"
  -- local fw = 32
  -- local fh = 32
  -- local frames = {}
  -- for i,dir in ipairs({"down", "left", "right", "up"}) do
  --   local y = ystart + (fh * (i-1))
  --   for j,fnum in ipairs({"1","2","3"}) do
  --     local x = xstart + (fw * (j-1))
  --     frames[dir..'_'..fnum] = love.graphics.newQuad(x,y,fw,fh, imgw, imgh)
  --   end
  -- end
  -- res.sprites[sname] = {
  --   image=image,
  --   frames=frames
  -- }

  -- res.sprites.jeff = {
  --   image = image,
  --   frames = {
  --     down_1=love.graphics.newQuad(0,0,32,32, imgw,imgh),
  --     down_2=love.graphics.newQuad(32,0,32,32, imgw,imgh),
  --     down_3=love.graphics.newQuad(64,0,32,32, imgw,imgh),
  --     left_1=love.graphics.newQuad(0,32,32,32, imgw,imgh),
  --     left_2=love.graphics.newQuad(32,32,32,32, imgw,imgh),
  --     left_3=love.graphics.newQuad(64,32,32,32, imgw,imgh),
  --     right_1=love.graphics.newQuad(0,64,32,32, imgw,imgh),
  --     right_2=love.graphics.newQuad(32,64,32,32, imgw,imgh),
  --     right_3=love.graphics.newQuad(64,64,32,32, imgw,imgh),
  --     up_1=love.graphics.newQuad(0,96,32,32, imgw,imgh),
  --     up_2=love.graphics.newQuad(32,96,32,32, imgw,imgh),
  --     up_3=love.graphics.newQuad(64,96,32,32, imgw,imgh),
  --   }
  -- }
end

local function mkTimeLookupFunc(data,opts)
  opts = tcopy(opts,{loop=true})
  return function(t)
    local newVal = nil
    if opts.loop then
      t = t % data[#data-1]
    end
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

local function mkIntervalSeries(interval, values)
  local data = {}
  local t = 0
  for i = 1,#values do
    table.insert(data,t)
    table.insert(data,values[i])
    t = t + interval
  end
  return data
end

local function prepAnims(res)
  res.anims={}

  local interval = 0.125
  res.anims['rpg_stand_down'] = function(t) return "down_2" end
  res.anims['rpg_stand_up'] = function(t) return "up_2" end
  res.anims['rpg_stand_left'] = function(t) return "left_2" end
  res.anims['rpg_stand_right'] = function(t) return "right_2" end

  res.anims['rpg_walk_down'] = (function(t)
    local fnames = { "down_1", "down_2", "down_3", "down_2", "down_1" }
    return mkTimeLookupFunc(mkIntervalSeries(interval, fnames))
  end)()

  res.anims['rpg_walk_up'] = (function(t)
    local fnames = { "up_1", "up_2", "up_3", "up_2", "up_1" }
    return mkTimeLookupFunc(mkIntervalSeries(interval, fnames))
  end)()

  res.anims['rpg_walk_left'] = (function(t)
    local fnames = { "left_1", "left_2", "left_3", "left_2", "left_1"}
    return mkTimeLookupFunc(mkIntervalSeries(interval, fnames))
  end)()

  res.anims['rpg_walk_right'] = (function(t)
    local fnames = { "right_1", "right_2", "right_3", "right_2", "right_1" }
    return mkTimeLookupFunc(mkIntervalSeries(interval, fnames))
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
    images=prepImages(),
    fonts={},
    anims={},
    maps=prepMaps(),
  }
  prepSprites(res)
  prepAnims(res)

  return res
end

return R
