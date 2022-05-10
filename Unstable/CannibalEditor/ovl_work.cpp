//****************************************************************************
//**
//**    OVL_WORK.CPP
//**    Overlays - Workspace
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include <windows.h>
#include <windowsx.h>

#include "cbl_defs.h"
#include "ovl_defs.h"
#include "ovl_work.h"
#include "ovl_skin.h"
#include "ovl_frm.h"
#include "ovl_seq.h"
#include "file_imp.h"

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
int OVL_WriteBMP16(char *filename, word *data, int width, int height)
{
	BITMAPFILEHEADER fhdr;
	BITMAPINFOHEADER ihdr;
	FILE *fp;
	int i, k, r, g, b, val;
	char filebuf[_MAX_PATH];
	
	strcpy(filebuf, filename);
	SYS_ForceFileExtention(filebuf, "BMP");
	fp = fopen(filebuf, "wb");
	if (!fp)
		return(0);
	fhdr.bfType = 0x4D42; // BM
	fhdr.bfSize = 0; // recalc
	fhdr.bfReserved1 = fhdr.bfReserved2 = 0;
	fhdr.bfOffBits = 0; // recalc
	SYS_SafeWrite(&fhdr, sizeof(BITMAPFILEHEADER), 1, fp);
	ihdr.biSize = sizeof(BITMAPINFOHEADER);
	ihdr.biWidth = width;
	ihdr.biHeight = height;
	ihdr.biPlanes = 1;
	ihdr.biBitCount = 24;
	ihdr.biCompression = BI_RGB;
	ihdr.biSizeImage = width*height*3;
	ihdr.biXPelsPerMeter = 0;
	ihdr.biYPelsPerMeter = 0;
	ihdr.biClrUsed = 0;
	ihdr.biClrImportant = 0;
	SYS_SafeWrite(&ihdr, sizeof(BITMAPINFOHEADER), 1, fp);
	fhdr.bfOffBits = ftell(fp);
	for (i=height-1;i>=0;i--)
	{
		for (k=0;k<width;k++)
		{
			val = data[i*width+k];
			r = (val >> 10) & 31; g = (val >> 5) & 31; b = val & 31;
			r <<= 3; g <<= 3; b <<= 3;
			SYS_SafeWrite(&b, 1, 1, fp);
			SYS_SafeWrite(&g, 1, 1, fp);
			SYS_SafeWrite(&r, 1, 1, fp);
		}
	}

	fhdr.bfSize = ftell(fp);
	fseek(fp, 0, SEEK_SET);
	SYS_SafeWrite(&fhdr, sizeof(BITMAPFILEHEADER), 1, fp);
	fclose(fp);
	return(1);
}

CONFUNC(SaveProject, NULL, 0)
{
	char *str;
	OWorkspace *ws;

	str = argList[1];
	if (argNum < 2)
	{
		if (!(str = SYS_SaveFileBox("Duke Nukem Extended Model (*.mdx)\0*.mdx\0\0", "Save MDX", "mdx")))
			return;
	}
	ws = (OWorkspace *)ovl_Windows;
	strcpy(ws->mdxName, str);
	ws->mdx->SaveMDX(str);
	return;
}

CONFUNC(LoadProject, NULL, 0)
{
	char *str;
	int i;
	modelFrame_t *f;
	int sChanged=0, fChanged=0;
	OWorkspace *ws;
	
	str = argList[1];
	if (argNum < 2)
	{
		if (!(str = SYS_OpenFileBox("Duke Nukem Extended Model (*.mdx)\0*.mdx\0\0", "Open MDX", "mdx")))
			return;
	}
	ws = (OWorkspace *)ovl_Windows;
	for (i=0;i<WS_MAXSKINS;i++)
	{
		if (ws->mdx->skins[i].flags & MRF_INUSE & MRF_MODIFIED)
			sChanged++;
	}
	MRL_ITERATENEXT(f,f,ws->mdx->frames)
	{
		if (f->flags & MRF_MODIFIED)
			fChanged++;
	}
	if (sChanged || fChanged)
	{
		if (sChanged && fChanged)
		{
			if (SYS_MessageBox("Are you sure?", MB_YESNO,
				"You have unsaved changes to %d skins and %d frames.  Are you sure you want to load a new model?",
				sChanged, fChanged) != IDYES)
				return;
		}
		else if (sChanged)
		{
			if (SYS_MessageBox("Are you sure?", MB_YESNO,
				"You have unsaved changes to %d skins.  Are you sure you want to load a new model?", sChanged) != IDYES)
				return;
		}
		else if (fChanged)
		{
			if (SYS_MessageBox("Are you sure?", MB_YESNO,
				"You have unsaved changes to %d frames.  Are you sure you want to load a new model?", fChanged) != IDYES)
				return;
		}
	}
	delete ws->mdx;
	ws->InitModel();
	if (ws->mdx->LoadMDX(str, true))
	{
		ws = (OWorkspace *)ovl_Windows; // ws might have changed with the load
		strcpy(ws->mdxName, str);
		ws->mdx->ws = ws;
	}
	return;
}

//----------------------------------------------------------------------------
//    Public Code
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Class Member Code
//----------------------------------------------------------------------------
///////////////////////////////////////////
////    OWorkspace
///////////////////////////////////////////

REGISTEROVLTYPE(OWorkspace, OToolWindow);

void OWorkspace::InitModel()
{
	mdx = new model_t();
	mdx->ws = this;
}

OWorkspace::~OWorkspace()
{
	if (mdx)
		delete mdx;
}

void OWorkspace::CloseFrameReferences(modelFrame_t *f)
{
	OFrameView *kid;

	kid = NULL;
	while (kid = (OFrameView *)OVL_FindChild(this, kid, "OFrameView", NULL))
	{
		if (kid->frame == f)
		{
			kid->flags |= OVLF_TAGDESTROY;
			kid->frame = NULL;
		}
	}
}

