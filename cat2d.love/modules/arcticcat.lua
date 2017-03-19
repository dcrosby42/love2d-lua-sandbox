local here = (...):match("(.*/)[^%/]+$")

local Field = require(here..'/field')
local Modules = {
  title = require(here..'/titlescreen/titlescreen'),
  other = require(here..'/other'),
  room1 = require(here..'/room1/room1'),
  room1 = require(here..'/tiledtest'),
}

local StateTransitions = {
  _start="room1",
  -- _start="other",
  -- _start="title",
  title={
    start='room1',
    continue='other',
  },
  room1={
    leave='title'
  },
  other={
    leave='title'
  },
}

local M ={}

local function getCurrent(w)
  local cur = w.current
  local s = w.subWorlds[cur]
  local m = Modules[cur]
  return s,m,cur
end

M.newWorld = function()
  local w = {
    subWorlds = {},
    current = StateTransitions._start,
  }

  for name,module in pairs(Modules) do
    w.subWorlds[name] = module.newWorld()
  end

  return w, nil
end

M.updateWorld = function(world, action)
  -- Update the current subworld:
  state,mode,current = getCurrent(world)
  state1, effects = mode.updateWorld(state, action)
  world.subWorlds[current] = state1

  -- Process any returned aftereffects:
  if effects then
    -- print("arcticcat.lua update: effects:"..tdebug(effects,'  '))
    for _, ef in ipairs(effects) do
      if ef.type == "transition" then
        local trans = StateTransitions[world.current]
        if trans and trans[ef.value] then
          local next = trans[ef.value]
          print("arcticcat.lua: TRANSITION "..world.current.."["..ef.value.."] -> "..next)
          world.current = next
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
