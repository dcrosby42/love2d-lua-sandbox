local Comp = require 'ecs/component'

Comp.define("avatar", {'hdir',1, 'motion','standing'})

local MoveSpeed = 200
return defineUpdateSystem(hasComps('avatar','controller'),
  function(e, estore, input, res)
    local c = e.controller
    local av = e.avatar

    -- Standing still or walking?
    local walking = false
    if c.leftx < 0 then
      av.hdir = -1
      walking = true
    elseif c.leftx > 0 then
      av.hdir = 1
      walking = true
    end
    if c.lefty < 0 then
      av.vdir = -1
      walking = true
    elseif c.lefty > 0 then
      av.vdir = 1
      walking = true
    end
    if walking then
      av.motion = "walking"
    else
      av.motion = "standing"
    end

    -- Appear to face left or right?
    if (av.hdir > 0 and e.img.sx < 0) or (av.hdir < 0 and e.img.sx > 0) then
      e.img.sx = -e.img.sx
    end

    -- Update the animation:
    if av.motion == 'standing' then
      e.effects.anim.animFunc = 'cat_idle'
    elseif av.motion == 'walking' then
      e.effects.anim.animFunc = 'cat_walk'
    end

    -- Update the velocity:
    e.vel.dx = MoveSpeed * e.controller.leftx
    e.vel.dy = MoveSpeed * e.controller.lefty
  end
)
