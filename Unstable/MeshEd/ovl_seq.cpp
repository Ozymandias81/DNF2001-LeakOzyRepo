//****************************************************************************
//**
//**    OVL_SEQ.CPP
//**    Overlays - Sequence
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
//----------------------------------------------------------------------------
//    Private Data
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Data
//----------------------------------------------------------------------------
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
////    OSequence
///////////////////////////////////////////

REGISTEROVLTYPE(OSequence, OWindow);

void OSequence::OnSave()
{
	Super::OnSave();
	VCR_EnlargeActionDataBuffer(64);
	if (!seq)
		VCR_WriteString("NULL");
	else
		VCR_WriteString(seq->name);
}

void OSequence::OnLoad()
{
	char *str;

	Super::OnLoad();
	seq = NULL;
	sName[0] = 0;
	str = VCR_ReadString();
	if (strcmp(str, "NULL"))
		strcpy(sName, str); // sName is ONLY used for resolution of seq when null at draw time, it is NOT always synced
}

/*
void OSequence::OnResize()
{
}
*/

void OSequence::OnCalcLogicalDim(int dx, int dy)
{
	Super::OnCalcLogicalDim(dx, dy);
	if (!seq)
		return;
	if (!seq->numItems)
		return;
	if (vpos.y > (seq->numItems*12+32-dim.y))
		vpos.y = (seq->numItems*12+32-dim.y);
	if (vpos.y < 0)
		vpos.y = 0;
	vmax.y = (float)(seq->numItems*12+18);
	vmin.y = 0;
}

