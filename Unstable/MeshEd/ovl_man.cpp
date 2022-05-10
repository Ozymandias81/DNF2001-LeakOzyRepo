//****************************************************************************
//**
//**    OVL_MAN.CPP
//**    Overlay Management
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include "stdtool.h"
//----------------------------------------------------------------------------
//    Private Definitions
//----------------------------------------------------------------------------
#define OVL_MINWINDOWSIZEX	48
#define OVL_MINWINDOWSIZEY	20
//----------------------------------------------------------------------------
//    Private Structures
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Additional External References
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Data
//----------------------------------------------------------------------------
static COvlTypeDecl *ovl_OvlTypeDecls = NULL;
overlay_t *ovl_Windows = NULL;

//----------------------------------------------------------------------------
//    Public Data
//----------------------------------------------------------------------------
overlay_t overlay_t_ovlprototype(NULL);
overlay_t *ovl_lockOverlay = NULL, *ovl_focusOverlay = NULL;

//----------------------------------------------------------------------------
//    Private Code Prototypes
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Code
//----------------------------------------------------------------------------
CONFUNC(CreateWindow, NULL, 0)
{
	overlay_t *ovl;
	int px, py, dx, dy;

	if (argNum < 7)
	{
		CON->Printf("[?] CreateWindow OType name px py dx dy [xtracfg.cfg]");
		return;
	}
	px = atoi(argList[3]);
	py = atoi(argList[4]);
	dx = atoi(argList[5]);
	dy = atoi(argList[6]);
	if (dx < 48)
		dx = 48;
	if (dy < 20)
		dy = 20;
	if (!strcmp(argList[2], "?"))
	{
		char *str;
		if (!(str = SYS_InputBox("Window Name", "UnnamedWindow", "What would you like to name this window?")))
			return;
		ovl = OVL_CreateOverlay(argList[1], str, NULL, px, py, dx, dy, 0, true);
	}
	else
		ovl = OVL_CreateOverlay(argList[1], argList[2], NULL, px, py, dx, dy, 0, true);
	if (argNum > 7)
		CON->ExecuteFile(ovl, argList[7], true);
}

