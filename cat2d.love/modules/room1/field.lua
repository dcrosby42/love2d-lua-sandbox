local Field = {}

local c = {
  white={255,255,255},
  black={0,0,0},
  red={255,0,0},
  green={50,230,50},
  blue={0,0,255},
  brown={127, 95, 26},
}

local function mkTree(estore, opts)
  local fullH = opts.trunkH + opts.bushH
  local fullW = opts.bushW
  return estore:newEntity({
    {'pos', {x=opts.x, y=opts.y}},
    {'name', {name='tree'}},
    {'bounds', offsetBounds({},fullW,fullH, 0.5, 1.0)},
  }, {
    {
      {'name', {name='trunk'}},
      {'pos', {x=0,y=0}},
      {'rect', offsetBounds({color=opts.trunkCol}, opts.trunkW, opts.trunkH, 0.5, 1.0)},
    },
    {
      {'name', {name='branches'}},
      {'pos', {x=0,y=-opts.trunkH}},
      {'rect', {offx=-opts.bushW/2, offy=-opts.bushH, w=opts.bushW,h=opts.bushH,color=opts.bushCol}},
    },
  })
end

local function mkTreeImg(estore, opts, res)
  local fullH = opts.trunkH + opts.bushH
  local fullW = opts.bushW
  local tree1 = res.images.tree1
  local w = tree1:getWidth()
  local h = tree1:getHeight()
  local sx = opts.scalex
  local sy = opts.scaley
  return estore:newEntity({
    {'pos', {x=opts.x, y=opts.y}},
    {'name', {name='tree'}},
    {'img', {imgId='tree1', sx=sx, sy=sy, offx=w/2, offy=h}},
    {'bounds', offsetBounds({},w*sx,h*sy, 0.5, 1.0)},
  })
end

Field.newFieldEntity = function(estore, res)
  -- field
  local field = estore:newEntity({
    {'tag', {name='room1-field'}},
    {'zChildren', {}},
    {'pos', {x=100, y=300}},
    {'bounds', {w=300,h=300}},
    {'vel', {}},
    {'controller', {id='con2'}},
  })

  -- Make a bunch of trees:
  local opts = {
    x=100,
    y=100,
    scalex=0.5,
    scaley=0.5,
    trunkW=30,
    trunkH=60,
    bushW=100,
    bushH=60,
    trunkCol=c.brown,
    bushCol=c.green
  }

  for i = 0,800,120 do
    for j = 100,600,200 do
      opts.x = i
      opts.y = j
      local tr = mkTreeImg(estore, opts, res)
      -- local tr = mkTree(estore, opts)
      field:addChild(tr)
    end
  end

  return field
end


return Field
