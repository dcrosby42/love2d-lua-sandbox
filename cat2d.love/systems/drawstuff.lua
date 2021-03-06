
local DBG=false
local BOUNDS=false

return function(estore,output,res)
  local drawBounds = false
  estore:walkEntities(hasComps('tag','debug'), function(e)
    if e.tags.debug then
      if e.debugs.drawBounds then
        drawBounds = e.debugs.drawBounds.value
        return false -- stop searching
      end
    end
  end)

  estore:walkEntities(nil, function(e)
    if not e.pos then return false end

    --
    -- IMG
    --
    if e.img and e.pos then
      local img = e.img
      local x,y = getPos(e)
      local imgRes = res.images[img.imgId]
      if not imgRes then
        error("No image resource '"..img.imgId.."'")
      end
      love.graphics.setColor(unpack(img.color))
      love.graphics.draw(
        res.images[img.imgId],
        x,y,
        img.r,     -- radians
        img.sx, img.sy,
        img.offx, img.offy)

    --
    -- LABEL
    --
    elseif e.label and e.pos then
      local label = e.label
      if label.font then
        local font = res.fonts[label.font]
        if font then love.graphics.setFont(font) end
      end
      love.graphics.setColor(unpack(label.color))
      local x,y = getPos(e)
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
        love.graphics.printf(label.text, x, y, label.width,label.align)
      else
        love.graphics.print(label.text, x, y)
      end

    --
    -- CIRCLE
    --
    elseif e.circle and e.pos then
      local circle = e.circle
      local x,y = getPos(e)
      x = x + circle.offx
      y = y + circle.offy
      love.graphics.setColor(unpack(circle.color))
      love.graphics.circle("line", x, y, circle.radius)
      love.graphics.circle("fill", x, y, circle.radius)

    --
    -- RECTANGLE
    --
    elseif e.rect and e.pos then
      if DBG then
        print("DRAWING "..e.eid)
      end
      local x,y = getPos(e)
      local rect = e.rect
      love.graphics.setColor(unpack(rect.color))
      love.graphics.rectangle(rect.style, x-rect.offx, y-rect.offy, rect.w, rect.h)
    end

    if BOUNDS or drawBounds then
      if e.pos then
        local x,y = getPos(e)
        love.graphics.setColor(255,255,255)
        love.graphics.line(x-5,y, x+5,y)
        love.graphics.line(x,y-5, x,y+5)
        if e.bounds then
          local b = e.bounds
          love.graphics.rectangle("line", x-b.offx, y-b.offy, b.w, b.h)
        end
      end
    end

    -- drewItems = drewItems + 1
  end)

  if DBG then DBG=false end
  -- print("drawstuff: visited "..drewItems.." items")
end
