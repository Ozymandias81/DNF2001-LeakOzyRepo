//****************************************************************************
//**
//**    OVL_FRM.CPP
//**    Overlays - Frame View
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include "cbl_defs.h"
#include "ovl_defs.h"
#include "ovl_work.h"
#include "ovl_mdl.h"
//#include "ovl_skin.h"
#include "ovl_cc.h"
#include "ovl_frm.h"

//----------------------------------------------------------------------------
//    Private Definitions
//----------------------------------------------------------------------------
#define TRIFLAGS_MIN_WIDTH	150
#define TRIFLAGS_MIN_HEIGHT	225
//----------------------------------------------------------------------------
//    Private Structures
//----------------------------------------------------------------------------
typedef struct
{
	char marker[4];
	word version;
	word numtris;
} cbfheader_t;

//----------------------------------------------------------------------------
//    Additional External References
//----------------------------------------------------------------------------

// FIXME: these are in OVL_SKIN.CPP... need to unify the interface
extern void Undo_SkinPaint(char *sig);
extern void Undo_BaseManip(char *sig);
extern vector_t skin_curColor;
extern boolean skin_hsvMode;
extern vector_t RGB2HSV(vector_t RGB);

//----------------------------------------------------------------------------
//    Private Data
//----------------------------------------------------------------------------
CONVAR(float, mdl_moveSpeed, 100.0, 0, NULL);
CONVAR(float, mdl_turnSpeed, PI/2.0, 0, NULL);

//----------------------------------------------------------------------------
//    Public Data
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Code Prototypes
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Code
//----------------------------------------------------------------------------
static int PointInPoly(vector_t &p, vector_t *v, plane_t &tplane)
{
	int i;
	vector_t enorms[3], tvec;
	
	tvec = v[1] - v[0]; tvec.Normalize();
	enorms[0] = tvec ^ tplane.n;
	tvec = v[2] - v[1]; tvec.Normalize();
	enorms[1] = tvec ^ tplane.n;
	tvec = v[0] - v[2]; tvec.Normalize();
	enorms[2] = tvec ^ tplane.n;
	
	for (i=0;i<3;i++)
	{
		if ((p * enorms[i]) < (v[i] * enorms[i]))
			return(0);
	}
	return(1);
}

static int LoadCBF(modelFrame_t *f, char *filename)
{
	int k, bert, numtris;
	FILE *fp;
	char filebuf[256];
	cbfheader_t hdr;
	baseTri_t *baseTris, *tri;

	strcpy(filebuf, filename);
	SYS_ForceFileExtention(filebuf, "CBF");
	fp = fopen(filebuf, "rb");
	if (!fp)
		return(0);
	SYS_SafeRead(&hdr, sizeof(cbfheader_t), 1, fp);
	if ((hdr.marker[0] != 'C') || (hdr.marker[1] != 'B') || (hdr.marker[2] != 'F') || (hdr.marker[3] != '1'))
	{
		fclose(fp);
		return(0);
	}
	if ((hdr.version <= 0) || (hdr.version > 3))
	{
		fclose(fp);
		return(0);
	}
	numtris = hdr.numtris;
	if (f->numTris < numtris)
		numtris = f->numTris; // read lesser of two tri counts
	baseTris = f->GetBaseTris();
	for (k=0;k<numtris;k++)
	{
		tri = &baseTris[k];
		// version 1
		SYS_SafeRead(&tri->tverts[0].x, sizeof(float), 1, fp); tri->tverts[0].x = (int)tri->tverts[0].x;
		SYS_SafeRead(&tri->tverts[0].y, sizeof(float), 1, fp); tri->tverts[0].y = (int)tri->tverts[0].y;
		SYS_SafeRead(&tri->tverts[1].x, sizeof(float), 1, fp); tri->tverts[1].x = (int)tri->tverts[1].x;
		SYS_SafeRead(&tri->tverts[1].y, sizeof(float), 1, fp); tri->tverts[1].y = (int)tri->tverts[1].y;
		SYS_SafeRead(&tri->tverts[2].x, sizeof(float), 1, fp); tri->tverts[2].x = (int)tri->tverts[2].x;
		SYS_SafeRead(&tri->tverts[2].y, sizeof(float), 1, fp); tri->tverts[2].y = (int)tri->tverts[2].y;
		tri->flags = BTF_INUSE;
		if ((tri->tverts[0].x == -1) || (tri->tverts[0].y == -1)
		 || (tri->tverts[1].x == -1) || (tri->tverts[1].y == -1)
		 || (tri->tverts[2].x == -1) || (tri->tverts[2].y == -1))
			tri->flags = 0;
		if (hdr.version == 2)
        {
		    // version 2
		    SYS_SafeRead(&bert, sizeof(int), 1, fp); // groupNum, not used by baseframes separately anymore
        }
        if (hdr.version == 3)
        {
            // version 3
            SYS_SafeRead(&tri->skinIndex, sizeof(int), 1, fp);
        }
	}
	fclose(fp);
	return(1);
}

static int LoadBaseframe(modelFrame_t *f, char *filename)
{
	if (!filename)
		return(0);
	if (!_stricmp(SYS_GetFileExtention(filename), "CBF"))
		return(LoadCBF(f, filename));
	return(0);
}

static int SaveCBF(modelFrame_t *f, char *filename)
{
	int k;
	FILE *fp;
	char filebuf[256];
	cbfheader_t hdr;
	baseTri_t *baseTris, *tri;

	strcpy(filebuf, filename);
	SYS_ForceFileExtention(filebuf, "CBF");
	fp = fopen(filebuf, "wb");
	if (!fp)
		return(0);
	hdr.marker[0] = 'C';
	hdr.marker[1] = 'B';
	hdr.marker[2] = 'F';
	hdr.marker[3] = '1';
	hdr.version = 3;
	hdr.numtris = f->numTris;
	SYS_SafeWrite(&hdr, sizeof(cbfheader_t), 1, fp);
	baseTris = f->GetBaseTris();
	for (k=0;k<f->numTris;k++)
	{
		tri = &baseTris[k];
		// version 1
		SYS_SafeWrite(&tri->tverts[0].x, sizeof(float), 1, fp);
		SYS_SafeWrite(&tri->tverts[0].y, sizeof(float), 1, fp);
		SYS_SafeWrite(&tri->tverts[1].x, sizeof(float), 1, fp);
		SYS_SafeWrite(&tri->tverts[1].y, sizeof(float), 1, fp);
		SYS_SafeWrite(&tri->tverts[2].x, sizeof(float), 1, fp);
		SYS_SafeWrite(&tri->tverts[2].y, sizeof(float), 1, fp);
        // version 3
        SYS_SafeWrite(&tri->skinIndex, sizeof(int), 1, fp);
	}
	fclose(fp);
	return(1);
}

static int SaveBaseframe(modelFrame_t *f, char *filename)
{
	if (!filename)
		return(0);
	if (!_stricmp(SYS_GetFileExtention(filename), "CBF"))
		return(SaveCBF(f, filename));
	return(0);
}

//----------------------------------------------------------------------------
//    Public Code
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Class Member Code
//----------------------------------------------------------------------------
///////////////////////////////////////////
////    OTriFlagsList
///////////////////////////////////////////
OVLTYPE(OTriFlagsList, OWindow)
{
private:
    int numCheckBoxes;
    OCheckBoxControl* checkBoxes[32];
    int checkFlags[32];
    OSpinBoxControl* alphaSpinBox;

public:
    OVL_DEFINE(OTriFlagsList, OWindow)
    {
        flags |= OVLF_NORESIZE|OVLF_ALWAYSTOP|OVLF_NODRAGDROP|OVLF_NOTITLEMINMAX;
        numCheckBoxes = 0;
        for (int i=0;i<32;i++)
        {
            checkBoxes[i] = NULL;
            checkFlags[i] = 0;
        }
    }
    ~OTriFlagsList() {}

    void CreateBox(unsigned long boxflag, char* boxname)
    {
        checkBoxes[numCheckBoxes] = (OCheckBoxControl*)OVL_CreateOverlay("OCheckBoxControl", boxname, this, 0, numCheckBoxes*15, 150, 15, OVLF_NOFOCUS, false);
        checkFlags[numCheckBoxes] = boxflag;
        checkBoxes[numCheckBoxes]->checked = 2;
        numCheckBoxes++;
    }
	U32 SetDimensions(U32 width,U32 height)
	{
		U32 ret=TRUE;
		dim.x=width;
		if (width < TRIFLAGS_MIN_WIDTH)
		{
			dim.x=TRIFLAGS_MIN_WIDTH;
			ret&=~0;
		}
		dim.y=height;
		if (height < TRIFLAGS_MIN_HEIGHT)
		{
			dim.y=TRIFLAGS_MIN_HEIGHT;
			ret&=~0;
		}
		return ret;
	}
    void OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox)
    {
        if (!numCheckBoxes)
        {
            CreateBox(TF_ENVMAP, "Environment");
			CreateBox(TF_HIDDEN, "Hidden");
            CreateBox(TF_MASKING, "Masking");
			CreateBox(TF_MODULATED, "Modulated");
            CreateBox(TF_NOVERTLIGHT, "NoVertLight");
            CreateBox(TF_SPECULAR, "Specular");
            CreateBox(TF_TRANSPARENT, "Transparent");
            CreateBox(TF_TWOSIDED, "Two-sided");
            CreateBox(TF_UNLIT, "Unlit");
            CreateBox(TF_NONCOLLIDE, "NonCollide");
			CreateBox(TF_TEXBLEND, "Blend");
			CreateBox(TF_ZLATER, "LateZ");
            
            alphaSpinBox = (OSpinBoxControl*)OVL_CreateOverlay("OSpinBoxControl", "TransAlpha", this, 0, numCheckBoxes*15+10, 150, 15, OVLF_NOFOCUS, false);
            alphaSpinBox->spinValue = 128;
            alphaSpinBox->spinMin = 1;
            alphaSpinBox->spinMax = 255;

            // menu test
            /*
            OMenuItem* item;
            OMenu* mainmenu = (OMenu*)OVL_CreateOverlay("OMenu", "Menu", this, 0, 0, 50, 10, OVLF_NOFOCUS, false);
			OMenu* menu = (OMenu*)OVL_CreateOverlay("OMenu", "File", this, 10, 10, 50, 10, OVLF_NOFOCUS, false); menu->logicParent = mainmenu;
            item = (OMenuItem*)OVL_CreateOverlay("OMenuItem", "Open", this, 20, 20, 50, 10, OVLF_NOFOCUS, false); item->logicParent = menu;
            item = (OMenuItem*)OVL_CreateOverlay("OMenuItem", "Save", this, 20, 30, 50, 10, OVLF_NOFOCUS, false); item->logicParent = menu;
            item = (OMenuItem*)OVL_CreateOverlay("OMenuItem", "Exit", this, 20, 40, 50, 10, OVLF_NOFOCUS, false); item->logicParent = menu;
            strcpy(item->command, "quit");
            menu->Hide();
            */
        }
	    OWorkspace *ws = (OWorkspace *)this->parent;
	    model_t *mdx = ws->mdx;
	    meshTri_t *tri;
        unsigned long orFlags = 0;
        unsigned long andFlags = 0;
        int count = 0;
        
        alphaSpinBox->spinValue = 0;
        for (int i=0;i<ws->mdx->mesh.numTris;i++)
        {
            tri = &ws->mdx->mesh.meshTris[i];
            if (!(tri->flags & TF_SELECTED))
                continue;
            orFlags |= tri->flags;
            andFlags |= ~tri->flags;
            alphaSpinBox->spinValue += tri->aux1;
            count++;
        }
        if (!count)
            alphaSpinBox->spinValue = 128;
        else
            alphaSpinBox->spinValue /= count; // get average alpha
        for (i=0;i<numCheckBoxes;i++)
        {
            if ((checkFlags[i] & orFlags) && (checkFlags[i] & andFlags))
                checkBoxes[i]->checked = 2;
            else if (checkFlags[i] & orFlags)
                checkBoxes[i]->checked = 1;
            else
                checkBoxes[i]->checked = 0;
        }
        Super::OnDraw(sx,sy,dx,dy,clipbox);
    }
    boolean OnPressCommand(int argNum, char **argList)
    {
        OVLCMDSTART
        OVLCMD("CheckBoxUpdate")
        {
	        OWorkspace *ws = (OWorkspace *)this->parent;
	        model_t *mdx = ws->mdx;
	        meshTri_t *tri;
            unsigned long orFlags = 0;
            unsigned long andFlags = 0;
            for (int i=0;i<numCheckBoxes;i++)
            {
                if (checkBoxes[i]->checked == 1)
                    orFlags |= checkFlags[i];
                else if (checkBoxes[i]->checked == 0)
                    andFlags |= checkFlags[i];
            }
            for (i=0;i<ws->mdx->mesh.numTris;i++)
            {
                tri = &ws->mdx->mesh.meshTris[i];
                if (!(tri->flags & TF_SELECTED))
                    continue;
                tri->flags &= ~andFlags;
                tri->flags |= orFlags;
            }
            return(1);
        }
        OVLCMD("SpinBoxUpdate")
        {
	        OWorkspace *ws = (OWorkspace *)this->parent;
	        model_t *mdx = ws->mdx;
	        meshTri_t *tri;
            for (int i=0;i<ws->mdx->mesh.numTris;i++)
            {
                tri = &ws->mdx->mesh.meshTris[i];
                if (!(tri->flags & TF_SELECTED))
                    continue;
                tri->aux1 = alphaSpinBox->spinValue;
            }
            return(1);
        }
        return(Super::OnPressCommand(argNum, argList));
    }
};
REGISTEROVLTYPE(OTriFlagsList, OWindow);

///////////////////////////////////////////
////    OFrameView
///////////////////////////////////////////

REGISTEROVLTYPE(OFrameView, OToolWindow);

void OFrameView::OnSave()
{
	Super::OnSave();
	VCR_EnlargeActionDataBuffer(512);
	if ((!frame) || (!frame->numVerts))
		VCR_WriteString("NULL");
	else
		VCR_WriteString(frame->name);
	VCR_WriteBulk(&camera, sizeof(camera_t));
	VCR_WriteByte(gridActive);
	VCR_WriteByte(wireframeActive);
	VCR_WriteByte(rotatewheelActive);
	VCR_WriteInt(gridNumUnits);
	VCR_WriteFloat(gridStart.x); VCR_WriteFloat(gridStart.y); VCR_WriteFloat(gridStart.z);
	VCR_WriteFloat(gridHDelta.x); VCR_WriteFloat(gridHDelta.y); VCR_WriteFloat(gridHDelta.z);
	VCR_WriteFloat(gridVDelta.x); VCR_WriteFloat(gridVDelta.y); VCR_WriteFloat(gridVDelta.z);
	VCR_WriteFloat(gridColor.x); VCR_WriteFloat(gridColor.y); VCR_WriteFloat(gridColor.z);
	VCR_WriteFloat(anchorPoint.x); VCR_WriteFloat(anchorPoint.y); VCR_WriteFloat(anchorPoint.z);
	VCR_WriteByte(anchorActive);
	VCR_WriteByte(selectionGlow);
	VCR_WriteByte(grabSkinIndex);
	VCR_WriteByte(mountIndex);
	VCR_WriteByte(brushsize);
	VCR_WriteByte(antialias);
	VCR_WriteByte(filtered);
	VCR_WriteByte(viewBlacklists);
	VCR_WriteByte(refOverride);
	VCR_WriteByte(origamiView);
}

void OFrameView::OnLoad()
{
	char *str;
	
	Super::OnLoad();
	frame = NULL;
	mesh = NULL;
	frameName[0] = 0;
	str = VCR_ReadString();
	if (strcmp(str, "NULL"))
		strcpy(frameName, str); // frameName is ONLY used for resolution of frame when null at draw time, it is NOT always synced
	VCR_ReadBulk(&camera, sizeof(camera_t));
	gridActive = VCR_ReadByte();
	wireframeActive = VCR_ReadByte();
	rotatewheelActive = VCR_ReadByte();
	gridNumUnits = VCR_ReadInt();
	gridStart.x = VCR_ReadFloat(); gridStart.y = VCR_ReadFloat(); gridStart.z = VCR_ReadFloat();
	gridHDelta.x = VCR_ReadFloat(); gridHDelta.y = VCR_ReadFloat(); gridHDelta.z = VCR_ReadFloat();
	gridVDelta.x = VCR_ReadFloat(); gridVDelta.y = VCR_ReadFloat(); gridVDelta.z = VCR_ReadFloat();
	gridColor.x = VCR_ReadFloat(); gridColor.y = VCR_ReadFloat(); gridColor.z = VCR_ReadFloat();
	anchorPoint.x = VCR_ReadFloat(); anchorPoint.y = VCR_ReadFloat(); anchorPoint.z = VCR_ReadFloat();
	anchorActive = VCR_ReadByte();
	selectionGlow = VCR_ReadByte();
	grabSkinIndex = VCR_ReadByte();
	mountIndex = VCR_ReadByte();
	brushsize = VCR_ReadByte();
	antialias = VCR_ReadByte();
	filtered = VCR_ReadByte();
	viewBlacklists = VCR_ReadByte();
	refOverride = VCR_ReadByte();
	origamiView = VCR_ReadByte();
}

/*
void OFrameView::OnResize()
{
}
*/

