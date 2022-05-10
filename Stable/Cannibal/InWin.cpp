//****************************************************************************
//**
//**    INWIN.CPP
//**    User Input - Windows DirectInput
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include <dinput.h>
#define KRNINC_WIN32
#include "Kernel.h"
#include "TimeMain.h"
#include "InDefs.h"
#include "InWin.h"

#pragma comment(lib, "dxguid.lib")
#pragma comment(lib, "dinput.lib")

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
#define INW_DICOOPFLAG DISCL_FOREGROUND

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
//============================================================================
//    PRIVATE DATA
//============================================================================

// directinput DIK_ to INKEY_ key map, filled in at init
static NDword inw_DIKToINKEY[INW_NUMDIKEYS];

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    PRIVATE FUNCTIONS
//============================================================================
static char* NameForDIError(HRESULT err)
{
	switch(err)
	{
		case DI_OK: return("OK"); break;
		//case DI_NOTATTACHED: return("NOTATTACHED"); break;
		//case DI_PROPNOEFFECT: return("PROPNOEFFECT"); break;
		case DI_BUFFEROVERFLOW: return("NOTATTACHED/PROPNOEFFECT/BUFFEROVERFLOW"); break;
		case DIERR_INPUTLOST: return("INPUTLOST"); break;
		case DIERR_INVALIDPARAM: return("INVALIDPARAM"); break;
		//case DIERR_OTHERAPPHASPRIO: return("OTHERAPPHASPRIO"); break;
		//case DIERR_HANDLEEXISTS: return("HANDLEEXISTS"); break;
		case DIERR_READONLY: return("OTHERAPPHASPRIO/HANDLEEXISTS/READONLY"); break;
		case DIERR_ACQUIRED: return("ACQUIRED"); break;
		case DIERR_NOTACQUIRED: return("NOTACQUIRED"); break;
		case DIERR_NOAGGREGATION: return("NOAGGREGATION"); break;
		case DIERR_ALREADYINITIALIZED: return("ALREADYINITIALIZED"); break;
		case DIERR_NOTINITIALIZED: return("NOTINITIALIZED"); break;
		case DIERR_UNSUPPORTED: return("UNSUPPORTED"); break;
		case DIERR_OUTOFMEMORY: return("OUTOFMEMORY"); break;
		case DIERR_GENERIC: return("GENERIC"); break;
		case DIERR_NOINTERFACE: return("NOINTERFACE"); break;
		case DIERR_DEVICENOTREG: return("DEVICENOTREG"); break;
		case DIERR_OBJECTNOTFOUND: return("OBJECTNOTFOUND"); break;
		case DIERR_BETADIRECTINPUTVERSION: return("BETADIRECTINPUTVERSION"); break;
		case DIERR_BADDRIVERVER: return("BADDRIVERVER"); break;
		case DI_POLLEDDEVICE: return("POLLEDDEVICE"); break;
		default:
			break;
	}
	return("Unknown");
}

