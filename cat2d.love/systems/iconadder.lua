
local function createNewIcon(estore, parE, tap, adderComp, res)
  local imgId = adderComp.imgId
  local img = res.images[imgId]
  local w = img:getWidth()
  local h = img:getHeight()

  parE:newChild({
    { 'tag', {name=adderComp.tagName}},
    { 'img', {imgId=imgId, sx=0.3, sy=0.3, offx=w/2, offy=h/2}},
    { 'pos', {x=tap.x, y=tap.y}},
    { 'bounds', {x=w/2, y=h/2, w=256, h=256}},
  })
end

local function destroyIcon(estore, parE, untap, adderComp, res)
  local kills = {}
  estore:search(
    hasComps('img','tag','pos'),
    function(e)
      if e.tags[adderComp.tagName] then
        local r = 256 * e.img.sx -- FIXME cheatsies precious
        if math.dist(untap.x,untap.y, e.pos.x, e.pos.y) <= r then
          table.insert(kills,e)
        end
      end
    end
  )
  for _,e in ipairs(kills) do
    estore:destroyEntity(e)
  end
end

return defineUpdateSystem(
  {'iconAdder'},
  function(e, estore, input, res)
    for _,adder in pairs(e.iconAdders) do
      for _,tap in ipairs(input.events.tap or {}) do
        if adder.id == tap.id then
          createNewIcon(estore, e, tap, adder, res)
        end
      end
      for _,untap in ipairs(input.events.untap or {}) do
        if adder.id == untap.id then
          destroyIcon(estore, e, untap, adder, res)
        end
      end
    end
  end
)
