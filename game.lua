local game = {objects={}}

function game.addObject(object)
  object.id = #game.objects + 1
  table.insert(game.objects,object)
  server.order('addObject',{object=object})
end
function game.update(dt)

end

return game
