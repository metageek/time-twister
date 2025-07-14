--Copyright 2025 John Stracke. Licensed under the GPLv3.
function say(s)
   print(s, 64 - (#s*2), 61, 11)
end

function setup()
  level += 1
  swarm = mkSwarm(1 + 2 * level)
  player = mkPlayer()
  recordedPlayers = {}
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
      return p.i <= #p.moves and player.state == 0
   end

   p.draw = function()
      if p.visible()
      then
         spr(3, p.x, p.y)
      end
   end

   p.lose = function()
      p.i = #p.moves + 1
   end

   return p
end

function mkPlayer()
   local p = rndSafePos(swarm.robots)

   p.x0 = p.x
   p.y0 = p.y

   p.moves = {}
   p.ticksSinceMove = 0

   -- 0: running
   -- 1: won
   -- 2: lost
   p.state = 0
   p.wonFlipped = true
   p.wonFlippedTicksLeft = 15
   p.wonDanceStepsLeft = 6
   p.runningTeleporting = false
   p.runningTeleportFrames = 0
   p.teleportedFrom = nil
   p.ticksSinceLost = nil

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
      if p.state == 2 and btn(5)
      then
         _init()
         return
      end
      if p.state ~= 0
      then return
      end

      if btnp(4)
      then
         recordedPlayers[#recordedPlayers + 1] = mkRecordedPlayer(p.x0, p.y0, p.moves)
         p.moves = {}
         p.ticksSinceMove = 0

         p.runningTeleporting = true
         p.teleportedFrom = { x = p.x, y = p.y}
         p.runningTeleportFrames = 0

         local dest = rndSafePos(swarm.robots)
         p.x = dest.x
         p.y = dest.y
         p.x0 = p.x
         p.y0 = p.y
         p.updated = true
         sfx(3)
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

      p.x = min(max(p.x + dx, 8), 112)
      p.y = min(max(p.y + dy, 8), 112)

      p.updated = true
      return
   end

   p.spiral = function ()
      local x = 0
      local y = 0
      local steps = 0
      if p.runningTeleportFrames >= 15
      then
         x = p.x
         y = p.y
         steps = 30 - p.runningTeleportFrames
      else
         x = p.teleportedFrom.x
         y = p.teleportedFrom.y
         steps = p.runningTeleportFrames
      end

      local dth = 30 / 360
      local th = dth + (steps / 5)
      local ds = 1
      local s = ds


      for i = 0, steps
      do
         local newx = x + s * cos(th)
         local newy = y + s * sin(th)

         line(x, y, newx, newy, 3)

         s += ds
         th += dth
         x = newx
         y = newy
      end
   end

   p.draw = function()
      if p.state == 0
      then
         if p.runningTeleporting
         then
            p.spiral()
            p.runningTeleportFrames += 1
            if p.runningTeleportFrames == 30
            then
               p.runningTeleporting = false
            end
         else
            spr(1, p.x, p.y)
         end
      elseif p.state == 1
      then
         say("You won level " .. tostr(level) .. "!")
         local xoffset = 4
         if p.wonFlipped
         then
            xoffset = 0
         end
         spr(1, p.x + xoffset, p.y)
         p.wonFlippedTicksLeft -= 1
         if p.wonFlippedTicksLeft == 0
         then
            p.wonDanceStepsLeft -= 1
            if p.wonDanceStepsLeft == 0
            then
               setup()
            else
               p.wonFlipped = not p.wonFlipped
               p.wonFlippedTicksLeft = 15
            end
         end
      else
         say("You lost. ")
         local t = p.ticksSinceLost \ 10
         local s = 5
         if t % 2 == 1 and t < 10
         then s = 1
         end
         spr(s,p.x, p.y)
         p.ticksSinceLost += 1
      end
   end

   p.win = function()
      if p.state == 0
      then
         p.state = 1
         sfx(1)
      end
   end

   p.lose = function()
      if p.state == 0
      then
         p.state = 2
         p.ticksSinceLost = 0
         sfx(2)
      end
   end

   return p
end

function rndCoord()
   return flr(rnd(14)) * 8 + 8
end

function rndSafePos(robots)
   function try()
      local x = rndCoord()
      local y = rndCoord()

      for _, r in ipairs(robots)
      do
         local dx = r.x - x
         local dy = r.y - y

         if abs(dx) <= 8 and abs(dy) <= 8
         then
            return nil
         end
      end

      return {x = x, y = y}
   end

   while true
   do
      local pos = try()
      if pos ~= nil
      then
         return pos
      end
   end
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

function mkRobot(robots)
   local r = rndSafePos(robots)
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
      r.p = nearestPlayer(r.x, r.y)

      if r.p.updated and r.exists
      then
         r.x += r.dx(r.p)
         r.y += r.dy(r.p)
         r.x = min(max(r.x, 8), 112)
         r.y = min(max(r.y, 8), 112)
      end
   end

   r.draw = function()
      local flipped = r.p.x < r.x
      if r.exists
      then

         spr(2, r.x, r.y, 1, 1, flipped)
      else
         spr(4, r.x, r.y, 1, 1, flipped)
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
      swarm.robots[i] = mkRobot(swarm.robots)
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
            score += 1
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
