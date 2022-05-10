#ifndef __INDEFS_H__
#define __INDEFS_H__
//****************************************************************************
//**
//**    INDEFS.H
//**    Header - User Input Common Definitions
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
// input event type
typedef enum
{
	INEV_NONE=0, // invalid
	INEV_MOUSEMOVE, // mouse position has changed
	INEV_PRESS, // key has changed from released to pressed
	INEV_DRAG, // key is still being pressed
	INEV_RELEASE, // key has changed from pressed to released
	
	INEV_NUMTYPES
} EInEventType;

// input receiver function
typedef struct _SInEvent SInEvent;
class IInTracker;
typedef NBool (*FInReceiverFunc)(SInEvent*,IInTracker*);

// input receiver handle
typedef NDword HInReceiver;

// input bind map handle
typedef NDword HInBindMap;

// input event flags
enum
{
	// first three flags hold status of modifier keys
	INEVF_SHIFT		= 0x00000001,
	INEVF_ALT		= 0x00000002,
	INEVF_CTRL		= 0x00000004,
	
	INEVF_KEYMASK	= 0x00000007
};

// input key constants
typedef enum
{
	// --------------------
	// characters 0-127 map to their ascii characters
	// --------------------

	INKEY_NULL			= 0x00000000,

    INKEY_BACKSPACE		= 0x00000008,
    INKEY_TAB			= 0x00000009,
    INKEY_ENTER			= 0x0000000D,
    INKEY_ESCAPE		= 0x0000001B,
    INKEY_SPACE			= 0x00000020, // same as ' ', here for convenience
	// regular characters don't need constants here; use 'a' 'b' etc.

	// --------------------
	// characters 128-255 are used for extended keys
	// --------------------
    
	// modifier keys
    INKEY_LEFTSHIFT		= 0x00000080,
    INKEY_RIGHTSHIFT,
	INKEY_LEFTCTRL,
	INKEY_RIGHTCTRL,
    INKEY_LEFTALT,
    INKEY_RIGHTALT,
	// arrow keys
	INKEY_LEFTARROW,
    INKEY_RIGHTARROW,
    INKEY_UPARROW,
    INKEY_DOWNARROW,
    // function keys
	INKEY_F1,
    INKEY_F2,
    INKEY_F3,
    INKEY_F4,
    INKEY_F5,
    INKEY_F6,
    INKEY_F7,
    INKEY_F8,
    INKEY_F9,
    INKEY_F10,
    INKEY_F11,
    INKEY_F12,
	// cursor control keys
    INKEY_INS,
    INKEY_DEL,
    INKEY_HOME,
    INKEY_END,
    INKEY_PGUP,
    INKEY_PGDN,
	// numeric keypad
    INKEY_NUMSLASH,
    INKEY_NUMSTAR,
    INKEY_NUMMINUS,
    INKEY_NUMPLUS,
    INKEY_NUMENTER,
    INKEY_NUMPERIOD,
    INKEY_NUM0,
    INKEY_NUM1,
    INKEY_NUM2,
    INKEY_NUM3,
    INKEY_NUM4,
    INKEY_NUM5,
    INKEY_NUM6,
    INKEY_NUM7,
    INKEY_NUM8,
    INKEY_NUM9,
    // locks and misc keys
	INKEY_NUMLOCK,
    INKEY_CAPSLOCK,
    INKEY_SCROLLLOCK,
    INKEY_PRINTSCRN,
    INKEY_PAUSE,
	// windows keys deliberately not listed (i don't believe in
	// keyboards specially rigged for a single operating system)

	// --------------------
	// characters 256 and up used for mouse buttons etc.
	// --------------------

	INKEY_MOUSELEFT		= 0x00000100,
	INKEY_MOUSERIGHT,
	INKEY_MOUSEMIDDLE,
	INKEY_MOUSEWHEELUP,
	INKEY_MOUSEWHEELDOWN,

	// --------------------
	INKEY_NUMKEYS,
	
	INKEY_MOUSEFIRSTBUTTON = INKEY_MOUSELEFT,
	INKEY_MOUSELASTBUTTON = INKEY_MOUSEMIDDLE,
	INKEY_MOUSENUMKEYS = ((INKEY_MOUSELASTBUTTON-INKEY_MOUSEFIRSTBUTTON)+1)

} EInKey;

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================

// input event structure
struct _SInEvent
{
	EInEventType eventType; // INEV_ type of event
	EInKey key; // INKEY_ value if event is a key-related event
	NDword flags; // INEVF_ flag combination
	NSDword mouseX, mouseY; // mouse position within set limits
	NSDword mouseFreeX, mouseFreeY; // mouse position without limits
	NSDword mouseDeltaX, mouseDeltaY; // mouse change since last context event
	NFloat pressTimeDelta; // time since key was first pressed, for key events
	NDword eventIndex; // index of event, incremented for each event sent
	NFloat frameTimeStamp; // timestamp of event at frame resolution
    NFloat lastPressEventDelta; // time since key last had a press event
};

/*
	IInTracker
*/
class IInTracker
{
public:
	// management functions, called internally
	virtual NBool Init(void* inInstance, void* inWindow, NBool inExclusive)=0;
	virtual NBool Shutdown()=0;

	// process function, called by user to scan input and fire events
	virtual NBool Process()=0;

	// focus functions, process will not respond when not in focus
	virtual NBool SetFocus()=0;
	virtual NBool KillFocus()=0;

	// receiver functions
	virtual HInReceiver AddReceiver(FInReceiverFunc inFunc, NChar* inName)=0;
	virtual HInReceiver FindReceiver(NChar* inName)=0;
	virtual NBool ChangeReceiverHandler(HInReceiver inReceiver, FInReceiverFunc inFunc)=0;
	virtual NBool RemoveReceiver(HInReceiver inReceiver)=0;

	// mouse functions
	virtual NBool SetMouseLimits(NSDword x1, NSDword y1, NSDword x2, NSDword y2)=0;
	virtual NBool SetMouseSensitivity(NFloat factor)=0;
	virtual NFloat GetMouseSensitivity()=0;
	virtual NBool SetMouseBaseWindow(void* inWindow)=0; // window that mouse coords should be relative to, if any

	// misc functions	
	virtual NBool InjectKeyEvent(NDword key, NBool state)=0; // force a key event into the event stream
	virtual NBool SetUserValue(NDword inValue)=0; // set a user value associated with this tracker
	virtual NDword GetUserValue()=0; // get the user value
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
//**    END HEADER INDEFS.H
//**
//****************************************************************************
#endif // __INDEFS_H__
