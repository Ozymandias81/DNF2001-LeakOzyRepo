#include "stdtool.h"

/* Force the app object to load before other globals */
/* -- comments -- */
/* needed to fix retarded console code */
/* generally a good idea since so much depends on this class */
/* definately not very portable */
#pragma warning(disable:4073)
#pragma init_seg(lib)

/* setup globals */
MeshApp mesh_app;
AppError _app_error;
VidIf	*vid=null;

MeshApp::MeshApp(void) : xres(800),yres(600)
{
	_global->set_error(&_app_error);

	/* setup os_information */
	os_version.dwOSVersionInfoSize=sizeof(OSVERSIONINFO);
	GetVersionEx(&os_version);
	if (os_version.dwPlatformId==VER_PLATFORM_WIN32_NT)
	{
		/* so hopefully this will work for whistler too */
		if (os_version.dwMajorVersion>=5)
			state.is_win2k=TRUE;
	}

	U32 len_path=GetCurrentDirectory(0,null);
	app_path=(char *)xmalloc(len_path+1);
	GetCurrentDirectory(len_path,app_path);

	/* setup timer information */
	QueryPerformanceFrequency((LARGE_INTEGER *)&ticks_per_second);
	QueryPerformanceCounter((LARGE_INTEGER *)&start_tick);

	volatile double tmp=((double)1.0)/((double)ticks_per_second);
	seconds_per_tick = (float)tmp;

	frame_begin = get_cur_time();
	frame_delta = 0.0f;

	/* try and setup cmd line early so we can figure resolution */
	attempt_cmdline_early();

	init_sys_parse();

	con=new CConsoleManager;

    U32 parm;
	if (parm = sys_check_parm("vidres", 2))
    {
        xres = atoi(argv[parm+1]);
        yres = atoi(argv[parm+2]);
    }
}

void MeshApp::init_sys_parse(void)
{
	if (state.sys_parse_init)
		return;
	
	parse.init();

	state.sys_parse_init=1;
}

U32 MeshApp::app_init(void)
{
	if (!create_window())
		return FALSE;

	/* wait till application in foreground */
	while(GetForegroundWindow()!=app_wnd->get_hwnd())
	{
		if (!HandleMessages())
			return FALSE;
		Sleep(0);
	}

#if 0
	while(1)
	{
		if (!HandleMessages())
			return FALSE;
	}
#endif

	if (!vid_init())
	{
		xxx_message(ERROR_IMPORTANT,"Unable to open device with current settings");
		return FALSE;
	}

	IN_Init();
	OVL_Init();

	con->ExecuteFile(NULL, "cannibal.cfg", true);
	con->ExecuteCmdLine(NULL, argc, argv);

	return TRUE;
}

U32 MeshApp::create_window(void)
{
	app_wnd=new AppWnd;

	if (!app_wnd->Create())
		return FALSE;
	
	app_wnd->ShowWindow();
	return TRUE;
}

void simple_test(void);

U32 MeshApp::vid_init(void)
{
	HMODULE dll=LoadLibrary("drivers\\vidd3d.dll");
	if (!dll)
	{
		xxx_fatal("Unable to open driver for d3d");
		return FALSE;
	}

	vid_version=(VidVersion_f)GetProcAddress(dll,"VidVersion");
	vid_query=(VidQuery_f)GetProcAddress(dll,"VidQuery");
	vid_release=(VidRelease_f)GetProcAddress(dll,"VidRelease");

	vid_if=vid_query();
	if (!vid_if)
		return FALSE;

	vid=vid_if;

	if (!vid->init(app_wnd,xres,yres,2))
		return FALSE;

	state.allow_cursor=FALSE;
	SetCursor(null);

	vid->ClearScreen();
	vid->BeginScene();
	vid->EndScene();
	vid->Swap();

	vid->ClearScreen();
	vid->BeginScene();
	vid->EndScene();
	vid->Swap();

	//vid->Diags();

	return TRUE;
}

