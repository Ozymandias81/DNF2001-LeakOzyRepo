//****************************************************************************
//**
//**    OVL_CC.CPP
//**    Overlays - Common Controls
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include "stdtool.h"
//----------------------------------------------------------------------------
//    Private Definitions
//----------------------------------------------------------------------------
#define OVL_MAXTOOLBARTOOLS 1024

//----------------------------------------------------------------------------
//    Private Structures
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Additional External References
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Data
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Data
//----------------------------------------------------------------------------
pool_t<ovltool_t> ovl_toolPool("Tools", OVL_MAXTOOLBARTOOLS, NULL, NULL);

//----------------------------------------------------------------------------
//    Private Code Prototypes
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Code
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Code
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Class Member Code
//----------------------------------------------------------------------------
///////////////////////////////////////////
////    OMenuItem
///////////////////////////////////////////
REGISTEROVLTYPE(OMenuItem, OWindow);
void OMenuItem::OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox)
{
	vector_t p[2];
    
    Super::OnDraw(sx,sy,dx,dy,clipbox);
	if (!OVL_ClipToBoxLimits(sx, sy, sx+dx, sy+dy, clipbox))
		return;
    vid->ColorMode(VCM_FLAT);
	vid->FlatColor(255, 255, 255);
	vid->DrawString(sx+2, sy+1, 8, 8, name, true, 128, 128, 128);
}

U32 OMenuItem::OnPress(inputevent_t* event)
{
	if (event->key != KEY_MOUSELEFT)
		return(Super::OnPress(event));
    if ((event->mouseX < 0) || (event->mouseX > dim.x))
        return(1);
    if ((event->mouseY < 0) || (event->mouseY > dim.y))
        return(1);
    if (command[0])
        CON->Execute(NULL, command, 0);
    if (logicParent)
        OVL_SendPressCommand(logicParent, "MenuKill");
    return(1);
}

U32 OMenuItem::OnRelease(inputevent_t* event)
{
	OVL_UnlockInput(this);
    return(1);
}

///////////////////////////////////////////
////    OMenu
///////////////////////////////////////////
REGISTEROVLTYPE(OMenu, OMenuItem);

void OMenu::OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox)
{
	vector_t p[2];
    
    Super::OnDraw(sx,sy,dx,dy,clipbox);
	if (!OVL_ClipToBoxLimits(sx, sy, sx+dx, sy+dy, clipbox))
		return;
    vid->ColorMode(VCM_FLAT);
	vid->FlatColor(255, 255, 255);
	vid->DrawString(sx+2, sy+1, 8, 8, name, true, 128, 128, 128);
    vid->DrawString(sx + (int)dim.x - 8, sy+1, 8, 8, ">", true, 128, 128, 128);
}

U32 OMenu::OnPress(inputevent_t* event)
{
	if (event->key != KEY_MOUSELEFT)
		return(Super::OnPress(event));
    if ((event->mouseX < 0) || (event->mouseX > dim.x))
        return(1);
    if ((event->mouseY < 0) || (event->mouseY > dim.y))
        return(1);
    if (showing)
        Hide();
    else
        Show();
    return(1);
}

U32 OMenu::OnRelease(inputevent_t* event)
{
	OVL_UnlockInput(this);
    return(1);
}

U32 OMenu::OnPressCommand(int argNum, CC8 **argList)
{
    OVLCMDSTART
    OVLCMD("MenuKill")
    {
	    for (overlay_t* child = parent->children->next; child != parent->children; child = child->next)
        {
            if (OVL_IsOverlayType(child, "OMenuItem"))
            {
                if (((OMenuItem*)child)->logicParent == this)                        
                    child->flags |= OVLF_TAGDESTROY;
            }
        }
        if (OVL_IsOverlayType(logicParent, "OMenu"))
            OVL_SendPressCommand(logicParent, "MenuKill");
        else
            flags |= OVLF_TAGDESTROY;
        return(1);
    }
    return(Super::OnPressCommand(argNum, argList));
}

///////////////////////////////////////////
////    OCheckBoxControl
///////////////////////////////////////////
REGISTEROVLTYPE(OCheckBoxControl, OWindow);

void OCheckBoxControl::OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox)
{
	vector_t p[2];
    
    Super::OnDraw(sx,sy,dx,dy,clipbox);
	if (!OVL_ClipToBoxLimits(sx, sy, sx+dx, sy+dy, clipbox))
		return;
    vid->ColorMode(VCM_FLAT);
	vid->FlatColor(255, 255, 255);
	p[0].Seti(sx, sy, 0);
	p[1].Seti(sx+10, sy+10, 0);
	vid->DepthEnable(FALSE);
	vid->DrawLineBox(&p[0], &p[1], NULL, NULL);
	vid->DrawString(sx+12, sy+2, 8, 8, name, true, 128, 128, 128);
    switch(checked)
    {
		case 0:
			break;
		case 1:
			vid->DrawString(sx+1, sy+2, 8, 8, "X", true, 0, 255, 0);
			break;
		case 2:
			vid->DrawString(sx+1, sy+2, 8, 8, "/", true, 64, 64, 64);
			break;
    }
	vid->DepthEnable(TRUE);
}

U32 OCheckBoxControl::OnPress(inputevent_t* event)
{
	if (event->key != KEY_MOUSELEFT)
		return(Super::OnPress(event));
    if ((event->mouseX < 0) || (event->mouseX > 10))
        return(1);
    if ((event->mouseY < 0) || (event->mouseY > 10))
        return(1);
    if (checked == 1)
        checked = 0;
    else
        checked = 1;
    OVL_SetRedraw(this, true);
    OVL_SendPressCommand(parent, "CheckBoxUpdate");
    return(1);
}

