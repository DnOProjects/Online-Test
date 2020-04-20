--Global classes
require 'class'
require 'vector'
--Global modules
debug, enet, bitser = require 'debugger', require 'enet', require 'bitser'
client, server = require 'client', require 'server'

local host = true --True: runs a server and a client; False: runs just a client
local ip = '192.168.0.4'

function love.load()
  if host then server.start(ip..':6789') end
  client.connect(ip..':6789')
end

function love.update(dt)
  debug.log('FPS',love.timer.getFPS())
  if host then server.update(dt) end --Gets clients' requests, runs the game, sends instructions to clients
  client.update(dt) --Gets server's instructions, sends requests to server
end

function love.draw()
  client.draw() --Draws the game from the client's incomplete store of game objects
  debug.draw()
end
