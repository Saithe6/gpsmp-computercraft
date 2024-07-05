rednet.open("top")
local authServer = 57
local proxData = {
  authLevel = 1,
  box = {
    {
      x = 415,
      y = 70,
      z = 786
    },
    {
      x = 410,
      y = 67,
      z = 781
    }
  }
}

local function receive()
  local sender,msg
  repeat
    sender,msg = rednet.receive("saithe:authServer-response")
  until sender == authServer
  return msg
end

local function promptPassword()
  term.clear()
  term.setCursorPos(1,1)
  print("password is needed for level "..proxData.authLevel.." access")
  term.write("password: ")
  return read("*")
end

local function main()
  local function allow()
    -- behavior upon successful authentication
  end
  local function disallow()
    -- behavior upon failed authentication
  end
  rednet.send(authServer,proxData,"saithe:authServer-request")
  local verdict = receive()
  if verdict == "password" then
    rednet.send(authServer,promptPassword(),"saithe:authServer-password")
    verdict = receive()
  end
  if verdict then allow() else disallow() end
end
main()
