local socket = require "socket"
local msgpack = require "vendor/msgpack"
 
local udp = socket.udp()
udp:settimeout(0)
udp:setsockname('*', 12345)
 
local world = {} -- the empty world-state
 
local data, msg_or_ip, port_or_nil
local entity, cmd, parms
local running = true
 
print "UDP server bound to 12345"
while running do
  local data, host, port = udp:receivefrom()
  if data then
    local msg = msgpack.unpack(data)
    print("FROM[" .. host .. ", " .. port .. "]: " .. msg.type .. ", " .. msg.message)


    -- local outmsg = "Same to you!"
    local outmsg = {type="debugresp", message="A msgpack response from the server!"}
    print("TO[" .. host .. ", " .. port .. "]: " .. outmsg.type .. ", " .. outmsg.message)
    local outdata = msgpack.pack(outmsg)
    local ok,err = udp:sendto(outdata, host,port)
    if not ok then 
      print("SEND FAILED: data="..data.." host="..host.." port="..port.." err="..tostring(err)) 
    end
  end
  socket.sleep(0.01)
end
 
