Comp = require 'ecs/component'
Etree = require 'ecs/entitytree'

local Estore = {
  eidCounter=1,
  cidCounter=1,
  comps={},
  ents={},
  etree={},
}

function Estore:new(o)
  local o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Estore:nextEid()
  local eid = "e" .. self.eidCounter
  -- local eid = self.eidCounter
  self.eidCounter = self.eidCounter + 1
  return eid
end

function Estore:nextCid()
  local cid = "c" .. self.cidCounter
  -- local cid = self.cidCounter
  self.cidCounter = self.cidCounter + 1
  return cid
end

function Estore:newEntity()
  local eid = self:nextEid()
  local e = {eid=eid}
  self.ents[eid] = e
  return e
end

function Estore:destroyEntity(e)
  local kills={}
  for _,comp in pairs(self.comps) do
    if comp.eid == e.eid then
      table.insert(kills,comp)
    end
  end
  for _,comp in ipairs(kills) do
    self:removeComp(comp)
  end
end

-- Get the component name, for use as a key into the collection of a particular comp type in an entity.
-- Eg, comp { type="imgsprite", name="door" } could be stored in e.imgsprites.door.
-- If name is nil or empty string, use count+1 (stringified).  Eg,  e.imgsprites["3"]
local function compName(comp, t)
  local name = comp.name
  if (not name) or (name == "") then
    local num = #t+1
    while t[tostring(num)] do
      num = num + 1
    end
    name = tostring(num)
  end
  return name
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

  -- Index the comp by cid
  if not comp.cid or comp.cid == '' then
    comp.cid = self:nextCid()
  end
  self.comps[comp.cid] = comp

  -- Add to this entity:
  local key = comp.type
  local keyp = key .. "s"
  if not e[key] then
    -- First component of this type
    e[key] = comp
    e[keyp] = {}
    e[keyp][compName(comp,e[keyp])] = comp
  else
    -- This entity already has some of this comp type
    e[keyp][compName(comp,e[keyp])] = comp
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

    local keycount = 0
    for k,v in pairs(e) do keycount = keycount + 1 end
    if keycount <= 1 then 
      -- eid is only remaining key, meaning we have no comps
      -- remove e from ents
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

function Estore:eachEntity(fn)
  for _,ent in pairs(self.ents) do
    fn(ent)
  end
end

function Estore:_walkEntitiesFromNode(node, flags, matchFn, doFn)
  local e = self:getEntity(node.eid)
  if e then
    if (not e.filter) or (e.filter and bit32.btest(e.filter.bits, flags)) then
      if (not matchFn) or matchFn(e) then -- execute doFn if either a) no matcher, or b) matcher provided and returns true
        doFn(e) 
      end
      for _,chnode in ipairs(node.ch) do
        self:_walkEntitiesFromNode(chnode, flags, matchFn, doFn)
      end
    end
  else
    print("!! ERR Estore:walkEntitiesFromNode: no entity for node.eid="..node.eid.."; node:"..tdebug(node,' '))
  end
end

function Estore:walkEntities(flags, matchFn, doFn)
  for _,node in pairs(self.etree.ROOT.ch) do
    self:_walkEntitiesFromNode(node, flags, matchFn, doFn)
  end
end

function Estore:updateEntityTree()
  Etree.updateEntityTree(self.ents, self.etree)
end

function Estore:search(matchFn,doFn)
  valsearch(self.ents, matchFn, doFn)
end


function compDebugString(comp)
  return Comp.debugString(comp)
end

function entityDebugString(e)
  s = e.eid .. ": " .. "\n"
  for k,v in pairs(e) do
    if v.cid and v.eid then
      keyp = k.."s"
      if tcount(e[keyp]) == 1 then
        s = s.."  "..k..": "..Comp.debugString(v) .. "\n"
      else
        s = s.."  "..keyp..": \n"
        for name,comp in pairs(e[keyp]) do
          s = s.."    "..name..": "
          if v.cid == comp.cid then
            s = s .. "*"
          end
          s = s..Comp.debugString(comp) 
          s = s .."\n"
        end
      end
    end
  end
  return s
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
  return s
end



return Estore
