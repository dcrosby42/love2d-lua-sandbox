local here = (...):match("(.*/)[^%/]+$")
local Cat = require(here..'/cat')

local Estore = require 'ecs/estore'

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

return function(res)
  local estore = Estore:new()
  estore:newEntity({
    {'tag', {name='debug'}},
    {'debug', {name='drawBounds',value=false}}
  })

  local base = estore:newEntity({
    {'pos', {}},
  })

  -- terrain image
  base:newChild({
    { 'name', {name='name'}},
    { 'img', {imgId='snowField'}},
    { 'pos', {0,0}},
  })

  -- scene root
  local scene = base:newChild({
    {'tag', {name='room1'}},
    {'zChildren', {}},
    {'pos', {}},
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
      scene:addChild(tr)
    end
  end

  -- Create a cat
  local cat = Cat.newEntity(estore)
  -- take control of cat
  cat:newComp('controller', {id='con1'})
  cat:newComp('name', {name='Player1'})
  scene:addChild(cat)

  return estore
end
