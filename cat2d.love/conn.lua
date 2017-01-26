require 'helpers'
local msgpack = require 'vendor/msgpack'
local socket = require "socket"

local function udp_client(host,port)
  local udp = socket.udp()
  udp:settimeout(0)
  udp:setpeername(host,port)
  return udp
end

local function udp_server(host,port)
  local udp = socket.udp()
  udp:settimeout(0)
  udp:setsockname('*', 12345)
  return udp
end

local function receive_msgpacks(s)
  local msgs = {}
  local data
  repeat
    data, err = s:receive()
    if data then
      local msg = msgpack.unpack(data)
      msgs[#msgs+1] = msg
    end
  until not data

  return msgs
end

local function send_msgpack(s,msg)
  local data,err = msgpack.pack(msg)
  if err then
    return false, "send_msgpack pack ERR: "..err
  end

  local ok, err = pcall(function() s:send(data) end)
  if not ok then
    return false, "send_msgpack send ERR: "..err
  end
  return true, nil
end

return {
  udp_server = udp_server,
  udp_client = udp_client,
  send_message = send_msgpack,
  receive_messages = receive_msgpacks,
  sleep = socket.sleep,
}
