require 'helpers'
local sti = require "sti"


function prepMaps()
  return lazytable({
      'town1',
      'town2',
    },
    function(k) return sti("maps/"..k..".lua") end
  )
end

local R = {}

R.load = function()
  local res = {
    images={},
    fonts={},
    anims={},
    maps=prepMaps(),
  }
  print(tdebug1(res))

  return res
end

return R