U32 OCheckBoxControl::OnRelease(inputevent_t* event)
{
	OVL_UnlockInput(this);
    return(1);
}

///////////////////////////////////////////
////    OSpinBoxControl
///////////////////////////////////////////
REGISTEROVLTYPE(OSpinBoxControl, OWindow);

void OSpinBoxControl::OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox)
{
	vector_t p[2];
    
    Super::OnDraw(sx,sy,dx,dy,clipbox);
	if (!OVL_ClipToBoxLimits(sx, sy, sx+dx, sy+dy, clipbox))
		return;
    vid->ColorMode(VCM_FLAT);
	vid->FlatColor(255, 255, 255);
	vid->DepthEnable(FALSE);
	p[0].Seti(sx, sy, 0);
	p[1].Seti(sx+8, sy+10, 0);
	vid->DrawLineBox(&p[0], &p[1], NULL, NULL);
    vid->DrawString(sx+1, sy+2, 6, 6, "-", true, 128, 128, 128);
	p[0].Seti(sx+27, sy, 0);
	p[1].Seti(sx+35, sy+10, 0);
	vid->DrawLineBox(&p[0], &p[1], NULL, NULL);
    vid->DrawString(sx+28, sy+2, 6, 6, "+", true, 128, 128, 128);
    char buf[16];
    sprintf(buf, "%d", spinValue);
	vid->DrawString(sx+9, sy+2, 6, 6, buf, true, 128, 128, 128);
	vid->DrawString(sx+37, sy+2, 8, 8, name, true, 128, 128, 128);
	vid->DepthEnable(TRUE);
}

U32 OSpinBoxControl::OnPress(inputevent_t* event)
{
	if (event->key != KEY_MOUSELEFT)
		return(Super::OnPress(event));
    if ((event->mouseX >= 0) && (event->mouseX <= 8) && (event->mouseY >= 0) && (event->mouseY <= 10))
    {
        spinValue--;
        if (spinValue < spinMin)
            spinValue = spinMin;
        OVL_SetRedraw(this, true);
        OVL_SendPressCommand(parent, "SpinBoxUpdate");
        return(1);
    }
    if ((event->mouseX >= 27) && (event->mouseX <= 35) && (event->mouseY >= 0) && (event->mouseY <= 10))
    {
        spinValue++;
        if (spinValue > spinMax)
            spinValue = spinMax;
        OVL_SetRedraw(this, true);
        OVL_SendPressCommand(parent, "SpinBoxUpdate");
        return(1);
    }
    return(Super::OnPress(event));
}

U32 OSpinBoxControl::OnDrag(inputevent_t* event)
{
	if (event->key != KEY_MOUSELEFT)
		return(Super::OnDrag(event));
    if ((event->mouseX >= 0) && (event->mouseX <= 8) && (event->mouseY >= 0) && (event->mouseY <= 10))
    {
        spinValue--;
        if (spinValue < spinMin)
            spinValue = spinMin;
        OVL_SetRedraw(this, true);
        OVL_SendPressCommand(parent, "SpinBoxUpdate");
        return(1);
    }
    if ((event->mouseX >= 27) && (event->mouseX <= 35) && (event->mouseY >= 0) && (event->mouseY <= 10))
    {
        spinValue++;
        if (spinValue > spinMax)
            spinValue = spinMax;
        OVL_SetRedraw(this, true);
        OVL_SendPressCommand(parent, "SpinBoxUpdate");
        return(1);
    }
    return(Super::OnDrag(event));
}

U32 OSpinBoxControl::OnRelease(inputevent_t* event)
{
	OVL_UnlockInput(this);
    return(1);
}

///////////////////////////////////////////
////    OToolbar
///////////////////////////////////////////

REGISTEROVLTYPE(OToolbar, OWindow);

/*
void OToolbar::OnSave()
{
}
*/

/*
void OToolbar::OnLoad()
{
}
*/

/*
void OToolbar::OnResize()
{
}
*/

