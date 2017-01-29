
function hasComps(...)
  local ctypes = {...}
  local num = #ctypes
  if num == 0 then
    return function(e) return true end
  elseif num == 1 then
    return function(e) 
      return e[ctypes[1]] ~= nil
    end
  elseif num == 2 then
    return function(e) 
      return e[ctypes[1]] ~= nil and e[ctypes[2]] ~= nil
    end
  elseif num == 3 then
    return function(e) 
      return e[ctypes[1]] ~= nil and e[ctypes[2]] and e[ctypes[3]] ~= nil
    end
  elseif num == 4 then
    return function(e) 
      return e[ctypes[1]] ~= nil and e[ctypes[2]] and e[ctypes[3]] ~= nil and e[ctypes[4]] ~= nil 
    end
  else
    return function(e)
      for _,ctype in ipairs(ctypes) do
        if e[ctype] == nil then return end
      end
      return true
    end
  end
end
    
function addInputEvent(input, evt)
  if not input.events[evt.type] then
    input.events[evt.type] = {}
  end
  table.insert(input.events[evt.type], evt)
end

function iterateFuncs(...)
  local funcs = {...} -- convert varargs into an array
  return function(estore,input)
    for _,fn in ipairs(funcs) do
      fn(estore,input)
    end
  end
end