static void InitDIKToINKEY()
{
	// since we can't guarantee that the constants for these DIKs won't
	// change, initialize the remap table here instead of statically

	// any key mapped to zero means unmapped and should be ignored
	memset(inw_DIKToINKEY, 0, INW_NUMDIKEYS*sizeof(NDword));

	inw_DIKToINKEY[DIK_ESCAPE] = INKEY_ESCAPE;
	inw_DIKToINKEY[DIK_1] = '1';
	inw_DIKToINKEY[DIK_2] = '2';
	inw_DIKToINKEY[DIK_3] = '3';
	inw_DIKToINKEY[DIK_4] = '4';
	inw_DIKToINKEY[DIK_5] = '5';
	inw_DIKToINKEY[DIK_6] = '6';
	inw_DIKToINKEY[DIK_7] = '7';
	inw_DIKToINKEY[DIK_8] = '8';
	inw_DIKToINKEY[DIK_9] = '9';
	inw_DIKToINKEY[DIK_0] = '0';
	inw_DIKToINKEY[DIK_MINUS] = '-';
	inw_DIKToINKEY[DIK_EQUALS] = '=';
	inw_DIKToINKEY[DIK_BACK] = INKEY_BACKSPACE;
	inw_DIKToINKEY[DIK_TAB] = INKEY_TAB;
	inw_DIKToINKEY[DIK_Q] = 'q';
	inw_DIKToINKEY[DIK_W] = 'w';
	inw_DIKToINKEY[DIK_E] = 'e';
	inw_DIKToINKEY[DIK_R] = 'r';
	inw_DIKToINKEY[DIK_T] = 't';
	inw_DIKToINKEY[DIK_Y] = 'y';
	inw_DIKToINKEY[DIK_U] = 'u';
	inw_DIKToINKEY[DIK_I] = 'i';
	inw_DIKToINKEY[DIK_O] = 'o';
	inw_DIKToINKEY[DIK_P] = 'p';
	inw_DIKToINKEY[DIK_LBRACKET] = '[';
	inw_DIKToINKEY[DIK_RBRACKET] = ']';
	inw_DIKToINKEY[DIK_RETURN] = INKEY_ENTER;
	inw_DIKToINKEY[DIK_LCONTROL] = INKEY_LEFTCTRL;
	inw_DIKToINKEY[DIK_A] = 'a';
	inw_DIKToINKEY[DIK_S] = 's';
	inw_DIKToINKEY[DIK_D] = 'd';
	inw_DIKToINKEY[DIK_F] = 'f';
	inw_DIKToINKEY[DIK_G] = 'g';
	inw_DIKToINKEY[DIK_H] = 'h';
	inw_DIKToINKEY[DIK_J] = 'j';
	inw_DIKToINKEY[DIK_K] = 'k';
	inw_DIKToINKEY[DIK_L] = 'l';
	inw_DIKToINKEY[DIK_SEMICOLON] = ';';
	inw_DIKToINKEY[DIK_APOSTROPHE] = '\'';
	inw_DIKToINKEY[DIK_GRAVE] = '`';
	inw_DIKToINKEY[DIK_LSHIFT] = INKEY_LEFTSHIFT;
	inw_DIKToINKEY[DIK_BACKSLASH] = '\\';
	inw_DIKToINKEY[DIK_Z] = 'z';
	inw_DIKToINKEY[DIK_X] = 'x';
	inw_DIKToINKEY[DIK_C] = 'c';
	inw_DIKToINKEY[DIK_V] = 'v';
	inw_DIKToINKEY[DIK_B] = 'b';
	inw_DIKToINKEY[DIK_N] = 'n';
	inw_DIKToINKEY[DIK_M] = 'm';
	inw_DIKToINKEY[DIK_COMMA] = ',';
	inw_DIKToINKEY[DIK_PERIOD] = '.';
	inw_DIKToINKEY[DIK_SLASH] = '/';
	inw_DIKToINKEY[DIK_RSHIFT] = INKEY_RIGHTSHIFT;
	inw_DIKToINKEY[DIK_MULTIPLY] = INKEY_NUMSTAR;
	inw_DIKToINKEY[DIK_LMENU] = INKEY_LEFTALT;
	inw_DIKToINKEY[DIK_SPACE] = INKEY_SPACE;
	inw_DIKToINKEY[DIK_CAPITAL] = INKEY_CAPSLOCK;
	inw_DIKToINKEY[DIK_F1] = INKEY_F1;
	inw_DIKToINKEY[DIK_F2] = INKEY_F2;
	inw_DIKToINKEY[DIK_F3] = INKEY_F3;
	inw_DIKToINKEY[DIK_F4] = INKEY_F4;
	inw_DIKToINKEY[DIK_F5] = INKEY_F5;
	inw_DIKToINKEY[DIK_F6] = INKEY_F6;
	inw_DIKToINKEY[DIK_F7] = INKEY_F7;
	inw_DIKToINKEY[DIK_F8] = INKEY_F8;
	inw_DIKToINKEY[DIK_F9] = INKEY_F9;
	inw_DIKToINKEY[DIK_F10] = INKEY_F10;
	inw_DIKToINKEY[DIK_NUMLOCK] = INKEY_NUMLOCK;
	inw_DIKToINKEY[DIK_SCROLL] = INKEY_SCROLLLOCK;
	inw_DIKToINKEY[DIK_NUMPAD7] = INKEY_NUM7;
	inw_DIKToINKEY[DIK_NUMPAD8] = INKEY_NUM8;
	inw_DIKToINKEY[DIK_NUMPAD9] = INKEY_NUM9;
	inw_DIKToINKEY[DIK_SUBTRACT] = INKEY_NUMMINUS;
	inw_DIKToINKEY[DIK_NUMPAD4] = INKEY_NUM4;
	inw_DIKToINKEY[DIK_NUMPAD5] = INKEY_NUM5;
	inw_DIKToINKEY[DIK_NUMPAD6] = INKEY_NUM6;
	inw_DIKToINKEY[DIK_ADD] = INKEY_NUMPLUS;
	inw_DIKToINKEY[DIK_NUMPAD1] = INKEY_NUM1;
	inw_DIKToINKEY[DIK_NUMPAD2] = INKEY_NUM2;
	inw_DIKToINKEY[DIK_NUMPAD3] = INKEY_NUM3;
	inw_DIKToINKEY[DIK_NUMPAD0] = INKEY_NUM0;
	inw_DIKToINKEY[DIK_DECIMAL] = INKEY_NUMPERIOD;
	inw_DIKToINKEY[DIK_F11] = INKEY_F11;
	inw_DIKToINKEY[DIK_F12] = INKEY_F12;
	inw_DIKToINKEY[DIK_NUMPADENTER] = INKEY_NUMENTER;
	inw_DIKToINKEY[DIK_RCONTROL] = INKEY_RIGHTCTRL;
	inw_DIKToINKEY[DIK_DIVIDE] = INKEY_NUMSLASH;
	inw_DIKToINKEY[DIK_SYSRQ] = INKEY_PRINTSCRN;
	inw_DIKToINKEY[DIK_RMENU] = INKEY_RIGHTALT;
	inw_DIKToINKEY[DIK_HOME] = INKEY_HOME;
	inw_DIKToINKEY[DIK_UP] = INKEY_UPARROW;
	inw_DIKToINKEY[DIK_PRIOR] = INKEY_PGUP;
	inw_DIKToINKEY[DIK_LEFT] = INKEY_LEFTARROW;
	inw_DIKToINKEY[DIK_RIGHT] = INKEY_RIGHTARROW;
	inw_DIKToINKEY[DIK_END] = INKEY_END;
	inw_DIKToINKEY[DIK_DOWN] = INKEY_DOWNARROW;
	inw_DIKToINKEY[DIK_NEXT] = INKEY_PGDN;
	inw_DIKToINKEY[DIK_INSERT] = INKEY_INS;
	inw_DIKToINKEY[DIK_DELETE] = INKEY_DEL;
	inw_DIKToINKEY[DIK_LWIN] = 0;
	inw_DIKToINKEY[DIK_RWIN] = 0;
	inw_DIKToINKEY[DIK_APPS] = 0;
}