void OWorkspace::CloseSkinReferences(modelSkin_t *sk)
{
	OSkinView *kid;

	kid = NULL;
	while (kid = (OSkinView *)OVL_FindChild(this, kid, "OSkinView", NULL))
	{
		if (kid->skin == sk)
		{
			kid->flags |= OVLF_TAGDESTROY;
			kid->skin = NULL;
		}
	}
}

void OWorkspace::CloseSequenceReferences(modelSequence_t *s)
{
	OSequence *kid;

	kid = NULL;
	while (kid = (OSequence *)OVL_FindChild(this, kid, "OSequence", NULL))
	{
		if (kid->seq == s)
		{
			kid->flags |= OVLF_TAGDESTROY;
			kid->seq = NULL;
		}
	}
}

modelFrame_t *OWorkspace::GetTopmostFrame()
{
	if (!children)
		return(NULL);
	for (overlay_t *child=children->next;child!=children;child=child->next)
	{
		if (OVL_IsOverlayType(child, "OFrameView"))
			return(((OFrameView *)child)->frame);
	}
	return(NULL);
}

modelSequence_t *OWorkspace::GetTopmostSequence()
{
	if (!children)
		return(NULL);
	for (overlay_t *child=children->next;child!=children;child=child->next)
	{
		if (OVL_IsOverlayType(child, "OSequence"))
			return(((OSequence *)child)->seq);
	}
	return(NULL);
}

void OWorkspace::OnSave()
{
	Super::OnSave();
	VCR_EnlargeActionDataBuffer(128);
	VCR_WriteString(mdxName);
    for (int i=0;i<4;i++)
    {
        VCR_WriteFloat(vposBackup[i].x);
        VCR_WriteFloat(vposBackup[i].y);
        VCR_WriteFloat(vposBackup[i].z);
    }
}

void OWorkspace::OnLoad()
{
	Super::OnLoad();
	strcpy(mdxName, VCR_ReadString());
    for (int i=0;i<4;i++)
    {
        vposBackup[i].x = VCR_ReadFloat();
        vposBackup[i].y = VCR_ReadFloat();
        vposBackup[i].z = VCR_ReadFloat();
    }
}

/*
void OWorkspace::OnResize()
{
}
*/

void OWorkspace::OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox)
{
	Super::OnDraw(sx, sy, dx, dy, clipbox);
	if (!resourcesOvl)
	{
		if (!(resourcesOvl = OVL_FindChild(this, NULL, "OWorkResources", NULL)))
			resourcesOvl = OVL_CreateOverlay("OWorkResources", "Resources", this, 20, 50, 300, 400, OVLF_NOTITLEDESTROY|OVLF_NOFOCUS, false);
	}
}

/*
boolean OWorkspace::OnPress(inputevent_t *event)
{
}
*/

/*
boolean OWorkspace::OnDrag(inputevent_t *event)
{
}
*/

/*
boolean OWorkspace::OnRelease(inputevent_t *event)
{
}
*/

