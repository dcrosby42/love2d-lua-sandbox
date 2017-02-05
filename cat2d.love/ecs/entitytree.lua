Etree = {}

local function byOrder(a,b) 
  if a.order == nil then print("NIL ORDER for a? eid="..a.eid.." pid="..a.pid) end
  if b.order == nil then print("NIL ORDER for b? eid="..b.eid.." pid="..b.pid) end
  return a.order < b.order
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
    local pidChanged, orderChanged
    local node = t[eid]
    if node then 
      if node.pid == pid then
        -- already ok
        skip = true
      else
        -- parent set/changed
        node.pid = pid
        pidChanged = true
      end
      if node.order ~= order then
        node.order = order
        orderChanged = true
      end
    else
      -- first time we've seen this eid, create a node
      node = {eid=eid, pid=pid, order=order, ch={}} 
      t[eid] = node
      pidChanged = true
      orderChanged = true
    end
    -- TODO: If RE-parenting or RE-ordering has transpired, we;re not handing that yet
    if not skip then
      local pnode = t[pid]
      if pnode then
        -- parent node already exists, append this node to its children
        table.insert(pnode.ch, node)
        table.sort(pnode.ch, byOrder)
      else
        -- parent node not added yet; add it and set this node as first child
        pnode = {eid=pid, order=0, ch={node}}
        t[pid] = pnode
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
        local remi
        for i,node in ipairs(pnode.ch) do
          if node.eid == eid then
            remi = i
            break
          end
        end
        if remi then table.remove(pnode.ch, remi) end
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
