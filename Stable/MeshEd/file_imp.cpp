//****************************************************************************
//**
//**    FILE_IMP.CPP
//**    Files - General Import Loaders
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include "stdtool.h"

//----------------------------------------------------------------------------
//    Private Definitions
//----------------------------------------------------------------------------
#define CHUNK_MAINMAGIC		0x4d4d
#define CHUNK_NAMEDOBJECT	0x4000

#define VERT_BBMAX -1
#define VERT_BBMIN -2

//----------------------------------------------------------------------------
//    Private Structures
//----------------------------------------------------------------------------
typedef struct
{
	char marker[4]; // AGMA
	char versionMajor;
	char versionMinor;
	short numFrames;
	short numTris;
	short numVerts;
	long vertsOfs;
} gmaHeader_t; // following header is numTris*3 shorts for tris, and at vertsOfs is numFrames*numVerts vector_t's

typedef struct
{
	U16 type;
	unsigned long length;
	void *data;
} chunk_t;

static int mdl_loadError; // declared here so the cheesy structures below can use it

class triangle_t
{
public:
	long facesfront;
	long verts[3];
	long& operator [] (int i)
	{
		return(verts[i]);
	}
};
class trivert_t
{
public:
	U8 pos[3]; // packed position, actualpos[i] = (hdr->scale[i] * pos[i]) + hdr->origin[i];
	U8 lightnormindex;
	U8& operator [] (int i)
	{
		return(pos[i]);
	}
};
class simpleframe_t
{
public:
	trivert_t min;
	trivert_t max;
	char name[16];
	trivert_t *frameverts;
	trivert_t& operator [] (int i)
	{
		if (i < 0)
		{
			if (i == VERT_BBMIN)
				return(min);
			else
			if (i == VERT_BBMAX)
				return(max);
			else
			{
				SYS_Error("Simpleframe_t: Unacceptable index");
				return(min); // dumb error
			}
		}
		else
			return(frameverts[i]);
	}
};

class mdlheader_t
{
public:
	long id;                     // 0x4F504449 = "IDPO" for IDPOLYGON
	long version;                // Version = 6
	vector_t scale;              // Model scale factors.
	vector_t origin;             // Model origin.
	float radius;				 // Model bounding radius.
	vector_t offsets;            // Eye position (useless?)
	long numskins ;              // the number of skin textures
	long skinwidth;              // Width of skin texture
								 //           must be multiple of 8
	long skinheight;             // Height of skin texture
								 //           must be multiple of 8
	long numverts;               // Number of vertices
	long numtris;                // Number of triangles surfaces
	long numframes;              // Number of frames
	long synctype;               // 0= synchron, 1= random
	long flags;                  // 0 (see Alias models)
	float size;					 // average size of triangles
	
	mdlheader_t(FILE *fp)
	{
		int ofp = ftell(fp);
		SYS_SafeRead(&id, sizeof(long), 1, fp);
		if (id != 0x4F504449)
		{
			CON->Printf("Invalid MDL Marker");
			mdl_loadError = 1; return;
		}
		fseek(fp, ofp, SEEK_SET);
		SYS_SafeRead(this, sizeof(mdlheader_t), 1, fp);
		if (version != 6)
		{
			CON->Printf("Invalid MDL Version");
			mdl_loadError = 1; return;
		}
	}
	~mdlheader_t() { }
};

class mdlskin_t
{
public:
	long group;
	union
	{
		struct
		{
			U8 *skin; // [skinwidth*skinheight]
		};
		struct
		{
			long numskins;
			float *skintimes; // [numskins]
			U8 **skins; // [numskins][skinwidth*skinheight]
		};
	};

