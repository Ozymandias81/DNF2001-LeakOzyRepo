#ifndef __CBL_MOBJ_H__
#define __CBL_MOBJ_H__
//****************************************************************************
//**
//**    CBL_MOBJ.H
//**    Header - Cannibal 3D C3S Toolkit Model Objects
//**
//****************************************************************************
//============================================================================
//    INTERFACE REQUIRED HEADERS
//============================================================================
#include "c3s_defs.h"
#include "c3s_mdl.h"
//============================================================================
//    INTERFACE DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
#define CBLCC_FOURCC(a,b,c,d)	((a) + (b << 8) + (c << 16) + (d << 24))

enum
{
    CBLCC_TEXTURE			= CBLCC_FOURCC('T','X','T','R'),
    CBLCC_SOUND				= CBLCC_FOURCC('W','A','V','E'),
    CBLCC_MATERIAL			= CBLCC_FOURCC('M','A','T','R'),
    CBLCC_VERTEX			= CBLCC_FOURCC('V','R','T','X'),
    CBLCC_VERTEXGROUP		= CBLCC_FOURCC('V','G','R','P'),
    CBLCC_VERTEXFRAME		= CBLCC_FOURCC('V','F','R','M'),
    CBLCC_EDGE				= CBLCC_FOURCC('E','D','G','E'),
    CBLCC_TRIFACE			= CBLCC_FOURCC('T','R','I','F'),
    CBLCC_TEXVERTEX			= CBLCC_FOURCC('T','V','R','T'),
    CBLCC_TEXVERTEXGROUP	= CBLCC_FOURCC('T','G','R','P'),
    CBLCC_TEXVERTEXFRAME	= CBLCC_FOURCC('T','F','R','M'),
    CBLCC_BONE				= CBLCC_FOURCC('B','O','N','E'),
    CBLCC_SEQUENCE			= CBLCC_FOURCC('A','S','E','Q'),
    CBLCC_SURFACEMOUNT		= CBLCC_FOURCC('S','M','N','T'),

	CBLCC_NUMTYPES = 14
};

//============================================================================
//    INTERFACE CLASS PROTOTYPES / EXTERNAL CLASS REFERENCES
//============================================================================
//============================================================================
//    INTERFACE STRUCTURES / UTILITY CLASSES
//============================================================================
//============================================================================
//    INTERFACE DATA DECLARATIONS
//============================================================================
//============================================================================
//    INTERFACE FUNCTION PROTOTYPES
//============================================================================
//============================================================================
//    INTERFACE OBJECT CLASS DEFINITIONS
//============================================================================
enum
{
	CBL_TEXF_MASKING = 0x00000001
};

class CBLTK_API CBLTexture : public CBLModelObject
{
	CBLMODELOBJECT_INTERFACE(CBLTexture)

private:
	cblDword m_width;
	cblDword m_height;
	cblChar* m_imageFile;

public:
	CBL_ACCESSOR_BOTH(cblDword, Width, m_width);
	CBL_ACCESSOR_BOTH(cblDword, Height, m_height);
	CBL_ACCESSOR_BOTH_STR(ImageFile, m_imageFile);
};

class CBLTK_API CBLSound : public CBLModelObject
{
	CBLMODELOBJECT_INTERFACE(CBLSound)

private:
	cblChar* m_waveFile;

public:
	CBL_ACCESSOR_BOTH_STR(WaveFile, m_waveFile);
};

enum
{
	CBL_MATF_UNLIT = 0x00000001
};

class CBLTK_API CBLMaterial : public CBLModelObject
{
	CBLMODELOBJECT_INTERFACE(CBLMaterial)

private:
	cblFloat m_transparency;
	cblArrayT<CBLTexture*> m_textures;
	cblArrayT<CBLSound*> m_sounds;

public:
	CBL_ACCESSOR_BOTH(cblFloat, Transparency, m_transparency);
	CBL_ACCESSOR_GET_ARRAY(CBLTexture*, GetTextures, m_textures);
	CBL_ACCESSOR_GET_ARRAY(CBLSound*, GetSounds, m_sounds);
};

enum
{
	CBL_VF_DISABLED = 0x00000001
};

class CBLTK_API CBLVertex : public CBLModelObject
{
	CBLMODELOBJECT_INTERFACE(CBLVertex)