void simple_test(void)
{
	vid->Diags();

#if 0
	while(1)
	{
		vid->ClearScreen(0x000000FF);
		vid->BeginScene();

		vector_t tris[3];
		vector_t colors[3];

		tris[0].x=400.0f;
		tris[0].y=50.0f;
		tris[0].z=0.5f;

		colors[0].x=255.0f;
		colors[0].y=0.0f;
		colors[0].z=0.0f;

		tris[1].x=200.0f;
		tris[1].y=400.0f;
		tris[1].z=0.5f;

		colors[1].x=0.0f;
		colors[1].y=255.0f;
		colors[1].z=0.0f;

		tris[2].x=600.0f;
		tris[2].y=400.0f;
		tris[2].z=0.5f;

		colors[2].x=0.0f;
		colors[2].y=0.0f;
		colors[2].z=255.0f;

		vid->ColorWrite(TRUE);
		vid->DepthWrite(TRUE);
		vid->ColorMode(VCM_GOURAUD);
		vid->WindingMode(VWM_SHOWALL);
		vid->AlphaTestMode(VCMP_ALWAYS);
		vid->DrawTriangle(tris,colors,NULL,NULL);

		vid->EndScene();
		vid->Swap();
	}
#endif
}

U32 MeshApp::vid_close(void)
{
	vid_release();
	vid=vid_if=null;
	return TRUE;
}

U32 MeshApp::main(void)
{
	while(!state.app_exit)
	{
		if (!HandleMessages())
			break;
		/* only enter frame stuff we we are the active process */
		if ((state.active) && (state.app_active))
		{
			/* setup begin of frame */
			begin_frame();
			SYS_Frame();
			end_frame();
		}
		/* handle queued actions */
		handle_queued();
	}

	SYS_Shutdown();
	vid_close();
	DestroyWindow(get_app_hwnd());

	return TRUE;
}

void MeshApp::quit(void)
{
	PostQuitMessage(0);
}

void MeshApp::QueueConsoleAction(U32 num,CC8 **list,con_action_f func,void *data)
{
	ConQueue *q=action_queue.get_queue(num,list);

	q->set_action(func);
	q->set_data(data);

	action_queue.add_queue(q);
}

void MeshApp::handle_queued(void)
{
	action_queue.handle_actions();
}

void MeshApp::begin_frame(void)
{
	/* see if we need to reactivate the video device */
	if (state.queue_activate)
	{
		/* make sure we are active */
		/* work around funny WM_ACTIVATE behavior */
		if (GetForegroundWindow()==mesh_app.get_app_hwnd())
		{
			if (vid)
			{
				vid->Activate();
				state.vid_active=TRUE;
			}
			state.queue_activate=FALSE;
		}
		else
			state.active=FALSE;
	}

	/* adjust frame related time */
	float last_begin=frame_begin;
	frame_begin = get_cur_time();
	frame_delta = frame_begin - last_begin;

	state.in_frame=TRUE;
}

void MeshApp::end_frame(void)
{
	state.in_frame=FALSE;
}

void MeshApp::app_activate(U32 enable)
{
	if (enable)
	{
		state.app_active=TRUE;
		state.queue_activate=TRUE;
	}
	else
	{
		if (vid)
		{
			vid->Deactivate();
			state.vid_active=FALSE;
		}
		state.app_active=FALSE;
		state.queue_activate=FALSE;
	}
}

void MeshApp::activate(void)
{
	if (state.active)
		return;
	state.queue_activate=FALSE;
	state.active=TRUE;
	if (state.in_frame)
	{
		/* force application into foreground before we will move on */
		while(GetForegroundWindow()!=get_app_hwnd())
		{
			HandleMessages();
			Sleep(0);
		}

		if (vid)
		{
			vid->Activate();
			state.vid_active=TRUE;
		}
	}
	else
		state.queue_activate=TRUE;

	IN_WinAcquireKeyboard();
	IN_WinAcquireMouse();
}

void MeshApp::deactivate(void)
{
	if (!state.active)
		return;
	IN_WinUnacquireMouse();
	IN_WinUnacquireKeyboard();

	state.active=FALSE;
	if (vid)
	{
		vid->Deactivate();
		state.vid_active=FALSE;
	}
	state.queue_activate=FALSE;
}

