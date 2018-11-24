local Debug = require 'mydebug'
local AnimalScreen = require 'modules/animalscreen'
local AnimalScreenProto = require 'modules/animalscreenproto'
local ImgScratch = require 'modules/imgscratch'

local M = {}


M.newWorld = function()
  Debug.setup()
  local w = {}
  w.modes={}
  w.modes["f2"] = { module=AnimalScreen, state=AnimalScreen.newWorld() }
  w.modes["f3"] = { module=AnimalScreenProto, state=AnimalScreenProto.newWorld() }
  w.modes["f4"] = { module=ImgScratch, state=ImgScratch.newWorld() }
  w.current = "f2"
  w.ios = love.system.getOS() == "iOS"
  if w.ios then
    w.showLog = false
  else
    w.showLog = true
  end

  return w
end

local function withCurrentMode(w,func)
  local mode = w.modes[w.current]
  if mode then func(mode) end
end

M.updateWorld = function(w,action)
  if action.type == "keyboard" and action.state == "pressed" then
    -- Reload game?
    if action.key == 'r' then
      withCurrentMode(w, function(mode) 
        if mode.module.shutdownWorld then
          mode.module.shutdownWorld(mode.state)
        end
      end)
      return w, {{type="crozeng.reloadRootModule"}}
    end

    -- toggle log?
    if action.key == 'f1' then
      w.showLog = not w.showLog
    end
    
    -- Switch modes?
    local mode = w.modes[action.key]
    if mode then
      if w.current ~= action.key then
        withCurrentMode(w, function(mode) 
          if mode.module.shutdownWorld then
            mode.module.shutdownWorld(mode.state)
          end
        end)
        w.current = action.key
      end
    end
  end

  -- toggle debug log?
  if action.type == "mouse" and action.state == "pressed" then
    if action.x < 75 and action.y > Debug.d.bounds.y then
      w.showLog = not w.showLog
      return
    end
  end

  -- don't pass mouse events to sub module when on ios
  if w.ios and action.type == "mouse" then return w end

  -- Update current submodule
  withCurrentMode(w, function(mode) 
    mode.module.updateWorld(mode.state, action)
  end)

  return w
end

M.drawWorld = function(w)
  love.graphics.setBackgroundColor(0,0,0,0)

  -- local mode = w.modes[w.current]
  -- if mode then
  --   mode.module.drawWorld(mode.state)
  -- end
  withCurrentMode(w, function(mode) 
    mode.module.drawWorld(mode.state)
  end)

  if w.showLog then
    Debug.draw()
  end

end

return M
