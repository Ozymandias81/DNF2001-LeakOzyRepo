//****************************************************************************
//**
//**    VCR_MAN.CPP
//**    Action Recorder / Memory Streaming
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include "stdtool.h"
//----------------------------------------------------------------------------
//    Private Definitions
//----------------------------------------------------------------------------
#define MAXACTIONS 64

#define AF_READBACKWARD		0x00000001
//----------------------------------------------------------------------------
//    Private Structures
//----------------------------------------------------------------------------
typedef struct action_s action_t;
struct action_s
{
	U8 *data;
	U8 **localData;
	int datalen;
	char *sig;
	int readindex;
	int writeindex;
	int flags;
	void (*undofunc)(char *);
	action_t *next;
};
//----------------------------------------------------------------------------
//    Additional External References
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Data
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Data
//----------------------------------------------------------------------------
action_t *vcr_undoStack=NULL;
action_t *vcr_activeAction=NULL;
action_t *vcr_clipBoardAction=NULL;
action_t *vcr_localAction=NULL;

//----------------------------------------------------------------------------
//    Private Code
//----------------------------------------------------------------------------
CONFUNC(Undo, NULL, 0)
{
	VCR_Undo();
}

void VCR_Shutdown(void)
{
#if 0
	action_t *head=vcr_undoStack;
	while(head)
	{
		if (head->data)
			xfree(head->data);
		
		action_t *obj=head;
		head=head->next;
		
		delete obj;
	}

	head=vcr_activeAction;
	while(head)
	{
		if (head->data)
			xfree(head->data);
		
		action_t *obj=head;
		head=head->next;
		
		delete obj;
	}
	head=vcr_clipBoardAction;
	while(head)
	{
		if (head->data)
			xfree(head->data);
		
		action_t *obj=head;
		head=head->next;
		
		delete obj;
	}
	head=vcr_localAction;
	while(head)
	{
		if (head->data)
			xfree(head->data);
		
		action_t *obj=head;
		head=head->next;
		
		delete obj;
	}
#endif
}

static int WriteByte(action_t *action, U8 val)
{
	if (!action)
		SYS_Error("WriteByte: No open action");
	if (action->writeindex >= action->datalen)
		return(0);
	action->data[action->writeindex] = val;
	action->writeindex++;
	return(1);
}

static int WriteShort(action_t *action, short val)
{
	if (!action)
		SYS_Error("WriteShort: No open action");
	if (action->writeindex >= (action->datalen-1))
		return(0);
	*((short *)((U8 *)action->data+action->writeindex)) = val;
	action->writeindex += 2;
	return(1);
}

static int WriteInt(action_t *action, int val)
{
	if (!action)
		SYS_Error("WriteInt: No open action");
	if (action->writeindex >= (action->datalen-3))
		return(0);
	*((int *)((U8 *)action->data+action->writeindex)) = val;
	action->writeindex += 4;
	return(1);
}

static int WriteFloat(action_t *action, float val)
{
	if (!action)
		SYS_Error("WriteFloat: No open action");
	if (action->writeindex >= (action->datalen-3))
		return(0);
	*((float *)((U8 *)action->data+action->writeindex)) = val;
	action->writeindex += 4;
	return(1);
}

static int WriteBulk(action_t *action, void *data, int len)
{
	if (!action)
		SYS_Error("WriteBulk: No open action");
	if (action->writeindex >= (action->datalen-(len-1)))
		return(0);
	if (data)
		memcpy((U8 *)action->data+action->writeindex, data, len);
	else
		memset((U8 *)action->data+action->writeindex, 0, len);
	action->writeindex += len;
	return(1);
}

static int ReadRemaining(action_t *action)
{
	if (!action)
		SYS_Error("ReadByte: No open action");
	if (action->flags & AF_READBACKWARD)
		return(action->readindex);
	else
		return(action->writeindex - action->readindex);
}

