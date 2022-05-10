#ifndef _XWND_H_
#define _XWND_H_

class XWnd
{
protected:
	HWND hwnd;
public:
	XWnd(void);
	inline U32 ShowWindow(U32 cmd_show=SW_SHOW){return ::ShowWindow(hwnd,cmd_show);}
	inline HWND get_hwnd(void){return hwnd;}
};

#endif /* ifndef _XWND_H_ */
