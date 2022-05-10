#ifndef __C3S_STRM_H__
#define __C3S_STRM_H__
//****************************************************************************
//**
//**    C3S_STRM.H
//**    Header - Cannibal 3D C3S Toolkit Streams
//**
//****************************************************************************
//============================================================================
//    INTERFACE REQUIRED HEADERS
//============================================================================
#include "c3s_defs.h"
//============================================================================
//    INTERFACE DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//============================================================================
//    INTERFACE CLASS PROTOTYPES / EXTERNAL CLASS REFERENCES
//============================================================================
class CBLStream;

class CBLModel;

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
class CBLTK_API CBLStream
{
private:	
	cblByte* dataPtr; // buffer pointer
	cblDword dataSize; // data stream size in bytes, access limit
	cblDword readPos; // reading position
	cblDword writePos; // writing position
	cblDword streamMode; // stream mode (reading/writing)
	CBLModel* loadModel; // loading model during reading
public:

	void Init(cblDword inDataSize = 0, void* inDataPtr = CBLNULL);
	CBLStream(cblDword inDataSize = 0, void* inDataPtr = CBLNULL);
	CBLStream(const CBLStream& inStream);
	CBLStream& operator = (const CBLStream& inStream);
	~CBLStream();

	cblBool SetSaving();
	cblBool SetLoading();
	cblBool IsSaving();
	cblBool IsLoading();
	cblBool SetLoadModel(CBLModel* inModel);
	CBLModel* GetLoadModel();

	cblBool WriteSeek(cblDword pos);
	cblDword WriteTell();
	cblBool Write(void* ptr, cblDword length);
	
	cblBool WriteByte(cblByte v);
	cblBool WriteWord(cblWord v);
	cblBool WriteDword(cblDword v);
	cblBool WriteSByte(cblSByte v);
	cblBool WriteSWord(cblSWord v);
	cblBool WriteSDword(cblSDword v);
	cblBool WriteFloat(cblFloat v);
	cblBool WriteCompDword(cblCompDword v);
	cblBool WriteString(cblChar* v);
	cblBool WriteVec2(vgvec2& v);
	cblBool WriteVec3(vgvec3& v);
	cblBool WriteQuat(vgquat3& v);
	cblBool WriteOCS(vgocs3& v);

	cblBool ReadSeek(cblDword pos);
	cblDword ReadTell();
	cblBool Read(void* ptr, cblDword length);

	cblByte ReadByte();
	cblWord ReadWord();
	cblDword ReadDword();
	cblSByte ReadSByte();
	cblSWord ReadSWord();
	cblSDword ReadSDword();
	cblFloat ReadFloat();
	cblCompDword ReadCompDword();
	cblChar* ReadString();
	cblBool ReadVec2(vgvec2* v);
	cblBool ReadVec3(vgvec3* v);
	cblBool ReadQuat(vgquat3* v);
	cblBool ReadOCS(vgocs3* v);
};

inline CBLStream& operator << (CBLStream& inStream, cblByte& v) { inStream.WriteByte(v); return(inStream); }
inline CBLStream& operator << (CBLStream& inStream, cblWord& v) { inStream.WriteWord(v); return(inStream); }
inline CBLStream& operator << (CBLStream& inStream, cblDword& v) { inStream.WriteDword(v); return(inStream); }
inline CBLStream& operator << (CBLStream& inStream, cblSByte& v) { inStream.WriteSByte(v); return(inStream); }
inline CBLStream& operator << (CBLStream& inStream, cblSWord& v) { inStream.WriteSWord(v); return(inStream); }
inline CBLStream& operator << (CBLStream& inStream, cblSDword& v) { inStream.WriteSDword(v); return(inStream); }
inline CBLStream& operator << (CBLStream& inStream, cblFloat& v) { inStream.WriteFloat(v); return(inStream); }
inline CBLStream& operator << (CBLStream& inStream, cblCompDword& v) { inStream.WriteCompDword(v); return(inStream); }
inline CBLStream& operator << (CBLStream& inStream, cblChar*& v) { inStream.WriteString(CBL_GetStr(v)); return(inStream); }
inline CBLStream& operator << (CBLStream& inStream, vgvec2& v) { inStream.WriteVec2(v); return(inStream); }
inline CBLStream& operator << (CBLStream& inStream, vgvec3& v) { inStream.WriteVec3(v); return(inStream); }
inline CBLStream& operator << (CBLStream& inStream, vgquat3& v) { inStream.WriteQuat(v); return(inStream); }
inline CBLStream& operator << (CBLStream& inStream, vgocs3& v) { inStream.WriteOCS(v); return(inStream); }

inline CBLStream& operator >> (CBLStream& inStream, cblByte& v) { v = inStream.ReadByte(); return(inStream); }
inline CBLStream& operator >> (CBLStream& inStream, cblWord& v) { v = inStream.ReadWord(); return(inStream); }
inline CBLStream& operator >> (CBLStream& inStream, cblDword& v) { v = inStream.ReadDword(); return(inStream); }
inline CBLStream& operator >> (CBLStream& inStream, cblSByte& v) { v = inStream.ReadSByte(); return(inStream); }
inline CBLStream& operator >> (CBLStream& inStream, cblSWord& v) { v = inStream.ReadSWord(); return(inStream); }
inline CBLStream& operator >> (CBLStream& inStream, cblSDword& v) { v = inStream.ReadSDword(); return(inStream); }
inline CBLStream& operator >> (CBLStream& inStream, cblFloat& v) { v = inStream.ReadFloat(); return(inStream); }
inline CBLStream& operator >> (CBLStream& inStream, cblCompDword& v) { v = inStream.ReadCompDword(); return(inStream); }
inline CBLStream& operator >> (CBLStream& inStream, cblChar*& v) { CBL_SetStr(v, inStream.ReadString()); return(inStream); }
inline CBLStream& operator >> (CBLStream& inStream, vgvec2& v) { inStream.ReadVec2(&v); return(inStream); }
inline CBLStream& operator >> (CBLStream& inStream, vgvec3& v) { inStream.ReadVec3(&v); return(inStream); }
inline CBLStream& operator >> (CBLStream& inStream, vgquat3& v) { inStream.ReadQuat(&v); return(inStream); }
inline CBLStream& operator >> (CBLStream& inStream, vgocs3& v) { inStream.ReadOCS(&v); return(inStream); }

//============================================================================
//    INTERFACE TRAILING HEADERS
//============================================================================

//****************************************************************************
//**
//**    END HEADER C3S_STRM.H
//**
//****************************************************************************
#endif // __C3S_STRM_H__
