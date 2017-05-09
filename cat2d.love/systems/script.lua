
-- Script system

local context = {
  script='',
  entity='',
  estore='',
  input='',
  res='',
  args={},
}

return defineUpdateSystem(hasComps('script'), function(e,estore,input,res)
  if e.script.on == 'tick' then
    local scriptFunc = res.scripts[e.script.script]
    if scriptFunc then
      context.script = script
      context.entity = e
      context.estore = estore
      context.input = input
      context.res = res
      context.args = {}
      scriptFunc(context)
    end
  end
end)
