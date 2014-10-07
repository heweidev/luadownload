#include "stdafx.h"
#include "lua.hpp"
#include "download.h"

/*
	cmd: a 
	params: url, savepath
	ret: taskid
*/

#define TEST_LINK		L"http://dlsw.baidu.com/sw-search-sp/soft/3a/12350/QQ6.4.1411525511.exe"
//#define TEST_LINK		L"http://dlsw.baidu.com/sw-search-sp/soft/7b/26860/ThunderSpeed1.0.15.168.1411009942.exe"
#define TEST_SAVEPATH	L"d:\\test_download.exe"

int _tmain(int argc, _TCHAR* argv[])
{
	download* down = new download();
	down->init(TEST_LINK, TEST_SAVEPATH);
	down->wait();
	down->uninit();
	delete down;
	return 0;
}