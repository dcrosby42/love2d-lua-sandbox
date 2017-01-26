local msgpack = require 'vendor/msgpack'
local socket = require "socket"

local Server = {}

function Server:new(host,port)
  local udp = socket.udp()
  udp:settimeout(0)
  udp:setsockname(host,port)

  o = { udp=udp }
  setmetatable(o, self)
  self.__index = self
  return o
end

function Server:send_to(msg, host, port)
  local data,err = msgpack.pack(msg)
  if err then
    return false, "Server:send msgpack ERR: "..err
  end

  local ok, err = pcall(function() self.udp:sendto(data, host, port) end)
  if not ok then
    return false, "Server:send send ERR: "..err
  end
  return true, nil
end

function Server:receive_from()
  local data, host, port = self.udp:receivefrom()
  if data then
    local msg = msgpack.unpack(data)
    return msg, host, port, nil
  else
    return nil, nil, nil, nil
  end
end

function Server:sleep(t)
  socket.sleep(t)
end

function Server:getTime()
  return socket.gettime()
end

return Server