static void DrawModelAtMount(OFrameView *view, int sx, int sy, int dx, int dy,
							 model_t *mdx, modelMount_t *mount)
{
	int i, k;
	vector_t p[6], v[6], c[6], tv[6];
	meshTri_t *tri;
	baseTri_t *baseTris, *btri;
	frameVert_t *frameVerts;
	modelFrame_t *useframe;
	modelSkin_t *skin;
	modelTrimesh_t *mesh;

	if (!(mount->flags & MRF_INUSE))
		return;

	useframe = mdx->refFrame;
	mesh = &mdx->mesh;

	baseTris = useframe->GetBaseTris();
	if (!baseTris)
		return;
	frameVerts = useframe->GetVerts();
	if (!frameVerts)
		return;

	view->camera.SetFOV(256.0*vid.resolution->width/(dx+1), 256.0*vid.resolution->height/(dy+1));
	view->camera.SetScreenBox(sx, sy, dx+1, dy+1);
	view->camera.frust.Set(view->camera.frust.xr, view->camera.frust.yr, 0.5, 1024.0);

	vid.ColorMode(VCM_FLAT);
	vid.FlatColor(128, 0, 255);
//	vid.FlatColor(0, 0, 0);
	for (i=0;i<mesh->numTris;i++)
	{
		tri = &mesh->meshTris[i];
		if (tri->flags & TF_HIDDEN)
			continue;
		btri = &baseTris[i];
		p[0] = frameVerts[tri->verti[0]].pos;
		p[1] = frameVerts[tri->verti[1]].pos;
		p[2] = frameVerts[tri->verti[2]].pos;
		if (mesh->mountPoints[tri->verti[0]])
			mdx->mounts[mesh->mountPoints[tri->verti[0]]].MountToWorld(p[0]);
		if (mesh->mountPoints[tri->verti[1]])
			mdx->mounts[mesh->mountPoints[tri->verti[1]]].MountToWorld(p[1]);
		if (mesh->mountPoints[tri->verti[2]])
			mdx->mounts[mesh->mountPoints[tri->verti[2]]].MountToWorld(p[2]);
		mount->useAttachOrigin = true;
		mount->MountToWorld(p[0]);
		mount->MountToWorld(p[1]);
		mount->MountToWorld(p[2]);
		mount->useAttachOrigin = false;
		if ((!(skin = &mdx->skins[btri->skinIndex])) || (!skin->tex) || (!(btri->flags & BTF_INUSE)))
		{
			view->camera.DrawTriangle(p, NULL, NULL, NULL, true);
		}
		else
		{
			vid.ColorMode(VCM_TEXTURE);
			vid.TexActivate(skin->tex, VTA_NORMAL);
			//if (filtered)
				vid.FilterMode(VFM_BILINEAR);
			for (k=0;k<3;k++)
			{
				float aspect = (float)skin->tex->height / (float)skin->tex->width;
				//tv[k].x = btri->tverts[k].x;//*256.0/skin->tex->width;
				//tv[k].y = btri->tverts[k].y;//*256.0/skin->tex->height;
				tv[k].x = btri->tverts[k].x*256.0/skin->tex->width;
				tv[k].y = btri->tverts[k].y*256.0/skin->tex->height;
				if (aspect < 1)
					tv[k].y *= aspect;
				else
					tv[k].x /= aspect;
			}
			view->camera.DrawTriangleFlags(tri->flags,p, NULL, NULL, tv, true);
			vid.FilterMode(VFM_NONE);
			vid.ColorMode(VCM_FLAT);
			vid.FlatColor(128, 0, 255);
//			vid.FlatColor(0, 0, 0);
		}
	}
}

static void DrawArrow(camera_t *cam, vector_t &p0, vector_t &p1, vector_t &c)
{
	vector_t a1, a2, ac;
//	float lac;

	cam->SetDrawDepthBias(-0.1);
	vid.ColorMode(VCM_GOURAUD);
	vid.AlphaMode(VAM_GOURAUD);
	vid.BlendMode(VBM_TRANSMERGE);
	vid.Antialias(true);
	
	cam->DrawLine(&p0, &p1, &c, &c, true);
	/*
	ac = (p1 - p0) * 0.1;
	lac = ac.Length();
	ac = p1 - ac;
	a1 = ac + (cam->vup * lac);
	a2 = ac - (cam->vup * lac);
	cam->DrawTriangle(&a1, &a2, &p1, 
	*/
	
	vid.Antialias(false);
	vid.BlendMode(VBM_OPAQUE);
	vid.AlphaMode(VAM_FLAT);
	cam->SetDrawDepthBias(0);
}

void OFrameView::OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox)
{
	int i, k;
	vector_t p[6], v[6], c[6], tv[6];
	meshTri_t *tri;
	baseTri_t *baseTris, *refBaseTris, *btri;
	frameVert_t *frameVerts, *refFrameVerts, *lerpFrameVerts;
	modelFrame_t *useframe, *nextlerpframe;
	float frontfrac, backfrac;
	modelSkin_t *skin;
	OWorkspace *ws;
	model_t *mdx;
	char tbuffer[128];
	boolean playing;
	modelSequence_t *s;

	Super::OnDraw(sx, sy, dx, dy, clipbox);

	ws = (OWorkspace *)this->parent;
	mdx = ws->mdx;
	if (!refOverrideFrame)	
		refOverrideFrame = mdx->refFrame;
	if (!frame)
	{
		modelFrame_t *f;
		
		MRL_ITERATENEXT(f,f,mdx->frames)
		{
			if (!_stricmp(f->name, frameName))
				frame = f;
		}
		if (refOverride)
		{			
			f = refOverrideFrame;
			refOverrideFrame = frame;
			frame = f;
		}
	}
	if (!mesh)
		mesh = &mdx->mesh;

	useframe = frame;

	if ((!mesh) || (!useframe))
		return;
	if ((!mesh->numTris) || (!useframe->numVerts))
		return;

	playing = false;
	s = ws->GetTopmostSequence();
	if (s && s->playing)
		playing = true;

	seqTrigger_t* htrig = NULL;
	if (playing)
	{
		int ctime, etime, duration;
		seqItem_t *item;
        seqTrigger_t *trigger;
		
		for (htrig = s->triggers.next; htrig!=&s->triggers; htrig = htrig->next)
		{
			if (htrig->triggerBinData && htrig->trigger && !_stricmp(htrig->trigger, "_HIDDENTRIS"))
				break;
		}
		if (htrig == &s->triggers)
			htrig = NULL;

		useframe = NULL;
		etime = 0;
		duration = 1000.0 / s->framesPerSecond;
		for (item=s->items.next;item!=&s->items;item=item->next)
			etime += duration;
		ctime = (sys_curTime - s->playStartTime) * 1000;
		if (ctime < 0)
			ctime = 0;
		ctime = ctime % etime;
		etime = 0;
		for (item=s->items.next;item!=&s->items;item=item->next)
		{
			if ((ctime >= etime) && (ctime < etime+duration))
			{
                for (trigger=s->triggers.next;trigger!=&s->triggers;trigger=trigger->next)
                {
                    if ((trigger->trigTimeFrac*1000.0 >= etime) && (trigger->trigTimeFrac*1000.0 < etime+duration))
                    {
                        if (trigger->trigger && !_strnicmp(trigger->trigger, "playwav ", 8))
                        {
                            SYS_PlaySound(trigger->trigger+8);
                        }
                    }
                }
				useframe = item->setFrame;
				if (item->next == &s->items)
					nextlerpframe = s->items.next->setFrame;
				else
					nextlerpframe = item->next->setFrame;
				frontfrac = (float)(ctime - etime) / (float)duration;
				if (frontfrac < 0.0)
					frontfrac = 0.0;
				if (frontfrac > 1.0)
					frontfrac = 1.0;
				backfrac = 1.0 - frontfrac;
				lerpFrameVerts = nextlerpframe->GetVerts();
				if (!lerpFrameVerts)
					return;
				break;
			}
			etime += duration;
		}
		if (!useframe)
		{
			useframe = frame;
			playing = 0;
		}
	}

	baseTris = useframe->GetBaseTris();
	if (!baseTris)
		return;
	refBaseTris = mdx->refFrame->GetBaseTris();
	if (!refBaseTris)
		return;
	frameVerts = useframe->GetVerts();
	if (!frameVerts)
		return;
	refFrameVerts = mdx->refFrame->GetVerts();
	if (!refFrameVerts)
		return;

	camera.SetFOV(256.0*vid.resolution->width/(dx+1), 256.0*vid.resolution->height/(dy+1));
	camera.SetScreenBox(sx, sy, dx+1, dy+1);
	camera.frust.Set(camera.frust.xr, camera.frust.yr, 0.5, 1024.0);

	if ((useframe == mdx->refFrame) && (!playing))
		vid.DrawString(sx+1, sy+1, 6, 6, "Reference", true, 128, 128, 128);
	strcpy(tbuffer, "Skin: ");
	if (mdx->skins[grabSkinIndex].flags & MRF_INUSE)
		strcat(tbuffer, SYS_GetFileRoot(mdx->skins[grabSkinIndex].name));
	else
		strcat(tbuffer, "(empty)");
	vid.DrawString(sx+dx-strlen(tbuffer)*6-1, sy+1, 6, 6, tbuffer, true, 128, 128, 128);
	strcpy(tbuffer, "Mount: ");
	if (mountIndex)
		sprintf(tbuffer+7, "%d", mountIndex);
	else
		strcat(tbuffer, "Origin");
	vid.DrawString(sx+dx-strlen(tbuffer)*6-1, sy+8, 6, 6, tbuffer, true, 128, 128, 0);

	for (i=0;i<WS_MAXMOUNTS;i++)
	{
		if (mdx->mounts[i].flags & MRF_INUSE)
		{
			if (!playing)
				mdx->mounts[i].SetFrame(useframe);
			else
				mdx->mounts[i].SetFrameLerped(useframe, nextlerpframe, backfrac, frontfrac);
			
			if (i == mountIndex)
			{
				mdx->mounts[i].useAttachOrigin = true;

				p[0].Set(0,0,0);
				mdx->mounts[i].MountToWorld(p[0]);
				
				p[1].Set(10,0,0);
				mdx->mounts[i].MountToWorld(p[1]);
				c[0].Set(255,0,0);
				//camera.DrawLine(&p[0], &p[1], NULL, NULL, true);
				DrawArrow(&camera, p[0], p[1], c[0]);
				p[1].Set(0,10,0);
				mdx->mounts[i].MountToWorld(p[1]);
				c[0].Set(0,255,0);
				//camera.DrawLine(&p[0], &p[1], NULL, NULL, true);
				DrawArrow(&camera, p[0], p[1], c[0]);
				p[1].Set(0,0,10);
				mdx->mounts[i].MountToWorld(p[1]);
				c[0].Set(0,0,255);
				//camera.DrawLine(&p[0], &p[1], NULL, NULL, true);
				DrawArrow(&camera, p[0], p[1], c[0]);

				mdx->mounts[i].useAttachOrigin = false;
				
				p[0].Set(0,0,0);
				mdx->mounts[i].MountToWorld(p[0]);
				
				p[1].Set(10,0,0);
				mdx->mounts[i].MountToWorld(p[1]);
				c[0].Set(128,0,0);
				//camera.DrawLine(&p[0], &p[1], NULL, NULL, true);
				DrawArrow(&camera, p[0], p[1], c[0]);
				p[1].Set(0,10,0);
				mdx->mounts[i].MountToWorld(p[1]);
				c[0].Set(0,128,0);
				//camera.DrawLine(&p[0], &p[1], NULL, NULL, true);
				DrawArrow(&camera, p[0], p[1], c[0]);
				p[1].Set(0,0,10);
				mdx->mounts[i].MountToWorld(p[1]);
				c[0].Set(0,0,128);
				//camera.DrawLine(&p[0], &p[1], NULL, NULL, true);
				DrawArrow(&camera, p[0], p[1], c[0]);
			}

			if (mdx->mounts[i].attachModel)
				DrawModelAtMount(this, sx, sy, dx, dy, mdx->mounts[i].attachModel, &mdx->mounts[i]);
		}
	}

	if (showLodLocked)
	{
		int t, r, g, b;

		t = (int)(sys_curTime * 256.0);
		r = (t&511)-256; if (r < 0) r = -r; if (r > 255) r = 255;
		g = ((t+170)&511)-256; if (g < 0) g = -g; if (g > 255) g = 255;
		b = ((t+340)&511)-256; if (b < 0) b = -b; if (b > 255) b = 255;
		for (i=0;i<mesh->numVerts;i++)
		{
			if (!(frameVerts[i].flags & FVF_P_LODLOCKED))
				continue;
			p[0] = p[1] = frameVerts[i].pos;
			p[0].x -= 0.4; p[1].x += 0.4;
			p[0].y -= 0.4; p[1].y += 0.4;
			p[0].z -= 0.4; p[1].z += 0.4;
			c[0].Set(r, g, b);
			c[1].Set(g, b, r);
			c[2].Set(128, 128, 128);
			camera.DrawBox(&p[0], &p[1], c, NULL, true, false);
		}
	}

	if (anchorActive)
	{
		p[0] = p[1] = anchorPoint;
		p[0].x -= 0.3; p[1].x += 0.3;
		p[0].y -= 0.3; p[1].y += 0.3;
		p[0].z -= 0.3; p[1].z += 0.3;
		c[0].Set(0, 0, 255);
		c[1].Set(255, 255, 0);
		c[2].Set(128, 128, 128);
		camera.DrawBox(&p[0], &p[1], c, NULL, true, true);
	}

	if (wireframeActive)
	{
		vid.ColorMode(VCM_FLAT);
		vid.FlatColor(255, 255, 255);
		camera.SetDrawDepthBias(-0.1);
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			if (tri->flags & TF_HIDDEN)
				continue;
			p[0] = frameVerts[tri->verti[0]].pos;
			p[1] = frameVerts[tri->verti[1]].pos;
			p[2] = frameVerts[tri->verti[2]].pos;
			camera.DrawLine(&p[0], &p[1], NULL, NULL, true);
			camera.DrawLine(&p[1], &p[2], NULL, NULL, true);
			camera.DrawLine(&p[2], &p[0], NULL, NULL, true);
		}
		camera.SetDrawDepthBias(0);
	}

	if ((useframe == mdx->refFrame) && (!playing))
		gridColor.Set(0, 0, 255);
	else
		gridColor.Set(255, 0, 0);
	if (gridActive)
	{
		vid.ColorMode(VCM_FLAT);
		vid.FlatColor(gridColor.x, gridColor.y, gridColor.z);
		p[0] = p[1] = gridStart;
		for (i=0;i<=gridNumUnits;i++)
		{
			p[1] = p[0];
			p[1] += gridHDelta * gridNumUnits;
			camera.DrawLine(&p[0], &p[1], NULL, NULL, true);
			p[0] += gridVDelta;
		}
		p[0] = p[1] = gridStart;
		for (i=0;i<=gridNumUnits;i++)
		{
			p[1] = p[0];
			p[1] += gridVDelta * gridNumUnits;
			camera.DrawLine(&p[0], &p[1], NULL, NULL, true);
			p[0] += gridHDelta;
		}
		camera.SetDrawDepthBias(-0.2);
		vid.FlatColor(0, 255, 255);
		float len = gridHDelta.Length();
		p[0].Set(0, 0, 0);
		p[1].Set(len, 0, 0);
		camera.DrawLine(&p[0], &p[1], NULL, NULL, true);
		p[1].Set(0, len, 0);
		camera.DrawLine(&p[0], &p[1], NULL, NULL, true);
		p[1].Set(0, 0, len);
		camera.DrawLine(&p[0], &p[1], NULL, NULL, true);
		camera.SetDrawDepthBias(0);
	}

	vid.ColorMode(VCM_FLAT);
	vid.FlatColor(128, 0, 255);
