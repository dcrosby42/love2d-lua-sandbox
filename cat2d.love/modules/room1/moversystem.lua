
function forControllerInputEvents(input, id, fn)
  forEachMatching(input.events.controller, 'id', id, fn)
end

function extremeties(x,y,bounds)
  local left = x - bounds.offx
  local right = left + bounds.w
  local top = y - bounds.offy
  local bottom = top + bounds.h
  return {
    left=left,
    right=right,
    top=top,
    bottom=bottom,
  }
end

function localExtremeties(bounds)
  local x = 0
  local y = 0
  local left = x - bounds.offx
  local right = left + bounds.w
  local top = y - bounds.offy
  local bottom = top + bounds.h
  return {
    left=left,
    right=right,
    top=top,
    bottom=bottom,
  }
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

    if e.tags.bounded then
      local par = e:getParent()
      if par and par.bounds then
        local px,py = getPos(par)
        local pext = localExtremeties(par.bounds)
        local mbnds = e.bounds
        local mext = extremeties(pos.x, pos.y, mbnds)
        if mext.right > pext.right then
          pos.x = pext.right - mbnds.w + mbnds.offx
        elseif mext.left < pext.left then
          pos.x = pext.left + mbnds.offx
        end

        if mext.bottom > pext.bottom then
          pos.y = pext.bottom - mbnds.h + mbnds.offy
        elseif mext.top < pext.top then
          pos.y = pext.top + e.bounds.offy
        end
      end
    end

  end
)
