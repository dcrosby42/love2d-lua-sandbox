require 'vendor/TEsound'

local ActiveChannels = {}  -- {cid -> channel}
      

local function removeUnseenKeys(t, seenKeys, fn)
  local toRemove = {}
  for key, val in pairs(t) do
    if not lcontains(seenKeys, key) then
      if fn then
        fn(key,val)
      end
      table.insert(toRemove, key)
    end
  end
  for i=1, #toRemove do
    t[toRemove[i]] = nil
  end
end

return function(estore,res)
  local seen = {} -- [cid]
  estore:walkEntities(hasComps('sound'), function(e)
    for _,snd in pairs(e.sounds) do
      table.insert(seen, snd.cid) -- mark this sound's cid as "seen" this pass

      -- Is the sound already playing?
      local channel = ActiveChannels[snd.cid]
      if channel then
        -- Sound already playing. Update it?
      else
        -- Sound component is new, we need to play something.
        local soundFile = res.soundFilenames[snd.sound]
        if soundFile then
          local channel
          if snd.loop then
            channel = TEsound.playLooping(soundFile)
          else
            channel = TEsound.play(soundFile)
          end
          ActiveChannels[snd.cid] = channel
        else
          print("!! drawsound: unknown sound: "..snd.sound)
        end
      end
    end
  end)

  -- Consider ActiveChannels whose sound components have disappeared
  removeUnseenKeys(ActiveChannels, seen, function(cid,channel) 
    TEsound.stop(channel)
  end)

  TEsound.cleanup()
  -- local toRemove = {}
  -- for cid,channel in pairs(ActiveChannels) do
  --   if not lcontains(seen,cid) then
  --     -- Sound component removed from world
  --     TEsound.stop(channel)
  --     table.insert(toRemove,cid)
  --   end
  -- end
  -- for i=1,#toRemove do
  --   ActiveChannels[toRemove[i]] = nil
  -- end
end


