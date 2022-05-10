//****************************************************************************
//**
//**    IN_MAIN.CPP
//**    Input - Main Operations
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include "cbl_defs.h"
#include "in_win.h"
#include "in_main.h"
//----------------------------------------------------------------------------
//    Private Definitions
//----------------------------------------------------------------------------
#define IN_MAXBUTTONS 256
#define IN_MAXCURSORS 256
//----------------------------------------------------------------------------
//    Private Structures
//----------------------------------------------------------------------------
struct incursor_s
{
	char cursorname[32];
	char filename[64];
	int hotspotX, hotspotY;
	int flags;
	VidTex *tex;
} inCursors[IN_MAXCURSORS];

struct inbutton_s
{
	char buttonname[32];
	char filename[64];
	int flags;
	VidTex *tex;
} inButtons[IN_MAXBUTTONS];

//----------------------------------------------------------------------------
//    Additional External References
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Data
//----------------------------------------------------------------------------
static incursor_s *in_curCursor=NULL;
static int in_loadCursor=0, in_loadButton=0;
static boolean in_inResourceLoading=false;

struct keydefs_s
{
	char *name;
	int key;
	char *dname;
} KeyDefs[] =
{
	{ "ALT", KEY_RALT, NULL},
	{ "SPACE", KEY_SPACE, NULL},
	{ "BACKSPACE", KEY_BACKSPACE, NULL},
	{ "ENTER", KEY_ENTER, NULL},
	{ "UPARROW", KEY_UPARROW, NULL},
	{ "DOWNARROW", KEY_DOWNARROW, NULL},
	{ "RIGHTARROW", KEY_RIGHTARROW, NULL},
	{ "LEFTARROW", KEY_LEFTARROW, NULL},
	{ "SHIFT", KEY_SHIFT, NULL},
	{ "CTRL", KEY_CTRL, NULL},
	{ "TAB", KEY_TAB, NULL},
	{ "F1", KEY_F1, NULL},
	{ "F2", KEY_F2, NULL},
	{ "F3", KEY_F3, NULL},
	{ "F4", KEY_F4, NULL},
	{ "F5", KEY_F5, NULL},
	{ "F6", KEY_F6, NULL},
	{ "F7", KEY_F7, NULL},
	{ "F8", KEY_F8, NULL},
	{ "F9", KEY_F9, NULL},
	{ "F10", KEY_F10, NULL},
	{ "F11", KEY_F11, NULL},
	{ "F12", KEY_F12, NULL},
	{ "PGUP", KEY_PGUP, NULL},
	{ "PGDN", KEY_PGDN, NULL},
	{ "HOME", KEY_HOME, NULL},
	{ "END", KEY_END, NULL},
	{ "INS", KEY_INS, NULL},
	{ "DEL", KEY_DEL, NULL},
	{ "SEMICOLON", ';', ";"},
	{ "QUOTE", '\'', "\'"},
	{ "PAUSE", KEY_PAUSE, NULL},
	{ "SCROLL", KEY_SCROLL, NULL},
	{ "PRINTSCREEN", KEY_PRINT, NULL},
	{ "CAPS", KEY_CAPS, NULL},
	{ "ESCAPE", KEY_ESCAPE, NULL},
	{ "KP/", KEY_KP_SLASH, "/"},
	{ "KP*", KEY_KP_STAR, "*"},
	{ "KP-", KEY_KP_MINUS, "-"},
	{ "KP+", KEY_KP_PLUS, "+"},
	{ "KPENTER", KEY_KP_ENTER, NULL},
	{ "KP.", KEY_KP_PERIOD, "."},
	{ "KP0", KEY_KP0, "0"},
	{ "KP1", KEY_KP1, "1"},
	{ "KP2", KEY_KP2, "2"},
	{ "KP3", KEY_KP3, "3"},
	{ "KP4", KEY_KP4, "4"},
	{ "KP5", KEY_KP5, "5"},
	{ "KP6", KEY_KP6, "6"},
	{ "KP7", KEY_KP7, "7"},
	{ "KP8", KEY_KP8, "8"},
	{ "KP9", KEY_KP9, "9"},
	{ "TILDE", '`', "`"},
	{ "MOUSE1", KEY_MOUSELEFT, NULL},
	{ "MOUSE2", KEY_MOUSERIGHT, NULL},
	{ "MOUSE3", KEY_MOUSEMIDDLE, NULL},

	{ NULL, 0, NULL }
};

