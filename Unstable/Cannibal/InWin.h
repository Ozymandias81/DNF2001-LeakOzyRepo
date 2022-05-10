#ifndef __INWIN_H__
#define __INWIN_H__
//****************************************************************************
//**
//**    INWIN.H
//**    Header - User Input - Windows DirectInput
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#define INW_MAXRECEIVERS 32 // maximum number of receivers per tracker
#define INW_INPUTBUFFERSIZE 128 // maximum pieces of dinput data per frame
#define INW_NUMDIKEYS 256 // maximum number of directinput DIK_ keys
#define INW_MAXINJECT 128 // maximum injected key events per frame

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================

// Input receiver type
// Entry in a chain of callbacks that user input is fed through
// Receiver functions return true if the input has been accepted, or false
// if it should be continued down the chain.  Receivers can safely call
// the Remove function within themselves.

typedef struct _SInputReceiverDI SInputReceiverDI;
struct _SInputReceiverDI
{
	FInReceiverFunc mFunc;
	NChar mName[256];
	SInputReceiverDI* mPrev;
	SInputReceiverDI* mNext;
};

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================

// DirectInput input tracker implementation

class CInputTrackerDI
: public IInTracker
{
private:
	// static initialization
	static NBool s_StaticInit;

	// windows hinstance/hwnd
	HINSTANCE m_hInst;
	HWND m_hWnd, m_hWndMouseBase;

	// directinput device crap
	LPDIRECTINPUT m_lpDI;
	LPDIRECTINPUTDEVICE m_lpMouse;
	LPDIRECTINPUTDEVICE m_lpKeyboard;
	DIDEVCAPS m_DICaps;

	// current and previous key states
	NByte m_keyStates[INKEY_NUMKEYS];
	NByte m_oldKeyStates[INKEY_NUMKEYS];

	// time since keys were "press"ed, for key delays etc.
	NFloat m_keyPressTimes[INKEY_NUMKEYS];

	// keys that are blocked from sending press messages until release is verified
	NByte m_keyPressBlocked[INKEY_NUMKEYS];

	// mouse positions during key events for drag deltas
	NSDword m_keyMouseDragPositions[INKEY_NUMKEYS][2]; // x/y

	// mouse limits, set to "no limit" extremes by default
	NSDword m_mouseMinX, m_mouseMinY; // signed minimum
	NSDword m_mouseMaxX, m_mouseMaxY; // signed maximum

	// current mouse positions
	NSDword m_mouseX, m_mouseY; // within limits
	NSDword m_mouseFreeX, m_mouseFreeY; // without limits
	NSDword m_mouseWheelPos; // without limits
	// note: 32 bits is sufficient for the free coordinates unless you set a
	//       super-high mouse sensitivity or feel like rolling in one direction
	//       for a few weeks straight with no break... uhh, i don't think so.

	// mouse sensitivity multiplier
	NFloat m_mouseSensitivity;

	// exclusive mode toggle
	NBool m_mouseExclusive;

	// device acquired status
	NBool m_hasFocus, m_mouseAcquired, m_keyboardAcquired;

	// keyboard event injection buffer
	NDword m_keyInjectionBuffer[INW_MAXINJECT][2]; // key/state
	NDword m_keyInjectionBufferIndex;

	// event index
	NDword m_eventIndex;

	// receiver data
	SInputReceiverDI m_ReceiverPool[INW_MAXRECEIVERS];
	SInputReceiverDI m_ReceiverChain;

	// user value
	NDword m_userValue;

public:
	// CInputTrackerDI
	CInputTrackerDI();
	~CInputTrackerDI();
	
	NBool EventDispatch(SInEvent *inEvent, IInTracker* inTracker);
	HRESULT SetMouseCooperative(DWORD inFlags);
	void FlushKeyboardData();
	void AcquireMouse();
	void UnacquireMouse();
	void AcquireKeyboard();
	void UnacquireKeyboard();
	void CheckKeyEvents(NDword key, SInEvent *event);
	NBool SetMouseExclusive(NBool exclusive);

	// IInTracker
	NBool Init(void* inInstance, void* inWindow, NBool inExclusive);
	NBool Shutdown();
	NBool Process();
	NBool SetFocus();
	NBool KillFocus();
	HInReceiver AddReceiver(FInReceiverFunc inFunc, NChar* inName);
	HInReceiver FindReceiver(NChar* inName);
	NBool ChangeReceiverHandler(HInReceiver inReceiver, FInReceiverFunc inFunc);
	NBool RemoveReceiver(HInReceiver inReceiver);
	NBool SetMouseLimits(NSDword x1, NSDword y1, NSDword x2, NSDword y2);
	NBool SetMouseSensitivity(NFloat factor);
	NFloat GetMouseSensitivity();
	NBool SetMouseBaseWindow(void* inWindow);
	NBool InjectKeyEvent(NDword key, NBool state);
	NBool SetUserValue(NDword inValue);
	NDword GetUserValue();
};

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
//============================================================================
//    INLINE CLASS METHODS
//============================================================================
//============================================================================
//    TRAILING HEADERS
//============================================================================

//****************************************************************************
//**
//**    END HEADER INWIN.H
//**
//****************************************************************************
#endif // __INWIN_H__
