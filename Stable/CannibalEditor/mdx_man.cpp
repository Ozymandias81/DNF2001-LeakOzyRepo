//****************************************************************************
//**
//**    MDX_MAN.CPP
//**    MDX Management
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include "cbl_defs.h"
#include "mdx_man.h"
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
//----------------------------------------------------------------------------
//    Public Code
//----------------------------------------------------------------------------
int MDX_LoadChunkFile(mdxChunkFile_t *cf, char *filename, char *tmark, int typevers)
{
	FILE *fp;
	ascfentrylink_t *temp;
	int i;

	fp = fopen(filename, "rb");
	if (!fp)
		return(0);
	SYS_SafeRead(&cf->header, sizeof(ascfheader_t), 1, fp);
	// check standard markers
	if ((cf->header.marker != (unsigned long)(ASCFMARKER))
		|| (cf->header.ascfVersion != ASCFVERSION))
	{
		fclose(fp);
		return(0);
	}
	// check user markers
	if ((cf->header.typeMarker != (unsigned long)((tmark[0]<<0)+(tmark[1]<<8)+(tmark[2]<<16)+(tmark[3]<<24)))
		|| (cf->header.typeVersion != typevers))
	{
		fclose(fp);
		return(0);
	}
	
	// read in directory info
	cf->dir = NULL;
	fseek(fp, cf->header.dirOfs, SEEK_SET);
	for (i=0;i<(int)cf->header.dirEntries;i++)
	{
		temp = ALLOC(ascfentrylink_t, 1);
		SYS_SafeRead(&temp->entry, sizeof(ascfentry_t), 1, fp);
		temp->data = NULL;
		temp->next = cf->dir;
		cf->dir = temp;
	}
	// load up chunks themselves
	for (temp=cf->dir;temp;temp=temp->next)
	{
		temp->data = ALLOC(char, temp->entry.chunkLen);
		fseek(fp, temp->entry.chunkOfs, SEEK_SET);
		SYS_SafeRead(temp->data, 1, temp->entry.chunkLen, fp);
	}
	// close file
	fclose(fp);
	return(1);
}

void MDX_NewChunkFile(mdxChunkFile_t *cf, char *tmark, int typevers)
{
	cf->header.marker = (unsigned long)(ASCFMARKER);
	cf->header.ascfVersion = ASCFVERSION;
	cf->header.typeMarker = (unsigned long)((tmark[0]<<0)+(tmark[1]<<8)+(tmark[2]<<16)+(tmark[3]<<24));
	cf->header.typeVersion = typevers;
	cf->header.fileSize = 0; // filled in at save time
	cf->header.dirOfs = 0; // "
	cf->header.dirEntries = 0; // "
	cf->header.user1 = 0;
	cf->header.user2 = 0;
	cf->dir = NULL;
}

int MDX_SaveChunkFile(mdxChunkFile_t *cf, char *filename)
{
	FILE *fp;
	ascfentrylink_t *temp;

	fp = fopen(filename, "wb");
	if (!fp)
		return(0);

	SYS_SafeWrite(&cf->header, sizeof(ascfheader_t), 1, fp); // will rewrite after data is written
	
	// write out chunk data
	for (temp=cf->dir;temp;temp=temp->next)
	{
		temp->entry.chunkOfs = ftell(fp);
		SYS_SafeWrite(temp->data, temp->entry.chunkLen, 1, fp);
	}
	// write out directory info
	cf->header.dirOfs = ftell(fp);
	cf->header.dirEntries = 0;
	for (temp=cf->dir;temp;temp=temp->next)
	{
		SYS_SafeWrite(&temp->entry, sizeof(ascfentry_t), 1, fp);
		cf->header.dirEntries++;
	}	
	cf->header.fileSize = ftell(fp);
	// rewrite final header
	fseek(fp, 0, SEEK_SET);
	SYS_SafeWrite(&cf->header, sizeof(ascfheader_t), 1, fp);

	// close file
	fclose(fp);
	return(1);
}

void MDX_FreeChunkFile(mdxChunkFile_t *cf)
{
	ascfentrylink_t *temp, *next;

	for (temp=cf->dir;temp;temp=next)
	{		
		next = temp->next;
		FREE(temp->data);
		FREE(temp);
	}
}

ascfentrylink_t *MDX_FindChunk(mdxChunkFile_t *cf, ascfentrylink_t *prev, char *label, char *instance, int *len, int *version)
{
	ascfentrylink_t *temp;

	if (!prev)
		prev = cf->dir;
	else
		prev = prev->next;
	for (temp=prev;temp;temp=temp->next)
	{
		if ((label) &&
			(temp->entry.chunkLabel != (unsigned long)((label[0]<<0)+(label[1]<<8)+(label[2]<<16)+(label[3]<<24))))
			continue;
		if ((instance) &&
			(strcmp(temp->entry.chunkInstance, instance)))
			continue;
		// chunk found
		if (len)
			*len = temp->entry.chunkLen;
		if (version)
			*version = temp->entry.chunkVersion;
		return(temp);
	}
	return(NULL);
}

ascfentrylink_t *MDX_AddChunk(mdxChunkFile_t *cf, char *label, char *instance, int len, byte version, void *data)
{
	ascfentrylink_t *temp;

	temp = ALLOC(ascfentrylink_t, 1);
	if (label)
		temp->entry.chunkLabel = *((unsigned long *)label);
	else
		temp->entry.chunkLabel = *((unsigned long *)"????");
	memset(temp->entry.chunkInstance, 0, 32);
	if (instance)
		strncpy(temp->entry.chunkInstance, instance, 31);
	temp->entry.chunkLen = len;
	temp->entry.chunkVersion = version;
	temp->entry.reserved[0] = 0;
	temp->entry.reserved[1] = 0;
	temp->entry.reserved[2] = 0;
	temp->entry.chunkOfs = 0; // filled in at save time
	temp->data = ALLOC(char, len);
	memcpy(temp->data, data, len);
	temp->next = cf->dir;
	cf->dir = temp;
	return(temp);
}

//----------------------------------------------------------------------------
//    Class Member Code
//----------------------------------------------------------------------------

//****************************************************************************
//**
//**    END MODULE MDX_MAN.CPP
//**
//****************************************************************************