	mdlskin_t(FILE *fp, mdlheader_t *hdr)
	{
		SYS_SafeRead(&group, sizeof(long), 1, fp);
		if (!group)
		{
			skin = ALLOC(U8, hdr->skinwidth*hdr->skinheight);
			SYS_SafeRead(skin, 1, hdr->skinwidth*hdr->skinheight, fp);
		}
		else
		{
			SYS_SafeRead(&numskins, sizeof(long), 1, fp);
			skintimes = ALLOC(float, numskins);
			SYS_SafeRead(skintimes, sizeof(float), numskins, fp);
			skins = ALLOC(U8 *, numskins);
			for (int i=0;i<numskins;i++)
			{
				skins[i] = ALLOC(U8, hdr->skinwidth*hdr->skinheight);
				SYS_SafeRead(skins[i], 1, hdr->skinwidth*hdr->skinheight, fp);
			}
		}
	}		
	~mdlskin_t()
	{
		if (!group)
		{
			if (skin)
				FREE(skin);
			skin=null;
		}
		else
		{
			if (skintimes)
				FREE(skintimes);
			skintimes=null;
			if (skins)
			{
				for (int i=0;i<numskins;i++)
				{
					FREE(skins[i]);
					skins[i]=null;
				}
				FREE(skins);
				skins=null;
			}
		}
	}
};

class mdlskinverts_t
{
public:
	typedef struct
	{
		long onseam;
		long s;
		long t;
	} skinvert_t;
	skinvert_t *verts;
	
	mdlskinverts_t(FILE *fp, mdlheader_t *hdr)
	{
		verts = ALLOC(skinvert_t, hdr->numverts);
		SYS_SafeRead(verts, sizeof(skinvert_t), hdr->numverts, fp);
	}
	~mdlskinverts_t()
	{
		if (verts)
			FREE(verts);
		verts=null;
	}
};

class mdltriangles_t
{
public:
	triangle_t *tris;

	mdltriangles_t(FILE *fp, mdlheader_t *hdr)
	{
		tris = ALLOC(triangle_t, hdr->numtris);
		SYS_SafeRead(tris, sizeof(triangle_t), hdr->numtris, fp);
	}
	~mdltriangles_t()
	{
		if (tris)
			FREE(tris);
		tris=null;
	}
	triangle_t& operator [] (int i)
	{
		return(tris[i]);
	}
};

class mdlframes_t
{
public:		
	int numframes;
	long frametype;
	union
	{
		struct
		{
			simpleframe_t frame;
		};
		struct
		{
			trivert_t min;
			trivert_t max;
			float *frametimes; // [numframes]
			simpleframe_t *frames; // [numframes]
		};
	};
	mdlframes_t(FILE *fp, mdlheader_t *hdr, int nb)
	{
		numframes = nb;
		SYS_SafeRead(&frametype, sizeof(long), 1, fp);
		if (!frametype)
		{
			SYS_SafeRead(&frame.min, sizeof(trivert_t), 1, fp);
			SYS_SafeRead(&frame.max, sizeof(trivert_t), 1, fp);
			SYS_SafeRead(frame.name, 1, 16, fp);
			frame.frameverts = ALLOC(trivert_t, hdr->numverts);
			SYS_SafeRead(frame.frameverts, sizeof(trivert_t), hdr->numverts, fp);
		}
		else
		{
			SYS_SafeRead(&min, sizeof(trivert_t), 1, fp);
			SYS_SafeRead(&max, sizeof(trivert_t), 1, fp);
			frametimes = ALLOC(float, numframes);
			SYS_SafeRead(frametimes, sizeof(float), numframes, fp);
			frames = ALLOC(simpleframe_t, numframes);
			for (int i=0;i<numframes;i++)
			{
				SYS_SafeRead(&frames[i].min, sizeof(trivert_t), 1, fp);
				SYS_SafeRead(&frames[i].max, sizeof(trivert_t), 1, fp);
				SYS_SafeRead(frames[i].name, 1, 16, fp);
				frames[i].frameverts = ALLOC(trivert_t, hdr->numverts);
				SYS_SafeRead(frames[i].frameverts, sizeof(trivert_t), hdr->numverts, fp);
			}
		}
	}
	~mdlframes_t()
	{
		if (!frametype)
		{
			if (frame.frameverts)
				FREE(frame.frameverts);
			frame.frameverts=null;
		}
		else
		{
			if (frametimes)
				FREE(frametimes);
			frametimes=null;
			if (frames)
			{
				for (int i=0;i<numframes;i++)
				{
					if (frames[i].frameverts)
						FREE(frames[i].frameverts);
					frames[i].frameverts=null;
				}
				FREE(frames);
				frames=null;
			}
		}
	}
	simpleframe_t& operator [] (int i)
	{
		if (!frametype)
			return(frame);
		else
			return(frames[i]);
	}
};

