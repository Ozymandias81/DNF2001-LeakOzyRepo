#ifndef __C3S_MDL_H__
#define __C3S_MDL_H__
//****************************************************************************
//**
//**    C3S_MDL.H
//**    Header - Cannibal 3D C3S Toolkit Models
//**
//****************************************************************************
//============================================================================
//    INTERFACE REQUIRED HEADERS
//============================================================================
#include "c3s_defs.h"
//============================================================================
//    INTERFACE DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
#define CBLMODELOBJECT_INTERFACE(xname) \
protected: \
	static cblDword s_objCC; \
	void* operator new (size_t inSize) { return(CBL_Malloc(inSize)); } \
	void operator delete (void* inPtr) { CBL_Free(inPtr); } \
	void OnNew(); \
	cblBool OnDelete(cblBool inForce=0); \
public: \
	typedef xname ThisClass; \
	typedef CBLModelObject SuperClass; \
	static cblDword StaticGetCC() { return(s_objCC); } \
	cblDword GetCC() { return(StaticGetCC()); } \
	void Serialize(CBLStream& s); \
	static ThisClass* New(CBLModel* inModel=CBLNULL, cblChar* inName=CBLNULL) \
		{ ThisClass* obj = new ThisClass(inModel, inName); \
		if(obj) { if (obj->GetModel()) { obj->SetIndex(obj->GetModel()->AddObject(obj)); } \
		obj->OnNew(); } return(obj); } \
	cblBool Delete(cblBool inForce=0) \
		{ if ((!OnDelete(inForce)) && (!inForce)) return(0); if (GetModel()) GetModel()->RemoveObject(this); delete this; return(1); } \
	xname(CBLModel* inModel=CBLNULL, cblChar* inName=CBLNULL) \
		: CBLModelObject(inModel, inName) {} \
	~xname() {}

//============================================================================
//    INTERFACE CLASS PROTOTYPES / EXTERNAL CLASS REFERENCES
//============================================================================
class CBLScene;
class CBLModel;
class CBLModelObject;

class CBLTexture;
class CBLSound;
class CBLMaterial;
class CBLVertex;
class CBLVertexGroup;
class CBLVertexFrame;
class CBLEdge;
class CBLTriFace;
class CBLTexVertex;
class CBLTexVertexGroup;
class CBLTexVertexFrame;
class CBLBone;
class CBLSequence;
class CBLSurfaceMount;

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
class CBLTK_API CBLScene
{
private:
	// scene data
	cblDword m_version;
	cblChar* m_name;
	cblChar* m_author;
	cblChar* m_description;

	cblChar* m_fileName;

	// models
	cblArrayT<CBLModel*> m_models;

public:
	// accessors
	CBL_ACCESSOR_BOTH(cblDword, Version, m_version);
	CBL_ACCESSOR_BOTH_STR(Name, m_name);
	CBL_ACCESSOR_BOTH_STR(Author, m_author);
	CBL_ACCESSOR_BOTH_STR(Description, m_description);
	CBL_ACCESSOR_GET_ARRAY(CBLModel*, GetModels, m_models);

	CBL_ACCESSOR_BOTH_STR(FileName, m_fileName);

	// construction
	void* operator new (size_t inSize) { return(CBL_Malloc(inSize)); }
	void operator delete (void* inPtr) { CBL_Free(inPtr); }
	CBLScene();
	~CBLScene();

	// scene interface
	cblBool LoadFile(cblChar* inFileName);
	cblBool LoadMem(cblByte* inBuffer);
	cblBool Save();
	cblBool SaveAs(cblChar* inFileName);

};

class CBLTK_API CBLModel
{
private:
	// model data
	cblDword m_version;
	cblChar* m_name;
	CBLScene* m_scene;
	
	// subchunk objects
	cblArrayT<CBLTexture*> m_Textures;
	cblArrayT<CBLSound*> m_Sounds;
	cblArrayT<CBLMaterial*> m_Materials;
	cblArrayT<CBLVertex*> m_Vertices;
	cblArrayT<CBLVertexGroup*> m_VertexGroups;
	cblArrayT<CBLVertexFrame*> m_VertexFrames;
	cblArrayT<CBLEdge*> m_Edges;
	cblArrayT<CBLTriFace*> m_TriFaces;
	cblArrayT<CBLTexVertex*> m_TexVertices;
	cblArrayT<CBLTexVertexGroup*> m_TexVertexGroups;
	cblArrayT<CBLTexVertexFrame*> m_TexVertexFrames;
	cblArrayT<CBLBone*> m_Bones;
	cblArrayT<CBLSequence*> m_Sequences;
	cblArrayT<CBLSurfaceMount*> m_SurfaceMounts;

public:	
	// accessors
	CBL_ACCESSOR_BOTH(cblDword, Version, m_version);
	CBL_ACCESSOR_BOTH_STR(Name, m_name);
	CBL_ACCESSOR_BOTH(CBLScene*, Scene, m_scene);

