require 'ecs/flags'

local function updateSceneGraph(entities, t)
  local seen = {ROOT=true}
  local changed = false
  for _, e in pairs(entities) do
    local eid = e.eid
    local pid
    if e.parent then 
      pid = e.parent.parentEid
    else
      pid = "ROOT"
    end

    local skip = false
    seen[eid] = true
    if t[eid] then 
      if t[eid].pid == pid then
        -- already ok
        skip = true
      else
        -- parent set/changed
        t[eid].pid = pid
      end
    else
      -- first time we've seen this eid, create a node
      t[eid] = {eid=eid, pid=pid, ch={}} 
    end
    if not skip then
      changed = true
      local pnode = t[pid]
      if pnode then
        -- parent node already exists, append this node to its children
        table.insert(pnode.ch, t[eid])
      else
        -- parent node not added yet; add it and set this node as first child
        pnode = {eid=pid, ch={t[eid]}}
        t[pid] = pnode
      end
    end
  end
  -- )
  -- Phase 2: iterate the tree and cleanup anything that isn't in estore:
  for eid,node in pairs(t) do
    if not seen[eid] then
      changed = true
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
      changed = true
    end
  end
    
  -- if changed then print("== Scene graph updated ==\n"..tdebug(t.ROOT)) end
  -- return t["ROOT"]
end

local function walkEntitiesFromNode(estore, node, flags, fn)
  local e = estore:getEntity(node.eid)
  if e then
    if (not e.filter) or (e.filter and bit32.btest(e.filter.bits, flags)) then
      fn(e)
      for _,chnode in ipairs(node.ch) do
        walkEntitiesFromNode(estore, chnode, flags, fn)
      end
    end
  else
    print("!! ERR walkEntitiesFromNode: no entity for node.eid="..node.eid.."; node:"..tdebug(node,' '))
  end
end

local function walkEntities(estore, root, flags, fn)
  for _,node in pairs(root.ch) do
    walkEntitiesFromNode(estore, node, flags, fn)
  end
end

return function(estore,output,res)
  if not output.scenegraph then output.scenegraph = {} end
  updateSceneGraph(estore.ents, output.scenegraph, res)
  local root = output.scenegraph.ROOT

  walkEntities(estore, root, Flags.Draw, function(e)
    if e.img and e.pos then
      local img = e.img
      love.graphics.draw(
        res.images[img.imgId],
        e.pos.x, e.pos.y,
        img.r,     -- radians
        img.sx, img.sy,
        img.offx, img.offy)

    elseif e.label and e.pos then
      local label = e.label
      love.graphics.setColor(label.r, label.g, label.b)
      love.graphics.print(label.text, e.pos.x, e.pos.y)
    end
  end)
end

