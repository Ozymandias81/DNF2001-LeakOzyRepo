//****************************************************************************
//**
//**    OVL_DEFS.CPP
//**    Overlays - Standard Overlay Type Definitions
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include "stdtool.h"
//----------------------------------------------------------------------------
//    Private Definitions
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Structures
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Additional External References
//----------------------------------------------------------------------------
extern overlay_t overlay_t_ovlprototype;
//----------------------------------------------------------------------------
//    Private Data
//----------------------------------------------------------------------------
char *ovlFlagNames[] =
{
	"nodraw",
	"noinput",
	"noborder",
	"notitle",
	"noerasecolor",
	"noerasedepth",
	"nomove",
	"noresize",
	"alwaystop",
	"proportional",
	"notitledestroy",
	"viewabsolute"
};

//----------------------------------------------------------------------------
//    Public Data
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Code Prototypes
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Code
//----------------------------------------------------------------------------
static unsigned long OVL_OverlayFlagForName(CC8 *name)
{
	int i, flag;

	if (!name)
		return(0);
	flag = 1;
	for (i=0,flag=1; ovlFlagNames[i]; i++,flag<<=1)
	{
		if (!_stricmp(name, ovlFlagNames[i]))
			return(flag);
	}
	return(0);
}

//----------------------------------------------------------------------------
//    Public Code
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Class Member Code
//----------------------------------------------------------------------------

///////////////////////////////////////////
////	OWindow
///////////////////////////////////////////

REGISTEROVLTYPE(OWindow, overlay_t);

U32 OWindow::OnMessage(ovlmsg_t *msg)
{
	OVLMSGSTART
	OVLMSG("GetBodyCursor") // (CC8 **cursorName)
	{
		*(OVLMSGPARM(0, CC8 **)) = "select";
		return(1);
	}
	return(Super::OnMessage(msg));
}

U32 OWindow::OnPressCommand(int argNum, CC8 **argList)
{	
	OVLCMDSTART
	OVLCMD("minimize")
	{
		if (!(flags & OVLF_NOTITLEMINMAX))
		{
			flags &= ~OVLF_MAXIMIZED;
			flags |= OVLF_MINIMIZED;
		}
		return(1);
	}
	OVLCMD("maximize")
	{
		if (!(flags & OVLF_NOTITLEMINMAX))
		{
			flags &= ~OVLF_MINIMIZED;
			flags |= OVLF_MAXIMIZED;
		}
		return(1);
	}
	OVLCMD("restore")
	{
		if (!(flags & OVLF_NOTITLEMINMAX))
			flags &= ~(OVLF_MINIMIZED|OVLF_MAXIMIZED);
		return(1);
	}
	OVLCMD("minmaxup")
	{
		if (flags & OVLF_MAXIMIZED)
			return(1);
		if (flags & OVLF_MINIMIZED)
		{
			if (!(flags & OVLF_NOTITLEMINMAX))
				flags &= ~(OVLF_MINIMIZED|OVLF_MAXIMIZED);
		}
		else
		{
			if (!(flags & OVLF_NOTITLEMINMAX))
			{
				flags &= ~OVLF_MINIMIZED;
				flags |= OVLF_MAXIMIZED;
			}
		}
		return(1);
	}
	OVLCMD("minmaxdown")
	{
		if (flags & OVLF_MINIMIZED)
			return(1);
		if (flags & OVLF_MAXIMIZED)
		{
			if (!(flags & OVLF_NOTITLEMINMAX))
				flags &= ~(OVLF_MINIMIZED|OVLF_MAXIMIZED);
		}
		else
		{
			if (!(flags & OVLF_NOTITLEMINMAX))
			{
				flags &= ~OVLF_MAXIMIZED;
				flags |= OVLF_MINIMIZED;
			}
		}
		return(1);
	}
	OVLCMD("destroy")
	{
		if (!(flags & OVLF_NOTITLEDESTROY))
			flags |= OVLF_TAGDESTROY; //delete ovl;
		return(1);
	}
	OVLCMD("setflag")
	{
		if (argNum < 2)
		{
			CON->Printf("[?] OWindow::Setflag flagname");
			return(1);
		}
		int flag = OVL_OverlayFlagForName(argList[1]);
		if (flag)
			flags |= flag;
		return(1);
	}
	OVLCMD("unsetflag")
	{
		if (argNum < 2)
		{
			CON->Printf("[?] OWindow::Unsetflag flagname");
			return(1);
		}
		int flag = OVL_OverlayFlagForName(argList[1]);
		if (flag)
			flags &= ~flag;
		return(1);
	}
	OVLCMD("toggleconsole")
	{
		overlay_t *console;
		console = OVL_CreateOverlay("OConsole", "Console (no target)", NULL, 0, 0, 320, 160, 0, true);
		OVL_SendMsg(console, "ConsoleTarget", 1, this);
		OVL_SetTopmost(console);
		return(1);
	}
	OVLCMD("exec")
	{
		if (argNum < 2)
		{
			CON->Printf("[?] OWindow::Exec filename.cfg");
			return(1);
		}
		CON->ExecuteFile(this, argList[1], true);
	}
	return(Super::OnPressCommand(argNum, argList));
}