	struct vertexWeight_t
	{
		cblFloat weightFactor;
		vgvec3 offsetPos;
		CBLBone* weightBone;
		vertexWeight_t() { weightFactor=0.0; offsetPos=vgvec3(0,0,0); weightBone=CBLNULL; }
	};

private:
	cblFloat m_lodDeathLevel;
	cblArrayT<CBLEdge*> m_edgeLinks;
	cblArrayT<CBLTriFace*> m_triFaceLinks;
	cblArrayT<vertexWeight_t> m_vertexWeights;

public:
	CBL_ACCESSOR_BOTH(cblFloat, LodDeathLevel, m_lodDeathLevel);
	CBL_ACCESSOR_GET_ARRAY(CBLEdge*, GetEdgeLinks, m_edgeLinks);
	CBL_ACCESSOR_GET_ARRAY(CBLTriFace*, GetTriFaceLinks, m_triFaceLinks);
	CBL_ACCESSOR_GET_ARRAY(vertexWeight_t, GetVertexWeights, m_vertexWeights);
};

class CBLTK_API CBLVertexGroup : public CBLModelObject
{
	CBLMODELOBJECT_INTERFACE(CBLVertexGroup)

private:
	cblArrayT<CBLVertex*> m_vertices;

public:
	CBL_ACCESSOR_GET_ARRAY(CBLVertex*, GetVertices, m_vertices);
};

enum
{
	CBL_VFF_COMPRESSED = 0x00000001
};

class CBLTK_API CBLVertexFrame : public CBLModelObject
{
	CBLMODELOBJECT_INTERFACE(CBLVertexFrame)

	struct byteVert_t
	{
		cblByte v[3];
		byteVert_t() {}
	};

private:
	CBLVertexGroup* m_vertexGroup;
	vgvec3 m_bbMin;
	vgvec3 m_bbMax;
	vgvec3 m_scale;
	vgvec3 m_translate;
	cblArrayT<byteVert_t> m_byteVertData;
	cblArrayT<vgvec3> m_vertData;

public:
	CBL_ACCESSOR_BOTH(CBLVertexGroup*, VertexGroup, m_vertexGroup);
	CBL_ACCESSOR_BOTH_REF(vgvec3, BoundingBoxMin, m_bbMin);
	CBL_ACCESSOR_BOTH_REF(vgvec3, BoundingBoxMax, m_bbMax);
	CBL_ACCESSOR_BOTH_REF(vgvec3, ByteVertScale, m_scale);
	CBL_ACCESSOR_BOTH_REF(vgvec3, ByteVertTranslate, m_translate);
	CBL_ACCESSOR_GET_ARRAY(byteVert_t, GetByteVertData, m_byteVertData);
	CBL_ACCESSOR_GET_ARRAY(vgvec3, GetVertData, m_vertData);

	cblBool AuxCalcBoundingBox();
	cblBool AuxCompress();
	cblBool AuxDecompress();
};

enum
{
	CBL_EF_DISABLED = 0x00000001,
	CBL_EF_LODONLY	= 0x00000002
};

class CBLTK_API CBLEdge : public CBLModelObject
{
	CBLMODELOBJECT_INTERFACE(CBLEdge)

private:
	cblFloat m_lodDeathLevel;
	CBLVertex* m_headVertex;
	CBLVertex* m_tailVertex;
	CBLEdge* m_invertedEdge;
	cblArrayT<CBLTriFace*> m_triFaceLinks;

public:
	CBL_ACCESSOR_BOTH(cblFloat, LodDeathLevel, m_lodDeathLevel);
	CBL_ACCESSOR_BOTH(CBLVertex*, HeadVertex, m_headVertex);
	CBL_ACCESSOR_BOTH(CBLVertex*, TailVertex, m_tailVertex);
	CBL_ACCESSOR_BOTH(CBLEdge*, InvertedEdge, m_invertedEdge);
	CBL_ACCESSOR_GET_ARRAY(CBLTriFace*, GetTriFaceLinks, m_triFaceLinks);
};

enum
{
	CBL_TFF_DISABLED = 0x00000001,
	CBL_TFF_TWOSIDED = 0x00000002,
	CBL_TFF_NINVERT  = 0x00000004,
	CBL_TFF_VNIGNORE = 0x00000008,
	CBL_TFF_HIDDEN	= 0x00000010
};

class CBLTK_API CBLTriFace : public CBLModelObject
{
	CBLMODELOBJECT_INTERFACE(CBLTriFace)
	
	struct triFaceLodRange_t
	{
		cblFloat rangeStart;
		CBLMaterial* material;
		CBLEdge* edgeRing[3];
		CBLTexVertex* texVertexRing[3];
		triFaceLodRange_t()
		{
			rangeStart=0.0; material=CBLNULL;
			edgeRing[0]=edgeRing[1]=edgeRing[2]=CBLNULL;
			texVertexRing[0]=texVertexRing[1]=texVertexRing[2]=CBLNULL;
		}
	};

private:
	cblFloat m_lodDeathLevel;
	CBLMaterial* m_material;
	CBLEdge* m_edgeRing[3];
	CBLTexVertex* m_texVertexRing[3];
	cblArrayT<triFaceLodRange_t> m_lodRanges;

public:
	CBL_ACCESSOR_BOTH(cblFloat, LodDeathLevel, m_lodDeathLevel);
	CBL_ACCESSOR_BOTH(CBLMaterial*, Material, m_material);
	CBL_ACCESSOR_GET(CBLEdge**, GetEdgeRing, m_edgeRing);
	CBL_ACCESSOR_GET(CBLTexVertex**, GetTexVertexRing, m_texVertexRing);
	CBL_ACCESSOR_GET_ARRAY(triFaceLodRange_t, GetLodRanges, m_lodRanges);
};