static void OVL_RecursiveDrawOverlay(overlay_t *ovl, int x, int y, int limdx, int limdy, ovlClipBox_t *clip)
{	
	vector_t p[4], c[4];
	int px, py, dx, dy;//, mx, my;
	vector_t relpos;
	overlay_t *child;//, *drchild;
	U32 redraw;

	if (!OVL_ClipToBoxLimits(x, y, x+limdx, y+limdy, clip))
		return;
	
	relpos = ovl->pos;
	if ((ovl->parent) && (!(ovl->flags & OVLF_VIEWABSOLUTE)))
		relpos -= ovl->parent->vpos;
	
	px = (int)(x + relpos.x);
	py = (int)(y + relpos.y);
	dx = (int)ovl->dim.x;
	dy = (int)ovl->dim.y;
	if (ovl->flags & OVLF_MINIMIZED)
		dy = 12+3+3; // title

	redraw = 1;
	
	if (ovl->flags & OVLF_REDRAW)
	{
		ovl->flags &= ~OVLF_REDRAW;
		ovl->flags |= OVLF_REDRAWSWAP;
	}
	else if (ovl->flags & OVLF_REDRAWSWAP)
	{
		ovl->flags &= ~OVLF_REDRAWSWAP;
	}

	if ((redraw) && (!(ovl->flags & OVLF_NODRAW)))
	{
		if (!(ovl->flags & OVLF_NOBORDER))
		{			
			vid->DepthEnable(FALSE);
			vid->ColorMode(VCM_GOURAUD);
			p[0].Seti(px, py, 0);
			p[1].Seti(px+dx-1, py+dy-1, 0);
			c[0].Seti(128, 128, 128);
			c[1].Seti(48, 48, 48);
			vid->DrawLineBox(&p[0], &p[1], &c[0], &c[1]);
			p[0].x += 1; p[0].y += 1; p[1].x -= 1; p[1].y -= 1;
			c[0].Seti(255, 255, 255);
			c[1].Seti(255, 255, 255);
			vid->DrawLineBox(&p[0], &p[1], &c[0], &c[1]);
			p[0].x += 1; p[0].y += 1; p[1].x -= 1; p[1].y -= 1;
			c[0].Seti(48, 48, 48);
			c[1].Seti(128, 128, 128);
			vid->DrawLineBox(&p[0], &p[1], &c[0], &c[1]);
			
			px += 3; py += 3;
			dx -= 6; dy -= 6;
		}
		if (!(ovl->flags & OVLF_NOTITLE))
		{			
			vid->DepthEnable(FALSE);
			vid->ColorMode(VCM_GOURAUD);
			p[0].Seti(px-1, py+10, 0);
			p[1].Seti(px+dx+1, py+10, 0);			
			c[0].Seti(192, 192, 192);
			c[1].Seti(192, 192, 192);
			vid->DrawLine(&p[0], &p[1], &c[0], &c[1]);
			p[0].y += 1; p[1].y += 1;
			c[0].Seti(255, 255, 255);
			c[1].Seti(255, 255, 255);
			vid->DrawLine(&p[0], &p[1], &c[0], &c[1]);
			p[0].y += 1; p[1].y += 1;
			c[0].Seti(64, 64, 64);
			c[1].Seti(64, 64, 64);
			vid->DrawLine(&p[0], &p[1], &c[0], &c[1]);
			
			//if (OVL_ClipToBoxLimits(px, py, px+dx, py+9, clip))
			if (OVL_ClipToBoxLimits(px, py, px+dx, py+10, clip))
			{
				vid->DepthEnable(TRUE);
				vid->ClearScreen();
				vid->DepthEnable(FALSE);
				if ((!ovl->parent) || (ovl == ovl->parent->children->next))
				{
					p[0].Seti(px, py, 0);
					p[1].Seti(px+dx, py, 0);
					p[2].Seti(px+dx, py+10, 0);
					p[3].Seti(px, py+10, 0);			
					c[0].Seti(0, 0, 96);
					c[1].Seti(32, 0, 96);
					c[2].Seti(64, 0, 192);
					c[3].Seti(32, 0, 96);
					vid->ColorMode(VCM_GOURAUD);
					vid->DrawClippedPolygon(4, p, c, NULL, NULL);
				}
				if (ovl == ovl_focusOverlay)
				{
					p[0].Seti(px, py, 0);
					p[1].Seti(px+dx, py, 0);
					p[2].Seti(px+dx, py+10, 0);
					p[3].Seti(px, py+10, 0);			
					c[0].Seti(64, 0, 64);
					c[1].Seti(96, 0, 96);
					c[2].Seti(192, 0, 192);
					c[3].Seti(96, 0, 96);
					vid->ColorMode(VCM_GOURAUD);
					vid->DrawClippedPolygon(4, p, c, NULL, NULL);
				}
				
				int len = 0;
				if (!(ovl->flags & OVLF_NOTITLEDESTROY))
					len += 10;
				if (!(ovl->flags & OVLF_NOTITLEMINMAX))
					len += 20;
				int tsize = (dx-len) / fstrlen(ovl->name);
				if (tsize > 8)
					tsize = 8;
				vid->DrawString(px, py+1, tsize, tsize, ovl->name, true, 128, 128, 128);

				if (!(ovl->flags & OVLF_NOTITLEDESTROY))
				{
					p[0].Seti(px+dx-9, py, 0);
					p[1].Seti(px+dx-1, py+8, 0);
					c[0].Seti(255, 255, 255);
					c[1].Seti(255, 255, 255);
					vid->DrawLineBox(&p[0], &p[1], &c[0], &c[1]);
					vid->DrawString(px+dx-9, py+1, 8, 8, "X", true, 128, 128, 128);
				}
				
				if (!(ovl->flags & OVLF_NOTITLEMINMAX))
				{
					if (ovl->flags & OVLF_MINIMIZED)
					{
						p[0].Seti(px+dx-19, py, 0);
						p[1].Seti(px+dx-10, py+8, 0);
						c[0].Seti(255, 255, 255);
						c[1].Seti(255, 255, 255);
						vid->DrawLineBox(&p[0], &p[1], &c[0], &c[1]);
						vid->DrawString(px+dx-19, py+1, 8, 8, "+", true, 128, 128, 128);
						p[0].Seti(px+dx-29, py, 0);
						p[1].Seti(px+dx-20, py+8, 0);
						c[0].Seti(255, 255, 255);
						c[1].Seti(255, 255, 255);
						vid->DrawLineBox(&p[0], &p[1], &c[0], &c[1]);
						vid->DrawString(px+dx-29, py+1, 8, 8, "/", true, 128, 128, 128);
					}
					else if (ovl->flags & OVLF_MAXIMIZED)
					{
						p[0].Seti(px+dx-19, py, 0);
						p[1].Seti(px+dx-10, py+8, 0);
						c[0].Seti(255, 255, 255);
						c[1].Seti(255, 255, 255);
						vid->DrawLineBox(&p[0], &p[1], &c[0], &c[1]);
						vid->DrawString(px+dx-19, py+1, 8, 8, "/", true, 128, 128, 128);
						p[0].Seti(px+dx-29, py, 0);
						p[1].Seti(px+dx-20, py+8, 0);
						c[0].Seti(255, 255, 255);
						c[1].Seti(255, 255, 255);
						vid->DrawLineBox(&p[0], &p[1], &c[0], &c[1]);
						vid->DrawString(px+dx-29, py+1, 8, 8, "-", true, 128, 128, 128);
					}
					else
					{
						p[0].Seti(px+dx-19, py, 0);
						p[1].Seti(px+dx-10, py+8, 0);
						c[0].Seti(255, 255, 255);
						c[1].Seti(255, 255, 255);
						vid->DrawLineBox(&p[0], &p[1], &c[0], &c[1]);
						vid->DrawString(px+dx-19, py+1, 8, 8, "+", true, 128, 128, 128);
						p[0].Seti(px+dx-29, py, 0);
						p[1].Seti(px+dx-20, py+8, 0);
						c[0].Seti(255, 255, 255);
						c[1].Seti(255, 255, 255);
						vid->DrawLineBox(&p[0], &p[1], &c[0], &c[1]);
						vid->DrawString(px+dx-29, py+1, 8, 8, "-", true, 128, 128, 128);
					}
				}
				
				OVL_ClipToBoxLimits(x, y, x+limdx, y+limdy, clip);
			}
			py += 12;
			dy -= 12;
		}
	}
	else
	{
		if (!(ovl->flags & OVLF_NOBORDER))
		{			
			px += 3; py += 3;
			dx -= 6; dy -= 6;
		}
		if (!(ovl->flags & OVLF_NOTITLE))
		{
			py += 12;
			dy -= 12;
		}
	}
	ovl->OnCalcLogicalDim(dx, dy);
	if ((ovl->vmin.x < ovl->vpos.x) || (ovl->vmax.x > (ovl->vpos.x+dx)))
		ovl->flags |= OVLF_HSCROLL;
	else
		ovl->flags &= ~OVLF_HSCROLL;
	if ((ovl->vmin.y < ovl->vpos.y) || (ovl->vmax.y > (ovl->vpos.y+dy)))
		ovl->flags |= OVLF_VSCROLL;
	else
		ovl->flags &= ~OVLF_VSCROLL;
	
	vid->DepthEnable(TRUE);

	if ((redraw) && (!(ovl->flags & (OVLF_NODRAW|OVLF_MINIMIZED))))
	{
		vid->DepthEnable(FALSE);
		if (ovl->flags & OVLF_HSCROLL)
		{
			float frac;
			int ss, se;
			
			if (OVL_ClipToBoxLimits(px, py+dy-11, px+dx, py+dy, clip))
			{
				int hx, lx;
				vid->DepthEnable(TRUE);
				vid->ClearScreen();
				vid->DepthEnable(FALSE);
				vid->ColorMode(VCM_GOURAUD);
				p[0].Seti(px-1, py+dy-10, 0);
				p[1].Seti(px+dx+1, py+dy-10, 0);			
				c[0].Seti(192, 192, 192);
				c[1].Seti(192, 192, 192);
				vid->DrawLine(&p[0], &p[1], &c[0], &c[1]);
				p[0].y += 1; p[1].y += 1;
				c[0].Seti(255, 255, 255);
				c[1].Seti(255, 255, 255);
				vid->DrawLine(&p[0], &p[1], &c[0], &c[1]);
				p[0].y += 1; p[1].y += 1;
				c[0].Seti(64, 64, 64);
				c[1].Seti(64, 64, 64);
				vid->DrawLine(&p[0], &p[1], &c[0], &c[1]);
				p[0].y += 4; p[1].y += 4;
				c[0].Seti(128, 128, 128);
				c[1].Seti(128, 128, 128);
				vid->DrawLine(&p[0], &p[1], &c[0], &c[1]);
				lx = (int)(ovl->vmin.x);
				hx = (int)(ovl->vmax.x);
				if (ovl->vpos.x < lx)
					lx = (int)(ovl->vpos.x);
				if ((ovl->vpos.x + dx) > hx)
					hx = (int)(ovl->vpos.x + dx);
				frac = (float)dx / (float)(hx - lx);
				ss = (int)(px + (ovl->vpos.x - lx) * frac);
				se = (int)(ss + dx * frac);
				p[0].Seti(ss, py+dy-7, 0);
				p[1].Seti(se+1, py+dy-7, 0);
				p[2].Seti(se+1, py+dy-1, 0);
				p[3].Seti(ss, py+dy-1, 0);
				vid->ColorMode(VCM_FLAT);
				vid->FlatColor(192, 192, 192);
				vid->DrawPolygon(4, p, NULL, NULL, NULL);

				OVL_ClipToBoxLimits(x, y, x+limdx, y+limdy, clip);
			}
			dy -= 11;
		}
		if (ovl->flags & OVLF_VSCROLL)
		{
			float frac;
			int ss, se;

			if (OVL_ClipToBoxLimits(px+dx-11, py, px+dx, py+dy, clip))
			{
				int hy, ly;

				vid->DepthEnable(TRUE);
				vid->ClearScreen();
				vid->DepthEnable(FALSE);
				vid->ColorMode(VCM_GOURAUD);
				p[0].Seti(px+dx-10, py-1, 0);
				p[1].Seti(px+dx-10, py+dy+1, 0);
				c[0].Seti(192, 192, 192);
				c[1].Seti(192, 192, 192);
				vid->DrawLine(&p[0], &p[1], &c[0], &c[1]);
				p[0].x += 1; p[1].x += 1;
				c[0].Seti(255, 255, 255);
				c[1].Seti(255, 255, 255);
				vid->DrawLine(&p[0], &p[1], &c[0], &c[1]);
				p[0].x += 1; p[1].x += 1;
				c[0].Seti(64, 64, 64);
				c[1].Seti(64, 64, 64);
				vid->DrawLine(&p[0], &p[1], &c[0], &c[1]);
				p[0].x += 4; p[1].x += 4;
				c[0].Seti(128, 128, 128); c[1].Seti(128, 128, 128);
				vid->DrawLine(&p[0], &p[1], &c[0], &c[1]);
				ly = (int)ovl->vmin.y;
				hy = (int)ovl->vmax.y;
				if (ovl->vpos.y < ly)
					ly = (int)ovl->vpos.y;
				if ((ovl->vpos.y + dy) > hy)
					hy = (int)(ovl->vpos.y + dy);
				frac = (float)dy / (float)(hy - ly);
				ss = (int)(py + (ovl->vpos.y - ly) * frac);
				se = (int)(ss + dy * frac);
				p[0].Seti(px+dx-7, ss, 0);
				p[1].Seti(px+dx-1, ss, 0);
				p[2].Seti(px+dx-1, se+1, 0);
				p[3].Seti(px+dx-7, se+1, 0);
				vid->ColorMode(VCM_FLAT);
				vid->FlatColor(192, 192, 192);
				vid->DrawPolygon(4, p, NULL, NULL, NULL);

				OVL_ClipToBoxLimits(x, y, x+limdx, y+limdy, clip);
			}
			dx -= 11;
		}
		if (!(ovl->flags & OVLF_NOERASECOLOR & OVLF_NOERASEDEPTH))
		{
			if (OVL_ClipToBoxLimits(px, py, px+dx, py+dy, clip))
			{
				vid->DepthEnable(TRUE);
				if (ovl->flags & OVLF_NOERASECOLOR)
					vid->ColorWrite(false);
				if (ovl->flags & OVLF_NOERASEDEPTH)
					vid->DepthWrite(false);
				vid->ClearScreen();
				if (ovl->flags & OVLF_NOERASECOLOR)
					vid->ColorWrite(true);
				if (ovl->flags & OVLF_NOERASEDEPTH)
					vid->DepthWrite(true);
				OVL_ClipToBoxLimits(x, y, x+limdx, y+limdy, clip);
			}
		}
		vid->DepthEnable(TRUE);
		// call the ondraw method for the overlay
		ovl->OnDraw(px, py, dx, dy, clip);
	}

	// now draw child overlays
	if ((!ovl->children) || (ovl->flags & OVLF_MINIMIZED))
		return;
	ovlClipBox_t kidclip;
	for (child = ovl->children->next; child != ovl->children; child = child->next)
		child->flags &= ~OVLF_TOUCH;
	for (child = ovl->children->prev; child != ovl->children; child = child->prev)
	{ // draw normal children first
		if (child->flags & OVLF_ALWAYSTOP)
			continue;
		child->flags |= OVLF_TOUCH;
		relpos = child->pos;
		if (!(child->flags & OVLF_VIEWABSOLUTE))
			relpos -= ovl->vpos;
		// if the child is not within the logical window, skip it
		if ((relpos.x >= dx) || (relpos.y >= dy))
			continue;
		if ((relpos.x + child->dim.x < 0) || (relpos.y + child->dim.y < 0))
			continue;
		// set up the child clipping extremes
		kidclip.sx = px; kidclip.sy = py; kidclip.ex = px+dx, kidclip.ey = py+dy;
		if (kidclip.sx < clip->sx)
			kidclip.sx = clip->sx;
		if (kidclip.sy < clip->sy)
			kidclip.sy = clip->sy;
		if (kidclip.ex > clip->ex)
			kidclip.ex = clip->ex;
		if (kidclip.ey > clip->ey)
			kidclip.ey = clip->ey;
		if (kidclip.sx < 0) kidclip.sx = 0;
		if (kidclip.sy < 0) kidclip.sy = 0;
		if (kidclip.ex > (I32)vid->res.width) kidclip.ex = vid->res.width;
		if (kidclip.ey > (I32)vid->res.height) kidclip.ey = vid->res.height;
		// if the child isn't within the clipping extremes, skip it
		if ((px+relpos.x >= kidclip.ex) || (py+relpos.y >= kidclip.ey))
			continue;
		if ((px+relpos.x+child->dim.x <= kidclip.sx) || (py+relpos.y+child->dim.y <= kidclip.sy))
			continue;
		// go for it
		OVL_RecursiveDrawOverlay(child, px, py, dx, dy, &kidclip);
	}
	for (child = ovl->children->prev; child != ovl->children; child = child->prev)
	{ // now draw topmost-flagged children
		if (child->flags & OVLF_TOUCH)
		{
			child->flags &= ~OVLF_TOUCH;
			continue;
		}
		child->flags &= ~OVLF_TOUCH;
		relpos = child->pos;
		if (!(child->flags & OVLF_VIEWABSOLUTE))
			relpos -= ovl->vpos;	
		// if the child is not within the logical window, skip it
		if ((relpos.x >= dx) || (relpos.y >= dy))
			continue;
		if ((relpos.x + child->dim.x < 0) || (relpos.y + child->dim.y < 0))
			continue;
		// set up the child clipping extremes
		kidclip.sx = px; kidclip.sy = py; kidclip.ex = px+dx, kidclip.ey = py+dy;
		if (kidclip.sx < clip->sx)
			kidclip.sx = clip->sx;
		if (kidclip.sy < clip->sy)
			kidclip.sy = clip->sy;
		if (kidclip.ex > clip->ex)
			kidclip.ex = clip->ex;
		if (kidclip.ey > clip->ey)
			kidclip.ey = clip->ey;
		if (kidclip.sx < 0) kidclip.sx = 0;
		if (kidclip.sy < 0) kidclip.sy = 0;
		if (kidclip.ex > (I32)vid->res.width) kidclip.ex = vid->res.width;
		if (kidclip.ey > (I32)vid->res.height) kidclip.ey = vid->res.height;
		// if the child isn't within the clipping extremes, skip it
		if ((px+relpos.x >= kidclip.ex) || (py+relpos.y >= kidclip.ey))
			continue;
		if ((px+relpos.x+child->dim.x <= kidclip.sx) || (py+relpos.y+child->dim.y <= kidclip.sy))
			continue;
		// go for it
		OVL_RecursiveDrawOverlay(child, px, py, dx, dy, &kidclip);
	}
}

