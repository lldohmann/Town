local data = require 'maps.map_data'
local Object = require 'libraries.classic'
local gamera = require 'libraries.gamera'
local bump = require 'libraries.bump'
local Timer = require 'libraries.timer'

local Wall = require 'objects.obj_wall'
local Player = require 'objects.obj_player'
local Warp = require 'objects.obj_warp'
local NPC = require 'objects.obj_npc'

local Map = Object:extend()
local lg = love.graphics

function Map:new(mapData, player) --(pallet, player, warps, walls, detail)
	self.offset = 6
	self.tileSize = 16
	self.timer = Timer()
	self.transition = false

	self:changeMap(mapData, player)
end

function Map:changeMap(mapData, player)
	self.mapData = mapData 

	-- SET UP TILES
	self.tileSetImage = lg.newImage(mapData.pallet) --lg.newImage(pallet)
	self.detail = mapData.detail --detail
	self.tileQuads = {}
	self:setTileQuads()
	self.tileBatch = lg.newSpriteBatch(self.tileSetImage, displayWidth/scale * displayHeight/scale) -- load SpriteBatch

	-- SET UP BUMP WORLD
	self.world = bump.newWorld(self.tileSize)
	self.walls = mapData.walls --walls

	self.mapWidth = #self.detail[1]*self.tileSize
	self.mapHeight = #self.detail*self.tileSize

	self.player = Player(self.world, (player.x - 1)*self.tileSize, (player.y - 1)*self.tileSize - self.offset, self)

	-- SET UP GAMERA
	self.cam = gamera.new(0, 0, self.mapWidth, self.mapHeight)
	self.cam:setWindow(0, 0, displayWidth, displayHeight)
	self.cam:setScale(scale)
	--self.cam:setPosition(0,0)
	self.cam:setPosition(self.player.spriteX - displayWidth/2, self.player.spriteY - displayHeight/2)

	local l,t,w,h = self.cam:getWindow()
	self.boxTrans = {height1 = 0, y2 = h, height2 = 0}

	self:addWalls()

	self:addNpcs()

	if debug then
		local l,t,w,h = self.cam:getWorld()
		print("world.x: ".. l .. ", world.y: " .. t .. ", world.w: " .. w .. ", world.h: " .. h)
	end
end

function Map:update(dt)
	local l,t,w,h = self.cam:getVisible()
	local visibleThings, len = self.world:queryRect(l,t,w,h)

	for i = 1, len do
		if self.transition == false then
			visibleThings[i]:update(dt)
		end
	end

	self.cam:setPosition(self.player.spriteX, self.player.spriteY)

	self.timer:update(dt)
end

function Map:draw()
	local l,t,w,h = self.cam:getVisible()
	-- GET THE COORDINATES OF THE TILES SEENS BY CAMERA
	local minX = math.max(math.floor((l/self.tileSize)+1), 1)
	local maxX = math.min(minX + w/self.tileSize, (self.mapWidth/self.tileSize) )
	local minY = math.max(math.floor((t/self.tileSize)+1), 1)
	local maxY = math.min(minY + h/self.tileSize, (self.mapHeight/self.tileSize) )

	self:updateTileBatch(minX, maxX, minY, maxY)

	local visibleThings, len = self.world:queryRect(l,t,w,h)

	self.cam:draw(function(l,t,w,h)
		lg.draw(self.tileBatch)
		for i = 1, len do
			visibleThings[i]:draw()
		end
	end)
	self:drawTransition()
end

function Map:keypressed(key)
	self.player:keypressed(key)
	if key == "c" then
		if debug then
			local camX, camY = self.player.spriteX, self.player.spriteY 
			print("camX: " .. camX .. ", camY: " .. camY)
		end
	end
end

function Map:addWalls()
	local width = #self.detail[1]
	local height = #self.detail
	for y = 1, height do --minY, maxY do
		for x = 1, width do --minX, maxX do
			if self.walls[y][x] == 1 then
				local wall = Wall(self.world, (x-1)*self.tileSize, (y-1)*self.tileSize - self.offset)
			elseif self.walls[y][x] ~= 0 then -- add warps
				local index = self.walls[y][x]
				local warp = Warp(self.world, (x-1)*self.tileSize, (y-1)*self.tileSize - self.offset, data.warps[index].map, data.warps[index].player)
				print("index: " .. index .. " warp: " .. tostring(warp.mapChange))
			end
		end
	end
end

function Map:addNpcs()
	local len = #self.mapData.npcs
	print("npcs: " .. len)
	for i = 1, len do 
		local obj = self.mapData.npcs[i]
		local npc = NPC(self.world, (obj.x - 1)*16, (obj.y - 1)*16 - self.offset, obj.dialog, obj.still, obj.spriteSheet, obj.facing) -- NPC(self.world, 10*self.tileSize, 9*self.tileSize, "hello world!", false, 'assets/npcs/man1.png', "down")
	end
end

function Map:updateTileBatch(minX, maxX, minY, maxY)
	self.tileBatch:clear()
	for y = minY, maxY do
		for x = minX, maxX do --1, self.mapWidth do
			if self.detail[y][x] ~= 0 then
				self.tileBatch:add(self.tileQuads[(self.detail[y][x])], (x - 1)*self.tileSize, (y - 1)*self.tileSize)-- + self.offset)
			end
		end
	end
	self.tileBatch:flush()
end

function Map:setTileQuads()
	local width = self.tileSetImage:getWidth()
	local height = self.tileSetImage:getHeight()
	local i = 1
	for y = 0, height/self.tileSize - 1 do
		for x = 0, width/ self.tileSize - 1 do
			self.tileQuads[i] = lg.newQuad(x * self.tileSize,
										   y * self.tileSize,
										   self.tileSize,
										   self.tileSize,
										   width,
										   height)
			i = i + 1
		end
	end
end

function Map:TransIn(mapChange, player)
	local l,t,w,h = self.cam:getWindow()
	local soundScreenDown = love.audio.newSource("assets/audio/sound/screendown.wav", "static")
	local soundScreenUp = love.audio.newSource("assets/audio/sound/screenup.wav", "static")
	self.transition = true
	soundScreenDown:play()
	self.timer:tween(0.5, self.boxTrans, {height1 = h/2, y2 = h/2, height2 = h/2}, 'linear', function()
		self.timer:after(0.5, function()
			self:changeMap(mapChange, player)

			self.player.state = self.player.playerStates.moving

			self.boxTrans = {height1 = h/2, y2 = h/2, height2 = h/2}
			soundScreenUp:play()
			self.timer:tween(0.5, self.boxTrans, {height1 = 0, y2 = h, height2 = 0}, 'linear', function()
				self.transition = false

				self.player.state = self.player.playerStates.still
			end)
		end)
	end)
end

function Map:drawTransition()
	local l,t,w,h = self.cam:getWindow()
	lg.setColor(0,0,0)
	lg.rectangle('fill', l, t, w, self.boxTrans.height1)
	lg.rectangle('fill', l, self.boxTrans.y2, w, self.boxTrans.height2)
	lg.setColor(255,255,255)
end

return Map