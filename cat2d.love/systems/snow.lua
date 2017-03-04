local Comp = require 'ecs/component'

Comp.define("snowmachine", {'large',1,'small',1,'init',true,'dx',0,'dy',0})

Comp.define("snow", {'lowerbound',0})

Snow = {}

-- TODO see this about managing rng state more directly: https://love2d.org/wiki/RandomGenerator:getState
local CHEAT_RNG = love.math.newRandomGenerator(1234,5678)

Snow.Defaults = {
  large=3,
  small=1,
  dx=0,
  dy=30,
  interval=0.2,
}

Snow.newSnowMachine = function(estore, opts)
  local opts = tcopy(opts,Snow.Defaults)
  -- local opts = Snow.Defaults
  return estore:newEntity({
    {'snowmachine', {large=opts.large,small=opts.small,dx=opts.dx,dy=opts.dy}},
    {'pos',{x=0,y=0}},
    {'bounds', {w=love.graphics.getWidth(), h=love.graphics.getHeight()}},
    {'timer', {name='flake', reset=opts.interval, loop=true}},
    {'timer', {name='acc', countDown=false}},
  })
end

local function addSnowflake(e,y)
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

--
-- SnowMachine system: Generate snow flakes
--
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
        addSnowflake(e,y)
      end
    end
    if e.timers.flake.alarm then
      local y = e.pos.y
      addSnowflake(e,y)
    end
  end
)

--
-- Snow system: float each snowflake downward, then remove
--
local snowSystem = defineUpdateSystem(
  {'snow'},
  function(e, estore, input, res)
    e.pos.y = e.pos.y + e.vel.dy * input.dt
    if e.pos.y > e.snow.lowerbound then
      estore:destroyEntity(e)
    end
  end
)

Snow.System = iterateFuncs({
  snowMachineSystem,
  snowSystem,
})


return Snow