//----------------------------------------------------------------------------
//    Public Data
//----------------------------------------------------------------------------
int in_MouseX = 0, in_MouseY = 0;
unsigned long in_keyFlags = 0;
unsigned short in_cursorBackup[256];
vector_t in_cursorBackupPos;
boolean in_cursorBackupPending = 0;
int in_Shifted[256];
CONVAR(float, in_keyDelay, 0.5, 0, NULL);
CONVAR(float, in_defaultKeyDelay, 0.5, 0, NULL);
//----------------------------------------------------------------------------
//    Private Code Prototypes
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Code
//----------------------------------------------------------------------------
CONFUNC(AddCursor, NULL, 0)
{
	if (!in_inResourceLoading)
	{
		CON->Printf("ADDCURSOR can only be executed within resource.cfg");
		return;
	}
	if (argNum < 5)
	{
		CON->Printf("[?] ADDCURSOR cursorName filename.bmp hotspotX hotspotY");
		return;
	}
	if (in_loadCursor >= IN_MAXCURSORS)
	{
		CON->Printf("ADDCURSOR: Too many cursors");
		return;
	}
	strcpy(inCursors[in_loadCursor].cursorname, argList[1]);
	strcpy(inCursors[in_loadCursor].filename, "resource\\");
	strcat(inCursors[in_loadCursor].filename, argList[2]);
	SYS_ForceFileExtention(inCursors[in_loadCursor].filename, "bmp");
	inCursors[in_loadCursor].hotspotX = atoi(argList[3]);
	inCursors[in_loadCursor].hotspotY = atoi(argList[4]);
	inCursors[in_loadCursor].flags = 0;
	inCursors[in_loadCursor].tex = vid.TexLoadBMP(inCursors[in_loadCursor].filename, true);
	in_loadCursor++;
}

U32 UnloadCursors(void)
{
	while(in_loadCursor)
	{
		in_loadCursor--;
		vid.TexRelease(inCursors[in_loadCursor].tex);
		inCursors[in_loadCursor].tex=null;
	}
	return TRUE;
}

CONFUNC(AddButton, NULL, 0)
{
	if (!in_inResourceLoading)
	{
		CON->Printf("ADDBUTTON can only be executed within resource.cfg");
		return;
	}
	if (argNum < 3)
	{
		CON->Printf("[?] ADDBUTTON buttonName filename.bmp");
		return;
	}
	if (in_loadButton >= IN_MAXBUTTONS)
	{
		CON->Printf("ADDBUTTON: Too many buttons");
		return;
	}
	strcpy(inButtons[in_loadButton].buttonname, argList[1]);
	strcpy(inButtons[in_loadButton].filename, "resource\\");
	strcat(inButtons[in_loadButton].filename, argList[2]);
	SYS_ForceFileExtention(inButtons[in_loadButton].filename, "bmp");
	inButtons[in_loadButton].flags = 0;
	inButtons[in_loadButton].tex = vid.TexLoadBMP(inButtons[in_loadButton].filename, true);
	in_loadButton++;
}

U32 UnloadButtons(void)
{
#if 0
	I32 i;

	for (i=0;i<in_loadButton;i++)
	{
		vid.TexRelease(inButtons[i].tex);
		inButtons[i].tex=null;
	}
#else
	while(in_loadButton)
	{
		in_loadButton--;
		vid.TexRelease(inButtons[in_loadButton].tex);
		inButtons[in_loadButton].tex=null;
	}
#endif
	return TRUE;
}

