local socket = require "socket"
 
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
    print("FROM[" .. host .. ", " .. port .. "]: " .. data)

    local outmsg = "Same to you!"
    print("TO[" .. host .. ", " .. port .. "]: " .. outmsg)
    local ok,err = udp:sendto(outmsg, host,port)
    if not ok then 
      print("SEND FAILED: data="..data.." host="..host.." port="..port.." err="..tostring(err)) 
    end
  end
  socket.sleep(0.01)
end
 
