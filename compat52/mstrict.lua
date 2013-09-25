
--- Stricter version of compat52.
-- Attempts to emulate Lua 5.2 when built without LUA_COMPAT_ALL.


if _VERSION == "Lua 5.1" then

   require("compat52")

   local exclude_from_G = {
      module = true,
      getfenv = true,
      setfenv = true,
      loadstring = true,
      unpack = true,
      loadlib = true,
      math = {
         log10 = true,
         mod = true,
      },
      table = {
         getn = true,
         setn = true,
      },
      string = {
         gfind = true,
      },
   }

   local function not_available()
      error("This function is not available in Lua 5.2!", 2)
   end

   local function make_copy(value, excl)
      if not excl then
         return value
      end
      if type(value) == "table" and type(excl) == "table" then
         local newvalue = {}
         for k,v in pairs(value) do
            newvalue[k] = make_copy(v, excl[k])
         end
         return setmetatable({}, {
            __index = newvalue,
            __newindex = function(t, k, v)
               rawset(newvalue, k, v)
               rawset(value, k, v)
            end,
            __pairs = function() return pairs(newvalue) end,
            __ipairs = function() return ipairs(newvalue) end,
         }), newvalue
      else
         return not_available
      end
   end

   local new_G, G_index = make_copy(_G, exclude_from_G)
   G_index._G = new_G
   return function()
      setfenv(2, new_G)
   end
else
   return function() end
end

