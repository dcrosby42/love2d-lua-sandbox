M = {}


local CatDefaults = {
  x = 0,
  y = 0,
  sx = 0.3,
  sy = 0.3,
}

M.newEntity = function(estore,res,opts)
  if not opts then opts = {} end
  opts = tcopy(opts,CatDefaults)
  imgId = "cat-Idle-1"
  local w = res.images[imgId]:getWidth()
  local h = res.images[imgId]:getHeight()

  local cat = estore:newEntity({
    {'avatar',{}},
    {'name', {name='Animated Cat'}},
    {'pos', {x=opts.x, y=opts.y}},
    {'vel', {}},
    {'tag', {name='bounded'}},
    {'img', {imgId=imgId, sx=opts.sx, sy=opts.sy, offx=w/2, offy=h}},
    {'bounds', offsetBounds({}, w * opts.sx, h * opts.sy, 0.5, 1.0)},
    {'timer', {name='anim', t=0, reset=0.7, countDown=false, loop=true}},
    {'effect', {name='anim', timer='anim', path={'img','imgId'}, animFunc='cat_idle'}},
  })

  return cat
end

return M