//----------------------------------------------------------------------------
//    Public Code
//----------------------------------------------------------------------------
void IN_Init()
{
	int i;

	IN_WinInit(); // initialize windows interface

	for (i=0;i<256;i++)
		in_Shifted[i] = -1;
	in_Shifted['a'] = 'A';
	in_Shifted['b'] = 'B';
	in_Shifted['c'] = 'C';
	in_Shifted['d'] = 'D';
	in_Shifted['e'] = 'E';
	in_Shifted['f'] = 'F';
	in_Shifted['g'] = 'G';
	in_Shifted['h'] = 'H';
	in_Shifted['i'] = 'I';
	in_Shifted['j'] = 'J';
	in_Shifted['k'] = 'K';
	in_Shifted['l'] = 'L';
	in_Shifted['m'] = 'M';
	in_Shifted['n'] = 'N';
	in_Shifted['o'] = 'O';
	in_Shifted['p'] = 'P';
	in_Shifted['q'] = 'Q';
	in_Shifted['r'] = 'R';
	in_Shifted['s'] = 'S';
	in_Shifted['t'] = 'T';
	in_Shifted['u'] = 'U';
	in_Shifted['v'] = 'V';
	in_Shifted['w'] = 'W';
	in_Shifted['x'] = 'X';
	in_Shifted['y'] = 'Y';
	in_Shifted['z'] = 'Z';
	in_Shifted['0'] = ')';
	in_Shifted['1'] = '!';
	in_Shifted['2'] = '@';
	in_Shifted['3'] = '#';
	in_Shifted['4'] = '$';
	in_Shifted['5'] = '%';
	in_Shifted['6'] = '^';
	in_Shifted['7'] = '&';
	in_Shifted['8'] = '*';
	in_Shifted['9'] = '(';
	in_Shifted['-'] = '_';
	in_Shifted['='] = '+';
	in_Shifted['['] = '{';
	in_Shifted[']'] = '}';
	in_Shifted['\\'] = '|';
	in_Shifted[';'] = ':';
	in_Shifted['\''] = '"';
	in_Shifted[','] = '<';
	in_Shifted['.'] = '>';
	in_Shifted['/'] = '?';
	in_Shifted[' '] = ' ';

	// execute resource.cfg to load cursors and buttons
	in_inResourceLoading = true;
	CON->ExecuteFile(NULL, "resource.cfg", true);
	in_inResourceLoading = false;
	IN_SetCursor("select");
}

void IN_Shutdown()
{
	UnloadCursors();
	UnloadButtons();
	IN_WinShutdown();
}

void IN_Event(inputevent_t *event)
{
//	int i, k;
//	unsigned short *buf;
//	int bufPitch;
/*
	if ((event->eventType == INEV_MOUSEMOVE) && (in_cursorBackupPending))
	{
		if (vid.LockScreen(VLS_WRITEBACK, &buf, &bufPitch))
		{		
			for (i=in_cursorBackupPos.y;i<in_cursorBackupPos.y+16;i++)
				for (k=in_cursorBackupPos.x;k<in_cursorBackupPos.x+16;k++)
					buf[i*bufPitch+k] = in_cursorBackup[(int)((i-in_cursorBackupPos.y)*16+(k-in_cursorBackupPos.x))];
			in_cursorBackupPending = 0;
			vid.UnlockScreen();
		}
		else
			CON->Printf("Lock Failure!");
	}
*/
	OVL_InputEvent(event);
}

void IN_Process()
{
	IN_WinProcessKeys();
	IN_WinProcessMouse();
}

char *IN_NameForKey(int key)
{
//	return(nameForKey[key]);
	int i;
	static char tempy[2] = {0,0};

	for(i=0;KeyDefs[i].name;i++)
	{
		if (KeyDefs[i].key == key)
		{
			return(KeyDefs[i].name);
		}
	}
	if (
		((key >= 'a') && (key <= 'z')) ||
		((key >= '0') && (key <= '9')) ||
		(key == '-') || (key == '=') ||
		(key == '[') || (key == ']') || (key == '\\') ||
		(key == ';') || (key == '\'') ||
		(key == ',') || (key == '.') || (key == '/')
		)
	{
		tempy[0] = toupper(key);
		return(tempy);
	}

	return(NULL);
}

