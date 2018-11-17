local M = {}

M.newWorld = function()
  return {
    message="Hello animals"
  }
end

M.updateWorld = function(w,action)
end

M.drawWorld = function(w)
  love.graphics.print(w.message,0,0)
end

return M
