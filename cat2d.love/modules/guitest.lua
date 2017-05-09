local Estore = require 'ecs.estore'
require 'comps'
local Comp = require 'ecs/component'

local timerSystem = require 'systems/timer'
local selfDestructSystem = require 'systems/selfdestruct'
local outputCleanupSystem = require 'systems/outputcleanup'
local effectsSystem = require 'systems/effects'
local zChildrenSystem = require 'systems/zchildren'
local drawSystem = require 'systems/drawstuff'


local M ={}

Comp.define("mousehandler", {'on','pressed', 'button','', 'script',''})

local context = {
  script='',
  entity='',
  estore='',
  input='',
  res='',
  args={},
}

local mouseEventSystem = function(estore,input,res)
  if input.events.mouse then
    for i=1,#input.events.mouse do
      local evt = input.events.mouse[i]
      estore:walkEntities(hasComps('mousehandler'), function(e)
        local x,y,w,h = getBoundingRect(e)
        if math.pointinrect(evt.x, evt.y, x,y,w,h) then
          for _,handler in pairs(e.mousehandlers) do
            if string.find(handler.on, evt.state) then
              -- TODO button match? if e.mousehandler.button == '' or (e.mousehandler.button ~= '1' and string.find(e.mousehandler.button, ""..evt.button)) then
              if e.scripts and e.scripts[handler.scriptName] then
                local scriptFunc = res.scripts[e.scripts[handler.scriptName].script]
                if scriptFunc then
                  context.script = script
                  context.entity = e
                  context.estore = estore
                  context.input = input
                  context.res = res
                  context.args = evt
                  scriptFunc(context)
                end
              end
              -- end
            end
          end -- for handlers
        end -- if pointinrect
      end)
    end
  end
end

local runSystems = iterateFuncs({
  mouseEventSystem,
--   outputCleanupSystem,
--   timerSystem,
--   selfDestructSystem,
--   zChildrenSystem,
--   effectsSystem,
})
local function newButton(estore, opts)
  return estore:newEntity({
    {'pos',{x=opts.x, y=opts.y}},
    {'bounds',{w=opts.w,h=opts.h}},
    {'tag', {name='mousey'}},
    {'rect', {style='line',w=opts.w,h=opts.h,color=opts.color}},
    {'script', {name='hdlr', script=opts.script}},
    {'mousehandler', {name='a',on='pressed', button='1', scriptName='hdlr'}},
    {'script', {name='hdlr2', script="m"..opts.script}},
    {'mousehandler', {name='b',on='moved', button='', scriptName='hdlr2'}},
  },{
    {
      {'pos',{}},
      {'label', {text=opts.label, font="narpassword-medium", color=opts.color, width=opts.w, align='center'}},
    }
  })
end

local function buildEstore(opts,res)
  local estore = Estore:new()

  local g1 = estore:newEntity({
    {'pos',{x=200,y=125}},
    {'bounds',{w=100,h=150}}
  })
  g1:addChild(newButton(estore, {label="One",script='one', x=0, y=0, w=100, h=50, color={100,100,255}}))
  g1:addChild(newButton(estore, {label="Two",script='two',x=0, y=50, w=100, h=50, color={100,100,255}}))
  g1:addChild(newButton(estore, {label="Three",script='three',x=0, y=100, w=100, h=50, color={100,100,255}}))

  return estore
end

local function newWorld(opts)
  local res = {
    fonts = {
      ["narpassword-medium"] = love.graphics.newFont("fonts/narpassword.ttf",30)
    },
    scripts = {
      one=function(ctx) print("one!") end,
      two=function(ctx) print("two!") end,
      three=function(ctx) print("three!") end,
      mone=function(ctx) print("...one!") end,
      mtwo=function(ctx) print("...two!") end,
      mthree=function(ctx) print("...three!") end,
    }
  }
  local estore = buildEstore(opts,res)
  local world = {
    bgcolor = {0,0,0},
    estore = estore,
    input = { dt=0, events={} },
    resources = res,
  }
  return world
end

local function updateWorld(world,action)
  if action.type == 'tick' then
    runSystems(world.estore, world.input, world.resources)
    world.input.events = {}

  elseif action.type == 'mouse' then
    addInputEvent(world.input, shallowclone(action))
  end

  return world
end

local function drawWorld(world,action)
  love.graphics.setBackgroundColor(0,0,0)
  love.graphics.setColor(255,255,255)

  drawSystem(world.estore, nil, world.resources)
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