#define IDALIASHEADER		(('2'<<24)+('P'<<16)+('D'<<8)+'I')
#define ALIAS_VERSION	8

#define	MAX_TRIANGLES	4096
#define MAX_VERTS		2048
#define MAX_FRAMES		512
#define MAX_MD2SKINS	32
#define	MAX_SKINNAME	64

typedef struct
{
	short	s;
	short	t;
} dstvert_t;

typedef struct 
{
	short	index_xyz[3];
	short	index_st[3];
} dtriangle_t;

typedef struct
{
	U8	v[3];			// scaled U8 to fit in frame mins/maxs
	U8	lightnormalindex;
} dtrivertx_t;

#define DTRIVERTX_V0   0
#define DTRIVERTX_V1   1
#define DTRIVERTX_V2   2
#define DTRIVERTX_LNI  3
#define DTRIVERTX_SIZE 4

typedef struct
{
	float		scale[3];	// multiply U8 verts by this
	float		translate[3];	// then add this
	char		name[16];	// frame name from grabbing
	dtrivertx_t	verts[1];	// variable sized
} daliasframe_t;

typedef struct
{
	int			ident;
	int			version;

	int			skinwidth;
	int			skinheight;
	int			framesize;		// U8 size of each frame

	int			num_skins;
	int			num_xyz;
	int			num_st;			// greater than num_xyz for seams
	int			num_tris;
	int			num_glcmds;		// dwords in strip/fan command list
	int			num_frames;

	int			ofs_skins;		// each skin is a MAX_SKINNAME string
	int			ofs_st;			// U8 offset from start for stverts
	int			ofs_tris;		// offset for dtriangles
	int			ofs_frames;		// offset for first frame
	int			ofs_glcmds;	
	int			ofs_end;		// end of file

} dmdl_t;

//----------------------------------------------------------------------------
//    Additional External References
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Data
//----------------------------------------------------------------------------
static vector_t *loadingVerts;
static int *loadingFaces;
static int num3dsverts;
static int num3dsfaces;
static int num3dsobjects;
static int isCounting;

//----------------------------------------------------------------------------
//    Public Data
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Code
//----------------------------------------------------------------------------
static int ReadChunk(chunk_t *prevchunk, void *limit)
{
	chunk_t res;

	res.data = (U8 *)prevchunk->data + prevchunk->length;
	if ((U32)res.data >= (U32)limit)
		return(0);
	res.type = *((U16 *)res.data);
	res.data = (U8 *)res.data + 2;
	res.length = *((long *)res.data) - 6;
	res.data = (U8 *)res.data + 4;
	*prevchunk = res;
	return(1);
}

static void ParseVertList(chunk_t *chunk, void *limit)
{
	U16 numverts = *((U16 *)chunk->data);
	void *verts = (U8 *)chunk->data + 2;

	if (isCounting)
	{
		num3dsverts += numverts;
		return;
	}

	for (U32 i=0;i<numverts;i++)
	{        
		if (loadingVerts)
		{
			loadingVerts[num3dsverts+i].x = *((float *)verts);
			loadingVerts[num3dsverts+i].y = *((float *)verts+2);
			loadingVerts[num3dsverts+i].z = -(*((float *)verts+1));
		}
		verts = (U8 *)verts + 12;
	}

	num3dsverts += numverts;
}

static void ParseFaceList(chunk_t *chunk, void *limit)
{
	U16 numfaces = *((U16 *)chunk->data);
	void *faces = (U8 *)chunk->data + 2;
    U32 sizer = 2;

	if (isCounting)
	{
		num3dsfaces += numfaces;
		return;
	}

	for (U32 i=0;i<numfaces;i++)
	{
		if (loadingFaces)
		{
			loadingFaces[(num3dsfaces+i)*3+2] = *((U16 *)faces);
			loadingFaces[(num3dsfaces+i)*3+1] = *((U16 *)faces+1);
			loadingFaces[(num3dsfaces+i)*3+0] = *((U16 *)faces+2);
		}
		faces = (U8 *)faces + 8; // skip flags field
        sizer += 8;
	}

    chunk_t subChunk = {0x4120, sizer, chunk->data};
    if (sizer < chunk->length)
    {
        while (ReadChunk(&subChunk, limit)) ;
			// got rid of matgroup reading stuff here
    }        

	num3dsfaces += numfaces;
}