//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
//============================================================================
//    CLASS METHODS
//============================================================================
NBool CInputTrackerDI::s_StaticInit = 0;

CInputTrackerDI::CInputTrackerDI()
{
	if (!s_StaticInit)
	{
		// initialize timer
		//TIME_Init();
		
		// set up DIK_ remap
		InitDIKToINKEY();

		s_StaticInit = 1;
	}
	
	m_hInst = NULL;
	m_hWnd = NULL;
	m_hWndMouseBase = NULL;
	
	m_lpDI = NULL;
	m_lpMouse = NULL;
	m_lpKeyboard = NULL;
	memset(&m_DICaps, 0, sizeof(DIDEVCAPS));

	memset(m_keyStates, 0, INKEY_NUMKEYS*sizeof(NByte));
	memset(m_oldKeyStates, 0, INKEY_NUMKEYS*sizeof(NByte));
	memset(m_keyPressTimes, 0, INKEY_NUMKEYS*sizeof(NFloat));
	memset(m_keyPressBlocked, 0, INKEY_NUMKEYS*sizeof(NByte));
	memset(m_keyMouseDragPositions, 0, INKEY_NUMKEYS*2*sizeof(NSDword));

	m_mouseMinX = m_mouseMinY = 0x80000000; // signed minimum
	m_mouseMaxX = m_mouseMaxY = 0x7fffffff; // signed maximum
	m_mouseX = m_mouseY = 0;
	m_mouseFreeX = m_mouseFreeY = 0;
	m_mouseWheelPos = 0;
	m_mouseSensitivity = 1.0;
	m_mouseExclusive = 0;
	m_hasFocus = m_mouseAcquired = m_keyboardAcquired = 0;

	memset(m_keyInjectionBuffer, 0, INW_MAXINJECT*2*sizeof(NDword));
	m_keyInjectionBufferIndex = 0;

	m_eventIndex = 0;

	memset(m_ReceiverPool, 0, INW_MAXRECEIVERS*sizeof(SInputReceiverDI));
	m_ReceiverChain.mNext = m_ReceiverChain.mPrev = &m_ReceiverChain; // link receiver head to itself

	m_userValue = 0;
}
CInputTrackerDI::~CInputTrackerDI()
{
}

// event handler, dispatches events to receiver stack
NBool CInputTrackerDI::EventDispatch(SInEvent *inEvent, IInTracker* inTracker)
{
	SInputReceiverDI *rec, *next;

	for (rec=m_ReceiverChain.mNext; rec!=&m_ReceiverChain; rec=next)
	{
		next = rec->mNext; // use a safe next pointer incase receiver removes self
		if (rec->mFunc(inEvent, inTracker))
			return(1);
	}
	return(0);
}

