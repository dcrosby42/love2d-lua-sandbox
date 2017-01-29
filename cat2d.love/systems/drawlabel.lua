
return function(estore,output,res)
  estore:search(
    hasComps('label','pos','parent'),
    function(e)
      local parent = estore:getEntity(e.parent.parentEid)
      if parent.scene and parent.scene.active then
        local label = e.label
        love.graphics.setColor(label.r, label.g, label.b)
        love.graphics.print(label.text, e.pos.x, e.pos.y)
      end
    end
  )
end
