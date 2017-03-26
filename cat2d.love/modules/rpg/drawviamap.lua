
local function drawEntity(e, res)
  --
  -- IMG
  --
  if e.img then
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
  -- SPRITES
  --
  elseif e.sprite then
    local sprite = e.sprite
    local x,y = getPos(e)
    local sres = res.sprites[e.sprite.spriteId]
    assert(sres,"no sprite res for "..e.sprite.spriteId)
    local frame = sres.frames[e.sprite.frame]
    assert(frame,"no frame="..tostring(e.sprite.frame).." for sprite="..tostring(e.sprite.spriteId))
    local sx = 1
    local sy = 1
    if e.scale then
      sx = e.scale.sx
      sy = e.scale.sy
    end
    love.graphics.draw(
      sres.image,
      sres.frames[e.sprite.frame],
      x,y,
      sprite.r,
      sx,sy,
      sprite.offx, sprite.offy)

  --
  -- LABEL
  --
  elseif e.label then
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
end

local function drawBounds(e)
  if e.pos then
    local x,y = getPos(e)
    love.graphics.setColor(255,255,255)
    love.graphics.line(x-5,y, x+5,y)
    love.graphics.line(x,y-5, x,y+5)
    if e.bounds then
      x,y,w,h = getBoundingRect(e)
      love.graphics.rectangle("line", x,y,w,h)
      -- local b = e.bounds
      -- local sx = 1
      -- local sy = 1
      -- if e.scale then
      --   sx = e.scale.sx
      --   sy = e.scale.sy
      -- end
      -- love.graphics.rectangle("line", x-(sx*b.offx), y-(sy*b.offy), sx*b.w, sy*b.h)
    end
  end
end

return function(estore,res)
  local mapF
  estore:seekEntity(hasComps('map'), function(e,estore)
    mapF = res.maps[e.map.id]
  end)

  if not mapF then
    error("Drawing: no map registered with id="..e.map.id)
  end
  local map = mapF()

  if map then
    local slayer = map.layers.CustomSpriteLayer
    function slayer:draw()
      estore:walkEntities(hasComps('pos'),function(e)
        drawEntity(e,res)
        -- drawBounds(e)
      end)
    end
    map:draw()
    -- map:bump_draw(map._sidecar.bumpWorld)
  end
end
