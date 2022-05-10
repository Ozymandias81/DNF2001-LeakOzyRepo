//****************************************************************************
//**
//**    STRMAIN.CPP
//**    String Utilities
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include <direct.h>
#include <io.h>
#include "Kernel.h"
#include "StrMain.h"

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
#define STR_FILEFINDSTACKDEPTH		64

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
struct CStrFileFindState
{
	signed long handle;
	char fileSpec[_MAX_PATH];
	char fileNameBuf[_MAX_PATH];

	CStrFileFindState()
	{
		handle = -1;
		fileSpec[0] = 0;
		fileNameBuf[0] = 0;
	}
};

//============================================================================
//    PRIVATE DATA
//============================================================================
static unsigned long str_Argc = 0;
static char** str_Argv = NULL;

static CStrFileFindState str_FileFindStack[STR_FILEFINDSTACKDEPTH+1];
static unsigned long str_FileFindStackIndex = 0;

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    PRIVATE FUNCTIONS
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
KRN_API char* STR_Va(char*& inFmt)
{
	static char buf[16384];
	if (!inFmt)
		return(NULL);
	va_list args;
	va_start(args, inFmt);
	vsprintf(buf, inFmt, args);
	va_end(args);
	return(buf);
}

KRN_API char* STR_Indent(unsigned long inNumSpc)
{
	static char buf[1024];
	if (inNumSpc > 1023)
		inNumSpc = 1023;
	memset(buf, ' ', inNumSpc);
	buf[inNumSpc] = 0;
	return(buf);
}

KRN_API char STR_Literal(char*& ioPtr)
{
	char r;
	int i, shifter;

	if (*ioPtr != '\\')
	{
		r = *ioPtr++;
		return(r);
	}

	ioPtr++; // eat slash
	if (!(*ioPtr)) return(0);
	switch(*ioPtr)
	{
	case '0': r = 0x00; ioPtr++; break;
	case 'n': r = 0x0A; ioPtr++; break;
	case 'r': r = 0x0D; ioPtr++; break;
	case 't': r = 0x09; ioPtr++; break;
	case 'x':
		r = 0; ioPtr++;
		shifter = 4;
		for (i=0;i<2;i++)
		{
			if (!(*ioPtr)) return(0);
			if ((*ioPtr >= '0') && (*ioPtr <= '9'))
				r += ((*ioPtr - '0') << shifter);
			else if ((*ioPtr >= 'a') && (*ioPtr <= 'f'))
				r += (((*ioPtr - 'a') + 10) << shifter);
			else if ((*ioPtr >= 'A') && (*ioPtr <= 'F'))
				r += (((*ioPtr - 'A') + 10) << shifter);
			ioPtr++;
			shifter -= 4;
		}
		break;
	default: r = *ioPtr++; break;
	}
	return(r);
}

KRN_API unsigned long STR_CalcHash(char* inStr)
{
	if (!inStr)
		return(0);
	unsigned long hash = 0x55555555 ^ strlen(inStr);
	char* str;
	unsigned long c;
	for (str = inStr; *str; str++)
	{
		c = toupper(*str);
		hash = c + _rotl((5 + (c ^ 101)) ^ (hash ^ 17), hash & 31);
	}
	return(hash);
}

KRN_API char* STR_FilePath(char* inFileName)
{
	static char buf[1024];
	char* ptr;
	strcpy(buf, inFileName);
	ptr = strrchr(buf, '\\');
	if (ptr)
	{
		ptr[1] = 0;
		return(buf);
	}
	ptr = strrchr(buf, ':');
	if (ptr)
	{
		ptr[1] = '\\';
		ptr[2] = 0;
		return(buf);
	}
	buf[0] = 0;
	return(buf);
}

KRN_API char* STR_FileRoot(char* inFileName)
{
	static char buf[1024];
	char* ptr;
	ptr = strrchr(inFileName, '\\');
	if (!ptr)
		ptr = strrchr(inFileName, ':');
	if (!ptr)
		ptr = inFileName-1;
	strcpy(buf, ptr+1);
	ptr = strchr(buf, '.');
	if (ptr)
		*ptr = 0;
	return(buf);
}

KRN_API char* STR_FileExtension(char* inFileName)
{
	char* ptr = strrchr(inFileName, '.');
	if (ptr)
		ptr++;
	else
		ptr = "";
	return(ptr);
}

KRN_API char* STR_FileSuggestedExt(char* inFileName, char* inExt)
{
	static char buf[1024];	
	strcpy(buf, inFileName);
	char* ptr = strrchr(buf, '.');
	if (!ptr)
	{
		strcat(buf, ".");
		strcat(buf, inExt);
	}
	return(buf);
}

