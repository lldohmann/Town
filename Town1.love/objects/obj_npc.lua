local anim8 = require 'libraries.anim8'
local Entity = require 'objects.obj_entity'
local Timer = require 'libraries.timer'

local NPC = Entity:extend()
NPC:implement(destroy)

function NPC:new(world, x, y, dialog, still, spriteSheet, facing)
	NPC.super.new(self, world, x, y, true)

	self.dx = x
	self.dy = y

	self.still = still -- true if npc never moves
	
	self.moveSpeed = 25
	self.frameSpeed = .35

	local spriteSheet = spriteSheet or nil -- invisible npcs for those behind a wall
	if spriteSheet then
		self.image = love.graphics.newImage(spriteSheet)
		self.g = anim8.newGrid(16,16,self.image:getWidth(), self.image:getHeight())
		self.animation = {
			["down"] = anim8.newAnimation(self.g('1-2', 1), self.frameSpeed),
			["right"] = anim8.newAnimation(self.g('1-2', 2), self.frameSpeed),
			["left"] = anim8.newAnimation(self.g('1-2', 3), self.frameSpeed),
			["up"] = anim8.newAnimation(self.g('1-2', 4), self.frameSpeed)
		}
	else
		self.image = nil
	end
	
	self.dialog = dialog or ""
	self.facing = facing or randomFacing() 
	self.timer = Timer.new()

	self.waitMin, self.waitMax = 3, 6

	if self.still == false then -- random movement
		self.timer:after(1, function(f) -- math.random(self.waitMin, self.waitMax)
		self:setDestination()
		self.timer:after(math.random(self.waitMin, self.waitMax), f)
		end)
	end
end

function NPC:update(dt)
	self.timer:update(dt)
	if self.image then
		self.animation[self.facing]:update(dt)
	end
	self:movement(dt)
end

function NPC:draw()
	if self.image then
		self.animation[self.facing]:draw(self.image, self.x, self.y)
	end
	if debug then
		love.graphics.rectangle('line', self.dx, self.dy, 16, 16)
	end
end

function NPC:setDestination()
	-- enum the direction moved
	local direction = {
		[1] = "up",
		[2] = "down",
		[3] = "left",
		[4] = "right"
	}

	local destination = math.random(4)

	self.facing = direction[destination]
	if destination == 1 then
		self.dx, self.dy = self.world:move(self, self.dx, self.y - 16)
	elseif destination == 2 then
		self.dx, self.dy = self.world:move(self, self.dx, self.y + 16)
	elseif destination == 3 then
		self.dx, self.dy = self.world:move(self, self.dx - 16, self.y)
	elseif destination == 4 then
		self.dx, self.dy = self.world:move(self, self.dx + 16, self.y)
	end
end

function NPC:movement(dt)
	--down
	if self.dy > self.y then
		self.y = self.y + self.moveSpeed *dt
		if self.dy < self.y then
			self.y = self.dy
		end
	end
	-- up
	if self.dy < self.y then
		self.y = self.y - self.moveSpeed *dt
		if self.dy > self.y then
			self.y = self.dy
		end
	end
	-- left
	if self.dx < self.x then
		self.x = self.x - self.moveSpeed *dt
		if self.dx > self.x then
			self.x = self.dx
		end
	end
	-- right
	if self.dx > self.x then
		self.x = self.x + self.moveSpeed *dt
		if self.dx < self.x then
			self.x = self.dx
		end
	end
end

function randomFacing()
	local direction = {
		[1] = "up",
		[2] = "down",
		[3] = "left",
		[4] = "right"
	}

	local choice = math.random(4)
	return direction[choice]
end

function NPC:facePlayer(playerDirection)
	local input = playerDirection
	if input == "up" then
		self.facing = "down"
	elseif input == "down" then
		self.facing = "up"
	elseif input == "left" then
		self.facing = "right"
	elseif input == "right" then
		self.facing = "left"
	end
end

return NPC