static ovlInputRegion_t OVL_FindInputRegion(overlay_t *ovl, int px, int py)
{
	if (ovl->flags & OVLF_NOINPUT)
		return(OVLREGION_NONE);

	if ((px < 0) || (py < 0) || (px > ovl->dim.x))
		return(OVLREGION_NONE); // out of range
	if (ovl->flags & OVLF_MINIMIZED)
	{
		if (py > 12+3+3)
			return(OVLREGION_NONE);
	}
	else
	{
		if (py > ovl->dim.y)
			return(OVLREGION_NONE);
	}

	if (!(ovl->flags & OVLF_NOBORDER))
	{
		if (px < 3)
		{ // left side
			if (py < 3)
				return(OVLREGION_BULCORNER);
			if (py > ovl->dim.y-3)
				return(OVLREGION_BLLCORNER);
			else
				return(OVLREGION_BLEFT);
		}
		else
		if (px > ovl->dim.x-3)
		{ // right side
			if (py < 3)
				return(OVLREGION_BURCORNER);
			if (py > ovl->dim.y-3)
				return(OVLREGION_BLRCORNER);
			else
				return(OVLREGION_BRIGHT);
		}
		else
		if (py < 3)
			return(OVLREGION_BTOP);
		else
		if (py > ovl->dim.y-3)
			return(OVLREGION_BBOTTOM);
	}
	if (!(ovl->flags & OVLF_NOTITLE))
	{
		if (py < 13)
		{
			if ((!(ovl->flags & OVLF_NOTITLEDESTROY)) && (px > ovl->dim.x-12))
				return(OVLREGION_TDESTROY);
			if (!(ovl->flags & OVLF_NOTITLEMINMAX))
			{
				if (ovl->flags & OVLF_MINIMIZED)
				{
					if ((px > ovl->dim.x-23) && (px <= ovl->dim.x-12))
						return(OVLREGION_TMAXIMIZE);
					else
					if ((px > ovl->dim.x-33) && (px <= ovl->dim.x-23))
						return(OVLREGION_TRESTORE);
				}
				else
				if (ovl->flags & OVLF_MAXIMIZED)
				{
					if ((px > ovl->dim.x-23) && (px <= ovl->dim.x-12))
						return(OVLREGION_TRESTORE);
					else
					if ((px > ovl->dim.x-33) && (px <= ovl->dim.x-23))
						return(OVLREGION_TMINIMIZE);
				}
				else
				{
					if ((px > ovl->dim.x-23) && (px <= ovl->dim.x-12))
						return(OVLREGION_TMAXIMIZE);
					else
					if ((px > ovl->dim.x-33) && (px <= ovl->dim.x-23))
						return(OVLREGION_TMINIMIZE);
				}

			}
			return(OVLREGION_TITLE);
		}
	}
	if (ovl->flags & OVLF_MINIMIZED)
		return(OVLREGION_NONE);
	if (ovl->flags & OVLF_HSCROLL)
	{
		if (py > ovl->dim.y-10)
			return(OVLREGION_HSCROLL);
	}
	if (ovl->flags & OVLF_VSCROLL)
	{
		if (px > ovl->dim.x-10)
			return(OVLREGION_VSCROLL);
	}
	return(OVLREGION_BODY);
}

static U32 OVL_ResizeLimits(overlay_t *ovl)
{
	if ((ovl->dim.x < OVL_MINWINDOWSIZEX) || (ovl->dim.y < OVL_MINWINDOWSIZEY))
	{
		if (ovl->dim.x < OVL_MINWINDOWSIZEX) ovl->dim.x = OVL_MINWINDOWSIZEX;
		if (ovl->dim.y < OVL_MINWINDOWSIZEY) ovl->dim.y = OVL_MINWINDOWSIZEY;
		return(1);
	}
	return(0);
}

static void OVL_ResizeCheckProportional(overlay_t *ovl)
{
	float xp, yp;

	if (!(ovl->flags & OVLF_PROPORTIONAL))
		return;
	xp = ovl->dim.y / ovl->proportionRatio;
	yp = ovl->dim.x * ovl->proportionRatio;
	// alter the one that's closer to fitting the ratio
	if (fabs(xp - ovl->dim.x) < fabs(yp - ovl->dim.y))
		ovl->dim.x = xp;
	else
		ovl->dim.y = yp;

}

static char *OVL_GetDerivedBinding(overlay_t *ovl, int key, int flags)
{
	if (!ovl)
		return(NULL);
	COvlTypeDecl *odecl = ovl->typedecl;
	while (odecl)
	{
		if (odecl->bindconfig.keyBindings[key][flags][0])
			return(odecl->bindconfig.keyBindings[key][flags]);
		if (odecl->ovlPrototypeBase)
			odecl = odecl->ovlPrototypeBase->typedecl;
		else
			odecl = NULL;
	}
	return(NULL);
}