//	vid.FlatColor(0, 0, 0);
	int specFlicker = (((int)(SYS_GetTimeFloat()*8))&1);
	
    for (int transreps=0; transreps < 2; transreps++)
    {
        for (i=0;i<mesh->numTris;i++)
	    {
		    tri = &mesh->meshTris[i];
		    if (tri->flags & TF_HIDDEN)
			    continue;
			if (htrig && htrig->triggerBinData[i] & 1)
				continue;
            if (((tri->flags & TF_TRANSPARENT) != 0) != transreps)
                continue;
		    btri = &baseTris[i];
		    if (!(btri->flags & BTF_INUSE))
			    btri = &refBaseTris[i]; // look at the reference frame if this baseframe tri isn't valid
		    if (frameVerts[tri->verti[0]].flags & FVF_IRRELEVANT)
			    p[0] = refFrameVerts[tri->verti[0]].pos;
		    else
			    p[0] = frameVerts[tri->verti[0]].pos;
		    if (frameVerts[tri->verti[1]].flags & FVF_IRRELEVANT)
			    p[1] = refFrameVerts[tri->verti[1]].pos;
		    else
			    p[1] = frameVerts[tri->verti[1]].pos;
		    if (frameVerts[tri->verti[2]].flags & FVF_IRRELEVANT)
			    p[2] = refFrameVerts[tri->verti[2]].pos;
		    else
			    p[2] = frameVerts[tri->verti[2]].pos;
		    if (mesh->mountPoints[tri->verti[0]])
			    mdx->mounts[mesh->mountPoints[tri->verti[0]]].MountToWorld(p[0]);
		    if (mesh->mountPoints[tri->verti[1]])
			    mdx->mounts[mesh->mountPoints[tri->verti[1]]].MountToWorld(p[1]);
		    if (mesh->mountPoints[tri->verti[2]])
			    mdx->mounts[mesh->mountPoints[tri->verti[2]]].MountToWorld(p[2]);
		    if (playing)
		    {
			    if (lerpFrameVerts[tri->verti[0]].flags & FVF_IRRELEVANT)
				    p[3] = refFrameVerts[tri->verti[0]].pos;
			    else
				    p[3] = lerpFrameVerts[tri->verti[0]].pos;
			    if (lerpFrameVerts[tri->verti[1]].flags & FVF_IRRELEVANT)
				    p[4] = refFrameVerts[tri->verti[1]].pos;
			    else
				    p[4] = lerpFrameVerts[tri->verti[1]].pos;
			    if (lerpFrameVerts[tri->verti[2]].flags & FVF_IRRELEVANT)
				    p[5] = refFrameVerts[tri->verti[2]].pos;
			    else
				    p[5] = lerpFrameVerts[tri->verti[2]].pos;
			    if (mesh->mountPoints[tri->verti[0]])
				    mdx->mounts[mesh->mountPoints[tri->verti[0]]].MountToWorld(p[3]);
			    if (mesh->mountPoints[tri->verti[1]])
				    mdx->mounts[mesh->mountPoints[tri->verti[1]]].MountToWorld(p[4]);
			    if (mesh->mountPoints[tri->verti[2]])
				    mdx->mounts[mesh->mountPoints[tri->verti[2]]].MountToWorld(p[5]);
			    p[0] = p[0]*backfrac + p[3]*frontfrac;
			    p[1] = p[1]*backfrac + p[4]*frontfrac;
			    p[2] = p[2]*backfrac + p[5]*frontfrac;
		    }
		    if ((!(skin = &mdx->skins[btri->skinIndex])) || (!skin->tex) || (!(btri->flags & BTF_INUSE)))
		    {
			    camera.DrawTriangle(p, NULL, NULL, NULL, true);
		    }
		    else
		    {
			    vid.ColorMode(VCM_TEXTURE);
			    vid.TexActivate(skin->tex, VTA_NORMAL);
			    if (filtered)
				    vid.FilterMode(VFM_BILINEAR);
                vidmaskmodetype_t vmm;
                if (tri->flags & TF_MASKING)
                {
                    vid.MaskColor(255,0,255,0);
                    vmm = vid.MaskMode(VMM_ENABLE);
                }
			    if (tri->flags & TF_TWOSIDED)
                    vid.WindingMode(VWM_SHOWALL);
                if ((!envMapTest) || (!mdx->refFrame->vertNorms))
			    {
				    if (tri->flags & TF_TRANSPARENT)
				    {
					    vid.AlphaMode(VAM_FLAT);
					    vid.FlatAlpha(tri->aux1); // aux1 is alpha transparency value
					    vid.BlendMode(VBM_TRANSMERGE);
                        vid.DepthActive(0);
				    }
				    for (k=0;k<3;k++)
				    {
					    float aspect = (float)skin->tex->height / (float)skin->tex->width;
					    //tv[k].x = btri->tverts[k].x;//*256.0/skin->tex->width;
					    //tv[k].y = btri->tverts[k].y;//*256.0/skin->tex->height;
					    tv[k].x = btri->tverts[k].x*256.0/skin->tex->width;
					    tv[k].y = btri->tverts[k].y*256.0/skin->tex->height;
					    if (aspect < 1)
						    tv[k].y *= aspect;
					    else
						    tv[k].x /= aspect;
				    }
			    }
			    else
			    {
				    vector_t u, n, rv;
				    float m;
				    for (k=0;k<3;k++)
				    {
					    u = p[k];
					    camera.TransWorldToCamera(&u);
					    u.Normalize();
					    n = mdx->refFrame->vertNorms[tri->verti[k]];
					    n *= camera.xform;
					    rv = u - (n*2.0) * (n*u);
					    rv.Normalize();
					    m = 2.0 * sqrt(rv.x*rv.x + rv.y*rv.y + (rv.z+1)*(rv.z+1));
					    tv[k].x = 256.0*rv.x/m + 0.5;
					    tv[k].y = 256.0*rv.y/m + 0.5;
				    }
			    }
				if (tri->flags & TF_TEXBLEND)
				{
					vid.AlphaMode(VAM_TEXTURE);
					vid.BlendMode(VBM_TRANSMERGE);
				}
				camera.DrawTriangleFlags(tri->flags,p,null,null,tv,true);
			    //camera.DrawTriangle(p, NULL, NULL, tv, true);
			    vid.FilterMode(VFM_NONE);
			    vid.ColorMode(VCM_FLAT);
			    vid.FlatColor(128, 0, 255);
				vid.BlendMode(VBM_OPAQUE);
			    if (tri->flags & TF_TWOSIDED)
                    vid.WindingMode(VWM_SHOWCLOCKWISE);
                if (tri->flags & TF_MASKING)
                {
                    vid.MaskColor(0,0,0,0);
                    vid.MaskMode(vmm);
                }
			    if (tri->flags & TF_TRANSPARENT)
			    {
				    vid.FlatAlpha(255);
                    vid.DepthActive(1);
			    }
    //			vid.FlatColor(0, 0, 0);
		    }
		    if ((tri->flags & TF_SELECTED) && (selectionGlow) && ((!origamiView) || (tri != origamiTri)))
		    {
			    int t, r, g, b;

			    vid.AlphaMode(VAM_FLAT);
			    if (tri->flags & (TF_NOVERTLIGHT|TF_UNLIT))
			    {
				    vid.FlatAlpha(192);
				    vid.BlendMode(VBM_TRANSMERGE);
			    }
			    else
			    {
				    vid.FlatAlpha(128);
				    vid.BlendMode(VBM_TRANSTOTAL);
			    }
			    vid.ColorMode(VCM_GOURAUD);
			    t = (int)(sys_curTime * 256.0);
			    r = (t&511)-256; if (r < 0) r = -r; if (r > 255) r = 255;
			    g = ((t+170)&511)-256; if (g < 0) g = -g; if (g > 255) g = 255;
			    b = ((t+340)&511)-256; if (b < 0) b = -b; if (b > 255) b = 255;
			    if (tri->flags & TF_NOVERTLIGHT)
			    {
				    c[0].Set(g, g, g);
				    c[1].Set(r, r, r);
				    c[2].Set(b, b, b);
			    }
			    else if (tri->flags & TF_UNLIT)
			    {
				    c[0].Set(255, 255, 255);
				    c[1].Set(255, 255, 255);
				    c[2].Set(255, 255, 255);
			    }
			    else if (tri->flags & TF_ENVMAP)
			    {
				    c[0].Set(r, g, r);
				    c[1].Set(r, r, g);
				    c[2].Set(g, r, r);
			    }
			    else if (tri->flags & (TF_SPECULAR|TF_MODULATED))
			    {
				    if (1)//(specFlicker)
				    {
					    c[0].Set(r, g, b);
					    c[1].Set(r, g, b);
					    c[2].Set(r, g, b);
				    }
			    }
			    else
			    {
				    c[0].Set(r, g, b);
				    c[1].Set(b, r, g);
				    c[2].Set(g, b, r);
			    }
			    camera.SetDrawDepthBias(-0.2);
			    camera.DrawTriangleFlags(tri->flags,p, c, NULL, NULL, true);
			    vid.BlendMode(VBM_OPAQUE);
			    vid.ColorMode(VCM_FLAT);
			    vid.FlatColor(128, 0, 255);
			    camera.SetDrawDepthBias(0);
		    }
		    if ((origamiView) && (origamiTri))
		    {
			    if (tri == origamiTri)
			    {
				    int t, r, g, b;

				    vid.AlphaMode(VAM_FLAT);
				    vid.FlatAlpha(192);
				    vid.ColorMode(VCM_GOURAUD);
				    vid.BlendMode(VBM_TRANSMERGE);
				    t = (int)(sys_curTime * 256.0);
				    r = (t&511)-256; if (r < 0) r = -r; if (r > 255) r = 255;
				    g = ((t+170)&511)-256; if (g < 0) g = -g; if (g > 255) g = 255;
				    b = ((t+340)&511)-256; if (b < 0) b = -b; if (b > 255) b = 255;
				    c[0].Set(0, g, 0);
				    c[1].Set(0, r, 0);
				    c[2].Set(0, b, 0);
				    camera.SetDrawDepthBias(-0.2);
				    camera.DrawTriangleFlags(tri->flags,p, c, NULL, NULL, true);
				    vid.BlendMode(VBM_OPAQUE);
				    vid.ColorMode(VCM_FLAT);
				    vid.FlatColor(128, 0, 255);
				    camera.SetDrawDepthBias(0);
			    }
			    else
			    if ((tri == &mesh->meshTris[origamiTri->edgeTris[0] & 0x3FFF])
			     || (tri == &mesh->meshTris[origamiTri->edgeTris[1] & 0x3FFF])
			     || (tri == &mesh->meshTris[origamiTri->edgeTris[2] & 0x3FFF]))
			    {
				    int t, r, g, b;

				    vid.AlphaMode(VAM_FLAT);
				    vid.FlatAlpha(192);
				    vid.ColorMode(VCM_GOURAUD);
				    vid.BlendMode(VBM_TRANSMERGE);
				    t = (int)(sys_curTime * 256.0);
				    r = (t&511)-256; if (r < 0) r = -r; if (r > 255) r = 255;
				    g = ((t+170)&511)-256; if (g < 0) g = -g; if (g > 255) g = 255;
				    b = ((t+340)&511)-256; if (b < 0) b = -b; if (b > 255) b = 255;
				    c[0].Set(0, 0, b);
				    c[1].Set(0, 0, g);
				    c[2].Set(0, 0, r);
				    camera.SetDrawDepthBias(-0.2);
				    camera.DrawTriangleFlags(tri->flags,p, c, NULL, NULL, true);
				    vid.BlendMode(VBM_OPAQUE);
				    vid.ColorMode(VCM_FLAT);
				    vid.FlatColor(128, 0, 255);
				    camera.SetDrawDepthBias(0);
			    }
		    }
        }
	}

	if (viewBlacklists)
	{
		vector_t v[3];

		vid.ColorMode(VCM_FLAT);
		for (i=0;i<frame->numVerts;i++)
		{
			if (frameVerts[i].flags & FVF_IRRELEVANT)
			{
				vid.FlatColor(255, 0, 0);
				p[0].Set(frameVerts[i].pos.x+0.3, frameVerts[i].pos.y+0.3, frameVerts[i].pos.z+0.3);
				p[1].Set(frameVerts[i].pos.x, frameVerts[i].pos.y+0.3, frameVerts[i].pos.z-0.3);
				p[2].Set(frameVerts[i].pos.x-0.3, frameVerts[i].pos.y+0.3, frameVerts[i].pos.z+0.3);
				p[3].Set(frameVerts[i].pos.x, frameVerts[i].pos.y-0.3, frameVerts[i].pos.z);				
			}
			else
			{
				vid.FlatColor(0, 255, 0);
				p[0].Set(frameVerts[i].pos.x-0.3, frameVerts[i].pos.y-0.3, frameVerts[i].pos.z+0.3);
				p[1].Set(frameVerts[i].pos.x, frameVerts[i].pos.y-0.3, frameVerts[i].pos.z-0.3);
				p[2].Set(frameVerts[i].pos.x+0.3, frameVerts[i].pos.y-0.3, frameVerts[i].pos.z+0.3);
				p[3].Set(frameVerts[i].pos.x, frameVerts[i].pos.y+0.3, frameVerts[i].pos.z);				
			}
			v[0] = p[2]; v[1] = p[1]; v[2] = p[0];
			camera.DrawTriangle(v, NULL, NULL, NULL, true);
			v[0] = p[1]; v[1] = p[3]; v[2] = p[0];
			camera.DrawTriangle(v, NULL, NULL, NULL, true);
			v[0] = p[2]; v[1] = p[3]; v[2] = p[1];
			camera.DrawTriangle(v, NULL, NULL, NULL, true);
			v[0] = p[0]; v[1] = p[3]; v[2] = p[2];
			camera.DrawTriangle(v, NULL, NULL, NULL, true);
		}
	}

	if (rotatewheelActive)
	{
		vector_t c(sx+(dx/2),sy+(dy/2), 0);
		vector_t s(sx,sy,0);
		rotateWheelCenter.Set(c.x-sx, c.y-sy-6, 0); // the -6 offsets the 12 height diff with the title
		float rad = dx/3;
		if (dy/3 < rad)
			rad = dy/3;
		float adj = rad/10;
		rotateWheelRadius = rad;
		vid.ColorMode(VCM_FLAT);
		vid.FlatColor(0, 255, 0);
		p[0].Set(c.x+rad, c.y, -256);
		for (i=0;i<=64;i++)
		{
			p[1].Set(c.x+cos(i*PI/32.0)*rad, c.y-sin(i*PI/32.0)*rad, -256);
			vid.DrawLine(&p[0], &p[1], NULL, NULL, false);
			p[0] = p[1];
		}
		
		vid.FlatColor(0, 255, 255);
		p[0] = c;
		p[1].Set(c.x+cos(camera.rollangle+PI/2)*rad, c.y-sin(camera.rollangle+PI/2)*rad, 0);
		vid.DrawLine(&p[0], &p[1], NULL, NULL, false);

		vid.FlatColor(128, 255, 0);
		
		p[0].Set(c.x-rad-adj, c.y-adj, -256); rotateWheelBoxes[0][0] = p[0]-s;
		p[2].Set(c.x-rad+adj, c.y+adj, -256); rotateWheelBoxes[0][1] = p[2]-s;
		p[1].Set(p[2].x, p[0].y, -256);
		p[3].Set(p[0].x, p[2].y, -256);
		vid.DrawLine(&p[0], &p[1], NULL, NULL, false);
		vid.DrawLine(&p[1], &p[2], NULL, NULL, false);
		vid.DrawLine(&p[2], &p[3], NULL, NULL, false);
		vid.DrawLine(&p[3], &p[0], NULL, NULL, false);

		p[0].Set(c.x+rad-adj, c.y-adj, -256); rotateWheelBoxes[1][0] = p[0]-s;
		p[2].Set(c.x+rad+adj, c.y+adj, -256); rotateWheelBoxes[1][1] = p[2]-s;
		p[1].Set(p[2].x, p[0].y, -256);
		p[3].Set(p[0].x, p[2].y, -256);
		vid.DrawLine(&p[0], &p[1], NULL, NULL, false);
		vid.DrawLine(&p[1], &p[2], NULL, NULL, false);
		vid.DrawLine(&p[2], &p[3], NULL, NULL, false);
		vid.DrawLine(&p[3], &p[0], NULL, NULL, false);

		p[0].Set(c.x-adj, c.y-rad-adj, -256); rotateWheelBoxes[2][0] = p[0]-s;
		p[2].Set(c.x+adj, c.y-rad+adj, -256); rotateWheelBoxes[2][1] = p[2]-s;
		p[1].Set(p[2].x, p[0].y, -256);
		p[3].Set(p[0].x, p[2].y, -256);
		vid.DrawLine(&p[0], &p[1], NULL, NULL, false);
		vid.DrawLine(&p[1], &p[2], NULL, NULL, false);
		vid.DrawLine(&p[2], &p[3], NULL, NULL, false);
		vid.DrawLine(&p[3], &p[0], NULL, NULL, false);

		p[0].Set(c.x-adj, c.y+rad-adj, -256); rotateWheelBoxes[3][0] = p[0]-s;
		p[2].Set(c.x+adj, c.y+rad+adj, -256); rotateWheelBoxes[3][1] = p[2]-s;
		p[1].Set(p[2].x, p[0].y, -256);
		p[3].Set(p[0].x, p[2].y, -256);
		vid.DrawLine(&p[0], &p[1], NULL, NULL, false);
		vid.DrawLine(&p[1], &p[2], NULL, NULL, false);
		vid.DrawLine(&p[2], &p[3], NULL, NULL, false);
		vid.DrawLine(&p[3], &p[0], NULL, NULL, false);
	}

	if ((selectBoxStart.x != -1) && (selectBoxStart.y != -1))
	{
		int mx, my;
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		vector_t mpoint;
		mpoint.x = mx; mpoint.y = my;
		mx = selectBoxStart.x; my = selectBoxStart.y; OVL_MousePosWindowRelative(this, &mx, &my);
		vector_t mpoint2;
		mpoint2.x = mx; mpoint2.y = my;
		p[0].Set(sx+mpoint2.x, sy+mpoint2.y, 0.0);
		p[2].Set(sx+mpoint.x, sy+mpoint.y, 0.0);
		p[1].Set(p[2].x, p[0].y, 0.0);
		p[3].Set(p[0].x, p[2].y, 0.0);
		vid.ColorMode(VCM_FLAT);
		vid.FlatColor(255, 255, 255);
		vid.DrawLine(&p[0], &p[1], NULL, NULL, false);
		vid.DrawLine(&p[1], &p[2], NULL, NULL, false);
		vid.DrawLine(&p[2], &p[3], NULL, NULL, false);
		vid.DrawLine(&p[3], &p[0], NULL, NULL, false);
	}

	Super::OnDraw(sx, sy, dx, dy, clipbox);
}

/*
boolean OFrameView::OnPress(inputevent_t *event)
{
}
*/

/*
boolean OFrameView::OnDrag(inputevent_t *event)
{
}
*/

/*
boolean OFrameView::OnRelease(inputevent_t *event)
{
}
*/

static bool RayPolyIntersect(vector_t& lu, vector_t& lv, vector_t& v0, vector_t& v1, vector_t& v2,
							 float* outT, float* outU, float* outV)
{
	vector_t e1 = v1-v0;
	vector_t e2 = v2-v0;
	vector_t p = lv ^ e2;
	float a = e1*p;
	if (fabs(a) < 1E-4) return(0);
	float f = 1.f/a;
	vector_t s = lu-v0;
	float u = f*(s*p);
	if ((u < 0.f) || (u > 1.f)) return(0);
	vector_t q = s ^ e1;
	float v = f*(lv*q);
	if ((v < 0.f) || ((u+v) > 1.f)) return(0);
	float t = f*(e2*q);
	if (outT) *outT = t;
	if (outU) *outU = u;
	if (outV) *outV = v;
	return(1);
}

static void GetBarys(vector_t &p, vector_t &v0, vector_t &v1, vector_t &v2, vector_t &out)
{
	vector_t u,v,w,t,pm;
	matrix_t m;
	float d,d1,d2,d3;

	u = v2 - v0;
	v = v1 - v0;
	w = u ^ v;

	t.Set(1,0,0);
	d = u * (v ^ w);
	d1 = t * (v ^ w);
	d2 = u * (t ^ w);
	d3 = u * (v ^ t);
	m.Data[0][0] = d1/d; m.Data[0][1] = d2/d; m.Data[0][2] = d3/d; m.Data[0][3] = 0;
	t.Set(0,1,0);
	d = u * (v ^ w);
	d1 = t * (v ^ w);
	d2 = u * (t ^ w);
	d3 = u * (v ^ t);
	m.Data[1][0] = d1/d; m.Data[1][1] = d2/d; m.Data[1][2] = d3/d; m.Data[1][3] = 0;
	t.Set(0,0,1);
	d = u * (v ^ w);
	d1 = t * (v ^ w);
	d2 = u * (t ^ w);
	d3 = u * (v ^ t);
	m.Data[2][0] = d1/d; m.Data[2][1] = d2/d; m.Data[2][2] = d3/d; m.Data[2][3] = 0;
	t = -v0;
	d = u * (v ^ w);
	d1 = t * (v ^ w);
	d2 = u * (t ^ w);
	d3 = u * (v ^ t);
	m.Data[3][0] = d1/d; m.Data[3][1] = d2/d; m.Data[3][2] = d3/d; m.Data[3][3] = 1;
	
	pm = p * m;
	out.z = pm.x;
	out.y = pm.y;
	out.x = 1.0 - out.z - out.y;
}

