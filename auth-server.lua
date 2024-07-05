rednet.open("top")
os.pullEvent = os.pullEventRaw
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

local function log(logfile,users,authLevel,proxId,details)
  logfile = fs.open("/logs/"..logfile..".txt","a")
  local timeStamp = textutils.formatTime(os.time("utc"))
  local userlist = textutils.serialize(users)
  local n = "\n"
  local output
  if details == nil then
    output =
      timeStamp..n..
      proxId.."/"..authLevel..n..
      userlist..n..n
  else
    output =
      timeStamp..n..
      proxId.."/"..authLevel..n..
      userlist..n..
      details..n..n
  end
  logfile.write(output)
end

local function doorAuth(users,authLevel,proxId)
  local hasAuth = hasAuthUser(users,authLevel)
  local hasOther = hasAuthUser(users,3,true)
  local logfile = "errbin"
  local authorized = false
  local details
  if hasAuth and not hasOther then
    logfile = "authorized"
    authorized = true
  elseif hasAuth and hasOther then
    logfile = "password"
    local input = filteredReceive(proxId)
    if authLevel == 0 then
      authorized = input == rootPass
    else
      authorized = input == adminPass or input == rootPass
    end
    details = authorized and "authorized" or "denied"
  elseif not hasAuth then
    logfile = "denied"
  end
  log(logfile,users,authLevel,proxId,details)
end

local function main()
  while true do
    local proxy,proxData = rednet.receive("saithe:authServer-request")
    local users = detector.getPlayersInCoords(proxData.box[1],proxData.box[2])
    rednet.send(proxy,doorAuth(users,proxData.authLevel),"saithe:authServer-response")
  end
end
main()
