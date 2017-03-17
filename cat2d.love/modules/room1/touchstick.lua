
local StickDefaults = {
  radius = 100
}

local function newState()
  return {
    on=false,
    id=nil,
    startx=0,
    starty=0,
    lastx=0,
    lasty=0,
    magx=0,
    magy=0,
  }
end

local function newStick(opts)
  opts = tcopy(opts,StickDefaults)
  local bottom = love.graphics.getHeight()
  local x = opts.radius
  local y = bottom - opts.radius
  local w = 2 * opts.radius
  local h = w
  local bounds = {0,bottom-h,w,h}
  return {
    state = newState(),
    x=x,
    y=y,
    bounds=bounds,
    radius = opts.radius,
    draw={
      debug=false,
      knob=true,
    }
  }
end

local function addMotionEvents(stick, list)
  local s = stick.state
  local xdist = s.lastx - stick.x
  s.magx = math.clamp(xdist / stick.radius, -1, 1)
  table.insert(list, {input='x',action=s.magx})

  local ydist = s.lasty - stick.y
  s.magy = math.clamp(ydist / stick.radius, -1, 1)
  table.insert(list, {input='y',action=s.magy})

  return list
end

local function addStopEvents(stick, list)
  table.insert(list, {input='x',action=0})
  table.insert(list, {input='y',action=0})
  return list
end

local function start(stick, id, x,y)
  local s = stick.state
  if not s.on then
    if math.pointinrect(x, y, unpack(stick.bounds)) then
      s.on = true
      s.id = id
      s.startx = x
      s.starty = y
      s.lastx = x
      s.lasty = y
      s.magx = 0
      s.magy = 0
      return addMotionEvents(stick, {})
    end
  end
end

local function move(stick, id, x,y)
  local s = stick.state
  if s.on and s.id == id then
    s.lastx = x
    s.lasty = y
    return addMotionEvents(stick, {})
  end
end

local function done(stick, id, x,y)
  local s = stick.state
  if s.on and s.id == id then
    s.lastx = 0
    s.lastx = 0
    s.magx = 0
    s.magy = 0
    s.on = false
    s.id = false
    return addStopEvents(stick,{})
  end
end

local function draw(stick)
  if stick.draw.debug then
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("line", unpack(stick.bounds))
    love.graphics.circle("fill", stick.x, stick.y, 1, 5)
    love.graphics.circle("fill", stick.state.lastx, stick.state.lasty, 1, 5)
    love.graphics.circle("line", stick.x, stick.y, stick.radius)
  end

  if stick.draw.knob then
    love.graphics.setColor(255, 255, 255, 100)
    local knobx = stick.x
    local knoby = stick.y
    if stick.state.on then
      knobx = knobx + (stick.state.magx * stick.radius)
      knoby = knoby + (stick.state.magy * stick.radius)
    end
    love.graphics.circle("fill", knobx,knoby, 35)
  end
end

return {
  newStick=newStick,
  start=start,
  move=move,
  done=done,
  draw=draw,
}
