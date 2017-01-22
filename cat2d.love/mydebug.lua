local D = {}

D.d = {
  varNames = {},
  varMap = {},
  maxStringLines = 10,
  stringLines = {},
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

function println(str)
  lines = D.d.stringLines
  appendScrolled(lines, str, D.d.maxStringLines)
end

function toLines()
  local lines = {}
  i = 1
  for sli,line in ipairs(D.d.stringLines) do
    lines[i] = line
    i = i + 1
  end
  return lines
end

D.toLines = toLines
D.println = println

return D
