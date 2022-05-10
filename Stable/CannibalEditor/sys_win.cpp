//****************************************************************************
//**
//**    SYS_WIN.CPP
//**    System Control - Windows Interface
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include <windows.h>
#include <windowsx.h>
#include <commctrl.h>
#include <direct.h>

#include "cbl_defs.h"
#include "sys_win.h"
#include "in_win.h"
//----------------------------------------------------------------------------
//    Private Definitions
//----------------------------------------------------------------------------
#define WINDOWFUNC(name) \
	LRESULT CALLBACK name(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
#define DIALOGBOXFUNC(name) \
	BOOL CALLBACK name(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)

#define ID_STATUSBAR 51515
#define SBTIMER_NONE 51512

//----------------------------------------------------------------------------
//    Private Structures
//----------------------------------------------------------------------------
typedef struct
{
	char *caption;
	char *text;
	char *definput;
} inputBoxInfo_t;

typedef struct
{
	char *caption;
	char *text;
	char *choices;
} selectionBoxInfo_t;

//----------------------------------------------------------------------------
//    Additional External References
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Data
//----------------------------------------------------------------------------

// timer
static int sys_statusTimer = SBTIMER_NONE;
static _int64 sys_ticks_per_second;
static float sys_seconds_per_tick;
static int sys_PerformanceTimerPresent;
static _int64 sys_StartTimePC;
static DWORD sys_StartTimeMM;

// settings
CONVAR(boolean,sys_exceptionhandler, 0, 0, NULL);
static boolean sys_paused = 0;

static OSVERSIONINFO os_version;

//----------------------------------------------------------------------------
//    Public Data
//----------------------------------------------------------------------------

// windows stuff
HINSTANCE sys_hInst;
HWND sys_hwnd;
HWND sys_statusBarHwnd;

int sys_argc;
char **sys_argv;
boolean sys_userException = 0;
char sys_userExceptionString[256];
char sys_programPath[256];
U32 is_win2k=FALSE;

//----------------------------------------------------------------------------
//    Private Code Prototypes
//----------------------------------------------------------------------------
static WINDOWFUNC(MainWindow_wf);
static void SetupTimer(void);
static int EvaluateException(unsigned long n_except);
static void ExceptionHandler(unsigned long e);
int WINAPI WinMain(HINSTANCE hInst, HINSTANCE hPrevInst,
				   LPSTR argList, int winMode);
//----------------------------------------------------------------------------
//    Private Code
//----------------------------------------------------------------------------
static WINDOWFUNC(MainWindow_wf)
{
	switch(msg)
	{
	case WM_SETFOCUS:
		IN_WinAcquireKeyboard();
		IN_WinAcquireMouse();
		if (vid_dllActive)
			vid.Activate();
		break;
	case WM_KILLFOCUS:
		IN_WinUnacquireMouse();
		IN_WinUnacquireKeyboard();
		if (vid_dllActive)
			vid.Deactivate();
		break;
	case WM_CLOSE:
	case WM_DESTROY:
	case WM_QUIT:
        SYS_Quit();
		return(0);
		break;
	default:
		break;
	}
	return(DefWindowProc(hwnd, msg, wParam, lParam));
}

static DIALOGBOXFUNC(GenericInputBox_df)
{
	static char outbuffer[1024];
	inputBoxInfo_t *info;
	RECT rect;

	switch(msg)
	{
	case WM_INITDIALOG:
		GetWindowRect(hwnd, &rect);
		SetWindowPos(hwnd, HWND_TOP,
			(GetSystemMetrics(SM_CXSCREEN)-(rect.right-rect.left))/2,
			(GetSystemMetrics(SM_CYSCREEN)-(rect.bottom-rect.top))/2,
			rect.right-rect.left, rect.bottom-rect.top, SWP_SHOWWINDOW);		
		info = (inputBoxInfo_t *)lParam;
		SetWindowText(hwnd, info->caption);
		SetDlgItemText(hwnd, IDC_ST_GENERICINPUTBOX, info->text);
		SetDlgItemText(hwnd, IDC_EB_GENERICINPUTBOX, info->definput);
		return(1);
		break;
	case WM_COMMAND:
		switch(GET_WM_COMMAND_ID(wParam, lParam))
		{
		case IDCANCEL:
			EndDialog(hwnd, (unsigned long)NULL);
			break;
		case IDOK:
			GetDlgItemText(hwnd, IDC_EB_GENERICINPUTBOX, outbuffer, 1023);
			EndDialog(hwnd, (unsigned long)outbuffer);
			break;
		default:
			break;
		}
		break;
	}
	return(0);
}

static DIALOGBOXFUNC(GenericSelectionBox_df)
{
	static char outbuffer[1024];
	selectionBoxInfo_t *info;
	RECT rect;
	char *ptr;
	int selitem;

	switch(msg)
	{
	case WM_INITDIALOG:
		GetWindowRect(hwnd, &rect);
		SetWindowPos(hwnd, HWND_TOP,
			(GetSystemMetrics(SM_CXSCREEN)-(rect.right-rect.left))/2,
			(GetSystemMetrics(SM_CYSCREEN)-(rect.bottom-rect.top))/2,
			rect.right-rect.left, rect.bottom-rect.top, SWP_SHOWWINDOW);		
		info = (selectionBoxInfo_t *)lParam;
		SetWindowText(hwnd, info->caption);
		SetDlgItemText(hwnd, IDC_ST_GENERICSELECTIONBOX, info->text);
		ptr = info->choices;
		for (ptr=info->choices; *ptr; ptr += strlen(ptr)+1)
			SendDlgItemMessage(hwnd, IDC_LB_GENERICSELECTIONBOX, LB_ADDSTRING, 0, (LPARAM)ptr);
		SendDlgItemMessage(hwnd, IDC_LB_GENERICSELECTIONBOX, LB_SETCURSEL, 0, 0);

		return(1);
		break;
	case WM_COMMAND:
		switch(GET_WM_COMMAND_ID(wParam, lParam))
		{
		case IDCANCEL:
			EndDialog(hwnd, (unsigned long)NULL);
			break;
		case IDOK:
			if ((selitem = SendDlgItemMessage(hwnd, IDC_LB_GENERICSELECTIONBOX, LB_GETCURSEL, 0, 0)) == LB_ERR)
				EndDialog(hwnd, (unsigned long)NULL);
			SendDlgItemMessage(hwnd, IDC_LB_GENERICSELECTIONBOX, LB_GETTEXT, selitem, (LPARAM)outbuffer);
			EndDialog(hwnd, (unsigned long)outbuffer);
			break;
		default:
			break;
		}
		break;
	}
	return(0);
}

static void SetupTimer(void)
{
	if (!QueryPerformanceFrequency((LARGE_INTEGER *)&sys_ticks_per_second))
	{
		sys_StartTimeMM = timeGetTime();
		sys_PerformanceTimerPresent = FALSE;
	}
	else
	{
		QueryPerformanceCounter((LARGE_INTEGER *)&sys_StartTimePC);
		sys_seconds_per_tick = ((double)1.0)/((double)sys_ticks_per_second);
		sys_PerformanceTimerPresent = TRUE;
	}
}

int SYS_EvaluateException(unsigned long n_except)
{	
	if ( n_except == STATUS_INTEGER_OVERFLOW ||
		 n_except == STATUS_FLOAT_UNDERFLOW ||
		 n_except == STATUS_FLOAT_OVERFLOW )
		 return(EXCEPTION_CONTINUE_SEARCH); // ignore these

	if (sys_exceptionhandler)
	{ // exception handler is active, try to shut everything down and let the error get caught
		return(EXCEPTION_EXECUTE_HANDLER);
	}
	else
	{ // no exception handler, let it slide through (if the debugger is active, it should catch it)
		return(EXCEPTION_CONTINUE_SEARCH);
	}
}

void SYS_ExceptionHandler(unsigned long e)
{
	static char *disclaimer = "\nPlease write down the information given above and let Chris know of the error.";
	switch(e)
	{
	case EXCEPTION_ACCESS_VIOLATION:			SYS_Error("Fatal Exception: Access Violation\n%s\n", disclaimer); break;
	case EXCEPTION_ARRAY_BOUNDS_EXCEEDED:		SYS_Error("Fatal Exception: Array Bounds Exceeded\n%s\n", disclaimer); break;
	case EXCEPTION_BREAKPOINT:					SYS_Error("Fatal Exception: Breakpoint\n%s\n", disclaimer); break;
	case EXCEPTION_DATATYPE_MISALIGNMENT:		SYS_Error("Fatal Exception: Datatype Misalignment\n%s\n", disclaimer); break;
	case EXCEPTION_FLT_DENORMAL_OPERAND:		SYS_Error("Fatal Exception: Float Denormal Operand\n%s\n", disclaimer); break;
	case EXCEPTION_FLT_DIVIDE_BY_ZERO:			SYS_Error("Fatal Exception: Float Divide By Zero\n%s\n", disclaimer); break;
	case EXCEPTION_FLT_INEXACT_RESULT:			SYS_Error("Fatal Exception: Float Inexact Result\n%s\n", disclaimer); break;
	case EXCEPTION_FLT_INVALID_OPERATION:		SYS_Error("Fatal Exception: Float Invalid Operation\n%s\n", disclaimer); break;
	case EXCEPTION_FLT_OVERFLOW:				SYS_Error("Fatal Exception: Float Overflow\n%s\n", disclaimer); break;
	case EXCEPTION_FLT_STACK_CHECK:				SYS_Error("Fatal Exception: Float Stack Check\n%s\n", disclaimer); break;
	case EXCEPTION_FLT_UNDERFLOW:				SYS_Error("Fatal Exception: Float Underflow\n%s\n", disclaimer); break;
	case EXCEPTION_ILLEGAL_INSTRUCTION:			SYS_Error("Fatal Exception: Illegal Instruction\n%s\n", disclaimer); break;
	case EXCEPTION_IN_PAGE_ERROR:				SYS_Error("Fatal Exception: In-page Error\n%s\n", disclaimer); break;
	case EXCEPTION_INT_DIVIDE_BY_ZERO:			SYS_Error("Fatal Exception: Integer Divide By Zero\n%s\n", disclaimer); break;
	case EXCEPTION_INT_OVERFLOW:				SYS_Error("Fatal Exception: Integer Overflow\n%s\n", disclaimer); break;
	case EXCEPTION_INVALID_DISPOSITION:			SYS_Error("Fatal Exception: Invalid Disposition\n%s\n", disclaimer); break;
	case EXCEPTION_NONCONTINUABLE_EXCEPTION:	SYS_Error("Fatal Exception: Noncontinuable Exception\n%s\n", disclaimer); break;
	case EXCEPTION_PRIV_INSTRUCTION:			SYS_Error("Fatal Exception: Private Instruction\n%s\n", disclaimer); break;
	case EXCEPTION_SINGLE_STEP:					SYS_Error("Fatal Exception: Single-step\n%s\n", disclaimer); break;
	case EXCEPTION_STACK_OVERFLOW:				SYS_Error("Fatal Exception: Stack Overflow\n%s\n", disclaimer); break;
	default:
		if (sys_userException)
		{
			SYS_Error("Fatal Exception: %s\n%s\n", sys_userExceptionString, disclaimer); break;
		}
		else
		{
			SYS_Error("Fatal Exception: Unknown: %x\n%s\n", e, disclaimer); break;
		}
	}
}

int WINAPI WinMain(HINSTANCE hInst, HINSTANCE hPrevInst,
				   LPSTR argList, int winMode)
{
	MSG msg  ={ NULL, 0, 0, 0, 0, { 0, 0 } };  // NJS: Just changed this to get rid of that 'msg may have been used without being initialized warning'.
	WNDCLASSEX wcl;
	unsigned long exceptval;

	os_version.dwOSVersionInfoSize=sizeof(OSVERSIONINFO);
	GetVersionEx(&os_version);
	is_win2k=FALSE;
	if (os_version.dwPlatformId==VER_PLATFORM_WIN32_NT)
	{
		/* so hopefully this will work for whistler too */
		if (os_version.dwMajorVersion>=5)
			is_win2k=TRUE;
	}

	InitCommonControls(); // initialize standard windows common controls
	sys_hInst = hInst; // set up global instance
	SetupTimer(); // initialize system timer
	sys_argc = __argc;
	sys_argv = __argv;
	_getcwd(sys_programPath, 256);

	// Register main window class
	wcl.style = CS_DBLCLKS;
	wcl.cbSize = sizeof(WNDCLASSEX);
	wcl.hIcon = LoadIcon(sys_hInst, MAKEINTRESOURCE(IDI_CANNIBAL));
	wcl.hIconSm = LoadIcon(sys_hInst, MAKEINTRESOURCE(IDI_CANNIBAL));
	wcl.hCursor = LoadCursor(NULL, IDC_ARROW);
	wcl.lpszMenuName = NULL;
	//wcl.lpszMenuName = MAKEINTRESOURCE(IDM_CANNIBAL);
	wcl.cbClsExtra = 0;
	wcl.cbWndExtra = 0;
	wcl.hInstance = sys_hInst;
	wcl.lpszClassName = "CANNIBAL_MAINWINDOW";
	wcl.lpfnWndProc = MainWindow_wf;
	wcl.hbrBackground = (HBRUSH)GetStockObject(DKGRAY_BRUSH);
	if (!RegisterClassEx(&wcl))
		return(false);

	// Create main window
	sys_hwnd = CreateWindowEx(WS_EX_APPWINDOW, "CANNIBAL_MAINWINDOW",
		"Cannibal",
		WS_POPUP | WS_OVERLAPPED | WS_CAPTION | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX | WS_MAXIMIZE,
		//0, 0, GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN),
		CW_USEDEFAULT, CW_USEDEFAULT, 640, 480, 
		HWND_DESKTOP, NULL, sys_hInst, NULL);
	if (!sys_hwnd)
		return(false);

	// Display main window
	ShowWindow(sys_hwnd, winMode);
	UpdateWindow(sys_hwnd);

	// Call application startup stuff
	SYS_Init();

	__try
	{
		while (1)
		{
			if(PeekMessage(&msg,sys_hwnd, 0, 0, PM_REMOVE))
			{
				TranslateMessage(&msg);
				DispatchMessage(&msg);
			}
			if (!sys_paused)
				SYS_Frame();
		}
	}
	__except(SYS_EvaluateException(exceptval = GetExceptionCode()))
	{
		SYS_ExceptionHandler(exceptval);
	}

	SYS_Shutdown();

	return(msg.wParam);
}

float SYS_GetTimeFloat()
{
	_int64 time;

	if (sys_PerformanceTimerPresent)
	{
		QueryPerformanceCounter((LARGE_INTEGER *)&time);
		return( ((float)(time-sys_StartTimePC)) * sys_seconds_per_tick );
	}
	else
	{
		return( ((float)(timeGetTime()-sys_StartTimeMM)) * (1.0f/1000.0f) );
	}
}

void SYS_PlaySound(char *filename)
{
	PlaySound(filename, NULL, SND_FILENAME|SND_ASYNC);
}

char *SYS_InputBox(char *caption, char *definput, char *text, ...)
{
	static char tbuffer[1024];
	va_list args;	
	inputBoxInfo_t info;

	info.caption = caption;
	info.definput = definput;
	va_start(args, text);
	vsprintf(tbuffer, text, args);
	va_end(args);
	info.text = tbuffer;
	return((char *)DialogBoxParam(sys_hInst, MAKEINTRESOURCE(IDD_GENERICINPUTBOX), sys_hwnd, (DLGPROC)GenericInputBox_df, (LPARAM)&info));
}

char *SYS_SelectionBox(char *caption, char *choices, char *text, ... )
{
	static char tbuffer[1024];
	va_list args;	
	selectionBoxInfo_t info;

	info.caption = caption;
	info.choices = choices;
	va_start(args, text);
	vsprintf(tbuffer, text, args);
	va_end(args);
	info.text = tbuffer;
	return((char *)DialogBoxParam(sys_hInst, MAKEINTRESOURCE(IDD_GENERICSELECTIONBOX), sys_hwnd, (DLGPROC)GenericSelectionBox_df, (LPARAM)&info));
}

UINT APIENTRY FileBoxHook(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	//HDC memdc;
	switch(msg)
	{
	case WM_CREATE:
		SendMessage(sys_hwnd, WM_KILLFOCUS, (WPARAM)hwnd, 0);
		return(0);
		break;
	case WM_DESTROY:
		SendMessage(sys_hwnd, WM_SETFOCUS, 0, 0);
		return(0);
		break;
	default:
		break;
	}
	return(0);
}

static char sys_mfbPath[_MAX_PATH] = {0};
static char *sys_mfbFileList = NULL;
static int sys_mfbFirstFile = 0;
static char ofnLastPath[_MAX_PATH] = {0};
static char fileNameBuf[_MAX_PATH*64];

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

char *SYS_OpenFileBox(char *maskInfo, char *boxTitle, char *defExt)
{
	SYS_OPENFILENAME_EX opfn;
	char start_path[MAX_PATH];

	opfn.lStructSize=sizeof(SYS_OPENFILENAME_EX);
	opfn.FlagsEx=0;
	if (!is_win2k)
		opfn.lStructSize-=12;

	opfn.hwndOwner = sys_hwnd;
	opfn.lpstrFilter = maskInfo;
	opfn.lpstrCustomFilter = NULL;
	opfn.nFilterIndex = 1;
	opfn.lpstrFile = fileNameBuf;
	opfn.nMaxFile = _MAX_PATH;
	opfn.lpstrFileTitle = NULL;
	opfn.lpstrInitialDir = NULL;
    if (ofnLastPath[0])
        opfn.lpstrInitialDir = ofnLastPath;
	else
	{
		GetCurrentDirectory(MAX_PATH,start_path);
		opfn.lpstrInitialDir = start_path; 
	}
	opfn.lpstrTitle = boxTitle;
	opfn.lpfnHook = FileBoxHook;
	opfn.Flags = OFN_LONGNAMES | OFN_FILEMUSTEXIST | OFN_PATHMUSTEXIST | OFN_ENABLEHOOK | OFN_EXPLORER | OFN_HIDEREADONLY;
	opfn.lpstrDefExt = defExt;
	
	if (!GetOpenFileName((OPENFILENAME *)&opfn))
        return(NULL);
	strcpy(ofnLastPath, SYS_GetFilePath(fileNameBuf));
    if (ofnLastPath[strlen(ofnLastPath)-1] == '\\')
        ofnLastPath[strlen(ofnLastPath)-1] = 0;
    return(fileNameBuf);
}

int SYS_OpenFileBoxMulti(char *maskInfo, char *boxTitle, char *defExt)
{
	OPENFILENAME opfn;
	opfn.lStructSize = sizeof(OPENFILENAME);
	opfn.hwndOwner = sys_hwnd;
	opfn.lpstrFilter = maskInfo;
	opfn.lpstrCustomFilter = NULL;
	opfn.nFilterIndex = 1;
	opfn.lpstrFile = fileNameBuf;
	opfn.nMaxFile = _MAX_PATH*64;
	opfn.lpstrFileTitle = NULL;
	opfn.lpstrInitialDir = NULL;
    if (ofnLastPath[0])
        opfn.lpstrInitialDir = ofnLastPath;
	opfn.lpstrTitle = boxTitle;
	opfn.Flags = OFN_LONGNAMES | OFN_FILEMUSTEXIST | OFN_PATHMUSTEXIST
		| OFN_ALLOWMULTISELECT | OFN_EXPLORER | OFN_HIDEREADONLY;
	opfn.lpstrDefExt = defExt;
	if (!GetOpenFileName(&opfn))
		return(0);
	sys_mfbFileList = fileNameBuf+strlen(fileNameBuf)+1;
	strcpy(sys_mfbPath, fileNameBuf);
	fileNameBuf[0] = 0;
	sys_mfbFirstFile = true;
	strcpy(ofnLastPath, sys_mfbPath);
    if (ofnLastPath[strlen(ofnLastPath)-1] == '\\')
        ofnLastPath[strlen(ofnLastPath)-1] = 0;
	return(1);
}

char *SYS_NextMultiFile()
{
	static char nameBuffer[_MAX_PATH];
	if (!sys_mfbFirstFile)
	{
		if (!sys_mfbFileList[0])
			return(NULL);
	}
	else
	{
		sys_mfbFirstFile = false;
		if (!sys_mfbFileList[0])
			return(sys_mfbPath);
	}
	strcpy(nameBuffer, sys_mfbPath);
	strcat(nameBuffer, "\\");
	strcat(nameBuffer, sys_mfbFileList);
	sys_mfbFileList += strlen(sys_mfbFileList)+1;
	return(nameBuffer);
}

char *SYS_SaveFileBox(char *maskInfo, char *boxTitle, char *defExt)
{
	OPENFILENAME opfn;
	opfn.lStructSize = sizeof(OPENFILENAME);
	opfn.hwndOwner = sys_hwnd;
	opfn.lpstrFilter = maskInfo;
	opfn.lpstrCustomFilter = NULL;
	opfn.nFilterIndex = 1;
	opfn.lpstrFile = fileNameBuf;
	opfn.nMaxFile = _MAX_PATH;
	opfn.lpstrFileTitle = NULL;
	opfn.lpstrInitialDir = NULL;
    if (ofnLastPath[0])
        opfn.lpstrInitialDir = ofnLastPath;
	opfn.lpstrTitle = boxTitle;
	opfn.lpfnHook = FileBoxHook;
	opfn.Flags = OFN_LONGNAMES | OFN_ENABLEHOOK | OFN_EXPLORER | OFN_OVERWRITEPROMPT | OFN_HIDEREADONLY;
	opfn.lpstrDefExt = defExt;
	if (!GetSaveFileName(&opfn))
		return(NULL);
	strcpy(ofnLastPath, SYS_GetFilePath(fileNameBuf));
    if (ofnLastPath[strlen(ofnLastPath)-1] == '\\')
        ofnLastPath[strlen(ofnLastPath)-1] = 0;
    return(fileNameBuf);
}

//----------------------------------------------------------------------------
//    Public Code
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Class Member Code
//----------------------------------------------------------------------------


//****************************************************************************
//**
//**    END MODULE SYS_WIN.CPP
//**
//****************************************************************************

