local Comp = require 'ecs/component'

Comp.define("avatar", {'dir','down', 'motion','standing'})

local MoveSpeed = 200
return defineUpdateSystem(hasComps('avatar','controller'),
  function(e, estore, input, res)
    local c = e.controller
    local av = e.avatar

    -- Standing still or walking?
    local walking = false
    if c.lefty < 0 then
      av.dir = 'up'
      walking = true
    elseif c.lefty > 0 then
      av.dir = 'down'
      walking = true
    end
    if c.leftx < 0 then
      av.dir = 'left'
      walking = true
    elseif c.leftx > 0 then
      av.dir = 'right'
      walking = true
    end
    if walking then
      av.motion = "walking"
    else
      av.motion = "standing"
    end

    -- Update the velocity:
    e.vel.dx = MoveSpeed * e.controller.leftx
    e.vel.dy = MoveSpeed * e.controller.lefty
  end
)