static U8 ReadByte(action_t *action)
{
	if (!action)
		SYS_Error("ReadByte: No open action");
	if (action->flags & AF_READBACKWARD)
	{
		action->readindex--;
		if (action->readindex < 0)
			SYS_Error("ReadByte: Overflow in \"%s\"", action->sig);
		return(action->data[action->readindex]);
	}
	else
	{
		if (action->readindex >= action->writeindex)
			SYS_Error("ReadByte: Overflow in \"%s\"", action->sig);
		action->readindex++;
		return(action->data[action->readindex-1]);
	}
}

static short ReadShort(action_t *action)
{
	if (!action)
		SYS_Error("ReadInt: No open action");
	if (action->flags & AF_READBACKWARD)
	{
		action->readindex -= 2;
		if (action->readindex < 0)
			SYS_Error("ReadInt: Overflow in \"%s\"", action->sig);
		return(*((short *)((U8 *)action->data+action->readindex)));
	}
	else
	{
		if (action->readindex >= (action->writeindex-1))
			SYS_Error("ReadInt: Overflow in \"%s\"", action->sig);
		action->readindex += 2;
		return(*((short *)((U8 *)action->data+action->readindex-2)));
	}
}

static int ReadInt(action_t *action)
{
	if (!action)
		SYS_Error("ReadInt: No open action");
	if (action->flags & AF_READBACKWARD)
	{
		action->readindex -= 4;
		if (action->readindex < 0)
			SYS_Error("ReadInt: Overflow in \"%s\"", action->sig);
		return(*((int *)((U8 *)action->data+action->readindex)));
	}
	else
	{
		if (action->readindex >= (action->writeindex-3))
			SYS_Error("ReadInt: Overflow in \"%s\"", action->sig);
		action->readindex += 4;
		return(*((int *)((U8 *)action->data+action->readindex-4)));
	}
}

static float ReadFloat(action_t *action)
{
	if (!action)
		SYS_Error("ReadFloat: No open action");
	if (action->flags & AF_READBACKWARD)
	{
		action->readindex -= 4;
		if (action->readindex < 0)
			SYS_Error("ReadFloat: Overflow in \"%s\"", action->sig);
		return(*((float *)((U8 *)action->data+action->readindex)));
	}
	else
	{
		if (action->readindex >= (action->writeindex-3))
			SYS_Error("ReadFloat: Overflow in \"%s\"", action->sig);
		action->readindex += 4;
		return(*((float *)((U8 *)action->data+action->readindex-4)));
	}
}

static char *ReadString(action_t *action)
{
	static char tbuffer[2048];
	char *ptr;

	for (ptr = tbuffer; *ptr = (char)ReadByte(action); ptr++) ;
	return(tbuffer);
}

static void ReadBulk(action_t *action, void *data, int len)
{
	if (!action)
		SYS_Error("ReadBulk: No open action");
	if (action->flags & AF_READBACKWARD)
	{
		action->readindex -= len;
		if (action->readindex < 0)
			SYS_Error("ReadBulk: Overflow in \"%s\"", action->sig);
		if (data)
			memcpy(data, action->data+action->readindex, len);
		return;
	}
	else
	{
		if (action->readindex >= (action->writeindex-(len-1)))
			SYS_Error("ReadBulk: Overflow in \"%s\"", action->sig);
		action->readindex += len;
		if (data)
			memcpy(data, action->data+action->readindex-len, len);
		return;
	}
}

static void ReadSetForward(action_t *action)
{
	if (!action)
		SYS_Error("ReadSetForward: No open action");
	action->readindex = 0;
	action->flags &= ~AF_READBACKWARD;
}

static void ReadSetBackward(action_t *action)
{
	if (!action)
		SYS_Error("ReadSetBackward: No open action");
	action->readindex = action->writeindex;
	action->flags |= AF_READBACKWARD;
}

