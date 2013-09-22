#include "lua.h"
#include "lauxlib.h"

#if !defined(LUA_VERSION_NUM)
/* Lua 5.0 */
#define luaL_Reg luaL_reg

#define luaL_addchar(B,c) \
  ((void)((B)->p < ((B)->buffer+LUAL_BUFFERSIZE) || luaL_prepbuffer(B)), \
   (*(B)->p++ = (char)(c)))
#endif /* Lua 5.0 */


#if defined(LUA_VERSION_NUM) && LUA_VERSION_NUM == 501
/* Lua 5.1 */

typedef LUAI_UINT32 lua_Unsigned;

#define lua_tounsigned(L, i) lua_tounsignedx(L, i, NULL)

void lua_pushunsigned (lua_State *L, lua_Unsigned n);
lua_Unsigned luaL_checkunsigned (lua_State *L, int i);
lua_Unsigned lua_tounsignedx (lua_State *L, int i, int *isnum);

#endif /* Lua 5.1 */


#if !defined(LUA_VERSION_NUM) || LUA_VERSION_NUM == 501
/* Lua 5.0 *or* 5.1 */

#define luaL_newlib(L, l) \
  (lua_newtable((L)),luaL_setfuncs((L), (l), 0))

#endif /* Lua 5.0 *or* 5.1 */

lua_Number lua_tonumberx (lua_State *L, int i, int *isnum);
void lua_getuservalue (lua_State *L, int i);
void lua_setuservalue (lua_State *L, int i);
void luaL_setfuncs (lua_State *L, const luaL_Reg *l, int nup);

