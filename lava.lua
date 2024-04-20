current = turtle.getFuelLevel()
print(current)
max = turtle.getFuelLimit()
print(max)
turtle.suckUp()
turtle.refuel()
for i = current,max,1000 do
  turtle.placeDown()
  turtle.refuel()
  sleep(.05)
end
turtle.dropUp()