
--- Stricter version of compat52.
-- Attempts to emulate Lua 5.2 when built without LUA_COMPAT_ALL.

require("compat52")

if _VERSION == "Lua 5.1" then

   module = nil
   setfenv = nil
   getfenv = nil
   math.log10 = nil
   loadstring = nil
   table.maxn = nil
   unpack = nil

end
