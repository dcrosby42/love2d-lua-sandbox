require 'ecs/ecshelpers'
local Estore = require 'ecs/estore'

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

local DoUpdate = iterateFuncs({
  outputCleanupSystem,
  timerSystem,
  selfDestructSystem,
  controllerSystem,
  moverSystem,

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

  local scene = buildEntity(estore, {
    {'tag', {name='room1'}},
  })

  local ord = 0
  local box = function(p,x,y,w,h,col)
    local ent = buildEntity(estore, {
      {'pos', {x=x,y=y}},
      {'rect', {offx=-w/2, offy=-h/2, w=w,h=h,color=col}},
      {'parent', {parentEid=p.eid, order=ord}},
    })
    ord = ord + 1
    return ent
  end
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

    local tree = buildEntity(estore, {
      {'pos', {x=opts.x, y=opts.y}},
      {'bounds', {offx=-fullW/2,offy=-fullW,w=fullW,h=fullH}},
      {'parent', {parentEid=opts.parent.eid, order=opts.order}},
    })
    buildEntity(estore, {
      {'pos', {x=0,y=0}},
      {'rect', {offx=-opts.trunkW/2, offy=-opts.trunkH, w=opts.trunkW,h=opts.trunkH,color=opts.trunkCol}},
      {'parent', {parentEid=tree.eid, order=0}},
    })
    buildEntity(estore, {
      {'pos', {x=0,y=-opts.trunkH}},
      {'rect', {offx=-opts.bushW/2, offy=-opts.bushH, w=opts.bushW,h=opts.bushH,color=opts.bushCol}},
      {'parent', {parentEid=tree.eid, order=1}},
    })
    return tree
  end

  local opts = {
    parent=scene,
    order=1,
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
      opts.order = opts.order + 1
      tree3(opts)
    end
  end

  local player = box(scene, 400,260, 20,32, {200,200,200})
  estore:newComp(player, 'tag', {name='player'})
  estore:newComp(player, 'name', {name='Player1'})
  estore:newComp(player, 'controller', {id='con1'})
  estore:newComp(player, 'bounds', {offx=-10,offy=-16,w=20,h=32})
  estore:newComp(player, 'vel', {})

  local item = box(player, 12,-3, 13,7, {150,150,190})

  ------------------------------------
  return estore
end



return M