void MeshApp::on_create(HWND hwnd)
{
	state.window=TRUE;
	_app_error.set_window(hwnd);
}

void MeshApp::on_close(void)
{
	state.window=FALSE;
	_app_error.no_window();
}

float MeshApp::get_cur_time(void)
{
	I64 time;
	float ret;

	QueryPerformanceCounter((LARGE_INTEGER *)&time);
	ret=(float)(((double)(time - start_tick)) * seconds_per_tick);
	return ret;
}

/* private afx define */
#define WM_KICKIDLE         0x036A

U32 MeshApp::HandleMessages(void)
{
	U32 count=0;

	while(1)
	{
		if (!::PeekMessage(&app_msg, NULL, NULL, NULL, PM_REMOVE))
			break;
		
		if (app_msg.message==WM_QUIT)
		{
			state.app_exit=TRUE;
			return FALSE;
		}

		if (app_msg.message==WM_KICKIDLE)
			continue;
#if 0
		if (state.is_win2k)
		{
			/* hack around loss of focus here */
			if (app_msg.message==WM_SYSKEYDOWN)
				continue;
			if (app_msg.message==WM_SYSKEYUP)
				continue;
		}
#endif
		::TranslateMessage(&app_msg);
		::DispatchMessage(&app_msg);
	}
	return TRUE;
}

CC8 *AppWnd::wnd_default_class=null;

static AppWnd *_app_wnd=null;

AppWnd::AppWnd(void) : wnd_class_name(null)
{
	D_ASSERT(!_app_wnd);
	_app_wnd=this;
}

AppWnd::~AppWnd(void)
{
	if (hwnd)
		DestroyWindow(hwnd);

	_app_wnd=null;
}

U32 AppWnd::reg_default_class(void)
{
	if (wnd_default_class)
	{
		wnd_class_name=wnd_default_class;
		return TRUE;
	}

	CC8 *class_name="MESHED_MAINWINDOW_CLASS";
	WNDCLASSEX wc;

	wc.cbSize=sizeof(WNDCLASSEX);
	wc.style=CS_DBLCLKS;
	wc.lpfnWndProc=win_messaging;
	wc.cbClsExtra=0;
	wc.cbWndExtra=0;
	wc.hInstance=_winapp->get_hinst();
	//wc.hIcon=LoadIcon(_winapp->get_hinst(),MAKEINTRESOURCE(IDI_CANNIBAL));
	wc.hIcon=null;
	wc.hCursor=LoadCursor(NULL, IDC_ARROW);
	wc.hbrBackground=GetSysColorBrush(COLOR_APPWORKSPACE);
	wc.lpszMenuName=null;
	wc.lpszClassName=class_name;
	//wc.hIconSm=LoadIcon(_winapp->get_hinst(),MAKEINTRESOURCE(IDI_CANNIBAL));
	wc.hIconSm=null;

	if (!RegisterClassEx(&wc))
		xxx_fatal("AppWnd::reg_default_class: Unable to register class");

	wnd_default_class=class_name;
	wnd_class_name=class_name;

	return TRUE;
}


U32 AppWnd::Create(void)
{
	if (!wnd_class_name)
		reg_default_class();

	hwnd=CreateWindowEx(WS_EX_APPWINDOW,
						wnd_class_name,
						"MeshEd",
						WS_OVERLAPPED | WS_CAPTION | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX |WS_VISIBLE,
						CW_USEDEFAULT,
						CW_USEDEFAULT,
						800,
						600,
						null,
						null,
						_winapp->get_hinst(),
						null);
	if (!hwnd)
	{
		U32 ret=GetLastError();
		return FALSE;
	}

	return TRUE;
}