enum
{
	CBL_TVF_DISABLED = 0x00000001
};

class CBLTK_API CBLTexVertex : public CBLModelObject
{
	CBLMODELOBJECT_INTERFACE(CBLTexVertex)
};

class CBLTK_API CBLTexVertexGroup : public CBLModelObject
{
	CBLMODELOBJECT_INTERFACE(CBLTexVertexGroup)

private:
	cblArrayT<CBLTexVertex*> m_texVertices;

public:
	CBL_ACCESSOR_GET_ARRAY(CBLTexVertex*, GetTexVertices, m_texVertices);
};

class CBLTK_API CBLTexVertexFrame : public CBLModelObject
{
	CBLMODELOBJECT_INTERFACE(CBLTexVertexFrame)

private:
	CBLTexVertexGroup* m_texVertexGroup;
	cblArrayT<vgvec2> m_texVertData;

public:
	CBL_ACCESSOR_BOTH(CBLTexVertexGroup*, TexVertexGroup, m_texVertexGroup);
	CBL_ACCESSOR_GET_ARRAY(vgvec2, GetTexVertData, m_texVertData);
};

enum
{
	CBL_BF_IMPLICIT = 0x00000001
};

class CBLTK_API CBLBone : public CBLModelObject
{
	CBLMODELOBJECT_INTERFACE(CBLBone)

private:
	vgocs3 m_baseOCS;
	CBLBone* m_parentBone;
	cblArrayT<CBLBone*> m_childBones;

public:
	CBL_ACCESSOR_BOTH_REF(vgocs3, BaseOCS, m_baseOCS);
	CBL_ACCESSOR_BOTH(CBLBone*, ParentBone, m_parentBone);
	CBL_ACCESSOR_GET_ARRAY(CBLBone*, GetChildBones, m_childBones);
};

class CBLTK_API CBLSequence : public CBLModelObject
{
	CBLMODELOBJECT_INTERFACE(CBLSequence)

	struct boneKey_t
	{
		CBLBone* keyBone;
		vgocs3 animOCS;
		boneKey_t() { keyBone=CBLNULL; animOCS=vgocs3(); }
	};
	struct keyFrame_t
	{
		cblArrayT<CBLTexVertexFrame*> texVertexFrames;
		cblArrayT<boneKey_t> boneKeys;
		cblArrayT<CBLVertexFrame*> vertexFrames;
		keyFrame_t() {}
		~keyFrame_t() {}
	};
	struct seqTrigger_t
	{
		cblFloat timeVal;
		cblDword command;
		cblArrayT<cblByte> parameters;
		seqTrigger_t() { timeVal=0.0; command=0; }
		~seqTrigger_t() {}
	};

private:
	cblFloat m_playRate;
	cblChar* m_sequenceGroup;
	cblArrayT<keyFrame_t> m_keyFrames;
	cblArrayT<seqTrigger_t> m_seqTriggers;
	cblArrayT<CBLSequence*> m_linkedSeqs;

public:
	CBL_ACCESSOR_BOTH(cblFloat, PlayRate, m_playRate);
	CBL_ACCESSOR_BOTH_STR(SequenceGroup, m_sequenceGroup);
	CBL_ACCESSOR_GET_ARRAY(keyFrame_t, GetKeyFrames, m_keyFrames);
	CBL_ACCESSOR_GET_ARRAY(seqTrigger_t, GetSeqTriggers, m_seqTriggers);
	CBL_ACCESSOR_GET_ARRAY(CBLSequence*, GetLinkedSeqs, m_linkedSeqs);
};

class CBLTK_API CBLSurfaceMount : public CBLModelObject
{
	CBLMODELOBJECT_INTERFACE(CBLSurfaceMount)

private:
	vgocs3 m_mountBaseOCS;
	CBLTriFace* m_mountTriFace;
	vgvec3 m_mountBarys;

public:
	CBL_ACCESSOR_BOTH_REF(vgocs3, MountBaseOCS, m_mountBaseOCS);
	CBL_ACCESSOR_BOTH(CBLTriFace*, MountTriFace, m_mountTriFace);
	CBL_ACCESSOR_BOTH_REF(vgvec3, MountBarys, m_mountBarys);
};