boolean OFrameView::OnPressCommand(int argNum, char **argList)
{
	OVLCMDSTART

	OVLCMD("moveforward") { camera.MoveForward(mdl_moveSpeed*sys_frameTime); return(1); }
	OVLCMD("movebackward") { camera.MoveForward(-mdl_moveSpeed*sys_frameTime); return(1); }
	OVLCMD("moveright") { camera.MoveRight(mdl_moveSpeed*sys_frameTime); return(1); }
	OVLCMD("moveleft") { camera.MoveRight(-mdl_moveSpeed*sys_frameTime); return(1); }
	OVLCMD("moveup") { camera.MoveUp(mdl_moveSpeed*sys_frameTime); return(1); }
	OVLCMD("movedown") { camera.MoveUp(-mdl_moveSpeed*sys_frameTime); return(1); }
	OVLCMD("turnright") { camera.TiltX(mdl_turnSpeed*sys_frameTime); return(1); }
	OVLCMD("turnleft") { camera.TiltX(-mdl_turnSpeed*sys_frameTime); return(1); }
	OVLCMD("lookdown") { camera.TiltY(mdl_turnSpeed*sys_frameTime); return(1); }
	OVLCMD("lookup") { camera.TiltY(-mdl_turnSpeed*sys_frameTime); return(1); }
	OVLCMD("tiltright") { camera.TiltZ(mdl_turnSpeed*sys_frameTime); return(1); }
	OVLCMD("tiltleft") { camera.TiltZ(-mdl_turnSpeed*sys_frameTime); return(1); }
	
	OVLCMD("rotate")
	{
		int mx, my;
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
			return(1);
		vector_t mp(mx,my,0);
		oldMouseX = mx; oldMouseY = my;
		rotateType = 0;
		if ((mx >= rotateWheelBoxes[0][0].x) && (mx <= rotateWheelBoxes[0][1].x)
		 && (my >= rotateWheelBoxes[0][0].y) && (my <= rotateWheelBoxes[0][1].y))
			rotateType = 1;
		else if ((mx >= rotateWheelBoxes[1][0].x) && (mx <= rotateWheelBoxes[1][1].x)
		 && (my >= rotateWheelBoxes[1][0].y) && (my <= rotateWheelBoxes[1][1].y))
			rotateType = 1;
		else if ((mx >= rotateWheelBoxes[2][0].x) && (mx <= rotateWheelBoxes[2][1].x)
		 && (my >= rotateWheelBoxes[2][0].y) && (my <= rotateWheelBoxes[2][1].y))
			rotateType = 2;
		else if ((mx >= rotateWheelBoxes[3][0].x) && (mx <= rotateWheelBoxes[3][1].x)
		 && (my >= rotateWheelBoxes[3][0].y) && (my <= rotateWheelBoxes[3][1].y))
			rotateType = 2;
		else if (mp.Distance(rotateWheelCenter) <= (rotateWheelRadius+5))
			rotateType = 3;
		if (anchorActive)
		{
			camera.SetTarget(anchorPoint);
			rotateType += 4;
		}
		OVL_LockInput(this);
		return(1);
	}

	OVLCMD("pan")
	{
		int mx, my;
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
			return(1);
		oldMouseX = mx; oldMouseY = my;
		OVL_LockInput(this);
		return(1);
	}

	OVLCMD("zoom")
	{
		int mx, my;
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
			return(1);
		oldMouseX = mx; oldMouseY = my;
		OVL_LockInput(this);
		return(1);
	}

	OVLCMD("gridmove")
	{
		int mx, my;
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
			return(1);
		oldMouseX = mx; oldMouseY = my;
		OVL_LockInput(this);
		return(1);
	}

	OVLCMD("select")
	{
		int i, mx, my;
		plane_t pln;
		float dist, neardist;
		vector_t mpoint, lu, lv;
		meshTri_t *tri, *neartri;
		baseTri_t *baseTris, *refBaseTris, *btri;
		vector_t p[4];
		frameVert_t *frameVerts;
		OWorkspace *ws = (OWorkspace *)this->parent;

		baseTris = NULL;
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		baseTris = frame->GetBaseTris();
		if (!baseTris)
			return(1);
		refBaseTris = ws->mdx->refFrame->GetBaseTris();
		if (!refBaseTris)
			return(1);
		frameVerts = frame->GetVerts();
		if (!frameVerts)
			return(1);
		mx = in_MouseX; my = in_MouseY;
		if (in_keyFlags & KF_ALT)
		{
			selectBoxStart.x = mx;
			selectBoxStart.y = my;
			OVL_LockInput(this);
			return(1);
		}
		OVL_MousePosWindowRelative(this, &mx, &my);
		if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
			return(1);
		mx -= (dim.x-6)/2; my -= (dim.y-6-12)/2;
		mpoint.x = mx*(dim.x-6)/256.0; mpoint.y = my*(dim.y-6-12)/256.0;
		mpoint.x += (dim.x-6)/2; mpoint.y += (dim.y-6-12)/2;
		camera.TransViewToWorldLine(mpoint, lu, lv);
		neartri = NULL;
		neardist = FLT_MAX;
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			btri = &baseTris[i];
			if (!(btri->flags & BTF_INUSE))
				btri = &refBaseTris[i];
			if (!(in_keyFlags & KF_CONTROL))
			{
				tri->flags &= ~TF_SELECTED;
				btri->flags &= ~(BTF_VM0|BTF_VM1|BTF_VM2);
			}
			if (tri->flags & TF_HIDDEN)
				continue;
			p[0] = frameVerts[tri->verti[0]].pos;
			p[1] = frameVerts[tri->verti[1]].pos;
			p[2] = frameVerts[tri->verti[2]].pos;
			pln.TriExtract(p[0], p[1], p[2]);
			dist = pln.IntersectionUV(lu, lv, mpoint);
			if ((dist >= 0.0) && (dist < neardist))
			{
				if (PointInPoly(mpoint, p, pln))
				{
					neartri = tri;
					neardist = dist;
					//mdl_debugVec = mpoint;
				}
			}
		}
		if (neartri)
			neartri->flags ^= TF_SELECTED;
		return(1);
	}

	OVLCMD("paint")
	{
		int i, mx, my, xo, yo;
		plane_t pln;
		float dist, neardist;
		vector_t mpoint, lu, lv;
		meshTri_t *tri, *neartri;
		baseTri_t *baseTris, *refBaseTris, *btri, *nearbtri;
		vector_t p[4], tv[4];
		frameVert_t *frameVerts;
		//unsigned short *scrBuf;
		int k;//, scrPitch;
		OWorkspace *ws = (OWorkspace *)this->parent;
		modelSkin_t *skin;

		baseTris = NULL;
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		baseTris = frame->GetBaseTris();
		if (!baseTris)
			return(1);
		refBaseTris = ws->mdx->refFrame->GetBaseTris();
		if (!refBaseTris)
			return(1);
		frameVerts = frame->GetVerts();
		if (!frameVerts)
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
			return(1);
		mx -= (dim.x-6)/2; my -= (dim.y-6-12)/2;
		mpoint.x = mx*(dim.x-6)/256.0; mpoint.y = my*(dim.y-6-12)/256.0;
		mpoint.x += (dim.x-6)/2; mpoint.y += (dim.y-6-12)/2;
		camera.TransViewToWorldLine(mpoint, lu, lv);
		neartri = NULL;
		nearbtri = NULL;
		neardist = FLT_MAX;
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			btri = &baseTris[i];
			if (tri->flags & TF_HIDDEN)
				continue;
			if (!(btri->flags & BTF_INUSE))
				btri = &refBaseTris[i];
			p[0] = frameVerts[tri->verti[0]].pos;
			p[1] = frameVerts[tri->verti[1]].pos;
			p[2] = frameVerts[tri->verti[2]].pos;
			pln.TriExtract(p[0], p[1], p[2]);
			dist = pln.IntersectionUV(lu, lv, mpoint);
			if ((dist >= 0.0) && (dist < neardist))
			{
				if (PointInPoly(mpoint, p, pln))
				{
					neartri = tri;
					nearbtri = btri;
					neardist = dist;
					//mdl_debugVec = mpoint;
				}
			}
		}
		if ((!neartri) || (!nearbtri) || (!(nearbtri->flags & BTF_INUSE)) || (!(ws->mdx->skins[nearbtri->skinIndex].flags & MRF_INUSE)))
			return(1);
		vid.ColorMode(VCM_TEXTURE);
		skin = &ws->mdx->skins[nearbtri->skinIndex];
		for (k=0;k<3;k++)
		{
			float aspect = (float)skin->tex->height / (float)skin->tex->width;
			//tv[k].x = nearbtri->tverts[k].x;//*256.0/skin->tex->width;
			//tv[k].y = nearbtri->tverts[k].y;//*256.0/skin->tex->height;
			tv[k].x = nearbtri->tverts[k].x*256.0/skin->tex->width;
			tv[k].y = nearbtri->tverts[k].y*256.0/skin->tex->height;
			if (aspect < 1)
				tv[k].y *= aspect;
			else
				tv[k].x /= aspect;
		}
		p[0] = frameVerts[neartri->verti[0]].pos;
		p[1] = frameVerts[neartri->verti[1]].pos;
		p[2] = frameVerts[neartri->verti[2]].pos;
#if 0
		vid.TexActivate(ws->mdx->skins[nearbtri->skinIndex].tex, VTA_XO);
		vid.ForceDraw(true);
		vid.WindingMode(VWM_SHOWALL);
		camera.DrawTriangle(p, NULL, NULL, tv, true);
		vid.LockScreen(VLS_READBACK, &scrBuf, &scrPitch);
		xo = scrBuf[in_MouseY*scrPitch+in_MouseX];
		vid.UnlockScreen();
		vid.ColorMode(VCM_TEXTURE);
		vid.TexActivate(*vid.blankTex, VTA_NORMAL); // need intermediate texture between mode change (vid interface texture caching caveat)
		vid.TexActivate(ws->mdx->skins[nearbtri->skinIndex].tex, VTA_YO);
		p[0] = frameVerts[neartri->verti[0]].pos;
		p[1] = frameVerts[neartri->verti[1]].pos;
		p[2] = frameVerts[neartri->verti[2]].pos;
		camera.DrawTriangle(p, NULL, NULL, tv, true);
		vid.ForceDraw(false);
		vid.WindingMode(VWM_SHOWCLOCKWISE);
		vid.LockScreen(VLS_READBACK, &scrBuf, &scrPitch);
		yo = scrBuf[in_MouseY*scrPitch+in_MouseX];
		vid.UnlockScreen();
#else
		for (k=0;k<3;k++)
			tv[k] = nearbtri->tverts[k];
		float u, v;
		if (!RayPolyIntersect(lu, lv, p[0], p[1], p[2], NULL, &u, &v))
			return(1);
		xo = tv[1].x*u + tv[2].x*v + tv[0].x*(1.f-(u+v));
		yo = tv[1].y*u + tv[2].y*v + tv[0].y*(1.f-(u+v));
