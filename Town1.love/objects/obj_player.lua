local anim8 = require 'libraries.anim8'
local Entity = require 'objects.obj_entity'
local Timer = require 'libraries.timer'

local Player = Entity:extend()
Player:implement(destroy)

local playerFilter = function(item, other)
	if other.isWall or other.isNpc then
		return 'slide'
	elseif other.isWarp then
		return 'cross'
	end
end

function Player:new(world, x, y, map)
	Player.super.new(self, world, x, y)
	self.timer = Timer()

	self.point = {
		x = self.x + 8,
		y = self.y + 24
	}

	self.w = 16
	self.h = 16

	self.map = map
	-- SET MOVEMENT
	self.moveSpeed = 45
	self.distance = 16
	self.spriteX = self.x
	self.spriteY = self.y

	-- SET ANIMATION
	self.frameSpeed = .25
	self.image = love.graphics.newImage('assets/npcs/hero.png')
	self.g = anim8.newGrid(self.w, self.h, self.image:getWidth(), self.image:getHeight())
	self.animation = {
		["down"] = anim8.newAnimation(self.g('1-2', 1), self.frameSpeed),
		["right"] = anim8.newAnimation(self.g('1-2', 2), self.frameSpeed),
		["left"] = anim8.newAnimation(self.g('1-2', 3), self.frameSpeed),
		["up"] = anim8.newAnimation(self.g('1-2', 4), self.frameSpeed)
	}
	self.key = "down"
	-- SET PLAYER STATES
	self.playerStates = {}
	self.playerStates.still = {
		bindings = {
			moveUp = function()
				local goalX = self.x
				local goalY = self.y - self.distance
				local actualX, actualY = self.world:move(self, goalX, goalY, playerFilter)
				self.x, self.y = actualX, actualY

				self.point.x, self.point.y = self.x + 8, self.y - 8

				self.key = "up"
				if self.x ~= self.spriteX or self.y ~= self.spriteY then
					self.state = self.playerStates.moving
				end
			end,
			moveDown = function()
				local goalX = self.x
				local goalY = self.y + self.distance
				local actualX, actualY = self.world:move(self, goalX, goalY, playerFilter)
				self.x, self.y = actualX, actualY

				self.point.x, self.point.y = self.x + 8, self.y + 8 + self.h

				self.key = "down"
				if self.x ~= self.spriteX or self.y ~= self.spriteY then
					self.state = self.playerStates.moving
				end
			end,
			moveLeft = function()
				local goalX = self.x - self.distance
				local goalY = self.y
				local actualX, actualY = self.world:move(self, goalX, goalY, playerFilter)
				self.x, self.y = actualX, actualY

				self.point.x, self.point.y = self.x - 8, self.y + 8

				self.key = "left"
				if self.x ~= self.spriteX or self.y ~= self.spriteY then
					self.state = self.playerStates.moving
				end
			end,
			moveRight = function()
				local goalX = self.x + self.distance
				local goalY = self.y
				local actualX, actualY = self.world:move(self, goalX, goalY, playerFilter)
				self.x, self.y = actualX, actualY

				self.point.x, self.point.y = self.x + 8 + self.w , self.y + 8

				self.key = "right"
				if self.x ~= self.spriteX or self.y ~= self.spriteY then
					self.state = self.playerStates.moving
				end
			end,
			check = function()
				Gamestate.push(Message)
			end
		},
		keys = {
			["up"] = "moveUp",
			["down"] = "moveDown",
			["left"] = "moveLeft",
			["right"] = "moveRight",
			["z"] = "check"
		},
		update = function(dt)
		end
	}
	self.playerStates.moving = {
		bindings = {},
		keys = {},
		update = function(dt)
			self.animation[self.key]:update(dt)
			if self.key == "up" then
				self.spriteY = self.spriteY - self.moveSpeed * dt
				if self.y > self.spriteY then
					self.spriteY = self.y
					self:checkTile()
				end
			elseif self.key == "down" then
				self.spriteY = self.spriteY + self.moveSpeed * dt
				if self.y < self.spriteY then
					self.spriteY = self.y
					self:checkTile()
				end
			elseif self.key == "left" then
				self.spriteX = self.spriteX - self.moveSpeed * dt
				if self.x > self.spriteX then
					self.spriteX = self.x
					self:checkTile()
				end
			elseif self.key == "right" then
				self.spriteX = self.spriteX + self.moveSpeed * dt
				if self.x < self.spriteX then
					self.spriteX = self.x
					self:checkTile()
				end
			end
		end
	}

	self.state = self.playerStates.still
end

function Player:update(dt)
	self.state.update(dt)
	if love.keyboard.isDown("up") then
		local bindings = self.state.keys["up"]
		return self:inputHandler(bindings)
	elseif love.keyboard.isDown("down") then
		local bindings = self.state.keys["down"]
		return self:inputHandler(bindings)
	elseif love.keyboard.isDown("left") then
		local bindings = self.state.keys["left"]
		return self:inputHandler(bindings)
	elseif love.keyboard.isDown("right") then
		local bindings = self.state.keys["right"]
		return self:inputHandler(bindings)
	end
end

function Player:draw()
	self.animation[self.key]:draw(self.image, self.spriteX, self.spriteY)
	if debug then
		love.graphics.rectangle('line', self.x, self.y, 16, 16) -- collision box
		love.graphics.setColor(255,0,0)
		love.graphics.rectangle('fill', self.point.x, self.point.y, 2, 2)-- point of interest
		love.graphics.setColor(255,255,255)
	end
end

function Player:keypressed(key)
	local bindings = self.state.keys[key]
	return self:inputHandler(bindings)
end

function Player:inputHandler(input)
	local action = self.state.bindings[input]
	if action then return action() end
end

function Player:checkTile()
	local actualX, actualY, cols, len = self.world:check(self, self.x, self.y, playerFilter)
	if len > 0 then
		for i = 1, len do
			local other = cols[i].other
			if other.isWarp then
				print("warp hit!")
				self.map:TransIn(other.mapChange, other.player)
			else
				self.state = self.playerStates.still
			end
		end
	else
		self.state = self.playerStates.still
	end
end

function Player:getFacing()
	return self.key
end

return Player