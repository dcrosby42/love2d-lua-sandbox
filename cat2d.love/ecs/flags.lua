require 'helpers'

Flags = {
  Update = bit32.lshift(1, 0),
  Draw   = bit32.lshift(1, 1),
  Sound  = bit32.lshift(1, 2),

  None   = 0,
  All    = 0xffffffff, -- 32 bits
}

print(tdebug(Flags))
