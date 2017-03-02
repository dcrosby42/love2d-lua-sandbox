local here = (...):match("(.*/)[^%/]+$")
local Cat = require(here..'/cat')

local Estore = require 'ecs/estore'


return function()
  local estore = Estore:new()

  local scene = estore:newEntity({
    {'tag', {name='room1'}},
    {'zChildren', {}},
    {'pos', {}},
    {'vel', {}},
    {'controller', {id='con2'}},
  })

  local c = {
    white={255,255,255},
    black={0,0,0},
    red={255,0,0},
    green={50,230,50},
    blue={0,0,255},
    brown={127, 95, 26},
  }
  local tree3 = function(opts)
    local fullH = opts.trunkH + opts.bushH
    local fullW = opts.bushW

    return opts.parent:newChild({
      {'pos', {x=opts.x, y=opts.y}},
      {'name', {name='tree'}},
      -- {'bounds', {offx=-fullW/2,offy=-fullW,w=fullW,h=fullH}},
      {'bounds', offsetBounds({},fullW,fullH, 0.5, 1.0)},
    }, {
      {
        {'pos', {x=0,y=0}},
        -- {'rect', {offx=-opts.trunkW/2, offy=-opts.trunkH, w=opts.trunkW,h=opts.trunkH,color=opts.trunkCol}},
        {'rect', offsetBounds({color=opts.trunkCol}, opts.trunkW, opts.trunkH, 0.5, 1.0)},
      },
      {
        {'pos', {x=0,y=-opts.trunkH}},
        {'rect', {offx=-opts.bushW/2, offy=-opts.bushH, w=opts.bushW,h=opts.bushH,color=opts.bushCol}},
      },
    })
  end

  local opts = {
    parent=scene,
    x=100,
    y=100,
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
      tree3(opts)
    end
  end

  local cat = Cat.newEntity(estore)
  cat:newComp('controller', {id='con1'})
  cat:newComp('name', {name='Player1'})

  scene:addChild(cat)

  return estore
end
