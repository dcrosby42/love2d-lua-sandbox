local Debug = require 'mydebug'
local R = require 'resourceloader'
local A = require 'animalpics'
require 'vendor/TEsound'

local M = {}

local function randint(lo,hi)
  return math.floor(love.math.random() * (hi-lo+1)) + lo
end

function M.newWorld()
  local bounds = {w=love.graphics.getWidth(), h=love.graphics.getHeight()}

  local img = R.getImage("data/images/zoo_keeper.png")

  return {
    bounds=bounds,
    bg={
      img=img,
      sizeX=bounds.w / img:getWidth(),
      sizeY=bounds.h / img:getHeight(),
    },
    stamps={},
    selector=0,

    playBgMusic=true,
    bgMusic=0,
  }
end

function M.shutdownWorld(w)
  for i,_ in ipairs(TEsound.channels) do
    TEsound.stop(i)
    TEsound.cleanup()
  end
end

function M.updateWorld(w,action)
  if action.type == "tick" then
    -- print(flattenTable(action))
  elseif action.type == "touch" or action.type == "mouse" then
    if action.state == "pressed" then
      if action.x < 75 and action.y < 75 then
        w.stamps = {}
        Debug.println("Clear")
        w.playBgMusic = not w.playBgMusic
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

  TEsound.cleanup()

  return w
end

local function updateMusic(w)
  if w.playBgMusic and w.bgMusic == 0 then
    w.bgMusic = TEsound.playLooping("data/sounds/music/music.wav", {"bgmusic"})
  elseif w.playBgMusic == false and w.bgMusic ~= 0 then
    TEsound.stop(w.bgMusic)
    w.bgMusic = 0
  end
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

  updateMusic(w)
end

return M
