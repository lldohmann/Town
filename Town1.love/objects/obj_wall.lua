local Entity = require 'objects.obj_entity'

local Wall = Entity:extend()
Wall:implement(destroy)

function Wall:new(world, x, y)
	Wall.super.new(self, world, x, y, false, true)
end

function Wall:update(dt)
end

function Wall:draw()
	if debug then
		love.graphics.rectangle('line', self.x, self.y, 16, 16)
	end
end

return Wall