#ifndef _MESHED_H_
#define _MESHED_H_

#ifndef __AFXWIN_H__
#include <afxwin.h>
#endif
#ifndef _XCORE_H_
#include <xcore.h>
#endif
#ifndef _WINAPP_H_
#include <winapp.h>
#endif
#ifndef _VIDMAIN_H_
#include <vidmain.h>
#endif

class MeshWindow;
class OvlView;

#ifndef _CON_MAN_H_
#include <con_man.h>
#endif


class MeshEd : public XWinApp
{
	VidView			*view;
	VidIf			*vid;
	MeshWindow		*main_wnd;
	CConsoleManager *con;
	U32				app_done;

protected:
	U32 init(void);
	U32 close(void);
	void HandleMessages(void);
	U32 PreRender(void);
	void DoRender(void);
	void IPCManage(void);
	U32 vid_init(void);
	U32 create_main(U32 width,U32 height);
	
public:
	MeshEd(void) : view(null),vid(null),main_wnd(null),con(null) {}
	~MeshEd(void);

	U32 main(void);
	U32 app_close(void);
	
	VidIf *get_vidif(void){return vid;}
};

class MeshWindow : public CWnd
{
	static CC8 *class_name;
	
	U32 width,height;
	VidView *view;

public:
	MeshWindow(void) : view(null) {}
	U32 init(U32 width,U32 height);
	void render(void);
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnSize(UINT nType,int cx,int cy);
	afx_msg void OnClose(void);
	DECLARE_MESSAGE_MAP()
};

class MeshView : public CWnd
{
};

class MeshSkin : public CWnd
{
};

class MeshTools : public CWnd
{
};

class MeshResources : public CWnd
{
};

class MeshWorkspace : public CWnd
{
};

class OvlView : public CWnd
{
};

class TestError : public CError
{
public:
	void message(U32 level,CC8 *str);
	void throw_msg(U32 level,CC8 *str);
	void assert(CC8 *file,U32 line);
};

#endif /* ifndef _MESHED_H_ */
