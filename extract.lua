local redlib = require("libs/redlib")
local chatbox = peripheral.wrap("left")

local function dropDoor(integrator,side)
  redlib.pulse(side,.1,.05,"~",integrator)
end

local function userLookup(username)
  local users = {
    Saithe6 = dropDoor(peripheral.wrap("top"),"top")
  }
  if users[username] == nil then return false end
  return users[username]
end

local function readChat()
  local event,username,message,uuid,hidden =  os.pullEvent("chat")
  if hidden and message == "e" and userLookup(username) then return userLookup(username) end
  return false
end

local function main()
  while true do
    local rSide = readChat()
    if rSide ~= false then
      redlib.pulse()
    end
  end
end
main()
