
function lazy(fn)
  local called = false
  local value
  return function()
    if not called then 
      value = fn()
      called = true
    end
    return value
  end
end


local M = {}

M.t = lazy(function() 
  local socket = require 'socket'
  return socket.gettime()
end)


print(M.t())
print(M.t())
print(M.t())
