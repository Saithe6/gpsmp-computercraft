local tor = require("libs/tortise")
local tArgs = {...}


local function volume()
  local vol
  local vDir
  if tArgs[3] ~= nil then
    vol = tonumber(string.sub(tArgs[3],1,-2))
    vDir = string.sub(tArgs[3],-1,-1)
  end

  local layers = tonumber(string.sub(tArgs[2],1,-2))
  local lDir = string.sub(tArgs[2],-1,-1)

  local dist = tonumber(string.sub(tArgs[1],1,-2))
  local dir = string.sub(tArgs[1],-1,-1)

  local function layer()
    if dir == "y" and dist < 0 then
    elseif dir == "y" then
    else
      tor.directMove(tArgs[1],true)
      local turn = 1
      if dist >= 0 then
        turn = -1
      end
      dist = math.abs(dist)
      for i = 1,math.abs(layers) do
        if lDir == "y" then
          if layers < 0 then
            tor.directMove("-1y",true)
          else
            tor.directMove("1y",true)
          end
          tor.directMove("-"..dist.."f",true)
        elseif lDir == "f" then
          tor.directMove(turn.."l",true)
          tor.directMove(turn*dist.."l",true)
          turn = -turn
        end
      end
    end
  end

  if vDir == nil then
    layer()
  else
    layer()
    for i = 1,math.abs(vol) do
      if vDir == "f" then
        layers = -layers
        if math.abs(layers)%2 == 0 then
          tor.directMove("-1l",true)
        else
          tor.directMove("1l",true)
        end
      elseif vDir == "y" and vol < 0 then
        tor.directMove("0l")
        tor.directMove("0l")
        tor.directMove("-1y",true)
      elseif vDir == "y" then
        layers = -layers
        tor.directMove("1y",true)
      end
      layer()
    end
  end
end

local function main()
  if #tArgs == 0 then
    print("error: no arguments")
  else
    if tArgs[1] == "f" then
      tor.directMove("1f",true)
      table.remove(tArgs,1)
    elseif tArgs[1] == "y" then
      tor.directMove("1y",true)
      table.remove(tArgs,1)
    elseif tArgs[1] == "-y" then
      tor.directMove("-1y",true)
      table.remove(tArgs,1)
    end
    volume()
  end
end
main()
