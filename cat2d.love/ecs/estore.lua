Comp = require 'ecs/component'
Entity = require 'ecs/entity'

local Estore = {
}

function Estore:new(o)
  local o = o or {
    eidCounter=1,
    cidCounter=1,
    comps={},
    ents={},
    _root={_children={}},
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function Estore:nextEid()
  local eid = "e" .. self.eidCounter
  self.eidCounter = self.eidCounter + 1
  return eid
end

function Estore:nextCid()
  local cid = "c" .. self.cidCounter
  self.cidCounter = self.cidCounter + 1
  return cid
end

function Estore:newEntity(compList, subs)
  local eid = self:nextEid()
  local e = Entity:new({
    eid=eid,
    _estore=self,
    _parent=nil,
    _children={}
  })
  self.ents[eid] = e
  addChildEntityTo(self._root, e)

  if compList then
    for _,cinfo in ipairs(compList) do
      local ctype, data = unpack(cinfo)
      self:newComp(e, ctype, data)
    end
  end

  if subs then
    for _, childComps in ipairs(subs) do
      e:newChild(childComps)
    end
  end
  return e
end

function Estore:buildEntity(compList, subs)
  return self:newEntity(compList, subs)
end

function Estore:destroyEntity(e)
  for _,childEnt in ipairs(e._children) do
    self:destroyEntity(childEnt)
  end

  local compsToRemove={}
  for _,comp in pairs(self.comps) do
    if comp.eid == eid then
      table.insert(compsToRemove,comp)
    end
  end

  for _,comp in ipairs(compsToRemove) do
    self:removeComp(comp)
  end

  if e._parent then
    removeChildEntityFrom(e._parent, e)
  end
end

-- Claim a comp from its object pool and (optionally) initialize with values from given data.
-- Once initialized, the comp is then added via Estore:addComp(e,comp)... see those docs for more info.
function Estore:newComp(e, typeName, data)
  local compType = assert(Comp.types[typeName], "No component type '"..typeName.."'")
  local comp = compType.cleanCopy(data)
  return self:addComp(e, comp)
end

-- Attaches a component to an entity.
-- The component will be added to:
--   - the internal component cache (keyed by cid)
--   - the entity's singular reference for this type of component (for the first comp of any given type)
--   - the entity's collection for this comp type, keyed by name or pseudoname (a string representing the number of this comp)
-- The component will be modified:
--   - comp.eid will be set to the entity's eid
--
-- Eg:
--   Given comp={type="imgsprite", cid=42, name="hat"} and e={eid=100}
--   When  estore.addComp(e,comp)
--   Then  e.imgsprite == comp
--         e.imgsprites.hat == comp
--         comp.eid == 100
--
-- Another eg:
--   Given comp with no name
--   When  estore.addComp(e,comp)
--   Then  e.imgsprite == comp
--         e.imgsprites["1"] == comp
--         comp.eid == 100
function Estore:addComp(e,comp)
  if not self.ents[e.eid] then
    self.ents[e.eid] = e -- shenanigans... if while modifying an entity, it becomes empty of comps, it may have gotten cleaned out of the ents cache.
  end

  -- Officially relate this comp to its entity
  comp.eid = e.eid

  -- Assign the next cid:
  if not comp.cid or comp.cid == '' then
    comp.cid = self:nextCid()
  end
  -- Index the comp by cid
  self.comps[comp.cid] = comp

  -- Add to this entity:
  local key = comp.type
  local keyp = key .. "s"

  if key == "parent" then
    if e.parent then
      error("UNACCEPTABLE! only one 'parent' Component per Entity please! comp="..tdebug(comp).." entity="..entityDebugString(e))
    end
    local pid = comp.parentEid
    local parentEntity = self.ents[pid]
    if parentEntity then
      if e._parent then
        removeChildEntityFrom(e._parent, e)
      end
      e._parent = parentEntity
      local chs = parentEntity._children
      local reorder = true
      if not comp.order or comp.order == '' then
        local myOrder = #chs + 1
        if #chs > 0 then
          local lastOrder = chs[#chs].order
          if lastOrder then
            myOrder = lastOrder + 1
          end
        end
        comp.order = myOrder
        reorder = false
      end
      table.insert(chs, e)
      if reorder then
        parentEntity:resort()
      end
    end
  end

  if not e[key] then
    -- First component of this type
    e[key] = comp
    e[keyp] = {}
    e[keyp][comp.name or comp.cid] = comp
  else
    -- This entity already has some of this comp type
    e[keyp][comp.name or comp.cid] = comp
  end

  return comp
end

-- Detach a component from the given entity.
-- Use this method if you plan to move a comp from one entity to another.
-- The comp will remain in the comps cache, and will NOT be released back to its object pool.
function Estore:detachComp(e,comp)
  if e then
    local key = comp.type
    local keyp = key .. "s"
    local plural = e[keyp]

    -- Remove comp from the plural ref table:
    for k,c in pairs(plural) do
      if c.cid == comp.cid then
        plural[k] = nil
      end
    end

    -- If this comp was the singular comp ref, pick a different comp (or nil) to replace it:
    if e[key] and e[key].cid == comp.cid then
      _, val = next(e[keyp], nil) -- pluck any comp from the plural ref
      e[key] = val -- will either be another comp or nil, if there weren't any more
      if not val then
        e[keyp] = nil -- plural ref was empty, clean it out
      end
    end

    if key == "parent" then
      self:_deparent(e)
    end

    local compkeycount = 0
    for k,v in pairs(e) do
      if k:byte(1) ~= 95 then  -- k doesn't start with _
        compkeycount = compkeycount + 1
      end
    end
    if compkeycount <= 1 then
      -- eid is only remaining key, meaning we have no comps... EVAPORATE THE ENTITY
      self:_deparent(e)
      self.ents[e.eid] = nil
    end
  end
  comp.eid = ''
end

-- Remove the comp from its entity and the estore.
-- The comp will be removed from the comps cache and released back to its object pool.
function Estore:removeComp(comp)
  self:detachComp(self.ents[comp.eid], comp)

  self.comps[comp.cid] = nil -- uncache
  comp.cid = ''

  Comp.release(comp)
end

function Estore:transferComp(eFrom, eTo, comp)
  self:detachComp(eFrom, comp)
  self:addComp(eTo, comp)
end

function Estore:getEntity(eid)
  return self.ents[eid]
end

function Estore:getComp(cid)
  return self.comps[cid]
end

function keyvalsearch(t,matchFn,callbackFn)
  for _,v in pairs(t) do
    if fn(k,v) then callbackFn(k,v) end
  end
end

function valsearch(t,matchFn,callbackFn)
  for _,v in pairs(t) do
    if matchFn(v) then callbackFn(v) end
  end
end

function valsearchfirst(t,matchFn,callbackFn)
  for _,v in pairs(t) do
    if fn(v) then return callbackFn(v) end
  end
end

function Estore:_eachEntity(fn)
  for _,ent in pairs(self.ents) do
    fn(ent)
  end
end

function Estore:walkEntities(matchFn, doFn)
  for _,e in pairs(self._root._children) do
    self:_walkEntity(e, matchFn, doFn)
  end
end

function Estore:_walkEntity(e, matchFn, doFn)
  local proceed = true
  if matchFn and type(matchFn) == "number" then
    print("WUT?")
    print(debug.traceback())
  end
  if (not matchFn) or matchFn(e) then -- execute doFn if either a) no matcher, or b) matcher provided and returns true
    local out = doFn(e)
    if out == false then proceed = false end
  end
  if proceed then
    for _,ch in ipairs(e._children) do
      self:_walkEntity(ch, matchFn, doFn)
    end
  end
