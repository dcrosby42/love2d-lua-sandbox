local A = {}

local names = {
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

-- name fname sx sy cx cy
--   img w h
--

A.animals = {}
for _,n in ipairs(names) do
  local an = {
    name=n,
    file="data/images/"..n..".png",
    sizeX=0.5,
    sizeY=0.5,
    centerX=0.5,
    centerY=0.5,
  }
  table.insert(A.animals, an)
end

return A
