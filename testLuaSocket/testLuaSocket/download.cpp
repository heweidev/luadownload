#include "StdAfx.h"
#include "download.h"
#include "lua.hpp"
#include <string>
#include <atlbase.h>
#include <atlconv.h>

struct ThreadData
{
	std::wstring mUrl;
	std::wstring mSavePath;
};

download::download(void)
{
}

download::~download(void)
{
}

bool download::init(LPCTSTR lpszUrl, LPCTSTR lpszSavePath)
{
	ThreadData* pData = new ThreadData();
	pData->mUrl = lpszUrl;
	pData->mSavePath = lpszSavePath;

	DWORD dwThreadId = 0;
	m_hThread = CreateThread(NULL, 0, down_proc, pData, 0, &dwThreadId);
	return m_hThread != NULL;
}

void download::uninit()
{
	if (m_hThread != NULL)
	{
		CloseHandle(m_hThread);
		m_hThread = NULL;
	}
}

void download::wait()
{
	if (m_hThread == NULL)
	{
		return;
	}

	WaitForSingleObject(m_hThread, INFINITE);
	DWORD dwRet = 0;
	BOOL bOK = GetExitCodeThread(m_hThread, &dwRet);
	printf("thread ret = %d\n", dwRet);
}

DWORD WINAPI download::down_proc(LPVOID lpValue)
{
	char luaScriptPath[] = "H:\\lua_download\\luadownload\\download.lua";
	ThreadData* pData = (ThreadData*) lpValue;

	if (pData == NULL)
	{
		return 1;
	}

	lua_State* L = luaL_newstate();
	luaL_openlibs(L);

	int ret = luaL_loadfile(L, luaScriptPath);
	if (ret != 0 )
	{
		printf("load lua script error: err = %s\n", luaL_checkstring(L, -1));
		goto clean;
	}

	lua_pushstring(L, CT2A(pData->mUrl.c_str()));
	lua_pushstring(L, CT2A(pData->mSavePath.c_str()));

	ret = lua_pcall(L, 2, 0, 0);
	if (ret != 0)
	{
		printf("call lua script error: err = %s\n", luaL_checkstring(L, -1));
		goto clean;
	}
	
clean:
	delete pData;
	pData = NULL;

	lua_close(L);
	return 0;
}


