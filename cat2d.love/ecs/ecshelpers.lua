
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

function setParentEntity(estore, childE, parentE, order)
  if childE.parent then
    estore:removeComp(childE.parent)
  end
  estore:newComp(childE, 'parent', {parentEid=parentE.eid, order=order})
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
      matchFn,
      function(e) fn(e, estore, input, res) end
    )
  end
end

function buildEntity(estore, compList)
  local e = estore:newEntity()
  for _,cinfo in ipairs(compList) do
    local ctype, data = unpack(cinfo)
    estore:newComp(e, ctype, data)
  end
  -- print(tdebug(e))
  return e
end


function getPos(e)
  local par = e:getParent()
  if par and par.pos then
    local x,y = getPos(par)
    return e.pos.x + x, e.pos.y + y
  else
    return e.pos.x, e.pos.y
  end
end
