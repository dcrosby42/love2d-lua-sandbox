require 'helpers'
local function parseDoorLink(linkStr)
  local parts = split(linkStr, ":")
  local kind = parts[1]
  parts = split(parts[2], "/")
  local mapname = parts[1]
  local spawnPointName = parts[2]
  return {
    type=kind,
    mapName=mapname,
    spawnName=spawnPointName,
  }
end
local function handleCollision(ent, hitEnt, estore, res)
  -- print(entityDebugString(hitEnt))
  if hitEnt.door then
    print("Door "..hitEnt.door.doorid.." to: "..hitEnt.door.link)
    local dl = parseDoorLink(hitEnt.door.link)
    print("  --> "..tflatten(dl))
    ent:newComp('output', {kind='door',value=dl})
  end
end

return defineUpdateSystem(hasComps('map'),
  function(mapEnt,estore,input,res)
    local map = getMapResource(mapEnt,res)
    if not map then return end
    local bumpWorld = map.bumpWorld
    local itemList = map.itemList
    local entityCollisions = {}

    -- Make sure bumpWorld is cleared of any items whose comps no longer exist in estore
    local removes = {}
    for i=1,#itemList do
      if not estore.comps[itemList[i]] then
        table.insert(removes,i)
      end
    end
    for i=1,#removes do
      local item = itemList[removes[i]]
      print("bumpWorld:remove("..item..")")
      bumpWorld:remove(item)
      table.remove(itemList,removes[i])
    end

    estore:walkEntities(hasComps('vel','pos'), function(e)
      -- Update position based on velocity:
      local vel = e.vel
      local pos = e.pos

      if e.collidable then
        local x,y = getPos(e)
        x,y,bw,bh = getBoundingRect(e)
        local item = e.collidable.cid

        if bumpWorld:hasItem(item) then
          bumpWorld:update(item, x, y, bw, bh)
        else
          print("bumpWorld:add("..item..") bumpWorld="..tostring(bumpWorld).." map="..tostring(map))
          bumpWorld:add(item, x, y, bw,bh)
          table.insert(itemList, item)
        end

        goalx = x + vel.dx * input.dt
        goaly = y + vel.dy * input.dt
        finalx, finaly, cols, numcols = bumpWorld:move(item, goalx, goaly)
        pos.x = pos.x + (finalx - x) -- convert back to local coords
        pos.y = pos.y + (finaly - y)
        if numcols > 0 then
          for i=1,numcols do
            local col = cols[i]
            if type(col.other) == "table" then
              if col.other and col.other.properties and col.other.properties.entityid then
                local hitE = estore:getEntity(col.other.properties.entityid)
                table.insert(entityCollisions, {e,hitE})
              else
                otherdbg = tdebug1(col.other)
                if col.other.properties then
                  otherdbg = otherdbg .. "--> properties:\n"..tdebug1(col.other.properties,'    ')
                end
                -- print("!! Unhandled collision while moving item="..item..": "..otherdbg)
              end
            end
          end
        end
      else
        -- no collision detection
        pos.x = pos.x + vel.dx * input.dt
        pos.y = pos.y + vel.dy * input.dt
      end
    end)

    for i=1,#entityCollisions do
      local ent,hitEnt = unpack(entityCollisions[i])
      handleCollision(ent, hitEnt, estore, res)
    end
  end
)