LRESULT CALLBACK AppWnd::win_messaging(HWND Hwnd,UINT msg,UINT wparam,LONG lparam)
{
	AppWnd *that=_app_wnd;

	switch (msg)
	{
		case WM_CREATE:
			that->hwnd=Hwnd;
			mesh_app.on_create(Hwnd);
			return 0;
			break;
		case WM_SETCURSOR:
			if (!mesh_app.allow_cursor())
			{
				SetCursor(null);
				return TRUE;
			}
			break;
		case WM_ACTIVATE:
			if (wparam==WA_INACTIVE)
				mesh_app.deactivate();
			else
				mesh_app.activate();
			break;
#if 1
		case WM_SETFOCUS:
			mesh_app.activate();
			break;
		case WM_KILLFOCUS:
			mesh_app.deactivate();
			break;
#endif
		case WM_ACTIVATEAPP:
			mesh_app.app_activate(wparam);
			break;
		case WM_CLOSE:
		case WM_DESTROY:
			mesh_app.on_close();
			break;
		default:
			break;
	}
	return DefWindowProc(Hwnd,msg,wparam,lparam);
}

void AppError::break_error(CC8 *str)
{
}

void AppError::message(U32 level,CC8 *str)
{
	break_error(str);
	WinMsgDef::message(level,str);
}

void AppError::throw_msg(U32 level,CC8 *str)
{
	break_error(str);
	WinMsgDef::throw_msg(level,str);
}

void AppError::assert(CC8 *file,U32 line)
{
	break_error("assert");
	WinMsgDef::assert(file,line);
}

typedef struct
{
	DWORD         lStructSize; 
	HWND          hwndOwner; 
	HINSTANCE     hInstance; 
	LPCTSTR       lpstrFilter; 
	LPTSTR        lpstrCustomFilter; 
	DWORD         nMaxCustFilter; 
	DWORD         nFilterIndex; 
	LPTSTR        lpstrFile; 
	DWORD         nMaxFile; 
	LPTSTR        lpstrFileTitle; 
	DWORD         nMaxFileTitle; 
	LPCTSTR       lpstrInitialDir; 
	LPCTSTR       lpstrTitle; 
	DWORD         Flags; 
	WORD          nFileOffset; 
	WORD          nFileExtension; 
	LPCTSTR       lpstrDefExt; 
	LPARAM        lCustData; 
	LPOFNHOOKPROC lpfnHook; 
	LPCTSTR       lpTemplateName; 
	void *        pvReserved;
	DWORD         dwReserved;
	DWORD         FlagsEx;
}SYS_OPENFILENAME_EX;

UINT APIENTRY FileBoxHook(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	return(0);
}

CC8 *MeshApp::OpenFileBox(CC8 *maskInfo, CC8 *boxTitle, CC8 *defExt)
{
	SYS_OPENFILENAME_EX opfn;
	autochar ret_file=(char *)xmalloc(XMAX_PATH);

	memset(&opfn,0,sizeof(SYS_OPENFILENAME_EX));

	opfn.hInstance=_winapp->get_hinst();
	opfn.lStructSize=sizeof(SYS_OPENFILENAME_EX);
	opfn.FlagsEx=0;
	opfn.hwndOwner = mesh_app.get_app_hwnd();
	if (!state.is_win2k)
		opfn.lStructSize-=12;

	opfn.lpstrFilter = maskInfo;
	opfn.lpstrCustomFilter = NULL;
	opfn.nFilterIndex = 1;
	opfn.lpstrFile = ret_file;ret_file[0]=0;
	opfn.nMaxFile = XMAX_PATH;
	opfn.lpstrFileTitle = NULL;
	opfn.lpstrInitialDir = last_open_path;
    
	opfn.lpstrTitle = boxTitle;
	opfn.lpfnHook = FileBoxHook;
	opfn.Flags = OFN_LONGNAMES | OFN_FILEMUSTEXIST | OFN_PATHMUSTEXIST | OFN_ENABLEHOOK | OFN_EXPLORER;
	opfn.lpstrDefExt = defExt;
	
	if (!GetOpenFileName((OPENFILENAME *)&opfn))
	{
        U32 ret=CommDlgExtendedError();
		return(NULL);
	}

	SysGetFilePath(last_open_path,ret_file);

	return((char *)ret_file.release());
}

