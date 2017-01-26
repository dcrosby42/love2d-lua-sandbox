require 'vendor/TEsound'
require 'helpers'

local Debug = require 'mydebug'
local TouchLog = require 'touchlog'

local Game = {}
local Input = {}

local TouchOnly = false
local Accel
local KeybAccel = false

function love.load()
  if love.system.getOS() == "OS X" then
    love.window.setMode(1024,768)
    KeybAccel = true
  elseif love.system.getOS() == "iOS" then
    TouchOnly = true
  end

  Debug.setup(Game)

  Debug.println("Bounds " .. flattenTable({width=love.graphics.getHeight(), height=love.graphics.getWidth()}))

  Input.touches = {}
  Input.accel = {x=0, y=0, z=0}

  setupCat(Game)
  setupRoller(Game)
  
  -- setupManipulator(Game)

  Game.touches = {}
  Game.touchIds = {}

  TouchLog.setup(Game)


  TEsound.playLooping("sounds/fx/tng_hum_clean.mp3","thrum")
  TEsound.play("sounds/fx/tng_viewscreen_on.mp3","viewon")
  TEsound.volume("ebeep",0.4)
end


function love.update(dt)
  input_updateAccel(dt,Input)

  -- UPDATE
  updateTouches(Game,dt,Input)
  updateRoller(Game,dt,Input)
  -- updateManipulator(Game,dt,Input)
  -- updateCat(Game,dt,Input)
  Debug.update(Game,dt,Input)
  TouchLog.update(Game,dt,Input)

  -- AFTER UPDATE
  local ts = Input.touches
  for i=1,#ts do ts[i] = nil end

  TEsound.cleanup()
end

function love.draw()
  love.graphics.setBackgroundColor(255,255,255)
  love.graphics.setColor(0,0,0)

  -- drawCat(Game)
  -- drawManipulator(Game)
  drawRoller(Game)
  drawTouches(Game)

  Debug.draw(Game)

  if Accel then
    drawAccel()
  end


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
    return min, true
  elseif val > max then
    return max, true
  else
    return val, false
  end
end

function drawTouches(game)
  if #game.touchIds <= 0 then return end

  local scale = 0.3
  for id,t in pairs(game.touches) do
    -- love.graphics.rectangle("line", t.x-50, t.y-50, 100, 100)
    love.graphics.ellipse("line", t.x, t.y, 48, 48)
    love.graphics.ellipse("line", t.x, t.y, 62, 62)
    --
    -- scale = clamp(begin + ((t.elapsed / span) * 0.3), 0, 0.6)
    -- scale = clamp(0.3 + ((t.elapsed / 2) * 0.3), 0, 0.6)
    -- rot = t.elapsed * 3.1415926
    -- love.graphics.draw(
    --   game.cat.image,
    --   t.x, t.y,
    --   rot,
    --   scale, scale,e
    --   256,256)  -- offx, offy

    love.graphics.print(t.num, t.x - 5, t.y - 61)

    -- SOUND
    if t.elapsed == 0 then
      -- TEsound.play("sounds/fx/deskviewerbeep.mp3")
      -- TEsound.play("sounds/fx/computerbeep_12.mp3")
      TEsound.play("sounds/fx/computerbeep_5.mp3","beep")
    end 
    if t.type == "released" then
      TEsound.play("sounds/fx/computerbeep_12.mp3", "ebeep")
    end
  end
end

function love.joystickadded(joystick)
  Debug.println("joystick added: " .. joystick:getName())
  if joystick:getName() == "iOS Accelerometer" then
    Debug.println("Accel!")
    Accel = joystick
  end
end

function input_updateAccel(dt, input)
  if Accel then
    local x,y,z = Accel:getAxes()
    input.accel.x = x
    input.accel.y = y
    input.accel.z = z
  elseif KeybAccel then
    if love.keyboard.isDown("a") then
      input.accel.y = -0.09
    elseif love.keyboard.isDown("d") then
      input.accel.y = 0.09
    else
      input.accel.y = 0
    end
    if love.keyboard.isDown("w") then
      input.accel.x = 0.08
    elseif love.keyboard.isDown("s") then
      input.accel.x = -0.08
    else
      input.accel.x = 0
    end
  end
end

function drawAccel()
  local a,b,c = Accel:getAxes()
  drawAccelVals(a,b,c)

  local half = love.graphics.getWidth() / 2
  local y = 100
  love.graphics.rectangle("fill", half,y, a*half,40)
  y = y + 42
  love.graphics.rectangle("fill", half,y, b*half,40)
  y = y + 42
  love.graphics.rectangle("fill", half,y, c*half,40)
end

function drawAccelVals(a,b,c)
  local x = 0
  local y = 20
  love.graphics.print(Accel:getName(), x, y)
  x = x + 20
  y = y + 12
  love.graphics.print(string.format("%.3f", a), x, y)
  y = y + 12
  love.graphics.print(string.format("%.3f", b), x, y)
  y = y + 12
  love.graphics.print(string.format("%.3f", c), x, y)
end


function setupRoller(game)
  local roller = {}
  roller.x = love.graphics.getWidth() / 2
  roller.y = love.graphics.getHeight() / 2
  roller.vx = 0
  roller.vy = 0
  roller.r = 50 
  game.roller = roller
end

function accelnormalize(v, deadzone, scope, max)
  local ab = math.abs(v)
  if ab < deadzone then return 0 end
  local nv = ab / scope
  if nv > 1 then
    return nv
  end
  if v < 0 then
    return -nv
  end
  return nv
end

function dampen(v,amt)
  if v == 0 then return 0 end
  local nv = math.abs(v) - amt
  if nv < 0 then nv = 0 end
  if v < 0 then return -nv end
  return nv
end

local rollerAccel = 100
local rollerVmax = 800
function updateRoller(game,dt,input)
  local r = game.roller
  r.vx = dampen(r.vx,20)
  r.vy = dampen(r.vy,20)

  local ax = accelnormalize(input.accel.y, 0.02, 0.2, 1)
  local ay = accelnormalize(-input.accel.x, 0.02, 0.2, 1)

  r.vx = clamp(r.vx + ax * rollerAccel, -rollerVmax,rollerVmax)
  r.vy = clamp(r.vy + ay * rollerAccel, -rollerVmax,rollerVmax)

  local hit
  r.x,hit = clamp(r.x + r.vx * dt,  r.r, love.graphics.getWidth()-r.r)
  if hit then r.vx = 0 end

  r.y,hit = clamp(r.y + r.vy * dt,  r.r, love.graphics.getHeight()-r.r)
  if hit then r.vy = 0 end
end

function drawRoller(game)
  local r = game.roller
  love.graphics.setColor(0,0,0)
  love.graphics.circle("line", r.x, r.y, r.r)

  love.graphics.setColor(255,0,0)
  love.graphics.line(r.x, r.y, r.x + (r.vx/rollerVmax*r.r), r.y)
  love.graphics.setColor(0,255,0)
  love.graphics.line(r.x, r.y, r.x,r.y + (r.vy/rollerVmax*r.r))
  love.graphics.setColor(0,0,0)
end
