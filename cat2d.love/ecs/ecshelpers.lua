
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

function defineUpdateSystem(matchSpec,fn)
  local matchFn
  if type(matchSpec) == "function" then
    matchFn = matchSpec
  else
    matchFn = hasComps(unpack(matchSpec))
  end
  return function(estore, input, res)
    estore:walkEntities(
      1, -- Flags.Update   FIXME I AM TEH CHEAT!!! I said the user can define flags, but this helper actually assumes that there's such a thing as the Update flag and it is 1.
      matchFn, 
      function(e) fn(e, estore, input, res) end
    )
  end
end

function buildEntity(estore, compList, opts)
  local e = estore:newEntity()
  for _,cinfo in ipairs(compList) do
    local ctype, data = unpack(cinfo)
    estore:newComp(e, ctype, data)
  end
  if opts then
    if opts.parent then
      estore:newComp(e, 'parent', {parentEid = opts.parent.eid})
    end
  end
  return e
end
