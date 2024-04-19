tor = {}
tor.blacklist = {
  mods = {
    "computercraft",
    "create",
    "advancedperipherals",
    "cccbridge",
    "vampirism",
    "fantasyfurniture",
    "farmersdelight",
    "minecolonies",
    "mcwfences",
    "domum_ornamentum",
    "estrogen",
    "structurize",
    "mcwwindows",
    "sophisticatedstorage",
    "sophisticatedbackpacks",
    "railways",
    "nethersdelight",
    "supplementaries",
    "create_enchantment_industry",
    "rats",
    "toms_storage",
    "morevillagers",
    "mna"
  },
  overrides = {
    "create:zinc_ore",
    "create:raw_zinc_block",
    "create:deepslate_zinc_ore",
    "create:asurine",
    "create:crimsite",
    "create:limestone",
    "create:ochrum",
    "create:scoria",
    "create:scorchia",
    "create:veridium",
    "mna:vinteum_ore"
  },
  types = {
    "chest",
    "barrel",
    "table",
    "bedrock"
  }
}
tor.data = {
  home = {
    x = 0,
    y = 0,
    z = 0
  },
  facing = "south"
}
tor.toolSide = "left"

function tor.move(dist,dir,mine)
  if mine then
    for i = 1,dist do
      print(turtle.getFuelLevel())
      tor.tryMove(dir)
    end
  else
    for i = 1,dist do
      if turtle.getFuelLevel() == 0 then print("Out of Fuel") else
        print(turtle.getFuelLevel())
        turtle[dir]()
      end
    end
  end
  return false
end

function tor.tryMove(dir)
  print("trying...")
  if turtle.getFuelLevel() == 0 then print("Out of Fuel")
  elseif not turtle[dir]() then
    print("checking path...")
    if not tor.checkPath(dir) then
      tor.tryMove(dir)
    end
  end
end

function tor.detect(dir)
  local isBlock = false
  local block = {}
  if dir == "up" then
    isBlock,block = turtle.inspectUp()
  elseif dir == "down" then
    isBlock,block = turtle.inspectDown()
  else
    isBlock,block = turtle.inspect()
  end
  return block,isBlock
end

function tor.checkPath(dir)
  local block,isBlock = tor.detect(dir)
  if block.name == nil then isBlock = false else print("good") end
  print(isBlock)
  if isBlock ~= false then
    if not tor.checkBlacklist(block.name) then
      if dir == "up" then
        turtle.digUp(tor.toolSide)
      elseif dir == "down" then
        turtle.digDown(tor.toolSide)
      else
        turtle.dig(tor.toolSide)
      end
    end
    return tor.checkBlacklist(block.name)
  end
  return true
end

local function checkTypes(block)
  for i,v in ipairs(tor.blacklist.types) do
    if string.find(block,v) ~= nil then return true end
  end
  return false
end

local function checkOverrides(block)
  for i,v in ipairs(tor.blacklist.overrides) do
    if block == v then return false end
  end
  return true
end

local function checkMods(block)
  if block ~= nil then
    for i,v in ipairs(tor.blacklist.mods) do
      local blockMod = v..":"
      if string.find(block,blockMod) ~= nil then return checkOverrides(block) end
    end
  end
  return false
end

function tor.checkBlacklist(block) return checkMods(block) or checkTypes(block) end


function tor.changeDir(turn)
  local facings = {
    north = {
      right = "east",
      left = "west"
    },
    east = {
      right = "south",
      left = "north"
    },
    south = {
      right = "west",
      left = "east"
    },
    west = {
      right = "north",
      left = "south"
    }
  }
  tor.data.facing = facings[tor.data.facing][turn]
end

function tor.turn(dir)
  if dir == "left" then
    turtle.turnLeft()
    tor.changeDir(dir)
  elseif dir == "right" then
    turtle.turnRight()
    tor.changeDir(dir)
  end
end

function tor.track(x,y,z)
  tor.data.home.x = tor.data.home.x - x
  tor.data.home.y = tor.data.home.y - y
  tor.data.home.z = tor.data.home.z - z
end

function tor.toRelative(absVec)
  local relVec = {y = absVec.y}
  local facing = tor.data.facing
  if facing == "north" then
    relVec.f = -absVec.z
    relVec.l = absVec.x
  elseif facing == "east" then
    relVec.f = absVec.x
    relVec.l = absVec.z
  elseif facing == "west" then
    relVec.f = -absVec.x
    relVec.l = -absVec.z
  else
    relVec.f = absVec.z
    relVec.l = -absVec.x
  end
  return relVec
end

function tor.vecMove(v,mine)
  if v.y > 0 then
    tor.move(v.y,"up",mine)
  elseif v.y < 0 then
    tor.move(math.abs(v.y),"down",mine)
  end

  if v.f > 0 then
    tor.move(v.f,"forward",mine)
  elseif v.f < 0 then
    tor.turn("left")
    tor.turn("left")
    v.l = -v.l
    tor.move(math.abs(v.f),"forward",mine)
  end

  if v.l > 0 then
    tor.turn("left")
    tor.move(v.l,"forward",mine)
  elseif v.l < 0 then
    tor.turn("right")
    tor.move(math.abs(v.l),"forward",mine)
  end
end

local function directMove(instruction,mine)
  local dir = string.sub(instruction,-1,-1)
  local dist = tonumber(string.sub(instruction,1,-2))
  local moves = {}

  function moves.f()
    if dist < 0 then
      tor.turn("left")
      tor.turn("left")
      dist = math.abs(dist)
    end
    tor.move(dist,"forward",mine)
  end
  
  function moves.l()
    if dist < 0 then
      tor.turn("right")
    else
      tor.turn("left")
    end
    tor.move(math.abs(dist),"forward",mine)
  end

  function moves.y()
    if dist < 0 then
      dir = "down"
    else
      dir = "up"
    end
    tor.move(math.abs(dist),dir,mine)
  end

  function moves.z()
    if dist < 0 then
      tor.orient("north")
      tor.move(math.abs(dist),"forward",mine)
    else
      tor.orient("south")
      tor.move(math.abs(dist),"forward",mine)
    end
  end

  function moves.x()
    if dist < 0 then
      tor.orient("west")
      tor.move(math.abs(dist),"forward",mine)
    else
      tor.orient("east")
      tor.move(math.abs(dist),"forward",mine)
    end
  end
  moves[dir]()
end

function tor.orient(goal)
  local instructions = {
    north = {
      east = "right",
      west = "left",
      south = "reverse"
    },
    east = {
      south = "right",
      north = "left",
      west = "reverse"
    },
    south = {
      west = "right",
      east = "left",
      north = "reverse"
    },
    west = {
      north = "right",
      south = "left",
      east = "reverse"
    }
  }
  local operation = instructions[tor.data.facing][goal]
  if operation == "reverse" then
    tor.turn("left")
    tor.turn("left")
  else
    tor.turn(operation)
  end
end

return tor
