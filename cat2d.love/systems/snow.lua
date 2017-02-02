local Comp = require 'ecs/component'

Comp.define("snowmachine", {'large',1,'small',1,'init',true})
Comp.define("circle", {'radius',0, 'color',{0,0,0}})
Comp.define("snow", {'lowerbound',0})


-- TODO see this about managing rng state more directly: https://love2d.org/wiki/RandomGenerator:getState
local CHEAT_RNG = love.math.newRandomGenerator(1234,5678)

local function addSnowflake(e,estore,y)
  -- print(entityDebugString(e))
  local x = CHEAT_RNG:random(e.bounds.x, e.bounds.w)
  -- local rad = CHEAT_RNG:random(e.small, e.large)
  local rad = CHEAT_RNG:random(e.snowmachine.small, e.snowmachine.large)

  local sflake = buildEntity(estore, {
    {'snow', {lowerbound=e.bounds.y+e.bounds.h}},
    {'vel', {dx=e.vel.dx, dy=e.vel.dy}},
    {'pos', { x=x, y=y}},
    {'circle', { radius=rad, color={255,255,255}}},
  }, {parent=e})
end

local snowMachineSystem = defineUpdateSystem(
  {'snowmachine'}, 
  function(e, estore,input,res)
    if e.snowmachine.init then
      -- Pre-populate the screen with proper distribution of snowflakes
      e.snowmachine.init = false
      local top = e.bounds.y
      local bottom = top + e.bounds.h
      local step = (e.timers.flake.reset * e.vel.dy)
      for y = top, bottom, step do 
        addSnowflake(e,estore,y)
      end
    end
    if e.timers.flake.alarm then
      local y = e.bounds.y
      addSnowflake(e,estore,y)
    end
  end
)

local snowSystem = defineUpdateSystem(
  {'snow'},
  function(e, estore, input, res)
    e.pos.y = e.pos.y + e.vel.dy * input.dt
    if e.pos.y > e.snow.lowerbound then
      estore:destroyEntity(e)
    end
  end
)

return iterateFuncs({
  snowMachineSystem,
  snowSystem,
})
