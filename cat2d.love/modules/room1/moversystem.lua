
function forControllerInputEvents(input, id, fn)
  forEachMatching(input.events.controller, 'id', id, fn)
end

local MoveSpeed = 200
return defineUpdateSystem(hasComps('controller','vel','pos'),
  function(e,estore,input,res)

    -- Update velocity based on controller input:
    forControllerInputEvents(input, e.controller.id, function(evt)
      if evt.input == 'leftx' then
        e.vel.dx = MoveSpeed * evt.action
      elseif evt.input == 'lefty' then
        e.vel.dy = MoveSpeed * evt.action
      end
    end)

    -- Update position based on velocity:
    local vel = e.vel
    local pos = e.pos
    pos.x = pos.x + vel.dx * input.dt
    pos.y = pos.y + vel.dy * input.dt

  end
)