KRN_API char* STR_FileForcedExt(char* inFileName, char* inExt)
{
	static char buf[1024];
	strcpy(buf, inFileName);
	char* ptr = strrchr(buf, '.');
	if (ptr)
		*ptr = 0;
	strcat(buf, ".");
	strcat(buf, inExt);
	return(buf);
}

KRN_API char* STR_FileFind(char* inFileSpec, int* outIsDir, unsigned long* outFileSize)
{	
	static _finddata_t data;
	CStrFileFindState* state = &str_FileFindStack[str_FileFindStackIndex];
	
	do
	{
		if (inFileSpec)
		{
			strcpy(state->fileSpec, inFileSpec);
			if ((state->handle = _findfirst(inFileSpec, &data)) == -1)
				return(NULL);
		}
		else
		{
			if (state->handle == -1)
				return(NULL);
			if (_findnext(state->handle, &data) == -1)
			{
				state->handle = -1;
				return(NULL);
			}			
		}
		if (outIsDir)
			*outIsDir = ((data.attrib & _A_SUBDIR)!=0);
		if (outFileSize)
			*outFileSize = data.size;
		strcpy(state->fileNameBuf, STR_FilePath(state->fileSpec));
		strcat(state->fileNameBuf, data.name);
		inFileSpec = NULL;
	} while (((data.attrib & _A_SUBDIR)!=0)
		&& ((!stricmp(data.name, ".")) || (!stricmp(data.name, ".."))));
	return(state->fileNameBuf);
}

KRN_API void STR_FileFindPushState()
{
	if (str_FileFindStackIndex >= STR_FILEFINDSTACKDEPTH)
		return;
	memcpy(&str_FileFindStack[str_FileFindStackIndex+1], &str_FileFindStack[str_FileFindStackIndex], sizeof(CStrFileFindState));
	str_FileFindStackIndex++;
}
KRN_API void STR_FileFindPopState()
{
	if (!str_FileFindStackIndex)
		return;
	str_FileFindStackIndex--;
}

KRN_API int STR_Chartoi(char* str)
{
    int value = 0;
    for (int i=0;i<4;i++)
    {
        if (!str[i])
            break;
        value += ((int)str[i] << (i << 3));
    }
    return(value);
}

KRN_API int STR_Binatoi(char* str)
{
    if (!str)
        return(0);
    char* ptr;
    int value=0, shifter=0;
    for (ptr=str+strlen(str)-1; ptr>str+1; ptr--)
    {
        if ((*ptr >= '0') && (*ptr <= '1'))
            value += ((*ptr - '0') << shifter);
        shifter++;
    }
    return(value);
}

KRN_API int STR_Octatoi(char* str)
{
    if (!str)
        return(0);
    char* ptr;
    int value=0, shifter=0;
    for (ptr=str+strlen(str)-1; ptr>str+1; ptr--)
    {
        if ((*ptr >= '0') && (*ptr <= '7'))
            value += ((*ptr - '0') << shifter);
        shifter += 3;
    }
    return(value);
}

KRN_API int STR_Hexatoi(char* str)
{
    if (!str)
        return(0);
    char* ptr;
    int value=0, shifter=0;
    for (ptr=str+strlen(str)-1; ptr>str+1; ptr--)
    {
        if ((*ptr >= '0') && (*ptr <= '9'))
            value += ((*ptr - '0') << shifter);
        else if ((*ptr >= 'A') && (*ptr <= 'F'))
            value += (((*ptr - 'A') + 10) << shifter);
        else if ((*ptr >= 'a') && (*ptr <= 'f'))
            value += (((*ptr - 'a') + 10) << shifter);
        shifter += 4;
    }
    return(value);
}

KRN_API void STR_ArgInit(unsigned long inArgc, char** inArgv)
{
	str_Argc = inArgc;
	str_Argv = inArgv;
}

KRN_API unsigned long STR_Argc()
{
	return(str_Argc);
}

KRN_API char* STR_Argv(unsigned long inIndex)
{
	return(str_Argv[inIndex]);
}

KRN_API unsigned long STR_ArgOption(char* inOptStr, unsigned long inReqParms)
{
	for (signed long i=1; i<((signed long)STR_Argc()-(signed long)inReqParms); i++)
	{
		if (((STR_Argv(i)[0] == '-') || (STR_Argv(i)[0] == '/'))
		 && (!stricmp(&STR_Argv(i)[1], inOptStr)))
		{
			return(i);
		}
	}
	return(0);
}


//============================================================================
//    CLASS METHODS
//============================================================================

//****************************************************************************
//**
//**    END MODULE STRMAIN.CPP
//**
//****************************************************************************

