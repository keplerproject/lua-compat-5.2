
-- utility module to make the Lua 5.1 standard libraries behave more like Lua 5.2

if _VERSION == "Lua 5.1" then
   
   bit32 = require("bit32")
   
   local unavailable = function() error("compat52: Do not use this function. It is incompatible with Lua 5.2") end
   
   setfenv = unavailable
   getfenv = unavailable
   
   local os_execute = os.execute
   os.execute = function(cmd)
      local code = os_execute(cmd)
      -- Lua 5.1 does not report exit by signal.
      if code == 0 then
         return true, "exit", code
      else
         return nil, "exit", code
      end
   end
   
   table.pack = function(...)
      local args = { n = select('#', ...) }
      for i = 1, args.n do
         args[i] = select(i, ...)
      end
      return args
   end

   table.unpack = unpack
   unpack = nil

   local main_coroutine = coroutine.create(function() end)
   
   local coroutine_running = coroutine.running
   coroutine.running = function()
      local co = coroutine_running()
      if co then
         return co, false
      else
         return main_coroutine, true
      end
   end
   
   local coroutine_yield = coroutine.yield
   coroutine.yield = function(...)
      local co = coroutine_running()
      if co then
         return coroutine_yield(...)
      else
         error("attempt to yield from outside a coroutine", 0)
      end
   end
   
   local coroutine_resume = coroutine.resume
   coroutine.resume = function(co, ...)
      if co == main_coroutine then
         return false, "cannot resume non-suspended coroutine"
      else
         return coroutine_resume(co, ...)
      end
   end
   
   local coroutine_status = coroutine.status
   coroutine.status = function(co)
      local notmain = coroutine_running()
      if co == main_coroutine then
         return notmain and "normal" or "running"
      else
         return coroutine_status(co)
      end
   end

end
