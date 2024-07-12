rednet.open("top")
local detector = peripheral.wrap("left")
local rootPass = "root"
local adminPass = "admin"

local function checkPerms(user,authLevel)
  local permissions = {
    Saithe6 = 0,
    haydeniscold = 2,
  }
  local userAuthLevel = permissions[user] or 3
  if userAuthLevel <= authLevel then return true end
  return false
end

local function hasAuthUser(users,authLevel,unauth)
  if users == nil then error("nil users table in hasPermittedUser") end
  unauth = unauth or false
  if unauth then
    for _,v in ipairs(users) do
      if not checkPerms(v,authLevel) then
        return true end
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
  local logfile = fs.open("/logs/"..logfile..".txt","a")
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
  local hasOther = hasAuthUser(users,2,true)
  local logfile = "errbin"
  local authorized = false
  local details
  if hasAuth and not hasOther then
    logfile = "authorized"
    authorized = true
  elseif hasAuth and hasOther then
    logfile = "password"
    rednet.send(proxId,"password","saithe:authServer-response")
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
  return authorized
end

local function main()
  local requestTypes = {
    securityGate = function(proxy,gateData)
      local users = detector.getPlayersInCoords(gateData.box[1],gateData.box[2])
      return doorAuth(users,gateData.authLevel,proxy)
    end,
  }

  local function foundError(proxId,request)
    local function errlog(errmsg)
      local logfile = fs.open("logs/errlog.txt","a")
      local timeStamp = textutils.formatTime(os.time("utc"))
      local requestText = textutils.serialize(request)
      local n = "\n"
      local output =
        timeStamp..n..
        proxId..": "..errmsg..n..
        requestText..n..n
      logfile.write(output)
    end

    local function isValidType(type)
      for k,_ in pairs(requestTypes) do
        if k == type then return true end
      end
      return false
    end

    if type(request) ~= "table"then
      errlog("no request table")
      rednet.send(proxId,"err","saithe:authServer-response")
    end
    if not isValidType(request.type) then
      errlog("invalid request type")
      rednet.send(proxId,"err","saithe:authServer-response")
    end
  end

  while true do
    local proxId,request = rednet.receive("saithe:authServer-request")
    if foundError(proxId,request) then os.reboot() end
    local verdict = requestTypes[request.type](proxId,request.data)
    rednet.send(proxId,verdict,"saithe:authServer-response")
  end
end
main()
