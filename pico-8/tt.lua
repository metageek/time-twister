function say(s)
   print(s, 64 - (#s*2), 61, 8)
end

function mkPlayer()
   local p = {}
   p.x = rndCoord()
   p.y = rndCoord()

   -- 0: running
   -- 1: won
   -- 2: lost
   p.state = 0

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
      if p.state ~= 0
      then return false
      end

      if btnp(4)
      then
         p.x = rndCoord()
         p.y = rndCoord()
         return true
      end
      
      local dx = p.dx()
      local dy = p.dy()
      p.x += dx
      p.y += dy
      return dx ~= 0 or dy ~= 0
   end

   p.draw = function()
      if p.state == 0
      then circ(p.x, p.y, 4, 1)
      elseif p.state == 1
      then say("You won!")
      else say("You lost.")
      end
   end

   p.win = function()
      if p.state == 0
      then
         p.state = 1
      end
   end
   
   p.lose = function()
      if p.state == 0
      then
         p.state = 2
      end
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
   r.exists = true

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
      if r.exists
      then
         r.x += r.dx()
         r.y += r.dy()
      end
   end

   r.draw = function()
      if r.exists
      then
         rect(r.x - 4, r.y - 4, r.x + 4, r.y + 4, 2)
      else
         line(r.x - 4, r.y - 4, r.x + 4, r.y + 4, 2)
         line(r.x - 4, r.y + 4, r.x + 4, r.y - 4, 2)
      end
   end

   r.collides = function(other)
      return r.x == other.x and r.y == other.y
   end

   return r
end

function mkSwarm(n)
   local swarm = { robots={} }

   swarm.numLeft = n
   
   for i=1,n
   do
      swarm.robots[i] = mkRobot()
   end

   swarm.update = function()
      for i=1,n
      do
         swarm.robots[i].update()
      end
      crashed = {}
      for i=1,n
      do
         if swarm.robots[i].exists and swarm.robots[i].collides(player)
         then
            player.lose()
         end
         for j=i+1,n
         do
            if swarm.robots[i].exists and swarm.robots[i].collides(swarm.robots[j])
            then
               crashed[#crashed + 1] = i
               crashed[#crashed + 1] = j
            end
         end
      end
      for i, r in ipairs(crashed)
      do
         if swarm.robots[r].exists
         then
            swarm.numLeft -= 1
            swarm.robots[r].exists = false
         end
      end

      if swarm.numLeft == 0
      then
         player.win()
      end
   end

   swarm.draw = function()
      for i=1,n
      do
         swarm.robots[i].draw()
      end
   end

   return swarm
end
