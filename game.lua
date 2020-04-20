local game = {objects={}}

function game.addObject(object)
  object.id = #game.objects + 1
  table.insert(game.objects,object)
  server.order('addObject',{object=object})
end

function game.update(dt)
  for i, obj in ipairs(game.objects) do
    if obj.vel then obj.pos = obj.pos + obj.vel end
    if obj.player then
      for j, objB in ipairs(game.objects) do
        if objB.bullet and objB.ownerID~=obj.id and objB.pos..obj.pos < 10 then
          server.clients[obj.clientID]:reset() --forcibly disconnect
          server.order('removeObject',{id=i})
          obj.trash = true
        end
      end
    end
  end
end

return game