static U32 OVL_RecursiveInputEvent(overlay_t *ovl, inputevent_t *event)
{
	int px, py, dx, dy;
	ovlInputRegion_t region;
	overlay_t *child;
	float frac;
	inputevent_t outevent;
	vector_t olddim;
	char *bindcmd;
	static U32 ovlDragDropMode=0;
	static overlay_t *ovlDragDropOverlay=NULL;
	char *bodycursor;

	px = (int)(event->mouseX - ovl->pos.x);
	py = (int)(event->mouseY - ovl->pos.y);
	dx = dy = 0;
	if (!(ovl->flags & OVLF_NOBORDER))
	{			
		dx += 3; dy += 3;
	}
	if (!(ovl->flags & OVLF_NOTITLE))
	{
		dy += 12;
	}
	if ((ovl->parent) && (!(ovl->flags & OVLF_VIEWABSOLUTE)))
	{
		px += (int)ovl->parent->vpos.x;
		py += (int)ovl->parent->vpos.y;
		dx -= (int)ovl->parent->vpos.x;
		dy -= (int)ovl->parent->vpos.y;
	}

	olddim = ovl->dim;
	region = OVLREGION_BODY;
	if ((!ovl_lockOverlay) || (ovl == ovl_lockOverlay))
	{		
		// get region
		if (ovl == ovl_lockOverlay)
			region = ovl->iregion;
		else
			ovl->iregion = region = OVL_FindInputRegion(ovl, px, py);
		
		if (region == OVLREGION_NONE)
		{
			return(0); // out of range
		}

		// set the cursor for this region
		IN_SetCursor("select");
		switch(region)
		{
		case OVLREGION_BODY:
			if (OVL_SendMsg(ovl, "GetBodyCursor", 1, &bodycursor))
				IN_SetCursor(bodycursor);
			break;
		case OVLREGION_TITLE:
			if (ovl->flags & (OVLF_NOMOVE|OVLF_MAXIMIZED))
				break;
			IN_SetCursor("carrow"); break;
		case OVLREGION_BLEFT:
		case OVLREGION_BRIGHT:
			if (ovl->flags & (OVLF_NORESIZE|OVLF_MAXIMIZED|OVLF_MINIMIZED))
				break;
		case OVLREGION_HSCROLL:
			// intentional fallthrough
			IN_SetCursor("harrow"); break;
		case OVLREGION_BBOTTOM:
		case OVLREGION_BTOP:
			if (ovl->flags & (OVLF_NORESIZE|OVLF_MAXIMIZED|OVLF_MINIMIZED))
				break;
			// intentional fallthrough
		case OVLREGION_VSCROLL:
			IN_SetCursor("varrow"); break;
		case OVLREGION_BLLCORNER:
		case OVLREGION_BURCORNER:
			if (ovl->flags & (OVLF_NORESIZE|OVLF_MAXIMIZED|OVLF_MINIMIZED))
				break;
			IN_SetCursor("darrowup"); break;
		case OVLREGION_BLRCORNER:
		case OVLREGION_BULCORNER:
			if (ovl->flags & (OVLF_NORESIZE|OVLF_MAXIMIZED|OVLF_MINIMIZED))
				break;
			IN_SetCursor("darrowdn"); break;
		case OVLREGION_TDESTROY:
		case OVLREGION_TMINIMIZE:
		case OVLREGION_TMAXIMIZE:
		case OVLREGION_TRESTORE:
			IN_SetCursor("select"); break;
		case OVLREGION_DRAGDROP:
			IN_SetCursor("grabwindow"); break;
		}
		
		// mousemoves only need to change the cursor, and that's it
		if (event->eventType == INEV_MOUSEMOVE)
		{
			if ((region != OVLREGION_BODY) || (!ovl->children))
				return(1);
			
			// pass mousemove to children incase they need to change it
			
			for (child = ovl->children->next; child != ovl->children; child = child->next)
				child->flags &= ~OVLF_TOUCH;
			if (!ovl_lockOverlay)
			{
				for (child = ovl->children->next; child != ovl->children; child = child->next)
				{ // check topmost-flagged children first
					if (!(child->flags & OVLF_ALWAYSTOP))
						continue;
					child->flags |= OVLF_TOUCH;
					outevent = *event;
					outevent.mouseX -= (int)(ovl->pos.x + dx);
					outevent.mouseY -= (int)(ovl->pos.y + dy);
					if (OVL_RecursiveInputEvent(child, &outevent))
						return(1);
				}
			}
			for (child = ovl->children->next; child != ovl->children; child = child->next)
			{ // now check normal children
				if (child->flags & OVLF_TOUCH)
					continue;
				outevent = *event;
				outevent.mouseX -= (int)(ovl->pos.x + dx);
				outevent.mouseY -= (int)(ovl->pos.y + dy);
				if (OVL_RecursiveInputEvent(child, &outevent))
					return(1);
			}

			return(1);
		} // mousemove

		// check input
		if (region == OVLREGION_BODY)
		{ // directed to body - call overlay methods
			if ((event->eventType == INEV_RELEASE) && (event->key == KEY_MOUSELEFT))
				OVL_UnlockInput(ovl);

			// check event with children first
			if (ovl->children)
			{
				for (child = ovl->children->next; child != ovl->children; child = child->next)
					child->flags &= ~OVLF_TOUCH;
				if (!ovl_lockOverlay)
				{
					for (child = ovl->children->next; child != ovl->children; child = child->next)
					{ // check topmost-flagged children first
						if (!(child->flags & OVLF_ALWAYSTOP))
							continue;
						child->flags |= OVLF_TOUCH;
						outevent = *event;
						outevent.mouseX -= (int)(ovl->pos.x + dx);
						outevent.mouseY -= (int)(ovl->pos.y + dy);
						if (OVL_RecursiveInputEvent(child, &outevent))
						{
							OVL_SetRedraw(child, false);
							return(1);
						}
					}
				}
				for (child = ovl->children->next; child != ovl->children; child = child->next)
				{ // now check normal children
					if (child->flags & OVLF_TOUCH)
						continue;
					outevent = *event;
					outevent.mouseX -= (int)(ovl->pos.x + dx);
					outevent.mouseY -= (int)(ovl->pos.y + dy);
					if (OVL_RecursiveInputEvent(child, &outevent))
					{
						OVL_SetRedraw(child, false);
						return(1);
					}
				}
			}

			// children didn't handle it, so it's our turn
			if (event->eventType == INEV_PRESS)
				OVL_SetTopmost(ovl);

			// check drag&drop first
			if ((event->key == KEY_MOUSELEFT) && (event->eventType == INEV_PRESS) && (ovlDragDropMode))
			{
				if (ovlDragDropOverlay != ovl)
					ovl->OnDragDrop(ovlDragDropOverlay);
				ovlDragDropMode = 0;
				ovlDragDropOverlay = NULL;
				OVL_SetRedraw(ovl, true);
				return(1);
			}

			// check standard events
			outevent = *event;
			outevent.mouseX -= (int)(ovl->pos.x + dx);
			outevent.mouseY -= (int)(ovl->pos.y + dy);
			switch(event->eventType)
			{
			case INEV_PRESS:
				if (ovl->OnPress(&outevent))
				{
					OVL_SetRedraw(ovl, false);
					return(1);
				}
				if (bindcmd = OVL_GetDerivedBinding(ovl, event->key, event->flags))
				{
					if (CON->Execute(ovl, bindcmd, 0))
					{
						OVL_SetRedraw(ovl, false);
						return(1);
					}
				}
				break;
			case INEV_DRAG:
				if (ovl->OnDrag(&outevent))
				{
					OVL_SetRedraw(ovl, false);
					return(1);
				}
				if (bindcmd = OVL_GetDerivedBinding(ovl, event->key, event->flags))
				{
					if (OVL_SendDragCommand(ovl, bindcmd))
					{
						OVL_SetRedraw(ovl, false);
						return(1);
					}
				}
				break;
			case INEV_RELEASE:
				if (ovl->OnRelease(&outevent))
				{
					OVL_SetRedraw(ovl, false);
					return(1);
				}
				if (bindcmd = OVL_GetDerivedBinding(ovl, event->key, event->flags))
				{
					if (OVL_SendReleaseCommand(ovl, bindcmd))
					{
						OVL_SetRedraw(ovl, false);
						return(1);
					}
				}
				break;
			}
			return(1); // still pressed in our space, so technically we've handled it

		} // body region
		else
		{ // input is for a system region

			// check window drag&drop
			if ((event->key == KEY_MOUSELEFT) && (event->eventType == INEV_PRESS) && (ovlDragDropMode))
			{
				OVL_SetTopmost(ovl);
				if (ovlDragDropOverlay != ovl)
					ovl->OnDragDrop(ovlDragDropOverlay);
				ovlDragDropMode = 0;
				ovlDragDropOverlay = NULL;
				OVL_SetRedraw(ovl, true);
				return(1);
			}

			if (event->key == KEY_MOUSERIGHT)
			{
				if (event->eventType == INEV_PRESS)// && (event->flags == KF_ALT))
				{
					OVL_SetTopmost(ovl);
					OVL_LockInput(ovl);
					ovl->iregion = OVLREGION_DRAGDROP;
					switch(region)
					{
					case OVLREGION_TITLE:
						ovlDragDropMode = 1;
						ovlDragDropOverlay = ovl;
						return(1);
						break;
					}
				}
				else
				if ((event->eventType == INEV_RELEASE) && (ovlDragDropMode))
				{
					OVL_UnlockInput(ovl);
					inputevent_t dragevent;
					dragevent.eventType = INEV_PRESS;
					dragevent.key = KEY_MOUSELEFT;
					dragevent.flags = 0;
					dragevent.mouseX = in_MouseX;
					dragevent.mouseY = in_MouseY;
					dragevent.mouseDeltaX = dragevent.mouseDeltaY = 0;
					dragevent.time = mesh_app.get_frame_begin();
					OVL_InputEvent(&dragevent);
					return(1);
				}
			}
			
			if (event->key != KEY_MOUSELEFT)
				return(1);

			if (event->eventType == INEV_PRESS)
			{
				OVL_SetTopmost(ovl);
				OVL_LockInput(ovl);
				
				switch(region)
				{
				case OVLREGION_TMINIMIZE:
					ovl->flags &= ~OVLF_MAXIMIZED;
					ovl->flags |= OVLF_MINIMIZED;
					return(1);
					break;
				case OVLREGION_TMAXIMIZE:
					ovl->flags &= ~OVLF_MINIMIZED;
					ovl->flags |= OVLF_MAXIMIZED;
					return(1);
					break;
				case OVLREGION_TRESTORE:
					ovl->flags &= ~(OVLF_MINIMIZED|OVLF_MAXIMIZED);
					return(1);
					break;
				}
			}
			else
			if (event->eventType == INEV_RELEASE)
			{				
				OVL_UnlockInput(ovl);
				switch(region)
				{
				case OVLREGION_TDESTROY:
					ovl->flags |= OVLF_TAGDESTROY;
					break;
				}
			}
			else
			if (event->eventType == INEV_DRAG)
			{
				switch(region)
				{
				case OVLREGION_HSCROLL:
					frac = (float)(ovl->vmax.x - ovl->vmin.x) / (float)ovl->dim.x;
					ovl->vpos.x += (int)(event->mouseDeltaX*frac);
					break;
				case OVLREGION_VSCROLL:
					frac = (float)(ovl->vmax.y - ovl->vmin.y) / (float)ovl->dim.y;
					ovl->vpos.y += (int)(event->mouseDeltaY*frac);
					break;
				case OVLREGION_TITLE:
					if (ovl->flags & (OVLF_NOMOVE|OVLF_MAXIMIZED))
						break;
					ovl->pos.x += event->mouseDeltaX; ovl->pos.y += event->mouseDeltaY;
					break;
				case OVLREGION_BLEFT:
					if (ovl->flags & (OVLF_NORESIZE|OVLF_MAXIMIZED|OVLF_MINIMIZED))
						break;
					ovl->dim.x -= event->mouseDeltaX;
					OVL_ResizeCheckProportional(ovl);
					if (OVL_ResizeLimits(ovl)) { in_MouseX -= event->mouseDeltaX; in_MouseY -= event->mouseDeltaY; break; }
					ovl->pos.x += event->mouseDeltaX;
					break;
				case OVLREGION_BRIGHT:
					if (ovl->flags & (OVLF_NORESIZE|OVLF_MAXIMIZED|OVLF_MINIMIZED))
						break;
					ovl->dim.x += event->mouseDeltaX;
					OVL_ResizeCheckProportional(ovl);
					if (OVL_ResizeLimits(ovl)) { in_MouseX -= event->mouseDeltaX; in_MouseY -= event->mouseDeltaY; break; }
					break;
				case OVLREGION_BBOTTOM:
					if (ovl->flags & (OVLF_NORESIZE|OVLF_MAXIMIZED|OVLF_MINIMIZED))
						break;
					ovl->dim.y += event->mouseDeltaY;
					OVL_ResizeCheckProportional(ovl);
					if (OVL_ResizeLimits(ovl)) { in_MouseX -= event->mouseDeltaX; in_MouseY -= event->mouseDeltaY; break; }
					break;
				case OVLREGION_BTOP:
					if (ovl->flags & (OVLF_NORESIZE|OVLF_MAXIMIZED|OVLF_MINIMIZED))
						break;
					ovl->dim.y -= event->mouseDeltaY;
					OVL_ResizeCheckProportional(ovl);
					if (OVL_ResizeLimits(ovl)) { in_MouseX -= event->mouseDeltaX; in_MouseY -= event->mouseDeltaY; break; }
					ovl->pos.y += event->mouseDeltaY;
					break;
				case OVLREGION_BLLCORNER:
					if (ovl->flags & (OVLF_NORESIZE|OVLF_MAXIMIZED|OVLF_MINIMIZED))
						break;
					ovl->dim.x -= event->mouseDeltaX;
					OVL_ResizeCheckProportional(ovl);
					if (OVL_ResizeLimits(ovl)) { in_MouseX -= event->mouseDeltaX; in_MouseY -= event->mouseDeltaY; break; }
					ovl->dim.y += event->mouseDeltaY;
					OVL_ResizeCheckProportional(ovl);
					if (OVL_ResizeLimits(ovl)) { in_MouseX -= event->mouseDeltaX; in_MouseY -= event->mouseDeltaY; break; }
					ovl->pos.x += event->mouseDeltaX;
					break;
				case OVLREGION_BURCORNER:
					if (ovl->flags & (OVLF_NORESIZE|OVLF_MAXIMIZED|OVLF_MINIMIZED))
						break;
					ovl->dim.x += event->mouseDeltaX;
					OVL_ResizeCheckProportional(ovl);
					if (OVL_ResizeLimits(ovl)) { in_MouseX -= event->mouseDeltaX; in_MouseY -= event->mouseDeltaY; break; }
					ovl->dim.y -= event->mouseDeltaY;
					OVL_ResizeCheckProportional(ovl);
					if (OVL_ResizeLimits(ovl)) { in_MouseX -= event->mouseDeltaX; in_MouseY -= event->mouseDeltaY; break; }
					ovl->pos.y += event->mouseDeltaY;
					break;
				case OVLREGION_BLRCORNER:
					if (ovl->flags & (OVLF_NORESIZE|OVLF_MAXIMIZED|OVLF_MINIMIZED))
						break;
					ovl->dim.x += event->mouseDeltaX;
					OVL_ResizeCheckProportional(ovl);
					if (OVL_ResizeLimits(ovl)) { in_MouseX -= event->mouseDeltaX; in_MouseY -= event->mouseDeltaY; break; }
					ovl->dim.y += event->mouseDeltaY;
					OVL_ResizeCheckProportional(ovl);
					if (OVL_ResizeLimits(ovl)) { in_MouseX -= event->mouseDeltaX; in_MouseY -= event->mouseDeltaY; break; }
					break;
				case OVLREGION_BULCORNER:
					if (ovl->flags & (OVLF_NORESIZE|OVLF_MAXIMIZED|OVLF_MINIMIZED))
						break;
					ovl->dim.x -= event->mouseDeltaX;
					OVL_ResizeCheckProportional(ovl);
					if (OVL_ResizeLimits(ovl)) { in_MouseX -= event->mouseDeltaX; in_MouseY -= event->mouseDeltaY; break; }
					ovl->dim.y -= event->mouseDeltaY;
					OVL_ResizeCheckProportional(ovl);
					if (OVL_ResizeLimits(ovl)) { in_MouseX -= event->mouseDeltaX; in_MouseY -= event->mouseDeltaY; break; }
					ovl->pos.x += event->mouseDeltaX;
					ovl->pos.y += event->mouseDeltaY;
					break;
				} // switch
				OVL_SetRedraw(ovl, true);
			} // drag
			if ((ovl->dim.x != olddim.x) || (ovl->dim.y != olddim.y))
			{
				ovl->OnResize();
				OVL_SetRedraw(ovl, true);
			}
			return(1);
		} // system region
	} // lock

	// event wasn't handled or lock didn't permit, so check children
	if (!ovl->children)
		return(0);
	
	for (child = ovl->children->next; child != ovl->children; child = child->next)
		child->flags &= ~OVLF_TOUCH;
	if (!ovl_lockOverlay)
	{
		for (child = ovl->children->next; child != ovl->children; child = child->next)
		{ // check topmost-flagged children first
			if (!(child->flags & OVLF_ALWAYSTOP))
				continue;
			child->flags |= OVLF_TOUCH;
			outevent = *event;
			outevent.mouseX -= (int)(ovl->pos.x + dx);
			outevent.mouseY -= (int)(ovl->pos.y + dy);
			if (OVL_RecursiveInputEvent(child, &outevent))
			{
				OVL_SetRedraw(child, false);
				return(1);
			}
		}
	}
	for (child = ovl->children->next; child != ovl->children; child = child->next)
	{ // now check normal children
		if (child->flags & OVLF_TOUCH)
			continue;
		outevent = *event;
		outevent.mouseX -= (int)(ovl->pos.x + dx);
		outevent.mouseY -= (int)(ovl->pos.y + dy);
		if (OVL_RecursiveInputEvent(child, &outevent))
		{
			OVL_SetRedraw(child, false);
			return(1);
		}
	}
	return(0);
}

