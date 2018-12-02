-- local Estore = require 'ecs.estore'
require 'ecs.ecshelpers'
local Entities = require 'modules.animalscreen.entities'
local Resources = require 'modules.animalscreen.resources'
local SoundManager = require 'soundmanager'
local Debug = require 'mydebug'

local UPDATE = composeSystems(requireModules({
  'systems.timer',
  'systems.sound',
  -- 'modules.animalscreen.zookeeper',
  'modules.animalscreen.manipsystem',
}))

local DRAW = composeDrawSystems(requireModules({
  'systems.drawstuff',
}))

local M = {}

function M.newWorld()
  local res = Resources.load()
  local world={
    estore = Entities.initialEntities(res),
    input = {
      dt=0,
      events={},
    },
    resources = res,
    soundmgr=SoundManager:new(),
  }
  return world
end

function M.stopWorld(w)
  w.soundmgr:clear()
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
  w.soundmgr:update(w.estore, nil, w.resources)
  DRAW(w.estore, w.resources)
end

return M