static void ParseTriObject(chunk_t *chunk, void *limit)
{
	chunk_t subChunk = {0x4100, 0, chunk->data};

	while (ReadChunk(&subChunk, limit))
	{
		if (subChunk.type == 0x4110)
			ParseVertList(&subChunk, (U8 *)subChunk.data+subChunk.length);
		else
		if (subChunk.type == 0x4120)
			ParseFaceList(&subChunk, (U8 *)subChunk.data+subChunk.length);
	}
}

static void ParseNamedObject(chunk_t *chunk, void *limit)
{
	U32 namelen = fstrlen((char *)chunk->data) + 1;
	chunk_t subChunk = {0x4000, namelen, chunk->data};

	while (ReadChunk(&subChunk, limit))
	{
		if (subChunk.type == 0x4100)
		{
			ParseTriObject(&subChunk, (U8 *)subChunk.data+subChunk.length);
			
			if (isCounting)
				num3dsobjects++;
		}
	}
}

//----------------------------------------------------------------------------
//    Public Code
//----------------------------------------------------------------------------
int FI_Load3DS(CC8 *filename,
			   int *numframes, int *numverts, vector_t **frameVerts,
			   int *numfaces, int **faces, char **frameNames)
{
	U8 *fbend;
	FILE *fp;
	int len;
	chunk_t mainChunk;
	char filebuf[_MAX_PATH];
		
	if (numframes)
		*numframes = 0;
	if (numverts)
		*numverts = 0;
	if (numfaces)
		*numfaces = 0;
	if (frameVerts)
		*frameVerts = NULL;
	if (faces)
		*faces = NULL;
	if (frameNames)
		*frameNames = NULL;
	loadingVerts = NULL;
	loadingFaces = NULL;

	strcpy(filebuf, filename);
	SYS_ForceFileExtention(filebuf, "3DS");
	fp = fopen(filebuf, "rb");
	if (!fp)
		return(0);

	fseek(fp, 0, SEEK_END);
	len = ftell(fp);
	fseek(fp, 0, SEEK_SET);

	autochar fbuffer=(char *)xmalloc(len+1);

	SYS_SafeRead(fbuffer, 1, len, fp);
	fbend = (U8 *)(fbuffer+len);
	fclose(fp);

	mainChunk.type = CHUNK_MAINMAGIC;
	mainChunk.length = 22;
	mainChunk.data = fbuffer;
	num3dsverts = 0;
	num3dsfaces = 0;
	num3dsobjects = 0;
	isCounting = 1;
	while (ReadChunk(&mainChunk, fbend))
	{
		if (mainChunk.type == CHUNK_NAMEDOBJECT)
		{
			ParseNamedObject(&mainChunk, (U8 *)mainChunk.data + mainChunk.length);
		}
	}

	if (numframes)
		*numframes = 1;
	if (numverts)
		*numverts = num3dsverts;
	if (numfaces)
		*numfaces = num3dsfaces;
	if (frameVerts)
		loadingVerts = *frameVerts = ALLOC(vector_t, num3dsverts);
	if (faces)
		loadingFaces = *faces = ALLOC(int, num3dsfaces*3);

	mainChunk.type = CHUNK_MAINMAGIC;
	mainChunk.length = 22;
	mainChunk.data = fbuffer;
	num3dsverts = 0;
	num3dsfaces = 0;
	isCounting = 0;
	while (ReadChunk(&mainChunk, fbend))
	{
		if (mainChunk.type == CHUNK_NAMEDOBJECT)
		{
			ParseNamedObject(&mainChunk, (U8 *)mainChunk.data + mainChunk.length);
		}
	}

	return(1);
}