//----------------------------------------------------------------------------
//    Public Code
//----------------------------------------------------------------------------
void VCR_Record(vcractiontype_t vt, const char *nsig, void (*nundofunc)(char *), int bufsize, U8 **localPtr)
{
	int i;
	action_t *temp = ALLOC(action_t, 1);

	temp->readindex = 0;
	temp->writeindex = 0;
	temp->flags = 0;
	temp->sig = (char *)nsig;
	if (!temp->sig)
	{
		if (vt == VCRA_UNDO)
			temp->sig = "$UnknownUndo";
		if (vt == VCRA_CLIPBOARD)
			temp->sig = "$UnknownClipboard";
		if (vt == VCRA_LOCAL)
			temp->sig = "$UnknownLocal";
	}
	temp->undofunc = nundofunc;
	temp->datalen = bufsize;
	temp->data = ALLOC(U8, bufsize);
	temp->localData = localPtr;
	if (temp->localData)
		*temp->localData = temp->data;
	switch(vt)
	{
	case VCRA_UNDO:
		temp->next = vcr_undoStack;
		vcr_undoStack = temp;
		// if we'd already hit MAXACTIONS, kill the deepest one
		for (i=0;(i<MAXACTIONS)&&(temp->next);i++,temp=temp->next) ;
		if (temp->next)
		{
			if (temp->next->data)
			{
				FREE(temp->next->data);
				temp->next->data=null;
			}
			FREE(temp->next);
			temp->next = NULL;
		}
		break;
	case VCRA_CLIPBOARD:
		if (vcr_clipBoardAction)
		{
			if (vcr_clipBoardAction->data)
			{
				FREE(vcr_clipBoardAction->data);
				vcr_clipBoardAction->data=null;
			}
			FREE(vcr_clipBoardAction);
			vcr_clipBoardAction=null;
		}
		temp->next = NULL;
		vcr_clipBoardAction = temp;
		break;
	case VCRA_LOCAL:
		if (!temp->localData)
			SYS_Error("VCR_Record: Local action specified without data pointer");
		if (vcr_localAction)
		{
//			if (vcr_localAction->data)
//				FREE(vcr_localAction->data); // freeing data for locals is caller's responsibility
			FREE(vcr_localAction);
			vcr_localAction=null;
		}
		temp->next = NULL;
		vcr_localAction = temp;
		break;
	}
	VCR_ActivateAction(vt);
}

void VCR_PlaybackLocal(U8 **localPtr, int lenWritten)
{
	action_t *temp = ALLOC(action_t, 1);

	if ((!localPtr) || (!(*localPtr)))
		SYS_Error("VCR_PlaybackLocal: no data pointer given");
	temp->readindex = 0;
	temp->writeindex = lenWritten;
	temp->flags = 0;
	temp->sig = "";
	temp->undofunc = NULL;
	temp->datalen = lenWritten;
	temp->data = *localPtr;
	temp->localData = localPtr;
	if (vcr_localAction)
		FREE(vcr_localAction);
	vcr_localAction=null;
	temp->next = NULL;
	vcr_localAction = temp;
	VCR_ActivateAction(VCRA_LOCAL);
	VCR_ReadSetForward();
}

void VCR_Undo()
{
//	M_StatusBarText("Undoing: %s", VCR_CurrentActionName());
	if (!vcr_undoStack)
		return;
	if (vcr_undoStack->undofunc)
		vcr_undoStack->undofunc(vcr_undoStack->sig);
	action_t *temp = vcr_undoStack;
	vcr_undoStack = vcr_undoStack->next;
	if (temp->data)
		FREE(temp->data);
	temp->data=null;
	FREE(temp);
	temp=null;
	VCR_ActivateAction(VCRA_UNDO);
}

