
local Comp = require 'ecs/component'
Comp.define('effect',{'path',{},'t',0,'loop',false,'data',{}})

function pathLookupEntCompKey(estore, e, path)
  local ent = nil
  local key = path[#path]
  local cur = e
  for i=1,#path-2 do
    if path[i] == 'PARENT' then
      cur = estore:getParent(cur)
    else
      cur = cur[path[i]]
    end
    if i == 1 then ent = cur end
  end
  local comp = cur[path[#path-1]]
  return ent, comp, key
end

local effectSystem = defineUpdateSystem({'effect','timer'},
  function(e, estore,input,res)
    local effect = e.effect
    local data = effect.data
    local timer = e.timer
    local ent,comp,key = pathLookupEntCompKey(estore, e, effect.path)
    -- -- TODO parameterizable data-to-value function:
    local newVal = nil
    for i=1, #data, 2 do
      if timer.t >= data[i] then
        newVal = data[i+1]
      else
        break
      end
    end
    -- --
    comp[key] = newVal
  end
)

return effectSystem