HRESULT CInputTrackerDI::SetMouseCooperative(DWORD inFlags)
{
	if (m_mouseExclusive)
		inFlags |= DISCL_EXCLUSIVE;
	else
		inFlags |= DISCL_NONEXCLUSIVE;
	return(m_lpMouse->SetCooperativeLevel(m_hWnd, inFlags));
}

void CInputTrackerDI::FlushKeyboardData()
{
	if (m_lpKeyboard)
	{
		NDword num;
	
		// flush the dinput buffer, don't worry about return value
		num = INFINITE;
		m_lpKeyboard->GetDeviceData(sizeof(DIDEVICEOBJECTDATA),NULL,&num,0);
	}

	// wipe our internal key data
	memset(m_keyStates, 0, INKEY_NUMKEYS*sizeof(NByte));
	memset(m_oldKeyStates, 0, INKEY_NUMKEYS*sizeof(NByte));
	memset(m_keyPressTimes, 0, INKEY_NUMKEYS*sizeof(NFloat));
	m_keyInjectionBufferIndex = 0;

	// block the mouse from sending inappropriate presses until release is confirmed
	memset(m_keyPressBlocked+INKEY_MOUSEFIRSTBUTTON, 1, sizeof(NByte)*(INKEY_MOUSELASTBUTTON+1-INKEY_MOUSEFIRSTBUTTON));
}

void CInputTrackerDI::AcquireMouse()
{
	if (m_lpMouse)
	{
		HRESULT err;
		int i;

// set coop level
//if (err = SetMouseCooperative(INW_DICOOPFLAG) != DI_OK)
//{
//	char* blargo = NameForDIError(err);
//	return;
//}

		m_mouseAcquired = 1;
		if ((err = m_lpMouse->Acquire()) == DI_OK)
			return;
		// didn't get it back, try a few more times
		for (i=0;i<50;i++)
		{
			if ((err = m_lpMouse->Acquire()) == DI_OK)
				return;
		}
		// still don't have it, something's up, oh well
		m_mouseAcquired = 0;
	}
}

void CInputTrackerDI::UnacquireMouse()
{
	m_mouseAcquired = 0;
	if (m_lpMouse)
		m_lpMouse->Unacquire();
}

void CInputTrackerDI::AcquireKeyboard()
{
	if (m_lpKeyboard)
	{
		HRESULT err;
		int i;

// set coop level.  note: the keyboard can't be exclusive
//if ((err = m_lpKeyboard->SetCooperativeLevel(m_hWnd,DISCL_NONEXCLUSIVE|INW_DICOOPFLAG)) != DI_OK)
//{
//	char* blargo = NameForDIError(err);
//	return;
//}

		m_keyboardAcquired = 1;
		if ((err = m_lpKeyboard->Acquire()) == DI_OK)
			return;
		// didn't get it back, try a few more times
		for (i=0;i<50;i++)
		{
			if ((err = m_lpKeyboard->Acquire()) == DI_OK)
				return;
		}
		// still don't have it, something's up, oh well
		m_keyboardAcquired = 0;
	}	
		
	FlushKeyboardData();
}

void CInputTrackerDI::UnacquireKeyboard()
{
	FlushKeyboardData();

	m_keyboardAcquired = 0;
	if (m_lpKeyboard)
		m_lpKeyboard->Unacquire();
}

void CInputTrackerDI::CheckKeyEvents(NDword key, SInEvent *event)
{
	if (m_keyStates[key])
	{
		if (!m_oldKeyStates[key])
		{
			// press event (key was up before but down now)
			event->eventType = INEV_PRESS;
			event->mouseDeltaX = 0;
			event->mouseDeltaY = 0;
			event->pressTimeDelta = 0.0;
			event->lastPressEventDelta = TIME_GetTimeFrame() - m_keyPressTimes[key];
			event->eventIndex = m_eventIndex++;

			EventDispatch(event, this);
			
			m_keyMouseDragPositions[key][0] = m_mouseX;
			m_keyMouseDragPositions[key][1] = m_mouseY;
			m_keyPressTimes[key] = TIME_GetTimeFrame();
		}
		else
		{
			// drag event (key is still down)
			event->eventType = INEV_DRAG;
			event->mouseDeltaX = m_mouseX - m_keyMouseDragPositions[key][0];
			event->mouseDeltaY = m_mouseY - m_keyMouseDragPositions[key][1];
			event->pressTimeDelta = TIME_GetTimeFrame() - m_keyPressTimes[key];
			event->lastPressEventDelta = event->pressTimeDelta;
			event->eventIndex = m_eventIndex++;
			
			EventDispatch(event, this);
			
			m_keyMouseDragPositions[key][0] = m_mouseX;
			m_keyMouseDragPositions[key][1] = m_mouseY;
		}
	}
	else if (m_oldKeyStates[key])
	{
		// release event (key was down before but up now)
		event->eventType = INEV_RELEASE;
		event->mouseDeltaX = m_mouseX - m_keyMouseDragPositions[key][0];
		event->mouseDeltaY = m_mouseY - m_keyMouseDragPositions[key][1];
		event->pressTimeDelta = TIME_GetTimeFrame() - m_keyPressTimes[key];
		event->lastPressEventDelta = event->pressTimeDelta;
		event->eventIndex = m_eventIndex++;

		EventDispatch(event, this);
	}
}