#define MODELOBJECT_STREAMINTERFACE(xname) \
inline CBLStream& operator << (CBLStream& inStream, CBL##xname*& v) \
{ \
	if (!v) \
		inStream.WriteCompDword((cblCompDword)0); \
	else \
		inStream.WriteCompDword((cblCompDword)(v->GetIndex()+1)); \
	return(inStream); \
} \
inline CBLStream& operator >> (CBLStream& inStream, CBL##xname*& v) \
{ \
	cblDword i = inStream.ReadCompDword(); \
	if (!i) v = CBLNULL; \
	else v = inStream.GetLoadModel()->Get##xname##s()[i-1]; \
	return(inStream); \
}

MODELOBJECT_STREAMINTERFACE(Texture)
MODELOBJECT_STREAMINTERFACE(Sound)
MODELOBJECT_STREAMINTERFACE(Material)
MODELOBJECT_STREAMINTERFACE(Vertex)
MODELOBJECT_STREAMINTERFACE(VertexGroup)
MODELOBJECT_STREAMINTERFACE(VertexFrame)
MODELOBJECT_STREAMINTERFACE(Edge)
MODELOBJECT_STREAMINTERFACE(TriFace)
MODELOBJECT_STREAMINTERFACE(TexVertex)
MODELOBJECT_STREAMINTERFACE(TexVertexGroup)
MODELOBJECT_STREAMINTERFACE(TexVertexFrame)
MODELOBJECT_STREAMINTERFACE(Bone)
MODELOBJECT_STREAMINTERFACE(Sequence)
MODELOBJECT_STREAMINTERFACE(SurfaceMount)


inline CBLStream& operator << (CBLStream& inStream, CBLVertex::vertexWeight_t& v)
{
	inStream << v.weightFactor << v.offsetPos << v.weightBone;
	return(inStream);
}
inline CBLStream& operator >> (CBLStream& inStream, CBLVertex::vertexWeight_t& v)
{
	inStream >> v.weightFactor >> v.offsetPos >> v.weightBone;
	return(inStream);
}

inline CBLStream& operator << (CBLStream& inStream, CBLVertexFrame::byteVert_t& v)
{
	inStream << (cblByte)v.v[0] << (cblByte)v.v[1] << (cblByte)v.v[2];
	return(inStream);
}
inline CBLStream& operator >> (CBLStream& inStream, CBLVertexFrame::byteVert_t& v)
{
	inStream >> (cblByte)v.v[0] >> (cblByte)v.v[1] >> (cblByte)v.v[2];
	return(inStream);
}

inline CBLStream& operator << (CBLStream& inStream, CBLTriFace::triFaceLodRange_t& v)
{
	inStream << v.rangeStart << v.material;
	inStream << v.edgeRing[0] << v.edgeRing[1] << v.edgeRing[2];
	inStream << v.texVertexRing[0] << v.texVertexRing[1] << v.texVertexRing[2];
	return(inStream);
}
inline CBLStream& operator >> (CBLStream& inStream, CBLTriFace::triFaceLodRange_t& v)
{
	inStream >> v.rangeStart >> v.material;
	inStream >> v.edgeRing[0] >> v.edgeRing[1] >> v.edgeRing[2];
	inStream >> v.texVertexRing[0] >> v.texVertexRing[1] >> v.texVertexRing[2];
	return(inStream);
}

inline CBLStream& operator << (CBLStream& inStream, CBLSequence::boneKey_t& v)
{
	inStream << v.keyBone << v.animOCS;
	return(inStream);
}
inline CBLStream& operator >> (CBLStream& inStream, CBLSequence::boneKey_t& v)
{
	inStream >> v.keyBone >> v.animOCS;
	return(inStream);
}

inline CBLStream& operator << (CBLStream& inStream, CBLSequence::keyFrame_t& v)
{
	inStream << v.texVertexFrames << v.boneKeys << v.vertexFrames;
	return(inStream);
}
inline CBLStream& operator >> (CBLStream& inStream, CBLSequence::keyFrame_t& v)
{
	inStream >> v.texVertexFrames >> v.boneKeys >> v.vertexFrames;
	return(inStream);
}

inline CBLStream& operator << (CBLStream& inStream, CBLSequence::seqTrigger_t& v)
{
	inStream << v.timeVal << v.command << v.parameters;
	return(inStream);
}
inline CBLStream& operator >> (CBLStream& inStream, CBLSequence::seqTrigger_t& v)
{
	inStream >> v.timeVal >> v.command >> v.parameters;
	return(inStream);
}

//============================================================================
//    INTERFACE TRAILING HEADERS
//============================================================================

//****************************************************************************
//**
//**    END HEADER CBL_MOBJ.H
//**
//****************************************************************************
#endif // __CBL_MOBJ_H__