void VCR_ActivateAction(vcractiontype_t vt)
{
	switch(vt)
	{
	case VCRA_UNDO:
		vcr_activeAction = vcr_undoStack;
		break;
	case VCRA_CLIPBOARD:
		vcr_activeAction = vcr_clipBoardAction;
		break;
	case VCRA_LOCAL:
		vcr_activeAction = vcr_localAction;
		break;
	}
}

char *VCR_ActiveActionName()
{
	char *empty = "(empty)";
	if (!vcr_activeAction)
		return(empty);
	return(vcr_activeAction->sig);
}

int VCR_GetActionWriteLen()
{
	if (!vcr_activeAction)
		return(0);
	return(vcr_activeAction->writeindex);
}

void VCR_SetActionWriteLen(int ofs)
{
	if (!vcr_activeAction)
		return;
	vcr_activeAction->writeindex = ofs;
	if (vcr_activeAction->writeindex >= vcr_activeAction->datalen)
		SYS_Error("VCR_SetActionWriteLen: Overflow");
}

int VCR_GetActionReadLen()
{
	if (!vcr_activeAction)
		return(0);
	return(vcr_activeAction->readindex);
}

void VCR_SetActionReadLen(int ofs)
{
	if (!vcr_activeAction)
		return;
	vcr_activeAction->readindex = ofs;
	if (vcr_activeAction->readindex >= vcr_activeAction->datalen)
		SYS_Error("VCR_SetActionReadLen: Overflow");
}

void *VCR_GetActionData()
{
	if (!vcr_activeAction)
		return(NULL);
	return(vcr_activeAction->data);
}

void VCR_ResetActionRead()
{
	if (!vcr_activeAction)
		return;
	vcr_activeAction->readindex = 0;
}

void VCR_EnlargeActionDataBuffer(int addbufsize)
{
	if (!vcr_activeAction)
		return;
	U8 *odata = vcr_activeAction->data;
	vcr_activeAction->datalen += addbufsize;
	vcr_activeAction->data = ALLOC(U8, vcr_activeAction->datalen);
	if (vcr_activeAction->localData)
		*vcr_activeAction->localData = vcr_activeAction->data;
	memcpy(vcr_activeAction->data, odata, vcr_activeAction->datalen - addbufsize);
	FREE(odata);
	odata=null;
}

int VCR_WriteByte(U8 val)
{
	return(WriteByte(vcr_activeAction, val));
}

int VCR_WriteShort(short val)
{
	return(WriteShort(vcr_activeAction, val));
}

int VCR_WriteInt(int val)
{
	return(WriteInt(vcr_activeAction, val));
}

int VCR_WriteFloat(float val)
{
	return(WriteFloat(vcr_activeAction, val));
}

int VCR_WriteString(char *str)
{
	if (!str)
		return(0);
	return(WriteBulk(vcr_activeAction, str, fstrlen(str)+1));
}

int VCR_WriteBulk(void *data, int len)
{
	return(WriteBulk(vcr_activeAction, data, len));
}

int VCR_ReadRemaining()
{
	return(ReadRemaining(vcr_activeAction));
}

U8 VCR_ReadByte()
{
	return(ReadByte(vcr_activeAction));
}

short VCR_ReadShort()
{
	return(ReadShort(vcr_activeAction));
}

int VCR_ReadInt()
{
	return(ReadInt(vcr_activeAction));
}

float VCR_ReadFloat()
{
	return(ReadFloat(vcr_activeAction));
}

char *VCR_ReadString()
{
	return(ReadString(vcr_activeAction));
}

void VCR_ReadBulk(void *data, int len)
{
	ReadBulk(vcr_activeAction, data, len);
}

void VCR_ReadSetForward()
{
	ReadSetForward(vcr_activeAction);
}

void VCR_ReadSetBackward()
{
	ReadSetBackward(vcr_activeAction);
}

//----------------------------------------------------------------------------
//    Class Member Code
//----------------------------------------------------------------------------

//****************************************************************************
//**
//**    END MODULE VCR_MAN.CPP
//**
//****************************************************************************