void OSequence::OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox)
{
	int i, adjy;
	vector_t p[4];
	seqItem_t *item;
	seqTrigger_t *trig;
	char tbuffer[128];
	OWorkspace *ws;

	Super::OnDraw(sx, sy, dx, dy, clipbox);
	if (!seq)
	{
		ws = (OWorkspace *)this->parent;
		modelSequence_t *s;
		
		MRL_ITERATENEXT(s,s,ws->mdx->seqs)
		{
			if (!_stricmp(s->name, sName))
				seq = s;
		}
	}
	if (!seq)
		return;
	if (!seq->numItems)
		return;
	if (!OVL_ClipToBoxLimits(sx, sy, sx+dx, sy+dy, clipbox))
		return;
	adjy = (int)vpos.y;
	if (adjy < 0)
		adjy = 0;
	if (adjy > (seq->numItems)*12)
		adjy = (seq->numItems)*12;
	sprintf(tbuffer, "Rate: %.1f FPS", seq->framesPerSecond);
	vid->DepthEnable(FALSE);
	vid->DrawString(sx+2, sy+2-adjy, 8, 8, tbuffer, true, 128, 128, 128);
	vid->ColorMode(VCM_FLAT);
	vid->FlatColor(255,255,255);
	p[0].Seti(sx, sy-adjy+12, 0);
	p[1].Seti(sx+dx, sy-adjy+12, 0);
	vid->DrawLine(&p[0], &p[1], NULL, NULL);
	p[0].Seti(sx+192+1, sy-adjy, 0);
	p[1].Seti(sx+192+1, sy-adjy+12, 0);
	vid->DrawLine(&p[0], &p[1], NULL, NULL);
	vid->DrawString(sx+192-36-2, sy+5-adjy, 6, 6, "FRAMES", true, 128, 128, 128);
	vid->DrawString(sx+192+2, sy+5-adjy, 6, 6, "TRIGGERS", true, 128, 128, 128);
	for (i=1,item=seq->items.next;item!=&seq->items;i++,item=item->next)
	{
		if (item->flags & SEQITEMF_SELECTED)
		{
			p[0].Seti(sx, sy+i*12 - adjy, 0);
			p[2].Setf((float)(sx+192), p[0].y+12, 0);
			p[1].Setf(p[2].x, p[0].y, 0);
			p[3].Setf(p[0].x, p[2].y, 0);
			vid->ColorMode(VCM_FLAT);
			vid->FlatColor(0, 0, 128);
			vid->DrawPolygon(4, p, NULL, NULL, NULL);
		}
		strcpy(tbuffer, item->setFrame->name);
		tbuffer[31] = 0;
		vid->DrawString(sx+2, sy+i*12+2-adjy, 8, 8, tbuffer, true, 128, 128, 128);
		vid->ColorMode(VCM_FLAT);
		vid->FlatColor(255,255,255);
		p[0].Seti(sx, sy+i*12-adjy+12, 0);
		p[1].Seti(sx+192+1, sy+i*12-adjy+12, 0);
		vid->DrawLine(&p[0], &p[1], NULL, NULL);
		p[0].Seti(sx+192+1, sy+i*12-adjy, 0);
		p[1].Seti(sx+192+1, sy+i*12-adjy+12, 0);
		vid->DrawLine(&p[0], &p[1], NULL, NULL);
	}
	vid->DepthEnable(FALSE);
	for (trig=seq->triggers.prev;trig!=&seq->triggers;trig=trig->prev)
	{
		if (trig->triggerBinData)
			continue;
		int len;
		i = (int)(trig->trigTimeFrac*seq->numItems*12+12-adjy + 0.5f);
		len = fstrlen(trig->trigger);
		if (trig->flags & SEQITEMF_SELECTED)
		{
			p[0].Seti(sx+228,sy+i-4,0);
			p[2].Seti(sx+228+len*6+4,sy+i+4,0);
		}
		else
		{
			p[0].Seti(sx+200,sy+i-4,0);
			p[2].Seti(sx+200+len*6+4,sy+i+4,0);
		}
		p[1].Setf(p[2].x, p[0].y, 0);
		p[3].Setf(p[0].x, p[2].y, 0);
		vid->ColorMode(VCM_FLAT);
		if (trig->flags & SEQITEMF_SELECTED)
			vid->FlatColor(0,0,192);
		else
			vid->FlatColor(64, 64, 64);
		vid->DrawPolygon(4, p, NULL, NULL, NULL);
		if (trig->flags & SEQITEMF_SELECTED)
			vid->FlatColor(0,0,255);
		else
			vid->FlatColor(128,128,128);
		vid->DrawLineBox(&p[0], &p[2], NULL, NULL);
		p[2] = p[0];
		p[3] = p[1];
		p[3].x = p[2].x;
		p[3].y += 4;
		p[2].y += 4;
		p[2].x -= 20;
		if (trig->flags & SEQITEMF_SELECTED)
			p[2].x -= 28;
		vid->DrawLine(&p[2], &p[3], NULL, NULL);
		if (trig->flags & SEQITEMF_SELECTED)
		{
			vid->DrawString((int)(p[0].x+2),(int)(p[0].y+2), 6, 6, trig->trigger, true, 255, 255, 0);
			sprintf(tbuffer, "%1.3f", trig->trigTimeFrac);
			vid->DrawString((int)(p[0].x-33),(int)(p[0].y-2), 6, 6, tbuffer, true, 255, 255, 255);
		}
		else
			vid->DrawString((int)(p[0].x+2),(int)(p[0].y+2), 6, 6, trig->trigger, true, 128, 128, 128);
	}
	vid->DepthEnable(TRUE);
}

static int seq_trigDragY=-1; // can remain static since due to mouselock only one window could use at a time