void OToolbar::OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox)
{
	int numtools, tsize, tooldx, tooldy, checkx, checky;
	vector_t p[4], tv[4];
	ovltool_t *tool, *toolsHead, *mtool;
	int mx, my;

//	OVL_SetRedraw(this, false);
	numtools = 0;
	dim.x = 160+6;
	dim.y = 12+6+10;
	if (!ovl_focusOverlay)
	{
		flags |= OVLF_NODRAW|OVLF_NOINPUT;
		OVL_SetRedraw(this, true);
		return;
	}
	if (!OVL_SendMsg(ovl_focusOverlay, "GetToolsList", 4, &toolsHead, &numtools, &tooldx, &tooldy))
	{
		flags |= OVLF_NODRAW|OVLF_NOINPUT;
		OVL_SetRedraw(this, true);
		return;
	}
	if (!numtools)
	{
		flags |= OVLF_NODRAW|OVLF_NOINPUT;
		OVL_SetRedraw(this, true);
		return;
	}
	/* turn of depth */
	vid->DepthEnable(FALSE);
	dim.x = (float)(tooldx + 6);
	if (dim.x < 160+6)
		dim.x = 160+6;
	dim.y = (float)(tooldy + 12+6+10);
	
	vid->ColorMode(VCM_FLAT);
	vid->FlatColor(255, 255, 255);
	p[0].Seti(sx, sy+dy-9, 0);
	p[1].Seti(sx+dx, sy+dy-9, 0);
	vid->DrawLine(&p[0], &p[1], NULL, NULL);

	tv[0].Seti(0, 0, 0);
	tv[1].Seti(256, 0, 0);
	tv[2].Seti(256, 256, 0);
	tv[3].Seti(0, 256, 0);
	buttondim = 16;
	vid->ColorMode(VCM_TEXTURE);

	checkx = checky = 0;
	mx = in_MouseX; my = in_MouseY;
	mtool = NULL;
	OVL_MousePosWindowRelative(this, &mx, &my);
	for (tool=toolsHead->next; tool!=toolsHead; tool=tool->next)
	{
		if (tool->tooltype == OVLTOOL_HSEPAR)
		{
			checkx += 4;
		}
		else if (tool->tooltype == OVLTOOL_VSEPAR)
		{
			checkx = 0; checky += 16; //20;
		}
		else
		{
			vid->TexActivate(IN_GetButtonTex(tool->button), VTA_NORMAL);
			p[0].Seti(sx+checkx, sy+checky, 0);
			p[1].Seti(sx+checkx+16, sy+checky, 0);
			p[2].Seti(sx+checkx+16, sy+checky+16, 0);
			p[3].Seti(sx+checkx, sy+checky+16, 0);

			if ((p[0].y - p[2].y) > 30.0f)
				xxx_throw("Something wacky");
			if ((p[2].y - p[0].y) > 30.0f)
				xxx_throw("Something wacky 2");

			vid->DrawPolygon(4, p, NULL, NULL, tv);
			if ((tool->active) || (tool->flashframes))
			{
				vid->ColorMode(VCM_FLAT);
				vid->AlphaMode(VAM_FLAT);
				vid->BlendMode(VBM_TRANSMERGE);
				vid->FlatColorf(tool->color.x, tool->color.y, tool->color.z);
				vid->FlatAlpha(96);
				vid->DrawPolygon(4, p, NULL, NULL, NULL);
				vid->ColorMode(VCM_TEXTURE);
				vid->BlendMode(VBM_OPAQUE);
				if (tool->flashframes)
					tool->flashframes--;
			}
			if ((!mtool) && (mx >= checkx) && (mx < checkx+16)
			 && (my >= checky) && (my < checky+16))
			{
				mtool = tool;
			}
			checkx += 16;
		}
	}
	if (mtool)
	{
		tsize = (int)((dim.x - 6) / fstrlen(mtool->name));
		if (tsize > 8)
			tsize = 8;
		vid->DrawString(sx+1, sy+dy-8, tsize, tsize, mtool->name, true, 128, 128, 128);
	}
	vid->DepthEnable(TRUE);
	Super::OnDraw(sx, sy, dx, dy, clipbox);
}

U32 OToolbar::OnPress(inputevent_t *event)
{
	int checkx, checky, tooldx, tooldy, numtools;
	ovltool_t *tool, *toolsHead, *checktool;

	if (!ovl_focusOverlay)
	{
		flags |= OVLF_NODRAW|OVLF_NOINPUT;
		OVL_SetRedraw(this, true);
		return(1);
	}
	if (!OVL_SendMsg(ovl_focusOverlay, "GetToolsList", 4, &toolsHead, &numtools, &tooldx, &tooldy))
	{
		flags |= OVLF_NODRAW|OVLF_NOINPUT;
		OVL_SetRedraw(this, true);
		return(1);
	}
	if (!numtools)
	{
		flags |= OVLF_NODRAW|OVLF_NOINPUT;
		OVL_SetRedraw(this, true);
		return(1);
	}

	if (event->key != KEY_MOUSELEFT)
		return(Super::OnPress(event));

	checkx = checky = 0;
	for (tool=toolsHead->next; tool!=toolsHead; tool=tool->next)
	{
		if (tool->tooltype == OVLTOOL_HSEPAR)
		{
			checkx += 4;
		}
		else if (tool->tooltype == OVLTOOL_VSEPAR)
		{
			checkx = 0; checky += 16; //20;
		}
		else
		{
			if ((event->mouseX >= checkx) && (event->mouseX < checkx+16)
			 && (event->mouseY >= checky) && (event->mouseY < checky+16))
			{
				break;
			}
			checkx += 16;
		}
	}
	if (tool == toolsHead)
		return(1);

	OVL_LockInput(this); // need to lock before executing commands, incase one of them needs to release the lock
	switch(tool->tooltype)
	{
	case OVLTOOL_RADIO:
		for (checktool=toolsHead->next; checktool!=toolsHead; checktool=checktool->next)
		{
			if ((checktool->tooltype == OVLTOOL_RADIO) && (checktool->radiogroup == tool->radiogroup))
			{
				if (checktool->active)
				{
					CON->Execute(ovl_focusOverlay, checktool->commands[2], 0);
				}
				checktool->active = 0;
			}
		}
		tool->active = 1;
		CON->Execute(ovl_focusOverlay, tool->commands[0], 0);
		break;
	case OVLTOOL_TOGGLE:
		tool->active ^= 1;
		if (tool->active)
			CON->Execute(ovl_focusOverlay, tool->commands[0], 0);
		else
			CON->Execute(ovl_focusOverlay, tool->commands[1], 0);
		break;
	case OVLTOOL_INSTANT:
		CON->Execute(ovl_focusOverlay, tool->commands[0], 0);
		tool->flashframes = (int)(0.1f / mesh_app.get_frame_delta()); // flash for 1/10th second
		break;
	}
	return(1);
}

