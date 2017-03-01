local here = (...):match("(.*/)[^%/]+$")

require 'ecs/ecshelpers'
local Estore = require 'ecs/estore'
local Comp = require 'ecs/component'
local Cat = require(here..'/cat')
require 'comps'


local timerSystem = require 'systems/timer'
local selfDestructSystem = require 'systems/selfdestruct'
local outputCleanupSystem = require 'systems/outputcleanup'
local effectsSystem = require 'systems/effects'
local controllerSystem = require 'systems/controller'
local drawSystem = require 'systems/drawstuff'

-- resource name shortcuts
local catIcon = "images/black-cat-icon.png"
local arcticCatTitle = "images/arctic_cat_title.png"


local MoveSpeed = 200
local moverSystem = defineUpdateSystem(hasComps('controller','vel','pos'),
  function(e,estore,input,res)
    local vel = e.vel
    if input.events.controller then
      for _,evt in ipairs(input.events.controller) do
        if evt.input == 'leftx' then
          vel.dx = MoveSpeed * evt.action
        elseif evt.input == 'lefty' then
          vel.dy = MoveSpeed * evt.action
        end
      end
    end

    local x,y = getPos(e)
    if vel.x ~= 0 then
      e.pos.x = x + vel.dx * input.dt
    end
    if vel.y ~= 0 then
      e.pos.y = y + vel.dy * input.dt
    end
  end
)

Comp.define("zChildren", {})
local zChildrenSystem = defineUpdateSystem(hasComps('zChildren'),
  function(e,estore,input,res)
    for _, ch in ipairs(e:getChildren()) do
      if ch.pos then
        x,y = getPos(ch)
        ch.parent.order = y
      end
    end
    e:resortChildren()
  end
)

local DoUpdate = iterateFuncs({
  outputCleanupSystem,
  timerSystem,
  selfDestructSystem,
  controllerSystem,
  moverSystem,
  zChildrenSystem,

  effectsSystem,
})

local DoDraw = iterateFuncs({
  drawSystem,
})

local M ={}

local newSnowScene

M.newWorld = function()
  local w = {
    bgcolor = {0,0,100},
    estore = buildEstore(),
    input = { dt=0, events={} },
    resources = {
      images={
        [catIcon] = love.graphics.newImage(catIcon),
        -- [arcticCatTitle] = love.graphics.newImage(arcticCatTitle),
      },
      fonts={
        -- ["Adventure-100"] = love.graphics.newFont("fonts/Adventure.ttf",100),
        -- ["AdventureOutline-50"] = love.graphics.newFont("fonts/Adventure Outline.ttf",50),
        -- ["narpassword-medium"] = love.graphics.newFont("fonts/narpassword.ttf",30),
      }
    },
  }

  return w, nil
end

M.updateWorld = function(world, action)
  local effects = nil

  if action.type == 'tick' then
    world.input.dt = action.dt

    local estore = world.estore
    DoUpdate(estore, world.input, world.resources)

    world.input.events = {}

    estore:search(hasComps('output'), function(e)
      effects = {}
      for _,out in pairs(e.outputs) do
        -- print("Effect: "..out.kind)
        effects[#effects+1] = {type=out.kind, value=out.value}
      end
    end)

  elseif action.type == 'mouse' then
    if action.button == 1 then
      if action.state == "pressed" then
        addInputEvent(world.input, {type='tap', id='p1', x=action.x, y=action.y})
      end
    elseif action.button == 2 then
      if action.state == "pressed" then
        addInputEvent(world.input, {type='untap', id='p1', x=action.x, y=action.y})
      end
    end

  elseif action.type == 'keyboard' then
    addInputEvent(world.input, action)

    local key = action.key
    if key == "p" then
      local estore = world.estore
      print("============================================================================")
      print(estore:debugString())
    elseif key == "g" then
      local estore = world.estore
      if estore.etree then
        print("============================================================================")
        print("-- Entity tree (Estore.etree):")
        print(tdebug(estore.etree.ROOT))
      end
    elseif key == "x" and action.state == 'pressed' then
      print("Manual switchover")
      effects = {
        {type='transition', value='leave'}
      }
    else
      local kbd = false
      if key == "w" then
        local mag = -1
        if action.state == 'released' then mag = 0 end
        addInputEvent(world.input, {type='controller', id='con1', input="lefty", action=mag})
      elseif key == "s" then
        local mag = 1
        if action.state == 'released' then mag = 0 end
        addInputEvent(world.input, {type='controller', id='con1', input="lefty", action=mag})
      elseif key == "a" then
        local mag = -1
        if action.state == 'released' then mag = 0 end
        addInputEvent(world.input, {type='controller', id='con1', input="leftx", action=mag})
      elseif key == "d" then
        local mag = 1
        if action.state == 'released' then mag = 0 end
        addInputEvent(world.input, {type='controller', id='con1', input="leftx", action=mag})
      end
    end

  end

  return world, effects
end

M.drawWorld = function(world)
  love.graphics.setBackgroundColor(unpack(world.bgcolor))

  DoDraw(world.estore, nil, world.resources)
end

-- ---------------------------------------------------------------
function buildEstore()
  local estore = Estore:new()

  local scene = estore:newEntity({
    {'tag', {name='room1'}},
    {'zChildren', {}},
    {'pos', {}}
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

function offsetBounds(t, w,h, wr, hr)
  t.w = w
  t.h = h
  t.offx = -wr * w
  t.offy = -hr * h
  return t
end

return M