static U32 OVL_RecursiveCheckTagDestroy(overlay_t *ovl)
{
	overlay_t *child;

	if (ovl->flags & OVLF_TAGDESTROY)
	{
		OVL_SendMsgAll(ovl_Windows, "Notify_OvlDeleting", 1, ovl);
		OVL_SetRedraw(ovl_Windows, false);
		delete ovl;
		return(1);
	}
	if (!ovl->children)
		return(0);
	
	for (child = ovl->children->next; child != ovl->children; child = child->next)
	{
		if (OVL_RecursiveCheckTagDestroy(child))
			child = ovl->children; // something was deleted, reset so child->next restarts list
		if (!child)
			break;
	}
	return(0);
}

//----------------------------------------------------------------------------
//    Public Code
//----------------------------------------------------------------------------
void OVL_Init()
{
	OVL_CreateRootWindow();
}

void OVL_Shutdown()
{
	if (ovl_Windows)
		delete ovl_Windows;
	ovl_Windows = NULL;
}

void OVL_Frame()
{
	ovlClipBox_t clip;
	vector_t oldpos, olddim;
	int oldflags;
	overlay_t *ovl;

	if (!ovl_Windows)
		return;
	clip.sx = clip.sy = 0; clip.ex = vid->res.width; clip.ey = vid->res.height;
	for (ovl=ovl_focusOverlay; (ovl)&&(!(ovl->flags & OVLF_MAXIMIZED)); ovl=ovl->parent)
		;
	if (ovl) // if this is non-null, it must be maximized
	{
		oldpos = ovl->pos;
		olddim = ovl->dim;
		oldflags = (ovl->flags & OVLF_VIEWABSOLUTE);
		ovl->flags |= OVLF_VIEWABSOLUTE;
		ovl->pos.Seti(0, 0, 0);
		ovl->dim.Seti(vid->res.width, vid->res.height, 0);
		ovl->OnResize();
		OVL_RecursiveDrawOverlay(ovl, (int)ovl->pos.x, (int)ovl->pos.y, (int)ovl->dim.x, (int)ovl->dim.y, &clip);
		ovl->pos = oldpos;
		ovl->dim = olddim;
		ovl->flags &= ~OVLF_VIEWABSOLUTE;
		ovl->flags |= oldflags;
		ovl->OnResize();
	}
	else
	{
		OVL_RecursiveDrawOverlay(ovl_Windows, 0, 0, vid->res.width, vid->res.height, &clip);
	}
	
	// check for destroy tags
	OVL_RecursiveCheckTagDestroy(ovl_Windows);
	
	vid->ClipWindow(0, 0, vid->res.width, vid->res.height);
}

void OVL_InputEvent(inputevent_t *event)
{
	inputevent_t outevent;
	overlay_t *ovl;
	char *bindcmd;
	vector_t oldpos, olddim;
	int oldflags;
	U32 wasMaximized;

	if (!ovl_Windows)
		return;
	outevent = *event;
	if ((outevent.eventType == INEV_MOUSEMOVE) || (outevent.key >= KEY_FIRSTMOUSEKEY))
	{
		for (ovl=ovl_focusOverlay; (ovl)&&(!(ovl->flags & (OVLF_MAXIMIZED|OVLF_MEGALOCK))); ovl=ovl->parent)
			;
		if (ovl) // if this is non-null, it must be maximized
		{		
			oldflags = (ovl->flags & OVLF_VIEWABSOLUTE);
			ovl->flags |= OVLF_VIEWABSOLUTE;
			wasMaximized = 0;
			if (ovl->flags & OVLF_MAXIMIZED)
			{
				oldpos = ovl->pos;
				olddim = ovl->dim;
				ovl->pos.Seti(0, 0, 0);
				ovl->dim.Seti(vid->res.width, vid->res.height, 0);
				ovl->OnResize();
				wasMaximized = 1;
			}
			else
			{
				outevent.mouseY -= 15;
				outevent.mouseX -= 3;
				//outevent = *event;
				//OVL_MousePosWindowRelative(ovl, &outevent.mouseX, &outevent.mouseY);
			}
			OVL_RecursiveInputEvent(ovl, &outevent);
			ovl->flags &= ~OVLF_VIEWABSOLUTE;
			ovl->flags |= oldflags;
			if (wasMaximized)
			{
				ovl->pos = oldpos;
				ovl->dim = olddim;
				ovl->OnResize();
			}
		}
		else
		{
			outevent.mouseX -= (int)(ovl_Windows->pos.x);
			outevent.mouseY -= (int)(ovl_Windows->pos.y);
			OVL_RecursiveInputEvent(ovl_Windows, &outevent);
		}
		return;
	}
	// keypresses route to lock or focus, and to parents as necessary	
	ovl = ovl_lockOverlay;
	if (!ovl)
		ovl = ovl_focusOverlay;
	if (ovl)
	{		
		OVL_MousePosWindowRelative(ovl, &outevent.mouseX, &outevent.mouseY);
		switch(event->eventType)
		{
		case INEV_PRESS:
			if (ovl->OnPress(&outevent))
			{
				OVL_SetRedraw(ovl, false);
				return;
			}
			if (bindcmd = OVL_GetDerivedBinding(ovl, event->key, event->flags))
			{
				if (CON->Execute(ovl, bindcmd, 0))
				{
					OVL_SetRedraw(ovl, false);
					return;
				}
			}
			break;
		case INEV_DRAG:
			if (ovl->OnDrag(&outevent))
			{
				OVL_SetRedraw(ovl, false);
				return;
			}
			if (bindcmd = OVL_GetDerivedBinding(ovl, event->key, event->flags))
			{
				if (OVL_SendDragCommand(ovl, bindcmd))
				{
					OVL_SetRedraw(ovl, false);
					return;
				}
			}
			break;
		case INEV_RELEASE:
			if (ovl->OnRelease(&outevent))
			{
				OVL_SetRedraw(ovl, false);
				return;
			}
			if (bindcmd = OVL_GetDerivedBinding(ovl, event->key, event->flags))
			{
				if (OVL_SendReleaseCommand(ovl, bindcmd))
				{
					OVL_SetRedraw(ovl, false);
					return;
				}
			}
			break;
		}
	}
}

