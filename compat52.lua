
-- utility module to make the Lua 5.1 standard libraries behave more like Lua 5.2

if _VERSION == "Lua 5.1" then
   
   bit32 = require("bit32")

   -- the most powerful getmetatable we can get (preferably from debug)
   local sudo_getmetatable = getmetatable

   if type(debug) == "table" then

      debug.setuservalue = debug.setfenv
      debug.getuservalue = debug.getfenv

      if type(debug.getmetatable) == "function" then
         sudo_getmetatable = debug.getmetatable
      end

      local debug_setmetatable = debug.setmetatable
      if type(debug_setmetatable) == "function" then
         debug.setmetatable = function(value, tab)
            debug_setmetatable(value, tab)
            return value
         end
      end
   end

   local _pairs = pairs
   pairs = function(t)
      local mt = sudo_getmetatable(t)
      if type(mt) == "table" and type(mt.__pairs) == "function" then
         return mt.__pairs(t)
      else
         return _pairs(t)
      end
   end

   local _ipairs = ipairs
   ipairs = function(t)
      local mt = sudo_getmetatable(t)
      if type(mt) == "table" and type(mt.__ipairs) == "function" then
         return mt.__ipairs(t)
      else
         return _ipairs(t)
      end
   end
   
   local _setfenv = setfenv

   local function check_mode(mode, prefix)
      local has = { text = false, binary = false }
      for i = 1,#mode do
         local c = mode:sub(i, i)
         if c == "t" then has.text = true end
         if c == "b" then has.binary = true end
      end
      local t = prefix:sub(1, 1) == "\27" and "binary" or "text"
      if not has[t] then
         return "attempt to load a "..t.." chunk (mode is '"..mode.."')"
      end
   end

   local _load, _loadstring = load, loadstring
   load = function(ld, source, mode, env)
      mode = mode or "bt"
      local chunk, msg
      if type( ld ) == "string" then
         if mode ~= "bt" then
            local merr = check_mode(mode, ld)
            if merr then return nil, merr end
         end
         chunk, msg = _loadstring(ld, source)
      else
         local ld_type = type(ld)
         if ld_type ~= "function" then
            error("bad argument #1 to 'load' (function expected, got "..ld_type..")", 2)
         end
         if mode ~= "bt" then
            local checked, merr = false, nil
            local function checked_ld()
               if checked then
                  return ld()
               else
                  checked = true
                  local v = ld()
                  merr = check_mode(mode, v or "")
                  if merr then return nil end
                  return v
               end
            end
            chunk, msg = _load(checked_ld, source)
            if merr then return nil, merr end
         else
            chunk, msg = _load(ld, source)
         end
      end
      if not chunk then
         return chunk, msg
      end
      if env ~= nil then
         _setfenv(chunk, env)
      end
      return chunk
   end

   loadstring = load

   local _loadfile = loadfile
   loadfile = function(file, mode, env)
      mode = mode or "bt"
      if mode ~= "bt" then
         local f = io.open(file, "rb")
         if f then
            local prefix = f:read(1)
            f:close()
            if prefix then
               local merr = check_mode(mode, prefix)
               if merr then return nil, merr end
            end
         end
      end
      local chunk, msg = _loadfile(file)
      if not chunk then
         return chunk, msg
      end
      if env ~= nil then
         _setfenv(chunk, env)
      end
      return chunk
   end

   local _xpcall = xpcall
   local _unpack = unpack
   xpcall = function(f, msgh, ...)
      local args, n = { ... }, select('#', ...)
      return _xpcall(function() return f(_unpack(args, 1, n)) end, msgh)
   end

   function rawlen(v)
      local t = type(v)
      if t ~= "string" and t ~= "table" then
         error("bad argument #1 to 'rawlen' (table or string expected)", 2)
      end
      return #v
   end
   
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
      return { n = select('#', ...), ... }
   end

   table.unpack = unpack

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

   local math_log = math.log
   math.log = function(x, base)
      if base ~= nil then
         return math_log(x)/math_log(base)
      else
         return math_log(x)
      end
   end

   local p_index = { searchers = package.loaders }
   setmetatable(package, {
      __index = p_index,
      __newindex = function(p, k, v)
         if k == "searchers" then
            rawset(p, "loaders", v)
            p_index.searchers = v
         else
            rawset(p, k, v)
         end
      end
   })

   local string_gsub = string.gsub
   local function fix_pattern(pattern)
      return string_gsub(pattern, "%z", "%%z")
   end
   
   local string_find = string.find
   function string.find(s, pattern, ...)
      return string_find(s, fix_pattern(pattern), ...)
   end

   local string_gmatch = string.gmatch
   function string.gmatch(s, pattern)
      return string_find(s, fix_pattern(pattern))
   end

   function string.gsub(s, pattern, ...)
      return string_gsub(s, fix_pattern(pattern), ...)
   end

   local string_match = string.match
   function string.match(s, pattern, ...)
      return string_match(s, fix_pattern(pattern), ...)
   end

   local string_rep = string.rep
   function string.rep(s, n, sep)
      if sep ~= nil and sep ~= "" and n >= 2 then
         return s .. string_rep(sep..s, n-1)
      else
         return string_rep(s, n)
      end
   end

   local io_write = io.write
   function io.write(...)
      local res, msg, errno = io_write(...)
      if res then
         return io.output()
      else
         return nil, msg, errno
      end
   end

   do
      local file_meta = sudo_getmetatable(io.stdout)
      if type(file_meta) == "table" and type(file_meta.__index) == "table" then
         local file_write = file_meta.__index.write
         file_meta.__index.write = function(self, ...)
            local res, msg, errno = file_write(self, ...)
            if res then
               return self
            else
               return nil, msg, errno
            end
         end
      end
   end

end