// change the exclusive mode on the mouse
NBool CInputTrackerDI::SetMouseExclusive(NBool exclusive)
{
	NBool wasAcquired = m_mouseAcquired;

	m_mouseExclusive = exclusive;	
	if (wasAcquired)
		UnacquireMouse();
	if (wasAcquired)
		AcquireMouse();
	return(1);
}

NBool CInputTrackerDI::Init(void* inInstance, void* inWindow, NBool inExclusive)
{
	m_hInst = (HINSTANCE)inInstance;
	m_hWnd = (HWND)inWindow;
	/*
	FIXME: If this is used it needs updated.
	GUID guid;
	DIPROPDWORD prop = { { sizeof(DIPROPDWORD), sizeof(DIPROPHEADER), 0,
		DIPH_DEVICE, }, INW_INPUTBUFFERSIZE };

	// create directinput object
	if (DirectInputCreate(m_hInst, DIRECTINPUT_VERSION, &m_lpDI, NULL) != DI_OK)
		return(0);

	// init keyboard
	guid = GUID_SysKeyboard;
	if (m_lpDI->CreateDevice(guid, &m_lpKeyboard, NULL) != DI_OK)
		return(0);
	if (m_lpKeyboard->SetDataFormat(&c_dfDIKeyboard) != DI_OK)
		return(0);

	// set coop level.  note: the keyboard can't be exclusive
	if (m_lpKeyboard->SetCooperativeLevel(m_hWnd,DISCL_NONEXCLUSIVE|INW_DICOOPFLAG) != DI_OK)
		return(0);

	// set the buffer size to our input buffer maximum
	if (m_lpKeyboard->SetProperty(DIPROP_BUFFERSIZE, &prop.diph) != DI_OK)
		return(0);

	// get it - commented, call SetFocus when you want it
	//AcquireKeyboard();

	// init mouse
	guid = GUID_SysMouse;
	if (m_lpDI->CreateDevice(guid, &m_lpMouse, NULL) != DI_OK)
		return(0);
	if (m_lpMouse->SetDataFormat(&c_dfDIMouse) != DI_OK)
		return(0);

	m_mouseExclusive = inExclusive;

	// set coop level
	if (SetMouseCooperative(INW_DICOOPFLAG) != DI_OK)
		return(0);

	// get it - commented, call SetFocus when you want it
	//AcquireMouse();
*/
	return(1);
}
NBool CInputTrackerDI::Shutdown()
{
	// make sure we're initialized
	if (!m_lpDI)
		return(0);
	
	// shutdown keyboard
	if (m_lpKeyboard)
	{
		UnacquireKeyboard();
		m_lpKeyboard->Release();
		m_lpKeyboard = NULL;
	}
	
	// shutdown mouse
	if (m_lpMouse)
	{
		UnacquireMouse();
		m_lpMouse->Release();
		m_lpMouse = NULL;
	}
	
	// kill directinput
	m_lpDI->Release();
	m_lpDI = NULL;

	return(1);
}

