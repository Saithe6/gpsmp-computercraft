chatbox = peripheral.find("chatBox")

local system = "Saithe6"
local alters = {
  {
    name = "Saithe",
    proxy = "sai",
    pronouns = "she/her",
    appendPronouns = true
  },
  {
    name = "Bailyth",
    proxy = "bai",
    pronouns = "he/que",
    appendPronouns = true
  },
  {
    name = "Xasa",
    proxy = "xa",
    pronouns = "she/her",
    appendPronouns = true
  }
}

local function readChat()
  local event,sender,message,uuid,isHidden
  repeat
    event,sender,message,uuid,isHidden = os.pullEvent("chat")
  until isHidden == true and sender == system
  return message
end

local function decode(rawMsg)
  local tProxy = {}
  for i = 1,#rawMsg do
    if string.sub(rawMsg,i,i) == " " then
      break
    else
      tProxy[i] = string.sub(rawMsg,i,i)
    end
  end
  local proxy = string.lower(table.concat(tProxy))
  local msg = string.sub(rawMsg,#proxy+1)
  return proxy,msg
end

local function proxyLookup()
  local proxList = {}
  for i,alter in ipairs(alters) do
    proxList[alter.proxy] = i
  end
  return proxList
end

local function nameCheck(alter,pronouns)
  if pronouns then
    return alter.name.." "..alter.pronouns
  else
    return alter.name
  end
end

while true do
  local proxy,message = decode(readChat())
  local proxList = proxyLookup()
  local alter = alters[proxList[proxy]]
  local namePrns = nameCheck(alter,alter.appendPronouns)
  chatbox.sendMessage(message,namePrns,"<>")
end