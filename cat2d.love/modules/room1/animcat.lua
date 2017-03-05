M = {}

eg = {'avatar_control', {
  hdir="left",  -- left | right
  vdir="down",  -- up | down
  tryMove="right",  -- up | down | left | right
  tryRun=false,
  tryJump=false,
}}



local CatDefaults = {
  x = 0,
  y = 0,
  sx = 0.5,
  sy = 0.5,
  h = 100,
  w = 100,
}

local function genAnimEffectsData(prefix,count,interval)
  local data = {}
  local t = 0
  for i = 1,count do
    table.insert(data,t)
    table.insert(data, prefix .. i)
    t = t + interval
  end
  return data
end

M.newEntity = function(estore,res,opts)
  if not opts then opts = {} end
  opts = tcopy(opts,CatDefaults)
  imgId = "cat-Idle-1"
  local w = res.images[imgId]:getWidth()
  local h = res.images[imgId]:getHeight()
  local cat = estore:newEntity({
    {'name', {name='Animated Cat'}},
    {'pos', {x=opts.x, y=opts.y}},
    {'vel', {}},
    -- {'tag', {name='bounded'}},
    {'img', {imgId=imgId, sx=opts.sx, sy=opts.sy, offx=w/2, offy=h}},
    {'bounds', offsetBounds({}, w * opts.sx, h * opts.sy, 0.5, 1.0)},
  })

  local numFrames = 10
  local frameInt = 0.07
  -- local edata = genAnimEffectsData("cat-Idle-", numFrames, frameInt)
  local edata = genAnimEffectsData("cat-Walk-", numFrames, frameInt)
  cat:newChild({
    {'name', {name='Cat Idle animation'}},
    {'timer', {name='anim', t=0, reset=(numFrames*frameInt), countDown=false, loop=true}},
    {'effect', {timer='anim', path={'PARENT','img','imgId'}, data=edata}},
    -- {'tag', {name='self_destruct'}},
    -- {'timer', {name='self_destruct', t=2}},
  })
  return cat
end

return M
