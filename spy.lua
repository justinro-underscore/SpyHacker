Spy = {}

function Spy:new(x, y, controller)
	local o = {}
	setmetatable(o, {__index = self})

	o.position = vector.new(x, y)
	o.size = vector.new(64, 96)
	o.velocity = vector.new(0, 0)
	o.facing = "right" -- The way that the spy is facing

	o.controller = controller

	--[[
	possible state values:
	-ground
	-air
	]]
	o.state = "air"

	o.mode = "acrobatic"

	o.hitGround = false -- will be set to true by the collision function, used by changestate
	o.hitWall = false

	o.collider = HC.rectangle(x, y, o.size.x, o.size.y)
	o.collider.parent = o -- used so that colliders can find their parent object

	o.tag = "Spy" -- used for other objects to find out what kind of object this is

	o.GRAVITY_CONSTANT = 500 -- constant that determines fall speed
	o.JUMP_SPEED = 300
	o.RUN_SPEED = 200
	o.DEFENSE_SPEED = 100

	o.spriteFramesAcro = {love.graphics.newImage("Spy Game Sprites/Standing Acro.png"),
												love.graphics.newImage("Spy Game Sprites/Running Straight Left Acro.png"),
												love.graphics.newImage("Spy Game Sprites/Mid-Running Right Acro.png"),
												love.graphics.newImage("Spy Game Sprites/Running Right Acro.png"),
												love.graphics.newImage("Spy Game Sprites/Running Straight Right Acro.png"),
												love.graphics.newImage("Spy Game Sprites/Mid-Running Left Acro.png"),
												love.graphics.newImage("Spy Game Sprites/Running Left Acro.png"),
												love.graphics.newImage("Spy Game Sprites/Jumping Acro.png")}
	o.spriteFramesDefe = {love.graphics.newImage("Spy Game Sprites/Standing.png"),
												love.graphics.newImage("Spy Game Sprites/Running Straight Left.png"),
												love.graphics.newImage("Spy Game Sprites/Mid-Running Right.png"),
												love.graphics.newImage("Spy Game Sprites/Running Right.png"),
												love.graphics.newImage("Spy Game Sprites/Running Straight Right.png"),
												love.graphics.newImage("Spy Game Sprites/Mid-Running Left.png"),
												love.graphics.newImage("Spy Game Sprites/Running Left.png"),
												love.graphics.newImage("Spy Game Sprites/Jumping.png")}
	o.spriteFra = 2
	o.sprite = o.spriteFramesAcro[1]
	o.time = 0

	o.RUN_ACCELERATION = 900
	o.AIR_ACCELERATION = 300

	o.terminalTouch = nil

	o.isKill = false

	return o
end

function Spy:update(dt)
	self:collide()
	self:changeState(dt)
	self:runState(dt)
	self:face()
	self:updateSprite(dt)
	self:terminal()
	self:winCheck()

	self.collider:moveTo(self.position.x, self.position.y)

	if self.isKill then
		self:delete()
	end
end

function Spy:terminal()
	local dx = 0
	local dy = 0
	for i, v in ipairs(terminalList) do
		dx = math.abs(v.position.x - self.position.x)
		dy = math.abs(v.position.y - self.position.y)
		if (dx <= (v.size.x / 2 + self.size.x / 2)) and (dy <= (v.size.y / 2 + self.size.y / 2)) then
			self.terminalTouch = v
			v.accessible = true
			return nil
		else
			if self.terminalTouch then
				v.accessible = false
			end
		end
	end
	self.terminalTouch = nil
end

function Spy:winCheck()
  local dx = 0
  local dy = 0
  dx = math.abs(winObjectList[1].position.x - self.position.x)
  dy = math.abs(winObjectList[1].position.y - self.position.y)
  if (dx <= (winObjectList[1].size.x / 2 + self.size.x / 2)) and (dy <= (winObjectList[1].size.y / 2 + self.size.y / 2)) then
		if self.controller.bEdge then
			return true
		end
  end
	return false
end

