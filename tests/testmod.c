#include <stdio.h>
#include "lua.h"
#include "lauxlib.h"
#include "compat-5.2.h"

#define NUP 3

static int test_tonumber (lua_State *L) {
  int isnum = 0;
  lua_Number n = lua_tonumberx(L, 1, &isnum);
  if( !isnum )
    lua_pushnil(L);
  else
    lua_pushnumber(L, n);
  return 1;
}

static int test_unsigned (lua_State *L) {
  lua_Unsigned u = luaL_checkunsigned(L, 1);
  lua_Unsigned u2 = lua_tounsigned(L, 1);
  lua_pushunsigned(L, u);
  lua_pushboolean(L, u == u2);
  return 2;
}

static int test_uservalue (lua_State *L) {
  void* udata = lua_newuserdata(L, 1);
  int ui = lua_gettop(L);
  lua_getuservalue(L, ui);
  lua_newtable(L);
  lua_setuservalue(L, ui);
  lua_getuservalue(L, ui);
  lua_pushnil(L);
  lua_setuservalue(L, ui);
  lua_getuservalue(L, ui);
  (void)udata;
  return 3;
}

static int test_dummy (lua_State *L) {
  lua_pushstring(L, "nothing here");
  return 1;
}

static int test_upvalues (lua_State *L) {
  int i = 1;
  for (i = 1; i <= NUP; ++i)
    lua_pushvalue(L, lua_upvalueindex(i));
  return NUP;
}

static const luaL_Reg funcs[] = {
  { "dummy", test_dummy },
  { "tonumber", test_tonumber },
  { "unsigned", test_unsigned },
  { "uservalue", test_uservalue },
  { NULL, NULL }
};

static const luaL_Reg more_funcs[] = {
  { "getupvalues1", test_upvalues },
  { "getupvalues2", test_upvalues },
  { NULL, NULL }
};

int luaopen_testmod (lua_State *L) {
  int i = 1;
  luaL_newlib(L, funcs);
  /* defeats the purpose of luaL_newlib, but this is test code: */
  for (i = 1; i <= NUP; ++i)
    lua_pushnumber(L, i);
  luaL_setfuncs(L, more_funcs, NUP);
  return 1;
}

