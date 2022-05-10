#ifndef __SYS_MAIN_H__
#define __SYS_MAIN_H__
//****************************************************************************
//**
//**    SYS_MAIN.H
//**    Header - System Control - Main Operations
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include "cbl_defs.h"
//----------------------------------------------------------------------------
//    Definitions
//----------------------------------------------------------------------------
#define ALLOC(type, num) (type*)SYS_SafeMalloc((num)*sizeof(type))
#define FREE(ptr) SYS_SafeFree((void **)&ptr)

#define RDTSC(var) \
	_asm _emit 0x0F \
	_asm _emit 0x31 \
	_asm mov DWORD PTR var, eax \
	_asm mov DWORD PTR var+4, edx

#define SYS_IMAGE_TYPE_NULL 0
#define SYS_IMAGE_TYPE_BMP	1
#define	SYS_IMAGE_TYPE_TGA	2

//----------------------------------------------------------------------------
//    Class Prototypes
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Required External Class References
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Structures
//----------------------------------------------------------------------------
typedef struct sys_prof_s sys_prof_t;
struct sys_prof_s
{
	const char *name;
	_int64 start, stop;
	unsigned long cycles;
};

typedef struct
{
	CC8 *name;
	U32 type;
}FileExtensionTypes;

//----------------------------------------------------------------------------
//    Public Data Declarations
//----------------------------------------------------------------------------
extern float sys_curTime;
extern float sys_frameTime;
extern int sys_infatalblock;
extern int sys_polysPerFrame;
extern int sys_linesPerFrame;
extern _int64 sys_profStart, sys_profStop;
extern sys_prof_t *sys_profPtr;
extern FileExtensionTypes img_ext_list[];
//----------------------------------------------------------------------------
//    Public Function Declarations
//----------------------------------------------------------------------------
void SYS_Init();
void SYS_Frame();
void SYS_Shutdown();
extern "C" void SYS_Error(char *text, ...);
void SYS_Quit();
int SYS_MessageBox(char *caption, unsigned long boxType, char *text, ... );
extern "C" void *SYS_SafeMalloc(int size);
extern "C" void SYS_SafeFree(void **ptr);
extern "C" void SYS_SafeRead(void *ptr, int elemSize, int numElems, FILE *fp);
extern "C" void SYS_SafeWrite(void *ptr, int elemSize, int numElems, FILE *fp);
extern "C" char *SYS_GetFilePath(char *filename);
extern "C" char *SYS_GetFileRoot(CC8 *filename);
extern "C" char *SYS_GetFileName(char *filename);
extern "C" char *SYS_GetFileExtention(CC8 *filename);
extern "C" CC8 *SYS_CheckFileExist(CC8 *filename,CC8 *ext);
extern "C" U32 SYS_GetImageExtension(CC8 *filename);
extern "C" U32 SYS_GetImageTypeFromExt(CC8 *ext);
extern "C" void SYS_ForceFileExtention(char *filename, char *extention);
extern "C" void SYS_SuggestFileExtention(char *filename, char *extention);
void SYS_Parse(char *text, ... );
int SYS_GetParseArgc();
char **SYS_GetParseArgv();
int SYS_CheckParm(char *str, int numparms);

void VID_Init();
void VID_Shutdown();

//----------------------------------------------------------------------------
//    Class Headers
//----------------------------------------------------------------------------
template <class T>
class pool_t
{
private:
	int numElements;
	byte *usedFlags;
	T *data;
	int numUsed, current;
	void (*initFunc)(T *item, char *info);
	void (*removeFunc)(T *item);
	const char *poolname;
	boolean valid;

public:
	pool_t(const char *name, int num, void (*init)(T *, char *), void (*remove)(T *))
	{
		poolname = name;
		numElements = num;
		usedFlags = ALLOC(byte, numElements/8 + 1);
		memset(usedFlags, 0, numElements/8 + 1);
		data = ALLOC(T, numElements);
		numUsed = 0;
		current = 0;
		initFunc = init;
		removeFunc = remove;
		valid = 1;
	}
	~pool_t()
	{
		valid = 0;
		FREE(usedFlags);
		FREE(data);
	}

	T *Alloc(char *info)
	{		
		if (!valid)
			SYS_Error("pool_t: Pool is invalid");
		int attempted;
		for (attempted=0; attempted<numElements; current++,attempted++)
		{
			if (current == numElements)
				current = 0;
			if (!(usedFlags[current>>3] & (1 << (current&7))))
			{
				usedFlags[current>>3] |= (1 << (current&7));
				if (initFunc)
					initFunc(&data[current], info);
				else
					memset(&data[current], 0, sizeof(T));
				return(&data[current]);
			}
		}
		SYS_Error("pool_t: Pool %s is empty", poolname);
		return(NULL);
	}

	void Free(T *item)
	{
		int index = item - data;
		if ((index < 0) || (index >= numElements))
			SYS_Error("pool_t: Pool %s received Free request on out-of-range item");
		if (!(usedFlags[index>>3] & (1 << (index&7))))
			SYS_Error("pool_t: Pool %s received Free request on unused item");
		usedFlags[index>>3] &= ~(1 << (index&7));
		if (removeFunc)
			removeFunc(item);
	}

	boolean PoolValid()
	{
		return(valid);
	}

	void FreeAll()
	{
		FREE(usedFlags);
		usedFlags = ALLOC(byte, numElements/8 + 1);
		memset(usedFlags, 0, numElements/8 + 1);
	}
};

//****************************************************************************
//**
//**    END HEADER SYS_MAIN.H
//**
//****************************************************************************
#endif // __SYS_MAIN_H__
