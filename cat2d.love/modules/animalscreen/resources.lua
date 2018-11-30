local R = require 'resourceloader'

local Res = {}

local animalNames = {
  "bear",
  "bee",
  "bunny",
  "cat",
  "chicken",
  "cow",
  "dog",
  "elephant",
  "fish",
  "giraffe",
  "goat",
  "hippo",
  "horse",
  "kangaroo",
  "lemur",
  "leopard",
  "lion",
  "monkey",
  "mouse",
  "owl",
  "penguin",
  "pig",
  "sheep",
  "squirrel",
  "turtle",
  "zebra",
}

local animalsWithSounds = {
  "cat",
  "cow",
  "elepant",
  "elephant",
  "fish",
  "horse",
  "lion",
  "monkey",
  "pig",
}

local cached
function Res.load()
  if not cached then
    local r = {}
    r.animalNames = animalNames
    r.images = {}
    r.images["background1"] = R.getImage("data/images/zoo_keeper.png")

    for _,name in ipairs(animalNames) do
      r.images[name] = R.getImage("data/images/"..name..".png")
    end

    r.soundFilenames = {}
    for _,name in ipairs(animalsWithSounds) do
      r.soundFilenames[name] = "data/sounds/fx/"..name..".wav"
    end
    r.soundFilenames["bgmusic"] = "data/sounds/music/music.wav" 

    cached = r
  end
  return cached
end

return Res
