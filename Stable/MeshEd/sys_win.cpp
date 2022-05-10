//****************************************************************************
//**
//**    SYS_WIN.CPP
//**    System Control - Windows Interface
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include "stdtool.h"
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

//----------------------------------------------------------------------------
//    Public Data
//----------------------------------------------------------------------------

// windows stuff
//HWND sys_statusBarHwnd;

boolean sys_userException = 0;
char sys_userExceptionString[256];
char sys_programPath[256];

//----------------------------------------------------------------------------
//    Private Code Prototypes
//----------------------------------------------------------------------------
static void SetupTimer(void);
static int EvaluateException(unsigned long n_except);
static void ExceptionHandler(unsigned long e);
int WINAPI WinMain(HINSTANCE hInst, HINSTANCE hPrevInst,
				   LPSTR argList, int winMode);

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
		switch(LOWORD(wParam))
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
		for (ptr=info->choices; *ptr; ptr += fstrlen(ptr)+1)
			SendDlgItemMessage(hwnd, IDC_LB_GENERICSELECTIONBOX, LB_ADDSTRING, 0, (LPARAM)ptr);
		SendDlgItemMessage(hwnd, IDC_LB_GENERICSELECTIONBOX, LB_SETCURSEL, 0, 0);

		return(1);
		break;
	case WM_COMMAND:
		switch(LOWORD(wParam))
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
		sys_seconds_per_tick = (float)(((double)1.0)/((double)sys_ticks_per_second));
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
	return((char *)DialogBoxParam(_winapp->get_hinst(), MAKEINTRESOURCE(IDD_GENERICINPUTBOX), mesh_app.get_app_hwnd(), (DLGPROC)GenericInputBox_df, (LPARAM)&info));
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
	return((char *)DialogBoxParam(_winapp->get_hinst(), MAKEINTRESOURCE(IDD_GENERICSELECTIONBOX), mesh_app.get_app_hwnd(), (DLGPROC)GenericSelectionBox_df, (LPARAM)&info));
}

