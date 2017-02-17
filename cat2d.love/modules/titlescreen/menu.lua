local M = {}

local ColdBlue = {36,153,204}
local ColdBlue_Bright = {86,203,254}

local Comp = require 'ecs/component'
Comp.define('menu',{'selected',nil,'choices',{}})
Comp.define('menu_item',{'name','','value',''})

function cycleMenuUp(e)
  local chs = e.menu.choices
  local index = tindexOf(chs, e.menu.selected) + 1
  if index >= #chs+1 then index = 1 end
  e.menu.selected = chs[index]
end

function cycleMenuDown(e)
  local chs = e.menu.choices
  local index = tindexOf(chs, e.menu.selected) - 1
  if index < 0 then index = #chs end
  e.menu.selected = chs[index]
end

function addBlueFlicker(estore, e,time)
  buildEntity(estore, {
    {'timer', {name='flicker', t=0, reset=0.16, countDown=false, loop=true}},
    {'effect', {
      path={'PARENT','label','color'},
      data={0,ColdBlue, 0.08, ColdBlue_Bright}}},
    {'tag', {name='self_destruct'}},
    {'timer', {name='self_destruct', t=time}},

    {'parent', {parentEid=e.eid}},
  })
end

local menuSystem = defineUpdateSystem({'menu'},
  function(e, estore,input,res)

    -- check for keyboard input:
    if input.events.keyboard then
      for _,action in ipairs(input.events.keyboard) do
        if action.key == "up" and action.state == "pressed" then
          cycleMenuUp(e)
        elseif action.key == "down" and action.state == "pressed" then
          cycleMenuUp(e)
        elseif action.key == "return" and action.state == "pressed" then
          local time = 1.0
          estore:search(hasComps('menu_item'), function(mie)
            if mie:getParent().eid == e.eid then
              if mie.menu_item.name == e.menu.selected then
                estore:newComp(mie, 'timer', {name='item_selected',t=time})
                addBlueFlicker(estore, mie, time)
              end
            end
          end)
        end
      end
    end
  end
)

--
-- menu_item system
--
local menuItemSystem = defineUpdateSystem({'menu_item'},
  function(e, estore,input,res)
    -- Look for timeout:
    if e.timers then
      local selTimer = e.timers.item_selected
      if selTimer and selTimer.alarm then
        estore:newComp(e, 'output', {kind='transition',value=e.menu_item.value})
        estore:removeComp(selTimer)
      end
    end

    -- Check for selected:
    local parent = e:getParent()
    if parent then
      if e.menu_item.name == parent.menu.selected then
        e.label.color = ColdBlue_Bright
      else
        e.label.color = ColdBlue
      end
    end

    -- Check for mouse clicks / taps on this item:
    if input.events.tap then
      for _,evt in ipairs(input.events.tap) do
        local b = e.bounds
        if math.pointinrect(evt.x,evt.y, b.x,b.y,b.w,b.h) then
          -- set menu selection to this item
          parent.menu.selected = e.menu_item.name
          -- add visual effect (flicker color)
          local time = 1.0
          addBlueFlicker(estore, e,time)
          -- Set the timeout:
          estore:newComp(e, 'timer', {name='item_selected',t=time})
        end
      end
    end
  end
)

M.Setup = function(world)
  local f = world.resources.fonts
  f["Adventure-50"] = love.graphics.newFont("fonts/Adventure.ttf",50)
  f["Adventure-100"] = love.graphics.newFont("fonts/Adventure.ttf",100)
  f["AdventureOutline-50"] = love.graphics.newFont("fonts/Adventure Outline.ttf",50)
  f["narpassword-medium"] = love.graphics.newFont("fonts/narpassword.ttf",30)
end

function buildMenu(estore)
  local menu = buildEntity(estore, {
    {'menu', {state='selecting',selected='start', choices={'start','continue'}}},
    {'menu', {state='selecting',selected='start', choices={'start',}}},
  })
--
  local y = 170
  buildEntity(estore, {
    {'label', {text='Arctic Cat', font="Adventure-100", color=ColdBlue, width=800, align='center'}},
    {'pos', {x=0, y=y}},
    {'parent', {parentEid=menu.eid, order=2}}
  })
  y = y + 120
  buildEntity(estore, {
    {'menu_item', {name='start',value='start'}},
    {'tag', {name='menu_item'}},
    {'tag', {name='start'}},
    {'label', {text='START', font="narpassword-medium", color=ColdBlue, width=800, align='center'}},
    {'pos', {x=0, y=y}},
    {'bounds',{x=0,y=y,w=800,h=50}},
    {'parent', {parentEid=menu.eid, order=2}}
  })
  y = y + 50
  buildEntity(estore, {
    {'menu_item', {name='continue',value='continue'}},
    {'tag', {name='menu_item'}},
    {'tag', {name='continue'}},
    {'label', {text='CONTINUE', font="narpassword-medium", color=ColdBlue, width=800, align='center'}},
    {'pos', {x=0, y=y}},
    {'bounds',{x=0,y=y,w=800,h=50}},
    {'parent', {parentEid=menu.eid, order=2}},
  })

  return menu
end

M.BuildMenuEntity = buildMenu

M.System = iterateFuncs({
  menuSystem,
  menuItemSystem,
})

return M
