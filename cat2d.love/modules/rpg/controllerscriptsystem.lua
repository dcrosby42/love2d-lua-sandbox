local Comp = require 'ecs/component'

Comp.define("controllerScript", {'script','','timerName','','controllerPath',{}})

local idling = makeTimeLookupFunc({
  0, 'stop',
  1, 'walkleft',
  2, 'stop',
  3, 'walkright',
  4, 'stop',
  5, 'walkright',
  6, 'stop',
  7, 'walkleft',
  8, 'stop',
  9, 'walkup',
  10, 'stop',
  11, 'walkdown',
  12, 'stop',
  13, 'walkdown',
  14, 'stop',
  15, 'walkup',
  16, 'stop',
})

return defineUpdateSystem(hasComps('controllerScript'),function(e,estore,input,res)
  -- print(e:getParent().avatar.name)
  local cs = e.controllerScript
  local _,controller,_ = resolveEntCompKeyByPath(e, cs.controllerPath)
  local timer = e.timers[cs.timerName]
  -- local script = res.data.scripts[cs.script]()

  if cs.script == 'idlingTownsman' then
    local s = idling(timer.t)
    local walkspd = 0.3
    if s == 'stop' then
      controller.leftx = 0
      controller.lefty = 0
    elseif s == 'walkleft' then
      controller.leftx = -walkspd
      controller.lefty = 0
    elseif s == 'walkright' then
      controller.leftx = walkspd
      controller.lefty = 0
    elseif s == 'walkup' then
      controller.leftx = 0
      controller.lefty = -walkspd
    elseif s == 'walkdown' then
      controller.leftx = 0
      controller.lefty = walkspd
    end
  end

  -- print(tdebug1(con))
end)
