//****************************************************************************
//**
//**    INMAIN.CPP
//**    User Input Main Interface
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include <dinput.h>
#define KRNINC_WIN32
#include "Kernel.h"
#include "MemMain.h"
#include "InMain.h"
#include "InWin.h"

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
#define IN_MAXTRACKERS 256
#define IN_MAXBINDMAPS 128

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================

// input bind mappings
class CInputBindMap
{
public:
	NChar* mName; // name of bind mapping
	NChar* mCmds[INKEY_NUMKEYS][INEVF_KEYMASK+1]; // command map

	void Init()
	{
		mName = NULL;
		memset(mCmds, 0, INKEY_NUMKEYS*(INEVF_KEYMASK+1)*sizeof(NChar*));
	}
	void Shutdown()
	{
		if (mName)
			MEM_Free(mName);
		for (NDword i=0;i<INKEY_NUMKEYS;i++)
			for (NDword j=0;j<(INEVF_KEYMASK+1);j++)
				if (mCmds[i][j])
					MEM_Free(mCmds[i][j]);
	}
};

//============================================================================
//    PRIVATE DATA
//============================================================================
// allocated trackers
static IInTracker* in_Trackers[IN_MAXTRACKERS];
static IInTracker* in_CurTracker = NULL;

// bind maps
static CInputBindMap* in_BindMaps[IN_MAXBINDMAPS];
static NDword in_NumBindMaps = 0;

// shifted key table
static NDword in_Shifted[256];

// key name list
struct keyName_s
{
	char *name;
	EInKey key;
	char *numname;
} in_KeyNames[] =
{
	{ "BACKSPACE", INKEY_BACKSPACE, NULL},
	{ "TAB", INKEY_TAB, NULL},
	{ "ENTER", INKEY_ENTER, NULL},
	{ "ESCAPE", INKEY_ESCAPE, NULL},
	{ "SPACE", INKEY_SPACE, NULL},

	{ "LEFTSHIFT", INKEY_LEFTSHIFT, NULL},
	{ "RIGHTSHIFT", INKEY_RIGHTSHIFT, NULL},
	{ "LEFTCTRL", INKEY_LEFTCTRL, NULL},
	{ "RIGHTCTRL", INKEY_RIGHTCTRL, NULL},
	{ "LEFTALT", INKEY_LEFTALT, NULL},
	{ "RIGHTALT", INKEY_RIGHTALT, NULL},
	
	{ "LEFTARROW", INKEY_LEFTARROW, NULL},
	{ "RIGHTARROW", INKEY_RIGHTARROW, NULL},
	{ "UPARROW", INKEY_UPARROW, NULL},
	{ "DOWNARROW", INKEY_DOWNARROW, NULL},

	{ "F1", INKEY_F1, NULL},
	{ "F2", INKEY_F2, NULL},
	{ "F3", INKEY_F3, NULL},
	{ "F4", INKEY_F4, NULL},
	{ "F5", INKEY_F5, NULL},
	{ "F6", INKEY_F6, NULL},
	{ "F7", INKEY_F7, NULL},
	{ "F8", INKEY_F8, NULL},
	{ "F9", INKEY_F9, NULL},
	{ "F10", INKEY_F10, NULL},
	{ "F11", INKEY_F11, NULL},
	{ "F12", INKEY_F12, NULL},

	{ "INS", INKEY_INS, NULL},
	{ "DEL", INKEY_DEL, NULL},
	{ "HOME", INKEY_HOME, NULL},
	{ "END", INKEY_END, NULL},
	{ "PGUP", INKEY_PGUP, NULL},
	{ "PGDN", INKEY_PGDN, NULL},

	{ "NUMSLASH", INKEY_NUMSLASH, "/"},
	{ "NUMSTAR", INKEY_NUMSTAR, "*"},
	{ "NUMMINUS", INKEY_NUMMINUS, "-"},
	{ "NUMPLUS", INKEY_NUMPLUS, "+"},
	{ "NUMENTER", INKEY_NUMENTER, NULL},
	{ "NUMPERIOD", INKEY_NUMPERIOD, "."},
	{ "NUM0", INKEY_NUM0, "0"},
	{ "NUM1", INKEY_NUM1, "1"},
	{ "NUM2", INKEY_NUM2, "2"},
	{ "NUM3", INKEY_NUM3, "3"},
	{ "NUM4", INKEY_NUM4, "4"},
	{ "NUM5", INKEY_NUM5, "5"},
	{ "NUM6", INKEY_NUM6, "6"},
	{ "NUM7", INKEY_NUM7, "7"},
	{ "NUM8", INKEY_NUM8, "8"},
	{ "NUM9", INKEY_NUM9, "9"},

	{ "NUMLOCK", INKEY_NUMLOCK, NULL},
	{ "CAPSLOCK", INKEY_CAPSLOCK, NULL},
	{ "SCROLLLOCK", INKEY_SCROLLLOCK, NULL},
	{ "PRINTSCREEN", INKEY_PRINTSCRN, NULL},
	{ "PAUSE", INKEY_PAUSE, NULL},
	
	{ "MOUSE1", INKEY_MOUSELEFT, NULL},
	{ "MOUSE2", INKEY_MOUSERIGHT, NULL},
	{ "MOUSE3", INKEY_MOUSEMIDDLE, NULL},
	{ "MWHEELUP", INKEY_MOUSEWHEELUP, NULL},
	{ "MWHEELDOWN", INKEY_MOUSEWHEELDOWN, NULL},

	// give names to a few regular keys that tend to be reserved
	{ "SEMICOLON", (EInKey)';', ";"},
	{ "QUOTE", (EInKey)'\'', "\'"},
	{ "TILDE", (EInKey)'`', "`"},

	{ NULL, (EInKey)0, NULL }
};

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    PRIVATE FUNCTIONS
//============================================================================
static char* strstri(char* s1, char* s2)
{
	static char buf1[256], buf2[256];
	strcpy(buf1, s1); strlwr(buf1);
	strcpy(buf2, s2); strlwr(buf2);
	return(strstr(buf1, buf2));
}

