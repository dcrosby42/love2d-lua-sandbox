local Debug = require 'mydebug'
local Packet = require 'packet'

SERVER_IDLE_MAX = 7

-- local conn = require 'conn'
local Client = require 'msgclient'

local client
local function setup(game,opts)
  client = Client:new(opts.host, opts.port)
  game.conn = {
    serverHost = opts.host,
    serverPort = opts.port,
    lastHeardServer = 0,
    clientId = 0,
    signInTimer = 0,
    pingTimer = 0,
  }
end

local function teardown(game)
  if client then
    client:send({Packet.QUIT})
    client:close()
  end
end

local SIGN_IN_TIMER = 2
local PING_TIMER = 3

local function maintainConnection(messages, s, dt, t)
  if #messages > 0 then s.lastHeardServer = t end

  for _,msg in ipairs(messages) do
    local type = msg[1]

    if type == Packet.PONG then
      Debug.println("Server: pong")
      s.pingTimer = PING_TIMER

    elseif type == Packet.PING then
      Debug.println("Server: ping'd us")
      client:send({Packet.PONG})
      s.pingTimer = PING_TIMER
      
    elseif type == Packet.SIGNED_IN then
      s.clientId = msg[2]
      s.signInTimer = 0
      Debug.println("Server: signed in, clientId="..s.clientId)
    end
  end

  
  if s.clientId == 0 then
    -- Sign in
    s.signInTimer = s.signInTimer - dt
    if s.signInTimer <= 0 then
      client:send({Packet.SIGN_IN})
      s.signInTimer = SIGN_IN_TIMER
      Debug.println("Signing in...")
    end
  else
    if (t - s.lastHeardServer) > SERVER_IDLE_MAX then
      Debug.println("Server idled out.")
      s.clientId = 0
      s.signInTimer = 0
    else
      s.pingTimer = s.pingTimer - dt
      if s.pingTimer <= 0 then
        Debug.println("Pinging...")
        client:send({Packet.PING})
        s.pingTimer = PING_TIMER
      end
    end
  end
end

local function update(game,dt,input)
  if client then
    local conn = game.conn
    if conn then
      messages = client:receive_many()

      maintainConnection(messages,conn,dt, socket.gettime())
    end


    --
    -- -- OUT TO SERVER
    -- for id,t in pairs(game.touches) do
    --   if t.elapsed == 0 then
    --     -- local toMsg = { type='debug', message="Dude this is the msg." }
    --     -- ok, err = client:send(toMsg)
    --     local toMsg = {Packet.PING}
    --     ok, err = client:send(toMsg)
    --     if not ok then
    --       Debug.println("Failed to send msg: "..err)
    --     end
    --     print("sent: "..flattenTable(toMsg))
    --   end
    -- end
  end
end


return {
  setup = setup,
  teardown = teardown,
  update = update

}
