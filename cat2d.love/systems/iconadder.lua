
local function createNewIcon(estore, parE, tap, adderComp, res)
  local imgId = adderComp.imgId
  local img = res.images[imgId]
  local w = img:getWidth()
  local h = img:getHeight()

  local e = estore:newEntity()
  estore:newComp(e, 'tag', {name=adderComp.tagName})
  estore:newComp(e, 'img', {imgId=imgId, sx=0.3, sy=0.3, offx=w/2, offy=h/2})
  estore:newComp(e, 'pos', {x=tap.x, y=tap.y})
  estore:newComp(e, 'bounds', {x=tap.x, y=tap.y, w=50, h=50})
  -- estore:newComp(e, 'parent', {parentEid = parE.parent.parentEid})
  estore:newComp(e, 'parent', {parentEid = parE.eid})
end

return function(estore, input,res)
  for _,tap in ipairs(input.events.tap or {}) do
    estore:search(
      hasComps('iconAdder'),
      function(e)
        for _,adder in pairs(e.iconAdders) do
          if adder.id == tap.id then
            createNewIcon(estore, e, tap, adder, res)
          end
        end
      end
    )
  end
end
