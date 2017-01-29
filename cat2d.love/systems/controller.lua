
return function(estore, input,res)
  estore:search(
    hasComps('controller'),
    function(e)
      local events = input.events.controller or {}
      for _,evt in ipairs(events) do
        if evt.id == e.controller.id then
          e.controller[evt.input] = evt.action
        end
      end
    end
  )
end
