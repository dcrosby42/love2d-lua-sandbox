local Comp = require 'ecs/component'

Comp.define("snowmachine", {'large',1,'small',1,'init',true,'dx',0,'dy',0})

Comp.define("snow", {'lowerbound',0})


-- TODO see this about managing rng state more directly: https://love2d.org/wiki/RandomGenerator:getState
local CHEAT_RNG = love.math.newRandomGenerator(1234,5678)

local function addSnowflake(e,estore,y)
  local left = e.pos.x
  local right = left + e.bounds.w
  local x = CHEAT_RNG:random(left,right)
  local rad = CHEAT_RNG:random(e.snowmachine.small, e.snowmachine.large)

  e:newChild({
    {'snow', {lowerbound=e.pos.y+e.bounds.h}},
    {'vel', {dx=e.snowmachine.dx, dy=e.snowmachine.dy}},
    {'pos', { x=x, y=y}},
    {'circle', { radius=rad, color={255,255,255}}},
  })
end

local snowMachineSystem = defineUpdateSystem(
  {'snowmachine'},
  function(e, estore,input,res)
    if e.snowmachine.init then
      -- Pre-populate the screen with proper distribution of snowflakes
      e.snowmachine.init = false
      local top = e.pos.y
      local bottom = top + e.bounds.h
      local step = (e.timers.flake.reset * e.snowmachine.dy)
      for y = top, bottom, step do
        addSnowflake(e,estore,y)
      end
    end
    if e.timers.flake.alarm then
      local y = e.pos.y
      addSnowflake(e,estore,y)
    end
  end
)

local snowSystem = defineUpdateSystem(
  {'snow'},
  function(e, estore, input, res)
    e.pos.y = e.pos.y + e.vel.dy * input.dt
    if e.pos.y > e.snow.lowerbound then
      -- print("Snow system: removing snow "..e.eid)
      estore:destroyEntity(e)
    end
  end
)

return iterateFuncs({
  snowMachineSystem,
  snowSystem,
})
