local Debug = require 'mydebug'
local socket = require "socket"
local msgpack = require 'vendor/msgpack'

-- the address and port of the server
local address, port = "192.168.1.124", 12345
-- local address, port = "10.1.1.1", 12345
-- local address, port = "107.155.66.22", 12345


local udp

local function setup(game,opts)
  if not opts then opts = {} end

  udp = socket.udp()
  udp:settimeout(0)
  udp:setpeername(address,port)
end

local function update(game,opts)
  if udp then
    -- IN FROM SERVER
    local data
    repeat
      data, err = udp:receive()
      if data then
        local msg = msgpack.unpack(data)
        Debug.println("FROM SERVER: "..msg.type .. "," .. msg.message)
      end
    until not data

    -- OUT TO SERVER
    for id,t in pairs(game.touches) do
      if t.elapsed == 0 then
        Debug.println("(sending msgpack msg to server...)")
        local toMsg = { type='debug', message="Dude this is the msg." }
        local data,err = msgpack.pack(toMsg)
        if err then
          Debug.println("Send failed: "..err)
        else
          local ok, err = pcall(function() udp:send(data) end)
          if not ok then
            print("udp:send failed: " .. err)
          end
        end
      end
    end
  end
end

return {
  setup = setup,
  update = update
}