/*
U32 OToolbar::OnDrag(inputevent_t *event)
{
}
*/

U32 OToolbar::OnRelease(inputevent_t *event)
{
	OVL_UnlockInput(this);
	if (ovl_focusOverlay)
		OVL_SetTopmost(ovl_focusOverlay);
	return(1);
}

/*
U32 OToolbar::OnPressCommand(int argNum, CC8 **argList)
{
}
*/

/*
U32 OToolbar::OnDragCommand(int argNum, CC8 **argList)
{
}
*/

/*
U32 OToolbar::OnReleaseCommand(int argNum, CC8 **argList)
{
}
*/

/*
U32 OToolbar::OnMessage(ovlmsg_t *msg)
{
}
*/

///////////////////////////////////////////
////    OToolWindow
///////////////////////////////////////////

REGISTEROVLTYPE(OToolWindow, OWindowScrollable);

void OToolWindow::ActivateRadioTool(ovltool_t *activeTool)
{
	if (!activeTool)
		return;
	if (activeTool->tooltype != OVLTOOL_RADIO)
		return;
	for (int i=0;i<OTOOLWINDOW_MAXCONTEXTS;i++)
	{
		for (ovltool_t *tool=contexts[i].toolsHead.next; tool!=&contexts[i].toolsHead; tool=tool->next)
		{
			if ((tool->tooltype == OVLTOOL_RADIO) && (tool->radiogroup == activeTool->radiogroup))
			{
				if (tool->active)
				{
					CON->Execute(ovl_focusOverlay, tool->commands[2], 0);
				}
				tool->active = 0;
			}
		}
	}
	activeTool->active = 1;
	CON->Execute(this, activeTool->commands[0], 0);
}

ovltool_t *OToolWindow::FindActiveRadioTool(int group)
{
	for (int i=0;i<OTOOLWINDOW_MAXCONTEXTS;i++)
	{
		for (ovltool_t *tool=contexts[i].toolsHead.next; tool!=&contexts[i].toolsHead; tool=tool->next)
		{
			if ((tool->tooltype == OVLTOOL_RADIO) && (tool->radiogroup == group) && (tool->active))
				return(tool);
		}
	}
	return(NULL);
}

ovltool_t *OToolWindow::ToolForName(CC8 *name)
{
	if (!name)
		return(NULL);
	for (int i=0;i<OTOOLWINDOW_MAXCONTEXTS;i++)
	{
		for (ovltool_t *tool=contexts[i].toolsHead.next; tool!=&contexts[i].toolsHead; tool=tool->next)
		{
			if ((tool->tooltype == OVLTOOL_HSEPAR) || (tool->tooltype == OVLTOOL_VSEPAR))
				continue;
			if (!_stricmp(name, tool->name))
				return(tool);
		}
	}
	return(NULL);
}

void OToolWindow::SetContext(int contextNum)
{
	if ((contextNum < 0) || (contextNum >= OTOOLWINDOW_MAXCONTEXTS))
		return;
	curContext = &contexts[contextNum];
}

void OToolWindow::OnSave()
{
	ovltool_t *tool;
	int i, size;

	Super::OnSave();
	for (size=4,i=0; i<OTOOLWINDOW_MAXCONTEXTS; i++)
	{
		size += 512*contexts[i].numtools + 16;
	}
	VCR_EnlargeActionDataBuffer(size);
	for (i=0; i<OTOOLWINDOW_MAXCONTEXTS; i++)
	{
		VCR_WriteInt(contexts[i].numtools);
		VCR_WriteInt(contexts[i].tooldx);
		VCR_WriteInt(contexts[i].curtooldx);
		VCR_WriteInt(contexts[i].tooldy);
		for (tool=contexts[i].toolsHead.next; tool!=&contexts[i].toolsHead; tool=tool->next)
		{
			VCR_WriteString(tool->name);
			VCR_WriteString(tool->cursor);
			VCR_WriteString(tool->button);
			VCR_WriteByte((U8)tool->active);
			VCR_WriteByte((U8)tool->tooltype);
			VCR_WriteByte(tool->radiogroup);
			VCR_WriteFloat(tool->color.x);
			VCR_WriteFloat(tool->color.y);
			VCR_WriteFloat(tool->color.z);
			VCR_WriteString(tool->commands[0]);
			VCR_WriteString(tool->commands[1]);
			VCR_WriteString(tool->commands[2]);
		}
	}
	VCR_WriteInt(curContext - contexts);
}

void OToolWindow::OnLoad()
{
	ovltool_t *tool;
	int i, k;

	Super::OnLoad();
	for (i=0; i<OTOOLWINDOW_MAXCONTEXTS; i++)
	{
		while(contexts[i].toolsHead.next != &contexts[i].toolsHead)
		{
			tool = contexts[i].toolsHead.next;
			tool->prev->next = tool->next;
			tool->next->prev = tool->prev;
			ovl_toolPool.Free(tool);
		}
		contexts[i].numtools = VCR_ReadInt();
		contexts[i].tooldx = VCR_ReadInt();
		contexts[i].curtooldx = VCR_ReadInt();
		contexts[i].tooldy = VCR_ReadInt();
		for (k=0;k<contexts[i].numtools;k++)
		{
			tool = ovl_toolPool.Alloc(NULL);
			tool->prev = contexts[i].toolsHead.prev;
			tool->next = &contexts[i].toolsHead;
			tool->prev->next = tool;
			tool->next->prev = tool;
			strcpy(tool->name, VCR_ReadString());
			strcpy(tool->cursor, VCR_ReadString());
			strcpy(tool->button, VCR_ReadString());
			tool->active = VCR_ReadByte();
			tool->tooltype = (ovltooltype_t)VCR_ReadByte();
			tool->radiogroup = VCR_ReadByte();
			tool->color.x = VCR_ReadFloat();
			tool->color.y = VCR_ReadFloat();
			tool->color.z = VCR_ReadFloat();
			strcpy(tool->commands[0], VCR_ReadString());
			strcpy(tool->commands[1], VCR_ReadString());
			strcpy(tool->commands[2], VCR_ReadString());
		}
	}
	curContext = &contexts[VCR_ReadInt()];
}

