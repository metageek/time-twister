function say(s)
   print(s, 64 - (#s*2), 61, 8)
end

function mkMove(dx, dy, count)
   local m = {dx = dx, dy = dy, count = count}

   m.step = function()
      if m.count > 1
      then
         m.count -= 1
         return nil
      else
         m.count = 0
         return m
      end
   end

   return m
end

function mkRecordedPlayer(x0, y0, moves)
   local p = {}
   p.x = x0
   p.y = y0
   p.moves = moves
   p.i = 1

   p.step = function()
      if p.i > #p.moves
      then
         return nil
      end

      local m = p.moves[p.i].step()
      if m == nil
      then
         return nil
      end

      p.i += 1
      return m
   end

   p.update = function()
      if player.state ~= 0
      then
         p.updated = false
         return
      end
      
      local m = p.step()
      if m ~= nil
      then
         p.x += m.dx
         p.y += m.dy
         p.updated = true
      else
         p.updated = false
      end
   end

   p.visible = function()
      return p.i <= #p.moves
   end

   p.draw = function()
      if p.visible()
      then
         circ(p.x, p.y, 4, 6)
      end
   end

   p.lose = function()
      p.i = #p.moves + 1
   end
   
   return p
end

recordedPlayers = {}

function mkPlayer()
   local p = {}
   p.x = rndCoord()
   p.y = rndCoord()

   p.x0 = p.x
   p.y0 = p.y
   
   p.moves = {}
   p.ticksSinceMove = 0

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

   p.recordMove = function(dx, dy)
      local m = mkMove(dx, dy, p.ticksSinceMove)
      p.ticksSinceMove = 0
      p.moves[#p.moves + 1] = m
   end
   
   p.update = function()
      p.updated = false
      if p.state ~= 0
      then return
      end

      if btnp(4)
      then
         recordedPlayers[#recordedPlayers + 1] = mkRecordedPlayer(p.x0, p.y0, p.moves)
         p.moves = {}
         p.ticksSinceMove = 0
         p.x = rndCoord()
         p.y = rndCoord()
         p.x0 = p.x
         p.y0 = p.y
         p.updated = true
         return
      end

      local dx = p.dx()
      local dy = p.dy()

      if dx == 0 and dy == 0
      then
         p.ticksSinceMove += 1
         return
      end

      p.recordMove(dx, dy)

      p.x = min(max(p.x + dx, 0), 120)
      p.y = min(max(p.y + dy, 0), 120)

      p.updated = true
      return
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

function nearestPlayer(x, y)
   -- Distances are squared
   function dist(p)
      return (p.x - x) * (p.x - x) + (p.y - y) * (p.y - y)
   end
   
   local nearest = player
   local nearestDist = dist(nearest)
   for _, r in ipairs(recordedPlayers)
   do
      if r.visible()
      then
         d = dist(r)
         if d < nearestDist
         then
            nearest = r
            nearestDist = d
         end
      end
   end

   return nearest
end

function mkRobot()
   local r = {}
   r.x = rndCoord()
   r.y = rndCoord()
   r.exists = true

   r.dx = function(p)
      if p.x < r.x
      then return -8
      elseif p.x > r.x
      then return 8
      else return 0
      end
   end
   
   r.dy = function(p)
      if p.y < r.y
      then return -8
      elseif p.y > r.y
      then return 8
      else return 0
      end
   end
   
   r.update = function()
      local p = nearestPlayer(r.x, r.y)
      
      if p.updated and r.exists
      then
         r.x += r.dx(p)
         r.y += r.dy(p)
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

function allPlayers()
   local i = nil
   local n = #recordedPlayers
   return function()
      if i == nil
      then
         i = 0
         return player
      else
         i += 1
         if i <= n then return recordedPlayers[i] end
      end
   end
end

function mkSwarm(n)
   local swarm = { robots={} }

   swarm.numLeft = n
   swarm.msg = ""
   
   for i=1,n
   do
      swarm.robots[i] = mkRobot()
   end

   swarm.update = function()
      for i=1,n
      do
         swarm.robots[i].update()
         swarm.msg = tostr(#recordedPlayers)
         for p in allPlayers()
         do
            if swarm.robots[i].exists and swarm.robots[i].collides(p)
            then
               p.lose()
            end
         end
      end
      
      crashed = {}

      for i=1,n
      do
         for j=1,n
         do
            if i ~= j and swarm.robots[i].exists and swarm.robots[i].collides(swarm.robots[j])
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
