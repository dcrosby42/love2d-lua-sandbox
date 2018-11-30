-- local Estore = require 'ecs.estore'
require 'ecs.ecshelpers'
local Entities = require 'modules.animalscreen.entities'
local Resources = require 'modules.animalscreen.resources'
local Debug = require 'mydebug'

-- local R = require 'resourceloader'
-- local A = require 'animalpics'
-- require 'vendor/TEsound'

local UPDATE = composeSystems(requireModules({
  'systems.timer',
  -- 'modules.animalscreen.zookeeper',
  'modules.animalscreen.manipsystem',
}))

local DRAW = composeDrawSystems(requireModules({
  'systems.drawstuff',
  'systems.drawsound',
}))

local M = {}

function M.newWorld()
  local world={
    estore = Entities.initialEntities(),
    input = {
      dt=0,
      events={},
    },
    resources = Resources.load(),
  }
  return world
end

function M.shutdownWorld(w)
end

local function resetInput(i) i.dt=0 i.events={} end

function M.updateWorld(w,action)
  if action.type == 'tick' then
    w.input.dt = action.dt
    UPDATE(w.estore, w.input, w.resources)
    resetInput(w.input)

  elseif action.type == 'touch' then
    table.insert(w.input.events, shallowclone(action))

  elseif action.type == 'mouse' then
    local evt = shallowclone(action)
    evt.type = "touch"
    evt.id = 1
    table.insert(w.input.events, evt)
  end
  return w
end

function M.drawWorld(w)
  DRAW(w.estore, w.resources)
end

return M