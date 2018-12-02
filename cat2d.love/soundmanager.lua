
local SoundManager = {}

function SoundManager:new()
  local o ={
    sources={},
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

local function removeUnseenKeys(t, seenKeys, fn)
  local rem = {}
  for key, val in pairs(t) do
    if not lcontains(seenKeys, key) then
      if fn then
        fn(key,val)
      end
      table.insert(rem, key)
    end
  end
  for _,key in ipairs(rem) do
    t[key] = nil
  end
end

function SoundManager:update(estore, _, res)
  local seen = {} -- [cid]
  -- For each entity having at least one sound component:
  estore:walkEntities(hasComps('sound'), function(e)
    -- For each sound component in this entity:
    for _,snd in pairs(e.sounds) do
      -- mark this sound's cid as "seen" this pass
      table.insert(seen, snd.cid) 

      -- Is the sound already known??
      local src = self.sources[snd.cid]
      if src then
        -- Sound already known. 
        -- TODO Update src from sound component state
      else
        -- Sound component is new, we need to act.
        local soundCfg = res.sounds[snd.sound]
        if soundCfg then
          local src = love.audio.newSource(soundCfg.data, soundCfg.mode or "static")
          src:setLooping(snd.loop)
          src:setVolume(snd.volume)
          print("snd.volume "..snd.volume)

          self.sources[snd.cid] = src
					src:play()
        else
          print("!! SoundManager:upadte(): unknown sound in "..tflatten(snd))
        end
      end
    end -- end for-each sound
  end) -- end walkEntities

  -- Consider ActiveChannels whose sound components have disappeared
  removeUnseenKeys(self.sources, seen, function(cid,src) 
    love.audio.stop(src)
  end)

end -- end update()

function SoundManager:clear()
  for cid,src in pairs(self.sources) do
		love.audio.stop(src)
	end
  self.sources={}
end


return SoundManager
