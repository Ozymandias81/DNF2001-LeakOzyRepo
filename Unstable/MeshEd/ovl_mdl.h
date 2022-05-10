#ifndef __OVL_MDL_H__
#define __OVL_MDL_H__
//****************************************************************************
//**
//**    OVL_MDL.H
//**    Header - Overlays - Model Management
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Definitions
//----------------------------------------------------------------------------
#define MRF_DUMMY		0x00000001
#define MRF_INUSE		0x00000002
#define MRF_MODIFIED	0x00000004
#define MRF_SELECTED	0x00000008
#define MRF_COMPRESSED	0x00000010

#define MRL_ITERATENEXT(xiter1,xiter,xlist) for (xiter1=xlist.First();xiter;xiter=xlist.Next(xiter))
#define MRL_ITERATEPREV(xiter1,xiter,xlist) for (xiter1=xlist.Last();xiter;xiter=xlist.Prev(xiter))

#define MDL_MAXMOUNTS	32

#define SEQITEMF_SELECTED	0x00000001

#define WSFRAME_MAXTRIS			4096
#define WSFRAME_MAXVERTS		4096
#define WSFRAME_MAXGROUPS		16
#define WS_MAXSKINS				32
#define WS_MAXMOUNTS			32

#define FVF_IRRELEVANT		0x00000001 // vert is removed from an frmd
#define FVF_TOUCH			0x00000002 // used only by operations running through vertex lists

#define FVF_P_LODLOCKED		0x00000010 // LOD locked, persistant flag, stored in high bits of groupNum in file

#define BTF_INUSE			0x00000001 // basetri has valid texture coordinates and is used
//#define BTF_SELECTED		0x00000002
#define BTF_HIDDEN		0x00000004
#define BTF_VM0				0x00000100
#define BTF_VM1				0x00000200
#define BTF_VM2				0x00000400

//----------------------------------------------------------------------------
//    Class Prototypes
//----------------------------------------------------------------------------
class model_t;

//----------------------------------------------------------------------------
//    Required External Class References
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Structures
//----------------------------------------------------------------------------
typedef struct
{
	int verti[3];
	unsigned short edgeTris[3]; // 0xFFFF for no link, high 2 bits is edge index on other tri (0-2)
    byte aux1; // alpha value 0-255 when transparency flags is set
    byte aux2;
	int flags; // TF_ flags
} meshTri_t;

typedef struct
{
	vector_t tverts[3];
	vector_t trverts[3]; // temporary, only used during things like rotation
	unsigned long flags; // BTF_ flags
	int skinIndex; // index from 0 to WS_MAXSKINS
} baseTri_t;

typedef struct
{
	vector_t pos;
	short flags;
//	int mountIndex;
	short groupNum;
} frameVert_t;

//----------------------------------------------------------------------------
//    Public Data Declarations
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Function Declarations
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Class Headers
//----------------------------------------------------------------------------
//****************************************************************************
//**
//**    CLASS modelResource_t
//**
//****************************************************************************
class modelResource_t
{
public:
	int flags; // MRF_ flags
	int mode; // optional
	modelResource_t *next, *prev; // CLL links
	char name[128]; // name of resource
	autochar path;
	model_t *mdl; // link to parent model
	int index; // index in resource list

	modelResource_t() { flags = mode = index = name[0] = 0; mdl = NULL; next = prev = this; }
	virtual ~modelResource_t() {}
};
//****************************************************************************
//**
//**    END CLASS modelResource_t
//**
//****************************************************************************
//****************************************************************************
//**
//**    CLASS modelSkin_t
//**
//****************************************************************************
class modelSkin_t : public modelResource_t
{
public:
	VidTex *tex;

	modelSkin_t() { tex = NULL; }
	~modelSkin_t() {}

	void *operator new(size_t size);
	void operator delete(void *ptr);
};
//****************************************************************************
//**
//**    END CLASS modelSkin_t
//**
//****************************************************************************
//****************************************************************************
//**
//**    CLASS modelTrimesh_t
//**
//****************************************************************************
class modelTrimesh_t : public modelResource_t
{
public:
	int numTris;
	int numVerts;
	meshTri_t *meshTris;
	byte *mountPoints; // mount point index hooks for verts