void OVL_CreateRootWindow()
{
	if (!ovl_Windows)
	{
		ovl_Windows = OVL_CreateOverlay("OWorkspace", "Cannibal", (overlay_t *)-1, 0, 0, vid->res.width, vid->res.height,
			OVLF_NOMOVE|OVLF_NORESIZE|OVLF_NOTITLEDESTROY|OVLF_NOTITLEMINMAX|OVLF_ROOTWINDOW, true);
		ovl_Windows->parent = NULL;
		ovl_focusOverlay = ovl_Windows;
	}
}

void OVL_SetTopmost(overlay_t *ovl)
{
	if ((!ovl) || (!(ovl->flags & OVLF_NOFOCUS)))
		ovl_focusOverlay = ovl;
	if (ovl)
		OVL_SetRedraw(ovl, true);
	if ((!ovl) || (!ovl->parent))
		return;	
	ovl->next->prev = ovl->prev;
	ovl->prev->next = ovl->next;
	ovl->next = ovl->parent->children->next;
	ovl->prev = ovl->parent->children;
	ovl->next->prev = ovl;
	ovl->prev->next = ovl;
}

void OVL_SetRedraw(overlay_t *ovl, U32 extreme)
{
/*	
	overlay_t *child;

	if ((extreme) && (ovl->parent))
	{ // extreme is used when overlays are moved etc, in which case the parent and all the children need redrawing
		OVL_SetRedraw(ovl->parent, false);
		return;
	}
	ovl->flags |= OVLF_REDRAW;
	if (ovl->children)
	{
		for (child = ovl->children->next; child != ovl->children; child = child->next)
			OVL_SetRedraw(child, false);
	}
	if ((ovl->parent) && (ovl->parent->children))
	{
		for (child = ovl->prev; child != ovl->parent->children; child = child->prev)
		{
			if ((!(child->flags & OVLF_REDRAW))
			 && (child->pos.x <= ovl->pos.x+ovl->dim.x) && (child->pos.x+child->dim.x >= ovl->pos.x)
			 && (child->pos.y <= ovl->pos.y+ovl->dim.y) && (child->pos.y+child->dim.y >= ovl->pos.y))
			{ // if an overlay is on top of this overlay, it needs to be redrawn too
				child->flags |= OVLF_REDRAW;
			}
		}
		for (child = ovl->parent->children->next; child != ovl->parent->children; child = child->next)
		{
			if ((!(child->flags & OVLF_REDRAW)) && (child->flags & OVLF_ALWAYSTOP)
			 && (child->pos.x <= ovl->pos.x+ovl->dim.x) && (child->pos.x+child->dim.x >= ovl->pos.x)
			 && (child->pos.y <= ovl->pos.y+ovl->dim.y) && (child->pos.y+child->dim.y >= ovl->pos.y))
			{ // same thing, but check all the topmost overlays
				child->flags |= OVLF_REDRAW;
			}
		}
	}
*/
}

U32 OVL_ClipToBoxLimits(int sx, int sy, int ex, int ey, ovlClipBox_t *clip)
{
	if (sx < clip->sx)
		sx = clip->sx;
	if (sy < clip->sy)
		sy = clip->sy;
	if (ex > clip->ex)
		ex = clip->ex;
	if (ey > clip->ey)
		ey = clip->ey;
	if ((ex <= sx) || (ey <= sy) || (ex <= 0) || (ey <= 0) || (sx >= (I32)vid->res.width) || (sy >= (I32)vid->res.height))
		return(0);
	vid->ClipWindow(sx, sy, ex, ey);
	return(1);
}

overlay_t *OVL_FindChild(overlay_t *parent, overlay_t *previous, char *ctype, char *cname)
{
	if (!parent)
		parent = ovl_Windows;
	if (!parent->children)
		return(NULL);
	if (!previous)
		previous = parent->children;
	else
		if (previous->parent != parent)
			return(NULL);
	for (overlay_t *child = previous->next; child != parent->children; child = child->next)
	{
		if ((cname) && (_stricmp(cname, child->name)))
			continue;
		if ((ctype) && (_stricmp(ctype, child->typedecl->ovlTypeName)))
			continue;
		return(child);
	}
	return(NULL);
}

void OVL_MousePosWindowRelative(overlay_t *ovl, int *mx, int *my)
{
	if (!ovl)
		return;
	if (ovl->parent)
	{
		if (!(ovl->flags & OVLF_MAXIMIZED))
		{
			OVL_MousePosWindowRelative(ovl->parent, mx, my);
			*mx -= (int)(ovl->pos.x);
			*my -= (int)(ovl->pos.y);
            if (!(ovl->flags & OVLF_VIEWABSOLUTE))
            {
			    *mx += (int)(ovl->parent->vpos.x);
			    *my += (int)(ovl->parent->vpos.y);
            }
		}
	}
	else
	{
		*mx -= (int)(ovl->pos.x);
		*my -= (int)(ovl->pos.y);
	}
	if (!(ovl->flags & OVLF_NOBORDER))
	{
		*mx -= 3; *my -= 3;
	}
	if (!(ovl->flags & OVLF_NOTITLE))
	{
		*my -= 12;
	}
}

U32 OVL_SendMsg(overlay_t *ovl, CC8 *msgname, int numparms, ... )
{
	ovlmsg_t fullmsg;
	va_list args;
	int i;

	if (!ovl)
		return(0);
	fullmsg.msgname = msgname;
	va_start(args, numparms);
	if (numparms > OVLMSG_NUMPARMS)
		numparms = OVLMSG_NUMPARMS;
	for (i=0;i<numparms;i++)
		fullmsg.p[i] = va_arg(args, void *);
	va_end(args);

	return(ovl->OnMessage(&fullmsg));
}

static void RecursiveSendMsg(overlay_t *ovl, ovlmsg_t *msg)
{
	if (!ovl)
		return;
	if (ovl->children)
	{
		overlay_t *child;
		for (child = ovl->children->next; child != ovl->children; child = child->next)
		{
			RecursiveSendMsg(child, msg);
		}
	}
	ovl->OnMessage(msg);
}

void OVL_SendMsgAll(overlay_t *ovl, CC8 *msgname, int numparms, ... )
{
	ovlmsg_t fullmsg;
	va_list args;
	int i;

	if (!ovl)
		return;
	fullmsg.msgname = msgname;
	va_start(args, numparms);
	if (numparms > OVLMSG_NUMPARMS)
		numparms = OVLMSG_NUMPARMS;
	for (i=0;i<numparms;i++)
		fullmsg.p[i] = va_arg(args, void *);
	va_end(args);

	RecursiveSendMsg(ovl, &fullmsg);
}

U32 OVL_SendPressCommand(overlay_t *ovl, CC8 *text, ... )
{
	static char tbuffer[1024];
	va_list args;
	int res;

	if (!ovl)
		return(0);
	va_start(args, text);
	vsprintf(tbuffer, text, args);
	va_end(args);
	SYS_Parse(tbuffer);
	res = ovl->OnPressCommand(SYS_GetParseArgc(), SYS_GetParseArgv());
	if (res)
		OVL_SetRedraw(ovl, false);
	return(res);
}

U32 OVL_SendDragCommand(overlay_t *ovl, CC8 *text, ... )
{
	static char tbuffer[1024];
	va_list args;
	int res;

	if (!ovl)
		return(0);
	va_start(args, text);
	vsprintf(tbuffer, text, args);
	va_end(args);
	SYS_Parse(tbuffer);
	res = ovl->OnDragCommand(SYS_GetParseArgc(), SYS_GetParseArgv());
	if (res)
		OVL_SetRedraw(ovl, false);
	return(res);
}

U32 OVL_SendReleaseCommand(overlay_t *ovl, CC8 *text, ... )
{
	static char tbuffer[1024];
	va_list args;
	int res;

	if (!ovl)
		return(0);
	va_start(args, text);
	vsprintf(tbuffer, text, args);
	va_end(args);
	SYS_Parse(tbuffer);
	res = ovl->OnReleaseCommand(SYS_GetParseArgc(), SYS_GetParseArgv());
	if (res)
		OVL_SetRedraw(ovl, false);
	return(res);
}

void OVL_LockInput(overlay_t *ovl)
{
	if (ovl_lockOverlay)
		return;
	ovl_lockOverlay = ovl;
}

void OVL_UnlockInput(overlay_t *ovl)
{
	if (ovl_lockOverlay != ovl)
		return;
	ovl_lockOverlay = NULL;
}

