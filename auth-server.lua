rednet.open("top")
local detector = peripheral.wrap("left")
local rootPass = "root"
local adminPass = "admin"

local function checkPerms(user,authLevel)
  local permissions = {
    Saithe6 = 0,
    haydeniscold = 2,
  }
  userAuthLevel = permissions[user] or 3
  if userAuthLevel <= authLevel then return true end
  return false
end

local function hasAuthUser(users,authLevel,unauth)
  if users == nil then error("nil users table in hasPermittedUser") end
  unauth = unauth or false
  if unauth then
    for _,v in ipairs(users) do
      if not checkPerms(v,authLevel) then return true end
    end
  else
    for _,v in ipairs(users) do
      if checkPerms(v,authLevel) then return true end
    end
  end
  return false
end

local function filteredReceive(authorizedSender)
  local sender,msg
  repeat
    sender,msg = rednet.receive("saithe:authServer-password")
  until sender == authorizedSender
  return msg
end

local function doorAuth(users,authLevel,proxId)
  local hasAuth = hasAuthUser(users,authLevel)
  local hasOther = hasAuthUser(users,3,true)
  if hasAuth and not hasOther then
    return true
  elseif hasAuth and hasOther then
    local input = filteredReceive(proxId)
    if authLevel == 0 then
      return input == rootPass
    else
      return input == adminPass or input == rootPass
    end
  elseif not hasAuth then
    return false
  end
end

local function main()
  while true do
    local proxy,proxData = rednet.receive("saithe:authServer-request")
    local users = detector.getPlayersInCoords(proxData.box[1],proxData.box[2])
    rednet.send(proxy,doorAuth(users,proxData.authLevel),"saithe:authServer-response")
  end
end
main()