	modelTrimesh_t()
	{
		numTris = numVerts = 0;
		meshTris = ALLOC(meshTri_t, WSFRAME_MAXTRIS);
		memset(meshTris, 0, WSFRAME_MAXTRIS*sizeof(meshTri_t));
		mountPoints = ALLOC(byte, WSFRAME_MAXVERTS);
		memset(mountPoints, 0, WSFRAME_MAXVERTS);
        for (int i=0;i<WSFRAME_MAXTRIS;i++)
            meshTris[i].aux1 = 128; // 0.5 alpha transparency
	}
	~modelTrimesh_t()
	{
		if (meshTris)
			FREE(meshTris);
		if (mountPoints)
			FREE(mountPoints); 
		meshTris=null;
		mountPoints=null;
	}

	void EvaluateLinks();
};
//****************************************************************************
//**
//**    END CLASS modelTrimesh_t
//**
//****************************************************************************
//****************************************************************************
//**
//**    CLASS modelFrame_t
//**
//****************************************************************************
class modelFrame_t : public modelResource_t
{
private:
	frameVert_t *verts; // only available when uncompressed
	baseTri_t *baseTris; // only available when uncompressed

	void RemoveFromCache();
	void CalcVertNormals(); // calculate vertex normals (reference frame only)

public:
	int numVerts;
	int numTris; // must match numTris in modelTrimesh_t
	byte *frmdData; // compressed data stream
	int frmdDataLen; // length in bytes of frmdData
	vector_t *vertNorms; // vertex normals, valid ONLY for reference frame, NULL for all other frames

	modelFrame_t()
	{
		verts = NULL;
		baseTris = NULL;
		numVerts = numTris = 0;
		frmdData = NULL;
		frmdDataLen = 0;
		vertNorms = NULL;
		strcpy(name, "UnnamedFrame");
	}

	~modelFrame_t()
	{
		RemoveFromCache();
		if (verts)
			FREE(verts);
		if (baseTris)
			FREE(baseTris);
		if (frmdData)
			FREE(frmdData);
		if (vertNorms)
			FREE(vertNorms);

		verts=null;
		baseTris=null;
		frmdData=null;
		vertNorms=null;
	}

	int Import(int inNumVerts, vector_t *inVerts, int inNumTris, int *inTris);
	int PreserveBaseframe(int preserveNumVerts, vector_t *preserveVerts,
		int preserveNumTris, int *preserveMeshTris, float *preserveBaseTris);
	void LoadMDXChunk(ascfentrylink_t *entry);
	void CacheIn();
	void Compress();
	void Decompress();
	void SetReference(modelFrame_t *ref);
	frameVert_t *GetVerts();
	baseTri_t *GetBaseTris();

	void *operator new(size_t size);
	void operator delete(void *ptr);
};
//****************************************************************************
//**
//**    END CLASS modelFrame_t
//**
//****************************************************************************
//****************************************************************************
//**
//**    CLASS modelSequence_t
//**
//****************************************************************************
typedef struct seqItem_s seqItem_t;
struct seqItem_s
{
	modelFrame_t *setFrame;
	seqItem_t *next, *prev;
	int flags;
};

typedef struct seqTrigger_s seqTrigger_t;
struct seqTrigger_s
{
	char *trigger;
	int triggerBinSize;
	byte *triggerBinData;
	float trigTimeFrac;
	seqTrigger_t *next, *prev;
	int flags;
};

extern pool_t<seqItem_t> ovl_seqItemPool;
extern pool_t<seqTrigger_t> ovl_seqTriggerPool;

class modelSequence_t : public modelResource_t
{
public:
	float framesPerSecond;
	int numItems, numTriggers;
	seqItem_t items;
	seqTrigger_t triggers;
	U32 playing;
	float playStartTime;

	modelSequence_t() { numItems = numTriggers = playing = 0; items.next = items.prev = &items; framesPerSecond = 10.0;
						triggers.next = triggers.prev = &triggers; strcpy(name, "UnnamedSequence"); }
	~modelSequence_t() { while (items.next != &items) DeleteItem(items.next);
						 while (triggers.next != &triggers) DeleteTrigger(triggers.next); }

	void *operator new(size_t size);
	void operator delete(void *ptr);

	seqItem_t *AddItem(modelFrame_t *frame)
	{
		seqItem_t *item = ovl_seqItemPool.Alloc(NULL);
		item->setFrame = frame;
		item->flags = 0;
		item->prev = items.prev;
		item->next = &items;
		item->next->prev = item;
		item->prev->next = item;
		numItems++;
		return(item);
	}

	void DeleteItem(seqItem_t *item)
	{
		item->next->prev = item->prev;
		item->prev->next = item->next;
		ovl_seqItemPool.Free(item);
		numItems--;
	}

