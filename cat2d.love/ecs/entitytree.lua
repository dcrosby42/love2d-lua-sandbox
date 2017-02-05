Etree = {}

local function byOrder(a,b) 
  -- if a.order == nil then print("NIL ORDER for a? eid="..a.eid.." pid="..a.pid) end
  -- if b.order == nil then print("NIL ORDER for b? eid="..b.eid.." pid="..b.pid) end
  return a.order < b.order
end

local function removeNodeFromList(list, node)
  if list then
    local remi = -1
    local eid = node.eid
    for i,n in ipairs(list) do
      if n.eid == node.eid then
        remi = i
        break
      end
    end
    if remi > 0 then
      table.remove(list,remi)
    end
  end
end

local function updateEntityTree(entities, t)
  local seen = {ROOT=true}
  for _, e in pairs(entities) do
    local eid = e.eid
    local pid, order
    if e.parent then 
      pid = e.parent.parentEid
      order = e.parent.order
      if not order then order = 0 end
    else
      pid = "ROOT"
      order = 0
    end

    seen[eid] = true
    local skip = false
    local pidUpdated = false
    local prevPid = nil
    local orderUpdated = false
    local node = t[eid]
    if node then 
      if node.pid == pid then
        -- no change
      elseif node.pid == nil then
        -- first time pid assigned
        node.pid = pid
        pidUpdated = true
      else 
        -- pid has changed
        prevPid = node.pid
        node.pid = pid
        pidUpdated = true
      end
      if node.order ~= order then
        node.order = order
        orderUpdated = true
      end
    else
      -- first time we've seen this eid, create a node
      node = {eid=eid, pid=pid, order=order, ch={}} 
      t[eid] = node
      pidUpdated = true
    end

    if pidUpdated then
      if prevPid then
        local prevpnode = t[prevPid]
        if prevpnode then
          -- print("Etree: removing node "..node.eid.." from parent "..prevpnode.eid)
          removeNodeFromList(prevpnode.ch, node)
        end
      end

      local pnode = t[pid]
      if pnode then
        -- parent node already exists, append this node to its children
        -- print("Etree: adding node "..node.eid.." to parent "..pnode.eid)
        table.insert(pnode.ch, node)
        table.sort(pnode.ch, byOrder)
      else
        -- parent node not added yet; add it and set this node as first child
        -- print("Etree: adding node "..node.eid.." to STUBBED parent "..eid)
        pnode = {eid=pid, order=0, ch={node}}
        t[pid] = pnode
      end
    elseif orderUpdated then
      -- The order value has changed for this node, but its parenting stayed the same
      local pnode = t[pid]
      if pnode then
        -- print("Etree: re-sorting children of "..pnode.eid.." due to order change")
        table.sort(pnode.ch, byOrder)
      end
    end
  end

  -- Phase 2: iterate the tree and cleanup anything that isn't in estore:
  for eid,node in pairs(t) do
    if not seen[eid] then
      -- entity for eid is in the graph but NOT in the estore
      -- remove from parent node's ch list:
      local pnode = t[t[eid].pid]
      if pnode then
        removeNodeFromList(pnode.ch, node)
      end
      -- remove from cache
      t[eid] = nil
    end
  end
end

Etree.updateEntityTree = updateEntityTree

Etree.etreeSystem = function(estore,input,res)
  estore:updateEntityTree()
end

return Etree
