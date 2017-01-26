local msgpack = require 'vendor/msgpack'
local socket = require "socket"

local Client = {}

function Client:new(host,port)
  local udp = socket.udp()
  udp:settimeout(0)
  udp:setpeername(host,port)

  o = { udp=udp }
  setmetatable(o, self)
  self.__index = self
  return o
end

function Client:send(msg)
  local data,err = msgpack.pack(msg)
  if err then
    return false, "Client:send msgpack ERR: "..err
  end

  local ok, err = pcall(function() self.udp:send(data) end)
  if not ok then
    return false, "Client:send send ERR: "..err
  end
  return true, nil
end

function Client:receive_many()
  local msgs = {}
  local data
  repeat
    data, err = self.udp:receive()
    if data then
      local msg = msgpack.unpack(data)
      msgs[#msgs+1] = msg
    end
  until not data

  return msgs
end

return Client