boolean OWorkspace::OnPressCommand(int argNum, char **argList)
{
	OVLCMDSTART

//-------------------- OPEN -------------------------	
	OVLCMD("ws_open_skin")
	{
		int i;
		VidTex *tex;
		char *str;

		if (argNum < 2)
			return(1);
		i = atoi(argList[1]);
		str = argList[2];
		if (argNum < 3)
		{
			if (!(str = SYS_OpenFileBox("Image Files (*.bmp,*.tga)\0" "*.bmp;*.tga\0" "24-bit Bitmap Files (*.bmp)\0" "*.bmp\0" "32-bit Targa Files (*.tga)\0" "*.tga\0\0", "Open Skin",null)))
				return(1);
		}
		U32 ext=SYS_GetImageExtension(str);
		switch(ext)
		{
			case SYS_IMAGE_TYPE_BMP:
				tex = vid.TexLoadBMP(str, false);
				break;
			case SYS_IMAGE_TYPE_TGA:
				tex = vid.TexLoadTGA(str, false);
				break;
		}
		if (tex)
		{
			mdx->skins[i].tex = tex;
			strcpy(mdx->skins[i].name, str);
			mdx->skins[i].flags = MRF_INUSE;
		}
		else
			SYS_Error("Unable to load image");

		return(1);
	}

	OVLCMD("ws_open_frames")
	{
		char *str;

		if (argNum == 1)
		{
			if (!SYS_OpenFileBoxMulti(	"3D Studio Mesh (*.3ds)\0*.3ds\0"
										"Quake Model (*.mdl)\0*.mdl\0"
										"Quake2 Model (*.md2)\0*.md2\0"
										"Lightwave Object (*.lwo)\0*.lwo\0"
										"Generic Mesh Animation (*.gma)\0*.gma\0"
                                        "DNF Unreal Mesh Export (*.mxb)\0*.mxb\0"
										"\0", "Open frames", "3ds"))
				return(1);
			while (str = SYS_NextMultiFile())
			{
				mdx->ImportFrames(str, false);
			}
		}
		else
		{
			for (int i=0;i<(argNum-1);i++)
			{
				mdx->ImportFrames(argList[i+1], false);
			}
		}
		return(1);
	}

	OVLCMD("ws_open_frames_restart")
	{
		char *str;

		if (argNum == 1)
		{
			if (!SYS_OpenFileBoxMulti(	"3D Studio Mesh (*.3ds)\0*.3ds\0"
										"Quake Model (*.mdl)\0*.mdl\0"
										"Quake2 Model (*.md2)\0*.md2\0"
										"Lightwave Object (*.lwo)\0*.lwo\0"
										"Generic Mesh Animation (*.gma)\0*.gma\0"
                                        "DNF Unreal Mesh Export (*.mxb)\0*.mxb\0"
										"\0", "Open frames", "3ds"))
				return(1);
			while (str = SYS_NextMultiFile())
			{
				mdx->ImportFrames(str, true);
			}
		}
		else
		{
			for (int i=0;i<(argNum-1);i++)
			{
				mdx->ImportFrames(argList[i+1], true);
			}
		}
		return(1);
	}

	OVLCMD("ws_open_mrg")
	{
		char *str;
		FILE *fp;

		if (argNum == 1)
		{
			if (!(str = SYS_OpenFileBox("MRGPlay Data (*.mrp)\0*.mrp\0"
										"\0", "Open MRG Data", "mrp")))
				return(1);
		}
		else
			str = argList[1];

		if (mdx->lodData)
			FREE(mdx->lodData);
		fp = fopen(str, "rb");
		if (!fp)
			return(1);
		fseek(fp, 0, SEEK_END);
		mdx->lodDataSize = ftell(fp);
		fseek(fp, 0, SEEK_SET);
		mdx->lodData = ALLOC(byte, mdx->lodDataSize);
		SYS_SafeRead(mdx->lodData, 1, mdx->lodDataSize, fp);
		fclose(fp);
		mdx->lodActive = true;
	}

//-------------------- NEW --------------------------	

	OVLCMD("ws_new_skin")
	{
		char *str;
		int width=0, height=0;
		VidTex *tex;
		int i;

		if (argNum < 2)
			return(1);
		i = atoi(argList[1]);
		while ((width <= 0) || (width > 256))
		{
			if (!(str = SYS_InputBox("Create Skin", "256", "Please specify the WIDTH of the new skin, between 16 and 256")))
				return(1);
			width = atoi(str);
		}
		while ((height <= 0) || (height > 256))
		{
			if (!(str = SYS_InputBox("Create Skin", "256", "Please specify the HEIGHT of the new skin, between 16 and 256")))
				return(1);
			height = atoi(str);
		}
		if (!(str = SYS_SaveFileBox("24-bit Bitmap Files (*.bmp)\0*.bmp\0\0", "Create Skin - Choose a filename", "bmp")))
			return(1);
		word *wtemp = ALLOC(word, width*height);
		memset(wtemp, 0, width*height*sizeof(word));
		OVL_WriteBMP16(str, wtemp, width, height);
		FREE(wtemp);
		tex = vid.TexLoadBMP(str, false);
		if (tex)
		{
			mdx->skins[i].tex = tex;
			strcpy(mdx->skins[i].name, str);
			mdx->skins[i].flags = MRF_INUSE;
		}
		return(1);
	}

	OVLCMD("ws_new_seq")
	{
		modelSequence_t *s;

		if (argNum < 2)
		{
			OVL_InputBox("New Sequence", "What will you name this new sequence?", this, "ws_new_seq", "Unnamed");
			return(1);
		}
		s = mdx->AddSequence();
		strcpy(s->name, argList[1]);
		return(1);
	}

//-------------------- SAVE -------------------------	
	
	OVLCMD("ws_save_skin")
	{
		int i;

		if (argNum < 2)
			return(1);
		i = atoi(argList[1]);
		if (!(mdx->skins[i].flags & MRF_INUSE))
			return(1);
		if (SYS_MessageBox("Save Skin", MB_YESNO, "Are you sure you want to save this skin?") != IDYES)
			return(1);
		OVL_WriteBMP16(mdx->skins[i].name, (U16 *)mdx->skins[i].tex->tex_data, mdx->skins[i].tex->width, mdx->skins[i].tex->height);
		mdx->skins[i].flags &= ~MRF_MODIFIED;
		return(1);
	}

//------------------- SAVEAS ------------------------	
	
	OVLCMD("ws_saveas_skin")
	{
		int i;
		char *str;

		if (argNum < 2)
			return(1);
		i = atoi(argList[1]);
		if (!(mdx->skins[i].flags & MRF_INUSE))
			return(1);
		str = argList[2];
		if (argNum < 3)
		{
			if (!(str = SYS_SaveFileBox("24-bit Bitmap Files (*.bmp)\0*.bmp\0\0", "Save Skin As...", "bmp")))
				return(1);
		}
		strcpy(mdx->skins[i].name, str);
		OVL_WriteBMP16(mdx->skins[i].name, (U16 *)mdx->skins[i].tex->tex_data, mdx->skins[i].tex->width, mdx->skins[i].tex->height);
		mdx->skins[i].flags &= ~MRF_MODIFIED;
		return(1);
	}

//-------------------- DELETE -------------------------	
	
	OVLCMD("ws_delete_skin")
	{
		int i;

		if (argNum < 2)
			return(1);
		i = atoi(argList[1]);
		if (!(mdx->skins[i].flags & MRF_INUSE))
			return(1);
		if (mdx->skins[i].flags & MRF_MODIFIED)
		{
			if (SYS_MessageBox("Are you sure?", MB_YESNO,
				"You have not saved your changes to this skin.  Are you sure you want to delete it from the workspace?") != IDYES)
				return(1);
		}
		mdx->DeleteSkin(&mdx->skins[i]);
		return(1);
	}
	OVLCMD("ws_delete_frame")
	{
		modelFrame_t *f;
		int index;

		if (argNum < 2)
			return(1);
		index = atoi(argList[1]);
		f = mdx->frames.Index(index);
		if (!f)
			return(1);
		if (f->flags & MRF_MODIFIED)
		{
			if (SYS_MessageBox("Are you sure?", MB_YESNO,
				"You have not saved your changes to this frame.  Are you sure you want to delete it from the workspace?") != IDYES)
				return(1);
		}
		mdx->DeleteFrame(f);
		return(1);
	}
	OVLCMD("ws_delete_seq")
	{
		modelSequence_t *s;
		int index;

		if (argNum < 2)
			return(1);
		index = atoi(argList[1]);
		s = mdx->seqs.Index(index);
		if (!s)
			return(1);
		if (s->flags & MRF_MODIFIED)
		{
			if (SYS_MessageBox("Are you sure?", MB_YESNO,
				"You have not saved your changes to this sequence.  Are you sure you want to delete it from the workspace?") != IDYES)
				return(1);
		}
		mdx->DeleteSequence(s);
		return(1);
	}
	OVLCMD("ws_rename_frame")
	{
		modelFrame_t *f, *f2;
		OFrameView *kid;
		int index;

		if (argNum < 3)
			return(1);
		index = atoi(argList[1]);
		f = mdx->frames.Index(index);
		if (!f)
			return(1);
        MRL_ITERATENEXT(f2,f2,mdx->frames)
        {
            if (!_stricmp(f2->name, argList[2]))
                return(1); // already something of that name
        }
		strcpy(f->name, argList[2]);
		kid = NULL;
		while (kid = (OFrameView *)OVL_FindChild(this, kid, "OFrameView", NULL))
		{
			if (kid->frame == f)
			{
				strcpy(kid->name, argList[2]);
			}
		}
		mdx->frames.Sort(&model_t::DeleteFrame);
		return(1);
	}
	OVLCMD("ws_rename_seq")
	{
		modelSequence_t *s, *s2;
		OSequence *kid;
		int index;

		if (argNum < 3)
			return(1);
		index = atoi(argList[1]);
		s = mdx->seqs.Index(index);
		if (!s)
			return(1);
		MRL_ITERATENEXT(s2,s2,mdx->seqs)
        {
            if (!_stricmp(s2->name, argList[2]))
                return(1); // already something of that name
        }
		strcpy(s->name, argList[2]);
		kid = NULL;
		while (kid = (OSequence *)OVL_FindChild(this, kid, "OSequence", NULL))
		{
			if (kid->seq == s)
			{
				strcpy(kid->name, argList[2]);
			}
		}
		mdx->seqs.Sort(&model_t::DeleteSequence);
		return(1);
	}

//-------------------- SPAWN ------------------------	

	OVLCMD("ws_spawnwindow_skin")
	{
		OSkinView *kid;
		modelSkin_t *skin;
		int i;

		skin = NULL;
		if (argNum < 2)
		{
			for (i=0;i<WS_MAXSKINS;i++)
			{
				if (!(mdx->skins[i].flags & MRF_INUSE))
				{
					skin = &mdx->skins[i];
					break;
				}
			}
		}
		else
		{
			skin = &mdx->skins[atoi(argList[1])];
		}
		if ((!skin) || (!(skin->flags & MRF_INUSE)))
			return(1);
		kid = (OSkinView *)OVL_CreateOverlay("OSkinView", "noname00.bmp", this, 0, 0, 128+6, 128+6+12,
			OVLF_PROPORTIONAL|OVLF_NODRAGDROP, true);
		kid->camera.SetPosition(0, 0, 256);
		kid->camera.SetTarget(0, 0, 0);
		kid->camera.SetViewVolume(vid.resolution->width, vid.resolution->height, 4, 1024);
		kid->camera.SetFOV(vid.resolution->width, vid.resolution->height);
		kid->skin = skin;		
		strcpy(kid->name, SYS_GetFileRoot(kid->skin->name));
		kid->dim.x = kid->skin->tex->width+6;
		kid->dim.y = kid->skin->tex->width+6+12;
		if (kid->dim.x < 64)
			kid->dim.x = 64+6;
		if (kid->dim.y < 64)
			kid->dim.y = 64+6+12;
		kid->proportionRatio = kid->dim.y / kid->dim.x;
		if (kid->skin->tex->width >= kid->skin->tex->height)
			kid->camera.SetPosition(0, 0, kid->skin->tex->width);
		else
			kid->camera.SetPosition(0, 0, kid->skin->tex->height);
		return(1);
	}
	OVLCMD("ws_spawnwindow_frame")
	{
		OFrameView *kid;
		modelFrame_t *f;
		int k;

		if ((!mdx->frames.Count()) || (!mdx->mesh.numTris))
			return(1);
		if (argNum < 2)
			f = mdx->frames.First();
		else
		{
			k = atoi(argList[1]);
			f = mdx->frames.Index(k);
			if (!f)
				return(1);
		}

		kid = (OFrameView *)OVL_CreateOverlay("OFrameView", "UnnamedFrame", this, 0, 0, 300+6, 300+6+12,
			OVLF_NODRAGDROP, true);
		kid->camera.SetPosition(0, 0, 128);
		kid->camera.SetTarget(0, 0, 0);
		kid->camera.SetViewVolume(vid.resolution->width, vid.resolution->height, 2, 1024);
		
		kid->mesh = &mdx->mesh;
		kid->frame = f;
		strcpy(kid->name, kid->frame->name);
		return(1);
	}
	OVLCMD("ws_spawnwindow_seq")
	{
		OSequence *kid;
		modelSequence_t *s;
		int k;

		if (!mdx->seqs.Count())
			return(1);
		if (argNum < 2)
			s = mdx->seqs.First();
		else
		{
			k = atoi(argList[1]);
			s = mdx->seqs.Index(k);
			if (!s)
				return(1);
		}

		kid = (OSequence *)OVL_CreateOverlay("OSequence", "UnnamedSeq", this, 40, 40, 340+6, 120+6+12,
			OVLF_NODRAGDROP, true);
		
		kid->seq = s;
		strcpy(kid->name, kid->seq->name);
		return(1);
	}

    return(Super::OnPressCommand(argNum, argList));
}

