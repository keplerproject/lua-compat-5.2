#include <stdio.h>
#include "lua.h"
#include "lauxlib.h"
#include "compat-5.2.h"


static int test_unsigned (lua_State *L) {
  lua_Unsigned u = luaL_checkunsigned(L, 1);
  lua_pushunsigned(L, u);
  return 1;
}

static int test_dummy (lua_State *L) {
  lua_pushstring(L, "nothing here");
  return 1;
}

static int test_upvalues (lua_State *L) {
  int i = 1;
  for (i = 1; i <= 3; ++i)
    lua_pushvalue(L, lua_upvalueindex(i));
  return 3;
}

static const luaL_Reg funcs[] = {
  { "dummy", test_dummy },
  { "unsigned", test_unsigned },
  { NULL, NULL }
};

static const luaL_Reg more_funcs[] = {
  { "getupvalues1", test_upvalues },
  { "getupvalues2", test_upvalues },
  { NULL, NULL }
};

int luaopen_testmod (lua_State *L) {
  luaL_newlib(L, funcs);
  /* defeats the purpose of luaL_newlib, but this is test code: */
  lua_pushnumber(L, 1);
  lua_pushnumber(L, 2);
  lua_pushnumber(L, 3);
  luaL_setfuncs(L, more_funcs, 3);
  return 1;
}

