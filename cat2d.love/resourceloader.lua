local R={}

local Images = {}

function R.getImage(fname)
  local img = Images[fname]
  if not img then
    img = love.graphics.newImage(fname)
    Images[fname] = img
  end
  return img
end

function R.getFont(fname, size)
  -- TODO
  return nil
end

function R.getSound(fname)
  -- TODO
  return nil
end

return R
