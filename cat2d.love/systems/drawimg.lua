
local function updateSceneGraph(estore, output, res)
  local seen = {ROOT=true}
  local changed = false
  local t = output.scenegraph
  if not t then
    t = {} -- {ROOT={ch={}}}
    output.scenegraph = t
  end
  estore:search(
    hasComps('parent'),
    function(e)
      local eid = e.eid
      local pid = e.parent.parentEid
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
  )
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
  return t["ROOT"]
end

local function forEachActiveEntity(estore, node,fn, parentEntity)
  -- if node.eid == "ROOT" then
  --   for _,chnode in ipairs(node.ch) do
  --     forEachActiveEntity(chnode, fn, nil)
  --   end
  -- else
  local e = estore:getEntity(node.eid)
  if e then
    if (not e.scene) or (e.scene and e.scene.active) then
      fn(e, parentEntity)
      for _,chnode in ipairs(node.ch) do
        forEachActiveEntity(estore, chnode, fn, e)
      end
    end
  else
    print("!! ERR forEachActiveEntity: no entity for node.eid="..node.eid.."; node:"..tdebug(node,' '))
  end
  -- end
end

local function drawEntity(estore, output, res, e, parentE)
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
end

return function(estore,output,res)
  local root = updateSceneGraph(estore,output,res)

  for _,node in pairs(root.ch) do
    forEachActiveEntity(estore, node, function(e, parentE)
      drawEntity(estore, output, res, e, parentE)
    end)
  end
end

