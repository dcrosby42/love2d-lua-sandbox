local Modules = {}
Modules.snow = require 'modules/snow'
Modules.other = require 'modules/other'

local M ={}

-- local newSnowScene, newOtherScene

local function getCurrent(w) 
  local cur = w.current
  local s = w.subWorlds[cur]
  local m = Modules[cur]
  return s,m,cur
end

M.newWorld = function()
  local w = {
    subWorlds = {
      snow = Modules.snow.newWorld(),
      other = Modules.other.newWorld(),
    },
    current = "snow",
  }
  return w, nil
end

M.updateWorld = function(world, action)
  state,mode,current = getCurrent(world)

  if action.type == 'keyboard' then
    local key = action.key
    if key == "s" then
      if current == "snow" then 
        world.current = "other"
      else
        world.current = "snow"
      end
      return world, nil
    end
  end

  state1, effects = mode.updateWorld(state, action)
  world.subWorlds[current] = state1

  if effects then
    for _, ef in ipairs(effects) do
      if ef.type == 'exit' then
        if world.current == "snow" then
          world.current = "other"
        else
          world.current = "snow"
        end
      end
    end
  end
end

M.drawWorld = function(world)
  state,mode = getCurrent(world)
  mode.drawWorld(state)
end


return M