#endif
		VCR_Record(VCRA_UNDO, "$skinpaint", Undo_SkinPaint, 8192, NULL);
		VCR_WriteInt((unsigned long)(((OWorkspace *)this->parent)->mdx->skins));
		OVL_SkinPaint(skin, xo, yo, brushsize, 1.0, false, antialias);
		vid.TexReload(skin->tex);
		return(1);
	}

	OVLCMD("eyedrop") // FIXME: too much cut&pasted code (90% of this is identical to paint
	{
		int i, mx, my, xo, yo, r, g, b, wv;
		plane_t pln;
		float dist, neardist;
		vector_t mpoint, lu, lv;
		meshTri_t *tri, *neartri;
		baseTri_t *baseTris, *refBaseTris, *btri, *nearbtri;
		vector_t p[4], tv[4];
		frameVert_t *frameVerts;
		unsigned short *scrBuf;
		int k, scrPitch;
		OWorkspace *ws = (OWorkspace *)this->parent;
		modelSkin_t *skin;

		baseTris = NULL;
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		baseTris = frame->GetBaseTris();
		if (!baseTris)
			return(1);
		refBaseTris = ws->mdx->refFrame->GetBaseTris();
		if (!refBaseTris)
			return(1);
		frameVerts = frame->GetVerts();
		if (!frameVerts)
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
			return(1);
		mx -= (dim.x-6)/2; my -= (dim.y-6-12)/2;
		mpoint.x = mx*(dim.x-6)/256.0; mpoint.y = my*(dim.y-6-12)/256.0;
		mpoint.x += (dim.x-6)/2; mpoint.y += (dim.y-6-12)/2;
		camera.TransViewToWorldLine(mpoint, lu, lv);
		neartri = NULL;
		nearbtri = NULL;
		neardist = FLT_MAX;
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			btri = &baseTris[i];
			if (tri->flags & TF_HIDDEN)
				continue;
			if (!(btri->flags & BTF_INUSE))
				btri = &refBaseTris[i];
			p[0] = frameVerts[tri->verti[0]].pos;
			p[1] = frameVerts[tri->verti[1]].pos;
			p[2] = frameVerts[tri->verti[2]].pos;
			pln.TriExtract(p[0], p[1], p[2]);
			dist = pln.IntersectionUV(lu, lv, mpoint);
			if ((dist >= 0.0) && (dist < neardist))
			{
				if (PointInPoly(mpoint, p, pln))
				{
					neartri = tri;
					nearbtri = btri;
					neardist = dist;
					//mdl_debugVec = mpoint;
				}
			}
		}
		if ((!neartri) || (!nearbtri) || (!(nearbtri->flags & BTF_INUSE)) || (!(ws->mdx->skins[nearbtri->skinIndex].flags & MRF_INUSE)))
			return(1);
		vid.ColorMode(VCM_TEXTURE);
		skin = &ws->mdx->skins[nearbtri->skinIndex];
		for (k=0;k<3;k++)
		{
			float aspect = (float)skin->tex->height / (float)skin->tex->width;
			//tv[k].x = nearbtri->tverts[k].x;//*256.0/skin->tex->width;
			//tv[k].y = nearbtri->tverts[k].y;//*256.0/skin->tex->height;
			tv[k].x = nearbtri->tverts[k].x*256.0/skin->tex->width;
			tv[k].y = nearbtri->tverts[k].y*256.0/skin->tex->height;
			if (aspect < 1)
				tv[k].y *= aspect;
			else
				tv[k].x /= aspect;
		}
		vid.TexActivate(ws->mdx->skins[nearbtri->skinIndex].tex, VTA_XO);
		p[0] = frameVerts[neartri->verti[0]].pos;
		p[1] = frameVerts[neartri->verti[1]].pos;
		p[2] = frameVerts[neartri->verti[2]].pos;
		vid.ForceDraw(true);
		vid.WindingMode(VWM_SHOWALL);
		camera.DrawTriangle(p, NULL, NULL, tv, true);
		vid.LockScreen(VLS_READBACK, &scrBuf, &scrPitch);
		xo = scrBuf[in_MouseY*scrPitch+in_MouseX];
		vid.UnlockScreen();
		vid.ColorMode(VCM_TEXTURE);
		vid.TexActivate(*vid.blankTex, VTA_NORMAL); // need intermediate texture between mode change (vid interface texture caching caveat)
		vid.TexActivate(ws->mdx->skins[nearbtri->skinIndex].tex, VTA_YO);
		p[0] = frameVerts[neartri->verti[0]].pos;
		p[1] = frameVerts[neartri->verti[1]].pos;
		p[2] = frameVerts[neartri->verti[2]].pos;
		camera.DrawTriangle(p, NULL, NULL, tv, true);
		vid.ForceDraw(false);
		vid.WindingMode(VWM_SHOWCLOCKWISE);
		vid.LockScreen(VLS_READBACK, &scrBuf, &scrPitch);
		yo = scrBuf[in_MouseY*scrPitch+in_MouseX];
		vid.UnlockScreen();
		if ((xo < 0) || (xo >= (I32)skin->tex->width) || (yo < 0) || (yo >= (I32)skin->tex->height))
			return(1);
		wv = skin->tex->tex_data[yo*skin->tex->width+xo];
		r = (wv >> 10) & 31; g = (wv >> 5) & 31; b = wv & 31;
		skin_curColor.Set(r<<3, g<<3, b<<3);
		if (skin_hsvMode)
			skin_curColor = RGB2HSV(skin_curColor);
		if (OPalette *palw = (OPalette *)OVL_FindChild(NULL, NULL, "OPalette", NULL))
			palw->InvalidatePalColors();
		return(1);
	}

	OVLCMD("grab")
	{
		meshTri_t *tri;
		baseTri_t *baseTris, *btri;
		frameVert_t *frameVerts;
		int i, k;
		float scale;
		vector_t min, max;
		
		OWorkspace *ws = (OWorkspace *)this->parent;
		if (!(ws->mdx->skins[grabSkinIndex].flags & MRF_INUSE))
		{
			for (i=grabSkinIndex+1;i!=grabSkinIndex;i++)
			{
				if (i == WS_MAXSKINS)
					i = 0;
				if ((i == grabSkinIndex) || (ws->mdx->skins[i].flags & MRF_INUSE))
					break;
			}
			grabSkinIndex = i;
			if (!(ws->mdx->skins[grabSkinIndex].flags & MRF_INUSE))
				return(1);
		}
		baseTris = NULL;
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		baseTris = frame->GetBaseTris();
		if (!baseTris)
			return(1);
		frameVerts = frame->GetVerts();
		if (!frameVerts)
			return(1);
		scale = 1.0;
		min.Set(FLT_MAX, FLT_MAX, 0);
		max.Set(-FLT_MAX, -FLT_MAX, 0);
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			btri = &baseTris[i];
			btri->flags &= ~(BTF_VM0|BTF_VM1|BTF_VM2);
			if (tri->flags & TF_SELECTED)
			{
				btri->tverts[0] = frameVerts[tri->verti[0]].pos; camera.TransWorldToCamera(&btri->tverts[0]); btri->tverts[0].y = -btri->tverts[0].y; btri->tverts[0].z = 0;
				btri->tverts[1] = frameVerts[tri->verti[1]].pos; camera.TransWorldToCamera(&btri->tverts[1]); btri->tverts[1].y = -btri->tverts[1].y; btri->tverts[1].z = 0;
				btri->tverts[2] = frameVerts[tri->verti[2]].pos; camera.TransWorldToCamera(&btri->tverts[2]); btri->tverts[2].y = -btri->tverts[2].y; btri->tverts[2].z = 0;
				btri->flags |= BTF_INUSE;
				btri->skinIndex = grabSkinIndex;
			}
		}
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			btri = &baseTris[i];
			if (tri->flags & TF_SELECTED)
			{
				for (k=0;k<3;k++)
				{
					if (btri->tverts[k].x < min.x)
						min.x = btri->tverts[k].x;
					if (btri->tverts[k].y < min.y)
						min.y = btri->tverts[k].y;
					if (btri->tverts[k].x > max.x)
						max.x = btri->tverts[k].x;
					if (btri->tverts[k].y > max.y)
						max.y = btri->tverts[k].y;
				}
			}
		}
		scale = 200.0/(max.x - min.x);
		if ((200.0/(max.y - min.y)) < scale)
			scale = 200.0/(max.y - min.y);
		//if (scale > 1.0)
		//	scale = 1.0;
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			btri = &baseTris[i];
			if (tri->flags & TF_SELECTED)
			{
				for (k=0;k<3;k++)
				{
					btri->tverts[k] -= min;
					btri->tverts[k] *= scale;
				}
			}
		}
		return(1);
	}

	OVLCMD("grabunfold")
	{
		int i, k, mx, my;
		plane_t pln;
		float dist, neardist, scale;
		vector_t mpoint, lu, lv;
		meshTri_t *tri, *neartri;
		baseTri_t *baseTris, *btri, *nearbtri;
		frameVert_t *frameVerts;
		vector_t p[4];
		vector_t min, max;
		
		OWorkspace *ws = (OWorkspace *)this->parent;
		if (!(ws->mdx->skins[grabSkinIndex].flags & MRF_INUSE))
		{
			for (i=grabSkinIndex+1;i!=grabSkinIndex;i++)
			{
				if (i == WS_MAXSKINS)
					i = 0;
				if ((i == grabSkinIndex) || (ws->mdx->skins[i].flags & MRF_INUSE))
					break;
			}
			grabSkinIndex = i;
			if (!(ws->mdx->skins[grabSkinIndex].flags & MRF_INUSE))
				return(1);
		}
		baseTris = NULL;
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		baseTris = frame->GetBaseTris();
		if (!baseTris)
			return(1);
		frameVerts = frame->GetVerts();
		if (!frameVerts)
			return(1);

		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
			return(1);
		mx -= (dim.x-6)/2; my -= (dim.y-6-12)/2;
		mpoint.x = mx*(dim.x-6)/256.0; mpoint.y = my*(dim.y-6-12)/256.0;
		mpoint.x += (dim.x-6)/2; mpoint.y += (dim.y-6-12)/2;
		camera.TransViewToWorldLine(mpoint, lu, lv);
		neartri = NULL;
		nearbtri = NULL;
		neardist = FLT_MAX;
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			btri = &baseTris[i];
			tri->flags &= ~TF_SELECTED;
			if (tri->flags & TF_HIDDEN)
				continue;
			p[0] = frameVerts[tri->verti[0]].pos;
			p[1] = frameVerts[tri->verti[1]].pos;
			p[2] = frameVerts[tri->verti[2]].pos;
			pln.TriExtract(p[0], p[1], p[2]);
			dist = pln.IntersectionUV(lu, lv, mpoint);
			if ((dist >= 0.0) && (dist < neardist))
			{
				if (PointInPoly(mpoint, p, pln))
				{
					neartri = tri;
					nearbtri = btri;
					neardist = dist;
				}
			}
		}
		if ((!neartri) || (!nearbtri))
			return(1);
		if ((!origamiTri) || (in_keyFlags & KF_CONTROL))
		{
			VCR_Record(VCRA_UNDO, "$basemanip", Undo_BaseManip, mesh->numTris*36 + 16, NULL);
			VCR_WriteBulk(&this->parent, 4);
			VCR_WriteBulk(&frame, 4);
			VCR_WriteInt(frame->flags & MRF_MODIFIED);
			VCR_WriteInt(frame->numTris);
			for (i=0;i<frame->numTris;i++)
			{
				btri = &baseTris[i];
				tri = &mesh->meshTris[i];
				for (k=0;k<3;k++)
				{
					VCR_WriteFloat(btri->tverts[k].x);
					VCR_WriteFloat(btri->tverts[k].y);
					VCR_WriteFloat(btri->tverts[k].z);
				}
			}
			origamiTri = tri = neartri;
			origamiBTri = btri = nearbtri;
			origamiTri->flags |= TF_SELECTED;
			btri->flags &= ~(BTF_VM0|BTF_VM1|BTF_VM2);
			if (!(btri->flags & BTF_INUSE))
			{
				btri->tverts[0] = frameVerts[tri->verti[0]].pos; camera.TransWorldToCamera(&btri->tverts[0]); btri->tverts[0].y = -btri->tverts[0].y; btri->tverts[0].z = 0;
				btri->tverts[1] = frameVerts[tri->verti[1]].pos; camera.TransWorldToCamera(&btri->tverts[1]); btri->tverts[1].y = -btri->tverts[1].y; btri->tverts[1].z = 0;
				btri->tverts[2] = frameVerts[tri->verti[2]].pos; camera.TransWorldToCamera(&btri->tverts[2]); btri->tverts[2].y = -btri->tverts[2].y; btri->tverts[2].z = 0;
				btri->flags |= BTF_INUSE;
				btri->skinIndex = grabSkinIndex;
				min.Set(FLT_MAX, FLT_MAX, 0);
				max.Set(-FLT_MAX, -FLT_MAX, 0);
				for (k=0;k<3;k++)
				{
					if (btri->tverts[k].x < min.x)
						min.x = btri->tverts[k].x;
					if (btri->tverts[k].y < min.y)
						min.y = btri->tverts[k].y;
					if (btri->tverts[k].x > max.x)
						max.x = btri->tverts[k].x;
					if (btri->tverts[k].y > max.y)
						max.y = btri->tverts[k].y;
				}
				scale = 200.0/(max.x - min.x);
				if ((200.0/(max.y - min.y)) < scale)
					scale = 200.0/(max.y - min.y);
				for (k=0;k<3;k++)
				{
					btri->tverts[k] -= min;
					btri->tverts[k] *= scale;
				}
			}
			return(1);
		}
		else
		{
			VCR_Record(VCRA_UNDO, "$basemanip", Undo_BaseManip, mesh->numTris*36 + 16, NULL);
			VCR_WriteBulk(&this->parent, 4);
			VCR_WriteBulk(&frame, 4);
			VCR_WriteInt(frame->flags & MRF_MODIFIED);
			VCR_WriteInt(frame->numTris);
			for (i=0;i<frame->numTris;i++)
			{
				btri = &baseTris[i];
				tri = &mesh->meshTris[i];
				for (k=0;k<3;k++)
				{
					VCR_WriteFloat(btri->tverts[k].x);
					VCR_WriteFloat(btri->tverts[k].y);
					VCR_WriteFloat(btri->tverts[k].z);
				}
			}			
			origamiTri->flags |= TF_SELECTED;
			tri = neartri;
			btri = nearbtri;
			int n1, n2, n3, n4;
			n4 = -1;
			for (k=0;k<3;k++)
			{
				if ((tri - mesh->meshTris) == (origamiTri->edgeTris[k] & 0x3FFF))
				{
					n4 = k;
					n3 = (k+1)%3;
				}
			}
			if (n4 == -1)
				return(1);
			n1 = (origamiTri->edgeTris[n4] & 0xC000) >> 14;
			n2 = (n1+1)%3;
/*
			for (k=0;k<3;k++)
			{
				if (tri->verti[n1] == origamiTri->verti[k])
					n3 = k;
				if (tri->verti[n2] == origamiTri->verti[k])
					n4 = k;
			}
*/
			// two of the tverts are now known
			btri->tverts[n1] = origamiBTri->tverts[n3];
			btri->tverts[n1].z = 0;
			btri->tverts[n2] = origamiBTri->tverts[n4];
			btri->tverts[n2].z = 0;

			// determine the third by its relationship (distance and location) from line of other two verts
			vector_t vup(0.0, 1.0, 0.0);
			p[0] = frameVerts[tri->verti[0]].pos;
			p[1] = frameVerts[tri->verti[1]].pos;
			p[2] = frameVerts[tri->verti[2]].pos;
			pln.TriExtract(p[0], p[1], p[2]);
			matrix_t unfoldMat = MatRotation(pln.n, vup);

			vector_t otherpt = frameVerts[tri->verti[(n1+2)%3]].pos;
			otherpt *= unfoldMat;
			vector_t nearotherpt;
			vector_t lu = frameVerts[tri->verti[n1]].pos * unfoldMat;
			vector_t lv = (frameVerts[tri->verti[n2]].pos * unfoldMat) - lu;
			float actuallen = lv.Length();
			lv.Normalize();
			vector_t tlu = btri->tverts[n1];
			vector_t tlv = btri->tverts[n2] - tlu;
			float projlen = tlv.Length();
			tlv.Normalize();
			float lineloc = otherpt.NearestUV(lu, lv, nearotherpt);
			float neardist = otherpt.Distance(nearotherpt);
			lineloc /= actuallen;
			lineloc *= projlen;
			neardist /= actuallen;
			neardist *= projlen;		
			otherpt = tlv;
			otherpt *= lineloc;
			otherpt += tlu;
			vector_t tlvnorm(-tlv.y, tlv.x, 0.0);
			tlvnorm *= neardist;
			otherpt += tlvnorm;
			otherpt.x = (int)otherpt.x;
			otherpt.y = (int)otherpt.y;
			otherpt.z = (int)otherpt.z;
			btri->flags |= BTF_INUSE;
			/*
			if ((otherpt.x < 0) || (otherpt.x >= ws->mdx->skins[grabSkinIndex].tex->width)
				|| (otherpt.y < 0) || (otherpt.y > ws->mdx->skins[grabSkinIndex].tex->height))
			{
				btri->tverts[0].Set(-1,-1,0);
				btri->tverts[1].Set(-1,-1,0);
				btri->tverts[2].Set(-1,-1,0);
				btri->flags &= ~BTF_INUSE;
				return(1); // don't allow if boundaries are broken
			}
			*/
			btri->tverts[(n1+2)%3] = otherpt;
			CON->Execute(this, "unselectall", 0);
			origamiTri->flags &= ~TF_SELECTED;
			origamiTri = tri;
			origamiTri->flags |= TF_SELECTED;
			origamiBTri = btri;

			return(1);

		}
	}

	OVLCMD("selectall")
	{
		int i;
		meshTri_t *tri;

		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			tri->flags |= TF_SELECTED;
		}
		return(1);
	}
	OVLCMD("unselectall")
	{
		int i;
		meshTri_t *tri;

		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			tri->flags &= ~TF_SELECTED;
		}
		return(1);
	}
	OVLCMD("selectallfront")
	{
		int i;
		meshTri_t *tri;
		frameVert_t *frameVerts;
		vector_t p[4];
		plane_t pln;

		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		frameVerts = frame->GetVerts();
		if (!frameVerts)
			return(1);
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			p[0] = frameVerts[tri->verti[0]].pos;
			p[1] = frameVerts[tri->verti[1]].pos;
			p[2] = frameVerts[tri->verti[2]].pos;
			camera.TransWorldToCamera(&p[0]);
			camera.TransWorldToCamera(&p[1]);
			camera.TransWorldToCamera(&p[2]);
			pln.TriExtract(p[0], p[1], p[2]);
			if (pln.n.z > 0)
				tri->flags |= TF_SELECTED;
			else
				tri->flags &= ~TF_SELECTED;
		}
		return(1);
	}
	OVLCMD("selectalluntextured")
	{
		int i;
		meshTri_t *tri;
		baseTri_t *baseTris, *btri;

		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		baseTris = frame->GetBaseTris();
		if (!baseTris)
			return(1);
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			btri = &baseTris[i];
			if (!(btri->flags & BTF_INUSE))
				tri->flags |= TF_SELECTED;
			else
				tri->flags &= ~TF_SELECTED;
		}
		return(1);
	}
	OVLCMD("switchselected")
	{
		int i;
		meshTri_t *tri;

		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			tri->flags ^= TF_SELECTED;
		}
		return(1);
	}
	OVLCMD("hideselected")
	{
		int i;
		meshTri_t *tri;

		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
//			tri->flags &= ~TF_HIDDEN;
			if (tri->flags & TF_SELECTED)
				tri->flags |= TF_HIDDEN;
		}
		return(1);
	}
	OVLCMD("showall")
	{
		int i;
		meshTri_t *tri;

		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			tri->flags &= ~TF_HIDDEN;
		}
		return(1);
	}
	
	OVLCMD("getseqhidden")
	{
		CON->Printf("Debug: SetSeqHidden called");

		OWorkspace *ws = (OWorkspace *)this->parent;
		meshTri_t* tri;
		int i;
		modelSequence_t *s = ws->GetTopmostSequence();
		if (!s)
			return(1);

		CON->Printf("Debug: Sequence found");

		for (seqTrigger_t* trig = s->triggers.next; trig!=&s->triggers; trig = trig->next)
		{
			if (trig->triggerBinData && trig->trigger && !_stricmp(trig->trigger, "_HIDDENTRIS"))
				break;
		}
		if (trig == &s->triggers)
		{
			for (i=0;i<mesh->numTris;i++)
			{
				tri = &mesh->meshTris[i];
				tri->flags &= ~TF_HIDDEN;
			}
			return(1);
		}

		CON->Printf("Debug: HiddenTris block found");
		
		for (i=0;i<trig->triggerBinSize&&i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			if (trig->triggerBinData[i] & 1)
				tri->flags |= TF_HIDDEN;
			else
				tri->flags &= ~TF_HIDDEN;
		}
		CON->Printf("Debug: Hidden tris recalled");
		return(1);
	}
	OVLCMD("setseqhidden")
	{
		CON->Printf("Debug: SetSeqHidden called");

		OWorkspace *ws = (OWorkspace *)this->parent;
		modelSequence_t *s = ws->GetTopmostSequence();
		if (!s)
			return(1);

		CON->Printf("Debug: Sequence found");
		
		for (seqTrigger_t* trig = s->triggers.next; trig!=&s->triggers; trig = trig->next)
		{
			if (trig->triggerBinData && trig->trigger && !_stricmp(trig->trigger, "_HIDDENTRIS"))
				break;
		}
		if (trig == &s->triggers)
		{
			CON->Printf("Debug: HiddenTris block created");

			trig = s->AddTrigger();
			if (trig->trigger)
				FREE(trig->trigger);
			char* buf = "_HIDDENTRIS";
			trig->trigger = ALLOC(char, strlen(buf)+1);
			strcpy(trig->trigger, buf);
			if (trig->triggerBinData)
				FREE(trig->triggerBinData);
			trig->triggerBinSize = mesh->numTris;
			trig->triggerBinData = ALLOC(byte, trig->triggerBinSize);
			memset(trig->triggerBinData, 0, trig->triggerBinSize);
		}
		for (int i=0;i<trig->triggerBinSize&&i<mesh->numTris;i++)
		{
			meshTri_t* tri = &mesh->meshTris[i];
			if (tri->flags & TF_HIDDEN)
				trig->triggerBinData[i] |= 1;
			else
				trig->triggerBinData[i] &= ~1;
		}		
		CON->Printf("Debug: Hidden tris set");
		return(1);
	}
	
	OVLCMD("vertlighttogselected")
	{
		int i;
		meshTri_t *tri;

		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			if (tri->flags & TF_SELECTED)
				tri->flags ^= TF_NOVERTLIGHT;
		}
		return(1);
	}
	OVLCMD("transparenttogselected")
	{
		int i;
		meshTri_t *tri;

		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			if (tri->flags & TF_SELECTED)
				tri->flags ^= TF_TRANSPARENT;
		}
		return(1);
	}
	OVLCMD("speculartogselected")
	{
		int i;
		meshTri_t *tri;

		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			if (tri->flags & TF_SELECTED)
				tri->flags ^= TF_SPECULAR;
		}
		return(1);
	}

	OVLCMD("blacklistselected")
	{	
		int i;
		meshTri_t *tri;
		frameVert_t *frameVerts;

		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		frameVerts = frame->GetVerts();
		if (!frameVerts)
			return(1);
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			if (!(tri->flags & TF_SELECTED))
				continue;
			frameVerts[tri->verti[0]].flags |= FVF_TOUCH;
			frameVerts[tri->verti[1]].flags |= FVF_TOUCH;
			frameVerts[tri->verti[2]].flags |= FVF_TOUCH;
		}
		for (i=0;i<frame->numVerts;i++)
		{
			if (frameVerts[i].flags & FVF_TOUCH)
			{
				frameVerts[i].flags |= FVF_IRRELEVANT;
				frameVerts[i].flags &= ~FVF_TOUCH;
			}
		}
		return(1);
	}

	OVLCMD("setselectedpartgroup")
	{	
		int i, group, px, py;
		meshTri_t *tri;
		frameVert_t *frameVerts;
		modelFrame_t *f;

		OWorkspace *ws = (OWorkspace *)this->parent;
		if (argNum < 2)
			return(1);
		group = atoi(argList[1]);
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		px = vid.resolution->width/2 - 112;
		py = vid.resolution->height/2 - 16;
		vid.DrawString(px, py, 32, 32, "WORKING", true, 128, 128, 128);
		vid.Swap();
		MRL_ITERATENEXT(f,f,ws->mdx->frames)
		{
			frameVerts = f->GetVerts();
			if (!frameVerts)
				continue;
			for (i=0;i<mesh->numTris;i++)
			{
				tri = &mesh->meshTris[i];
				if (!(tri->flags & TF_SELECTED))
					continue;
				frameVerts[tri->verti[0]].flags |= FVF_TOUCH;
				frameVerts[tri->verti[1]].flags |= FVF_TOUCH;
				frameVerts[tri->verti[2]].flags |= FVF_TOUCH;
			}
			for (i=0;i<frame->numVerts;i++)
			{
				if (frameVerts[i].flags & FVF_TOUCH)
				{
					frameVerts[i].groupNum = group;
					frameVerts[i].flags &= ~FVF_TOUCH;
				}
			}
		}
		vid.Swap();
		return(1);
	}

	OVLCMD("selectpartgroup")
	{
		int i, group;
		meshTri_t *tri;
		frameVert_t *frameVerts;

		if (argNum < 2)
			return(1);
		group = atoi(argList[1]);
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		frameVerts = frame->GetVerts();
		if (!frameVerts)
			return(1);
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			if ((frameVerts[tri->verti[0]].groupNum == group)
			 || (frameVerts[tri->verti[1]].groupNum == group)
			 || (frameVerts[tri->verti[2]].groupNum == group))
				tri->flags |= TF_SELECTED;
			else
				tri->flags &= ~TF_SELECTED;
		}
		return(1);
	}

	OVLCMD("viewlodlocktog")
	{
		showLodLocked ^= 1;
		return(1);
	}
	OVLCMD("verttoglodlock")
	{
		int i;
		meshTri_t *tri;
		frameVert_t *frameVerts;

		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		frameVerts = frame->GetVerts();
		if (!frameVerts)
			return(1);
		for (i=0;i<mesh->numVerts;i++)
		{
			frameVerts[i].flags |= FVF_TOUCH;
			for (int j=0;j<mesh->numTris;j++)
			{
				tri = &mesh->meshTris[j];
				if (!(tri->flags & TF_SELECTED))
					continue;
				if ((tri->verti[0]!=i) && (tri->verti[1]!=i) && (tri->verti[2]!=i))
					frameVerts[i].flags &= ~FVF_TOUCH;
			}
			if (frameVerts[i].flags & FVF_TOUCH)
				frameVerts[i].flags ^= FVF_P_LODLOCKED;
			frameVerts[i].flags &= ~FVF_TOUCH;
		}
		return(1);
	}
	
	OVLCMD("unblacklistselected")
	{
		int i;
		meshTri_t *tri;
		frameVert_t *frameVerts;

		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		frameVerts = frame->GetVerts();
		if (!frameVerts)
			return(1);
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			if (!(tri->flags & TF_SELECTED))
				continue;
			frameVerts[tri->verti[0]].flags |= FVF_TOUCH;
			frameVerts[tri->verti[1]].flags |= FVF_TOUCH;
			frameVerts[tri->verti[2]].flags |= FVF_TOUCH;
		}
		for (i=0;i<frame->numVerts;i++)
		{
			if (frameVerts[i].flags & FVF_TOUCH)
			{
				frameVerts[i].flags &= ~(FVF_IRRELEVANT|FVF_TOUCH);
			}
		}
		return(1);
	}
	OVLCMD("blacklistselectedtog")
	{
		int i;
		meshTri_t *tri;
		frameVert_t *frameVerts;

		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		frameVerts = frame->GetVerts();
		if (!frameVerts)
			return(1);
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			if (!(tri->flags & TF_SELECTED))
				continue;
			frameVerts[tri->verti[0]].flags |= FVF_TOUCH;
			frameVerts[tri->verti[1]].flags |= FVF_TOUCH;
			frameVerts[tri->verti[2]].flags |= FVF_TOUCH;
		}
		for (i=0;i<frame->numVerts;i++)
		{
			if (frameVerts[i].flags & FVF_TOUCH)
			{
				frameVerts[i].flags ^= FVF_IRRELEVANT;
				frameVerts[i].flags &= ~FVF_TOUCH;
			}
		}
		return(1);
	}

	OVLCMD("deleteselected")
	{
		int i;
		meshTri_t *tri;
		baseTri_t *baseTris, *btri;

		baseTris = NULL;
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		baseTris = frame->GetBaseTris();
		if (!baseTris)
			return(1);
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			btri = &baseTris[i];
			if (tri->flags & TF_SELECTED)
			{
				btri->flags &= ~BTF_INUSE;
				btri->tverts[0].Set(-1,-1,0);
				btri->tverts[1].Set(-1,-1,0);
				btri->tverts[2].Set(-1,-1,0);
			}
		}
		return(1);
	}

	OVLCMD("rollselectedleft")
	{
		int i;
		meshTri_t *tri;
		baseTri_t *baseTris, *btri;
		vector_t tempv;

		baseTris = NULL;
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		baseTris = frame->GetBaseTris();
		if (!baseTris)
			return(1);
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			btri = &baseTris[i];
			if (tri->flags & TF_SELECTED)
			{
				tempv = btri->tverts[0];
				btri->tverts[0] = btri->tverts[1];
				btri->tverts[1] = btri->tverts[2];
				btri->tverts[2] = tempv;
			}
		}
		return(1);
	}

	OVLCMD("rollselectedright")
	{
		int i;
		meshTri_t *tri;
		baseTri_t *baseTris, *btri;
		vector_t tempv;

		baseTris = NULL;
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		baseTris = frame->GetBaseTris();
		if (!baseTris)
			return(1);
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			btri = &baseTris[i];
			if (tri->flags & TF_SELECTED)
			{
				tempv = btri->tverts[0];
				btri->tverts[0] = btri->tverts[2];
				btri->tverts[2] = btri->tverts[1];
				btri->tverts[1] = tempv;
			}
		}
		return(1);
	}

	OVLCMD("reverseselected")
	{
		int i;
		meshTri_t *tri;
		baseTri_t *baseTris, *btri;
		vector_t tempv;

		baseTris = NULL;
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		baseTris = frame->GetBaseTris();
		if (!baseTris)
			return(1);
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			btri = &baseTris[i];
			if (tri->flags & TF_SELECTED)
			{
				tempv = btri->tverts[0];
				btri->tverts[0] = btri->tverts[2];
				btri->tverts[2] = tempv;
			}
		}
		return(1);
	}

	OVLCMD("anchor")
	{
		int i, mx, my;
		plane_t pln;
		float dist, neardist;
		vector_t mpoint, lu, lv;
		meshTri_t *tri;
		vector_t p[4];
		frameVert_t *frameVerts;

		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		frameVerts = frame->GetVerts();
		if (!frameVerts)
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
			return(1);
		mx -= (dim.x-6)/2; my -= (dim.y-6-12)/2;
		mpoint.x = mx*(dim.x-6)/256.0; mpoint.y = my*(dim.y-6-12)/256.0;
		mpoint.x += (dim.x-6)/2; mpoint.y += (dim.y-6-12)/2;
		camera.TransViewToWorldLine(mpoint, lu, lv);
		neardist = FLT_MAX;
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			if (tri->flags & TF_HIDDEN)
				continue;
			p[0] = frameVerts[tri->verti[0]].pos;
			p[1] = frameVerts[tri->verti[1]].pos;
			p[2] = frameVerts[tri->verti[2]].pos;
			pln.TriExtract(p[0], p[1], p[2]);
			dist = pln.IntersectionUV(lu, lv, mpoint);
			if ((dist >= 0.0) && (dist < neardist))
			{
				if (PointInPoly(mpoint, p, pln))
				{
					neardist = dist;
					anchorPoint = mpoint;
				}
			}
		}
