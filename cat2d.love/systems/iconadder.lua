
local function createNewIcon(estore, tap, adderComp, res)
  local e = estore:newEntity()
  estore:newComp(e, 'tag', {name=adderComp.tagName})
  estore:newComp(e, 'img', {imgId=adderComp.imgId, sx=0.3, sy=0.3, offx=25, offy=25})
  estore:newComp(e, 'pos', {x=tap.x, y=tap.y})
  estore:newComp(e, 'bounds', {x=tap.x, y=tap.y, w=50, h=50})
end

return function(estore, input,res)
  for _,tap in ipairs(input.events.tap or {}) do
    estore:search(
      hasComps('iconAdder'),
      function(e)
        for _,adder in pairs(e.iconAdders) do
          if adder.id == tap.id then
            createNewIcon(estore, tap, adder, res)
          end
        end
      end
    )
  end
end
