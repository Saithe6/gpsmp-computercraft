local redlib = require("libs/redlib")
local chatbox = peripheral.wrap("left")

local function dropDoor(integrator,side)
  redlib.pulse(side,.1,.05,"~",integrator)
end

local function userLookup(username)
  local users = {
    Saithe6 = function() dropDoor(peripheral.wrap("top"),"top") end
  }
  if users[username] == nil then return end
  users[username]()
end

local function readChat()
  local event,username,message,uuid,hidden =  os.pullEvent("chat")
  if hidden and message == "e" then userLookup(username) end
end

while true do
  readChat()
end