int IN_KeyForName(char *name)
{
	char *str;

	for (int i=0;i<IN_NUMKEYS;i++)
	{
		if ((str = IN_NameForKey(i)) && (!_stricmp(name, str)))
			return(i);
	}
	return(-1);
}

void IN_SetCursor(char *cursorName)
{
	int i;
	for(i=0;i<in_loadCursor;i++)
	{
		if (!_stricmp(cursorName, inCursors[i].cursorname))
		{
			in_curCursor = &inCursors[i];
			return;
		}
	}
	// invalid cursor, leave as is
}

char *IN_GetCursor()
{
	if (!in_curCursor)
		return("");
	return(in_curCursor->cursorname);
}

void IN_DrawCursor()
{
	vidcolormodetype_t vcm;
	vidmaskmodetype_t vmm;
	vidfiltermodetype_t vfm;
	vidalphamodetype_t vam;
	vidblendmodetype_t vbm;
	vector_t p[4], tv[4];
	int oldmaskcolor;
	int x1, y1;
//	int i, k;
//	unsigned short *buf;
//	int bufPitch;

//	in_cursorBackupPending = 0;
	if (!in_curCursor)
		return;
/*
	if (vid.LockScreen(VLS_READFRONT, &buf, &bufPitch))
	{		
		in_cursorBackupPos.x = in_MouseX - in_curCursor->hotspotX;
		in_cursorBackupPos.y = in_MouseY - in_curCursor->hotspotY;
		for (i=in_cursorBackupPos.y;i<in_cursorBackupPos.y+16;i++)
			for (k=in_cursorBackupPos.x;k<in_cursorBackupPos.x+16;k++)
				in_cursorBackup[(int)((i-in_cursorBackupPos.y)*16+(k-in_cursorBackupPos.x))] = buf[i*bufPitch+k];
		in_cursorBackupPending = 1;
		vid.UnlockScreen();
	}
	else
		CON->Printf("Lock Failure!");
*/

	tv[0].Set(0, 0, 0);
	tv[1].Set(255, 0, 0); // 192 since font texture is 8x8 but chars are only 6x6
	tv[2].Set(255, 255, 0);
	tv[3].Set(0, 255, 0);

	oldmaskcolor = *vid.maskColor;
	vid.MaskColor(0, 0, 0, 0);
	vcm = vid.ColorMode(VCM_TEXTURE);
	vmm = vid.MaskMode(VMM_ENABLE);
	vfm = vid.FilterMode(VFM_NONE);
	vam = vid.AlphaMode(VAM_FLAT);
	vbm = vid.BlendMode(VBM_OPAQUE);

	x1 = in_MouseX - in_curCursor->hotspotX;
	y1 = in_MouseY - in_curCursor->hotspotY;
	p[0].Set(x1, y1, 0);
	p[1].Set(x1+16, y1, 0);
	p[2].Set(x1+16, y1+16, 0);
	p[3].Set(x1, y1+16, 0);
	vid.TexActivate(in_curCursor->tex, VTA_NORMAL);
	vid.DrawPolygon(4, p, NULL, NULL, tv, false);
	vid.ColorMode(vcm);
	vid.AlphaMode(vam);
	vid.MaskMode(vmm);
	vid.FilterMode(vfm);
	vid.BlendMode(vbm);
	vid.MaskColor(oldmaskcolor&255, (oldmaskcolor>>8)&255, (oldmaskcolor>>16)&255, (oldmaskcolor>>24)&255);
}

VidTex *IN_GetButtonTex(char *buttonName)
{
	int i;
	for(i=0;i<in_loadButton;i++)
	{
		if (!_stricmp(buttonName, inButtons[i].buttonname))
		{
			return(inButtons[i].tex);
		}
	}
	return(*vid.blankTex); // blank
}


//----------------------------------------------------------------------------
//    Class Member Code
//----------------------------------------------------------------------------


//****************************************************************************
//**
//**    END MODULE IN_MAIN.CPP
//**
//****************************************************************************