CONFUNC(ws_vpos_save, NULL, 0)
{
    if (argNum < 2)
        return;
    int i = atoi(argList[1]);
    if ((!i) || (i>4))
        return;
    OWorkspace* ws = (OWorkspace*)ovl_Windows;
    ws->vposBackup[i-1].x = ws->vpos.x;
    ws->vposBackup[i-1].y = ws->vpos.y;
}

CONFUNC(ws_vpos_load, NULL, 0)
{
    if (argNum < 2)
        return;
    int i = atoi(argList[1]);
    if ((!i) || (i>4))
        return;
    OWorkspace* ws = (OWorkspace*)ovl_Windows;
    ws->vpos.x = ws->vposBackup[i-1].x;
    ws->vpos.y = ws->vposBackup[i-1].y;
    return;
}

/*
boolean OWorkspace::OnDragCommand(int argNum, char **argList)
{
}
*/

/*
boolean OWorkspace::OnReleaseCommand(int argNum, char **argList)
{
}
*/

/*
boolean OWorkspace::OnMessage(ovlmsg_t *msg)
{
}
*/

boolean OWorkspace::OnDragDrop(overlay_t *dropovl)
{
	if ((!dropovl) || (!dropovl->parent))
		return(1);
	if (dropovl->flags & OVLF_NODRAGDROP)
		return(1);
	for (overlay_t *pcheck = this; (pcheck) && (pcheck != dropovl); pcheck = pcheck->parent)
		;
	if (pcheck != dropovl)
	{
		dropovl->parent->UnlinkChild(dropovl);
		dropovl->parent = this;
		LinkChild(dropovl);
		dropovl->pos = vpos;
		OVL_SetTopmost(dropovl);
	}
	//return(Super::OnDragDrop(dropovl));
	return(1);
}

