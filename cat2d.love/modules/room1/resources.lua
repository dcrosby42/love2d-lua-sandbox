local R = {}

local ImageConfig = {
  catIcon        = {file="images/black-cat-icon.png"},
  arcticCatTitle = {file="images/arctic_cat_title.png"},
  snowField      = {file="images/simple-snow-field.png"},
  tree1          = {file="images/snowy-evergreen-1.png"},
}

-- images/cat/
-- Dead(10), Fall(8), Hurt(10), Idle(10), Jump(8), Run(8), Slide(10), Walk(10)
CatAnims = {
  {name='Idle', numframes=10},
  {name='Walk', numframes=10},
  {name='Run', numframes=8},
  {name='Slide', numframes=10},
  {name='Jump', numframes=8},
  {name='Fall', numframes=8},
  {name='Hurt', numframes=10},
  {name='Dead', numframes=10},
}
for _, anim in ipairs(CatAnims) do
  for i = 1, anim.numframes do
    imgname = "cat-"..anim.name.."-"..i
    imgfilename = "images/cat/"..anim.name.." (".. i ..").png"
    ImageConfig[imgname] = {file=imgfilename}
  end
end

local FontConfig = {
  ["Adventure-50"] = {file="fonts/Adventure.ttf", size=50},
  ["Adventure-100"] = {file="fonts/Adventure.ttf", size=100},
}

R.load = function()
  local res = {
    images={},
    fonts={},
  }

  for key,cfg in pairs(ImageConfig) do
    res.images[key] = love.graphics.newImage(cfg.file)
  end

  for key,cfg in pairs(FontConfig) do
    res.fonts[key] = love.graphics.newFont(cfg.file, cfg.size)
  end

  print(tdebug(res))
  return res
end

return R