function Spy:updateSprite(dt)
	if self.mode == "acrobatic" then
		self.time = self.time + dt
		if self.state == "air" then
			self.sprite = self.spriteFramesAcro[8]
			self.spriteFra = 2
			self.time = 0
		elseif self.velocity.x == 0 then
			self.sprite = self.spriteFramesAcro[1]
			self.spriteFra = 2
			self.time = 0
		elseif self.state == "air" then
			self.sprite = self.spriteFramesAcro[8]
			self.spriteFra = 2
			self.time = 0
		else
			self.sprite = self.spriteFramesAcro[self.spriteFra]
			if self.time >= (40 / self.RUN_SPEED) then
				self.spriteFra = self.spriteFra + 1
				self.time = self.time - (40 / self.RUN_SPEED)
			end
			if self.spriteFra > 7 then
				self.spriteFra = 2
			end
		end
	else
		self.time = self.time + dt
		if self.state == "air" then
			self.sprite = self.spriteFramesDefe[8]
			self.spriteFra = 2
			self.time = 0
		elseif self.velocity.x == 0 then
			self.sprite = self.spriteFramesDefe[1]
			self.spriteFra = 2
			self.time = 0
		elseif self.state == "air" then
			self.sprite = self.spriteFramesDefe[8]
			self.spriteFra = 2
			self.time = 0
		else
			self.sprite = self.spriteFramesDefe[self.spriteFra]
			if self.time >= (40 / self.RUN_SPEED) then
				self.spriteFra = self.spriteFra + 1
				self.time = self.time - (40 / self.RUN_SPEED)
			end
			if self.spriteFra > 7 then
				self.spriteFra = 2
			end
		end
	end
end

function Spy:collide()
	hitWall = false

	for other, delta in pairs(HC.collisions(self.collider)) do
		local otherParent = other.parent

		if (otherParent.tag == "Wall" or otherParent.tag == "VBoxOn" or otherParent.tag == "DoorClosed") and (math.abs(delta.x) > 0 or math.abs(delta.y) > 0) then

			if math.abs(delta.x) > 0 then
				if not hitWall then
					hitWall = true

					if self.position.x < otherParent.position.x then
						self.velocity.x = 0
						self.position.x = self.position.x - math.abs(delta.x)
					else
						self.velocity.x = 0
						self.position.x = self.position.x + math.abs(delta.x)
					end
				end

			else
				if math.abs(self.position.x - otherParent.position.x) < (self.size.x + otherParent.size.x) / 2 - 2 then
					if self.position.y < otherParent.position.y then
						if not self.hitGround then
							self.hitGround = true
							self.position.y = self.position.y - math.abs(delta.y)
						end
					else
						self.velocity.y = 0
						self.position.y = self.position.y + math.abs(delta.y)
					end
				end
			end

		elseif otherParent.tag == "Trap" then
			self.isKill = true
		end
  end
end

function Spy:checkGround() -- returns true true if the spy is above a block; used to determine if the spy walked off a ledge
	for i, v in ipairs(wallList) do
		if v.collider:contains(self.position.x - self.size.x / 2, self.position.y + (self.size.y / 2) + 2) or v.collider:contains(self.position.x + self.size.x / 2, self.position.y + (self.size.y / 2) + 2) then
			return true
		end
	end
	for i, v in ipairs(vboxList) do
		if v.collider:contains(self.position.x - self.size.x / 2, self.position.y + (self.size.y / 2) + 2) or v.collider:contains(self.position.x + self.size.x / 2, self.position.y + (self.size.y / 2) + 2) and (v.tag == "VBoxOn") then
			return true
		end
	end
	return false
end

function Spy:checkWallJump()
	if self.controller.aEdge then
		for i, v in ipairs(wallList) do
			if v.collider:contains(self.position.x + (self.size.x / 2) + 15, self.position.y + (self.size.y / 2) - 2) then
				return true, "left"
			elseif v.collider:contains(self.position.x - (self.size.x / 2) - 15, self.position.y + (self.size.y / 2) - 2) then
				return true, "right"
			end
		end

		for i, v in ipairs(vboxList) do
			if v.collider:contains(self.position.x + (self.size.x / 2) + 15, self.position.y + (self.size.y / 2) - 2) and (v.tag == "VBoxOn") then
				return true, "left"
			elseif v.collider:contains(self.position.x - (self.size.x / 2) - 15, self.position.y + (self.size.y / 2) - 2) and (v.tag == "VBoxOn") then
				return true, "right"
			end
		end

	end
	return false