	CBL_ACCESSOR_GET_ARRAY(CBLTexture*, GetTextures, m_Textures);
	CBL_ACCESSOR_GET_ARRAY(CBLSound*, GetSounds, m_Sounds);
	CBL_ACCESSOR_GET_ARRAY(CBLMaterial*, GetMaterials, m_Materials);
	CBL_ACCESSOR_GET_ARRAY(CBLVertex*, GetVertexs, m_Vertices);
	CBL_ACCESSOR_GET_ARRAY(CBLVertexGroup*, GetVertexGroups, m_VertexGroups);
	CBL_ACCESSOR_GET_ARRAY(CBLVertexFrame*, GetVertexFrames, m_VertexFrames);
	CBL_ACCESSOR_GET_ARRAY(CBLEdge*, GetEdges, m_Edges);
	CBL_ACCESSOR_GET_ARRAY(CBLTriFace*, GetTriFaces, m_TriFaces);
	CBL_ACCESSOR_GET_ARRAY(CBLTexVertex*, GetTexVertexs, m_TexVertices);
	CBL_ACCESSOR_GET_ARRAY(CBLTexVertexGroup*, GetTexVertexGroups, m_TexVertexGroups);
	CBL_ACCESSOR_GET_ARRAY(CBLTexVertexFrame*, GetTexVertexFrames, m_TexVertexFrames);
	CBL_ACCESSOR_GET_ARRAY(CBLBone*, GetBones, m_Bones);
	CBL_ACCESSOR_GET_ARRAY(CBLSequence*, GetSequences, m_Sequences);
	CBL_ACCESSOR_GET_ARRAY(CBLSurfaceMount*, GetSurfaceMounts, m_SurfaceMounts);
	
	// construction
	void* operator new (size_t inSize) { return(CBL_Malloc(inSize)); }
	void operator delete (void* inPtr) { CBL_Free(inPtr); }
	CBLModel(CBLScene* inScene=CBLNULL, cblChar* inName=CBLNULL);
	~CBLModel();

	// model interface	
	void Serialize(CBLStream& s, cblDword modelDataSize);
	cblDword AddObject(CBLModelObject* inObject);
	void RemoveObject(CBLModelObject* inObject);

	// auxiliary
	cblBool AuxGenerateFrame(CBLSequence* inSeq, cblSDword inFrame1,
		cblSDword inFrame2, cblFloat inAlpha, vgvec3* outVerts, vgvec2* outTexVerts);
};

class CBLTK_API CBLModelObject
{
private:
	// object data
	cblDword m_version;
	cblChar* m_name;
	cblDword m_flags;
	cblDword m_index;
	CBLModel* m_model;

public:
	// accessors
	CBL_ACCESSOR_BOTH(cblDword, Version, m_version);
	CBL_ACCESSOR_BOTH_STR(Name, m_name);
	CBL_ACCESSOR_BOTH(cblDword, Flags, m_flags);
	CBL_ACCESSOR_BOTH(cblDword, Index, m_index);
	CBL_ACCESSOR_GET(CBLModel*, GetModel, m_model);

protected:
	// abstract constructor
	inline CBLModelObject(CBLModel* inModel=CBLNULL, cblChar* inName=CBLNULL)
		: m_version(1), m_name(CBLNULL), m_flags(0), m_index(0), m_model(CBLNULL)
	{
		SetName(inName);
		m_model = inModel;
	}

public:
	// object methods
	virtual cblDword GetCC() { return(0); }
	virtual void Serialize(CBLStream& s)
	{
		if (s.IsSaving())
			s << (cblCompDword)m_version << m_name << (cblCompDword)m_flags;
		else
		{
			m_version = (cblDword)s.ReadCompDword();
			s >> m_name;
			m_flags = (cblDword)s.ReadCompDword();
		}
	}
	virtual ~CBLModelObject()
	{
		m_model = NULL;
		SetName(CBLNULL);
	}
};

//============================================================================
//    INTERFACE TRAILING HEADERS
//============================================================================

//****************************************************************************
//**
//**    END HEADER C3S_MDL.H
//**
//****************************************************************************
#endif // __C3S_MDL_H__
