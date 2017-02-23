local Comp = require 'ecs/component'

Comp.define("mouse_sensor", {'on','pressed','eventName','','eventData',''})

return defineUpdateSystem(
  {'mouse_sensor','pos','rect'},
  function(e, estore,input,res)
    local sensor = e.mouse_sensor
    local x,y = getPos(e)
    for _,evt in ipairs(input.events.mouse or {}) do
      if evt.state == sensor.on then
        if math.pointinrect(evt.x,evt.y,  x,y, e.rect.w,e.rect.h) then
          estore:newComp(e, 'event', {name=sensor.eventName, data=sensor.eventData})
        end
      end
    end
  end
)
