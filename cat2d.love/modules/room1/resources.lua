local R = {}

local ImageConfig = {
  catIcon        = {file="images/black-cat-icon.png"},
  arcticCatTitle = {file="images/arctic_cat_title.png"},
  snowField      = {file="images/simple-snow-field.png"},
}

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

  return res
end

return R
