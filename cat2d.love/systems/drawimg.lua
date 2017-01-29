
return function(estore,output,res)
  estore:search(
    hasComps('img','pos'),
    function(e)
      -- print(":: love.graphics.draw(res.images["..e.img.imgId.."], "..e.pos.x..","..e.pos.y..")")
      love.graphics.draw(
        res.images[e.img.imgId],
        e.pos.x, e.pos.y,
        e.img.r,     -- radians
        e.img.sx, e.img.sy,
        e.img.offx, e.img.offy)
    end
  )
end
