local M = {}

function M.handle(events, eventType, handlers)
  for _,evt in ipairs(events) do
    if evt.type == eventType then
      local fn = handlers[evt.state]
      if fn then
        fn(evt)
      end
    end
  end
end

return M
