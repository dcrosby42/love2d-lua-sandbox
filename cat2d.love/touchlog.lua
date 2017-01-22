local Debug = require 'mydebug'
local socket = require "socket"

-- the address and port of the server
local address, port = "192.168.1.124", 12345


local udp

local function setup(game,opts)
  if not opts then opts = {} end

  udp = socket.udp()
  udp:settimeout(0)
  udp:setpeername(address,port)


end

local function update(game,opts)
  -- IN FROM SERVER
  local data
  repeat
    data, err = udp:receive()
    if data then
      Debug.println("FROM SERVER: "..data)
    end
  until not data

  -- OUT TO SERVER
  for id,t in pairs(game.touches) do
    if t.elapsed == 0 then
      Debug.println("hi from touchlog")
      udp:send("hi from touchlog")
    end
  end
end

return {
  setup = setup,
  update = update
}
