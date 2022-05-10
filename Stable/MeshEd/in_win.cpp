//****************************************************************************
//**
//**    IN_WIN.CPP
//**    Input - Windows DirectInput Interface
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include "stdtool.h"
#include <windowsx.h>
#include <commctrl.h>
#include <dinput.h>
//----------------------------------------------------------------------------
//    Private Definitions
//----------------------------------------------------------------------------
#define DINPUT_BUFFERSIZE		128

//----------------------------------------------------------------------------
//    Private Structures
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Additional External References
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Data
//----------------------------------------------------------------------------
static LPDIRECTINPUT lpDI=NULL;
static LPDIRECTINPUTDEVICE lpMouse=NULL;
static LPDIRECTINPUTDEVICE lpKeyboard=NULL;
static DIDEVCAPS DICaps;
static unsigned char keyStates[IN_NUMKEYS];
static unsigned char oldKeyStates[IN_NUMKEYS];
static int keyMouseDragPositions[IN_NUMKEYS][2];
static float keyPressTimes[IN_NUMKEYS];
static U32 MouseButtonStatus[IN_NUMMOUSEKEYS];
static int in_MinX=1, in_MinY=1, in_MaxX=638, in_MaxY=478;

static U8 ScanToASCII[IN_NUMKEYS] =
{
	0,					KEY_ESCAPE,			'1',	 			'2',
	'3',    			'4',					'5',		  		'6',
	'7',    			'8',					'9',    			'0',
	'-',    			'=',					KEY_BACKSPACE,	KEY_TAB,		// 0
	'q',    			'w',			  		'e',    			'r',
	't',    			'y',			  		'u',				'i',
	'o',    			'p',					'[',    			']',
	KEY_ENTER,		KEY_CTRL,/*CONTROL*/		'a',  			's',      	// 1
	'd',    			'f',    				'g',	   		'h',
	'j',    			'k',					'l',		  		';',
	39 ,    			'`',					KEY_SHIFT, 		'\\',//(92 for backslash?)
	'z',    			'x',					'c',    			'v',      	// 2
	'b',    			'n',					'm',    			',',
	'.',    			'/',					KEY_SHIFT,		KEY_KP_STAR,
	KEY_LALT,		KEY_SPACE,			KEY_CAPS,   	KEY_F1,
	KEY_F2, 			KEY_F3, 				KEY_F4, 			KEY_F5,   	// 3
	KEY_F6, 			KEY_F7, 				KEY_F8, 			KEY_F9,
	KEY_F10,			0,/*NUMLOCK*/		KEY_SCROLL,		KEY_KP7,
	KEY_KP8,	KEY_KP9,			KEY_KP_MINUS,				KEY_KP4,
	KEY_KP5,				KEY_KP6,	KEY_KP_PLUS,				KEY_KP1, 	// 4
	KEY_KP2,	KEY_KP3,			KEY_KP0,			KEY_KP_PERIOD,
	0,					0,						0,					KEY_F11,
	KEY_F12,			0,						0,    			0,
	0,    			0,    				0,    			0,        	// 5
	0,    			0,    				0,    			0,
	0,					0,						0,					0,
	0,    			0,    				0,    			0,
	0,    			0,    				0,    			0,        	// 6
	0,					0,    				0,    			0,
	0,    			0,    				0,    			0,
	0,    			0,						0,    			0,
	0,    			0,						0,    			0,         	// 7
	0,					0,    				0,    			0,
	0,    			0,    				0,    			0,
	0,    			0,						0,    			0,
	0,    			0,						0,    			0,         	// 8
	0,					0,    				0,    			0,
	0,    			0,    				0,    			0,
	0,    			0,						0,    			0,
	KEY_KP_ENTER,		KEY_CTRL,/*CONTROL*/		0,    			0,         	// 9
	0,					0,    				0,    			0,
	0,    			0,    				0,    			0,
	0,    			0,						0,    			0,
	0,    			0,						0,    			0,         	// A
	0,					0,    				0,    			0,
	0,    			KEY_KP_SLASH,    				0,    			KEY_PRINT,
	KEY_RALT,		0,						0,    			0,
	0,    			0,						0,    			0,         	// B
	0,					0,    				0,    			0,
	0,    			0,    				0,    			KEY_HOME,
	KEY_UPARROW,	KEY_PGUP,			0,    			KEY_LEFTARROW,
	0,    			KEY_RIGHTARROW,	0,    			KEY_END,		// C
	KEY_DOWNARROW,	KEY_PGDN,			KEY_INS,			KEY_DEL,
	0,    			0,    				0,    			0,
	0,    			0,						0,    			0,/*LWIN*/
	0,/*RWIN*/		0,/*APPMENU*/		0,    			0,         	// D
	0,					0,    				0,    			0,
	0,    			0,    				0,    			0,
	0,    			0,						0,    			0,
	0,    			0,						0,    			0         	// E
};

