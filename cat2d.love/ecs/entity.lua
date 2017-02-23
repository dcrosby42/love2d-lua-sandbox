
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

function Entity:getParent()
  return self._estore:getParent(self)
end

function Entity:getChildren()
  return self._estore:children(self)
end

return Entity
