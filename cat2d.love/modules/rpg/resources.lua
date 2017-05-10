local here = dirname(...)

local Map = require(here.."/map")


local function prepMaps()
  return lazytable({
      'town1',
      'shop1',
      'town2',
    },
    function(k)
      return Map:new("maps/"..k..".lua")
    end
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
  { name="jeff", startAt={row=1,col=1}, },
  { name="ardin", startAt={row=5,col=1}, },
  { name="lea", startAt={row=1,col=4}, },
  { name="jane", startAt={row=5,col=4}, },
  { name="reb", startAt={row=1,col=7}, },
  { name="wuf", startAt={row=5,col=7}, },
  { name="oko", startAt={row=1,col=10}, },
  { name="kile", startAt={row=5,col=10}, },
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
  local image = res.images[rpg_chars_png]()
  local imgw,imgh = image:getDimensions()

  for _,char in ipairs(RpgSheetCharacters) do
    res.sprites[char.name] = {
      image=image,
      frames=rpgFrames(image, char)
    }
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
    return makeTimeLookupFunc(mkIntervalSeries(interval, fnames))
  end)()

  res.anims['rpg_walk_up'] = (function(t)
    local fnames = { "up_1", "up_2", "up_3", "up_2", "up_1" }
    return makeTimeLookupFunc(mkIntervalSeries(interval, fnames))
  end)()

  res.anims['rpg_walk_left'] = (function(t)
    local fnames = { "left_1", "left_2", "left_3", "left_2", "left_1"}
    return makeTimeLookupFunc(mkIntervalSeries(interval, fnames))
  end)()

  res.anims['rpg_walk_right'] = (function(t)
    local fnames = { "right_1", "right_2", "right_3", "right_2", "right_1" }
    return makeTimeLookupFunc(mkIntervalSeries(interval, fnames))
  end)()
end

function prepScripts()
  local names = {'idlingTownsman'}
  local s = {}
  for _,name in ipairs(names) do
    s[name] = require(here.."scripts/"..name)
  end
  return s
end

local R = {}

R.load = function()
  local res = {
    images=prepImages(),
    fonts={},
    anims={},
    maps=prepMaps(),
    scripts=prepScripts(),
  }
  prepSprites(res)
  prepAnims(res)

  return res
end

return R
