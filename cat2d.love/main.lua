Debug = require 'mydebug'

Game = {}
Input = {}

TouchOnly = false

function love.load()
  if love.system.getOS() == "OS X" then
    love.window.setMode(1024,768)
  elseif love.system.getOS() == "iOS" then
    TouchOnly = true
  end

  Debug.setup(Game)

  Debug.println("Bounds " .. flattenTable({width=love.graphics.getHeight(), height=love.graphics.getWidth()}))

  Input.touches = {}

  setupCat(Game)
  
  -- Touch manipulator
  setupManipulator(Game)

  Game.touches = {}
  Game.touchIds = {}
end


function love.update(dt)
  updateTouches(Game,dt,Input)
  updateManipulator(Game,dt,Input)
  -- updateCat(Game,dt,Input)
  Debug.update(Game,dt,Input)

  -- clear touch inputs
  local ts = Input.touches
  for i=1,#ts do ts[i] = nil end
end

function love.draw()
  love.graphics.setBackgroundColor(255,255,255)
  love.graphics.setColor(0,0,0)

  -- drawCat(Game)
  -- drawManipulator(Game)
  drawTouches(Game)

  Debug.draw(Game)


end

function love.mousepressed(x,y, button, istouch)
  if TouchOnly then return end
  -- Debug.println("mousepressed " .. flattenTable({x=x,y=y,button=button,istouch=istouch}))
  local ts = Input.touches
  local tid = 42
  if love.keyboard.isDown("1") then
    tid = 37
  end
  ts[#ts + 1] = { type="pressed", id=tid, x=x, y=y }
end
function love.mousemoved(x,y, button, istouch)
  if TouchOnly then return end
  -- Debug.println("mousemoved " .. flattenTable({x=x,y=y,button=button,istouch=istouch}))
  local ts = Input.touches
  local tid = 42
  if love.keyboard.isDown("1") then
    tid = 37
  end
  ts[#ts + 1] = { type="moved", id=tid, x=x, y=y }
end
function love.mousereleased(x,y, button, istouch)
  if TouchOnly then return end
  -- Debug.println("mousereleased " .. flattenTable({x=x,y=y,button=button,istouch=istouch}))
  local ts = Input.touches
  local tid = 42
  if love.keyboard.isDown("1") then
    tid = 37
  end
  ts[#ts + 1] = { type="released", id=tid, x=x, y=y }
end

function love.touchpressed(id, x,y, dx,dy, pressure)
  -- Debug.println("touchpressed " .. flattenTable({x=x,y=y,dx=dx,dy=dy,pressure=pressure}))
  local ts = Input.touches
  ts[#ts + 1] = { type="pressed", id=id, x=x, y=y }
end
function love.touchmoved(id, x,y, dx,dy, pressure)
  -- Debug.println("touchmoved " .. flattenTable({x=x,y=y,dx=dx,dy=dy,pressure=pressure}))
  local ts = Input.touches
  ts[#ts + 1] = { type="moved", id=id, x=x, y=y }
end
function love.touchreleased(id, x,y, dx,dy, pressure)
  -- Debug.println("touchreleased " .. flattenTable({x=x,y=y,dx=dx,dy=dy,pressure=pressure}))
  local ts = Input.touches
  ts[#ts + 1] = { type="released", id=id, x=x, y=y }
end

function flattenTable(t)
  s = ""
  for k,v in pairs(t) do
    if #s > 0 then s = s .. " " end
    s = s .. tostring(k) .. "=" .. tostring(v)
  end
  return s
end

--
-- Touch Manipulator
--

function setupManipulator(game)
  local manip = {
    state = "idle",
    pointA = nil,
    pointATouchId = nil,
    target = nil,
  }
  game.manipulator = manip
end

function updateManipulator(game,dt,input)
  local manip = game.manipulator

  for i,t in ipairs(input.touches) do
    if manip.state == "idle" then
      if t.type == "pressed" then
        local cat = game.cat 
        manip.state = "active"
        manip.pointATouchId = t.id
        manip.pointA = {x=t.x, y=t.y}
        manip.target = {
          id= "cat",
          dx= 0,
          dy= 0,
        }
        -- manip.pointAOffset = {x=(t.x - target.x), y=(t.y - target.y)}

        -- Debug.println("Manip going active "..flattenTable({id=tostring(t.id),x=t.x,y=t.y}))
      elseif t.type == "moved" then
      elseif t.type == "released" then
      end
    elseif manip.state == "active" then
      if t.type == "pressed" then
        if t.id ~= manip.pointATouchId and t.id ~= manip.pointBTouchId then
          manip.pointBTouchId = t.id
          manip.pointB = {x=t.x, y=t.y}
        end
      elseif t.type == "moved" then
        if t.id == manip.pointATouchId then
          pa = manip.pointA
          manip.target.dx = t.x - pa.x
          manip.target.dy = t.y - pa.y
          pa.x = t.x
          pa.y = t.y
          -- Debug.println("Manip moved"..flattenTable({id=tostring(t.id),x=t.x,y=t.y}))
        end
      elseif t.type == "released" then
        if t.id == manip.pointATouchId then
          manip.state = "idle"
          manip.pointA = nil
          manip.pointATouchId = nil
          manip.target = nil
          -- Debug.println("Manip released")
        elseif t.id == manip.pointBTouchId then
          manip.pointBTouchId = t.id
          manip.pointB = {x=t.x, y=t.y}
        end
      end
    end
  end
end
function drawManipulator(game)
  -- local manip = game.manipulator
  -- if manip.pointA then
  --   love.graphics.rectangle("line", manip.pointA.x-50, manip.pointA.y-50, 100, 100)
  -- end
  -- if manip.pointB then
  --   love.graphics.rectangle("line", manip.pointB.x-50, manip.pointB.y-50, 100, 100)
  -- end
end

--
-- Cat
--
function setupCat(game)
  local cat = {}
  cat.image = love.graphics.newImage('images/black-cat-icon.png')
  cat.x = 20
  cat.y = 20
  game.cat = cat
end

function updateCat(game,dt,input)
  local cat = game.cat
  local manip = game.manipulator
  if manip.state ~= "idle" and manip.target.id == "cat" then
    cat.x = cat.x + manip.target.dx
    cat.y = cat.y + manip.target.dy
  end
end

function drawCat(game)
  local cat = Game.cat
  love.graphics.draw(
    cat.image,
    cat.x, cat.y,
    0,     -- radians
    0.5, 0.5,  -- scalex, scaley
    0, 50)  -- offx, offy
end


function updateTouches(game,dt,input)
  local gts = game.touches
  local tids = game.touchIds
  local updateNums = false
  for id,gt in pairs(gts) do
    gt.elapsed = gt.elapsed + dt
    if gt.type == "released" then
      gts[id] = nil
      for i,tid in ipairs(tids) do
        if id == tid then
          table.remove(tids,i)
        end
        updateNums = true
      end
    end
  end
  local gt
  for _,t in ipairs(input.touches) do
    gt = gts[t.id]
    if not gt and t.type == "pressed" then
      gt = {id=t.id, elapsed=0}
      gts[t.id] = gt
      tids[#tids + 1] = t.id
      updateNums = true
    end
    if gt then
      gt.type = t.type
      gt.x = t.x
      gt.y = t.y
      gt.dx = t.dx
      gt.dy = t.dy
    end
  end
  if updateNums then
    for i,tid in ipairs(tids) do
      gts[tid].num = i
    end
  end
end

function clamp(val, min, max)
  if val < min then 
    return min
  elseif val > max then
    return max
  else
    return val
  end
end

function drawTouches(game)
  if #game.touchIds <= 0 then return end

  local scale = 0.3
  for id,t in pairs(game.touches) do
    -- love.graphics.rectangle("line", t.x-50, t.y-50, 100, 100)
    --
    -- scale = clamp(begin + ((t.elapsed / span) * 0.3), 0, 0.6)
    scale = clamp(0.3 + ((t.elapsed / 2) * 0.3), 0, 0.6)
    rot = t.elapsed * 3.1415926
    love.graphics.draw(
      game.cat.image,
      t.x, t.y,
      rot,
      scale, scale,
      256,256)  -- offx, offy

    love.graphics.print("Touch "..t.num, t.x - 20, t.y - 100)
  end
end
