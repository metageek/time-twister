function mkRobot()
   local r = {}
   r.update = function()
   end
   r.draw = function()
      line(0, 0, 63, 63, 1)
   end

   return r
end
