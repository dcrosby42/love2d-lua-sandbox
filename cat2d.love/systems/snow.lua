local Comp = require 'ecs/component'

Comp.define("snowmachine", {large=1,small=1})
Comp.define("circle", {radius=0, color={0,0,0}})
Comp.define("snow", {lowerbound=0})


-- TODO see this about managing rng state more directly: https://love2d.org/wiki/RandomGenerator:getState
local CHEAT_RNG = love.math.newRandomGenerator(1234,5678)

local snowMachineSystem = defineUpdateSystem(
  {'snowmachine'}, 
  function(e, estore,input,res)
    if e.timers.flake.alarm then
      local t = e.timers.acc.t

      local x = CHEAT_RNG:random(e.bounds.x, e.bounds.w)
      -- local x = CHEAT_RNG:randomNormal(e.bounds.x/4, e.bounds.x/2)
      local y = e.bounds.y
      -- local rad = CHEAT_RNG:randomNormal(2,5)
      local rad = CHEAT_RNG:random(2,5)

      local sflake = buildEntity(estore, {
        {'snow', {lowerbound=e.bounds.y+e.bounds.h}},
        {'vel', {dx=e.vel.dx, dy=e.vel.dy}},
        {'pos', { x=x, y=y}},
        {'circle', { radius=rad, color={255,255,255}}},
      }, {parent=e})

      -- print(entityDebugString(sflake))
    end
  end
)

local snowSystem = defineUpdateSystem(
  {'snow'},
  function(e, estore, input, res)
    -- Fall:
    e.pos.y = e.pos.y + e.vel.dy * input.dt

    if e.pos.y > e.snow.lowerbound then
      -- print("Snow expiring: "..entityDebugString(e))
      estore:destroyEntity(e)
    end
  end
)

return function(estore,input,res)
  snowMachineSystem(estore,input,res)
  snowSystem(estore,input,res)
end