/*
void OToolWindow::OnResize()
{
}
*/

void OToolWindow::OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox)
{
	if (!toolbar)
	{
		if (!(toolbar = OVL_FindChild(NULL, NULL, "OToolbar", NULL)))
		{ // create the toolbar if it doesn't already exist
			toolbar = OVL_CreateOverlay("OToolbar", "Tools", NULL, 0, 0, 3+3, 16+12+3+3,
				OVLF_VIEWABSOLUTE|OVLF_NORESIZE|OVLF_ALWAYSTOP|OVLF_NOTITLEDESTROY|OVLF_NOTITLEMINMAX|OVLF_NODRAGDROP|OVLF_NOFOCUS, true);
		}
	}
	if (ovl_focusOverlay == this)
	{
		if (toolbar->flags & OVLF_NODRAW)
			OVL_SetRedraw(toolbar, true);
		toolbar->flags &= ~(OVLF_NODRAW|OVLF_NOINPUT); // make sure it's visible
	}
	Super::OnDraw(sx, sy, dx, dy, clipbox);
}

/*
U32 OToolWindow::OnPress(inputevent_t *event)
{
}
*/

/*
U32 OToolWindow::OnDrag(inputevent_t *event)
{
}
*/

/*
U32 OToolWindow::OnRelease(inputevent_t *event)
{
}
*/

