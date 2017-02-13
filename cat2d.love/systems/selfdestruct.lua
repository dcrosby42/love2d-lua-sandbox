
local selfDestructSystem = defineUpdateSystem({'tag','timer'},
  function(e,estore,input,res)
    if e.tags.self_destruct and e.timers.self_destruct then
      if e.timers.self_destruct.alarm then
        estore:destroyEntity(e)
      end
    end
  end
)

return selfDestructSystem
