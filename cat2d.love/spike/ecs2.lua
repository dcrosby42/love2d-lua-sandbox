package.path = package.path .. ';../?.lua'

require 'helpers'

local Estore = require 'estore'
local Comp = require 'component'
local T = Comp.types

-- print("timer pool A: "..T.timer._pool:debugString())
-- print(estore:debugString())
-- print(Comp.debugString(e1.imgs.dude))


-- Comp.define("trans", {'x',0,'y',0,'w',50,'h',50,'ax',0.5,'ay',1,'r',0}, {initSize=1,incSize=0,mulSize=17})
-- Comp.define("img", {})
-- Comp.define("timer",{'event',"", 't',0, 'init',0, 'loop',false}, {initSize=1,incSize=2})
-- estore = Estore:new()
-- e1 = estore:newEntity()

Comp.define("controller", {'id','','up',false,'down',false,'left',false,'right',false})
Comp.define("pos", {'x',0,'y',0})


local function hasComps(...)
  local ctypes = {...}
  local num = #ctypes
  if num == 0 then
    return function(e) return true end
  elseif num == 1 then
    return function(e) 
      return e[ctypes[1]] ~= nil
    end
  elseif num == 2 then
    return function(e) 
      return e[ctypes[1]] ~= nil and e[ctypes[2]] ~= nil
    end
  elseif num == 3 then
    return function(e) 
      return e[ctypes[1]] ~= nil and e[ctypes[2]] and e[ctypes[3]] ~= nil
    end
  elseif num == 4 then
    return function(e) 
      return e[ctypes[1]] ~= nil and e[ctypes[2]] and e[ctypes[3]] ~= nil and e[ctypes[4]] ~= nil 
    end
  else
    return function(e)
      for _,ctype in ipairs(ctypes) do
        if e[ctype] == nil then return end
      end
      return true
    end
  end
end
    

local function controllerSystem(estore, input)
  estore:search(
    hasComps('controller'),
    function(e)
      local events = input.events.controller or {}
      for _,evt in ipairs(events) do
        if evt.id == e.controller.id then
          if evt.action == 'pressed' then
            e.controller[evt.input] = true
          elseif evt.action == 'released' then
            e.controller[evt.input] = false
          end
        end
      end
    end
  )
end

local function posMoverSystem(estore, input)
  estore:eachEntity(function(e)
    if e.controller and e.pos then
      if e.controller.right then
        e.pos.x = e.pos.x + 5
      end
      if e.controller.left then
        e.pos.x = e.pos.x - 5
      end
    end
  end)
end

local function iterFuncs(...)
  local funcs = {...} -- convert varargs into an array
  return function(estore,input)
    for _,fn in ipairs(funcs) do
      fn(estore,input)
    end
  end
end

local function addInputEvent(input, evt)
  if not input.events[evt.type] then
    input.events[evt.type] = {}
  end
  table.insert(input.events[evt.type], evt)
end

print("----------------------------------------------------------------------------")

local estore = Estore:new()
local e1 = estore:newEntity()
estore:newComp(e1, 'pos', {x=50,y=50})
estore:newComp(e1, 'controller', {id='k1'})

updateWorld = iterFuncs(
  controllerSystem,
  posMoverSystem
)

input = {
  dt=1/60,
  events={}
}

print(estore:debugString())

-- tick 1
addInputEvent(input, { type='controller', id='k1', input='right', action='pressed' })
updateWorld(estore,input)
print(estore:debugString())

-- tick 2
input.events={}
updateWorld(estore,input)
print(estore:debugString())

-- tick 3
addInputEvent(input, { type='controller', id='k1', input='right', action='released' })
updateWorld(estore,input)
print(estore:debugString())

