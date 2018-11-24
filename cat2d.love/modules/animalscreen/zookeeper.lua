local EventHelpers = require 'eventhelpers'

--
-- zookeeper system
--

-- TODO new component zookeeper to manage state of drag/spawn etc?
return defineUpdateSystem(allOf(hasTag('zookeeper')),
  function(e,estore,input,res)
    -- if #input.events > 0 then
    --   for _,e in ipairs(input.events) do
    --     print(tflatten(e))
    --   end
    -- end
    EventHelpers.handle(input.events, 'touch', {
      pressed=function(touch)
        print("TOUCH PRESSED "..tflatten(touch))
      end,
    })
    EventHelpers.handle(input.events, 'mouse', {
      pressed=function(touch)
        print("MOUSE PRESSED "..tflatten(touch))
      end,
      released=function(touch)
        print("MOUSE RELEASED "..tflatten(touch))
      end,
    })
  end
)