U32 OToolWindow::OnPressCommand(int argNum, CC8 **argList)
{
	OVLCMDSTART
	OVLCMD("radiocmd")
	{
		if (argNum < 2)
		{
			CON->Printf("[?] OToolWindow::Radiocmd radioGroup");
			return(1);
		}
		ovltool_t *tool = FindActiveRadioTool(atoi(argList[1]));
		if (!tool)
			return(1);
		CON->Execute(this, tool->commands[1], 0);
		return(1);
	}
	OVLCMD("radionext")
	{
		if (argNum < 2)
		{
			CON->Printf("[?] OToolWindow::Radionext radioGroup");
			return(1);
		}
		int group = atoi(argList[1]);
		ovltool_t *tool = FindActiveRadioTool(group);
		if (!tool)
			return(1);
		do
		{
			tool = tool->next;
		} while ((tool->tooltype != OVLTOOL_RADIO) || (tool->radiogroup != group) || (tool == &curContext->toolsHead));
		ActivateRadioTool(tool);
		return(1);
	}
	OVLCMD("radioprev")
	{
		if (argNum < 2)
		{
			CON->Printf("[?] OToolWindow::Radioprev radioGroup");
			return(1);
		}
		int group = atoi(argList[1]);
		ovltool_t *tool = FindActiveRadioTool(group);
		if (!tool)
			return(1);
		do
		{
			tool = tool->prev;
		} while ((tool->tooltype != OVLTOOL_RADIO) || (tool->radiogroup != group) || (tool == &curContext->toolsHead));
		ActivateRadioTool(tool);
		return(1);
	}
	OVLCMD("radioactivate")
	{
		if (argNum < 3)
		{
			CON->Printf("[?] OToolWindow::RadioActivate radioGroup toolNum");
			return(1);
		}
		int group = atoi(argList[1]);
		int index = atoi(argList[2]);
		int i = 0;
		
		for (int j=0;j<OTOOLWINDOW_MAXCONTEXTS;j++)
		{
			for (ovltool_t *tool=contexts[j].toolsHead.next; tool!=&contexts[j].toolsHead; tool=tool->next)
			{			
				if ((tool->tooltype == OVLTOOL_RADIO) && (tool->radiogroup == group))
				{
					if (i == index)
					{
						ActivateRadioTool(tool);
						return(1);
					}
					i++;
				}
			}
		}
		return(1);
	}
	OVLCMD("addtool")
	{
		ovltooltype_t ttype;

		if (argNum < 7)
		{
			CON->Printf("[?] OToolWindow::Addtool toolName toolType buttonName cursorName radioGroup command1 [command2] [command3]");
			return(1);
		}
		if (!_stricmp(argList[2], "radio"))
			ttype = OVLTOOL_RADIO;
		else if (!_stricmp(argList[2], "toggle"))
			ttype = OVLTOOL_TOGGLE;
		else if (!_stricmp(argList[2], "instant"))
			ttype = OVLTOOL_INSTANT;
		else if (!_stricmp(argList[2], "hsepar"))
			ttype = OVLTOOL_HSEPAR;
		else if (!_stricmp(argList[2], "vsepar"))
			ttype = OVLTOOL_VSEPAR;
		else
		{
			CON->Printf("Addtool: Invalid tool type (choose radio/toggle/instant/hsepar/vsepar)");
			return(1);
		}
		ovltool_t *tool = ovl_toolPool.Alloc(NULL);
		memset(tool->name, 0, 64);
		strncpy(tool->name, argList[1], 63);
		tool->prev = curContext->toolsHead.prev;
		tool->next = &curContext->toolsHead;
		tool->prev->next = tool;
		tool->next->prev = tool;
		tool->tooltype = ttype;
		strcpy(tool->button, argList[3]);
		strcpy(tool->cursor, argList[4]);
		tool->radiogroup = atoi(argList[5]);
		tool->color.Seti(0, 192, 96);
		tool->flashframes = 0;
		tool->active = 0;
		strcpy(tool->commands[0], argList[6]);
		tool->commands[1][0] = 0;
		tool->commands[2][0] = 0;
		if (argNum > 7)
			strcpy(tool->commands[1], argList[7]);
		if (argNum > 8)
			strcpy(tool->commands[2], argList[8]);
		switch(tool->tooltype)
		{
		case OVLTOOL_RADIO:
			curContext->curtooldx += 16;
			if (curContext->tooldx < curContext->curtooldx)
				curContext->tooldx = curContext->curtooldx;
//			ActivateRadioTool(tool);
			break;
		case OVLTOOL_TOGGLE:
			curContext->curtooldx += 16;
			if (curContext->tooldx < curContext->curtooldx)
				curContext->tooldx = curContext->curtooldx;
			break;
		case OVLTOOL_INSTANT:
			curContext->curtooldx += 16;
			if (curContext->tooldx < curContext->curtooldx)
				curContext->tooldx = curContext->curtooldx;
			break;
		case OVLTOOL_HSEPAR:
			curContext->curtooldx += 4;
			if (curContext->tooldx < curContext->curtooldx)
				curContext->tooldx = curContext->curtooldx;
			break;
		case OVLTOOL_VSEPAR:
			curContext->tooldy += 16; //20;
			curContext->curtooldx = 0;
			break;
		}
		curContext->numtools++;
		return(1);
	}
	OVLCMD("toolcolor")
	{
		ovltool_t *tool;

		if (argNum < 5)
		{
			CON->Printf("[?] OToolWindow::Toolcolor toolname r g b");
			return(1);
		}
		if (!(tool = ToolForName(argList[1])))
			return(1);
		tool->color.Seti(atoi(argList[2]), atoi(argList[3]), atoi(argList[4]));
		return(1);
	}
	OVLCMD("toolactivate")
	{
		ovltool_t *tool;
		ovltoolContext_t *oldContext;
		int cnum;

		if (argNum < 3)
		{
			CON->Printf("[?] OToolWindow::ToolActivate contextNum toolName");
			return(1);
		}
		oldContext = curContext;
		cnum = atoi(argList[1]);
		SetContext(cnum);
		tool = ToolForName(argList[2]);
		if (!tool)
		{
			CON->Printf("OToolWindow::ToolActivate: %s is not a valid tool in context %d", argList[2], cnum);
			return(1);
		}
		switch(tool->tooltype)
		{
		case OVLTOOL_RADIO:
			ActivateRadioTool(tool);
			break;
		case OVLTOOL_TOGGLE:
			tool->active ^= 1;
			if (tool->active)
				CON->Execute(this, tool->commands[0], 0);
			else
				CON->Execute(this, tool->commands[1], 0);
			break;
		case OVLTOOL_INSTANT:
			CON->Execute(this, tool->commands[0], 0);
			tool->flashframes = (int)(0.1f / mesh_app.get_frame_delta()); // flash for 1/10th second
			break;
		}
		curContext = oldContext;
		return(1);
	}
	OVLCMD("settoolcontext")
	{
		if (argNum < 2)
		{
			CON->Printf("[?] OToolWindow::SetToolContext contextNum");
			return(1);
		}
		SetContext(atoi(argList[1]));
		return(1);
	}
	return(Super::OnPressCommand(argNum, argList));
}

U32 OToolWindow::OnDragCommand(int argNum, CC8 **argList)
{
	OVLCMDSTART
	OVLCMD("radiocmd")
	{
		if (argNum < 2)
		{
			CON->Printf("[?] OToolWindow::Radiocmd radioGroup");
			return(1);
		}
		ovltool_t *tool = FindActiveRadioTool(atoi(argList[1]));
		if (!tool)
			return(1);
		OVL_SendDragCommand(this, tool->commands[1]);
		return(1);
	}
	return(Super::OnDragCommand(argNum, argList));
}

U32 OToolWindow::OnReleaseCommand(int argNum, CC8 **argList)
{
	OVLCMDSTART
	OVLCMD("radiocmd")
	{
		if (argNum < 2)
		{
			CON->Printf("[?] OToolWindow::Radiocmd radioGroup");
			return(1);
		}
		ovltool_t *tool = FindActiveRadioTool(atoi(argList[1]));
		if (!tool)
			return(1);
		OVL_SendReleaseCommand(this, tool->commands[1]);
		return(1);
	}
	return(Super::OnReleaseCommand(argNum, argList));
}

U32 OToolWindow::OnMessage(ovlmsg_t *msg)
{
	OVLMSGSTART
	OVLMSG("GetBodyCursor") // (CC8 **cursorName)
	{
		ovltool_t *tool = FindActiveRadioTool(0);
		if (tool)
			*(OVLMSGPARM(0, CC8 **)) = tool->cursor;
		else
			*(OVLMSGPARM(0, CC8 **)) = "select";
		return(1);
	}
	OVLMSG("GetToolsList") // (ovltool_t **toolsHead, int *numTools, int *tooldx, int *tooldy)
	{
		*(OVLMSGPARM(0, ovltool_t **)) = &curContext->toolsHead;
		*(OVLMSGPARM(1, int *)) = curContext->numtools;
		*(OVLMSGPARM(2, int *)) = curContext->tooldx;
		*(OVLMSGPARM(3, int *)) = curContext->tooldy + 16;
		return(1);
	}
	return(Super::OnMessage(msg));
}

