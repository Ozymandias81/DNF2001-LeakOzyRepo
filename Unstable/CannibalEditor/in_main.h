#ifndef __IN_MAIN_H__
#define __IN_MAIN_H__
//****************************************************************************
//**
//**    IN_MAIN.H
//**    Header - Input - Main Operations
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include "cbl_defs.h"
//----------------------------------------------------------------------------
//    Definitions
//----------------------------------------------------------------------------
#define IN_NUMKEYBOARDKEYS 256
#define IN_NUMMOUSEKEYS 3
#define IN_NUMKEYS	(IN_NUMKEYBOARDKEYS+IN_NUMMOUSEKEYS)

#define KEY_TAB				0x09
#define KEY_ENTER			13
#define KEY_ESCAPE			27
#define KEY_SPACE			32
#define KEY_APOSTROPHE		0x27
#define KEY_MINUS			0x2d
#define KEY_EQUALS			0x3d
#define KEY_BACKSPACE		127
#define KEY_RIGHTARROW		0xae
#define KEY_LEFTARROW		0xac
#define KEY_UPARROW			0xad
#define KEY_DOWNARROW		0xaf
#define KEY_LSHIFT      	0xfe
#define KEY_PAUSE			0xff
#define KEY_CTRL			(0x80+0x1d)
#define KEY_SHIFT			(0x80+0x36)
#define KEY_RALT			(0x80+0x38)
#define KEY_LALT			KEY_RALT
#define KEY_F1				(0x80+0x3b)
#define KEY_F2				(0x80+0x3c)
#define KEY_F3				(0x80+0x3d)
#define KEY_F4				(0x80+0x3e)
#define KEY_F5				(0x80+0x3f)
#define KEY_F6				(0x80+0x40)
#define KEY_F7				(0x80+0x41)
#define KEY_F8				(0x80+0x42)
#define KEY_F9				(0x80+0x43)
#define KEY_F10				(0x80+0x44)
#define KEY_HOME			(0x80+0x47)
#define KEY_PGUP			(0x80+0x49)
#define KEY_END				(0x80+0x4f)
#define KEY_PGDN			(0x80+0x51)
#define KEY_INS				(0x80+0x52)
#define KEY_DEL				(0x80+0x53)
#define KEY_F11				(0x80+0x57)
#define KEY_F12				(0x80+0x58)
#define KEY_PRINT			(0x80+0x60)
#define KEY_SCROLL			(0x80+0x61)
#define KEY_CAPS			(0x80+0x62)
#define KEY_KP_SLASH		(0x80+0x63)
#define KEY_KP_STAR			(0x80+0x64)
#define KEY_KP_MINUS		(0x80+0x65)
#define KEY_KP_PLUS			(0x80+0x66)
#define KEY_KP_ENTER		(0x80+0x67)
#define KEY_KP_PERIOD		(0x80+0x68)
#define KEY_KP0				(0x80+0x70)
#define KEY_KP1				(0x80+0x71)
#define KEY_KP2				(0x80+0x72)
#define KEY_KP3				(0x80+0x73)
#define KEY_KP4				(0x80+0x74)
#define KEY_KP5				(0x80+0x75)
#define KEY_KP6				(0x80+0x76)
#define KEY_KP7				(0x80+0x77)
#define KEY_KP8				(0x80+0x78)
#define KEY_KP9				(0x80+0x79)

#define KEY_MOUSELEFT		IN_NUMKEYBOARDKEYS
#define KEY_MOUSERIGHT		(IN_NUMKEYBOARDKEYS+1)
#define KEY_MOUSEMIDDLE		(IN_NUMKEYBOARDKEYS+2)

#define KEY_FIRSTMOUSEKEY	KEY_MOUSELEFT

typedef enum
{
	INEV_NONE,
	INEV_MOUSEMOVE,
	INEV_PRESS,
	INEV_DRAG,
	INEV_RELEASE,
	
	INEV_NUMTYPES
} inputeventtype_t;

//----------------------------------------------------------------------------
//    Class Prototypes
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Required External Class References
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Structures
//----------------------------------------------------------------------------
typedef struct
{
	inputeventtype_t eventType;
	int key, flags;
	int mouseX, mouseY;
	int mouseDeltaX, mouseDeltaY;
	float time;
} inputevent_t;

//----------------------------------------------------------------------------
//    Public Data Declarations
//----------------------------------------------------------------------------
extern int in_MouseX, in_MouseY; // physical mouse position
extern unsigned long in_keyFlags;
extern int in_Shifted[256]; // shifted versions of keys
extern float in_keyDelay, in_defaultKeyDelay;
//----------------------------------------------------------------------------
//    Public Function Declarations
//----------------------------------------------------------------------------
void IN_Init();
void IN_Shutdown();
void IN_Process();
void IN_Event(inputevent_t *event);

char *IN_NameForKey(int key);
int IN_KeyForName(char *name);
void IN_SetCursor(char *cursorName);
char *IN_GetCursor();
void IN_DrawCursor();
VidTex *IN_GetButtonTex(char *buttonName);

//----------------------------------------------------------------------------
//    Class Headers
//----------------------------------------------------------------------------


//****************************************************************************
//**
//**    END HEADER IN_MAIN.H
//**
//****************************************************************************
#endif // __IN_MAIN_H__
