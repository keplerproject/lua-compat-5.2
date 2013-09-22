#include <stdio.h>
#include "lua.h"
#include "lauxlib.h"
#include "compat-5.2.h"

#define NUP 3

static int test_globals (lua_State *L) {
  lua_pushglobaltable(L);
  return 1;
}

static int test_tonumber (lua_State *L) {
  int isnum = 0;
  lua_Number n = lua_tonumberx(L, 1, &isnum);
  if (!isnum)
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

static int test_optunsigned (lua_State *L) {
  lua_Unsigned u = luaL_optunsigned(L, 1, 17u);
  lua_pushunsigned(L, u);
  return 1;
}

static int test_len (lua_State *L) {
  luaL_checkany(L, 1);
  lua_len(L, 1);
  return 1;
}

static int test_udata (lua_State *L) {
  const char *tname = luaL_optstring(L, 1, "utype1");
  void *u1 = lua_newuserdata(L, 1);
  int u1pos = lua_gettop(L);
  void *u2 = lua_newuserdata(L, 1);
  int u2pos = lua_gettop(L);
  luaL_newmetatable(L, "utype1");
  luaL_newmetatable(L, "utype2");
  lua_pop(L, 2);
  luaL_setmetatable(L, "utype2");
  lua_pushvalue(L, u1pos);
  luaL_setmetatable(L, "utype1");
  lua_pop(L, 1);
  (void)u1;
  (void)u2;
  lua_pushlightuserdata(L, luaL_testudata(L, u1pos, tname));
  lua_pushlightuserdata(L, luaL_testudata(L, u2pos, tname));
  return 2;
}

static int test_uservalue (lua_State *L) {
  void *udata = lua_newuserdata(L, 1);
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

static int test_upvalues (lua_State *L) {
  int i = 1;
  for (i = 1; i <= NUP; ++i)
    lua_pushvalue(L, lua_upvalueindex(i));
  return NUP;
}

static const luaL_Reg funcs[] = {
  { "tonumber", test_tonumber },
  { "unsigned", test_unsigned },
  { "optunsigned", test_optunsigned },
  { "len", test_len },
  { "udata", test_udata },
  { "uservalue", test_uservalue },
  { "globals", test_globals },
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

