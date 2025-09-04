#include "md5.h"
#include <lua.h>
#include <lauxlib.h>

static MD5_CTX md5;

static int init(lua_State *L)
{
    MD5Init(&md5);
    return 0;
}

static int update(lua_State *L)
{
    size_t len;
    const char* s = luaL_checklstring(L, 1, &len);
    MD5Update(&md5, (unsigned char*)s, len);
    return 0;
}

static int final(lua_State *L)
{
    unsigned char md5_bin[16] = {0};
    MD5Final(&md5, md5_bin);
    lua_pushlstring(L, md5_bin, 16);
    return 1;
}

static int toHex(lua_State *L)
{
    unsigned char md5_bin[16] = {0};
    unsigned char md5_hex[32] = {0};
    MD5Final(&md5, md5_bin);
    for (int i = 0; i < 16; i++)
        sprintf((char*)(md5_hex + i * 2), "%02x", md5_bin[i]);
    lua_pushlstring(L, md5_hex, 32);
    return 1;
}

static int calc(lua_State *L)
{
    size_t len;
    const char* s = luaL_checklstring(L, 1, &len);
    unsigned char md5_bin[16] = {0};
    unsigned char md5_hex[32] = {0};
    MD5Calc((uint8_t*)s, len, md5_bin);
    for (int i = 0; i < 16; i++)
        sprintf((char*)(md5_hex + i * 2), "%02x", md5_bin[i]);
    lua_pushlstring(L, md5_hex, 32);
    return 1;
}

static const struct luaL_Reg md5lib[] =
{
    {"init", init},
    {"update", update},
    {"final", final},
    {"toHex", toHex},
    {"calc", calc},
    {NULL, NULL}
};


int luaopen_md5lib(lua_State *L)
{
    luaL_register(L, "md5lib", md5lib);
    return 1;
}