void OVL_SaveOverlay(overlay_t *ovl) // save overlay (and all child windows) to clipboard
{
	static int inSave = 0;
	
	overlay_t *child;
	int numkids;

	if (!ovl)
	{
		ovl = ovl_Windows;
		if (!ovl)
			return;
	}
	if (!inSave)
	{
		VCR_Record(VCRA_CLIPBOARD, "$overlay", NULL, 256, NULL); // initial buffer size is crap space; each overlay will enlarge
	}
	inSave++;	
	
	VCR_EnlargeActionDataBuffer(4+fstrlen(ovl->name)+fstrlen(ovl->typedecl->ovlTypeName)+4+32);
	VCR_WriteInt(1); // version
	
	// save creation info
	VCR_WriteString(ovl->name);
	VCR_WriteString((char *)ovl->typedecl->ovlTypeName);
	if (ovl == ovl_focusOverlay)
		ovl->flags |= OVLF_HASFOCUS;
	VCR_WriteInt(ovl->flags);
	ovl->flags &= ~OVLF_HASFOCUS;
	VCR_WriteFloat(ovl->pos.x);
	VCR_WriteFloat(ovl->pos.y);
	VCR_WriteFloat(ovl->dim.x);
	VCR_WriteFloat(ovl->dim.y);
	VCR_WriteFloat(ovl->vpos.x);
	VCR_WriteFloat(ovl->vpos.y);
	
	// save data particular to this overlay
	ovl->OnSave();
	
	// if we have any children, recursively save them
	if (ovl->children)
	{
		for (numkids=0,child = ovl->children->next; child != ovl->children; numkids++,child = child->next)
			;
		VCR_WriteInt(numkids);
		for (child = ovl->children->next; child != ovl->children; child = child->next)
			OVL_SaveOverlay(child);
	}
	else
	{
		VCR_WriteInt(0); // no kids
	}
	
	inSave--;
}

void OVL_LoadOverlay(overlay_t *parent) // create and load overlay and its children from clipboard, to the given parent
{
	static int inLoad = 0;
	
	char *actname;
	overlay_t *ovl;
	char ltype[128], lname[256];
	vector_t lpos, ldim;
	unsigned long lflags;
	int i, version, numkids;

	if (!inLoad)
	{
		VCR_ActivateAction(VCRA_CLIPBOARD);
		actname = VCR_ActiveActionName();
		if (strcmp(actname, "$overlay"))
			return;
		VCR_ResetActionRead();
		VCR_ReadSetForward();
	}
	
	inLoad++;
	
	version = VCR_ReadInt();
	if (version == 1)
	{
		// load up window info for creation
		strcpy(lname, VCR_ReadString());
		strcpy(ltype, VCR_ReadString());
		lflags = VCR_ReadInt();
		lpos.x = VCR_ReadFloat();
		lpos.y = VCR_ReadFloat();
		ldim.x = VCR_ReadFloat();
		ldim.y = VCR_ReadFloat();

		if (lflags & OVLF_ROOTWINDOW)
		{ // primary Cannibal window, do not create from file, just respawn by default then alter
			if (ovl_Windows)
				delete ovl_Windows;
			ovl_Windows = NULL;
			OVL_CreateRootWindow();
			ovl = ovl_Windows;
			ovl->vpos.x = VCR_ReadFloat();
			ovl->vpos.y = VCR_ReadFloat();
			ovl->vpos.z = 0;
			if (ovl->flags & OVLF_HASFOCUS)
			{
				ovl_focusOverlay = ovl;
				ovl->flags &= ~OVLF_HASFOCUS;
			}
			ovl = NULL; // set to null so children being created will go to root window
		}
		else
		{
			ovl = OVL_CreateOverlay(ltype, lname, parent, (int)lpos.x, (int)lpos.y, (int)ldim.x, (int)ldim.y, lflags, false);
			ovl->vpos.x = VCR_ReadFloat();
			ovl->vpos.y = VCR_ReadFloat();
			ovl->vpos.z = 0;
			if (ovl->flags & OVLF_HASFOCUS)
			{
				ovl_focusOverlay = ovl;
				ovl->flags &= ~OVLF_HASFOCUS;
			}
		}

		// load data particular to this overlay
		if (!ovl)
			ovl_Windows->OnLoad();
		else
			ovl->OnLoad();
		
		// if any children are saved with this one, recursively load them up
		numkids = VCR_ReadInt();
		for (i=0;i<numkids;i++)
			OVL_LoadOverlay(ovl);
	}
	else
	{
		SYS_Error("OVL_LoadOverlay: Invalid version number %d", version);
	}	
	
	inLoad--;
	if (!inLoad)
	{
		if (ovl_focusOverlay)
			OVL_SetTopmost(ovl_focusOverlay);
		ovl_lockOverlay = NULL;
	}
}

static COvlTypeDecl *OVL_GetOverlayPrototype(char *rtype)
{
	COvlTypeDecl *odecl;

	if (!rtype)
		return(NULL);
	for (odecl=ovl_OvlTypeDecls;odecl;odecl=odecl->next)
	{
		if (!_stricmp(odecl->ovlTypeName, rtype))
			return(odecl);
	}
	return(NULL);
}

overlay_t *OVL_CreateOverlay(char *ovltype,
							 char *title,
							 overlay_t *parent,
							 int posX, int posY,
							 int dimX, int dimY,
							 unsigned long flags,
							 U32 runConfig)
{
	COvlTypeDecl *odecl;
	overlay_t *res;

	if (!ovltype)
		return(OVL_CreateOverlay("OWindow", title, parent, posX, posY, dimX, dimY, flags, runConfig)); // give them the basic overlay
	odecl = OVL_GetOverlayPrototype(ovltype);
	if (!odecl)
		return(OVL_CreateOverlay("OWindow", title, parent, posX, posY, dimX, dimY, flags, runConfig)); // give them the basic overlay
	if (!parent)
	{
		OVL_CreateRootWindow();
		parent = ovl_Windows;
	}
	res = odecl->ovlPrototype->Spawn(odecl, parent);
	if (!res)
		SYS_Error("OVL_CreateOverlay: Unable to spawn overlay");
	res->pos.x = (float)posX; res->pos.y = (float)posY;
	res->SetDimensions(dimX,dimY);
	//res->dim.x = dimX; res->dim.y = dimY;
	res->proportionRatio = res->dim.y / res->dim.x;
	res->flags |= flags;
	if (!title)
		title = "";
	strcpy(res->name, title);
	res->OnResize();
	if (runConfig)
		CON->ExecuteFile(res, ovltype, false); // ex: exec config\owindow.cfg
	
	return(res);
}

U32 OVL_IsOverlayType(overlay_t *ovl, char *ovltype)
{
	if ((!ovl) || (!ovl->typedecl))
		return(0);
	return(!_stricmp(ovl->typedecl->ovlTypeName, ovltype));
}

void OVL_SelectionBox(char *caption, char *choices, overlay_t *cbOvl, char *cbCommand, int multiSelect)
{
	overlay_t *ovl = OVL_CreateOverlay("OSelectionBox", caption, NULL, 120, 120, 400, 240,
		OVLF_ALWAYSTOP|OVLF_VIEWABSOLUTE|OVLF_NODRAGDROP|OVLF_NOMOVE|OVLF_NORESIZE|OVLF_NOTITLEMINMAX|OVLF_NOTITLEDESTROY, false);
	OVL_SendMsg(ovl, "SelectionBoxInfo", 4, choices, cbOvl, cbCommand, multiSelect);
	OVL_SetTopmost(ovl);
	ovl_lockOverlay = NULL;
	OVL_LockInput(ovl);
	ovl->flags |= OVLF_MEGALOCK;
}

void OVL_InputBox(char *caption, char *text, overlay_t *cbOvl, char *cbCommand, char *initialInput)
{
	overlay_t *ovl = OVL_CreateOverlay("OInputBox", caption, NULL, 320 - (fstrlen(text)*8 + 10)/2, 220, fstrlen(text)*8 + 10, 40,
		OVLF_ALWAYSTOP|OVLF_VIEWABSOLUTE|OVLF_NODRAGDROP|OVLF_NOMOVE|OVLF_NORESIZE|OVLF_NOTITLEMINMAX|OVLF_NOTITLEDESTROY, false);
	OVL_SendMsg(ovl, "InputBoxInfo", 4, text, cbOvl, cbCommand, initialInput);
	OVL_SetTopmost(ovl);
	ovl_lockOverlay = NULL;
	OVL_LockInput(ovl);
	ovl->flags |= OVLF_MEGALOCK;
}

static int OVL_BindKey(char *name, int key, char *action, int flags)
{
	COvlTypeDecl *odecl = OVL_GetOverlayPrototype(name);
	if (!odecl)
		return(0);
	strcpy(odecl->bindconfig.keyBindings[key][flags], action);
	return(1);
}

static int OVL_UnbindKey(char *name, int key, int flags)
{
	COvlTypeDecl *odecl = OVL_GetOverlayPrototype(name);
	if (!odecl)
		return(0);
	odecl->bindconfig.keyBindings[key][flags][0] = 0;
	return(1);
}

static char *OVL_GetBind(char *name, int key, int flags)
{
	COvlTypeDecl *odecl = OVL_GetOverlayPrototype(name);
	if (!odecl)
		return(NULL);
	return(odecl->bindconfig.keyBindings[key][flags]);
}

static void OVL_GetKeyForBind(char *rname, char *name, int *key, int *flags)
{
	if (!name)
		return;
	COvlTypeDecl *odecl = OVL_GetOverlayPrototype(rname);
	if (!odecl)
		return;
	*key = -1;
	for (int i=0;i<IN_NUMKEYS;i++)
	{
		for (int k=0;k<8;k++)
		{
			if (!_stricmp(name, odecl->bindconfig.keyBindings[i][k]))
			{
				*key = i;
				*flags = k;
			}
		}
	}
}
CONFUNC(Bind, NULL, 0)
{
	char *ptr;
	int i, action=0, flags=0;
	static char fullkeyname[256];
	static char bclass[256];

	if (argNum < 3)
	{
		CON->Printf("[?] BIND [@roomtype] [options] key [command/?]\n[?] options: SHIFT CTRL ALT");
		return;
	}
	fullkeyname[0] = 0;
	bclass[0] = 0;
	for (i=1;i<argNum-1;i++)
	{
		if (!_stricmp(argList[i], "SHIFT"))
		{
			strcat(fullkeyname, "SHIFT ");
			flags |= KF_SHIFT;
		}
		else
		if (!_stricmp(argList[i], "CTRL"))
		{
			strcat(fullkeyname, "CTRL ");
			flags |= KF_CONTROL;
		}
		else
		if (!_stricmp(argList[i], "ALT"))
		{
			strcat(fullkeyname, "ALT ");
			flags |= KF_ALT;
		}
		else
		if (argList[i][0] == '@')
		{
			strcpy(bclass, &argList[i][1]);
		}
		else
		{
			action = i;
			break;
		}
	}
	if (!action)
	{
		CON->Printf("[?] BIND [@roomtype] [options] key [command/?]\n[?] options: SHIFT CTRL ALT");
		return;
	}
	for (i=0;i<IN_NUMKEYS;i++)
	{
		ptr = IN_NameForKey(i);
		if ((ptr) && (!_stricmp(argList[action], ptr)))
		{
			strcat(fullkeyname, ptr);
			if (!_stricmp(argList[action+1], "?"))
			{
				if (bclass[0])
				{
					char *cbind = OVL_GetBind(bclass, i, flags);
					if (cbind)
						CON->Printf("%s(%s) is bound to \"%s\"", fullkeyname, bclass, cbind);
					else
						CON->Printf("%s is not a valid overlay type", bclass);
				}
				else
					CON->Printf("%s is bound to \"%s\"", fullkeyname, OVL_GetBind("OWindow", i, flags));
			}
			else
			{
				if (bclass[0])
				{
					if (!OVL_BindKey(bclass, i, argList[action+1], flags))
						CON->Printf("%s is not a valid overlay type", bclass);
				}
				else
					OVL_BindKey("OWindow", i, argList[action+1], flags);
			}
			return;
		}
	}
	CON->Printf("No key named %s", argList[action]);
}