int FI_LoadMDL(CC8 *filename,
			   int *numframes, int *numverts, vector_t **frameVerts,
			   int *numfaces, int **faces, char **frameNames)
{
	FILE *fp;
	char filebuf[_MAX_PATH];
	int i, k, nf;
	
	if (numframes)
		*numframes = 0;
	if (numverts)
		*numverts = 0;
	if (numfaces)
		*numfaces = 0;
	if (frameVerts)
		*frameVerts = NULL;
	if (faces)
		*faces = NULL;
	if (frameNames)
		*frameNames = NULL;
	mdl_loadError = 0;
	
	strcpy(filebuf, filename);
	SYS_ForceFileExtention(filebuf, "MDL");
	fp = fopen(filebuf, "rb");
	if (!fp)
		return(0);

	mdlheader_t header(fp);
	if (mdl_loadError)
		return(0);
	mdlskin_t skindata(fp, &header);
	if (skindata.group)
		nf = skindata.numskins;
	mdlskinverts_t skinverts(fp, &header);
	mdltriangles_t intris(fp, &header);

	if (numframes)
		*numframes = header.numframes;
	if (numverts)
		*numverts = header.numverts;
	if (numfaces)
		*numfaces = header.numtris;
	if (faces)
	{
		*faces = ALLOC(int, header.numtris*3);
		for (i=0;i<header.numtris;i++)
		{
			(*faces)[i*3] = intris[i][0];
			(*faces)[i*3+1] = intris[i][1];
			(*faces)[i*3+2] = intris[i][2];
		}
	}
	if (frameVerts)
	{
		int len;

		*frameVerts = ALLOC(vector_t, header.numframes*header.numverts);
		if (frameNames)
			*frameNames = ALLOC(char, header.numframes*16);
		len = 0;
		for (i=0;i<header.numframes;i++)
		{
			mdlframes_t inframes(fp, &header, nf);
			if (frameNames)
				memcpy((*frameNames)+len, inframes[0].name, fstrlen(inframes[0].name)+1);
			len += fstrlen(inframes[0].name)+1;
			for (k=0;k<header.numverts;k++)
			{
				(*frameVerts)[i*header.numverts+k].x = -((header.scale.y * inframes[0][k][1]) + header.origin.y);
				(*frameVerts)[i*header.numverts+k].y = (header.scale.z * inframes[0][k][2]) + header.origin.z;
				(*frameVerts)[i*header.numverts+k].z = -((header.scale.x * inframes[0][k][0]) + header.origin.x);
			}
		}
	}
	fclose(fp);
	return(1);
}

int FI_LoadMD2(CC8 *filename,
			   int *numframes, int *numverts, vector_t **frameVerts,
			   int *numfaces, int **faces, char **frameNames)
{
	FILE *fp;
	char filebuf[_MAX_PATH];
	int i, k;
	U8 tempBytes[4];
	dmdl_t header;
	
	if (numframes)
		*numframes = 0;
	if (numverts)
		*numverts = 0;
	if (numfaces)
		*numfaces = 0;
	if (frameVerts)
		*frameVerts = NULL;
	if (faces)
		*faces = NULL;
	if (frameNames)
		*frameNames = NULL;
	
	strcpy(filebuf, filename);
	SYS_ForceFileExtention(filebuf, "MD2");
	fp = fopen(filebuf, "rb");
	if (!fp)
		return(0);

	SYS_SafeRead(&header, sizeof(dmdl_t), 1, fp);
	if ((header.ident != IDALIASHEADER) || (header.version != ALIAS_VERSION))
		return(0);

	if (numframes)
		*numframes = header.num_frames;
	if (numverts)
		*numverts = header.num_xyz;
	if (numfaces)
		*numfaces = header.num_tris;
	if (faces)
	{
		dtriangle_t tri;

		*faces = ALLOC(int, header.num_tris*3);
		fseek(fp, header.ofs_tris, SEEK_SET);
		for (i=0;i<header.num_tris;i++)
		{
			SYS_SafeRead(&tri, sizeof(dtriangle_t), 1, fp);
			(*faces)[i*3] = tri.index_xyz[0];
			(*faces)[i*3+1] = tri.index_xyz[1];
			(*faces)[i*3+2] = tri.index_xyz[2];
		}
	}
	if (frameVerts)
	{
		int len;
		daliasframe_t frame;
		
		*frameVerts = ALLOC(vector_t, header.num_frames*header.num_xyz);
		if (frameNames)
			*frameNames = ALLOC(char, header.num_frames*16);
		fseek(fp, header.ofs_frames, SEEK_SET);
		len = 0;
		for (i=0;i<header.num_frames;i++)
		{
			SYS_SafeRead(&frame, 40, 1, fp);
			if (frameNames)
				memcpy((*frameNames)+len, frame.name, fstrlen(frame.name)+1);
			len += fstrlen(frame.name)+1;
			for (k=0;k<header.num_xyz;k++)
			{
				SYS_SafeRead(tempBytes, 1, 4, fp);
				(*frameVerts)[i*header.num_xyz+k].x = -((frame.scale[1] * tempBytes[1]) + frame.translate[1]);
				(*frameVerts)[i*header.num_xyz+k].y = (frame.scale[2] * tempBytes[2]) + frame.translate[2];
				(*frameVerts)[i*header.num_xyz+k].z = -((frame.scale[0] * tempBytes[0]) + frame.translate[0]);
			}
		}
	}
	fclose(fp);
	return(1);
}

