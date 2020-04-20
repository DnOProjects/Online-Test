local debugger = {}

local log = {}
function debugger.log(name,value) log[name] = value end
function debugger.draw()
  local i=0
  for k,v in pairs(log) do
    love.graphics.print(k..': '..tostring(v),0,20*i)
    i=i+1
  end
end

return debugger