end

function Estore:_deparent(e)
  if e._parent then
    removeChildEntityFrom(e._parent, e)
    if e._parent.eid and e._children then
      for _,childEntity in ipairs(e._children) do
        self:setupParent(e._parent, childEntity)
      end
    end
  else
    if e._children then
      for _,childEntity in ipairs(e._children) do
        if childEntity.parent then
          self:removeComp(childEntity.parent)
        end
        addChildEntityTo(self._root, childEntity)
      end
    end
  end
end

function Estore:setupParent(parentEnt, childEnt)
  if childEnt.parent then
    self:removeComp(childEnt.parent)
  end
  self:newComp(childEnt, 'parent', {parentEid=parentEnt.eid})
end

function Estore:search(matchFn,doFn)
  valsearch(self.ents, matchFn, doFn)
end

function Estore:getParent(e)
  return e._parent
end

function Estore:getChildren(e)
  return e._children
end

function compDebugString(comp)
  return Comp.debugString(comp)
end


function Estore:debugString()
  local s = ""
  s = s .. "-- Estore:\n"
  s = s .. "--- Next eid: e" .. self.eidCounter .. ", Next cid: c" .. self.cidCounter .. "\n"
  s = s .. "--- Components (self.comps):\n"
  for cid,comp in pairs(self.comps) do
    s = s..cid .. ": " .. Comp.debugString(comp) .. "\n"
  end
  s = s .. "--- Entities (self.ents):\n"
  for eid,e in pairs(self.ents) do
    s = s .. entityDebugString(e)
  end
  s = s .. "--- Tree (self._root):\n"
  for _,ch in ipairs(self._root._children) do
    s = s .. entityTreeDebugString(ch,"  ")
  end
  return s
end

function addChildEntityTo(parEnt, chEnt)
  assert(parEnt, "ERR addChildEntityTo nil parEnt?")
  assert(parEnt._children, "ERR addChildEntityTo parent._children nil?")
  assert(chEnt, "ERR addChildEntityTo nil chEnt?")
  chEnt._parent = parEnt
  table.insert(parEnt._children, chEnt)
end

function removeChildEntityFrom(parEnt, chEnt)
  chEnt._parent = nil
  local remi = -1
  local eid = chEnt.eid
  local list = parEnt._children
  for i,n in ipairs(list) do
    if n.eid == eid then
      remi = i
      break
    end
  end
  if remi > 0 then
    table.remove(list,remi)
  end
end

function entityDebugString(e)
  local eid = e.eid
  if not eid then
    eid = "NO_EID"
  end
  s = eid .. ": " .. "\n"
  for k,v in pairs(e) do
    if tostring(k):byte(1) ~= 95 then
      if v.cid and v.eid then
        keyp = tostring(k).."s"
        if tcount(e[keyp]) == 1 then
          s = s.."  "..tostring(k)..": "..Comp.debugString(v) .. "\n"
        else
          s = s.."  "..tostring(keyp)..": \n"
          for name,comp in pairs(e[keyp]) do
            s = s.."    "..tostring(name)..": "
            if v.cid == comp.cid then
              s = s .. "*"
            end
            s = s..Comp.debugString(comp)
            s = s .."\n"
          end
        end
      end
    end
  end
  return s
end

function entityTreeDebugString(e,indent)
  local s = indent
  if e.name and e.name.name then
    s = s .. e.name.name .. " (" .. e.eid .. "): \n"
  else
    s = s .. e.eid .. ": \n"
  end
  for _,ch in ipairs(e._children) do
    s = s .. entityTreeDebugString(ch,indent.."  ")
  end
  return s
end



return Estore
