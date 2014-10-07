#pragma once

#include <Windows.h>

class download
{
public:
	download(void);
	~download(void);

	bool init(LPCTSTR lpszUrl, LPCTSTR lpszSavePath);
	void uninit();
	void wait();

private:
	static DWORD WINAPI down_proc(LPVOID lpValue);

	HANDLE m_hThread;
};