//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================

// initialization
KRN_API void IN_Init()
{
	int i;

	// set up shifted key table
	// keys with shift entries of zero don't have shifted versions
	for (i=0;i<26;i++)
		in_Shifted[i+'a'] = i+'A';
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
	in_Shifted['`'] = '~';
}

KRN_API IInTracker* IN_CreateTracker(void* inInstance, void* inWindow, NBool inExclusive)
{
	for (NDword i=0;i<IN_MAXTRACKERS;i++)
	{
		if (!in_Trackers[i])
			break;
	}
	if (i==IN_MAXTRACKERS)
		return(NULL);

	CInputTrackerDI* tracker = new CInputTrackerDI;
	in_Trackers[i] = tracker;

	if (!tracker->Init(inInstance, inWindow, inExclusive))
	{
		IN_DestroyTracker(tracker);
		return(NULL);
	}
	return(tracker);
}

KRN_API NBool IN_DestroyTracker(IInTracker* inTracker)
{
	if (!inTracker)
		return(0);
	CInputTrackerDI* tracker = (CInputTrackerDI*)inTracker;
	
	tracker->Shutdown();
	
	for (NDword i=0;i<IN_MAXTRACKERS;i++)
	{
		if (in_Trackers[i]==tracker)
			in_Trackers[i] = NULL;
	}

	if (tracker==in_CurTracker)
		in_CurTracker = NULL;

	delete tracker;
	
	return(1);
}

KRN_API IInTracker* IN_GetCurrentTracker()
{
	return(in_CurTracker);
}

KRN_API NBool IN_SetCurrentTracker(IInTracker* inTracker)
{
	in_CurTracker = inTracker;
	return(1);
}

// shutdown
KRN_API void IN_Shutdown()
{
	// kill trackers
	for (NDword i=0;i<IN_MAXTRACKERS;i++)
	{
		if (in_Trackers[i])
			IN_DestroyTracker(in_Trackers[i]);
	}
	// kill bind maps
	for (i=0;i<in_NumBindMaps;i++)
	{
		in_BindMaps[i]->Shutdown();
		MEM_Free(in_BindMaps[i]);
	}
}

// process all trackers
KRN_API NBool IN_ProcessAll()
{
	for (NDword i=0;i<IN_MAXTRACKERS;i++)
	{
		if (in_Trackers[i])
			in_Trackers[i]->Process();
	}
	return(1);
}

// return the string name for a key
KRN_API NChar* IN_NameForKey(EInKey inKey, NDword inFlags)
{
	int i;
	static char outStr[256];
	static char tempStr[2] = {0,0};

	inFlags &= INEVF_KEYMASK;
	if ((!inKey) || (inKey >= INKEY_NUMKEYS))
		return(NULL); // out of range

	outStr[0] = 0;
	if (inFlags & INEVF_CTRL)
		strcat(outStr, "Ctrl ");
	if (inFlags & INEVF_ALT)
		strcat(outStr, "Alt ");
	if (inFlags & INEVF_SHIFT)
		strcat(outStr, "Shift ");

	for (i=0; in_KeyNames[i].name; i++)
	{
		if (in_KeyNames[i].key == inKey)
		{
			strcat(outStr, in_KeyNames[i].name);
			return(outStr);
		}
	}
	// not an extended key, use regular characters
	if ((inKey < ' ') || (inKey > 127))
		return(NULL); // out of range

	if ((inKey >= 'a') && (inKey <= 'z'))
		inKey = IN_GetShiftedKey(inKey); // use uppercase for letters

	tempStr[0] = inKey;
	strcat(outStr, tempStr);

	return(outStr);
}