///////////////////////////////////////////
////	OWindowScrollable
///////////////////////////////////////////

REGISTEROVLTYPE(OWindowScrollable, OWindow);

U32 OWindowScrollable::OnPressCommand(int argNum, CC8 **argList)
{
	OVLCMDSTART
	OVLCMD("mscroll")
	{
		startx = in_MouseX; starty = in_MouseY;
		OVL_MousePosWindowRelative(this, &startx, &starty);
		OVL_LockInput(this);
		return(1);
	}
	return(Super::OnPressCommand(argNum, argList));
}

U32 OWindowScrollable::OnDragCommand(int argNum, CC8 **argList)
{
	OVLCMDSTART
	OVLCMD("mscroll")
	{
		float frac;
		int mx, my;

		mx = in_MouseX; my = in_MouseY;
		OVL_MousePosWindowRelative(this, &mx, &my);

		frac = 1; //frac = (float)(vmax.x - vmin.x) / (float)dim.x;
		vpos.x += (int)((mx-startx)*frac);
//			if ((vpos.x + dim.x) > vmax.x)
//				vpos.x = vmax.x - dim.x;
//			if (vpos.x < vmin.x)
//				vpos.x = vmin.x;
		frac = 1; //frac = (float)(vmax.y - vmin.y) / (float)dim.y;
		vpos.y += (int)((my-starty)*frac);
//			if ((vpos.y + dim.y) > vmax.y)
//				vpos.y = vmax.y - dim.y;
//			if (vpos.y < vmin.y)
//				vpos.y = vmin.y;
		startx = mx;
		starty = my;
		return(1);
	}
	return(Super::OnDragCommand(argNum, argList));
}

U32 OWindowScrollable::OnReleaseCommand(int argNum, CC8 **argList)
{
	OVLCMDSTART
	OVLCMD("mscroll")
	{
		OVL_UnlockInput(this);
		return(1);
	}
	return(Super::OnReleaseCommand(argNum, argList));
}

///////////////////////////////////////////
////	OConsole
///////////////////////////////////////////

REGISTEROVLTYPE(OConsole, OWindow);

U32 OConsole::OnMessage(ovlmsg_t *msg)
{
	OVLMSGSTART
	OVLMSG("ConsoleTarget")
	{
		target = OVLMSGPARM(0, overlay_t *);
		return(1);
	}
	OVLMSG("Notify_OvlDeleting")
	{
		if (OVLMSGPARM(0, overlay_t *) == target)
		{
			target = NULL;
		}
		return(Super::OnMessage(msg));
	}
	return(Super::OnMessage(msg));
}

U32 OConsole::OnPressCommand(int argNum, CC8 **argList)
{
	OVLCMDSTART
	OVLCMD("toggleconsole")
	{
		flags |= OVLF_TAGDESTROY;
		if (target)
			OVL_SetTopmost(target);
		return(1);
	}
	return(Super::OnPressCommand(argNum, argList));
}

void OConsole::OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox)
{
	OVL_SetRedraw(this, false);
	if (!target)
	{
		flags |= OVLF_TAGDESTROY;
		return; // console is meaningless without a target
	}
	sprintf(name, "Console for \"%s\"", target->name);

	vector_t p[2], c[2];
	int ex, ey;
	char tempbuffer[CON_MAXLINELEN];
	int i, cmdOverflow;
	int cmdDisplayWidthChars, cmdDisplayHeightChars;
	
	clicker = (int)(mesh_app.get_frame_begin()*4.0)&1;
	cmdDisplayWidthChars = (dx / 6);
	cmdDisplayHeightChars = (dy / 8);
	if (cmdDisplayWidthChars < 3)
		cmdDisplayWidthChars = 3;
	if (cmdDisplayHeightChars < 3)
		cmdDisplayHeightChars = 3;
	ex = sx+dx;
	ey = sy+dy;
	p[0].Seti(sx, ey-10, 0);
	p[1].Seti(ex, ey-10, 0);
	c[0].Seti(255, 255, 255); c[1].Seti(255, 255, 255);
	vid->DepthEnable(FALSE);
	vid->DrawLine(&p[0], &p[1], &c[0], &c[1]);
	for (i=1;i<cmdDisplayHeightChars;i++)
	{
		memset(tempbuffer, 0, CON_MAXLINELEN);
		strncpy(tempbuffer,
			CON->cmdDisplay+((((unsigned int)(CON->cmdDisplayIndex-i-dispBackScroll))%CON_DISPLAYLINES)*CON_MAXLINELEN),
			cmdDisplayWidthChars-2);
		vid->DrawString(sx, ey-i*8-11, 6, 6, tempbuffer, true, 128, 128, 128);
	}
	vid->DrawString(sx, ey-8, 6, 6, ">", true, 128, 128, 128);
	memset(tempbuffer, 0, CON_MAXLINELEN);
	strcpy(tempbuffer, CON->cmdLine);
	cmdOverflow = fstrlen(tempbuffer) - (cmdDisplayWidthChars-2);
	if (cmdOverflow < 0)
		cmdOverflow = 0;
	if (clicker)
		strcat(tempbuffer, "_");
	vid->DrawString(sx+6, ey-8, 6, 6, tempbuffer+cmdOverflow, true, 128, 128, 128);
	vid->DepthEnable(TRUE);
}

