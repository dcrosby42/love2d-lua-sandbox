local Comp = require 'ecs/component'

Comp.define("clickable", {})


return defineUpdateSystem(
  {'clickable','pos','rect'},
  function(e, estore,input,res)
    for _,evt in ipairs(input.events.mouse or {}) do
      if math.pointinrect(evt.x,evt.y,  e.pos.x,e.pos.y, e.rect.w,e.rect.h) then
        if evt.state == 'pressed' then
          -- print("CLICKED")
        elseif evt.state == 'released' then
          -- print("RELEASED")
          estore:newComp(e, 'output', {kind="transition",value="clicker"})
        end
      end
    end
  end
)
