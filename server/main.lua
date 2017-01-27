package.path = package.path .. ';../cat2d.love/?.lua'
local socket = require "socket"
require "helpers"
-- local msgpack = require "vendor/msgpack"
-- local conn = require 'conn'
local Server = require 'msgserver'
local Packet = require 'packet'
 
local PORT = 12345
local LOOP_DELAY = 0.01

local PING_TIMER = 2
local CLIENT_IDLE_THRESH = 5
local CLIENT_IDLE_MAX = CLIENT_IDLE_THRESH + (3 * PING_TIMER)

local server = Server:new("*", PORT)
 
local running = true

local clientIdCounter = os.time()
local clients = {}
local clientsByHost = {}

local function removeClient(client)
  clientsByHost[client.host][client.port] = nil
  clients[client.clientId] = nil
end
 
print("UDP server bound to "..PORT)
while running do
  local t = socket.gettime()

  local packet, host, port, err = server:receive_from()
  if packet then
    local type = packet[1]
    if type == Packet.SIGN_IN then 
      -- handshake / new client
      local clientId = clientIdCounter
      clientIdCounter = clientIdCounter + 1
      local client = {
        host = host,
        port = port,
        clientId = clientId,
        signIn = t,
        lastSeen = t,
        lastPinged = 0
      }
      clients[clientId] = client
      bh = clientsByHost[host]
      if not bh then
        bh = {}
        clientsByHost[host] = bh
      end
      bh[port] = client

      print(tostring(t) .. " - Client["..clientId.."] - SIGNED_IN")
      server:send_to({Packet.SIGNED_IN, clientId}, client.host, client.port)

    else
      bh = clientsByHost[host]
      if bh and bh[port] then
        local client = bh[port]
        client.lastSeen = t
        if type == Packet.PING then
          print(tostring(t) .. " - Client[".. client.clientId .."] - ping'd, ponging..")
          server:send_to({Packet.PONG}, client.host, client.port)
        elseif type == Packet.PING then
          print(tostring(t) .. " - Client[".. client.clientId .."] - pong.")
        elseif type == Packet.QUIT then
          print(tostring(t) .. " - Client[".. client.clientId .."] - quit.")
          removeClient(client)
        end
      else
        -- client isn't properly signed in
      end

    end
  end

  for clientId, client in pairs(clients) do
    local idle = (t - client.lastSeen)
    if idle > CLIENT_IDLE_MAX then
      print(tostring(t) .. " - Client["..clientId.."] - idled out, removing client.")
      removeClient(client)

    elseif idle > CLIENT_IDLE_THRESH then
      if (t - client.lastPinged) > PING_TIMER then
        print(tostring(t) .. " - Client["..clientId.."] - idling, sending PING.")
        server:send_to({Packet.PING}, client.host, client.port)
        client.lastPinged = t
      end
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