///////////////////////////////////////////
////    OSelectionBox
///////////////////////////////////////////

REGISTEROVLTYPE(OSelectionBox, OWindow);

/*
void OSelectionBox::OnSave()
{
}
*/

/*
void OSelectionBox::OnLoad()
{
}
*/

/*
void OSelectionBox::OnResize()
{
}
*/

void OSelectionBox::OnCalcLogicalDim(int dx, int dy)
{
	Super::OnCalcLogicalDim(dx, dy);
	vmax.y = (float)(numItems*8);
	vmin.y = 0;
	if (vpos.y < vmin.y)
		vpos.y = vmin.y;
	if (vpos.y > vmax.y - 28*8+4)
		vpos.y = vmax.y - 28*8+4;
}

void OSelectionBox::OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox)
{
	int i, adjy;
	char *ptr;
	vector_t p[4];

	if (!numItems)
		return;
	if (!OVL_ClipToBoxLimits(sx, sy, sx+dx, sy+dy, clipbox))
		return;
	adjy = (int)vpos.y;
	if (adjy < 0)
		adjy = 0;
	if (adjy > (numItems-1)*8)
		adjy = (numItems-1)*8;
	ptr = itemStr;
	vid->DepthEnable(FALSE);
	for (i=0;i<numItems;i++)
	{
		if (((!multiSelect) && (i == selectedItem)) || ((multiSelect) && (itemFlags[i] & OSELECTIONBOXF_SELECTED)))
		{
			p[0].Seti(sx, sy+i*8 - adjy, 0);
			p[2].Setf((float)(sx+dx), p[0].y+8, 0.0f);
			p[1].Setf(p[2].x, p[0].y, 0.0f);
			p[3].Setf(p[0].x, p[2].y, 0.0f);
			vid->ColorMode(VCM_FLAT);
			vid->FlatColor(0, 0, 128);
			vid->DrawPolygon(4, p, NULL, NULL, NULL);
		}
		vid->DrawString(sx+2, sy+i*8 - adjy, 8, 8, ptr, true, 128, 128, 128);
		ptr += fstrlen(ptr)+1;
	}
	vid->DepthEnable(TRUE);
}

U32 OSelectionBox::OnPress(inputevent_t *event)
{
	int i, k, adjy;
	char *ptr;

	if (event->key != KEY_MOUSELEFT)
	{
		if (event->key == KEY_ENTER)
		{			
			if (!multiSelect)
			{
				char tbuffer[256];
				sprintf(tbuffer, "%s \"%s\"", cbCommand, selectedItemText);
				if (cbOvl)
					CON->Execute(cbOvl, tbuffer, 0);
			}
			else
			{
				char tbuffer[256];

				for (k=0,ptr=itemStr;k<numItems;k++,ptr+=fstrlen(ptr)+1)
				{
					if (itemFlags[k] & OSELECTIONBOXF_SELECTED)
					{
						sprintf(tbuffer, "%s \"%s\"", cbCommand, ptr);
						if (cbOvl)
							CON->Execute(cbOvl, tbuffer, 0);
					}
				}
			}
			flags |= OVLF_TAGDESTROY;
			flags &= ~OVLF_MEGALOCK;
			OVL_UnlockInput(this);
			return(1);
		}
		else
		if (event->key == KEY_ESCAPE)
		{
			flags |= OVLF_TAGDESTROY;
			flags &= ~OVLF_MEGALOCK;
			OVL_UnlockInput(this);
			return(1);
		}
		else
			return(1); //return(Super::OnPress(event));
	}
	if (!numItems)
		return(1);
	adjy = (int)vpos.y;
	if (adjy < 0)
		adjy = 0;
	if (adjy > (numItems-1)*8)
		adjy = (numItems-1)*8;
	i = (event->mouseY + adjy) / 8;
	if ((i < 0) || (i >= numItems))
		return(1);	
	if ((!(event->flags & KF_CONTROL)) || (!multiSelect))
	{
		for (k=0;k<numItems;k++)
			itemFlags[k] &= ~OSELECTIONBOXF_SELECTED;
	}
	if ((event->flags & KF_SHIFT) && (multiSelect))
	{
		if (selectedItem > i)
		{
			for (k=i+1;k<=selectedItem;k++)
				itemFlags[k] |= OSELECTIONBOXF_SELECTED;
		}
		else
		{
			for (k=selectedItem;k<i;k++)
				itemFlags[k] |= OSELECTIONBOXF_SELECTED;
		}
	}
	selectedItem = i;
	itemFlags[i] ^= OSELECTIONBOXF_SELECTED;
	ptr = itemStr;
	for (i=0,ptr=itemStr;i<selectedItem;i++,ptr+=fstrlen(ptr)+1)
		;
	strcpy(selectedItemText, ptr);
	return(1);
}

/*
U32 OSelectionBox::OnDrag(inputevent_t *event)
{
}
*/

/*
U32 OSelectionBox::OnRelease(inputevent_t *event)
{
}
*/

/*
U32 OSelectionBox::OnPressCommand(int argNum, CC8 **argList)
{
}
*/

/*
U32 OSelectionBox::OnDragCommand(int argNum, CC8 **argList)
{
}
*/

/*
U32 OSelectionBox::OnReleaseCommand(int argNum, CC8 **argList)
{
}
*/

