local client = {
  host=enet.host_create(), --unbound (meaning it cannot be connect to) host object (self)
  server=nil, --peer object that it is connect to
  id=nil, --unique id of the client's player game object
  objects = {} --client-side objects list to draw graphics, interpret inputs and provide instant feedback with
}
local player = nil --is updated to refer to the client's player

local function processOrder(order) --orders are recieved from the server and each have a type
  local type = order.type
  if type=='setID' then client.id = order.id end
  if type=='setObjects' then client.objects = order.objects end
  if type=='addObject' then client.objects[#client.objects+1] = order.object end
  if type=='moveObj' then client.objects[order.id].pos = client.objects[order.id].pos+VecTab(order.vec) end
end
local function request(type,data)
  local request = data or {}
  request.type = type
  client.server:send(bitser.dumps(request))
end
local function getEvents() --Recieve and process all events
  local event = client.host:service()
  while event do
    if event.type == 'connect' then print('Client: ','Successfully connected to ',event.peer) end
    if event.type == 'disconnect' then print('Client: ','Disconnected from ',event.peer) end
    if event.type == 'receive' then
      local data = bitser.loads(event.data)
      if data.type~='multi' then processOrder(data)
      else
        for i,order in ipairs(data) do processOrder(order) end
      end
    end
    event = client.host:service() --get new event (nil if there are no new events)
  end
end

function client.connect(address) client.server = client.host:connect(address) end
local moveDirs = {w=Vec(0,-1),a=Vec(-1,0),s=Vec(0,1),d=Vec(1,0)}
function client.update(dt) --Called before main game updates
  getEvents()
  if client.id then player = client.objects[client.id] end
  if player then
    local vec = Vec()
    for k,v in pairs(moveDirs) do
      if love.keyboard.isDown(k) then vec = vec+v*5 end
    end
    if vec~=Vec() then request('moveObj',{vec=vec,id=client.id}) end
  end
  --Client logs
  debug.log('#Client Objects',#client.objects)
end
function client.draw()
  for i,obj in ipairs(client.objects) do
    love.graphics.circle('fill',obj.pos.x,obj.pos.y,10)
  end
end

return client
