local Debug = require 'mydebug'
local EventHelpers = require 'eventhelpers'
local Entities = require 'modules.animalscreen.entities'

return function(estore, input, res)
  EventHelpers.handle(input.events, 'touch', {

    pressed =function(touch)
      local hit
      estore:seekEntity(
        hasTag('animal'),
        function(e) 
          if dist(touch.x,touch.y, e.pos.x,e.pos.y) <= 70 then
            hit = e
            return true
          end
        end
      )
      local e = hit
      if not e then
        local name = pickRandom(res.animalNames)
        e = Entities.animal(estore, name)
      end
      e.img.sx = 0.7
      e.img.sy = 0.7
      e.pos.x = touch.x
      e.pos.y = touch.y
      e:newComp('manipulator', {id=touch.id, mode='drag'}) -- TODO MORE INFO HERE
    end,

    moved =function(touch)
      estore:walkEntities(
        hasComps('manipulator','pos'),
        function(e)
          if e.manipulator.id == touch.id then
            e.pos.x = touch.x
            e.pos.y = touch.y
          end
      end)
    end,

    released =function(touch)
      estore:walkEntities(
        hasComps('manipulator','pos'),
        function(e)
          if e.manipulator.id == touch.id then
            e.pos.x = touch.x
            e.pos.y = touch.y
            e.img.drawBounds = false
            e.img.sx = 0.5
            e.img.sy = 0.5
            e:removeComp(e.manipulator)
          end
      end)
    end,

  })
end

-- function defineUpdateSystem(matchSpec,fn)
--   local matchFn = matchSpecToFn(matchSpec)
--   return function(estore, input, res)
--     estore:walkEntities(
--       matchFn,
--       function(e) fn(e, estore, input, res) end
--     )
--   end
-- end