U32 MeshApp::OpenFileBoxMulti(CC8 *maskInfo,CC8 *boxTitle,CC8 *defExt)
{
	if (!multi_file_buffer)
		multi_file_buffer=(char *)xmalloc(XMAX_PATH * 128);

	multi_file_select=null;
	multi_file_path=null;

	SYS_OPENFILENAME_EX opfn;

	memset(&opfn,0,sizeof(SYS_OPENFILENAME_EX));

	opfn.hInstance=_winapp->get_hinst();
	opfn.lStructSize=sizeof(SYS_OPENFILENAME_EX);
	opfn.FlagsEx=0;
	opfn.hwndOwner = mesh_app.get_app_hwnd();
	if (!state.is_win2k)
		opfn.lStructSize-=12;

	opfn.lpstrFilter = maskInfo;
	opfn.lpstrCustomFilter = NULL;
	opfn.nFilterIndex = 1;
	opfn.lpstrFile = multi_file_buffer;multi_file_buffer[0]=0;
	opfn.nMaxFile = XMAX_PATH*128;
	opfn.lpstrFileTitle = NULL;
	opfn.lpstrInitialDir = last_open_path;
    
	opfn.lpstrTitle = boxTitle;
	opfn.lpfnHook = FileBoxHook;
	opfn.Flags = OFN_LONGNAMES | OFN_FILEMUSTEXIST | OFN_PATHMUSTEXIST
				| OFN_ALLOWMULTISELECT | OFN_EXPLORER | OFN_HIDEREADONLY;
	opfn.lpstrDefExt = defExt;

	if (!GetOpenFileName((OPENFILENAME *)&opfn))
	{
        U32 ret=CommDlgExtendedError();
		return(FALSE);
	}

	multi_file_path=multi_file_buffer;

	/* try and set last open path */
	CC8 *tmp=multi_file_path + fstrlen(multi_file_path) + 1;
	if (!tmp[0])
		SysGetFilePath(last_open_path,multi_file_path);
	else
	{
		last_open_path.reset();
		last_open_path << multi_file_path;
	}
	return TRUE;
}

CC8 *MeshApp::NextMultiFile(void)
{
	if (!multi_file_path)
		return null;

	autochar ret_file=(char *)xmalloc(XMAX_PATH);
	
	/* on first file or path */
	if (!multi_file_select)
	{
		multi_file_select=multi_file_path + fstrlen(multi_file_path) + 1;
		if (!multi_file_select[0])
		{
			fstrcpy(ret_file,multi_file_path);
			return ret_file.release();
		}
	}
	/* check if we are at end */
	else if (!multi_file_select[0])
	{
		multi_file_select=null;
		multi_file_path=null;
		return null;
	}
	
	char *end,*end2;

	end=fstrcpy(ret_file,multi_file_path);
	*end++=OS_SLASH;
	end2=fstrcpy(end,multi_file_select);
	multi_file_select+=(U32)(end2 - end) + 1;

	return ret_file.release();
}

CC8 *MeshApp::SaveFileBox(CC8 *maskInfo, CC8 *boxTitle, CC8 *defExt)
{
	SYS_OPENFILENAME_EX opfn;
	autochar ret_file=(char *)xmalloc(XMAX_PATH);

	opfn.hInstance=_winapp->get_hinst();
	opfn.lStructSize=sizeof(SYS_OPENFILENAME_EX);
	opfn.FlagsEx=0;
	if (!state.is_win2k)
		opfn.lStructSize-=12;

	opfn.hwndOwner = mesh_app.get_app_hwnd();
	opfn.lpstrFilter = maskInfo;
	opfn.lpstrCustomFilter = NULL;
	opfn.nFilterIndex = 1;
	opfn.lpstrFile = ret_file;ret_file[0]=0;
	opfn.nMaxFile = XMAX_PATH;
	opfn.lpstrFileTitle = NULL;
	opfn.lpstrInitialDir = last_save_path;

	opfn.lpstrTitle = boxTitle;
	opfn.lpfnHook = FileBoxHook;
	opfn.Flags = OFN_LONGNAMES | OFN_ENABLEHOOK | OFN_EXPLORER | OFN_OVERWRITEPROMPT;
	opfn.lpstrDefExt = defExt;
	if (!GetSaveFileName((OPENFILENAME *)&opfn))
		return(NULL);

	SysGetFilePath(last_save_path,ret_file);
    return((char *)ret_file.release());
}
