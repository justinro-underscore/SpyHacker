Bullet = {}

function Bullet:new(x, y, velocity_x, velocity_y)
  o = {}
  setmetatable(o,{__index = self})
  o.size(32, 32)
  o.position = vector.new(x,y)
  o.velocity = velocity.new(velocity_x,velocity_y)
	
	o.isKill = false
	
  return o
end

function Bullet:update(dt)
  self.position = self.position + self.velocity.x * dt
end

function Bullet:draw()
  love.graphics.circle("fill", self.position.x, self.position.y, 8, 8)
end

function Bullet:collision()
	
end

function Bullet:kill()
	
end