//		camera.SetTarget(anchorPoint);
		return(1);
	}

	OVLCMD("mountset")
	{
		int i, mx, my, nearTriIndex;
		plane_t pln;
		float dist, neardist;
		vector_t mpoint, lu, lv;
		meshTri_t *tri, *nearTri;
		vector_t p[4], nearPoint;
		frameVert_t *frameVerts;
		modelMount_t *m;

		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		if (!mountIndex)
			return(1);
		frameVerts = frame->GetVerts();
		if (!frameVerts)
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
			return(1);
		mx -= (dim.x-6)/2; my -= (dim.y-6-12)/2;
		mpoint.x = mx*(dim.x-6)/256.0; mpoint.y = my*(dim.y-6-12)/256.0;
		mpoint.x += (dim.x-6)/2; mpoint.y += (dim.y-6-12)/2;
		camera.TransViewToWorldLine(mpoint, lu, lv);
		neardist = FLT_MAX;
		nearTri = NULL;
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			if (tri->flags & TF_HIDDEN)
				continue;
			p[0] = frameVerts[tri->verti[0]].pos;
			p[1] = frameVerts[tri->verti[1]].pos;
			p[2] = frameVerts[tri->verti[2]].pos;
			pln.TriExtract(p[0], p[1], p[2]);
			dist = pln.IntersectionUV(lu, lv, mpoint);
			if ((dist >= 0.0) && (dist < neardist))
			{
				if (PointInPoly(mpoint, p, pln))
				{
					neardist = dist;
					nearPoint = mpoint;
					nearTri = tri;
					nearTriIndex = i;
				}
			}
		}
		if (nearTri)
		{				
			vector_t pb;
			
			m = &mesh->mdl->mounts[mountIndex];
			m->flags |= MRF_INUSE;

//			m->angles = 0;
			m->axes[0].Set(1,0,0);
			m->axes[1].Set(0,1,0);
			m->axes[2].Set(0,0,1);
			m->scale.Set(1,1,1);
			m->attachOrigin = 0;
			m->useAttachOrigin = false;
			p[0] = frameVerts[nearTri->verti[0]].pos;
			p[1] = frameVerts[nearTri->verti[1]].pos;
			p[2] = frameVerts[nearTri->verti[2]].pos;
			GetBarys(nearPoint, p[0], p[1], p[2], pb);				
			m->barys[0] = pb.x;
			m->barys[1] = pb.y;
			m->barys[2] = pb.z;
			if (!m->SetTriangle(nearTriIndex))
				m->flags &= ~MRF_INUSE; // circular reference
		}
		return(1);
	}
	
	OVLCMD("mountadj")
	{
		int mx, my;
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
			return(1);
		oldMouseX = mx; oldMouseY = my;
		OVL_LockInput(this);
		return(1);
	}

	OVLCMD("anchorview")
	{
		if (argNum < 2)
			return(1);
		if (atoi(argList[1]))
		{
//			camera.SetTarget(anchorPoint);
			anchorActive = 1;
		}
		else
		{
			anchorActive = 0;
		}
		return(1);
	}

	OVLCMD("wireframe")
	{
		if (argNum < 2)
			return(1);
		if (atoi(argList[1]))
			wireframeActive = 1;
		else
			wireframeActive = 0;
		return(1);
	}

	OVLCMD("envmaptesttog")
	{
		envMapTest ^= 1;
		return(1);
	}

	OVLCMD("rotatewheeltog")
	{
		rotatewheelActive ^= 1;
		return(1);
	}

	OVLCMD("origamiview")
	{
		if (argNum < 2)
			return(1);
		if (atoi(argList[1]))
			origamiView = 1;
		else
			origamiView = 0;
		origamiTri = NULL;
		return(1);
	}

	OVLCMD("selectionglow")
	{
		if (argNum < 2)
			return(1);
		if (atoi(argList[1]))
			selectionGlow = 1;
		else
			selectionGlow = 0;
		return(1);
	}

	OVLCMD("blacklists")
	{
		if (argNum < 2)
			return(1);
		if (atoi(argList[1]))
			viewBlacklists = 1;
		else
			viewBlacklists = 0;
		return(1);
	}

	OVLCMD("framenext")
	{
		modelFrame_t *oldf = frame;
		OWorkspace *ws = (OWorkspace *)this->parent;
		if (!frame)
		{			
			if (!ws->mdx->frames.Count())
				return(1); // still no frames, so stay null
			frame = ws->mdx->frames.First();
		}
		else
		{
			frame = ws->mdx->frames.Next(frame);
			if (!frame)
				frame = ws->mdx->frames.First();
		}
		if (frame != oldf)
		{
			strcpy(name, frame->name);
		}
		return(1);
	}
	OVLCMD("frameprev")
	{
		modelFrame_t *oldf = frame;
		OWorkspace *ws = (OWorkspace *)this->parent;
		if (!frame)
		{			
			if (!ws->mdx->frames.Count())
				return(1); // still no frames, so stay null
			frame = ws->mdx->frames.First();
		}
		else
		{
			frame = ws->mdx->frames.Prev(frame);
			if (!frame)
				frame = ws->mdx->frames.Last();
		}
		if (frame != oldf)
		{
			strcpy(name, frame->name);
		}
		return(1);
	}

	OVLCMD("triskinsetselected")
	{
		int i;
		meshTri_t *tri;
		baseTri_t *baseTris, *btri;
		OWorkspace *ws = (OWorkspace *)this->parent;

		baseTris = NULL;
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		baseTris = frame->GetBaseTris();
		if (!baseTris)
			return(1);
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			btri = &baseTris[i];
			if ((tri->flags & TF_SELECTED) && (ws->mdx->skins[grabSkinIndex].flags & MRF_INUSE))
			{
				btri->skinIndex = grabSkinIndex;
			}
		}
		return(1);
	}
	OVLCMD("tribaseshowskin")
    {
        int i;
        baseTri_t *baseTris, *tri;
	    modelFrame_t *f;

        f = ((OWorkspace *)this->parent)->mdx->refFrame;
        baseTris = f->GetBaseTris();
        for (i=0;i<f->numTris;i++)
        {
			tri = &baseTris[i];
            if (tri->skinIndex == grabSkinIndex)
                tri->flags &= ~BTF_HIDDEN;
            else
                tri->flags |= BTF_HIDDEN;
        }
        return(1);
    }
	OVLCMD("tribaseshowall")
    {
        int i;
        baseTri_t *baseTris, *tri;
	    modelFrame_t *f;

        f = ((OWorkspace *)this->parent)->mdx->refFrame;
        baseTris = f->GetBaseTris();
        for (i=0;i<f->numTris;i++)
        {
			tri = &baseTris[i];
            tri->flags &= ~BTF_HIDDEN;
        }
        return(1);
    }
    OVLCMD("triskinnext")
	{
		int i;
		OWorkspace *ws = (OWorkspace *)this->parent;

		for (i=grabSkinIndex+1;i!=grabSkinIndex;i++)
		{
			if (i == WS_MAXSKINS)
				i = 0;
			if ((i == grabSkinIndex) || (ws->mdx->skins[i].flags & MRF_INUSE))
				break;
		}
		grabSkinIndex = i;
		return(1);
	}
	OVLCMD("triskinprev")
	{
		int i;
		OWorkspace *ws = (OWorkspace *)this->parent;

		for (i=grabSkinIndex-1;i!=grabSkinIndex;i--)
		{
			if (i == -1)
				i = WS_MAXSKINS-1;
			if ((i == grabSkinIndex) || (ws->mdx->skins[i].flags & MRF_INUSE))
				break;
		}
		grabSkinIndex = i;
		return(1);
	}
	OVLCMD("mountnext")
	{
		mountIndex++;
		if (mountIndex == WS_MAXMOUNTS)
			mountIndex = 0;
		return(1);
	}
	OVLCMD("mountprev")
	{
		mountIndex--;
		if (mountIndex == -1)
			mountIndex = WS_MAXMOUNTS-1;
		return(1);
	}
	OVLCMD("mountattach")
	{
		char *str;
		modelMount_t *m;
		
		OWorkspace *ws = (OWorkspace *)this->parent;
		if (!mountIndex)
			return(1);
		m = &ws->mdx->mounts[mountIndex];
		if (!(m->flags & MRF_INUSE))
			return(1);
		str = argList[1];
		if (argNum < 2)
		{
			if (!(str = SYS_OpenFileBox("Duke Nukem Extended Model (*.mdx)\0*.mdx\0\0", "Attach MDX", "mdx")))
				return(1);
		}
		if (m->attachModel)
			delete m->attachModel;
		m->attachModel = new model_t;
		m->attachModel->ws = ws;
		if (!m->attachModel->LoadMDX(str, false))
		{
			delete m->attachModel;
			m->attachModel = NULL;
		}
		return(1);
	}
	OVLCMD("mountdetach")
	{
		modelMount_t *m;

		OWorkspace *ws = (OWorkspace *)this->parent;
		if (!mountIndex)
			return(1);
		m = &ws->mdx->mounts[mountIndex];
		if (!(m->flags & MRF_INUSE))
			return(1);
		if (m->attachModel)
		{
			delete m->attachModel;
			m->attachModel = NULL;
		}
		return(1);
	}
	OVLCMD("mountverts")
	{
		int i, px, py;
		meshTri_t *tri;
		frameVert_t *frameVerts;
		modelFrame_t *f;

		OWorkspace *ws = (OWorkspace *)this->parent;

		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		px = vid.resolution->width/2 - 112;
		py = vid.resolution->height/2 - 16;
		vid.DrawString(px, py, 32, 32, "WORKING", true, 128, 128, 128);
		vid.Swap();
		MRL_ITERATENEXT(f,f,ws->mdx->frames)
		{
			frameVerts = f->GetVerts();
			if (!frameVerts)
				continue;
			for (i=0;i<WS_MAXMOUNTS;i++)
			{
				if (ws->mdx->mounts[i].flags & MRF_INUSE)
					ws->mdx->mounts[i].SetFrame(f);
			}
			for (i=0;i<f->numVerts;i++)
			{
				if (mesh->mountPoints[i])
					ws->mdx->mounts[mesh->mountPoints[i]].MountToWorld(frameVerts[i].pos);
			}
		}
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			if (!(tri->flags & TF_SELECTED))
				continue;
			mesh->mountPoints[tri->verti[0]] = mountIndex;
			mesh->mountPoints[tri->verti[1]] = mountIndex;
			mesh->mountPoints[tri->verti[2]] = mountIndex;
		}
		MRL_ITERATENEXT(f,f,ws->mdx->frames)
		{
			frameVerts = f->GetVerts();
			if (!frameVerts)
				continue;
			for (i=0;i<WS_MAXMOUNTS;i++)
			{
				if (ws->mdx->mounts[i].flags & MRF_INUSE)
					ws->mdx->mounts[i].SetFrame(f);
			}
			for (i=0;i<f->numVerts;i++)
			{
				if (mesh->mountPoints[i])
					ws->mdx->mounts[mesh->mountPoints[i]].WorldToMount(frameVerts[i].pos);
			}
		}
		vid.Swap();
		return(1);
	}

	OVLCMD("makereference") // must hit 5 times in less than 1/2 second intervals for command
	{
		int px, py;
		static float lastTime = 0.0;
		static int numClicks = 0;
		
		if (!numClicks)
		{
			numClicks = 1;
			lastTime = sys_curTime;
		}
		else
		{
			if (sys_curTime <= (lastTime + 0.5))
				numClicks++;
			else
				numClicks = 1;
			lastTime = sys_curTime;
		}
		if (numClicks < 5)
			return(1);

		numClicks = 0;
		if (!frame)
			return(1);
		OWorkspace *ws = (OWorkspace *)this->parent;
		px = vid.resolution->width/2 - 112;
		py = vid.resolution->height/2 - 16;
		vid.DrawString(px, py, 32, 32, "WORKING", true, 128, 128, 128);
		vid.Swap();
		ws->mdx->SetReference(this->frame);
		vid.Swap();
		return(1);
	}

	OVLCMD("referenceoverride")
	{
		refOverride ^= 1;
		modelFrame_t *temp = refOverrideFrame;
		refOverrideFrame = frame;
		frame = temp;
		return(1);
	}

	OVLCMD("brushsize")
	{
		if (argNum < 2)
			return(1);
		brushsize = atoi(argList[1]);
		return(1);
	}
	OVLCMD("antialias")
	{
		if (argNum < 2)
			return(1);
		antialias = (atoi(argList[1]) != 0);
		return(1);
	}
	OVLCMD("filtered")
	{
		if (argNum < 2)
			return(1);
		filtered = (atoi(argList[1]) != 0);
		return(1);
	}

	OVLCMD("spawnpalettewindow")
	{
		overlay_t *palw;
		if (!(palw = OVL_FindChild(NULL, NULL, "OPalette", NULL)))
		{ // create a palette box if it doesn't already exist
			OVL_CreateOverlay("OPalette", "Palette", NULL, 0, 0, 128+6, 136+12+6,
				OVLF_ALWAYSTOP|OVLF_NORESIZE|OVLF_NODRAGDROP|OVLF_NOTITLEMINMAX|OVLF_NOFOCUS, true);
		}
		else
			OVL_SetTopmost(palw);
        return(1);
	}

	OVLCMD("spawntriflagswindow")
	{
		overlay_t *trifw;
		if (!(trifw = OVL_FindChild(NULL, NULL, "OTriFlagsList", NULL)))
		{ // create a tri flags box if it doesn't already exist
			OVL_CreateOverlay("OTriFlagsList", "TriFlags", NULL, pos.x, pos.y, TRIFLAGS_MIN_WIDTH, TRIFLAGS_MIN_HEIGHT, OVLF_NOTITLEMINMAX|OVLF_ALWAYSTOP, true);
		}
		else
			OVL_SetTopmost(trifw);
        return(1);
	}

	OVLCMD("openbaseframe")
	{
		char *str;

		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		if (argNum > 1)
		{
			LoadBaseframe(frame, argList[1]);
		}
		else
		{
			if (str = SYS_OpenFileBox("Cannibal Baseframe (*.cbf)\0*.cbf\0\0", "Open baseframe", "cbf"))
				LoadBaseframe(frame, str);
		}
		return(1);
	}

	OVLCMD("savebaseframe")
	{
		char *str;

		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		if (argNum > 1)
		{
			SaveBaseframe(frame, argList[1]);
		}
		else
		{
			if (str = SYS_SaveFileBox("Cannibal Baseframe (*.cbf)\0*.cbf\0\0", "Save baseframe", "cbf"))
				SaveBaseframe(frame, str);
		}
		return(1);
	}

	OVLCMD("savebaseframeimage")
	{
		int x,y,xinc,yinc,temp,x1,y1,x2,y2;
		int i, k, m, w;
		baseTri_t *baseTris, *tri;
		word *buffer;
		char *str;

		if (!(str = SYS_SaveFileBox("24-bit Bitmap Files (*.bmp)\0*.bmp\0\0", "Save Skin As...", "bmp")))
			return(1);
		OWorkspace *ws = (OWorkspace *)this->parent;
		if (!(ws->mdx->skins[grabSkinIndex].flags & MRF_INUSE))
		{
			for (i=grabSkinIndex+1;i!=grabSkinIndex;i++)
			{
				if (i == WS_MAXSKINS)
					i = 0;
				if ((i == grabSkinIndex) || (ws->mdx->skins[i].flags & MRF_INUSE))
					break;
			}
			grabSkinIndex = i;
			if (!(ws->mdx->skins[grabSkinIndex].flags & MRF_INUSE))
				return(1);
		}
		baseTris = NULL;
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		baseTris = frame->GetBaseTris();
		if (!baseTris)
			return(1);
		buffer = ALLOC(word, ws->mdx->skins[grabSkinIndex].tex->width*ws->mdx->skins[grabSkinIndex].tex->height);
		memset(buffer, 0, ws->mdx->skins[grabSkinIndex].tex->width*ws->mdx->skins[grabSkinIndex].tex->height*2);
		w = ws->mdx->skins[grabSkinIndex].tex->width;
		for (k=0;k<mesh->numTris;k++)
		{
			tri = &baseTris[k];
			if ((tri->flags & BTF_INUSE)
             && (tri->skinIndex == grabSkinIndex)
			 && (tri->tverts[0].x >= 0) && (tri->tverts[0].y >= 0)
			 && (tri->tverts[1].x >= 0) && (tri->tverts[1].y >= 0)
			 && (tri->tverts[2].x >= 0) && (tri->tverts[2].y >= 0)
			 && (tri->tverts[0].x < ws->mdx->skins[grabSkinIndex].tex->width) && (tri->tverts[0].y < ws->mdx->skins[grabSkinIndex].tex->height)
			 && (tri->tverts[1].x < ws->mdx->skins[grabSkinIndex].tex->width) && (tri->tverts[1].y < ws->mdx->skins[grabSkinIndex].tex->height)
			 && (tri->tverts[2].x < ws->mdx->skins[grabSkinIndex].tex->width) && (tri->tverts[2].y < ws->mdx->skins[grabSkinIndex].tex->height))
			{
				for (m=0;m<3;m++)
				{
					x1 = tri->tverts[m].x;
					y1 = tri->tverts[m].y;
					x2 = tri->tverts[(m+1)%3].x;
					y2 = tri->tverts[(m+1)%3].y;
					if (abs(x2-x1) >= abs(y2-y1)) // X-major
					{
						if (x2 < x1)
						{
							temp = x1;
							x1 = x2;
							x2 = temp;
							temp = y1;
							y1 = y2;
							y2 = temp;
						}

						if ((x2-x1) == 0) continue;
						yinc = ((y2-y1) << 16) / (x2-x1);
						y = y1 << 16;

						for (i=x1;i<=x2;i++)
						{
							temp = y>>16;
							buffer[temp*w+i] = 0x7FFF;
							y += yinc;
						}
					}
					else // Y-major
					{
						if (y2 < y1)
						{
							temp = x1;
							x1 = x2;
							x2 = temp;
							temp = y1;
							y1 = y2;
							y2 = temp;
						}

						if ((y2-y1) == 0) continue;
						xinc = ((x2-x1) << 16) / (y2-y1);
						x = x1 << 16;

						for (i=y1;i<=y2;i++)
						{
							temp = x>>16;
							buffer[i*w+temp] = 0x7FFF;
							x += xinc;
						}
					}
				}
			}
		}
		OVL_WriteBMP16(str, buffer, ws->mdx->skins[grabSkinIndex].tex->width, ws->mdx->skins[grabSkinIndex].tex->height);
		FREE(buffer);
		return(1);
	}

	OVLCMD("genbaseframe") // must hit 5 times in less than 1/2 second intervals for command
	{
		meshTri_t *tri;
		baseTri_t *baseTris, *btri;
		frameVert_t *frameVerts;
		vector_t sdiff, sfactor, bbMin, bbMax;
		plane_t pln;
		vector_t p[3];
		int i, k;		
		static float lastTime = 0.0;
		static int numClicks = 0;
		
		if (!numClicks)
		{
			numClicks = 1;
			lastTime = sys_curTime;
		}
		else
		{
			if (sys_curTime <= (lastTime + 0.5))
				numClicks++;
			else
				numClicks = 1;
			lastTime = sys_curTime;
		}
		if (numClicks < 5)
			return(1);

		numClicks = 0;

		OWorkspace *ws = (OWorkspace *)this->parent;
		if (!(ws->mdx->skins[grabSkinIndex].flags & MRF_INUSE))
		{
			for (i=grabSkinIndex+1;i!=grabSkinIndex;i++)
			{
				if (i == WS_MAXSKINS)
					i = 0;
				if ((i == grabSkinIndex) || (ws->mdx->skins[i].flags & MRF_INUSE))
					break;
			}
			grabSkinIndex = i;
			if (!(ws->mdx->skins[grabSkinIndex].flags & MRF_INUSE))
				return(1);
		}
		baseTris = NULL;
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		baseTris = frame->GetBaseTris();
		if (!baseTris)
			return(1);
		frameVerts = frame->GetVerts();
		if (!frameVerts)
			return(1);
		bbMin = FLT_MAX; bbMax = -FLT_MAX;
		for (i=0;i<ws->mdx->refFrame->numVerts;i++)
		{
			if (frameVerts[i].pos.x < bbMin.x) bbMin.x = frameVerts[i].pos.x;
			if (frameVerts[i].pos.y < bbMin.y) bbMin.y = frameVerts[i].pos.y;
			if (frameVerts[i].pos.z < bbMin.z) bbMin.z = frameVerts[i].pos.z;
			if (frameVerts[i].pos.x > bbMax.x) bbMax.x = frameVerts[i].pos.x;
			if (frameVerts[i].pos.y > bbMax.y) bbMax.y = frameVerts[i].pos.y;
			if (frameVerts[i].pos.z > bbMax.z) bbMax.z = frameVerts[i].pos.z;
		}
		sdiff = bbMax - bbMin;
		sfactor.x = (ws->mdx->skins[grabSkinIndex].tex->width-4)/(sdiff.x*2);
		sfactor.y = (ws->mdx->skins[grabSkinIndex].tex->height-4)/sdiff.y;
		if (sfactor.x < sfactor.y)
			sfactor.y = sfactor.x;
		else
			sfactor.x = sfactor.y;
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			btri = &baseTris[i];
			p[0] = frameVerts[tri->verti[0]].pos;
			p[1] = frameVerts[tri->verti[1]].pos;
			p[2] = frameVerts[tri->verti[2]].pos;
//			camera.TransWorldToCamera(&p[0]);
//			camera.TransWorldToCamera(&p[1]);
//			camera.TransWorldToCamera(&p[2]);
			pln.TriExtract(p[0], p[1], p[2]);
			for (k=0;k<3;k++)
			{
				btri->tverts[k].y = -(frameVerts[tri->verti[k]].pos.y - bbMax.y) * sfactor.y + 1;
				if (pln.n.z > 0)
					btri->tverts[k].x = (frameVerts[tri->verti[k]].pos.x - bbMin.x) * sfactor.x + 1;
				else
					btri->tverts[k].x = -(frameVerts[tri->verti[k]].pos.x - bbMax.x) * sfactor.x + 3 + sfactor.x*sdiff.x;
				btri->tverts[k].z = 0;
			}
			btri->flags |= BTF_INUSE;
		}		
		return(1);
	}

	OVLCMD("invertnormals")
	{
		int i, tempi;
		meshTri_t *ftri;
		baseTri_t *baseTris, *tri;
		vector_t tempv;
		modelFrame_t *f;
		OWorkspace *ws = (OWorkspace *)this->parent;

		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		for (i=0;i<mesh->numTris;i++)
		{
			ftri = &mesh->meshTris[i];
			if (!(ftri->flags & TF_SELECTED))
                continue;
			tempi = ftri->verti[0];
			ftri->verti[0] = ftri->verti[2];
			ftri->verti[2] = tempi;
		}
		MRL_ITERATENEXT(f,f,ws->mdx->frames)
		{
			baseTris = f->GetBaseTris();
			if (!baseTris)
				continue;
			for (i=0;i<mesh->numTris;i++)
			{
			    ftri = &mesh->meshTris[i];
			    if (!(ftri->flags & TF_SELECTED))
                    continue;
				tri = &baseTris[i];
				tempv = tri->tverts[0];
				tri->tverts[0] = tri->tverts[2];
				tri->tverts[2] = tempv;
			}
		}
		mesh->EvaluateLinks(); // recalculate edge links
		return(1);
	}

	OVLCMD("addtosequence")
	{
		OWorkspace *ws = (OWorkspace *)this->parent;
		seqItem_t *item;
		modelSequence_t *s = ws->GetTopmostSequence();
		if (!s)
			return(1);
		item = s->AddItem(this->frame);
		return(1);
	}

	OVLCMD("cut")
	{
		int i, num;
		meshTri_t *ftri;
		baseTri_t *baseTris, *tri;

		baseTris = NULL;
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		baseTris = frame->GetBaseTris();
		if (!baseTris)
			return(1);
		VCR_Record(VCRA_CLIPBOARD, "$skinbasecopy", NULL, 12*mesh->numTris+16, NULL);
		num = 0;
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &baseTris[i];
			ftri = &mesh->meshTris[i];
			if ((ftri->flags & TF_SELECTED))// && (tri->flags & BTF_INUSE))
			{
				VCR_WriteShort((short)tri->tverts[0].x);
				VCR_WriteShort((short)tri->tverts[0].y);
				VCR_WriteShort((short)tri->tverts[1].x);
				VCR_WriteShort((short)tri->tverts[1].y);
				VCR_WriteShort((short)tri->tverts[2].x);
				VCR_WriteShort((short)tri->tverts[2].y);
				tri->flags &= ~BTF_INUSE;
				tri->tverts[0].Set(-1,-1,0);
				tri->tverts[1].Set(-1,-1,0);
				tri->tverts[2].Set(-1,-1,0);
				num++;
			}
		}
		VCR_WriteShort(num);
		return(1);
	}

	OVLCMD("copy")
	{
		int i, num;
		meshTri_t *ftri;
		baseTri_t *baseTris, *tri;

		baseTris = NULL;
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		baseTris = frame->GetBaseTris();
		if (!baseTris)
			return(1);
		VCR_Record(VCRA_CLIPBOARD, "$skinbasecopy", NULL, 12*mesh->numTris+16, NULL);
		num = 0;
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &baseTris[i];
			ftri = &mesh->meshTris[i];
			if ((ftri->flags & TF_SELECTED))// && (tri->flags & BTF_INUSE))
			{
				VCR_WriteShort((short)tri->tverts[0].x);
				VCR_WriteShort((short)tri->tverts[0].y);
				VCR_WriteShort((short)tri->tverts[1].x);
				VCR_WriteShort((short)tri->tverts[1].y);
				VCR_WriteShort((short)tri->tverts[2].x);
				VCR_WriteShort((short)tri->tverts[2].y);
				num++;
			}
		}
		VCR_WriteShort(num);
		return(1);
	}

	OVLCMD("paste")
	{
		int i, num;
		meshTri_t *ftri;
		baseTri_t *baseTris, *tri;

		baseTris = NULL;
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		baseTris = frame->GetBaseTris();
		if (!baseTris)
			return(1);
		VCR_ActivateAction(VCRA_CLIPBOARD);
		if (strcmp(VCR_ActiveActionName(), "$skinbasecopy"))
			return(1);
		VCR_ResetActionRead();
		VCR_ReadSetBackward();
		num = VCR_ReadShort();
		VCR_ReadSetForward();
		if (!num)
			return(1);
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &baseTris[i];
			ftri = &mesh->meshTris[i];
			if (ftri->flags & TF_SELECTED)
			{
				tri->tverts[0].x = VCR_ReadShort();
				tri->tverts[0].y = VCR_ReadShort();
				tri->tverts[0].z = 0.0f;
				tri->tverts[1].x = VCR_ReadShort();
				tri->tverts[1].y = VCR_ReadShort();
				tri->tverts[1].z = 0.0f;
				tri->tverts[2].x = VCR_ReadShort();
				tri->tverts[2].y = VCR_ReadShort();
				tri->tverts[2].z = 0.0f;
				tri->flags |= BTF_INUSE;
				if ((tri->tverts[0].x == -1) || (tri->tverts[0].y == -1)
				 || (tri->tverts[1].x == -1) || (tri->tverts[1].y == -1)
				 || (tri->tverts[2].x == -1) || (tri->tverts[2].y == -1))
					tri->flags &= ~BTF_INUSE;
				num--;
				if (!num)
				{ // loop through as many times as we have tris
					VCR_ResetActionRead();
					VCR_ReadSetBackward();
					num = VCR_ReadShort();
					VCR_ReadSetForward();
				}
			}
		}
		return(1);
	}

	OVLCMD("playsequence")
	{
		modelSequence_t *s;
		OWorkspace *ws = (OWorkspace *)this->parent;
		
		s = ws->GetTopmostSequence();
		if (s)
			s->Play();
		return(1);
	}

	OVLCMD("stopsequence")
	{
		modelSequence_t *s;
		OWorkspace *ws = (OWorkspace *)this->parent;
		
		s = ws->GetTopmostSequence();
		if (s)
			s->Stop();
		return(1);
	}

	return(Super::OnPressCommand(argNum, argList));
}