end

function Spy:changeState(dt)
	if self.state == "run" then
		if self.controller.aEdge and not (self.mode == "defense") then -- can't jump in defense mode
			self.state = "air"
			self.velocity = self.velocity + vector.new(0, -self.JUMP_SPEED)
		elseif not self:checkGround() then
			self.state = "air"
		end

	elseif self.state == "air" then
		if self.hitGround then
			self.hitGround = false
			self.state = "run"
			self.velocity.y = 0
		end
	end
end

function Spy:runState(dt)
	if self.state == "run" then
		self:runRun(dt)
	elseif self.state == "air" then
		self:runAir(dt)
	end
end

function Spy:runRun(dt)
	if self.controller.joy1.x > 0 then
		self.velocity = self.velocity + (vector.new(self.RUN_ACCELERATION, 0) * dt)
	elseif self.controller.joy1.x < 0 then
		self.velocity = self.velocity + (vector.new(-self.RUN_ACCELERATION, 0) * dt)
	else

		if self.velocity.x > self.RUN_ACCELERATION/10 then
			self.velocity = self.velocity - (vector.new(self.RUN_ACCELERATION, 0) * dt)
		elseif self.velocity.x < -self.RUN_ACCELERATION/10 then
			self.velocity = self.velocity + (vector.new(self.RUN_ACCELERATION, 0) * dt)
		else
			self.velocity.x = 0
		end

	end

	local speedCap
	if self.mode == "defense" then
		speedCap = self.DEFENSE_SPEED
	else
		speedCap = self.RUN_SPEED
	end

	if math.abs(self.velocity.x) > speedCap then -- cap speed
		if self.velocity.x > 0 then
			self.velocity.x = speedCap
		else
			self.velocity.x = -speedCap
		end
	end

	self.position = self.position + (self.velocity * dt)
end

function Spy:runAir(dt)
	local acceleration = vector.new(0, self.GRAVITY_CONSTANT) -- fall due to gravity
	self.velocity = self.velocity + (acceleration * dt)

	if self.controller.joy1.x > 0 then -- arial movement due to joystick input
		self.velocity = self.velocity + (vector.new(self.AIR_ACCELERATION, 0) * dt)
	elseif self.controller.joy1.x < 0 then
		self.velocity = self.velocity + (vector.new(-self.AIR_ACCELERATION, 0) * dt)
	end

	local isJump, direction = self:checkWallJump()
	if isJump and self.mode == "acrobatic" then -- we can only jump in acrobatic mode
		if direction == "left" then
			self.velocity.x = -self.RUN_SPEED
			self.velocity.y = -self.JUMP_SPEED
		elseif direction == "right" then
			self.velocity.x = self.RUN_SPEED
			self.velocity.y = -self.JUMP_SPEED
		end
	end

	if math.abs(self.velocity.x) > self.RUN_SPEED then -- cap speed
		if self.velocity.x > 0 then
			self.velocity.x = self.RUN_SPEED
		else
			self.velocity.x = -self.RUN_SPEED
		end
	end

	self.position = self.position + (self.velocity * dt)
end

function Spy:face() -- Determines which way spy is facing
	if self.velocity.x > 0 then
		self.facing = "right"
	elseif self.velocity.x < 0 then
		self.facing = "left"
	end
end

function Spy:setMode(mode)
	self.mode = mode
end

function Spy:draw()
	love.graphics.setColor(255, 255, 255)

	local x = (self.position.x - self.size.x / 2) -- x coord
	local y = (self.position.y - self.size.y / 2) -- y coord

	if self.facing == "right" then
  	love.graphics.draw(self.sprite, x, y, 0, 2, 2) -- Places the sprite.
	elseif self.facing == "left" then
		x = x + self.size.x
	  love.graphics.draw(self.sprite, x, y, 0, -2, 2) -- Places the sprite.
	end
end

function Spy:delete()
  HC.remove(self.collider)
end