U32 OSelectionBox::OnMessage(ovlmsg_t *msg)
{
	OVLMSGSTART
	OVLMSG("SelectionBoxInfo") // char *choices, overlay_t *cbOvl, char *cbCommand, int multiSelect
	{
		char *ptr;
		int len;

		if (itemStr)
			FREE(itemStr);
		if (itemFlags)
			FREE(itemFlags);
		itemStr=null;
		itemFlags=null;

		numItems = 0;
		len = 1;
		for (ptr=OVLMSGPARM(0, char *); *ptr; ptr += fstrlen(ptr)+1)
		{
			len += fstrlen(ptr)+1;
			numItems++;
		}
		itemFlags = ALLOC(U8, numItems);
		memset(itemFlags, 0, numItems);
		itemStr = ALLOC(char, len);
		memcpy(itemStr, OVLMSGPARM(0, char *), len);
		selectedItem = 0;
		selectedItemText[0] = 0;
		if (numItems)
		{
			strcpy(selectedItemText, itemStr);
			itemFlags[0] |= OSELECTIONBOXF_SELECTED;
		}
		cbOvl = OVLMSGPARM(1, overlay_t *);
		strcpy(cbCommand, OVLMSGPARM(2, char *));
		multiSelect = OVLMSGPARM(3, int);
		return(1);
	}
	return(Super::OnMessage(msg));
}

///////////////////////////////////////////
////    OInputBox
///////////////////////////////////////////

REGISTEROVLTYPE(OInputBox, OWindow);

/*
void OInputBox::OnSave()
{
}
*/

/*
void OInputBox::OnLoad()
{
}
*/

/*
void OInputBox::OnResize()
{
}
*/

void OInputBox::OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox)
{
	vector_t p[2];
	int start, len;

	if (!OVL_ClipToBoxLimits(sx, sy, sx+dx, sy+dy, clipbox))
		return;
	vid->DepthEnable(FALSE);
	vid->DrawString(sx+2, sy+2, 8, 8, text, true, 128, 128, 128);
	p[0].Seti(sx+2, sy+12, 0);
	p[1].Setf((float)(sx+dx-2), p[0].y+8, 0.0f);
	vid->ColorMode(VCM_FLAT);
	vid->FlatColor(128, 128, 128);
	vid->DrawLineBox(&p[0], &p[1], NULL, NULL);

	len = ((dx-8)/6)-1;
	start = 0;
	if ((int)fstrlen(inputBuffer)>len)
		start = fstrlen(inputBuffer)-len;
	vid->DrawString(sx+4, sy+14, 6, 6, inputBuffer+start, true, 128, 128, 128);
	if ((int)(mesh_app.get_frame_begin()*4.0) & 1)
		vid->DrawString(sx+4+fstrlen(inputBuffer+start)*6, sy+13, 6, 6, "_", true, 128, 128, 128);

	vid->DepthEnable(TRUE);
}

U32 OInputBox::OnPress(inputevent_t *event)
{
	int key;
	char tempstr[32];

	switch(event->key)
	{
	case KEY_ENTER:
		char tbuffer[256];
		sprintf(tbuffer, "%s \"%s\"", cbCommand, inputBuffer);
		if (cbOvl)
			CON->Execute(cbOvl, tbuffer, 0);
		flags |= OVLF_TAGDESTROY;
		flags &= ~OVLF_MEGALOCK;
		OVL_UnlockInput(this);
		return(1);
		break;
	case KEY_ESCAPE:
		flags |= OVLF_TAGDESTROY;
		flags &= ~OVLF_MEGALOCK;
		OVL_UnlockInput(this);
		return(1);
		break;
	case KEY_BACKSPACE:
		if (fstrlen(inputBuffer) > 0)
			inputBuffer[fstrlen(inputBuffer)-1] = 0;
		if (event->flags & KF_SHIFT)
			inputBuffer[0] = 0;
		return(1);
		break;
	default:
		if ((vid->is_char_drawable(event->key)) // is it drawable?
			&& (!(event->flags & (KF_CONTROL|KF_ALT))))
		{
			key = event->key;
			if (event->flags & KF_SHIFT)
				key = in_Shifted[key];
			tempstr[0] = (U8)key; tempstr[1] = 0;
			if ((fstrlen(inputBuffer)+2) < 255)
				strcat(inputBuffer, tempstr);
			return(1);
		}
		break;
	}
	return(Super::OnPress(event));
}

/*
U32 OInputBox::OnDrag(inputevent_t *event)
{
}
*/

/*
U32 OInputBox::OnRelease(inputevent_t *event)
{
}
*/

/*
U32 OInputBox::OnPressCommand(int argNum, CC8 **argList)
{
}
*/

/*
U32 OInputBox::OnDragCommand(int argNum, CC8 **argList)
{
}
*/

/*
U32 OInputBox::OnReleaseCommand(int argNum, CC8 **argList)
{
}
*/

U32 OInputBox::OnMessage(ovlmsg_t *msg)
{
	OVLMSGSTART
	OVLMSG("InputBoxInfo") // char *text, overlay_t *cbOvl, char *cbCommand, char *initialInput
	{
		strcpy(text, OVLMSGPARM(0, char *));
		cbOvl = OVLMSGPARM(1, overlay_t *);
		strcpy(cbCommand, OVLMSGPARM(2, char *));
		strcpy(inputBuffer, OVLMSGPARM(3, char *));
		return(1);
	}
	return(Super::OnMessage(msg));
}

//****************************************************************************
//**
//**    END MODULE OVL_CC.CPP
//**
//****************************************************************************