	seqTrigger_t *AddTrigger()
	{
		char *iStr = "NoFunction";
		seqTrigger_t *trig = ovl_seqTriggerPool.Alloc(NULL);
		trig->trigger = ALLOC(char, fstrlen(iStr)+1);
		strcpy(trig->trigger, iStr);
		trig->triggerBinSize = 0;
		trig->triggerBinData = NULL;
		trig->trigTimeFrac = 0.5;
		trig->flags = 0;
		trig->prev = &triggers;
		trig->next = triggers.next;
		trig->next->prev = trig;
		trig->prev->next = trig;
		numTriggers++;
		return(trig);
	}

	void DeleteTrigger(seqTrigger_t *trig)
	{
		if (trig->trigger)
			FREE(trig->trigger);
		if (trig->triggerBinData)
			FREE(trig->triggerBinData);
		trig->trigger=null;
		trig->triggerBinData=null;

		trig->next->prev = trig->prev;
		trig->prev->next = trig->next;
		ovl_seqTriggerPool.Free(trig);
		numTriggers--;
	}
	void Play(void);
	void Stop()
	{
		playing = 0;
	}
};
//****************************************************************************
//**
//**    END CLASS modelSequence_t
//**
//****************************************************************************
//****************************************************************************
//**
//**    CLASS modelMount_t
//**
//****************************************************************************
class modelMount_t : public modelResource_t
{
private:
	matrix_t invrotate;
	vector_t v[3];
	float lastUpdateTime;
	U32 verified;

	U32 RecursiveCircularCheck(int mIndex);

public:
	int _triIndex;
	matrix_t _rotate;
	vector_t _translate;
	
	float barys[3];
	
	//vector_t angles; // xyz == pitch,yaw,roll
	vector_t axes[3];
	vector_t scale;

	vector_t attachOrigin; // origin for attached models, as additional translate
	model_t *attachModel;
	U32 useAttachOrigin;

	modelMount_t()
	{
		v[0] = v[1] = v[2] = 0;
		barys[0] = barys[1] = barys[2] = 0.3333f;
		
		//angles = 0;
		axes[0] = axes[1] = axes[2];
		scale = 1;
		
		attachOrigin = 0;
		useAttachOrigin = false;
		lastUpdateTime = -1.0;
		_triIndex = -1;
		verified = 0;
		attachModel = NULL;
	}

	~modelMount_t();

	int UpdateTransform(float updateTime, U32 forceUpdate);

	int SetTriangle(int index);
	
	// update transform for frame
	int SetFrame(modelFrame_t *frame);
	int SetFrameLerped(modelFrame_t *frame, modelFrame_t *lerpFrame, float back, float front);
	
private:
	void RecursiveMountToWorld(vector_t &point, float t)
	{
		if (!UpdateTransform(t, false))
			return;

		if (useAttachOrigin)
		{
			point.x *= scale.x;
			point.y *= scale.y;
			point.z *= scale.z;
			point += attachOrigin;
		}
		point *= _rotate;
		point += _translate;
	}

	void RecursiveWorldToMount(vector_t &point, float t)
	{
		if (!UpdateTransform(t, false))
			return;

		point -= _translate;
		point *= invrotate;
		if (useAttachOrigin)
		{
			point -= attachOrigin;
			point.x /= scale.x;
			point.y /= scale.y;
			point.z /= scale.z;
		}
	}

public:
	
	// transform coordinates based on triangle index and current frame
	void MountToWorld(vector_t &point);
	void WorldToMount(vector_t &point);
};
//****************************************************************************
//**
//**    END CLASS modelMount_t
//**
//****************************************************************************
//****************************************************************************
//**
//**    CLASS modelResourceList_t
//**
//****************************************************************************
typedef void (model_t::*modelMemberDeleteFunc_t)(modelResource_t *res);

typedef struct sortitem_s sortitem_t;
struct sortitem_s
{
	char str[256];
	sortitem_t *left, *right;
	modelResource_t *res;
};

extern pool_t<sortitem_t> ovl_sortPool;

template <class T>
class modelResourceList_t
{
private:
	int numItems;
	T headItem;
	model_t *mdl;
	modelResource_t *lastIndexPtr;
	int lastIndex;