//----------------------------------------------------------------------------
//    Public Data
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Code
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Code
//----------------------------------------------------------------------------
void IN_WinInit()
{	
    GUID guid;
	DIPROPDWORD dipdw =
	{
		{
			sizeof(DIPROPDWORD),			// diph.dwSize
			sizeof(DIPROPHEADER),		// diph.dwHeaderSize
			0,									// diph.dwObj
			DIPH_DEVICE,					// diph.dwHow
		},
		DINPUT_BUFFERSIZE,				// dwData
	};

    in_MaxX = vid->res.width - 2;
    in_MaxY = vid->res.height - 2;

	if (DirectInput8Create(_winapp->get_hinst(), DIRECTINPUT_VERSION, IID_IDirectInput8, (void **)&lpDI, NULL) != DI_OK)	 
		SYS_Error("IN_WinInit failure");

	// KEYBOARD
	guid = GUID_SysKeyboard;
	if (lpDI->CreateDevice(guid, &lpKeyboard, NULL) != DI_OK)
		SYS_Error("IN_WinInit failure");

	if (lpKeyboard->SetDataFormat(&c_dfDIKeyboard) != DI_OK)
		SYS_Error("IN_WinInit failure");

	if (lpKeyboard->SetCooperativeLevel(mesh_app.get_app_hwnd(),DISCL_NONEXCLUSIVE|DISCL_FOREGROUND) != DI_OK)
		SYS_Error("IN_WinInit failure");

	// Set the keyboard buffer size to DINPUT_BUFFERSIZE elements.
	if (lpKeyboard->SetProperty(DIPROP_BUFFERSIZE, &dipdw.diph) != DI_OK)
		SYS_Error("IN_WinInit failure");

	IN_WinAcquireKeyboard();

	// MOUSE
	guid = GUID_SysMouse;
	if (lpDI->CreateDevice(guid, &lpMouse, NULL) != DI_OK)
		SYS_Error("IN_WinInit failure");

	if (lpMouse->SetDataFormat(&c_dfDIMouse) != DI_OK)
		SYS_Error("IN_WinInit failure");

	if (lpMouse->SetCooperativeLevel(mesh_app.get_app_hwnd(),DISCL_EXCLUSIVE|DISCL_FOREGROUND) != DI_OK)
		SYS_Error("IN_WinInit failure");

	IN_WinAcquireMouse();
}

void IN_WinShutdown()
{
	if (!lpDI)
		return;
	IN_WinUnacquireKeyboard();
	lpKeyboard->Release();
	lpKeyboard = NULL;
	IN_WinUnacquireMouse();
	lpMouse->Release();
	lpMouse = NULL;
	lpDI->Release();
	lpDI = NULL;
}

void IN_WinAcquireMouse()
{
	HRESULT err;
	if (lpMouse)
	{
		if ((err = lpMouse->Acquire()) == DI_OK)
			return;
		if (err = DIERR_READONLY)
		{
			for (int i=0;i<50;i++)
			{
				if ((err = lpMouse->Acquire()) == DI_OK)
					return;
			}
		}
		switch(err)
		{
			case DI_OK:
				//M_StatusBarText("IN_WinAcquireMouse failure: No Error");
				break;
			// DI_NOTATTACHED
			// DI_PROPNOEFFECT
			case DI_BUFFEROVERFLOW:
				//M_StatusBarText("IN_WinAcquireMouse failure: BufferOverflow/NotAttached/PropNoEffect");
				break;
			case DIERR_INPUTLOST:
				//M_StatusBarText("IN_WinAcquireMouse failure: Input lost");
				break;
			case DIERR_INVALIDPARAM:
				//M_StatusBarText("IN_WinAcquireMouse failure: Invalid param/arg");
				break;
			// DIERR_OTHERAPPHASPRIO
			// DIERR_HANDLEEXISTS
			case DIERR_READONLY:
				//M_StatusBarText("IN_WinAcquireMouse failure: Read only/OtherAppHasPriority/HandleExists");
				break;
			case DIERR_ACQUIRED:
				//M_StatusBarText("IN_WinAcquireMouse failure: acquired");
				break;
			case DIERR_NOTACQUIRED:
				//M_StatusBarText("IN_WinAcquireMouse failure: Not acquired");
				break;
			case DIERR_NOAGGREGATION:
				//M_StatusBarText("IN_WinAcquireMouse failure: no aggregation");
				break;
			case DIERR_ALREADYINITIALIZED:
				//M_StatusBarText("IN_WinAcquireMouse failure: already initialized");
				break;
			case DIERR_NOTINITIALIZED:
				//M_StatusBarText("IN_WinAcquireMouse failure: Not initialized");
				break;
			case DIERR_UNSUPPORTED:
				//M_StatusBarText("IN_WinAcquireMouse failure: unsupported");
				break;
			case DIERR_OUTOFMEMORY:
				//M_StatusBarText("IN_WinAcquireMouse failure: Out of memory");
				break;
			case DIERR_GENERIC:
				//M_StatusBarText("IN_WinAcquireMouse failure: Generic");
				break;
			case DIERR_NOINTERFACE:
				//M_StatusBarText("IN_WinAcquireMouse failure: No interface");
				break;
			case DIERR_DEVICENOTREG:
				//M_StatusBarText("IN_WinAcquireMouse failure: Device not registred");
				break;
			case DIERR_OBJECTNOTFOUND:
				//M_StatusBarText("IN_WinAcquireMouse failure: Object not found");
				break;
			case DIERR_BETADIRECTINPUTVERSION:
				//M_StatusBarText("IN_WinAcquireMouse failure: Beta version");
				break;
			case DIERR_BADDRIVERVER:
				//M_StatusBarText("IN_WinAcquireMouse failure: bad driver version");
				break;
			case DI_POLLEDDEVICE:
				//M_StatusBarText("IN_WinAcquireMouse failure: Polled device");
				break;
			default:
				//M_StatusBarText("IN_WinAcquireMouse failure %X", (unsigned long)err);
				break;
		}	
	}
}