boolean OFrameView::OnDragCommand(int argNum, char **argList)
{
	OVLCMDSTART

	OVLCMD("moveforward") { camera.MoveForward(mdl_moveSpeed*sys_frameTime); return(1); }
	OVLCMD("movebackward") { camera.MoveForward(-mdl_moveSpeed*sys_frameTime); return(1); }
	OVLCMD("moveright") { camera.MoveRight(mdl_moveSpeed*sys_frameTime); return(1); }
	OVLCMD("moveleft") { camera.MoveRight(-mdl_moveSpeed*sys_frameTime); return(1); }
	OVLCMD("moveup") { camera.MoveUp(mdl_moveSpeed*sys_frameTime); return(1); }
	OVLCMD("movedown") { camera.MoveUp(-mdl_moveSpeed*sys_frameTime); return(1); }
	OVLCMD("turnright") { camera.TiltX(mdl_turnSpeed*sys_frameTime); return(1); }
	OVLCMD("turnleft") { camera.TiltX(-mdl_turnSpeed*sys_frameTime); return(1); }
	OVLCMD("lookdown") { camera.TiltY(mdl_turnSpeed*sys_frameTime); return(1); }
	OVLCMD("lookup") { camera.TiltY(-mdl_turnSpeed*sys_frameTime); return(1); }
	OVLCMD("tiltright") { camera.TiltZ(mdl_turnSpeed*sys_frameTime); return(1); }
	OVLCMD("tiltleft") { camera.TiltZ(-mdl_turnSpeed*sys_frameTime); return(1); }
	
	OVLCMD("rotate")
	{
		int mx, my;
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		switch(rotateType)
		{
		case 0:
			camera.TiltZ(-(mx-oldMouseX)*PI/512.0); oldMouseX = mx; oldMouseY = my;
			break;
		case 1:
			camera.TiltX((mx-oldMouseX)*PI/512.0); oldMouseX = mx; oldMouseY = my;
			break;
		case 2:
			camera.TiltY((my-oldMouseY)*PI/512.0); oldMouseX = mx; oldMouseY = my;
			break;
		case 3:
			camera.TiltX((mx-oldMouseX)*PI/512.0);
			camera.TiltY((my-oldMouseY)*PI/512.0); oldMouseX = mx; oldMouseY = my;
			break;
		case 4:
			camera.TiltZ(-(mx-oldMouseX)*PI/512.0); oldMouseX = mx; oldMouseY = my;
			break;
		case 5:
			camera.LookTilt(mx-oldMouseX, 0.0); oldMouseX = mx; oldMouseY = my;
			break;
		case 6:
			camera.LookTilt(0.0, my-oldMouseY); oldMouseX = mx; oldMouseY = my;
			break;
		case 7:
			camera.LookTilt(mx-oldMouseX, my-oldMouseY); oldMouseX = mx; oldMouseY = my;
			break;
		}
		OVL_SendMsg(this, "GetBodyCursor", 1, &rotateCursor);
		return(1);
	}

	OVLCMD("pan")
	{
		int mx, my;//, i;
		//frameVert_t *frameVerts;
		//modelFrame_t *f;

		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
/*
object move stuff commented out		
		if (in_keyFlags & KF_CONTROL)
		{
			f = frame;
			frameVerts = f->GetVerts();
			if (!frameVerts)
				return(1);
			for (i=0;i<f->numVerts;i++)
			{
				//frameVerts[i].pos += camera.vup*(oldMouseY-my);
				//frameVerts[i].pos += camera.vright*(mx-oldMouseX);
				frameVerts[i].pos.y += (oldMouseY-my)*0.1;
				frameVerts[i].pos.x += (mx-oldMouseX)*0.1;
			}
		}
		else
*/
		{
			camera.MoveUp(my-oldMouseY);
			camera.MoveRight(mx-oldMouseX);
		}
		oldMouseX = mx;
		oldMouseY = my;
		return(1);
	}

	OVLCMD("zoom")
	{
		int mx, my;//, i;
//		frameVert_t *frameVerts;
//		modelFrame_t *f;

		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
/*
object move stuff commented out		
		if (in_keyFlags & KF_CONTROL)
		{
			f = frame;
			frameVerts = f->GetVerts();
			if (!frameVerts)
				return(1);
			for (i=0;i<f->numVerts;i++)
			{
				//frameVerts[i].pos -= camera.vforward*(oldMouseY-my);
				frameVerts[i].pos.z += (oldMouseY-my)*0.1;
			}
		}
		else
*/
		{
			camera.MoveForward(oldMouseY-my);
		}
		oldMouseX = mx;
		oldMouseY = my;
		return(1);
	}

	OVLCMD("mountadj")
	{
		modelMount_t *m;

		if (!mountIndex)
			return(1);
		int mx, my;
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		m = &mesh->mdl->mounts[mountIndex];

#if 0 // oldmount - translation
		if (in_keyFlags & KF_CONTROL)
		{
			m->attachOrigin.y += ((oldMouseY-my)*0.1);
			if (in_keyFlags & KF_SHIFT)
				m->attachOrigin.z += ((mx-oldMouseX)*0.1);
			else
				m->attachOrigin.x += ((mx-oldMouseX)*0.1);
		}
#else
		if (in_keyFlags & KF_CONTROL)
		{
			if ((in_keyFlags & KF_SHIFT) && (in_keyFlags & KF_ALT))
				m->attachOrigin.z += ((oldMouseY-my)*0.1);
			else if (in_keyFlags & KF_ALT)
				m->attachOrigin.y += ((oldMouseY-my)*0.1);
			else
				m->attachOrigin.x += ((oldMouseY-my)*0.1);
		}
#endif // oldmount

#if 0 // oldmount - scaling
		else
		if ((in_keyFlags & KF_ALT) && (!(in_keyFlags & KF_SHIFT)))
		{
			float ys;//, xs;
			vector_t svec;

			ys = 1.0+(my - oldMouseY)*0.05;
			if ((my - oldMouseY) < 0)
				ys = 1.0/(1.0+(oldMouseY - my)*0.05);
			m->scale.x *= ys;
			m->scale.y *= ys;
			m->scale.z *= ys;
		}
#endif // oldmount
		else
		{			
#if 0 // oldmount - rotation
			matrix_t xmat;
			quatern_t qx(m->axes[0], ((oldMouseY-my)*PI/512.0));
			quatern_t qy(m->axes[1], ((oldMouseX-mx)*PI/512.0));
			quatern_t qz(m->axes[2], ((mx-oldMouseX)*PI/512.0));

			if ((in_keyFlags & KF_SHIFT) && (in_keyFlags & KF_ALT))
			{
				xmat = MatRotation(qz);
				m->axes[0] *= xmat;
				m->axes[1] *= xmat;
				m->axes[2] *= xmat;
			}
			else
			{
				xmat = MatRotation(qy);
				m->axes[0] *= xmat;
				m->axes[1] *= xmat;
				m->axes[2] *= xmat;
				xmat = MatRotation(qx);
				m->axes[0] *= xmat;
				m->axes[1] *= xmat;
				m->axes[2] *= xmat;
			}
#else
			if ((in_keyFlags & KF_SHIFT) && (in_keyFlags & KF_ALT))
			{
				// z axis
				quatern_t q(m->axes[2], ((oldMouseY-my)*PI/512.0));
				matrix_t xmat = MatRotation(q);
				m->axes[0] *= xmat;
				m->axes[1] *= xmat;
				m->axes[2] *= xmat;
			}
			else if (in_keyFlags & KF_ALT)
			{
				// y axis
				quatern_t q(m->axes[1], ((oldMouseY-my)*PI/512.0));
				matrix_t xmat = MatRotation(q);
				m->axes[0] *= xmat;
				m->axes[1] *= xmat;
				m->axes[2] *= xmat;
			}
			else
			{
				// xaxis
				quatern_t q(m->axes[0], ((oldMouseY-my)*PI/512.0));
				matrix_t xmat = MatRotation(q);
				m->axes[0] *= xmat;
				m->axes[1] *= xmat;
				m->axes[2] *= xmat;
			}			
#endif // oldmount
			m->axes[0].Normalize();
			m->axes[1].Normalize();
			m->axes[2] = m->axes[0] ^ m->axes[1];
		}
		oldMouseX = mx;
		oldMouseY = my;
		return(1);
	}

	OVLCMD("paint")
	{
		int i, mx, my, xo, yo;
		plane_t pln;
		float dist, neardist;
		vector_t mpoint, lu, lv;
		meshTri_t *tri, *neartri;
		baseTri_t *baseTris, *refBaseTris, *btri, *nearbtri;
		vector_t p[4], tv[4];
		frameVert_t *frameVerts;
		//unsigned short *scrBuf;
		int k;//, scrPitch;
		OWorkspace *ws = (OWorkspace *)this->parent;
		modelSkin_t *skin;

		baseTris = NULL;
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		baseTris = frame->GetBaseTris();
		if (!baseTris)
			return(1);
		refBaseTris = ws->mdx->refFrame->GetBaseTris();
		if (!refBaseTris)
			return(1);
		frameVerts = frame->GetVerts();
		if (!frameVerts)
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		if ((mx == oldMouseX) && (my == oldMouseY))
			return(1); // hasn't moved
		oldMouseX = mx;
		oldMouseY = my;
		if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
			return(1);
		mx -= (dim.x-6)/2; my -= (dim.y-6-12)/2;
		mpoint.x = mx*(dim.x-6)/256.0; mpoint.y = my*(dim.y-6-12)/256.0;
		mpoint.x += (dim.x-6)/2; mpoint.y += (dim.y-6-12)/2;
		camera.TransViewToWorldLine(mpoint, lu, lv);
		neartri = NULL;
		neardist = FLT_MAX;
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			btri = &baseTris[i];
			if (tri->flags & TF_HIDDEN)
				continue;
			if (!(btri->flags & BTF_INUSE))
				btri = &refBaseTris[i];
			p[0] = frameVerts[tri->verti[0]].pos;
			p[1] = frameVerts[tri->verti[1]].pos;
			p[2] = frameVerts[tri->verti[2]].pos;
			pln.TriExtract(p[0], p[1], p[2]);
			dist = pln.IntersectionUV(lu, lv, mpoint);
			if ((dist >= 0.0) && (dist < neardist))
			{
				if (PointInPoly(mpoint, p, pln))
				{
					neartri = tri;
					nearbtri = btri;
					neardist = dist;
					//mdl_debugVec = mpoint;
				}
			}
		}
		if ((!neartri) || (!nearbtri) || (!(nearbtri->flags & BTF_INUSE)) || (!(ws->mdx->skins[nearbtri->skinIndex].flags & MRF_INUSE)))
			return(1);
		vid.ColorMode(VCM_TEXTURE);
		skin = &ws->mdx->skins[nearbtri->skinIndex];
		for (k=0;k<3;k++)
		{
			float aspect = (float)skin->tex->height / (float)skin->tex->width;
			//tv[k].x = nearbtri->tverts[k].x;//*256.0/skin->tex->width;
			//tv[k].y = nearbtri->tverts[k].y;//*256.0/skin->tex->height;
			tv[k].x = nearbtri->tverts[k].x*256.0/skin->tex->width;
			tv[k].y = nearbtri->tverts[k].y*256.0/skin->tex->height;
			if (aspect < 1)
				tv[k].y *= aspect;
			else
				tv[k].x /= aspect;
		}
		p[0] = frameVerts[neartri->verti[0]].pos;
		p[1] = frameVerts[neartri->verti[1]].pos;
		p[2] = frameVerts[neartri->verti[2]].pos;
#if 0
		vid.TexActivate(ws->mdx->skins[nearbtri->skinIndex].tex, VTA_XO);
		vid.ForceDraw(true);
		vid.WindingMode(VWM_SHOWALL);
		camera.DrawTriangle(p, NULL, NULL, tv, true);
		vid.LockScreen(VLS_READBACK, &scrBuf, &scrPitch);
		xo = scrBuf[in_MouseY*scrPitch+in_MouseX];
		vid.UnlockScreen();
		vid.ColorMode(VCM_TEXTURE);
		vid.TexActivate(*vid.blankTex, VTA_NORMAL); // need intermediate texture between mode change (vid interface texture caching caveat)
		vid.TexActivate(ws->mdx->skins[nearbtri->skinIndex].tex, VTA_YO);
		p[0] = frameVerts[neartri->verti[0]].pos;
		p[1] = frameVerts[neartri->verti[1]].pos;
		p[2] = frameVerts[neartri->verti[2]].pos;
		camera.DrawTriangle(p, NULL, NULL, tv, true);
		vid.ForceDraw(false);
		vid.WindingMode(VWM_SHOWCLOCKWISE);
		vid.LockScreen(VLS_READBACK, &scrBuf, &scrPitch);
		yo = scrBuf[in_MouseY*scrPitch+in_MouseX];
		vid.UnlockScreen();
#else
		for (k=0;k<3;k++)
			tv[k] = nearbtri->tverts[k];
		float u, v;
		if (!RayPolyIntersect(lu, lv, p[0], p[1], p[2], NULL, &u, &v))
			return(1);
		xo = tv[1].x*u + tv[2].x*v + tv[0].x*(1.f-(u+v));
		yo = tv[1].y*u + tv[2].y*v + tv[0].y*(1.f-(u+v));
#endif
		OVL_SkinPaint(skin, xo, yo, brushsize, 1.0, false, antialias);
		vid.TexReload(skin->tex);
		return(1);
	}

	OVLCMD("gridmove")
	{
		int mx, my;
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		gridStart.y += oldMouseY-my;
		oldMouseX = mx;
		oldMouseY = my;
		return(1);
	}

	return(Super::OnDragCommand(argNum, argList));
}

