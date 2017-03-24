
return defineUpdateSystem(hasComps('vel','pos'),
  function(e,estore,input,res)
    -- Update position based on velocity:
    local vel = e.vel
    local pos = e.pos
    pos.x = pos.x + vel.dx * input.dt
    pos.y = pos.y + vel.dy * input.dt
  end
)
