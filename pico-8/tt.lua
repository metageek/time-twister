function mkPlayer()
   local p = {}
   p.x = rndCoord()
   p.y = rndCoord()

   p.dx = function ()
      if btnp(1)
      then
         return 8
      elseif btnp(0)
      then
         return -8
      else
         return 0
      end
   end
   p.dy = function ()
      if btnp(3)
      then
         return 8
      elseif btnp(2)
      then
         return -8
      else
         return 0
      end
   end
   p.update = function()
      local dx = p.dx()
      local dy = p.dy()
      p.x += dx
      p.y += dy
      return dx ~= 0 or dy ~= 0
   end

   p.draw = function()
      circ(p.x, p.y, 4, 1)
   end

   return p
end

function rndCoord()
   return flr(rnd(16)) * 8
end

function mkRobot()
   local r = {}
   r.x = rndCoord()
   r.y = rndCoord()

   r.dx = function()
      if player.x < r.x
      then return -8
      elseif player.x > r.x
      then return 8
      else return 0
      end
   end
   
   r.dy = function()
      if player.y < r.y
      then return -8
      elseif player.y > r.y
      then return 8
      else return 0
      end
   end
   
   r.update = function()
      r.x += r.dx()
      r.y += r.dy()
   end

   r.draw = function()
      rect(r.x - 4, r.y - 4, r.x + 4, r.y + 4, 2)
   end

   return r
end

function mkSwarm(n)
   local swarm = { robots={} }

   for i=0,n
   do
      swarm.robots[i] = mkRobot()
   end

   swarm.update = function()
      for i=0,n
      do
         swarm.robots[i].update()
      end
   end

   swarm.draw = function()
      for i=0,n
      do
         swarm.robots[i].draw()
      end
   end

   return swarm
end