int FI_LoadMXB(CC8 *filename,
               int *numframes, int *numverts, vector_t **frameVerts,
               int *numfaces, int **faces, char **frameNames)
{
    FILE *fp;
    char filebuf[_MAX_PATH];
    int i, k;
    int len;

	if (numframes)
		*numframes = 0;
	if (numverts)
		*numverts = 0;
	if (numfaces)
		*numfaces = 0;
	if (frameVerts)
		*frameVerts = NULL;
	if (faces)
		*faces = NULL;
	if (frameNames)
		*frameNames = NULL;
    
    strcpy(filebuf, filename);
	SYS_ForceFileExtention(filebuf, "MXB");
	fp = fopen(filebuf, "rb");
	if (!fp)
		return(0);
    fseek(fp, 0, SEEK_END);
    len = ftell(fp);
    fseek(fp, 0, SEEK_SET);
    
	autochar buf=(char *)xmalloc(len+1);

    fread(buf, 1, len, fp);
    fclose(fp);

	VCR_PlaybackLocal((U8 **)(&buf),len);

    int nt, nv, nf;
    if (((U32)VCR_ReadInt()) != (('M') + ('X' << 8) + ('B' << 16) + (' ' << 24))) // marker
        return(0);
    if (VCR_ReadByte() != 1) // versionMajor
        return(0);
    if (VCR_ReadByte() != 0) // versionMinor
        return(0);
    VCR_ReadShort(); // reserved

    int numTexs = VCR_ReadInt(); // numtextures
    nt = VCR_ReadInt(); // numtris
    int numSeqs = VCR_ReadInt(); // numseqs
    nf = VCR_ReadInt(); // numframes
    nv = VCR_ReadInt(); // numverts

    // scale
    VCR_ReadFloat();
    VCR_ReadFloat();
    VCR_ReadFloat();

    // origin
    VCR_ReadFloat();
    VCR_ReadFloat();
    VCR_ReadFloat();

    // rotorigin
    VCR_ReadFloat(); // p
    VCR_ReadFloat(); // y
    VCR_ReadFloat(); // r

    VCR_ReadString(); // name

    if (numframes)
        *numframes = nf;
    if (numverts)
        *numverts = nv;
    if (numfaces)
        *numfaces = nt;
    if (frameVerts)
        *frameVerts = ALLOC(vector_t, nf*nv);
    if (faces)
        *faces = ALLOC(int, nt*3);

    // skip textures
    for (i=0;i<numTexs;i++)
    {
        VCR_ReadString(); // name
        VCR_ReadShort(); // w
        VCR_ReadShort(); // h
    }
    // tris
    int* facePtr = NULL;
    if (faces)
        facePtr = *faces;
    for (i=0;i<nt;i++)
    {
        // vert indices
        if (facePtr)
        {
            *facePtr++ = VCR_ReadShort();
            *facePtr++ = VCR_ReadShort();
            *facePtr++ = VCR_ReadShort();
        }
        else
        {
            VCR_ReadShort();
            VCR_ReadShort();
            VCR_ReadShort();
        }
        // texcoords
        VCR_ReadShort();
        VCR_ReadShort();
        VCR_ReadShort();
        VCR_ReadShort();
        VCR_ReadShort();
        VCR_ReadShort();
        // texture index
        VCR_ReadShort();
        // poly flags
        VCR_ReadInt();
    }
    // skip sequences
    for (i=0;i<numSeqs;i++)
    {
        VCR_ReadString(); // name
        VCR_ReadString(); // group
        VCR_ReadInt(); // startframe
        VCR_ReadInt(); // numframes
        VCR_ReadFloat(); // rate
        int numTrigs = VCR_ReadInt(); // notify triggers
        for (k=0;k<numTrigs;k++)
        {
            VCR_ReadFloat(); // time
            VCR_ReadString(); // name
        }
    }
    // verts
    if (frameVerts)
        VCR_ReadBulk(*frameVerts, nf*nv*sizeof(vector_t));

    return(1);
}

