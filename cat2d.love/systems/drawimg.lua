require 'flags'

return function(estore,output,res)
  -- estore:updateEntityTree()

  estore:walkEntities(Flags.Draw, nil, function(e)
    if e.img and e.pos then
      local img = e.img
      love.graphics.draw(
        res.images[img.imgId],
        e.pos.x, e.pos.y,
        img.r,     -- radians
        img.sx, img.sy,
        img.offx, img.offy)

    elseif e.label and e.pos then
      local label = e.label
      love.graphics.setColor(label.r, label.g, label.b)
      love.graphics.print(label.text, e.pos.x, e.pos.y)

    elseif e.circle and e.pos then
      local pos = e.pos
      local circle = e.circle
      love.graphics.setColor(unpack(circle.color))
      love.graphics.circle("fill", pos.x, pos.y, circle.radius)
    end
  end)
end