	void SortRecursiveInsert(modelMemberDeleteFunc_t delCallback, sortitem_t **pdest, modelResource_t *r)
	{
		sortitem_t *dest = *pdest;
		int val;

		if (!dest)
		{
			dest = *pdest = ovl_sortPool.Alloc(NULL);
			dest->left = dest->right = NULL;
			strcpy(dest->str, r->name);
			dest->res = r;
			return;
		}
		val = _stricmp(dest->str, r->name);
		if (val < 0)
		{
			SortRecursiveInsert(delCallback, &dest->left, r);
			return;
		}
		if (val > 0)
		{
			SortRecursiveInsert(delCallback, &dest->right, r);
			return;
		}
		// frame is a replica, eliminate it
		(mdl->*delCallback)(r);
	}

	void SortRecursiveRebuild(sortitem_t *dest)
	{
		if (!dest)
			return;
		if (dest->left)
			SortRecursiveRebuild(dest->left);
		
		modelResource_t *r = dest->res;
		r->next = headItem.next;
		r->prev = &headItem;
		r->prev->next = r;
		r->next->prev = r;

		if (dest->right)
			SortRecursiveRebuild(dest->right);
	}

public:
	modelResourceList_t()
	{
		numItems = 0;
		headItem.next = headItem.prev = &headItem;
		lastIndex = -1;
	}
	~modelResourceList_t()
	{
		DeleteAll();
	}
	void Init(model_t *parentmdl)
	{
		mdl = parentmdl;
	}
	int Count() { return(numItems); }
	void Reindex()
	{
		int i;
		modelResource_t *item;
		if (!numItems)
			return;
		for (i=0,item=headItem.next; item!=&headItem; i++,item=item->next)
			item->index = i;
		lastIndex = -1;
	}
	T *Prepend()
	{
		T *item = new T;
		if (!item)
			return(NULL);
		item->mdl = mdl;
		item->next = headItem.next;
		item->prev = &headItem;
		item->next->prev = item;
		item->prev->next = item;
		numItems++;
		Reindex();
		return(item);
	}
	T *Append()
	{
		T *item = new T;
		if (!item)
			return(NULL);
		item->mdl = mdl;
		item->prev = headItem.prev;
		item->next = &headItem;
		item->next->prev = item;
		item->prev->next = item;
		item->index = numItems;
		numItems++;
		Reindex();
		return(item);
	}
	T *First()
	{
		if (!numItems)
			return(NULL);
		return((T *)headItem.next);
	}
	T *Last()
	{
		if (!numItems)
			return(NULL);
		return((T *)headItem.prev);
	}
	T *Next(T *item)
	{
		if (item->next == &headItem)
			return(NULL);
		return((T *)item->next);
	}
	T *Prev(T *item)
	{
		if (item->prev == &headItem)
			return(NULL);
		return((T *)item->prev);
	}
	T *Index(int index)
	{
		T *item;
		int i;
		if (!numItems)
			return(NULL);
		if (index == lastIndex)
			return((T *)lastIndexPtr);
		for (i=0,item=(T *)headItem.next; (i!=index)&&(item!=(T *)&headItem); i++,item=(T *)item->next)
			;
		if (item==(T *)&headItem)
			return(NULL); // hit end of list without index
		lastIndex = index;
		lastIndexPtr = item;
		return((T *)item);
	}
	void Delete(T *item)
	{		
		item->prev->next = item->next;
		item->next->prev = item->prev;
		item->prev = item->next = item;
		numItems--;
		Reindex();
		delete item;
	}
	void DeleteAll()
	{
		while (headItem.next != &headItem)
			Delete((T *)headItem.next);
	}
	void Sort(modelMemberDeleteFunc_t delCallback)
	{
		modelResource_t *r;
		sortitem_t *root;

		root = NULL;
		// build the sort tree
		for (r=First();r;r=Next((T *)r))
		{
			SortRecursiveInsert(delCallback, &root, r);
		}
		// drop everything from the list
		while (headItem.next != &headItem)
		{		
			r = headItem.next;
			r->next->prev = r->prev;
			r->prev->next = r->next;
			r->next = r->prev = r;
		}
		// rebuild list from binary tree
		SortRecursiveRebuild(root);
		ovl_sortPool.FreeAll();
		Reindex();
	}
};
//****************************************************************************
//**
//**    END CLASS modelResourceList_t
//**
//****************************************************************************
//****************************************************************************
//**
//**    CLASS model_t
//**
//****************************************************************************
class model_t
{
public:
	modelResourceList_t<modelFrame_t> frames;
	modelSkin_t skins[WS_MAXSKINS];
	modelResourceList_t<modelSequence_t> seqs;
	modelMount_t mounts[WS_MAXMOUNTS];
	modelFrame_t *refFrame; // reference frame in frames list
	modelTrimesh_t mesh;
	U32 lodActive;
	byte *lodData;
	int lodDataSize;
	OWorkspace *ws;

