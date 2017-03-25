local Comp = require 'ecs/component'

Comp.define("script", {'scriptId','','params',{}})

return defineUpdateSystem(hasComps('script'),function(e,estore,input,res)
  for _,script in pairs(e.scripts) do
    fn = res.scripts[script.scriptId]
    if not fn then error("No script registerd for '"..script.scriptId.."'") end
    fn(script,e,estore,input,res)
  end
end)
