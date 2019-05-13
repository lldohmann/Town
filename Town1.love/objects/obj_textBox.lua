local Object = require 'libraries.classic'
local Timer = require 'libraries.timer'

local Box = Object:extend()

function Box:Create(x, y, width, height, dialog)
	self.letters = 0
	self.elapsed = 0
	self.sound = love.audio.newSource("assets/audio/sound/textsound.wav", "static")
	self.speed = 0.05
	self.timer = Timer()

	--self.dialog = dialog
	self.x = x
	self.y = y
	self.w = width
	self.h = height
	self.tileset = love.graphics.newImage("assets/misc/textbox.png")
	self.tilesetBatch = love.graphics.newSpriteBatch(self.tileset, 1000)

	self.tileSize = 8
	
	self.dialog = {reformat(dialog, self.w, self.tileSize)}

	self.tilesetBatch:clear()
	local tileX, tileY = 0, 0
	for height = 0, self.h do
		for width = 0, self.w do
			if (height == 0) then
				if (width == 0) then -- top left
					tileX, tileY = 0, 0
				elseif (width == self.w) then -- top right
					tileX, tileY = 16, 0
				else
					tileX, tileY = 8, 0
				end
			elseif (height == self.h) then
				if (width == 0) then -- bottom left
					tileX, tileY = 0, 16
				elseif (width == self.w) then -- bottom right
					tileX, tileY = 16, 16
				else -- bottom mid 
					tileX, tileY = 8, 16
				end
			else
				if (width == 0) then -- mid left
					tileX, tileY = 0, 8
				elseif (width == self.w) then -- mid right
					tileX, tileY = 16, 8
				end
			end
			if (tileX ~= -1 and  tileY ~= -1) then
				self.tilesetBatch:add(
					love.graphics.newQuad(
						tileX, 
						tileY, 
						self.tileSize, 
						self.tileSize, 
						self.tileset:getWidth(), 
						self.tileset:getHeight()),
					self.x + width * self.tileSize, 
					self.y + height * self.tileSize)
			end
			tileX, tileY = -1, -1
		end
	end

	self.tilesetBatch:flush()

	self.timer:after(self.speed, function(f)
		self.elapsed = self.elapsed + 1
		self.letters = math.min(math.floor(self.elapsed), #self.dialog[1])
		if self.letters ~= #self.dialog[1] then
			self.sound:play()
		end
		self.timer:after(self.speed, f)
	end)
end

function Box:update(dt)
	self.timer:update(dt)
end

function Box:draw()
	local l,t,w,h = map.cam:getVisible()
	map.cam:draw(function(l,t,w,h)
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle('fill', self.x + l, self.y + t, self.w * self.tileSize, self.h * self.tileSize)
		love.graphics.setColor(255,255,255)
		love.graphics.draw(self.tilesetBatch, l, t)
		if self.dialog then
			love.graphics.printf(self.dialog[1]:sub(1, self.letters), l + self.x + self.tileSize, t + self.y + self.tileSize, self.w * self.tileSize - self.tileSize)
		end
	end)
end

function reformat(dialog, width, tileSize)
	local textLength = (width * tileSize - tileSize)/8
	local copy = dialog
	local totalLength = 0
	local result = ""
	for word in string.gfind(copy, "(%S+)") do
		if totalLength + string.len(word) < textLength then
			result = result .. word .. " "
			totalLength = totalLength + string.len(word) + 1
		else
			result = result .. "\n" .. word .. " "
			totalLength = string.len(word) + 1
		end
	end
	return result
end

return Box