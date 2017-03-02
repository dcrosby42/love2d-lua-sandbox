
local MoveSpeed = 200
return defineUpdateSystem(hasComps('controller','vel','pos'),
  function(e,estore,input,res)

    -- Update velocity based on controller input:
    local vel = e.vel
    if input.events.controller then
      for _,evt in ipairs(input.events.controller) do
        if evt.id == e.controller.id then
          print(e.eid .. " controller ".. evt.id .. " matches "..e.controller.id)
          if evt.input == 'leftx' then
            vel.dx = MoveSpeed * evt.action
          elseif evt.input == 'lefty' then
            vel.dy = MoveSpeed * evt.action
          end
        end
      end
    end

    -- Update position based on velocity:
    local pos = e.pos
    pos.x = pos.x + vel.dx * input.dt
    pos.y = pos.y + vel.dy * input.dt

  end
)
