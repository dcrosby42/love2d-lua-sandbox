local Field = {}

local function mkTreeImg(estore, opts, res)
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
    {'bounds', {w=600,h=300}},
    {'vel', {}},
    {'controller', {id='con2'}},
  })

  -- Make a bunch of trees:
  local opts = {
    x=100,
    y=100,
    scalex=0.7,
    scaley=0.7,
  }

  for i = 0,800,120 do
    for j = 100,600,200 do
      opts.x = i
      opts.y = j
      local tr = mkTreeImg(estore, opts, res)
      field:addChild(tr)
    end
  end

  return field
end


return Field
