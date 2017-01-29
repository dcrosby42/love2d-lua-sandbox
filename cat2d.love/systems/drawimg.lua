
return function(estore,output,res)
  estore:search(
    hasComps('img','pos','parent'),
    function(e)
      local parent = estore:getEntity(e.parent.parentEid)
      if parent.scene and parent.scene.active then
        love.graphics.draw(
          res.images[e.img.imgId],
          e.pos.x, e.pos.y,
          e.img.r,     -- radians
          e.img.sx, e.img.sy,
          e.img.offx, e.img.offy)
      end
    end
  )
end