// return a key matching the string name
KRN_API EInKey IN_KeyForName(NChar* inName)
{
	NSDword i;
	char *str;

	if (!inName)
		return((EInKey)0);
	// work downward instead of upward so lowercase characters match first
	for (i=INKEY_NUMKEYS-1;i>=0;i--)
	{
		if ((str = IN_NameForKey((EInKey)i, 0)) && (!stricmp(inName, str)))
			return((EInKey)i);
	}
	return((EInKey)0);
}

// returns a version of a key as if SHIFT were held down
// only works with regular characters
KRN_API EInKey IN_GetShiftedKey(EInKey inKey)
{
	if (in_Shifted[inKey])
		return((EInKey)in_Shifted[inKey]);
	return(inKey);
}

// find a bind map with the given name, if one doesn't exist create it
KRN_API HInBindMap IN_MakeBindMap(NChar* inName)
{
	if (!inName)
		return((HInBindMap)0);
	for (NDword i=0;i<in_NumBindMaps;i++)
	{
		if (!stricmp(inName, in_BindMaps[i]->mName))
			return((HInBindMap)(i+1));
	}
	in_BindMaps[in_NumBindMaps] = MEM_Malloc(CInputBindMap, 1);
	in_BindMaps[in_NumBindMaps]->Init();
	in_BindMaps[in_NumBindMaps]->mName = MEM_Malloc(NChar, strlen(inName)+1);
	strcpy(in_BindMaps[in_NumBindMaps]->mName, inName);
	in_NumBindMaps++;
	return(in_NumBindMaps);
}

KRN_API NBool IN_BindKey(HInBindMap inMap, EInKey inKey, NDword inFlags, NChar* inCmd)
{
	if (!inMap || (NDword)inMap > in_NumBindMaps)
		return(0);
	CInputBindMap* bindMap = in_BindMaps[(NDword)inMap - 1];
	NChar** pCmd = &bindMap->mCmds[(NDword)inKey][inFlags & INEVF_KEYMASK];
	if (*pCmd)
	{
		MEM_Free(*pCmd);
		*pCmd = NULL;
	}
	if (inCmd)
	{
		*pCmd = MEM_Malloc(NChar, strlen(inCmd)+1);
		strcpy(*pCmd, inCmd);
	}
	return(1);
}

// Translates an input event into the corresponding bound command for that event.
// Mouse moves translate to "MouseMove" since there is no key involved.  All key
// events map to "cmd", "cmd_drag", and "cmd_release" for press, drag, and release,
// respectively.  Note that the string returned is from a static local buffer, so
// commands which need to be preserved must be copied.
KRN_API NChar* IN_TranslateBindMap(HInBindMap inMap, SInEvent* inEvent)
{
	static char buf[4096];
	char* ptr;
	if (!inEvent)
		return(NULL);
	if (!inMap || (NDword)inMap > in_NumBindMaps)
		return(0);
	CInputBindMap* bindMap = in_BindMaps[(NDword)inMap - 1];
	switch(inEvent->eventType)
	{
	case INEV_MOUSEMOVE:
		strcpy(buf, "MouseMove");
		break;
	case INEV_PRESS:
		if (!(ptr = bindMap->mCmds[(NDword)inEvent->key][inEvent->flags & INEVF_KEYMASK]))
			return(NULL);
		strcpy(buf, ptr);
		break;
	case INEV_DRAG:
		if (!(ptr = bindMap->mCmds[(NDword)inEvent->key][inEvent->flags & INEVF_KEYMASK]))
			return(NULL);
		sprintf(buf, "%s_drag", ptr);
		break;
	case INEV_RELEASE:
		if (!(ptr = bindMap->mCmds[(NDword)inEvent->key][inEvent->flags & INEVF_KEYMASK]))
			return(NULL);
		sprintf(buf, "%s_release", ptr);
		break;
	default:
		return(NULL);
		break;
	}
	return(buf);
}

KRN_API NBool IN_DeTranslateBindMap(HInBindMap inMap, NChar* inCmd, EInKey* outKey, NDword* outFlags)
{
	if (!inMap || (NDword)inMap > in_NumBindMaps)
		return(0);
	CInputBindMap* bindMap = in_BindMaps[(NDword)inMap - 1];

	if (!inCmd)
		return(0);

	for (NDword i=0;i<INKEY_NUMKEYS;i++)
	{
		for (NDword j=0;j<(INEVF_KEYMASK+1);j++)
		{
			if (!bindMap->mCmds[i][j])
				continue;
			if (!stricmp(bindMap->mCmds[i][j], inCmd))
			{
				if (outKey)
					*outKey = (EInKey)i;
				if (outFlags)
					*outFlags = j;
				return(1);
			}
		}
	}
	return(0);
}

//============================================================================
//    CLASS METHODS
//============================================================================

//****************************************************************************
//**
//**    END MODULE INMAIN.CPP
//**
//****************************************************************************

