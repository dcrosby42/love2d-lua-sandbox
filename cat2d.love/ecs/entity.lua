
local Entity = {
}

function Entity:new(o)
  local o = o or {
    eid=nil,
    _estore=nil
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function Entity:newComp(ctype, data)
  return self._estore:newComp(self, ctype, data)
end

function Entity:addComp(comp)
  return self._estore:addComp(self, comp)
end

function Entity:removeComp(comp)
  self._estore:removeComp(comp)
end

function Entity:getParent()
  return self._parent
end

function Entity:getChildren()
  return self._children
end

function Entity:newChild(compInfos, subs)
  parentInfo = {'parent', {parentEid=self.eid}}
  if compInfos then
    local parentInfoFound = false
    for i,info in ipairs(compInfos) do
      if info[1] == 'parent' then
        if parentInfoFound then error("ERR newChild() cannot accept two 'parent' comp types") end
        parentInfoFound = true
        if info[2].order then
          parentInfo[2].order = info[2].order
        end
        compInfos[i] = parentInfo
      end
    end
    if not parentInfoFound then
      table.insert(compInfos,parentInfo)
    end
  else
    compInfos = { parentInfo }
  end

  return self._estore:newEntity(compInfos, subs)
end

function Entity:addChild(childEnt)
  self._estore:setupParent(self, childEnt)
end

return Entity
