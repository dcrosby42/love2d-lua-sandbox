M = {}

local Defaults = {
  x = 0,
  y = 0,
  sx = 0.2,
  sy = 0.2,
  h = 100,
  w = 100,
}

M.newEntity = function(estore,res,opts)
  if not opts then opts = {} end
  opts = tcopy(opts,Defaults)
  imgId = "cat-Idle-1"
  local w = res.images[imgId]:getWidth()
  local h = res.images[imgId]:getHeight()
  return estore:newEntity({
    {'pos', {x=opts.x, y=opts.y}},
    {'vel', {}},
    {'tag', {name='bounded'}},
    {'name', {name='cat-Idle-1'}},
    {'img', {imgId=imgId, sx=opts.sx, sy=opts.sy, offx=w/2, offy=h}},
    {'bounds', offsetBounds({}, w * opts.sx, h * opts.sy, 0.5, 1.0)},
  })
end

return M
