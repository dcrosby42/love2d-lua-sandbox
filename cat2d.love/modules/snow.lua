require 'ecs/ecshelpers'
local Estore = require 'ecs/estore'

require 'flags'
require 'comps'

local iconAdderSystem = require 'systems/iconadder'
local timerSystem = require 'systems/timer'
local snowSystem = require 'systems/snow'
local drawSystem = require 'systems/drawstuff'
local Etree = require 'ecs/entitytree'

-- resource name shortcuts
local catIcon = "images/black-cat-icon.png"
local arcticCatTitle = "images/arctic_cat_title.png"

local DoUpdate = iterateFuncs({
  timerSystem,
  snowSystem,
  iconAdderSystem,
  Etree.etreeSystem,
})

local DoDraw = iterateFuncs({
  drawSystem,
})

local M ={}

local newSnowScene

M.newWorld = function()
  local w = {
    bgcolor = {0,0,100},
    scene = newSnowScene(),
    input = { dt=0, events={} },
    resources = {
      images={
        [catIcon] = love.graphics.newImage(catIcon),
        [arcticCatTitle] = love.graphics.newImage(arcticCatTitle),
      },
      fonts={
        ["Adventure-50"] = love.graphics.newFont("fonts/Adventure.ttf",50),
        ["Adventure-100"] = love.graphics.newFont("fonts/Adventure.ttf",100),
        ["AdventureOutline-50"] = love.graphics.newFont("fonts/Adventure Outline.ttf",50),
        ["narpassword-medium"] = love.graphics.newFont("fonts/narpassword.ttf",30),
      }
    },
  }

  return w, nil
end

M.updateWorld = function(world, action)
  local effects = nil

  if action.type == 'tick' then
    world.input.dt = action.dt

    local estore = world.scene
    DoUpdate(estore, world.input, world.resources)

    world.input.events = {}

  elseif action.type == 'mouse' then
    if action.button == 1 then
      if action.state == "pressed" then
        addInputEvent(world.input, {type='tap', id='p1', x=action.x, y=action.y})
      end
    elseif action.button == 2 then
      if action.state == "pressed" then
        addInputEvent(world.input, {type='untap', id='p1', x=action.x, y=action.y})
      end
    end

  elseif action.type == 'keyboard' then
    local estore = world.scene
    local key = action.key
    if key == "p" then
      print("============================================================================")
      print(estore:debugString())
    elseif key == "g" then
      if estore.etree then
        print("============================================================================")
        print("-- Entity tree (Estore.etree):")
        print(tdebug(estore.etree.ROOT))
      end
    elseif key == "x" then
      effects = {
        {type='exit'}
      }
    end

  end

  return world, effects
end

M.drawWorld = function(world)
  love.graphics.setBackgroundColor(unpack(world.bgcolor))

  DoDraw(world.scene, nil, world.resources)
end

-- ---------------------------------------------------------------
function newSnowScene()
  local estore = Estore:new()
  local group = buildEntity(estore, {
    {'tag', {name='snowScene'}},
    {'filter', {bits = bit32.bor(Flags.Update, Flags.Draw)}},
  })

  buildEntity(estore, {
    {'iconAdder', {id='p1', imgId=catIcon, tagName='cattish'}},
    {'parent', {parentEid=group.eid}},
  })

  buildEntity(estore, {
    {'snowmachine', {large=2,small=1}},
    {'vel', {dx=0, dy=15}},
    {'bounds', {x=0,y=0, w=love.graphics.getWidth(), h=love.graphics.getHeight()}},
    {'timer', {name='flake', reset=0.2, loop=true}},
    {'timer', {name='acc', countDown=false}},
    {'parent', {parentEid=group.eid, order=1}},
  })

  buildEntity(estore, {
    {'snowmachine', {large=3,small=1}},
    {'vel', {dx=0, dy=30}},
    {'bounds', {x=0,y=0, w=love.graphics.getWidth(), h=love.graphics.getHeight()}},
    {'timer', {name='flake', reset=0.2, loop=true}},
    {'timer', {name='acc', countDown=false}},
    {'parent', {parentEid=group.eid, order=2}},
  })

  local menu = buildMenu(estore)
  setParentEntity(estore, menu, group, 3)

  buildEntity(estore, {
    {'snowmachine', {large=5, small=3}},
    {'vel', {dx=0, dy=60}},
    {'bounds', {x=0,y=0, w=love.graphics.getWidth(), h=love.graphics.getHeight()}},
    {'timer', {name='flake', reset=0.2, loop=true}},
    {'timer', {name='acc', countDown=false}},
    {'parent', {parentEid=group.eid, order=4}},
  })

  estore:updateEntityTree()
  return estore
end

local ColdBlue = {36,153,204}
local ColdBlue_Bright = {86,203,254}

function buildMenu(estore)
  local menu = buildEntity(estore, {
    {'tag', {name='menu'}},
  })

  local y = 170
  buildEntity(estore, {
    {'label', {text='Arctic Cat', font="Adventure-100", color=ColdBlue, maxWidth=800, align='center'}},
    {'pos', {x=0, y=y}},
    {'parent', {parentEid=menu.eid, order=2}}
  })
  y = y + 120
  buildEntity(estore, {
    {'label', {text='START', font="narpassword-medium", color=ColdBlue, maxWidth=800, align='center'}},
    {'pos', {x=0, y=y}},
    {'parent', {parentEid=menu.eid, order=2}}
  })
  y = y + 50
  buildEntity(estore, {
    {'label', {text='CONTINUE', font="narpassword-medium", color=ColdBlue_Bright, maxWidth=800, align='center'}},
    {'pos', {x=0, y=y}},
    {'parent', {parentEid=menu.eid, order=2}}
  })

  return menu
end

return M