U32 OConsole::OnPress(inputevent_t *event)
{
	if (!target)
	{
		flags |= OVLF_TAGDESTROY;
		return(1); // console is meaningless without a target
	}

	int tablen;
	int temp;
	static int histIndex=0, tabCycle=0;
	char tempstr[32];
	char *tabstr;
	int key;

	key = event->key;
	switch(key)
	{
	case KEY_ENTER:
		dispBackScroll = 0;
		if (!CON->cmdLine[0])
			break;
		CON->Printf(">%s", CON->cmdLine);
		CON->Execute(target, CON->cmdLine, 0);
		strcpy(CON->cmdHistory[CON->cmdHistoryIndex], CON->cmdLine);
		CON->cmdHistoryIndex++; CON->cmdHistoryIndex %= CON_HISTORYLINES;
		CON->cmdHistory[CON->cmdHistoryIndex][0] = 0;
		CON->cmdLine[0] = 0;
		histIndex=0;
		tabCycle = 0;
		break;
	case KEY_TAB:
		if (event->flags)
			return(Super::OnPress(event));
		if (!tabCycle)
			tablen = fstrlen(CON->cmdLine);
		tabstr = CON->MatchCommand(CON->cmdLine, tabCycle, tablen);
		if (tabstr)
		{
			strcpy(CON->cmdLine, tabstr);
			tabCycle++;
		}
		break;
	case KEY_UPARROW:
		temp = histIndex;
		histIndex++;
		if (!CON->cmdHistory[((unsigned int)(CON->cmdHistoryIndex-histIndex))%CON_HISTORYLINES][0])
			histIndex = temp;
		else
			strcpy(CON->cmdLine, CON->cmdHistory[((unsigned int)(CON->cmdHistoryIndex-histIndex))%CON_HISTORYLINES]);
		tabCycle = 0;
		break;
	case KEY_DOWNARROW:
		temp = histIndex;
		histIndex--;
		if ((!CON->cmdHistory[((unsigned int)(CON->cmdHistoryIndex-histIndex))%CON_HISTORYLINES][0]) && (histIndex != 0))
			histIndex = temp;
		else
			strcpy(CON->cmdLine, CON->cmdHistory[((unsigned int)(CON->cmdHistoryIndex-histIndex))%CON_HISTORYLINES]);
		tabCycle = 0;
		break;
	case KEY_BACKSPACE:
		if (fstrlen(CON->cmdLine) > 0)
			CON->cmdLine[fstrlen(CON->cmdLine)-1] = 0;
		if (event->flags & KF_SHIFT)
			CON->cmdLine[0] = 0;
		tabCycle = 0;
		break;
	case KEY_PGUP:
		dispBackScroll++;
		if (dispBackScroll >= (CON_DISPLAYLINES))//-cmdDisplayHeightChars))
			dispBackScroll = (CON_DISPLAYLINES);//-cmdDisplayHeightChars)-1;
		break;
	case KEY_PGDN:
		dispBackScroll--;
		if (dispBackScroll < 0)
			dispBackScroll = 0;
		break;
	case '`':
		return(Super::OnPress(event));
		break;
	case KEY_CTRL:
	case KEY_LSHIFT:
	case KEY_SHIFT:
	case KEY_LALT:
		return(Super::OnPress(event));
		break;
	default:		
		if ((vid->is_char_drawable(key)) // is it drawable?
			&& (!(event->flags & (KF_CONTROL|KF_ALT))))
		{
			if (event->flags & KF_SHIFT)
				key = in_Shifted[key];
			tempstr[0] = (byte)key; tempstr[1] = 0;
			if ((fstrlen(CON->cmdLine)+2) < CON_MAXLINELEN)
				strcat(CON->cmdLine, tempstr);
			return(1);
		}
		return(Super::OnPress(event));
	}
	return(1);
}

//****************************************************************************
//**
//**    END MODULE OVL_DEFS.CPP
//**
//****************************************************************************

