local Debug = require 'mydebug'

-- local conn = require 'conn'
local Client = require 'msgclient'

local client
local function setup(game,opts)
  -- udp = conn.udp_client(opts.host, opts.port)
  client = Client:new(opts.host, opts.port)
end

local function update(game,opts)
  if client then
    -- IN FROM SERVER
    msgs = client:receive_many()
    if #msgs > 0 then
      for _,msg in ipairs(msgs) do
        Debug.println("FROM SERVER: " .. msg.type .. "," .. msg.message)
      end
    end

    -- OUT TO SERVER
    for id,t in pairs(game.touches) do
      if t.elapsed == 0 then
        local toMsg = { type='debug', message="Dude this is the msg." }
        ok, err = client:send(toMsg)
        if not ok then
          Debug.println("Failed to send msg: "..err)
        end
      end
    end
  end
end

return {
  setup = setup,
  update = update
}
