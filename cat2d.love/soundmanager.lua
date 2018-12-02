
-- SoundManager
--   Thin layer between ECS 'sound' components and the love audio library.
--   Each update, SoundManager tries to make sure the state of the sound world matches what the 
--   data frmo the ECS world says.  Starting, pausing, stopping, removing sounds objects as needed.
--   Took some hints from https://love2d.org/wiki/Minimalist_Sound_Manager
--
--   Methods:
--     update(estore,_,resources)
--     clear()
--
local SoundManager = {}

function SoundManager:new()
  local o ={
    sources={},
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

-- Given a table (map) and a list of whitelist keys, 
-- iterate the entries and remove any that aren't on the whitelist.
-- If the fn arg is non-nil, it is invoked with the key,val pair for the entry before removal.
-- TODO: this helper is more or less generic and could be moved somewhere more general, like crozeng.helpers
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

-- update() finds all 'sound' comps in the estore and:
--   - if a sound source object has already been built to represent this component, do nothing. TBD: more subtle syncing.
--   - otherwise, create and start playing a new sound source, and cache it using the sound component's cid.
-- For any existing sound sources that were NOT discovered in the pass through all sound comonents:
--   - stop the sound from playing
--   - remove the cached sound object.
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
        if snd.state == 'playing' then
          -- Sound component is new, we need to act.
          local soundCfg = res.sounds[snd.sound]
          if soundCfg then
            local src = love.audio.newSource(soundCfg.data, soundCfg.mode or "static")
            src:setLooping(snd.loop)
            -- if snd.loop and snd.duration and snd.duration ~= '' then
            --   src:seek(snd.playtime % snd.duration)
            -- else
            if snd.duration == '' then
              print("Wtf? blank duration? "..tflatten(snd))
            else
              src:seek(snd.playtime % snd.duration)
            end
            -- end
            src:setVolume(snd.volume)
            -- print("snd.volume "..snd.volume)

            self.sources[snd.cid] = src
            src:play()
          else
            print("!! SoundManager:upadte(): unknown sound in "..tflatten(snd))
          end
        end
      end
    end -- end for-each sound
  end) -- end walkEntities

  -- Consider ActiveChannels whose sound components have disappeared
  removeUnseenKeys(self.sources, seen, function(cid,src) 
    love.audio.stop(src)
  end)

end -- end update()

-- clear() stops all cached sound objects and removes them.
function SoundManager:clear()
  for cid,src in pairs(self.sources) do
		love.audio.stop(src)
	end
  self.sources={}
end


return SoundManager
