
function flattenTable(t)
  s = ""
  for k,v in pairs(t) do
    if #s > 0 then s = s .. " " end
    s = s .. tostring(k) .. "=" .. tostring(v)
  end
  return s
end

tflatten = flattenTable

function tcount(t)
  local ct = 0
  for _,_ in pairs(t) do ct = ct + 1 end
  return ct
end

function tcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in pairs(orig) do
      copy[orig_key] = orig_value
    end
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

function deeptcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[deepcopy(orig_key)] = deepcopy(orig_value)
    end
    setmetatable(copy, deepcopy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

function tmerge(left,right)
  for k,v in pairs(right) do
    left[k] = v
  end
end

function tappend(t,x)
  t[#t+1] = x
end

function tdebug(t,ind)
  if not ind then ind = "" end

  if type(t) == "table" then
    local lines = {}
    if ind ~= "" then lines[1] = "" end  -- inner tables need to bump down a line
    local count = 0
    for k,v in pairs(t) do
      local s = ind .. k .. ": " .. tdebug(v,ind.."  ")
      tappend(lines, s)
      count = count +1
    end
    if count > 0 then
      return table.concat(lines,"\n")
    else
      return "{}"
    end
  else
    return tostring(t)
  end
end

function keyvalsearch(t,matchFn,callbackFn)
  for _,v in pairs(t) do
    if fn(k,v) then callbackFn(k,v) end
  end
end

function valsearch(t,matchFn,callbackFn)
  for _,v in pairs(t) do
    if fn(v) then callbackFn(v) end
  end
end

function valsearchfirst(t,matchFn,callbackFn)
  for _,v in pairs(t) do
    if fn(v) then return callbackFn(v) end
  end
end

local function iterateFuncs(...)
  local funcs = {...} -- convert varargs into an array
  return function(estore,input)
    for _,fn in ipairs(funcs) do
      fn(estore,input)
    end
  end
end