///////////////////////////////////////////
////    OWorkResources
///////////////////////////////////////////

REGISTEROVLTYPE(OWorkResources, OWindow);

/*
void OWorkResources::OnSave()
{
}
*/

/*
void OWorkResources::OnLoad()
{
}
*/

/*
void OWorkResources::OnResize()
{
}
*/

void OWorkResources::OnCalcLogicalDim(int dx, int dy)
{	
	Super::OnCalcLogicalDim(dx, dy);
	if (mode == WRM_SKINS)
		return;
	if ((mode == WRM_FRAMES) && (ws->mdx->frames.Count()))
	{
		if (vpos.y > (ws->mdx->frames.Count()*12+32-dim.y))
			vpos.y = (ws->mdx->frames.Count()*12+32-dim.y);
		if (vpos.y < 0)
			vpos.y = 0;
		vmax.y = ws->mdx->frames.Count()*12+18;
		vmin.y = 0;
	}
	else
	if ((mode == WRM_SEQUENCES) && (ws->mdx->seqs.Count()))
	{
		if (vpos.y > (ws->mdx->seqs.Count()*12+32-dim.y))
			vpos.y = (ws->mdx->seqs.Count()*12+32-dim.y);
		if (vpos.y < 0)
			vpos.y = 0;
		vmax.y = ws->mdx->seqs.Count()*12+18;
		vmin.y = 0;
	}
}

static char *wrmNames[WRM_NUMTYPES] =
{ "General", "Skins", "Frames", "Sequences" };