void IN_WinUnacquireMouse()
{
	if (lpMouse)
	{
		lpMouse->Unacquire();
		//if (lpMouse->Unacquire() != DI_OK)
		//	M_StatusBarText("IN_WinUnacquireMouse failure");
	}
}

void IN_WinAcquireKeyboard()
{
	unsigned long num, err;

	if (lpKeyboard)
	{
		if (lpKeyboard->Acquire() != DI_OK)
		{
			//M_StatusBarText("IN_WinAcquireKeyboard failure");
		}

		num = INFINITE;
		err=lpKeyboard->GetDeviceData(sizeof(DIDEVICEOBJECTDATA),NULL,&num,0);
		if ((err != DI_OK) && (err != DIERR_INPUTLOST))
		{
			//M_StatusBarText("IN_WinAcquireKeyboard failure");
		}
	}
	
	memset(keyStates, 0, sizeof(unsigned char)*IN_NUMKEYS);
	memset(keyPressTimes, 0, sizeof(float)*IN_NUMKEYS);
	memset(oldKeyStates, 0, sizeof(unsigned char)*IN_NUMKEYS);
}

void IN_WinUnacquireKeyboard()
{
	unsigned long num, err;

	if (lpKeyboard)
	{
		num = INFINITE;
		err=lpKeyboard->GetDeviceData(sizeof(DIDEVICEOBJECTDATA),NULL,&num,0);
		if ((err != DI_OK) && (err != DIERR_INPUTLOST))
		{
			//M_StatusBarText("IN_WinUnacquireKeyboard failure");
		}
	}
	
	memset(keyStates, 0, sizeof(unsigned char)*IN_NUMKEYS);
	memset(keyPressTimes, 0, sizeof(float)*IN_NUMKEYS);
	memset(oldKeyStates, 0, sizeof(unsigned char)*IN_NUMKEYS);
	
	if (lpKeyboard)
	{
		if (lpKeyboard->Unacquire() != DI_OK)
		{
			//M_StatusBarText("IN_WinUnacquireKeyboard failure");
		}
	}
}

void IN_WinMouseLimits(int x1, int y1, int x2, int y2)
{
	in_MinX = x1;
	in_MinY = y1;
	in_MaxX = x2;
	in_MaxY = y2;
}

