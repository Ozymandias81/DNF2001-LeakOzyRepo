#ifndef __VCR_MAN_H__
#define __VCR_MAN_H__
//****************************************************************************
//**
//**    VCR_MAN.H
//**    Header - Action Recorder / Memory Streaming
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Definitions
//----------------------------------------------------------------------------
typedef enum
{
	VCRA_UNDO,
	VCRA_CLIPBOARD,
	VCRA_LOCAL,

	VCRA_NUMTYPES
} vcractiontype_t;
//----------------------------------------------------------------------------
//    Class Prototypes
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Required External Class References
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Structures
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Data Declarations
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Function Declarations
//----------------------------------------------------------------------------
void VCR_Record(vcractiontype_t vt, const char *nsig, void (*nundofunc)(char *), int bufsize, byte **localPtr);
void VCR_PlaybackLocal(byte **localPtr, int lenWritten);
void VCR_Undo();
void VCR_ActivateAction(vcractiontype_t vt);
char *VCR_ActiveActionName();
int VCR_GetActionWriteLen();
void VCR_SetActionWriteLen(int ofs);
int VCR_GetActionReadLen();
void VCR_SetActionReadLen(int ofs);
void *VCR_GetActionData();
void VCR_ResetActionRead();
void VCR_EnlargeActionDataBuffer(int addbufsize);
int VCR_WriteByte(byte val);
int VCR_WriteShort(short val);
int VCR_WriteInt(int val);
int VCR_WriteFloat(float val);
int VCR_WriteString(char *str);
int VCR_WriteBulk(void *data, int len);
int VCR_ReadRemaining();
byte VCR_ReadByte();
short VCR_ReadShort();
int VCR_ReadInt();
float VCR_ReadFloat();
char *VCR_ReadString();
void VCR_ReadBulk(void *data, int len);
void VCR_ReadSetForward();
void VCR_ReadSetBackward();
//----------------------------------------------------------------------------
//    Class Headers
//----------------------------------------------------------------------------

//****************************************************************************
//**
//**    END HEADER VCR_MAN.H
//**
//****************************************************************************
#endif // __VCR_MAN_H__
