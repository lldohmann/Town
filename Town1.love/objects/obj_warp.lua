local Entity = require 'objects.obj_entity'

local Warp = Entity:extend()
Warp:implement(destroy)

function Warp:new(world, x, y, mapChange, player)
	Warp.super.new(self, world, x, y, false, false, true)
	self.mapChange = mapChange
	self.player = player
end

function Warp:update(dt)
end

function Warp:draw()
	if debug then
		love.graphics.setColor(0,0,255)
		love.graphics.rectangle('line', self.x, self.y, 16, 16)
		love.graphics.setColor(255,255,255)
	end
end

return Warp