boolean OFrameView::OnReleaseCommand(int argNum, char **argList)
{
	OVLCMDSTART
	OVLCMD("rotate")
	{
		rotateCursor = "select";
	}
	
	OVLCMD("select")
	{
		OVL_UnlockInput(this);
		if ((selectBoxStart.x == -1) || (selectBoxStart.y == -1))
			return(1);

		int i, mx, my;
		plane_t pln;
		vector_t mpoint, lu, lv;
		meshTri_t *tri;
		baseTri_t *baseTris, *refBaseTris, *btri;
		vector_t p[4];
		frameVert_t *frameVerts;
		OWorkspace *ws = (OWorkspace *)this->parent;

		baseTris = NULL;
		if ((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts))
			return(1);
		baseTris = frame->GetBaseTris();
		if (!baseTris)
			return(1);
		refBaseTris = ws->mdx->refFrame->GetBaseTris();
		if (!refBaseTris)
			return(1);
		frameVerts = frame->GetVerts();
		if (!frameVerts)
			return(1);
		mx = in_MouseX; my = in_MouseY;
		/*
		OVL_MousePosWindowRelative(this, &mx, &my);
		if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
			return(1);
		*/
		vector_t box[2];
		box[0] = vector_t(selectBoxStart.x,selectBoxStart.y,0);
		box[1] = vector_t(mx,my,0);
		if (box[0].x > box[1].x) { float t=box[0].x; box[0].x=box[1].x; box[1].x=t; }
		if (box[0].y > box[1].y) { float t=box[0].y; box[0].y=box[1].y; box[1].y=t; }
		/*
		for (i=0;i<2;i++)
		{
			box[i].x = ((box[i].x-(dim.x-6)/2)*(dim.x-6)/256.0) + (dim.x-6)/2;
			box[i].y = ((box[i].y-(dim.y-6-12)/2)*(dim.y-6-12)/256.0) + (dim.y-6-12)/2;
		}
		*/
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			btri = &baseTris[i];
			if (!(btri->flags & BTF_INUSE))
				btri = &refBaseTris[i];
			if (!(in_keyFlags & KF_CONTROL))
			{
				tri->flags &= ~TF_SELECTED;
				btri->flags &= ~(BTF_VM0|BTF_VM1|BTF_VM2);
			}
			if (tri->flags & TF_HIDDEN)
				continue;
			
			// automatically reject polys that are backfacing
			p[0] = frameVerts[tri->verti[0]].pos;
			p[1] = frameVerts[tri->verti[1]].pos;
			p[2] = frameVerts[tri->verti[2]].pos;
			camera.TransWorldToCamera(&p[0]);
			camera.TransWorldToCamera(&p[1]);
			camera.TransWorldToCamera(&p[2]);
			pln.TriExtract(p[0], p[1], p[2]);
			if (pln.n.z <= 0)
				continue;

			// project the poly
			camera.TransCameraToView(&p[0]);
			camera.TransCameraToView(&p[1]);
			camera.TransCameraToView(&p[2]);
		
			// if all three points are outside any one side of the box, it's a reject
			if ((p[0].x <= box[0].x) && (p[1].x <= box[0].x) && (p[2].x <= box[0].x))
				continue;
			if ((p[0].x >= box[1].x) && (p[1].x >= box[1].x) && (p[2].x >= box[1].x))
				continue;
			if ((p[0].y <= box[0].y) && (p[1].y <= box[0].y) && (p[2].y <= box[0].y))
				continue;
			if ((p[0].y >= box[1].y) && (p[1].y >= box[1].y) && (p[2].y >= box[1].y))
				continue;

			// select it
			tri->flags |= TF_SELECTED;	
		}

		/*
		for (int px=0; px<4; px++)
		{
			vector_t luA,lvA,luB,lvB;
			vector_t v = box[px];
			mpoint.x = ((v.x-(dim.x-6)/2)*(dim.x-6)/256.0) + (dim.x-6)/2;
			mpoint.y = ((v.y-(dim.y-6-12)/2)*(dim.y-6-12)/256.0) + (dim.y-6-12)/2;
			camera.TransViewToWorldLine(mpoint, luA, lvA);
			v = box[(px+1)%4];
			mpoint.x = ((v.x-(dim.x-6)/2)*(dim.x-6)/256.0) + (dim.x-6)/2;
			mpoint.y = ((v.y-(dim.y-6-12)/2)*(dim.y-6-12)/256.0) + (dim.y-6-12)/2;
			camera.TransViewToWorldLine(mpoint, luB, lvB);
			
			p[0] = luA;
			p[1] = luA + lvA*100.0;
			p[2] = luB + lvB*100.0;
			pln.TriExtract(p[0], p[1], p[2]);

			for (i=0;i<mesh->numTris;i++)
			{
				tri = &mesh->meshTris[i];
				if (tri->flags & TF_HIDDEN)
					continue;
					
				if (((frameVerts[tri->verti[0]].pos * pln.n) + pln.d) <= 0.0)
					continue;
				if (((frameVerts[tri->verti[1]].pos * pln.n) + pln.d) <= 0.0)
					continue;
				if (((frameVerts[tri->verti[2]].pos * pln.n) + pln.d) <= 0.0)
					continue;

			}
		}
		*/
		selectBoxStart.Set(-1, -1, 0);
		return(1);	
	}
	
	OVL_UnlockInput(this);
	return(Super::OnReleaseCommand(argNum, argList));
}

boolean OFrameView::OnMessage(ovlmsg_t *msg)
{
	OVLMSGSTART
	OVLMSG("GetBodyCursor") // (char **cursorName)
	{
		ovltool_t *tool = FindActiveRadioTool(0);
		if (tool)
		{
			if (((!mesh) || (!mesh->numTris) || (!frame) || (!frame->numVerts)) || (_stricmp(tool->cursor, "rotate")))
			{
				*(OVLMSGPARM(0, char **)) = tool->cursor;
			}
			else
			{
				if (_stricmp(rotateCursor, "select"))
				{
					*(OVLMSGPARM(0, char **)) = rotateCursor;
					return(1);
				}
				int mx, my;
				mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
				if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
				{
					*(OVLMSGPARM(0, char **)) = tool->cursor;
					return(1);
				}
				vector_t mp(mx,my,0);
				*(OVLMSGPARM(0, char **)) = "rotate";
				if ((mx >= rotateWheelBoxes[0][0].x) && (mx <= rotateWheelBoxes[0][1].x)
				 && (my >= rotateWheelBoxes[0][0].y) && (my <= rotateWheelBoxes[0][1].y))
					*(OVLMSGPARM(0, char **)) = "roty";
				else if ((mx >= rotateWheelBoxes[1][0].x) && (mx <= rotateWheelBoxes[1][1].x)
				 && (my >= rotateWheelBoxes[1][0].y) && (my <= rotateWheelBoxes[1][1].y))
					*(OVLMSGPARM(0, char **)) = "roty";
				else if ((mx >= rotateWheelBoxes[2][0].x) && (mx <= rotateWheelBoxes[2][1].x)
				 && (my >= rotateWheelBoxes[2][0].y) && (my <= rotateWheelBoxes[2][1].y))
					*(OVLMSGPARM(0, char **)) = "rotx";
				else if ((mx >= rotateWheelBoxes[3][0].x) && (mx <= rotateWheelBoxes[3][1].x)
				 && (my >= rotateWheelBoxes[3][0].y) && (my <= rotateWheelBoxes[3][1].y))
					*(OVLMSGPARM(0, char **)) = "rotx";
				else if (mp.Distance(rotateWheelCenter) < rotateWheelRadius)
					*(OVLMSGPARM(0, char **)) = "rotb";
			}
		}
		else
		{
			*(OVLMSGPARM(0, char **)) = "select";
		}
		return(1);
	}
	return(Super::OnMessage(msg));
}

/*
boolean OFrameView::OnDragDrop(overlay_t *dropovl)
{
	if ((!dropovl) || (!mesh) || (!mesh->numTris))
		return(1);
	if (OVL_IsOverlayType(dropovl, "OSkinView"))
	{
		meshTri_t *tri;
		baseTri_t *btri, *baseTris;
		int i;
		
		baseTris = frame->GetBaseTris();
		if (!baseTris)
			return(1);
		for (i=0;i<mesh->numTris;i++)
		{
			tri = &mesh->meshTris[i];
			btri = &baseTris[i];
			if (tri->flags & BTF_SELECTED)
				btri->skinIndex = ((OSkinView *)dropovl)->skin - &((OWorkspace *)this->parent)->skins[0];
		}
	}
	//return(Super::OnDragDrop(dropovl));
	return(1);
}
*/

//****************************************************************************
//**
//**    END MODULE OVL_FRM.CPP
//**
//****************************************************************************