void OWorkResources::OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox)
{
	vector_t p[4], tv[4];
	int i, modeWidth;
	static char tbuffer[64];

	Super::OnDraw(sx, sy, dx, dy, clipbox);
	strcpy(name, "Resources");
	if (ws->mdxName[0])
		sprintf(name+9, "- %s", ws->mdxName);
//	vid.ClipWindow(sx, sy, sx+dx, sy+dy);
	if (!OVL_ClipToBoxLimits(sx, sy, sx+dx, sy+dy, clipbox))
		return;

	// mode bar
	vid.ColorMode(VCM_FLAT);
	vid.FlatColor(255, 255, 255);
	p[0].Set(sx, sy+10, 0);
	p[1].Set(sx+dx, sy+10, 0);
	vid.DrawLine(&p[0], &p[1], NULL, NULL, false);
	modeWidth = dx / WRM_NUMTYPES;
	for (i=1;i<WRM_NUMTYPES;i++)
	{
		p[0].Set(sx+modeWidth*i, sy, 0);
		p[1].Set(sx+modeWidth*i, sy+10, 0);
		vid.DrawLine(&p[0], &p[1], NULL, NULL, false);
	}
	for (i=0;i<WRM_NUMTYPES;i++)
	{
		int tsize;

		if (i == (int)mode)
		{
			p[0].Set(sx+i*modeWidth, sy, 0);
			p[2].Set(sx+i*modeWidth+modeWidth-1, sy+9, 0);
			p[1].Set(p[2].x, p[0].y, 0);
			p[3].Set(p[0].x, p[2].y, 0);
			vid.ColorMode(VCM_FLAT);
			vid.FlatColor(128, 0, 0);
			vid.DrawPolygon(4, p, NULL, NULL, NULL, false);
		}
		tsize = (modeWidth-4) / strlen(wrmNames[i]);
		if (tsize > 8)
			tsize = 8;
		vid.DrawString(sx+i*modeWidth+2, sy+1, tsize, tsize, wrmNames[i], true, 128, 128, 128);
	}
	
	sy += 11;

	if (mode == WRM_SKINS)
	{
		int w, h;

		tv[0].Set(0,0,0);
		tv[1].Set(255,0,0);
		tv[2].Set(255,255,0);
		tv[3].Set(0,255,0);
		for (i=0;i<WS_MAXSKINS;i++)
		{
			if (ws->mdx->skins[i].flags & MRF_SELECTED)
			{
				p[0].Set(sx, sy+i*12, 0);
				p[2].Set(sx+dx, sy+i*12+11, 0);
				p[1].Set(p[2].x, p[0].y, 0);
				p[3].Set(p[0].x, p[2].y, 0);
				vid.ColorMode(VCM_FLAT);
				vid.FlatColor(0, 0, 128);
				vid.DrawPolygon(4, p, NULL, NULL, NULL, false);

				// file management buttons
				vid.ColorMode(VCM_TEXTURE);
				vid.FilterMode(VFM_BILINEAR);
				p[0].Set(sx, sy+i*12, 0);
				p[2].Set(sx+11, sy+i*12+11, 0);
				p[1].Set(p[2].x, p[0].y, 0);
				p[3].Set(p[0].x, p[2].y, 0);

				vid.TexActivate(IN_GetButtonTex("skin"), VTA_NORMAL);
				vid.DrawPolygon(4, p, NULL, NULL, tv, false);
				p[0].x+=18; p[1].x+=18; p[2].x+=18; p[3].x+=18;
				vid.TexActivate(IN_GetButtonTex("delete"), VTA_NORMAL);
				vid.DrawPolygon(4, p, NULL, NULL, tv, false);
				p[0].x+=12; p[1].x+=12; p[2].x+=12; p[3].x+=12;
				vid.TexActivate(IN_GetButtonTex("new"), VTA_NORMAL);
				vid.DrawPolygon(4, p, NULL, NULL, tv, false);
				p[0].x+=12; p[1].x+=12; p[2].x+=12; p[3].x+=12;
				vid.TexActivate(IN_GetButtonTex("open"), VTA_NORMAL);
				vid.DrawPolygon(4, p, NULL, NULL, tv, false);
				p[0].x+=12; p[1].x+=12; p[2].x+=12; p[3].x+=12;
				vid.TexActivate(IN_GetButtonTex("save"), VTA_NORMAL);
				vid.DrawPolygon(4, p, NULL, NULL, tv, false);
				p[0].x+=12; p[1].x+=12; p[2].x+=12; p[3].x+=12;
				vid.TexActivate(IN_GetButtonTex("saveas"), VTA_NORMAL);
				vid.DrawPolygon(4, p, NULL, NULL, tv, false);

				// resolution
				w = h = 0;
				if (ws->mdx->skins[i].flags & MRF_INUSE)
				{
					w = ws->mdx->skins[i].tex->width;
					h = ws->mdx->skins[i].tex->height;
				}
				sprintf(tbuffer, "%d", w);
				vid.DrawString(sx+82, sy+i*12, 6, 6, tbuffer, false, 128, 128, 128);
				sprintf(tbuffer, "%d", h);
				vid.DrawString(sx+82, sy+i*12+6, 6, 6, tbuffer, false, 128, 128, 128);				
			}
			// name
			if (ws->mdx->skins[i].flags & MRF_INUSE)
			{
				vid.DrawString(sx+122, sy+i*12+2, 8, 8, ws->mdx->skins[i].name, true, 128, 128, 128);
				if (ws->mdx->skins[i].flags & MRF_MODIFIED)
					vid.DrawString(sx+110, sy+i*12+3, 6, 6, "*", true, 192, 0, 128);
			}
			else
				vid.DrawString(sx+122, sy+i*12+2, 8, 8, "- empty -", true, 128, 128, 128);
			p[0].Set(sx, sy+i*12+12, 0);
			p[1].Set(sx+dx, sy+i*12+12, 0);
			vid.ColorMode(VCM_FLAT);
			vid.FlatColor(255,255,255);
			vid.DrawLine(&p[0], &p[1], NULL, NULL, false);
		}
		vid.FilterMode(VFM_NONE);
	}
	else
	if (mode == WRM_FRAMES)
	{
		modelFrame_t *f;
		int adjy;

		if (!ws->mdx->frames.Count())
		{
			vpos.x = vpos.y = 0;
		}
		else
		{
			tv[0].Set(0,0,0);
			tv[1].Set(255,0,0);
			tv[2].Set(255,255,0);
			tv[3].Set(0,255,0);
			//vid.ClipWindow(sx, sy, sx+dx, sy+dy-11);
			OVL_ClipToBoxLimits(sx, sy, sx+dx, sy+dy-11, clipbox);
			adjy = vpos.y;
			if (adjy < 0)
				adjy = 0;
			if (adjy > (ws->mdx->frames.Count()-1)*12)
				adjy = (ws->mdx->frames.Count()-1)*12;
			i=0;
			MRL_ITERATENEXT(f,f,ws->mdx->frames)
			{
				if (((sy+i*12-adjy) < sy-12) || ((sy+i*12-adjy) > sy+dy))
				{
					i++;
					continue;
				}
				if (f->flags & MRF_SELECTED)
				{
					p[0].Set(sx, sy+i*12-adjy, 0);
					p[2].Set(sx+dx, sy+i*12-adjy+11, 0);
					p[1].Set(p[2].x, p[0].y, 0);
					p[3].Set(p[0].x, p[2].y, 0);
					vid.ColorMode(VCM_FLAT);
					vid.FlatColor(0, 0, 128);
					vid.DrawPolygon(4, p, NULL, NULL, NULL, false);

					vid.ColorMode(VCM_TEXTURE);
					vid.FilterMode(VFM_BILINEAR);
					p[0].Set(sx, sy+i*12-adjy, 0);
					p[2].Set(sx+11, sy+i*12-adjy+11, 0);
					p[1].Set(p[2].x, p[0].y, 0);
					p[3].Set(p[0].x, p[2].y, 0);
					vid.TexActivate(IN_GetButtonTex("frame"), VTA_NORMAL);
					vid.DrawPolygon(4, p, NULL, NULL, tv, false);
					p[0].x+=18; p[1].x+=18; p[2].x+=18; p[3].x+=18;
					vid.TexActivate(IN_GetButtonTex("delete"), VTA_NORMAL);
					vid.DrawPolygon(4, p, NULL, NULL, tv, false);
				}
				if (f == ws->mdx->refFrame)
					vid.DrawString(sx+34, sy+i*12-adjy+3, 6, 6, "R", true, 255, 0, 255);
				if (f->flags & MRF_COMPRESSED)
					vid.DrawString(sx+40, sy+i*12-adjy+3, 6, 6, "P", true, 255, 0, 255);
				if (f->flags & MRF_MODIFIED)
					vid.DrawString(sx+46, sy+i*12-adjy+3, 6, 6, "*", true, 255, 0, 255);
				vid.DrawString(sx+58, sy+i*12-adjy+2, 8, 8, f->name, true, 128, 128, 128);
				p[0].Set(sx, sy+i*12-adjy+12, 0);
				p[1].Set(sx+dx, sy+i*12-adjy+12, 0);
				vid.ColorMode(VCM_FLAT);
				vid.FlatColor(255,255,255);
				vid.DrawLine(&p[0], &p[1], NULL, NULL, false);
				i++;
			}
			vid.FilterMode(VFM_NONE);
		}
	}
	else
	if (mode == WRM_SEQUENCES)
	{
		modelSequence_t *s;
		int adjy;

		if (!ws->mdx->seqs.Count())
		{
			vpos.x = vpos.y = 0;
		}
		else
		{
			tv[0].Set(0,0,0);
			tv[1].Set(255,0,0);
			tv[2].Set(255,255,0);
			tv[3].Set(0,255,0);
			//vid.ClipWindow(sx, sy, sx+dx, sy+dy-11);
			OVL_ClipToBoxLimits(sx, sy, sx+dx, sy+dy-11, clipbox);
			adjy = vpos.y;
			if (adjy < 0)
				adjy = 0;
			if (adjy > (ws->mdx->seqs.Count()-1)*12)
				adjy = (ws->mdx->seqs.Count()-1)*12;
			i=0;
			MRL_ITERATENEXT(s,s,ws->mdx->seqs)
			{
				if (((sy+i*12-adjy) < sy-12) || ((sy+i*12-adjy) > sy+dy))
				{
					i++;
					continue;
				}
				if (s->flags & MRF_SELECTED)
				{
					p[0].Set(sx, sy+i*12-adjy, 0);
					p[2].Set(sx+dx, sy+i*12-adjy+11, 0);
					p[1].Set(p[2].x, p[0].y, 0);
					p[3].Set(p[0].x, p[2].y, 0);
					vid.ColorMode(VCM_FLAT);
					vid.FlatColor(0, 0, 128);
					vid.DrawPolygon(4, p, NULL, NULL, NULL, false);

					vid.ColorMode(VCM_TEXTURE);
					vid.FilterMode(VFM_BILINEAR);
					p[0].Set(sx, sy+i*12-adjy, 0);
					p[2].Set(sx+11, sy+i*12-adjy+11, 0);
					p[1].Set(p[2].x, p[0].y, 0);
					p[3].Set(p[0].x, p[2].y, 0);
					vid.TexActivate(IN_GetButtonTex("sequence"), VTA_NORMAL);
					vid.DrawPolygon(4, p, NULL, NULL, tv, false);
					p[0].x+=18; p[1].x+=18; p[2].x+=18; p[3].x+=18;
					vid.TexActivate(IN_GetButtonTex("delete"), VTA_NORMAL);
					vid.DrawPolygon(4, p, NULL, NULL, tv, false);
				}
				if (s->flags & MRF_MODIFIED)
					vid.DrawString(sx+46, sy+i*12-adjy+3, 6, 6, "*", true, 255, 0, 255);
				vid.DrawString(sx+58, sy+i*12-adjy+2, 8, 8, s->name, true, 128, 128, 128);
				p[0].Set(sx, sy+i*12-adjy+12, 0);
				p[1].Set(sx+dx, sy+i*12-adjy+12, 0);
				vid.ColorMode(VCM_FLAT);
				vid.FlatColor(255,255,255);
				vid.DrawLine(&p[0], &p[1], NULL, NULL, false);
				i++;
			}
			vid.FilterMode(VFM_NONE);
		}
	}
	else
	if (mode == WRM_GENERAL)
	{
		modelFrame_t *f;
		int tCompressed = 0, tNonCompressed = 0;
		int tmem = 0, tmemC = 0, tmemN = 0;

		//vid.ClipWindow(sx, sy, sx+dx, sy+dy-11);
		OVL_ClipToBoxLimits(sx, sy, sx+dx, sy+dy-11, clipbox);
		if (!ws->mdx->mesh.numTris)
		{
			vid.DrawString(sx+15, sy+11, 8, 8, "  Trimesh: None loaded", true, 128, 128, 128);
		}
		else
		{
			sprintf(tbuffer, "  Trimesh: %d Tris, %d Verts", ws->mdx->mesh.numTris, ws->mdx->mesh.numVerts);
			vid.DrawString(sx+15, sy+11, 8, 8, tbuffer, true, 128, 128, 128);
		}
		i = 0;
        MRL_ITERATENEXT(f,f,ws->mdx->frames)
		{
			if (f->flags & MRF_COMPRESSED)
			{
				tmem += f->frmdDataLen;
				tmemC += f->frmdDataLen;
				tCompressed++;
			}
			else
			{
				tmem += f->numVerts*sizeof(frameVert_t) + f->numTris*sizeof(baseTri_t);
				tmemN += f->numVerts*sizeof(frameVert_t) + f->numTris*sizeof(baseTri_t);
				tNonCompressed++;
			}
			i++;
		}
		sprintf(tbuffer, "  Frames: %d", i);
		vid.DrawString(sx+15, sy+23, 8, 8, tbuffer, true, 128, 128, 128);
		sprintf(tbuffer, "  Packed: %d", tCompressed);
		vid.DrawString(sx+31, sy+35, 8, 8, tbuffer, true, 128, 128, 128);
		sprintf(tbuffer, "  Unpacked: %d", tNonCompressed);
		vid.DrawString(sx+31, sy+47, 8, 8, tbuffer, true, 128, 128, 128);
		sprintf(tbuffer, "  Internal Frame Memory: %dk", tmem / 1024);
		vid.DrawString(sx+15, sy+59, 8, 8, tbuffer, true, 128, 128, 128);
		sprintf(tbuffer, "  Packed: %dk", tmemC / 1024);
		vid.DrawString(sx+31, sy+71, 8, 8, tbuffer, true, 128, 128, 128);
		sprintf(tbuffer, "  Unpacked: %dk", tmemN / 1024);
		vid.DrawString(sx+31, sy+83, 8, 8, tbuffer, true, 128, 128, 128);
		if (ws->mdx->refFrame)
		{
			frameVert_t *frameVerts = ws->mdx->refFrame->GetVerts();
			if (frameVerts)
			{
				int lockedVerts = 0;
				for (i=0;i<ws->mdx->mesh.numVerts;i++)
				{
					if (frameVerts[i].flags & FVF_P_LODLOCKED)
						lockedVerts++;
				}
				sprintf(tbuffer, "  Locked Verts: %d", lockedVerts);
				vid.DrawString(sx+15, sy+95, 8, 8, tbuffer, true, 128, 128, 128);
			}
		}
	}	
}

