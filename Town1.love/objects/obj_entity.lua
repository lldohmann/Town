local Object = require 'libraries.classic'
local bump = require 'libraries.bump'
local Entity = Object:extend()

function Entity:new(world, x, y, npc, wall, warp)
	self.world = world
	self.x = x
	self.y = y 
	self.isNpc = npc or false
	self.isWall = wall or false
	self.isWarp = warp or false

	self.world:add(self, self.x, self.y, 16, 16)
end

function Entity:destroy()
	self.world:remove(self)
end

return Entity