NBool CInputTrackerDI::Process()
{
	DIDEVICEOBJECTDATA keys[INW_INPUTBUFFERSIZE];
	DIMOUSESTATE mstate;
	NDword key;
	NDword i, num;
	NSDword oldx, oldy, oldwheel;
	HRESULT err;
	SInEvent event;
	NBool ready;
	static NDword keyForMouseButton[3] = { INKEY_MOUSELEFT, INKEY_MOUSERIGHT, INKEY_MOUSEMIDDLE };
	static NBool keyEventSent[INKEY_NUMKEYS];

	// check for focus
	if (!m_hasFocus)
		return(0);

	// update frame time
	//TIME_Frame();

	//---------------------
	// mouse
	//---------------------	

	ready = 1;
	err = m_lpMouse->GetDeviceState(sizeof(DIMOUSESTATE), (LPVOID) &mstate);
	if (err != DI_OK)
	{
		if (err==DIERR_NOTACQUIRED)
		{
			// if it's not acquired, get it back and try again
			ready = 0;
			AcquireMouse();
			if ((err = m_lpMouse->GetDeviceState(sizeof(DIMOUSESTATE), (LPVOID) &mstate)) == DI_OK)
				ready = 1;
		}
		else if (err==DIERR_INPUTLOST)
		{
			// if the input is gone, all we can do is reacquire
			ready = 0;
			AcquireMouse();
		}
	}
	
	// handle events
	if (ready)
	{
		// get new mouse position status
		oldx = m_mouseX;
		oldy = m_mouseY;
		oldwheel = m_mouseWheelPos;
		if (m_hWndMouseBase)
		{
			// base window, get the cursor position relative to the window and update accordingly
			// note that there is no difference between clamped and unclamped coords when a base is involved
			// note also that mouse sensitivity is ignored.
			POINT p; GetCursorPos(&p);
			ScreenToClient(m_hWndMouseBase, &p);
			m_mouseFreeX = m_mouseX = p.x;
			m_mouseFreeY = m_mouseY = p.y;
		}
		else
		{
			// no base window, use directinput mickeys
			m_mouseFreeX += (NSDword)(mstate.lX * m_mouseSensitivity);
			m_mouseFreeY += (NSDword)(mstate.lY * m_mouseSensitivity);
			m_mouseX += (NSDword)(mstate.lX * m_mouseSensitivity);
			m_mouseY += (NSDword)(mstate.lY * m_mouseSensitivity);
		}
		m_mouseWheelPos += mstate.lZ;

		// clamp non-free mouse values to limits
		if (m_mouseX >= m_mouseMaxX)
			m_mouseX = m_mouseMaxX-1;
		if (m_mouseY >= m_mouseMaxY)
			m_mouseY = m_mouseMaxY-1;
		if (m_mouseX <= m_mouseMinX)
			m_mouseX = m_mouseMinX+1;
		if (m_mouseY <= m_mouseMinY)
			m_mouseY = m_mouseMinY+1;

		// rig up event data that won't change in the loop
		event.mouseX = m_mouseX;
		event.mouseY = m_mouseY;
		event.mouseFreeX = m_mouseFreeX;
		event.mouseFreeY = m_mouseFreeY;
		event.mouseDeltaX = event.mouseDeltaY = 0;
		event.frameTimeStamp = TIME_GetTimeFrame();
		event.pressTimeDelta = 0.0;
		event.key = (EInKey)0;
		event.flags = 0; // note: key flags will be off by a frame here since the mouse goes first
		if (m_keyStates[INKEY_LEFTSHIFT] || m_keyStates[INKEY_RIGHTSHIFT])
			event.flags |= INEVF_SHIFT;
		if (m_keyStates[INKEY_LEFTCTRL] || m_keyStates[INKEY_RIGHTCTRL])
			event.flags |= INEVF_CTRL;
		if (m_keyStates[INKEY_LEFTALT] || m_keyStates[INKEY_RIGHTALT])
			event.flags |= INEVF_ALT;
		
		// call a MOUSEMOVE event first if one occured
		if ((m_mouseX != oldx) || (m_mouseY != oldy))
		{
			event.mouseDeltaX = m_mouseX - oldx;
			event.mouseDeltaY = m_mouseY - oldy;
			event.eventType = INEV_MOUSEMOVE;
			event.eventIndex = m_eventIndex++;
			
			EventDispatch(&event, this);
		}

		// check the mouse wheel
		if (m_mouseWheelPos != oldwheel)
		{
			if (m_mouseWheelPos > oldwheel)
				event.key = INKEY_MOUSEWHEELUP;
			else
				event.key = INKEY_MOUSEWHEELDOWN;
			event.eventType = INEV_PRESS;
			event.mouseDeltaX = 0;
			event.mouseDeltaY = 0;
			event.pressTimeDelta = 0.0;
            event.lastPressEventDelta = TIME_GetTimeFrame() - m_keyPressTimes[event.key];
			event.eventIndex = m_eventIndex++;

			EventDispatch(&event, this);
			
			m_keyMouseDragPositions[event.key][0] = m_mouseX;
			m_keyMouseDragPositions[event.key][1] = m_mouseY;
			m_keyPressTimes[event.key] = TIME_GetTimeFrame();
		}
		
		// check the mouse buttons
		for(i=0; i<3; i++)
		{
			key = keyForMouseButton[i];
			event.key = (EInKey)key;

			// set current key state
			m_keyStates[key] = mstate.rgbButtons[i] & (NByte)0x80;
			if (m_keyPressBlocked[key])
				m_keyPressBlocked[key] = m_keyStates[key]!=0;
			if (!m_keyPressBlocked[key])
				CheckKeyEvents(key, &event);

			// save current key state to old
			m_oldKeyStates[key] = m_keyStates[key];
		}
	}

	//---------------------
	// keyboard
	//---------------------
	
	ready = 1;
	num=INW_INPUTBUFFERSIZE;
	err=m_lpKeyboard->GetDeviceData(sizeof(DIDEVICEOBJECTDATA),keys,&num,0);
	if (err != DI_OK)
	{
		if (err==DIERR_NOTACQUIRED)
		{
			// if it's not acquired, get it back and try again
			ready = 0;
			AcquireKeyboard();
			num=INW_INPUTBUFFERSIZE;
			if ((err=m_lpKeyboard->GetDeviceData(sizeof(DIDEVICEOBJECTDATA),keys,&num,0)) == DI_OK)
				ready = 1;
		}
		else if (err==DIERR_INPUTLOST)
		{
			// if the input is gone, all we can do is reacquire
			ready = 0;
			AcquireKeyboard();
		}
	}
	
	// handle events
	if (ready)
	{
		event.mouseX = m_mouseX;
		event.mouseY = m_mouseY;
		event.mouseFreeX = m_mouseFreeX;
		event.mouseFreeY = m_mouseFreeY;
		event.frameTimeStamp = TIME_GetTimeFrame();

		// run through input buffer to account for changed states
		for (i=0;i<num;i++)
		{
			key = inw_DIKToINKEY[keys[i].dwOfs]; // convert to our key table
			if (!key)
				continue; // not a mapped key, ignore it
			
			// set current key state
			m_keyStates[key] = (NByte)((NByte)keys[i].dwData & 0x80L);

			if (m_keyStates[key] != m_oldKeyStates[key])
			{
				// press or release event, need to handle it now
				event.key = (EInKey)key;
				event.flags = 0;
				if (m_keyStates[INKEY_LEFTSHIFT] || m_keyStates[INKEY_RIGHTSHIFT])
					event.flags |= INEVF_SHIFT;
				if (m_keyStates[INKEY_LEFTCTRL] || m_keyStates[INKEY_RIGHTCTRL])
					event.flags |= INEVF_CTRL;
				if (m_keyStates[INKEY_LEFTALT] || m_keyStates[INKEY_RIGHTALT])
					event.flags |= INEVF_ALT;

				CheckKeyEvents(key, &event);

				// save current key state to old
				m_oldKeyStates[key] = m_keyStates[key];

				// make sure we don't call a drag event in this frame
				keyEventSent[key] = 1;
			}
		}

		// handle key injection buffer in the same way
		for (i=0;i<m_keyInjectionBufferIndex;i++)
		{
			key = m_keyInjectionBuffer[i][0];

			// set current key state
			m_keyStates[key] = (NByte)(m_keyInjectionBuffer[i][1]);

			if (m_keyStates[key] != m_oldKeyStates[key])
			{
				// press or release event, need to handle it now
				event.key = (EInKey)key;
				event.flags = 0;
				if (m_keyStates[INKEY_LEFTSHIFT] || m_keyStates[INKEY_RIGHTSHIFT])
					event.flags |= INEVF_SHIFT;
				if (m_keyStates[INKEY_LEFTCTRL] || m_keyStates[INKEY_RIGHTCTRL])
					event.flags |= INEVF_CTRL;
				if (m_keyStates[INKEY_LEFTALT] || m_keyStates[INKEY_RIGHTALT])
					event.flags |= INEVF_ALT;

				CheckKeyEvents(key, &event);

				// save current key state to old
				m_oldKeyStates[key] = m_keyStates[key];

				// make sure we don't call a drag event in this frame
				keyEventSent[key] = 1;
			}
		}
		m_keyInjectionBufferIndex = 0;

		// send drag events for all unhandled keys
		event.flags = 0;
		if (m_keyStates[INKEY_LEFTSHIFT] || m_keyStates[INKEY_RIGHTSHIFT])
			event.flags |= INEVF_SHIFT;
		if (m_keyStates[INKEY_LEFTCTRL] || m_keyStates[INKEY_RIGHTCTRL])
			event.flags |= INEVF_CTRL;
		if (m_keyStates[INKEY_LEFTALT] || m_keyStates[INKEY_RIGHTALT])
			event.flags |= INEVF_ALT;
		for (i=0;i<256/*INKEY_NUMKEYS*/;i++)
		{
			if (keyEventSent[i] || !m_keyStates[i])
				continue; // already ran events on this key, or no drag to deal with
			event.key = (EInKey)i;
			
			CheckKeyEvents(i, &event);

			// save current key state to old
			m_oldKeyStates[i] = m_keyStates[i];
		}

		// clear the eventsent buffer
		memset(keyEventSent, 0, INKEY_NUMKEYS);
	}

	return(1);
}

