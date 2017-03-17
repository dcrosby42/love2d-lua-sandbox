
local StickDefaults = {
  radius = 200
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
    radius = opts.radius
  }
end

local function addMotionEvents(stick, list)
  local s = stick.state
  local xdist = s.lastx - stick.x
  local xmag = math.clamp(xdist / stick.radius, -1, 1)
  table.insert(list, {input='x',action=xmag})

  local ydist = s.lasty - stick.y
  local ymag = math.clamp(ydist / stick.radius, -1, 1)
  table.insert(list, {input='y',action=ymag})

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
    s.on = false
    s.id = false
    return addStopEvents(stick,{})
  end
end

return {
  newStick=newStick,
  start=start,
  move=move,
  done=done,
}
