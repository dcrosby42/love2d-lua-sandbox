require 'flags'
local Comp = require 'ecs/component'

return function(estore,input,res)
  estore:walkEntities(Flags.Update, 
    hasComps('timer'),
    function(e)
      for _,timer in pairs(e.timers) do
        if timer.countDown then
          if timer.t > 0 then
            timer.t = timer.t - input.dt
          else
            if timer.loop then 
              timer.t = timer.reset
            end
          end
        else
          timer.t = timer.t + input.dt
        end
      end
    end
  )
  local dt = input.dt
end