U32 OSequence::OnPress(inputevent_t *event)
{
	int adjy;
	int i, k, selItemIndex;
	seqItem_t *item, *item2, *selItem=NULL;
	seqTrigger_t *trig, *trig2, *selTrig=NULL;
	vector_t p[2];

	if (!seq)
		return(Super::OnPress(event));
	adjy = (int)vpos.y;
	if (adjy < 0)
		adjy = 0;
	if (adjy > (seq->numItems)*12)
		adjy = (seq->numItems)*12;
	k = (event->mouseY+adjy)/12;
	k--;
	if (k < -1)
		return(1);
	if (k >= 0)
	{
		selTrig = NULL;
		for (i=0,item=seq->items.next,selItem=NULL;item!=&seq->items;i++,item=item->next)
		{
			if (item->flags & SEQITEMF_SELECTED)
			{
				selItem = item;
				selItemIndex = i;
			}
		}
		if (!selItem)
		{
			for (i=0,trig=seq->triggers.next;trig!=&seq->triggers;i++,trig=trig->next)
			{
				if (trig->triggerBinData)
					continue;
				if (trig->flags & SEQITEMF_SELECTED)
				{
					selTrig = trig;
					selItemIndex = i;
				}
			}
		}
	}

	switch(event->key)
	{
	case KEY_MOUSELEFT:
		OVL_LockInput(this);
		if (k >= 0)
		{
			if (event->mouseX < 192)
			{
				for (i=0,item=seq->items.next,selItem=NULL;(i!=k)&&(item!=&seq->items);i++,item=item->next)
					;
				if (item==&seq->items)
					return(1);
				selItem = item;
				for (item2=seq->items.next;item2!=&seq->items;item2=item2->next)
					item2->flags &= ~(SEQITEMF_SELECTED);//|SEQITEMF_TIMEMODE|SEQITEMF_TRIGGERMODE);
				for (trig=seq->triggers.next;trig!=&seq->triggers;trig=trig->next)
					trig->flags &= ~SEQITEMF_SELECTED;
				item->flags |= SEQITEMF_SELECTED;
		//		if (event->mouseX > 256+32+2)
		//			item->flags |= SEQITEMF_TRIGGERMODE;
		//		else
		//		if (event->mouseX > 256+2)
		//			item->flags |= SEQITEMF_TIMEMODE;
			}
			else
			{
				for (trig=seq->triggers.next;trig!=&seq->triggers;trig=trig->next)
				{
					if (trig->triggerBinData)
						continue;
					int len;
					i = (int)(trig->trigTimeFrac*seq->numItems*12+12-adjy + 0.5f);
					len = fstrlen(trig->trigger);
					if (trig->flags & SEQITEMF_SELECTED)
					{
						p[0].Seti(228,i-4,0);
						p[1].Seti(228+len*6+4,i+4,0);
					}
					else
					{
						p[0].Seti(200,i-4,0);
						p[1].Seti(200+len*6+4,i+4,0);
					}
					if ((event->mouseX >= p[0].x) && (event->mouseX <= p[1].x)
					 && (event->mouseY >= p[0].y) && (event->mouseY <= p[1].y))
					{
						for (item2=seq->items.next;item2!=&seq->items;item2=item2->next)
							item2->flags &= ~(SEQITEMF_SELECTED);//|SEQITEMF_TIMEMODE|SEQITEMF_TRIGGERMODE);
						for (trig2=seq->triggers.next;trig2!=&seq->triggers;trig2=trig2->next)
							trig2->flags &= ~SEQITEMF_SELECTED;
						trig->flags |= SEQITEMF_SELECTED;
						// move new selected trigger to top of list
						trig->next->prev = trig->prev;
						trig->prev->next = trig->next;
						trig->next = seq->triggers.next;
						trig->prev = &seq->triggers;
						trig->prev->next = trig;
						trig->next->prev = trig;
						seq_trigDragY = event->mouseY;
						break;
					}
				}
			}
		}
		else
		{
			if (event->mouseX < 128)
			{
				if (!(event->flags & (KF_ALT|KF_SHIFT)))
				{
					OVL_SendPressCommand(this, "seqrate");
				}
			}
		}
		return(1);
		break;
	case KEY_INS:
		trig = seq->AddTrigger();
		if (selItem)
			trig->trigTimeFrac = ((float)selItemIndex / (float)seq->numItems) + (0.5f / (float)seq->numItems);
		return(1);
		break;
	case KEY_DEL:
		if (selItem)
			seq->DeleteItem(selItem);
		else if (selTrig)
			seq->DeleteTrigger(selTrig);
		return(1);
		break;
	case KEY_ENTER:
		if (selTrig)
			OVL_SendPressCommand(this, "triggername %d", selItemIndex);
//		if (selItem->flags & SEQITEMF_TIMEMODE)
//			OVL_SendPressCommand(this, "itemtime %d", selItemIndex);
//		else
//		if (selItem->flags & SEQITEMF_TRIGGERMODE)
//			OVL_SendPressCommand(this, "itemtrigger %d", selItemIndex);
		return(1);
        break;
    case KEY_SPACE:
        OVL_SendPressCommand(this, "addframes");
        return(1);
		break;
/*
	case KEY_TAB:
		if (!selItem)
			return(1);
		if (selItem->flags & SEQITEMF_TIMEMODE)
		{
			selItem->flags &= ~SEQITEMF_TIMEMODE;
			selItem->flags |= SEQITEMF_TRIGGERMODE;
		}
		else
		if (selItem->flags & SEQITEMF_TRIGGERMODE)
		{
			selItem->flags &= ~SEQITEMF_TRIGGERMODE;
		}
		else
			selItem->flags |= SEQITEMF_TIMEMODE;
		return(1);
		break;
*/
	case KEY_UPARROW:
		if (!selItem)
			return(1);
		if ((event->flags & KF_CONTROL) && (!(event->flags & (KF_ALT|KF_SHIFT))))
		{
			OVL_SendPressCommand(this, "itemmoveup %d", selItemIndex);
			return(1);
		}
		else
		if (!(event->flags & (KF_ALT|KF_SHIFT)))
		{
			if (selItem->prev != &seq->items)
			{
				selItem->flags &= ~(SEQITEMF_SELECTED);//|SEQITEMF_TIMEMODE|SEQITEMF_TRIGGERMODE);
				selItem->prev->flags |= SEQITEMF_SELECTED;
			}
			return(1);
		}
		break;
	case KEY_DOWNARROW:
		if (!selItem)
			return(1);
		if ((event->flags & KF_CONTROL) && (!(event->flags & (KF_ALT|KF_SHIFT))))
		{
			OVL_SendPressCommand(this, "itemmovedown %d", selItemIndex);
			return(1);
		}
		else
		if (!(event->flags & (KF_ALT|KF_SHIFT)))
		{
			if (selItem->next != &seq->items)
			{
				selItem->flags &= ~(SEQITEMF_SELECTED);//|SEQITEMF_TIMEMODE|SEQITEMF_TRIGGERMODE);
				selItem->next->flags |= SEQITEMF_SELECTED;
			}
			return(1);
		}
		break;
	default:
		break;
	}
	return(Super::OnPress(event));
}