void IN_WinProcessKeys()
{
	DIDEVICEOBJECTDATA keys[DINPUT_BUFFERSIZE];
	U8 key;
	unsigned long num,i;
	HRESULT err;
	float keytime;
	inputevent_t event;

	num=DINPUT_BUFFERSIZE;

	keytime = mesh_app.get_cur_time();
	err=lpKeyboard->GetDeviceData(sizeof(DIDEVICEOBJECTDATA),keys,&num,0);
	if (err != DI_OK)
	{
		if (err==DIERR_NOTACQUIRED)
		{
			IN_WinAcquireKeyboard();
			err=lpKeyboard->GetDeviceData(sizeof(DIDEVICEOBJECTDATA),keys,&num,0);
			if (err != DI_OK)
				return;
		}
		else if (err==DIERR_INPUTLOST)
		{
			IN_WinAcquireKeyboard();
			return;
		}
	}
	else
	{
		for (i=0;i<num;i++)
		{
			if (keys[i].dwOfs<IN_NUMKEYS)
			{				
				key=ScanToASCII[keys[i].dwOfs];
				if(key)
				{
					//oldKeyStates[key] = keyStates[key];
					keyStates[key] = (U8)(keys[i].dwData & 0x80L);
				}
			}
		}
		in_keyFlags = 0;
		if (keyStates[KEY_LSHIFT] || keyStates[KEY_SHIFT])
			in_keyFlags |= KF_SHIFT;
		if (keyStates[KEY_CTRL])
			in_keyFlags |= KF_CONTROL;
		if (keyStates[KEY_LALT])
			in_keyFlags |= KF_ALT;
		event.flags = in_keyFlags;
		event.mouseX = in_MouseX;
		event.mouseY = in_MouseY;		
		event.mouseDeltaX = event.mouseDeltaY = 0;
		event.time = keytime;
		for (i=0;i<IN_NUMKEYS;i++)
		{
			event.key = i;
			if (keyStates[i])
			{
				if (!oldKeyStates[i])
				{	// Newly pressed
					event.eventType = INEV_PRESS;
					IN_Event(&event);
					oldKeyStates[i] = keyStates[i];
					keyMouseDragPositions[i][0] = in_MouseX;
					keyMouseDragPositions[i][1] = in_MouseY;
				}
				else
				{
					event.eventType = INEV_DRAG;
					event.mouseDeltaX = in_MouseX - keyMouseDragPositions[i][0];
					event.mouseDeltaY = in_MouseY - keyMouseDragPositions[i][1];
					IN_Event(&event);
					keyMouseDragPositions[i][0] = in_MouseX;
					keyMouseDragPositions[i][1] = in_MouseY;
				}
			}
			else if (oldKeyStates[i])
			{
				event.eventType = INEV_RELEASE;
				IN_Event(&event);
				oldKeyStates[i] = keyStates[i];
			}
		}				
	}
}

void IN_WinProcessMouse()
{
	DIMOUSESTATE mstate;
	HRESULT err;
	int ix, oldx, oldy;
	float keytime;
	inputevent_t event;

	keytime = mesh_app.get_cur_time();
	err = lpMouse->GetDeviceState(sizeof(DIMOUSESTATE), (LPVOID) &mstate);
	if (err != DI_OK)
	{
		if (err==DIERR_NOTACQUIRED)
		{
			IN_WinAcquireMouse();
			return;
		}
		else if (err==DIERR_INPUTLOST)
		{
			IN_WinAcquireMouse();
			return;
		}
		SYS_Error("IN_WinProcessMouse failure");
	}
	else
	{
		oldx = in_MouseX;
		oldy = in_MouseY;
		in_MouseX += mstate.lX;	// x-change
		in_MouseY += mstate.lY;		// y-change
		if (in_MouseX >= in_MaxX)
			in_MouseX = in_MaxX-1;
		if (in_MouseY >= in_MaxY)
			in_MouseY = in_MaxY-1;
		if (in_MouseX <= in_MinX)
			in_MouseX = in_MinX+1;
		if (in_MouseY <= in_MinY)
			in_MouseY = in_MinY+1;
		event.flags = in_keyFlags;
		event.mouseX = in_MouseX;
		event.mouseY = in_MouseY;
		event.time = keytime;
		event.key = event.mouseDeltaX = event.mouseDeltaY = 0;
		if ((in_MouseX != oldx) || (in_MouseY != oldy))
		{
			event.mouseDeltaX = in_MouseX - oldx;
			event.mouseDeltaY = in_MouseY - oldy;
			event.eventType = INEV_MOUSEMOVE;
			IN_Event(&event);
		}
		
		for(ix=0; ix<IN_NUMMOUSEKEYS; ix++)
		{
			event.key = KEY_FIRSTMOUSEKEY+ix;
			if (mstate.rgbButtons[ix] & (unsigned char)0x80)
			{
				if(MouseButtonStatus[ix] == FALSE)
				{	// Newly pressed
					MouseButtonStatus[ix] = TRUE;
					event.eventType = INEV_PRESS;
					IN_Event(&event);
					keyMouseDragPositions[event.key][0] = in_MouseX;
					keyMouseDragPositions[event.key][1] = in_MouseY;
				}
				else
				{
					event.eventType = INEV_DRAG;
					event.mouseDeltaX = in_MouseX - keyMouseDragPositions[event.key][0];
					event.mouseDeltaY = in_MouseY - keyMouseDragPositions[event.key][1];
					IN_Event(&event);
					keyMouseDragPositions[event.key][0] = in_MouseX;
					keyMouseDragPositions[event.key][1] = in_MouseY;
				}
			}
			else if (MouseButtonStatus[ix] == TRUE)
			{	// Newly released
				MouseButtonStatus[ix] = FALSE;
				event.eventType = INEV_RELEASE;
				IN_Event(&event);
			}
		}
	}
}

//----------------------------------------------------------------------------
//    Class Member Code
//----------------------------------------------------------------------------


//****************************************************************************
//**
//**    END MODULE IN_WIN.CPP
//**
//****************************************************************************
