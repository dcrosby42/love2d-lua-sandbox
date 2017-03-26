
return defineUpdateSystem(hasComps('vel','pos'),
  function(e,estore,input,res)
    -- Update position based on velocity:
    local vel = e.vel
    local pos = e.pos

    if e.collidable then
      local x,y = getPos(e)
      x,y,bw,bh = getBoundingRect(e)
      local map = res.maps.town1() -- FIXME CHEATING!
      local bumpWorld = map._sidecar.bumpWorld -- FIXME
      local item = e.collidable.cid
      if bumpWorld:hasItem(item) then
        bumpWorld:update(item, x, y, bw, bh)
      else
        bumpWorld:add(item, x, y, bw,bh)
      end
      goalx = x + vel.dx * input.dt
      goaly = y + vel.dy * input.dt
      finalx, finaly, _collisions, _numcols = bumpWorld:move(item, goalx, goaly)
      pos.x = pos.x + (finalx - x) -- convert back to local coords
      pos.y = pos.y + (finaly - y)
    else
      -- no collision detection
      pos.x = pos.x + vel.dx * input.dt
      pos.y = pos.y + vel.dy * input.dt
    end
  end
)
