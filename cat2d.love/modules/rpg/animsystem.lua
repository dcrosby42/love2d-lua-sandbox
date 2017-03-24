
return defineUpdateSystem(hasComps('avatar','sprite'),
  function(e,estore,input,res)
    local av = e.avatar
    if av.motion == 'standing' then
      e.effects.anim.animFunc = 'rpg_stand_'..av.dir
    elseif av.motion == 'walking' then
      e.effects.anim.animFunc = 'rpg_walk_'..av.dir
    end
  end
)
