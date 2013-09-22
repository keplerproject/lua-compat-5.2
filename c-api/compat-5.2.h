#include "lua.h"
#include "lauxlib.h"
#if !defined LUA_VERSION_NUM
/* Lua 5.0 */
#define luaL_Reg luaL_reg

#define luaL_addchar(B,c) \
  ((void)((B)->p < ((B)->buffer+LUAL_BUFFERSIZE) || luaL_prepbuffer(B)), \
   (*(B)->p++ = (char)(c)))
#endif

#if !defined(LUA_VERSION_NUM) || LUA_VERSION_NUM == 501

typedef LUAI_UINT32 lua_Unsigned;

#define lua_tounsigned(L, i) lua_tounsignedx(L, i, NULL)

#define lua_getuservalue(L, i) ((void)lua_getfenv(L, i))
#define lua_setuservalue(L, i) \
  do { \
    lua_State *_l = L; \
    if (lua_isnil(_l, -1)) { \
      lua_newtable(_l); \
      lua_replace(_l, -2); \
    } \
    lua_setfenv(_l, i); \
  } while(0)

#define luaL_newlib(L, l) \
  (lua_newtable((L)),luaL_setfuncs((L), (l), 0))

#endif
void luaL_setfuncs (lua_State *L, const luaL_Reg *l, int nup);
void lua_pushunsigned (lua_State *L, lua_Unsigned n);
lua_Unsigned luaL_checkunsigned (lua_State *L, int i);
lua_Unsigned lua_tounsignedx (lua_State *L, int i, int *isnum);

