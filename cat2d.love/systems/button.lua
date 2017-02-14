local Comp = require 'ecs/component'

Comp.define("mouse_sensor", {'on','pressed','eventName','','eventData',''})

return defineUpdateSystem(
  {'mouse_sensor','pos','rect'},
  function(e, estore,input,res)
    for _,evt in ipairs(input.events.mouse or {}) do
      if math.pointinrect(evt.x,evt.y,  e.pos.x,e.pos.y, e.rect.w,e.rect.h) then
        local s = e.mouse_sensor
        if evt.state == s.on then
          estore:newComp(e, 'event', {name=s.eventName, data=s.eventData})
        end
      end
    end
  end
)