int FI_LoadGMA(CC8 *filename,
			   int *numframes, int *numverts, vector_t **frameVerts,
			   int *numfaces, int **faces, char **frameNames)
{
	FILE *fp;
	char filebuf[_MAX_PATH];
	int i, k;
	vector_t tempv;
	gmaHeader_t header;
	short triIndex[3];
	
	if (numframes)
		*numframes = 0;
	if (numverts)
		*numverts = 0;
	if (numfaces)
		*numfaces = 0;
	if (frameVerts)
		*frameVerts = NULL;
	if (faces)
		*faces = NULL;
	if (frameNames)
		*frameNames = NULL;
	
	strcpy(filebuf, filename);
	SYS_ForceFileExtention(filebuf, "GMA");
	fp = fopen(filebuf, "rb");
	if (!fp)
		return(0);

	SYS_SafeRead(&header, sizeof(gmaHeader_t), 1, fp);
	if ((header.marker[0]!='A') || (header.marker[1]!='G') || (header.marker[2]!='M') || (header.marker[3]!='A'))
	{
		fclose(fp);
		return(0);
	}
	if ((header.versionMajor != 1) || (header.versionMinor != 0))
	{
		fclose(fp);
		return(0);
	}

	if (numframes)
		*numframes = header.numFrames;
	if (numverts)
		*numverts = header.numVerts;
	if (numfaces)
		*numfaces = header.numTris;
	if (faces)
	{
		*faces = ALLOC(int, header.numTris*3);
		for (i=0;i<header.numTris;i++)
		{
			SYS_SafeRead(triIndex, sizeof(short), 3, fp);
			(*faces)[i*3] = triIndex[0];
			(*faces)[i*3+1] = triIndex[1];
			(*faces)[i*3+2] = triIndex[2];
		}
	}
	if (frameVerts)
	{
		*frameVerts = ALLOC(vector_t, header.numFrames*header.numVerts);
		for (i=0;i<header.numFrames;i++)
		{
			for (k=0;k<header.numVerts;k++)
			{
				SYS_SafeRead(&tempv, sizeof(vector_t), 1, fp);
				(*frameVerts)[i*header.numVerts+k] = tempv;
			}
		}
	}
	fclose(fp);
	return(1);
}

static short SwapShort(short s)
{
	U8 b1,b2;
	b1 = s&255;
	b2 = (s>>8)&255;
	return((b1<<8)+b2);
}

static int SwapInt(int i)
{
	U8 b1,b2,b3,b4;
	b1 = i&255;
	b2 = (i>>8)&255;
	b3 = (i>>16)&255;
	b4 = (i>>24)&255;
	return(((int)b1<<24) + ((int)b2<<16) + ((int)b3<<8) + b4);
}

static float SwapFloat(float f)
{
	union { U8 b[4]; float f; } in, out;
	in.f = f;
	out.b[0] = in.b[3];
	out.b[1] = in.b[2];
	out.b[2] = in.b[1];
	out.b[3] = in.b[0];	
	return(out.f);
}

typedef struct
{
	char label[4];
	int size;
} lwoChunkHdr_t;

static U32 IsLabel(lwoChunkHdr_t *chunk, char *label)
{
	return(((chunk->label[0] == label[0])
		&& (chunk->label[1] == label[1])
		&& (chunk->label[2] == label[2])
		&& (chunk->label[3] == label[3])));
}

