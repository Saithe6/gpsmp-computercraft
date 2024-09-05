local current = turtle.getFuelLevel()
print(current)
local max = turtle.getFuelLimit()
print(max)
turtle.suckUp()
turtle.refuel()
while current < max do
  turtle.placeDown()
  if turtle.refuel() then
    print(current)
  end
  sleep(.05)
  current = turtle.getFuelLevel()
end
turtle.dropUp()
