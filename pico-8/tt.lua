function mkPlayer()
   local p = {}
   p.x = rndCoord()
   p.y = rndCoord()

   p.dx = function ()
      if btn(1)
      then
         return 1
      elseif btn(0)
      then
         return -1
      else
         return 0
      end
   end
   p.dy = function ()
      if btn(3)
      then
         return 1
      elseif btn(2)
      then
         return -1
      else
         return 0
      end
   end
   p.update = function()
      p.x += p.dx()
      p.y += p.dy()
   end

   p.draw = function()
      circ(p.x, p.y, 4, 1)
   end

   return p
end

function rndCoord()
   return flr(rnd(128))
end

function mkRobot()
   local r = {}
   r.x = rndCoord()
   r.y = rndCoord()

   r.dx = function()
      if player.x < r.x
      then return -1
      elseif player.x > r.x
      then return 1
      else return 0
      end
   end
   
   r.dy = function()
      if player.y < r.y
      then return -1
      elseif player.y > r.y
      then return 1
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