CONFUNC(Unbind, NULL, 0)
{
	char *ptr;
	int i, action=0, flags=0;
	static char bclass[256];

	if (argNum < 2)
	{
		CON->Printf("[?] UNBIND [@roomtype] [SHIFT] [CTRL] [ALT] key");
		return;
	}
	bclass[0] = 0;
	for (i=1;i<argNum;i++)
	{
		if (!_stricmp(argList[i], "SHIFT"))
			flags |= KF_SHIFT;
		else
		if (!_stricmp(argList[i], "CTRL"))
			flags |= KF_CONTROL;
		else
		if (!_stricmp(argList[i], "ALT"))
			flags |= KF_ALT;
		else
		if (argList[i][0] == '@')
		{
			strcpy(bclass, &argList[i][1]);
		}
		else
		{
			action = i;
			break;
		}
	}
	if (!action)
	{
		CON->Printf("[?] UNBIND [@roomtype] [SHIFT] [CTRL] [ALT] key");
		return;
	}
	for (i=0;i<IN_NUMKEYS;i++)
	{
		ptr = IN_NameForKey(i);
		if ((ptr) && (!_stricmp(argList[action], ptr)))
		{
			if (bclass[0])
			{
				if (!OVL_UnbindKey(bclass, i, flags))
					CON->Printf("%s is not a valid overlay type", bclass);
			}
			else
				OVL_UnbindKey("OWindow", i, flags);
			return;
		}
	}
	CON->Printf("No key named %s", argList[action]);
}
//----------------------------------------------------------------------------
//    Class Member Code
//----------------------------------------------------------------------------
COvlTypeDecl::COvlTypeDecl(const char *name, overlay_t *proto, overlay_t *protobase)
{
	ovlTypeName = name;
	ovlPrototype = proto;
	ovlPrototypeBase = protobase;
	if (ovlPrototypeBase == &overlay_t_ovlprototype)
		ovlPrototypeBase = NULL;
	next = ovl_OvlTypeDecls;
	ovl_OvlTypeDecls = this;
	for (int i=0;i<IN_NUMKEYS;i++)
	{
		for (int k=0;k<8;k++)
			bindconfig.keyBindings[i][k][0] = 0;
	}
}

COvlTypeDecl::~COvlTypeDecl()
{
}

//****************************************************************************
//**
//**    CLASS overlay_t
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Public Construction
//----------------------------------------------------------------------------
overlay_t::overlay_t(overlay_t *parentwindow) // used only for dummy nodes
{
	if ((!parentwindow) && (ovl_Windows))
		SYS_Error("overlay_t: Dummy node created without parent");
	pos.Seti(0, 0, 0);
	//dim.Set(vid->res.width, vid->res.height, 0);
	dim.Seti(640, 480, 0);
	vpos = pos;
	vmin.Seti(0, 0, 0);
	vmax = dim;
	proportionRatio = dim.y/dim.x;
	name[0] = 0;
	iregion = OVLREGION_BODY;
	parent = parentwindow;
	typedecl = NULL;
	flags = OVLF_DUMMY|OVLF_NODRAW|OVLF_NOINPUT;
	next = prev = this;
	if (parentwindow)
		parentwindow->children = this;
	children = NULL;
	OVL_SetRedraw(this, true);
}

overlay_t::overlay_t(COvlTypeDecl *decl, overlay_t *parentwindow)
{
	typedecl = decl;
	flags = 0;
	pos.Seti(0, 0, 0);
	dim.Seti(320, 200, 0);
	vpos = pos;
	vmin.Seti(0, 0, 0);
	vmax = dim;
	proportionRatio = 200.0f/320.0f;
	name[0] = 0;
	next = prev = this;
	children = NULL;
	parent = parentwindow;
	iregion = OVLREGION_BODY;
	if (parent)
	{
		if (parent != (overlay_t *)-1) // used only by ovl_Windows
			parent->LinkChild(this);
		else
			parent = NULL;
		OVL_SetRedraw(this, true);
	}
	else
		flags |= OVLF_PROTOTYPE; // only prototypes don't have defined parents
}

overlay_t::~overlay_t()
{
	OVL_UnlockInput(this);
	if ((parent) && (!(flags & OVLF_DUMMY)))
		parent->UnlinkChild(this);
	while (children)
		delete children->next; // the last of the children's unlinking will delete the children dummy as well
}

overlay_t *overlay_t::Spawn(COvlTypeDecl *decl, overlay_t *parentwindow)
{
	return NULL; // overlay_t is abstract and cannot be spawned directly
}

void overlay_t::LinkChild(overlay_t *kid)
{
	overlay_t *ovl;

	if (!kid)
		return;
	if (kid->parent != this)
		SYS_Error("overlay_t::LinkChild: Attempted to link to unconnected parent");
	if (kid->flags & OVLF_DUMMY)
		SYS_Error("overlay_t::LinkChild: Attempted to link a dummy node");
	if (!children)
	{
		ovl = new overlay_t(this); // will auto-set as children
		if (!ovl)
			SYS_Error("overlay_t::LinkChild: Out of memory for child dummy node");
	}
	kid->prev = children;
	kid->next = children->next;
	kid->prev->next = kid;
	kid->next->prev = kid;
}

void overlay_t::UnlinkChild(overlay_t *kid)
{
	if (!kid)
		return;
	if (kid->parent != this)
		SYS_Error("overlay_t::UnlinkChild: Attempted to unlink from unconnected parent");
	if (kid->flags & OVLF_DUMMY)
		SYS_Error("overlay_t::LinkChild: Attempted to unlink a dummy node");
	if (kid == ovl_focusOverlay)
	{
		overlay_t *ovl;
		for (ovl=kid->next; (ovl != kid) && (ovl->flags&(OVLF_DUMMY|OVLF_NOINPUT|OVLF_NODRAW|OVLF_NOFOCUS)); ovl=ovl->next)
			;
		if (ovl == kid)
			ovl_focusOverlay = this;
		else
			ovl_focusOverlay = ovl;
	}
	kid->next->prev = kid->prev;
	kid->prev->next = kid->next;
	if (children->next == children)
	{
		delete children;
		children = NULL;
	}
}

void overlay_t::OnLoad()
{
}

void overlay_t::OnSave()
{
}

void overlay_t::OnResize()
{
}

void overlay_t::OnCalcLogicalDim(int dx, int dy)
{
	int minx, miny, maxx, maxy;
	if (!children)
	{
		vmin = vmax = vpos;
		return;
	}
	minx = maxx = (int)vpos.x;
	miny = maxy = (int)vpos.y;
	//maxx += dx;
	//maxy += dy;
	for (overlay_t *child = children->prev; child != children; child = child->prev)
	{	
		if (child->flags & (OVLF_VIEWABSOLUTE|OVLF_NODRAW))
			continue;
		if (child->pos.x < minx)
			minx = (int)(child->pos.x);
		if (child->pos.y < miny)
			miny = (int)(child->pos.y);
		if ((child->pos.x + child->dim.x) > maxx)
			maxx = (int)(child->pos.x + child->dim.x);
		if (!(child->flags & OVLF_MINIMIZED))
		{
			if ((child->pos.y + child->dim.y) > maxy)
				maxy = (int)(child->pos.y + child->dim.y);
		}
		else
		{
			if ((child->pos.y + 12+3+3) > maxy)
				maxy = (int)(child->pos.y + 12+3+3);
		}
	}
	vmin.Seti(minx, miny, 0);
	vmax.Seti(maxx, maxy, 0);
}

void overlay_t::OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox)
{
}

U32 overlay_t::OnMouseMove(inputevent_t *event)
{
	return(0);
}

U32 overlay_t::OnPress(inputevent_t *event)
{
	return(0);
}

U32 overlay_t::OnDrag(inputevent_t *event)
{
	return(0);
}

U32 overlay_t::OnRelease(inputevent_t *event)
{
	return(0);
}

U32 overlay_t::OnPressCommand(int argNum, CC8 **argList)
{
	return(0);
}

U32 overlay_t::OnDragCommand(int argNum, CC8 **argList)
{
	return(0);
}

U32 overlay_t::OnReleaseCommand(int argNum, CC8 **argList)
{
	return(0);
}

U32 overlay_t::OnMessage(ovlmsg_t *msg)
{
	return(0);
}

U32 overlay_t::OnDragDrop(overlay_t *dropovl)
{
	return(0);
}

//----------------------------------------------------------------------------
//    Public Methods
//----------------------------------------------------------------------------
//****************************************************************************
//**
//**    END CLASS overlay_t
//**
//****************************************************************************

//****************************************************************************
//**
//**    END MODULE OVL_MAN.CPP
//**
//****************************************************************************

