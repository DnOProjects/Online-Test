local game = require 'game'

local server = {
  host=nil, --host object (self) bound to an address
  clients={} --to store the clients when they connect
}
local orders = nil
local function send(data,client) client:send(bitser.dumps(data)) end
local function broadcast() --Called after main game update, sends orders to all clients
  local serialisedOrders = bitser.dumps(orders)
  for i=1,#server.clients do server.clients[i]:send(serialisedOrders) end
end
local function getEvents() --Recieve and process all events
  local event = server.host:service()
  while event do
    if event.type == 'connect' then
      table.insert(server.clients,event.peer) --Add client
      send({type='setObjects',objects=game.objects},event.peer) --Send current objects to new client
      game.addObject({pos=Vec()})--Add new player object
      send({type='setID',id=#game.objects},event.peer) --Send the client's unique player id
      print('Server: ',event.peer, ' connected')
    end
    if event.type == 'disconnect' then
      --todo: remove from clients list
      print('Server: ',event.peer, ' disconnected')
    end
    if event.type == 'receive' then
      local data = bitser.loads(event.data)
      local requestType = data.type
      if requestType=='addObject' then
        local object = data.object
        for k,v in pairs(object) do
          if type(v)=="table" then object[k] = VecTab(v) end
        end
        game.addObject(object)
      end
      if requestType=='moveObj' then
        game.objects[data.id].pos = game.objects[data.id].pos+VecTab(data.vec)
        server.order(requestType,data)
      end
    end
    event = server.host:service() --get new event (nil if there are no new events)
  end
end

function server.start(address)
  server.host = enet.host_create(address)
  if server.host then print('Server: ','Started server at ',address)
  else print('Server: ','//COULD NOT START//') end
end
function server.order(orderType,data) --Called several times during main game update
  local data = data or {}
  data.type = orderType
  table.insert(orders,data)
end
function server.update(dt) --Called before main game updates
  --Server logs
  debug.log('#Game Objects',#game.objects)
  debug.log('#Clients',#server.clients)

  orders = {type="multi"} --clear orders
  getEvents() --get and process events and packets sent by clients and send orders
  game.update(dt) --process game logic and send orders
  broadcast() --send accumulated orders to all clients
end

return server