int FI_LoadLWO(CC8 *filename,
			   int *numframes, int *numverts, vector_t **frameVerts,
			   int *numfaces, int **faces, char **frameNames)
{
	FILE *fp;
	char filebuf[_MAX_PATH];
	int i;
	vector_t tempv;
	short triIndex[3];
	lwoChunkHdr_t chunk;
	int numv, numf, fpPols, bRead;
	int fsize;
	short s;
	
	if (numframes)
		*numframes = 0;
	if (numverts)
		*numverts = 0;
	if (numfaces)
		*numfaces = 0;
	if (frameVerts)
		*frameVerts = NULL;
	if (faces)
		*faces = NULL;
	if (frameNames)
		*frameNames = NULL;
	
	strcpy(filebuf, filename);
	SYS_ForceFileExtention(filebuf, "LWO");
	fp = fopen(filebuf, "rb");
	if (!fp)
		return(0);

	SYS_SafeRead(&chunk, sizeof(lwoChunkHdr_t), 1, fp); chunk.size = SwapInt(chunk.size);
	if (!IsLabel(&chunk, "FORM"))
	{
		CON->Printf("LoadLWO: Not a valid LWO file");
		fclose(fp);
		return(0);
	}
	fsize = chunk.size + 8;
	SYS_SafeRead(chunk.label, 1, 4, fp);
	if (!IsLabel(&chunk, "LWOB"))
	{
		CON->Printf("LoadLWO: Not a valid LWO file");
		fclose(fp);
		return(0);
	}

	numv = numf = 0;
	while ((!numv) || (!numf))
	{
		if (ftell(fp) >= fsize)
		{
			if (!numv)
				CON->Printf("LoadLWO: PNTS chunk not found");
			if (!numf)
				CON->Printf("LoadLWO: POLS chunk not found");
			fclose(fp);
			return(0);
		}
		SYS_SafeRead(&chunk, sizeof(lwoChunkHdr_t), 1, fp); chunk.size = SwapInt(chunk.size);
		if (IsLabel(&chunk, "PNTS"))
		{
			numv = chunk.size / 12;
			if (numverts)
				*numverts = numv;
			if (numframes)
				*numframes = 1;
			if (frameVerts)
			{
				*frameVerts = ALLOC(vector_t, numv);
				for (i=0;i<numv;i++)
				{
					SYS_SafeRead(&tempv.x, sizeof(float), 1, fp); tempv.x = SwapFloat(tempv.x);
					SYS_SafeRead(&tempv.y, sizeof(float), 1, fp); tempv.y = SwapFloat(tempv.y);
					SYS_SafeRead(&tempv.z, sizeof(float), 1, fp); tempv.z = SwapFloat(tempv.z); tempv.z = -tempv.z;
					(*frameVerts)[i] = tempv;
				}
			}
			else
			{
				fseek(fp, chunk.size, SEEK_CUR);
			}
		}
		else
		if (IsLabel(&chunk, "POLS"))
		{
			fpPols = ftell(fp);
			numf = 0;
			bRead = 0;
			while (bRead < chunk.size)
			{
				SYS_SafeRead(&s, sizeof(short), 1, fp); s = SwapShort(s); bRead += 2;
				if (s != 3)
				{
					CON->Printf("LoadLWO: Non-triangular polygon found");
					fclose(fp);
					return(0);
				}
				fseek(fp, 6, SEEK_CUR); bRead += 6;
				SYS_SafeRead(&s, sizeof(short), 1, fp); s = SwapShort(s); bRead += 2;
				if (s < 0)
				{
					CON->Printf("LoadLWO: Detail polygons are not allowed");
					fclose(fp);
					return(0);
				}
				numf++;
			}

			if (numfaces)
				*numfaces = numf;
			fseek(fp, fpPols, SEEK_SET);
			if (faces)
			{
				*faces = ALLOC(int, numf*3);
				for (i=0;i<numf;i++)
				{
					SYS_SafeRead(&s, sizeof(short), 1, fp); s = SwapShort(s);
					SYS_SafeRead(triIndex, sizeof(short), 3, fp);
					(*faces)[i*3] = SwapShort(triIndex[0]);
					(*faces)[i*3+1] = SwapShort(triIndex[1]);
					(*faces)[i*3+2] = SwapShort(triIndex[2]);
					SYS_SafeRead(&s, sizeof(short), 1, fp); s = SwapShort(s);
				}
			}
			else
			{
				fseek(fp, chunk.size, SEEK_CUR);
			}
		}
		else
			fseek(fp, chunk.size, SEEK_CUR);
	}
	CON->Printf("LoadLWO: Loaded successfully");
	fclose(fp);
	return(1);
}

//----------------------------------------------------------------------------
//    Class Member Code
//----------------------------------------------------------------------------


//****************************************************************************
//**
//**    END MODULE FILE_IMP.CPP
//**
//****************************************************************************

