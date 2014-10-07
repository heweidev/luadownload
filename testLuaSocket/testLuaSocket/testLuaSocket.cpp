// testLuaSocket.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"
#include "lua.hpp"

extern "C" {
#include "except.h"
}

/*
int _tmain(int argc, _TCHAR* argv[])
{
	lua_State* L = luaL_newstate();
	luaL_openlibs(L);
	
	lua_newtable(L);
	except_open(L);
	lua_setglobal(L, "except");

	luaL_loadfile(L, "H:\\lua_download\\luadownload\\test.lua");
	int ret = lua_pcall(L, 0, 0, 0);
	if (ret != 0)
	{
		printf("call err: %s\n", luaL_checkstring(L, -1));
	}

	lua_close(L);
	return 0;
}
*/