	model_t()
	{
		int i;

		refFrame = NULL;
		ws = NULL;
		lodActive = false;
		lodData = NULL;
		lodDataSize = 0;
		frames.Init(this);
		seqs.Init(this);
		mesh.mdl = this;
		//skins.Init(this);
		memset(skins, 0, WS_MAXSKINS*sizeof(modelSkin_t));
		memset(mounts, 0, WS_MAXMOUNTS*sizeof(modelMount_t));
		for (i=0;i<WS_MAXSKINS;i++)
		{
			skins[i].index = i;
			skins[i].mdl = this;
		}
		for (i=0;i<WS_MAXMOUNTS;i++)
		{
			mounts[i].index = i;
			mounts[i].mdl = this;
		}
	}

	~model_t()
	{
		int i;

		if (lodData)
			FREE(lodData);
		lodData=null;

		while (frames.Count())
			DeleteFrame(frames.First());
		while (seqs.Count())
			DeleteSequence(seqs.First());
		for (i=0;i<WS_MAXSKINS;i++)
			if (skins[i].flags & MRF_INUSE)
				DeleteSkin(&skins[i]);
		for (i=0;i<WS_MAXMOUNTS;i++)
			if (mounts[i].flags & MRF_INUSE)
				DeleteMount(&mounts[i]);
	}

	modelFrame_t *AddFrame()
	{
		modelFrame_t *f = frames.Prepend();
		if (!refFrame)
			refFrame = f;
		f->Compress();
		return(f);
	}
	modelSkin_t *AddSkin(int slot)
	{
		if (skins[slot].flags & MRF_INUSE)
			SYS_Error("AddSkin: Skin already inuse");
		skins[slot].flags |= MRF_INUSE;
		return(&skins[slot]);
	}
	modelMount_t *AddMount(int slot)
	{
		if (mounts[slot].flags & MRF_INUSE)
			SYS_Error("AddMount: Mount already inuse");
		mounts[slot].flags |= MRF_INUSE;
		return(&mounts[slot]);
	}
	modelSequence_t *AddSequence()
	{
		modelSequence_t *s = seqs.Prepend();
		return(s);
	}
	void DeleteFrame(modelResource_t *fr)
	{
		modelFrame_t *f = (modelFrame_t *)fr;
		seqItem_t *item, *next;

		if (ws)
			ws->CloseFrameReferences(f);
		MRL_ITERATENEXT(modelSequence_t *s,s,seqs)
		{
			for (item=s->items.next;item!=&s->items;item=next)
			{
				next = item->next;
				if (item->setFrame == f)
					s->DeleteItem(item);
			}
		}
		if (f == refFrame)
		{
			if (frames.Count() == 1)
				refFrame = NULL;
			else
			{
				if (!frames.Prev(f))
					SetReference(frames.Last());
				else
					SetReference(frames.Prev(f));
			}
		}
		frames.Delete(f);
		if (!frames.Count())
		{
			mesh.numTris = mesh.numVerts = 0;
		}
	}
	void DeleteSkin(modelResource_t *skr)
	{
		modelSkin_t *sk = (modelSkin_t *)skr;
		if (!(sk->flags & MRF_INUSE))
			SYS_Error("DeleteSkin: Skin not inuse");
		if (ws)
			ws->CloseSkinReferences(sk);
		vid->TexRelease(sk->tex);
		sk->tex=null;
		sk->flags &= ~MRF_INUSE;
	}
	void DeleteMount(modelResource_t *mr)
	{
		modelMount_t *m = (modelMount_t *)mr;
		if (!(m->flags & MRF_INUSE))
			SYS_Error("DeleteMount: Mount not inuse");
		m->flags &= ~MRF_INUSE;
	}
	void DeleteSequence(modelResource_t *sr)
	{
		modelSequence_t *s = (modelSequence_t *)sr;
		if (ws)
			ws->CloseSequenceReferences(s);
		seqs.Delete(s);
	}

	void SetReference(modelFrame_t *ref);
	modelFrame_t *GetReference();
	int ImportFrames(CC8 *filename, U32 forceRestart); // import a frame or series of frames
	int SaveMDX(CC8 *filename);
	int LoadMDX(CC8 *filename, U32 useProjectData);
};
//****************************************************************************
//**
//**    END CLASS model_t
//**
//****************************************************************************

//****************************************************************************
//**
//**    END HEADER OVL_MDL.H
//**
//****************************************************************************
#endif // __OVL_MDL_H__
