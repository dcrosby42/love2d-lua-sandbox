package.path = package.path .. ';../cat2d.love/?.lua'
local socket = require "socket"
require "helpers"
-- local msgpack = require "vendor/msgpack"
-- local conn = require 'conn'
local Server = require 'msgserver'
 
local PORT = 12345
local LOOP_DELAY = 0.01

local server = Server:new("*", PORT)
 
local running = true

 
print("UDP server bound to "..PORT)
while running do
  local msg, host, port, err = server:receive_from()
  if msg then
    print("FROM[" .. host .. ", " .. port .. "]: " .. flattenTable(msg))

    local outmsg = {type="debugresp", message="A msgpack response from the server!"}
    print("TO[" .. host .. ", " .. port .. "]: " .. outmsg.type .. ", " .. outmsg.message)
    -- local outdata = msgpack.pack(outmsg)
    -- local ok,err = udp:sendto(outdata, host,port)
    local ok, err = server:send_to(outmsg, host, port)
    if not ok then 
      print("SEND FAILED: data="..data.." host="..host.." port="..port.." err="..tostring(err)) 
    end
  end
  server:sleep(LOOP_DELAY)
end
 
-- while running do
--   local data, host, port = udp:receivefrom()
--   if data then
--     local msg = msgpack.unpack(data)
--     print("FROM[" .. host .. ", " .. port .. "]: " .. msg.type .. ", " .. msg.message)
--
--
--     -- local outmsg = "Same to you!"
--     local outmsg = {type="debugresp", message="A msgpack response from the server!"}
--     print("TO[" .. host .. ", " .. port .. "]: " .. outmsg.type .. ", " .. outmsg.message)
--     local outdata = msgpack.pack(outmsg)
--     local ok,err = udp:sendto(outdata, host,port)
--     if not ok then 
--       print("SEND FAILED: data="..data.." host="..host.." port="..port.." err="..tostring(err)) 
--     end
--   end
--   conn.sleep(LOOP_DELAY)
-- end
--  
