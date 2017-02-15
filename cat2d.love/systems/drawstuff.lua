require 'flags'

local DBG=false

return function(estore,output,res)
  -- estore:updateEntityTree()

  -- estore:search(hasComps('pos'), function(e)
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
      if label.font then
        local font = res.fonts[label.font]
        if font then love.graphics.setFont(font) end
      end
      love.graphics.setColor(unpack(label.color))
      local y = e.pos.y
      if label.height then
        if label.valign == 'middle' then
          local halfLineH = love.graphics.getFont():getHeight() / 2
          y = y + (label.height/2) - halfLineH
        elseif label.valign == 'bottom' then
          local lineH = love.graphics.getFont():getHeight()
          y = y + label.height - lineH
        end
      end
      if label.width then
        local align = label.align
        if not align then align = 'left' end
        love.graphics.printf(label.text, e.pos.x, y, label.width,label.align)
      else
        love.graphics.print(label.text, e.pos.x, y)
      end

    elseif e.circle and e.pos then
      local pos = e.pos
      local circle = e.circle
      love.graphics.setColor(unpack(circle.color))
      love.graphics.circle("line", pos.x, pos.y, circle.radius)
      love.graphics.circle("fill", pos.x, pos.y, circle.radius)
    elseif e.rect and e.pos then
      if DBG then
        print("DRAWING "..e.eid)
      end
      local pos = e.pos
      local rect = e.rect
      love.graphics.setColor(unpack(rect.color))
      love.graphics.rectangle(rect.style, pos.x, pos.y, rect.w, rect.h)
      --love.graphics.setColor(0,0,0)
      -- love.graphics.rectangle("line", pos.x, pos.y, rect.w, rect.h)
    end
  end)

  if DBG then DBG=false end
end
