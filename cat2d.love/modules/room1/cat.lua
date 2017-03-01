local Cat = {}

Cat.newEntity = function(estore)
  return estore:newEntity({
    { 'pos', {x=400,y=260}},
    { 'vel', {}},
    { 'rect', offsetBounds({color={200,200,200}}, 20,32, 0.5, 1)},
    { 'bounds', offsetBounds({},20,32, 0.5, 1)},
  }, {
    {
      { 'name', {name='leftear'}},
      { 'pos', {x=-5,y=-32}},
      { 'rect', offsetBounds({color={150,150,190}}, 5, 8, 0.5, 1)},
    },
    {
      { 'name', {name='rightear'}},
      { 'pos', {x=5,y=-32}},
      { 'rect', offsetBounds({color={150,150,190}}, 5, 8, 0.5, 1)},
    },
    {
      { 'name', {name='tail'}},
      { 'pos', {x=10,y=0}},
      { 'rect', offsetBounds({color={150,150,190}}, 17, 6, 0.5, 1)},
    }
  })
end
return Cat
