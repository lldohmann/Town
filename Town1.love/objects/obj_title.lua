local Object = require 'libraries.classic'
local gamera = require 'libraries.gamera'
local Timer = require 'libraries.timer'

local TitleScreen = Object:extend()

function TitleScreen:new()
	self.image = love.graphics.newImage('assets/misc/title.png')
	self.sound = love.audio.newSource('assets/audio/sound/start.wav', 'static')
	self.music = love.audio.newSource('assets/audio/music/title.wav')
	self.text = {
		[1] = "Press 'z' to start",
		[2] = "Made by LudvickToba"
	}
	self.cam = gamera.new(0, 0, displayWidth, displayHeight)
	self.cam:setWindow(0, 0, displayWidth, displayHeight)
	self.cam:setScale(scale)
	self.cam:setPosition(0,0)
	self.timer = Timer()
	self.text_display = 1
	self.b_box_w = 0
	self.b_box_h = 0
	self.press_Once = false
	self.music:play()
end

function TitleScreen:update(dt)
	self.timer:update(dt)
end

function TitleScreen:draw()
	local l,t,w,h = self.cam:getVisible()
	self.cam:draw(function(l,t,w,h)
		love.graphics.draw(self.image)
		if self.text_display == 1 then
			love.graphics.print(self.text[1], 64, 168)
		end
		love.graphics.print(self.text[2], 56, 224)
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle('fill', 0, 0, self.b_box_w, self.b_box_h)
		love.graphics.setColor(255,255,255)
	end)
end

function TitleScreen:keypressed(key)
	if self.press_Once == false then
		if key == 'z' then
			self.press_Once = true
			self.music:stop()
			self.text_display = self.text_display * -1
			self.sound:play()
			self.timer:after(2, function(f)
				Gamestate.switch(Game)
			end)
			self.timer:after(.25, function(g)
				self.text_display = self.text_display * -1
				self.timer:after(.25, g)
			end)
			self.timer:after(1.5, function()
				self.b_box_w = 256
				self.b_box_h = 240
			end)
		end
	end
end

return TitleScreen