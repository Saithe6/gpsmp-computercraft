rednet.open("top")
-- os.pullEvent = os.pullEventRaw
local monitor = peripheral.find("monitor")
local speaker = peripheral.find("speaker")
local rsi = peripheral.find("redstoneIntegrator")

-- set to true to mirror all left/right code
local mirror = false
local authServer = 57

local function centered(msg)
  local x,y = monitor.getSize()
  local msglen = string.len(msg)
  monitor.clear()
  monitor.setCursorPos((x-msglen)/2+1,y/2)
  monitor.write(msg)
end

local function receive()
  local sender,msg
  repeat
    sender,msg = rednet.receive("saithe:authServer-response")
  until sender == authServer
  return msg
end

local function setrs(rside,state)
  local side1,side2 = "right","left"
  if mirror then
    side1 = "left"
    side2 = "right"
  end
  local rsides = {
    gate = function()
      if state == nil then state = not rs.getOutput(side1) end
      rs.setOutput(side1,state)
    end,
    exterior = function()
      if state == nil then state = not rsi.getOutput("front") end
      rsi.setOutput("front",state)
    end,
    terminal = function()
      if state == nil then state = not rsi.getOutput(side2) end
      rsi.setOutput(side2,state)
    end
  }
  rsides[rside]()
end

local function main()
  local gate,exterior,terminal = "gate","exterior","terminal"
  local gateRequest = {
    type = "securityGate",
    data = {
      authLevel = 1,
      box = {
        {
          x = 408,
          y = 74,
          z = 853
        },
        {
          x = 410,
          y = 76,
          z = 846
        }
      }
    }
  }
  monitor.setTextScale(.5)

  local function promptPassword()
    speaker.playSound("create:deny")
    setrs(terminal,true)
    term.clear()
    term.setCursorPos(1,1)
    print("password is needed for level "..gateRequest.data.authLevel.." access")
    term.write("password: ")
    local input = read("*")
    setrs(terminal,false)
    return input
  end

  local function allow()
    monitor.setBackgroundColor(colors.green)
    monitor.setTextColor(colors.white)
    centered("welcome!!")
    speaker.playSound("vampirism:task_complete")
    setrs(gate,true)
    sleep(4)
    setrs(gate,false)
    sleep(1)
    setrs(exterior,false)
  end

  local function disallow()
    sleep(.5)
    monitor.setBackgroundColor(colors.red)
    monitor.setTextColor(colors.white)
    centered("denied")
    speaker.playSound("born_in_chaos_v1:fallen_step")
    setrs(exterior,false)
    sleep(1.5)
  end

  while true do
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.white)
    centered("awaiting...")
    os.pullEvent("monitor_touch")
    setrs(exterior,true)
    sleep(2)
    rednet.send(authServer,gateRequest,"saithe:authServer-request")
    local verdict = receive()
    if verdict == "password" then
      rednet.send(authServer,promptPassword(),"saithe:authServer-password")
      verdict = receive()
    end
    if verdict then allow() else disallow() end
  end
end
main()