U32 OSequence::OnDrag(inputevent_t *event)
{
	seqTrigger_t *trig;

	if (seq_trigDragY == -1)
		return(Super::OnDrag(event));
	for (trig=seq->triggers.next;trig!=&seq->triggers;trig=trig->next)
	{
		if (trig->triggerBinData)
			continue;
		if (trig->flags & SEQITEMF_SELECTED)
			break;
	}
	if (trig == &seq->triggers)
		return(1);
	int diffy = event->mouseY - seq_trigDragY;
	trig->trigTimeFrac += (float)diffy / (12.0f*seq->numItems);
	if (trig->trigTimeFrac < 0.0)
		trig->trigTimeFrac = 0.0;
	if (trig->trigTimeFrac > 1.0)
		trig->trigTimeFrac = 1.0;
	seq_trigDragY = event->mouseY;
	return(1);
}

U32 OSequence::OnRelease(inputevent_t *event)
{
	OVL_UnlockInput(this);
	seq_trigDragY = -1;
	return(Super::OnRelease(event));
}

U32 OSequence::OnPressCommand(int argNum, CC8 **argList)
{
	OVLCMDSTART
	OVLCMD("seqrate")
	{
		char tbuffer[32];
		float val;
		if (argNum < 2)
		{
			sprintf(tbuffer, "%.1f", seq->framesPerSecond);
			OVL_InputBox("Animation Rate", "Enter the rate of this sequence in frames per second", this, "seqrate", tbuffer);
			return(1);
		}
		val = (float)atof(argList[1]);
		if (val > 0.0)
			seq->framesPerSecond = val;
		return(1);
	}
	OVLCMD("triggername")
	{
		int i, k;
		seqTrigger_t *trig;
		char tbuffer[32];
		if (argNum < 2)
			return(1);
		k = atoi(argList[1]);
		for (i=0,trig=seq->triggers.next;(i!=k)&&(trig!=&seq->triggers);i++,trig=trig->next)
		{
			if (trig->triggerBinData)
				i--;
			continue;
		}
		if (trig==&seq->triggers)
			return(1);
		if (argNum < 3)
		{
			sprintf(tbuffer, "triggername %d", k);
			OVL_InputBox("Trigger Function", "Enter the name of the function for this trigger", this, tbuffer, trig->trigger);
			return(1);
		}
		if (trig->trigger)
			FREE(trig->trigger);
		trig->trigger=null;
		trig->trigger = ALLOC(char, fstrlen(argList[2])+1);
		strcpy(trig->trigger, argList[2]);
		return(1);
	}
	OVLCMD("itemtime")
	{
		int i, k;
		seqItem_t *item;
//		char tbuffer[32], tbuf2[16];
		if (argNum < 2)
			return(1);
		k = atoi(argList[1]);
		for (i=0,item=seq->items.next;(i!=k)&&(item!=&seq->items);i++,item=item->next)
			;
		if (item==&seq->items)
			return(1);
		if (argNum < 3)
		{
//			sprintf(tbuffer, "itemtime %d", k);
//			sprintf(tbuf2, "%d", item->duration);
//			OVL_InputBox("Time Duration", "Enter the time delay for this frame in milliseconds", this, tbuffer, tbuf2);
			return(1);
		}
//		item->duration = atoi(argList[2]);
		return(1);
	}
	OVLCMD("itemtrigger")
	{
		int i, k;
		seqItem_t *item;
//		char tbuffer[32];
		if (argNum < 2)
			return(1);
		k = atoi(argList[1]);
		for (i=0,item=seq->items.next;(i!=k)&&(item!=&seq->items);i++,item=item->next)
			;
		if (item==&seq->items)
			return(1);
		if (argNum < 3)
		{
			return(1);
		}
		return(1);
	}
	OVLCMD("itemmoveup")
	{
		int i, k;
		seqItem_t *item, *prev;
		if (argNum < 2)
			return(1);
		k = atoi(argList[1]);
		for (i=0,item=seq->items.next;(i!=k)&&(item!=&seq->items);i++,item=item->next)
			;
		if (item==&seq->items)
			return(1);
		if (item->prev != &seq->items)
		{
			prev = item->prev;
			item->prev->next = item->next;
			item->next->prev = item->prev;
			item->next = prev;
			item->prev = prev->prev;
			item->next->prev = item;
			item->prev->next = item;
		}
		return(1);
	}
	OVLCMD("itemmovedown")
	{
		int i, k;
		seqItem_t *item, *next;
		if (argNum < 2)
			return(1);
		k = atoi(argList[1]);
		for (i=0,item=seq->items.next;(i!=k)&&(item!=&seq->items);i++,item=item->next)
			;
		if (item==&seq->items)
			return(1);
		if (item->next != &seq->items)
		{
			next = item->next;
			item->prev->next = item->next;
			item->next->prev = item->prev;
			item->next = next->next;
			item->prev = next;
			item->next->prev = item;
			item->prev->next = item;
		}
		return(1);
	}
    OVLCMD("addframes")
    {
        static char buffer[65000];
        OWorkspace *ws = (OWorkspace *)this->parent;
	    modelFrame_t* f;
        int len = 0;
		modelSequence_t *s = ws->GetTopmostSequence();
		if (!s)
			return(1);
        MRL_ITERATENEXT(f,f,ws->mdx->frames)
        {
            strcpy(buffer+len, f->name);
            len += fstrlen(f->name)+1;
        }
        OVL_SelectionBox("Add Frames", buffer, this, "addframes_item", 1);
        return(1);
    }
    OVLCMD("addframes_item")
    {
        if (argNum < 2)
            return(1);
        OWorkspace *ws = (OWorkspace *)this->parent;
		modelSequence_t *s = ws->GetTopmostSequence();
		if (!s)
			return(1);
        modelFrame_t* f, *f2=NULL;
        MRL_ITERATENEXT(f,f,ws->mdx->frames)
        {
    		if (!_stricmp(f->name, argList[1]))
	    		f2 = f;
        }
        if (f2)
            s->AddItem(f2);        
        return(1);
    }
	return(Super::OnPressCommand(argNum, argList));
}

/*
U32 OSequence::OnDragCommand(int argNum, CC8 **argList)
{
}
*/

/*
U32 OSequence::OnReleaseCommand(int argNum, CC8 **argList)
{
}
*/

/*
U32 OSequence::OnMessage(ovlmsg_t *msg)
{
}
*/

//****************************************************************************
//**
//**    END MODULE OVL_SEQ.CPP
//**
//****************************************************************************

