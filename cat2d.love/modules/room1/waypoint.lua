local Comp = require 'ecs/component'

Comp.define("destination", {'x',0,'y',0,'dist',0})

local addDestSystem = defineUpdateSystem({'controller','pos'}, function(e,estore,input,res)
  forEachMatching(input.events.waypoint, 'controllerId', e.controller.id, function(evt)
    local d = math.dist(evt.x,evt.y, e.pos.x, e.pos.y)
    e:newComp('destination', {x=evt.x,y=evt.y,dist=-1})
  end)
end)

local destSystem = defineUpdateSystem({'destination','controller','pos'}, function(e,estore,input,res)
  local pos = e.pos
  local dest = e.destination
  local c = e.controller

  -- Figure out how to influence the directional controls to move toward dest
  local dx = dest.x - pos.x
  local dy = dest.y - pos.y
  c.leftx = 0
  c.lefty = 0
  if math.abs(dx) > 5 then
    c.leftx = 1
    if dx < 0 then c.leftx = -c.leftx end
  end
  if math.abs(dy) > 5 then
    c.lefty = 1
    if dy < 0 then c.lefty = -c.lefty end
  end

  if c.leftx == 0 and c.lefty == 0 then
    -- no need to move? we must be there
    e:removeComp(dest)
  else
    local d = math.dist(dest.x,dest.y, pos.x, pos.y)
    if dest.dist < 0 then
      -- first actual movement toward dest
      dest.dist = d
    else
      if dest.dist - d < 2 then
        -- not making progress; give up
        c.leftx = 0
        c.lefty = 0
        e:removeComp(dest)
      else
        -- record the remaining distance
        dest.dist = d
      end
    end
  end
end)

local function handleMouse(action, controllerId, worldInput)
  if action.state == 'pressed' then
    addInputEvent(worldInput, {type='waypoint', controllerId=controllerId, x=action.x, y=action.y})
  end
end

return {
  handleMouse=handleMouse,
  System = iterateFuncs({
    addDestSystem,
    destSystem
  })
}
