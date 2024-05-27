local patch = {
  name = "estrogen:estrogen_patches",
  toSlot = 36,
  fromSlot = 36,
  count = 1,
}

local function toggle(int,side)
  if int.getOutput(side) then
    int.setOutput(side,false)
  else
    int.setOutput(side,true)
  end
end

local rsi = {
  peripheral.wrap("redstoneIntegrator_17"),
}

local users = {
  Saithe6 = {
    manager = peripheral.wrap("inventoryManager_4"),
    toggle = function()
      toggle(rsi[1],"right")
    end
  }
}

local function extract(user)
  patch.toSlot = 0
  user.manager.removeItemFromPlayer("back",patch)
  patch.toSlot = 36
  user.toggle()
end

local function retrieve(user)
  patch.fromSlot = 0
  user.manager.addItemToPlayer("back",patch)
  patch.fromSlot = 36
  user.toggle()
end

local function checkUsers(user)
  for k,v in pairs(users) do
    if k == user then return true end
  end
  return false
end

local function readChat()
  local chat = peripheral.wrap("left")
  local event,sender,msg,uuid,isHidden
  repeat
    event,sender,msg,uuid,isHidden = os.pullEvent("chat")
  until checkUsers(sender) and isHidden and msg == "estrogen"
  return sender
end

local function main()
  while true do
    local user = users[readChat()]
    extract(user)
    sleep(2)
    retrieve(user)
  end
end
main()