boolean OWorkResources::OnPress(inputevent_t *event)
{
	int i, k;
	modelFrame_t *f, *f2;
	modelSequence_t *s, *s2;
	modelSkin_t *skin;
	char tbuffer[128];

	if ((event->mouseY <= 10) && (event->key == KEY_MOUSELEFT))
	{
		int modeWidth;
		
		modeWidth = (dim.x-6) / WRM_NUMTYPES;
		mode = (workResourceModeType_t)(event->mouseX / modeWidth);
		OVL_SendPressCommand(this->parent, "settoolcontext %d", (int)mode);
		return(1);
	}

	if (mode == WRM_SKINS)
	{
		if (event->key != KEY_MOUSELEFT)
			return(Super::OnPress(event));
		OVL_LockInput(this);
		i = (event->mouseY-11)/12;
		if ((i < 0) || (i >= WS_MAXSKINS))
			return(1);
		skin = &ws->mdx->skins[i];
		if (skin->flags & MRF_SELECTED)
		{		
			if (event->mouseX < 12)
			{
				OVL_SendPressCommand(ws, "ws_spawnwindow_skin %d", i);
			}
			else
			if ((event->mouseX >= 18) && (event->mouseX < 78))
			{
				k = (event->mouseX-18) / 12;
				switch(k)
				{
				case 0:
					OVL_SendPressCommand(ws, "ws_delete_skin %d", i); break;
				case 1:
					OVL_SendPressCommand(ws, "ws_new_skin %d", i); break;
				case 2:
					OVL_SendPressCommand(ws, "ws_open_skin %d", i); break;
				case 3:
					OVL_SendPressCommand(ws, "ws_save_skin %d", i); break;
				case 4:
					OVL_SendPressCommand(ws, "ws_saveas_skin %d", i); break;
				}
			}
		}
		for (i=0;i<WS_MAXSKINS;i++)
			ws->mdx->skins[i].flags &= ~MRF_SELECTED;
		skin->flags |= MRF_SELECTED;
		return(1);
	}
	else
	if (mode == WRM_FRAMES)
	{
		int adjy;

		if (event->key != KEY_MOUSELEFT)
			return(Super::OnPress(event));
		OVL_LockInput(this);
		adjy = vpos.y;
		if (adjy < 0)
			adjy = 0;
		if (adjy > (ws->mdx->frames.Count()-1)*12)
			adjy = (ws->mdx->frames.Count()-1)*12;
		k = (event->mouseY-11+adjy)/12;
		f = ws->mdx->frames.Index(k);
		if (!f)
			return(1);
		if (f->flags & MRF_SELECTED)
		{		
			if (event->mouseX < 12)
				OVL_SendPressCommand(ws, "ws_spawnwindow_frame %d", k);
			else
			if ((event->mouseX >= 18) && (event->mouseX < 30))
				OVL_SendPressCommand(ws, "ws_delete_frame %d", k);
			else
			if (event->flags & KF_ALT)
			{
				sprintf(tbuffer, "ws_rename_frame %d", k);
				OVL_InputBox("Rename Frame", "What will you rename this frame to?", ws, tbuffer, f->name);
			}
		}
		MRL_ITERATENEXT(f2,f2,ws->mdx->frames)
			f2->flags &= ~MRF_SELECTED;
		f->flags |= MRF_SELECTED;
		return(1);
	}
	else
	if (mode == WRM_SEQUENCES)
	{
		int adjy;

		if (event->key != KEY_MOUSELEFT)
			return(Super::OnPress(event));
		OVL_LockInput(this);
		adjy = vpos.y;
		if (adjy < 0)
			adjy = 0;
		if (adjy > (ws->mdx->seqs.Count()-1)*12)
			adjy = (ws->mdx->seqs.Count()-1)*12;
		k = (event->mouseY-11+adjy)/12;
		s = ws->mdx->seqs.Index(k);
		if (!s)
			return(1);
		if (s->flags & MRF_SELECTED)
		{		
			if (event->mouseX < 12)
				OVL_SendPressCommand(ws, "ws_spawnwindow_seq %d", k);
			else
			if ((event->mouseX >= 18) && (event->mouseX < 30))
				OVL_SendPressCommand(ws, "ws_delete_seq %d", k);
			else
			if (event->flags & KF_ALT)
			{
				sprintf(tbuffer, "ws_rename_seq %d", k);
				OVL_InputBox("Rename Sequence", "What will you rename this sequence to?", ws, tbuffer, s->name);
			}
		}
		MRL_ITERATENEXT(s2,s2,ws->mdx->seqs)
			s2->flags &= ~MRF_SELECTED;
		s->flags |= MRF_SELECTED;
		return(1);
	}
	return(Super::OnPress(event));
}

/*
boolean OWorkResources::OnDrag(inputevent_t *event)
{
}
*/

boolean OWorkResources::OnRelease(inputevent_t *event)
{
	OVL_UnlockInput(this);
	return(Super::OnRelease(event));
}

/*
boolean OWorkResources::OnPressCommand(int argNum, char **argList)
{
}
*/

/*
boolean OWorkResources::OnDragCommand(int argNum, char **argList)
{
}
*/

/*
boolean OWorkResources::OnReleaseCommand(int argNum, char **argList)
{
}
*/

/*
boolean OWorkResources::OnMessage(ovlmsg_t *msg)
{
}
*/

//****************************************************************************
//**
//**    END MODULE OVL_WORK.CPP
//**
//****************************************************************************