NBool CInputTrackerDI::SetFocus()
{		
	AcquireMouse();
	AcquireKeyboard();
	m_hasFocus = 1;

	if (m_hWndMouseBase)
	{
		// if we have a base, reset the mouse coordinates due to the change in focus,
		// since it generally means we have other windows to consider
		
		//m_mouseX = m_mouseY = 0;
		//m_mouseFreeX = m_mouseFreeY = 0;
		//m_mouseWheelPos = 0;		
	}

	return(1);
}
NBool CInputTrackerDI::KillFocus()
{
	m_hasFocus = 0;
	UnacquireMouse();
	UnacquireKeyboard();
	return(1);
}

// allocate a new receiver on the receiver stack
// returns 0 if the allocation failed, or a handle to the receiver
HInReceiver CInputTrackerDI::AddReceiver(FInReceiverFunc inFunc, NChar* inName)
{
	int i;
	SInputReceiverDI *rec;

	for (i=0;i<INW_MAXRECEIVERS;i++)
	{
		rec = &m_ReceiverPool[i];
		if (!rec->mFunc)
		{
			// receiver is available
			rec->mFunc = inFunc;
			rec->mName[0] = 0;
			if (inName)
				strcpy(rec->mName, inName);
			// add it to the list
			rec->mPrev = &m_ReceiverChain;
			rec->mNext = m_ReceiverChain.mNext;
			rec->mPrev->mNext = rec;
			rec->mNext->mPrev = rec;
			return((HInReceiver)(rec - m_ReceiverPool) + 1);
		}
	}
	return(0);
}

