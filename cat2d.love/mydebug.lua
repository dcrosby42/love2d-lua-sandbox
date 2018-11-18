local D = {}

D.d = {
  varNames = {},
  varMap = {},
  lineHeight = 12,
  maxStringLines = 10,
  stringLines = {},
  bounds = {}
}

local function appendScrolled(lines,s,max)
  local e = #lines
  if e >= max then
    for i=1, (e - 1) do
      lines[i] = lines[i+1]
    end
    e = e - 1
  end
  n = e + 1
  lines[n] = s
end

local function println(str)
  lines = D.d.stringLines
  appendScrolled(lines, str, D.d.maxStringLines)
end

local function toLines()
  local lines = {}
  i = 1
  for sli,line in ipairs(D.d.stringLines) do
    lines[i] = line
    i = i + 1
  end
  return lines
end

local function setup()
  local bounds = D.d.bounds
  bounds.height = D.d.maxStringLines * D.d.lineHeight
  bounds.width = love.graphics.getWidth() / 2
  bounds.y = love.graphics.getHeight() - bounds.height
  bounds.x = 0
end

local function draw()
  -- DEBUG
  local dlines = toLines()
  local y = D.d.bounds.y
  for i,line in ipairs(dlines) do
    love.graphics.print(line,0,y)
    y = y + D.d.lineHeight
  end
end

D.toLines = toLines
D.println = println
D.setup = setup
D.update = update
D.draw = draw

return D
