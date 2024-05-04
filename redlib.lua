redlib = {}

function redlib.pulse(side,hold,delay,strength,integrator)
  if hold == nil or hold == "~" then hold = .05 end
  if delay == nil or delay == "~" then delay = .05 end
  if integrator == nil then integrator = rs end

  if strength == nil or strength == "~" then
    integrator.setOutput(side, true)
    sleep(hold)
    integrator.setOutput(side, false)
    sleep(delay)
  else
    integrator.setAnalogOutput(side, strength)
    sleep(hold)
    integrator.setAnalogOutput(side, 0)
    sleep(delay)
  end
end


function redlib.toggle(side)
  if rs.getOutput(side) == false then
    rs.setOutput(side, true)
  else
    rs.setOutput(side, false)
  end
end


-- this code is thanks to JackMacWindows
function redlib.forceState(state,...)
  local exceptions = {...}
  local sides = rs.getSides()
  for i, v in ipairs(sides) do
    local ok = true
    for _, w in ipairs(exceptions) do
      if v == w then
        ok = false
        break
      end
    end
    if ok then
      rs.setOutput(v, state)
    end
  end
end
-- function redlib.forceState(state, exceptions{...})
--   local sides = rs.getSides()
--   for i = 1, 6 do
--     rs.setOutput(sides[i], state)
--     rs.setOutput(exceptions[i], not state)
--   end
-- end
return redlib