HInReceiver CInputTrackerDI::FindReceiver(NChar* inName)
{
	int i;
	SInputReceiverDI* rec;

	for (i=0;i<INW_MAXRECEIVERS;i++)
	{
		rec = &m_ReceiverPool[i];
		if (!rec->mFunc)
			continue;
		if ((!inName) || (!stricmp(inName, rec->mName)))
			return((HInReceiver)(rec - m_ReceiverPool) + 1);
	}
	return(0);
}

// change the handler of an existing receiver
NBool CInputTrackerDI::ChangeReceiverHandler(HInReceiver inReceiver, FInReceiverFunc inFunc)
{
	SInputReceiverDI *rec;

	if ((!inReceiver) || (inReceiver > INW_MAXRECEIVERS))
		return(0); // trying to change an out-of-range receiver
	rec = &m_ReceiverPool[inReceiver - 1];
	if (!rec->mFunc)
		return(0); // trying to change a free receiver

	rec->mFunc = inFunc;
	
	return(1);
}

// take a receiver out of the stack and free it, takes handle as parameter
NBool CInputTrackerDI::RemoveReceiver(HInReceiver inReceiver)
{
	SInputReceiverDI *rec;

	if ((!inReceiver) || (inReceiver > INW_MAXRECEIVERS))
		return(0); // trying to free an out-of-range receiver
	rec = &m_ReceiverPool[inReceiver - 1];
	if (!rec->mFunc)
		return(0); // trying to free an already free receiver
	
	rec->mFunc = NULL;
	// unlink from the list
	rec->mPrev->mNext = rec->mNext;
	rec->mNext->mPrev = rec->mPrev;

	return(1);
}

// set the limit box for the mouseX/mouseY values
NBool CInputTrackerDI::SetMouseLimits(NSDword x1, NSDword y1, NSDword x2, NSDword y2)
{
	m_mouseMinX = x1;
	m_mouseMinY = y1;
	m_mouseMaxX = x2;
	m_mouseMaxY = y2;
	return(1);
}

// set the mouse sensitivity multiplier
NBool CInputTrackerDI::SetMouseSensitivity(NFloat factor)
{
	m_mouseSensitivity = factor;
	return(1);
}

NFloat CInputTrackerDI::GetMouseSensitivity()
{
	return(m_mouseSensitivity);
}

NBool CInputTrackerDI::SetMouseBaseWindow(void* inWindow)
{
	m_hWndMouseBase = (HWND)inWindow;
	
	return(1);
}

NBool CInputTrackerDI::InjectKeyEvent(NDword key, NBool state)
{
	if (m_keyInjectionBufferIndex >= INW_MAXINJECT)
		return(0); // too many injected keys
	m_keyInjectionBuffer[m_keyInjectionBufferIndex][0] = key;
	m_keyInjectionBuffer[m_keyInjectionBufferIndex][1] = state;
	m_keyInjectionBufferIndex++;
	return(1);
}

NBool CInputTrackerDI::SetUserValue(NDword inValue)
{
	m_userValue = inValue;
	return(1);
}

NDword CInputTrackerDI::GetUserValue()
{
	return(m_userValue);
}


//****************************************************************************
//**
//**    END MODULE INWIN.CPP
//**
//****************************************************************************

