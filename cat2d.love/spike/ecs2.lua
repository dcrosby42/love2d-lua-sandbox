package.path = package.path .. ';../?.lua'

require 'helpers'
require 'ecshelpers'

local Estore = require 'estore'
local Comp = require 'component'
local T = Comp.types

Comp.define("controller", {'id','','leftx',0,'lefty',0,})
Comp.define("pos", {'x',0,'y',0})
Comp.define("bounds", {'x',0,'y',0,'w',0,'h',0})
Comp.define("img", {'imgId','','ax',0,'ay',0,'sx',1,'sy',1,'r',0})
Comp.define("tag", {})
Comp.define("iconAdder", {'imgId', '', 'tagName', ''})

local function controllerSystem(estore, input,res)
  estore:search(
    hasComps('controller'),
    function(e)
      local events = input.events.controller or {}
      for _,evt in ipairs(events) do
        if evt.id == e.controller.id then
          e.controller[evt.input] = evt.action
        end
      end
    end
  )
end

local function posMoverSystem(estore, input,res)
  estore:search(
    hasComps('controller', 'pos'),
    function(e)
      e.pos.x = e.pos.x + (600 * e.controller.leftx * input.dt)
    end
  )
end

local function createNewIcon(estore, tap, adderComp, res)
  local e = estore:newEntity()
  estore:newComp(e, 'tag', {name=adderComp.tagName})
  estore:newComp(e, 'img', {imgId=adderComp.imgId})
  estore:newComp(e, 'pos', {x=tap.x, y=tap.y})
  estore:newComp(e, 'bounds', {x=tap.x, y=tap.y, w=50, h=50})
end

local function iconAdderSystem(estore, input,res)
  for _,tap in ipairs(input.events.tap or {}) do
    estore:search(
      hasComps('iconAdder'),
      function(e)
        for _,adder in pairs(e.iconAdders) do
          if adder.id == tap.id then
            createNewIcon(estore, tap, adder, res)
          end
        end
      end
    )
  end
end

local function drawImgSystem(estore,output,res)
  estore:search(
    hasComps('img','pos'),
    function(e)
      print(":: love.graphics.draw(res.images["..e.img.imgId.."], "..e.pos.x..","..e.pos.y..")")
      -- love.graphics.draw(
      --   res.images[img.imgid]
      --   e.pos.x, e.pos.y,
      --   e.img.r,     -- radians
      --   e.img.sx, e.img.sy,  -- scalex, scaley
      --   e.img.ax, ay)  -- offx, offy
    end
  )
end

print("----------------------------------------------------------------------------")

local estore = Estore:new()
local e1 = estore:newEntity()
estore:newComp(e1, 'pos', {x=50,y=50})
estore:newComp(e1, 'controller', {id='p1'})
estore:newComp(e1, 'iconAdder', {id='p1', imgId='cat.jpg', tagName='cattish'})

local e2 = estore:newEntity()
estore:newComp(e2, 'iconAdder', {id='p2', imgId='dog.jpg', tagName='doggish'})
estore:newComp(e2, 'iconAdder', {id='p2', imgId='circle.jpg', tagName='circ'})

updateWorld = iterateFuncs(
  controllerSystem,
  iconAdderSystem,
  posMoverSystem
)

drawWorld = iterateFuncs(
  drawImgSystem
)

input = {
  dt=1/60,
  events={}
}

print(estore:debugString())

-- tick 1
addInputEvent(input, { type='controller', id='p1', input='leftx', action=1.0 })
updateWorld(estore,input)
print(estore:debugString())

-- tick 2
input.events={}
updateWorld(estore,input)
print(estore:debugString())

-- tick 3
addInputEvent(input, { type='controller', id='p1', input='leftx', action=0.0 })
updateWorld(estore,input)
print(estore:debugString())

-- tick 4
addInputEvent(input, { type='tap', id='p1', touchid='0x12345', x=120, y=73})
addInputEvent(input, { type='tap', id='p1', touchid='0x12346', x=66, y=88})
addInputEvent(input, { type='tap', id='p2', touchid='0x45451', x=200, y=124})
updateWorld(estore,input)
print(estore:debugString())

-- faux draw
output={}
res={}
drawWorld(estore,output,res)
