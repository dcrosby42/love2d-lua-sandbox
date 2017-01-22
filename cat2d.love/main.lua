Debug = require 'mydebug'
print("Debug:")

for k, v in pairs(Debug) do
  print(k .. ": " .. tostring(v))
end

function love.load()
  cat = {}
  cat.image = love.graphics.newImage('images/black-cat-icon.png')
  cat.x = 20
  cat.y = 20
  
  sprites = {}
end

function love.update(dt)
end

function love.draw()
  love.graphics.setBackgroundColor(255,255,255)
  love.graphics.setColor(0,0,0)

  love.graphics.print("Cat2d!",0,0)

  love.graphics.draw(
    cat.image,
    cat.x, cat.y,
    0,     -- radians
    0.5, 0.5,  -- scalex, scaley
    0, 50)  -- offx, offy

  -- DEBUG
  local lheight = 12
  local dlines = Debug.toLines()
  local dheight = #dlines * lheight
  local y = love.graphics.getHeight() - dheight
  for i,line in ipairs(dlines) do
    love.graphics.print(line,0,y)
    y = y + lheight
  end
end

function love.mousepressed(x,y, button, istouch)
  Debug.println("mousepressed " .. flattenTable({x=x,y=y,button=button,istouch=istouch}))
end

function love.touchpressed(id, x,y, dx,dy, pressure)
  Debug.println("touchpressed " .. flattenTable({x=x,y=y,dx=dx,dy=dy,pressure=pressure}))
end

function flattenTable(t)
  s = ""
  for k,v in pairs(t) do
    if #s > 0 then s = s .. " " end
    s = s .. tostring(k) .. "=" .. tostring(v)
  end
  return s
end
