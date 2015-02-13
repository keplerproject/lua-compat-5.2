package = "bit32"

version = "5.2.3-1"

source = {
   url = "git://github.com/hishamhm/lua-compat-5.2.git",
   tag = "bitlib-5.2.3",
}

description = {
   summary = "Lua 5.2 bit manipulation library",
   detailed = [[
      bit32 is the native Lua 5.2 bit manipulation library,
      backported to Lua 5.1
   ]],
   license = "MIT/X11",
   homepage = "http://www.lua.org/manual/5.2/manual.html#6.7",
}

dependencies = {
   "lua >= 5.1, < 5.2"
}

build = {
   type = "builtin",
   modules = {
      bit32 = {
         sources = { "lbitlib.c", "c-api/compat-5.2.c" },
         incdirs = { "c-api" },
      }
   }
}
