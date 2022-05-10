//****************************************************************************
//**
//**    SYS_MAIN.CPP
//**    System Control - Main Operations
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include "stdtool.h"
//----------------------------------------------------------------------------
//    Private Definitions
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Structures
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Additional External References
//----------------------------------------------------------------------------
//extern HINSTANCE sys_hInst;
//extern HWND sys_statusBarHwnd;
//----------------------------------------------------------------------------
//    Private Data
//----------------------------------------------------------------------------
static char sys_parseBuffer[1024];
static char *sys_parseArgv[32];
static int sys_parseArgc;
CONVAR(boolean, sys_polycounts, 0, 0, NULL);
CONVAR(boolean, sys_framerate, 0, 0, NULL);
//----------------------------------------------------------------------------
//    Public Data
//----------------------------------------------------------------------------
int sys_infatalblock = 0;
int sys_polysPerFrame = 0;
int sys_linesPerFrame = 0;
_int64 sys_profStart, sys_profStop;
sys_prof_t *sys_profPtr;

FileExtensionTypes img_ext_list[]=
{
	{"tga",SYS_IMAGE_TYPE_TGA},
	{"bmp",SYS_IMAGE_TYPE_BMP},
	{null,SYS_IMAGE_TYPE_NULL}
};

//----------------------------------------------------------------------------
//    Private Code Prototypes
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Code
//----------------------------------------------------------------------------

static void SYS_Screenshot(char *filename)
{
}

U32 quit_app(ConQueue *q);

CONFUNC(Quit, NULL, 0)
{
	mesh_app.QueueConsoleAction(argNum,(CC8 **)argList,quit_app);
}

U32 quit_app(ConQueue *q)
{
	U32 argNum;
	CC8 **argList;

	q->get_args(argNum,argList);
	
	if ((argNum >= 2) && (!_stricmp(argList[1], "/Y")))
		mesh_app.quit();
	if (SYS_MessageBox("Confirm Quit", MB_YESNO, "Are you sure you want to exit Cannibal?") == IDYES)
		mesh_app.quit();

	return TRUE;
}

CONFUNC(screenshot, NULL, 0)
{
	FILE *fp;
	char tbuffer[256];
	char filebuf[256];
	int i=0;

	char* mdxname = ((OWorkspace*)ovl_Windows)->mdxName;
	if (!mdxname || !mdxname[0])
		strcpy(tbuffer, "cblshot");
	else
		strcpy(tbuffer, SYS_GetFileRoot(mdxname));
	int len = fstrlen(tbuffer);
	for (i=0;i<=99;i++)
	{
		sprintf(&tbuffer[len], "%d.bmp", i);
		sprintf(filebuf, "%s\\scrshots\\%s", mesh_app.get_app_path(), tbuffer);
		fp = fopen(filebuf, "rb");
		if (!fp)
			break;
		fclose(fp);
	}
	SYS_Screenshot(filebuf);
}

//----------------------------------------------------------------------------
//    Public Code
//----------------------------------------------------------------------------

#if 0
void SYS_Init()
{
	char tbuffer[256];

	IN_Init();
	OVL_Init();

	CON->ExecuteFile(NULL, "cannibal.cfg", true);
	if ((SYS_CheckParm("backup", 0)) || (SYS_CheckParm("loadbackup", 0)))
		sprintf(tbuffer, "loadproject %s\\_backup_.mdx", sys_programPath);
	CON->ExecuteCmdLine(NULL, sys_argc, sys_argv);
	CON->Execute(NULL, tbuffer, 0);
}
#endif

void SYS_Frame()
{
	if (vid->is_active())
	{
		vid->BeginScene();
		vid->ClearScreen();
		IN_Process();
		OVL_Frame();
		IN_DrawCursor();
		vid->EndScene();
		vid->Swap();
	}
}

void SYS_Shutdown()
{
	OVL_Shutdown();
	IN_Shutdown();
	VCR_Shutdown();
}

void SYS_Error(char *text, ...)
{
	static char textBuffer[255];
	va_list args;
	va_start(args, text);
	vsprintf(textBuffer, text, args);
	va_end(args);
	SYS_MessageBox("Fatal Error", MB_OK, textBuffer);
	if (!sys_infatalblock)
	{
		sys_userException = 1;
		strcpy(sys_userExceptionString, textBuffer);
//		RaiseException(EXCEPTION_ACCESS_VIOLATION, 0, 0, NULL);
		SYS_Shutdown();
		ExitProcess(1);
	}
	else
	{
		SYS_Shutdown();
		ExitProcess(1);
	}
}

#if 0
void SYS_Quit()
{
	char tbuffer[256];
	if ((SYS_CheckParm("backup", 0)) || (SYS_CheckParm("savebackup", 0)))
		sprintf(tbuffer, "saveproject %s\\_backup_.mdx", mesh_app.get_app_path());
	CON->Execute(NULL, tbuffer, 0);
	SYS_Shutdown();
	exit(0);
}
#endif

int SYS_MessageBox(char *caption, unsigned long boxType, char *text, ... )
{
	static char textBuffer[512];
	va_list args;
	va_start(args, text);
	vsprintf(textBuffer, text, args);
	va_end(args);
	return(MessageBox(mesh_app.get_app_hwnd(), textBuffer, caption, boxType));
}

#if 0
void *SYS_SafeMalloc(int size)
{
	void *res = xmalloc(size+4);
	if (!res)
		SYS_Error("Out of memory");
	*((long *)res) = 0x2b3d5150;
	return((long *)res+1);
}

void SYS_SafeFree(void **ptr)
{
//	if (*((long *)0x00E8FF95) == 0xFFFFFFFF)
//		SYS_Error("Gotcha!");
	long *p;
	if (!(*ptr))
		SYS_Error("Attempt to free null ptr");
	p = (long *)*ptr; p -= 1;
	if (*p != 0x2b3d5150)
		SYS_Error("Attempt to free nonallocated pointer");
	xfree(p);
	*ptr = NULL;
}
#endif

void SYS_SafeRead(void *ptr, int elemSize, int numElems, FILE *fp)
{
	unsigned actual;
	if ((actual = fread(ptr, (unsigned)elemSize, (unsigned)numElems, fp)) != (unsigned)numElems)
		SYS_Error("SafeRead failure, %d elements read, %d attempted", actual, numElems);
}

void SYS_SafeWrite(void *ptr, int elemSize, int numElems, FILE *fp)
{
	if (fwrite(ptr, elemSize, numElems, fp) != (unsigned)numElems)
		SYS_Error("SafeWrite failure");
}

void SysGetFilePath(StrGrow &str,CC8 *filename)
{
	fstrlen(filename);
	CC8 *ptr=strrchr(filename,OS_SLASH);
	if (ptr)
	{
		str.reset();
		str.copy(filename,ptr - filename + 1);
		return;
	}
	ptr=strrchr(filename,':');
	if (ptr)
	{
		str.reset();
		str.copy(filename,ptr - filename + 1);
		str << OS_SLASH;
	}
}

CC8 *SYS_GetFilePath(CC8 *filename)
{
	static char rootBuf[_MAX_PATH];
	char *ptr;
	strcpy(rootBuf, filename);
	ptr = strrchr(rootBuf, '\\');
	if (ptr)
	{
		ptr[1] = 0;
		return(rootBuf);
	}
	ptr = strrchr(rootBuf, ':');
	if (ptr)
	{
		ptr[1] = 0;
		strcat(ptr, "\\");
		return(rootBuf);
	}
	rootBuf[0] = 0;
	return(rootBuf);
}

char *SYS_GetFileRoot(CC8 *filename)
{
	static char rootBuf[_MAX_PATH];
	CC8 *ptr;
	ptr = strrchr(filename, '\\');
	if (!ptr) ptr = strrchr(filename, ':');
	if (!ptr) ptr = filename-1;
	strcpy(rootBuf, ptr+1);
	ptr = strchr(rootBuf, '.');
	if (ptr) *((char *)ptr) = 0;
	return(rootBuf);
}

char *SYS_GetFileName(CC8 *filename)
{
	static char rootBuf[_MAX_PATH];
	char *ptr;
	ptr = strrchr(filename, '\\');
	if (!ptr) ptr = strrchr(filename, ':');
	if (!ptr) ptr = (char *)(filename-1);
	strcpy(rootBuf, ptr+1);
	return(rootBuf);
}

char *SYS_GetFileExtention(CC8 *filename)
{
	char *ptr = strrchr(filename, '.');
	if (ptr) ptr++;
	else ptr = "";
	return(ptr);
}

U32 SYS_GetImageTypeFromExt(CC8 *ext)
{
	if (!ext)
		return SYS_IMAGE_TYPE_NULL;
	FileExtensionTypes *list=img_ext_list;

	while(list->name)
	{
		if (_stricmp(list->name,ext)==0)
			return list->type;
		list++;
	}
	return SYS_IMAGE_TYPE_NULL;
}

U32 SYS_GetImageExtension(CC8 *filename)
{
	if (!filename)
		return SYS_IMAGE_TYPE_NULL;

	CC8 *ext=SYS_GetFileExtention(filename);

	return SYS_GetImageTypeFromExt(ext);
}

CC8 *SYS_CheckFileExist(CC8 *filename,CC8 *ext)
{
	static char pathname[MAX_PATH];
	
	if (ext)
	{
		strcpy(pathname,filename);
		char *dot=strrchr(pathname,'.');
		if (dot)*dot=0;
		U32 len=fstrlen(pathname);
		pathname[len]='.';
		pathname[len+1]=0;
		strcat(pathname,ext);
		filename=pathname;
	}
	
	XFile file;

	if (file.open(filename,"r"))
		return null;
	return filename;
}

void SYS_ForceFileExtention(char *filename, char *extention)
{
	char *ptr = strrchr(filename, '.');
	if (ptr) *ptr = 0;
	strcat(filename, ".");
	strcat(filename, extention);
}

void SYS_SuggestFileExtention(char *filename, char *extention)
{
	char *ptr = strrchr(filename, '.');
	if (!ptr)
	{
		strcat(filename, ".");
		strcat(filename, extention);
	}
}

#if 0
void SYS_Parse(char *text, ... )
{
	enum
	{
		STATE_NORMAL,
		STATE_QUOTE
	};
	va_list args;
	char *ptr;
	int state = STATE_NORMAL;
	int inWhiteSpace = 1;

	sys_parseArgc = 0;
	if (!text)
		return;
	va_start(args, text);
	vsprintf(sys_parseBuffer, text, args);
	va_end(args);

	for (ptr=sys_parseBuffer;*ptr;ptr++)
	{
		if (state == STATE_NORMAL)
		{
			if ((*ptr == '/') && (*(ptr+1) == '/'))
			{
				*ptr = 0;
				ptr--; // starting a comment, line's over
			}
			else
			if (*ptr == '`')
			{
				*ptr = '\"'; // replace tilde-key apostrophes with literal quotes
			}
			else
			if (*ptr == ' ')
			{
				*ptr = 0;
				inWhiteSpace = 1;
			}
			else
			if (inWhiteSpace)
			{
				if (sys_parseArgc >= 32)
				{
					*ptr = 0;
					ptr--;
				}
				else
				{
					sys_parseArgv[sys_parseArgc] = ptr;
					sys_parseArgc++;
					inWhiteSpace = 0;
					if (*ptr == '\"')
					{
						state = STATE_QUOTE;
						sys_parseArgv[sys_parseArgc-1] = ptr+1;
					}
				}
			}
		}
		else
		if (state == STATE_QUOTE)
		{
			if (*ptr == '\"')
			{
				*ptr = 0;
				state = STATE_NORMAL;
				inWhiteSpace = 1;
			}
			else
			if (*ptr == '`')
			{
				*ptr = '\"'; // replace tilde-key apostrophes with literal quotes
			}
		}
		else
			SYS_Error("SYS_Parse: Unknown state");
	}
}

int SYS_GetParseArgc()
{
	return(sys_parseArgc);
}

char **SYS_GetParseArgv()
{
	return(sys_parseArgv);
}

int SYS_CheckParm(char *str, int numparms)
{
	int i;
	for (i=1;i<(sys_argc-numparms);i++)
	{
		if ((sys_argv[i][0] == '-') && (!_stricmp(&sys_argv[i][1], str)))
			return(i);
	}
	return(0);
}
#endif

void MeshApp::sys_parse(CC8 *text,...)
{
	enum
	{
		STATE_NORMAL,
		STATE_QUOTE
	};
	va_list args;
	char *ptr;
	int parse_state = STATE_NORMAL;
	int inWhiteSpace = 1;

	if (!text)
		return;
	
	if (!state.sys_parse_init)
		init_sys_parse();

	va_start(args, text);
	while(1)
	{
		if (_vsnprintf(parse.buffer,parse.buffer_size,text,args)!=-1)
			break;
		parse.realloc_buffer();
	}
	va_end(args);

start_over:
	parse.argc=0;
	for (ptr=parse.buffer;*ptr;ptr++)
	{
		if (parse_state == STATE_NORMAL)
		{
			if ((*ptr == '/') && (*(ptr+1) == '/'))
			{
				*ptr = 0;
				ptr--; // starting a comment, line's over
			}
			else if (*ptr == '`')
			{
				*ptr = '\"'; // replace tilde-key apostrophes with literal quotes
			}
			else if (*ptr == ' ')
			{
				*ptr = 0;
				inWhiteSpace = 1;
			}
			else if (inWhiteSpace)
			{
				if (parse.argc >= parse.num_arg_alloc)
				{
					parse.realloc_argv();
					goto start_over;
				}
				else
				{
					parse.argv[parse.argc] = ptr;
					parse.argc++;
					inWhiteSpace = 0;
					if (*ptr == '\"')
					{
						parse_state = STATE_QUOTE;
						parse.argv[parse.argc-1] = ptr+1;
					}
				}
			}
		}
		else if (parse_state == STATE_QUOTE)
		{
			if (*ptr == '\"')
			{
				*ptr = 0;
				parse_state = STATE_NORMAL;
				inWhiteSpace = 1;
			}
			else if (*ptr == '`')
			{
				*ptr = '\"'; // replace tilde-key apostrophes with literal quotes
			}
		}
		else
			xxx_fatal("SYS_Parse: Unknown state");
	}
}

U32 MeshApp::get_parse_argc(void)
{
	return(parse.argc);
}

CC8 **MeshApp::get_parse_argv(void)
{
	return parse.get_argv();
}

U32 MeshApp::sys_check_parm(CC8 *str,U32 num_parms)
{
	int i;
	for (i=1;i<((I32)(argc - num_parms));i++)
	{
		if ((argv[i][0] == '-') && (!_stricmp(&argv[i][1], str)))
			return(i);
	}
	return(0);
}

void SysParse::init(void)
{
	num_arg_alloc=32;
	argv=(char **)xmalloc(sizeof(void *) * num_arg_alloc);

	buffer_size=1024;
	buffer=(char *)xmalloc(buffer_size);
}

void SysParse::close(void)
{
	delete argv;
	delete buffer;
}

void SysParse::realloc_buffer(void)
{
	delete buffer;
	buffer_size*=2;
	if (buffer_size > 1024*1024)
		xxx_fatal("SysParse::realloc_buffer: buffer size is obnoxious");
	buffer=(char *)xmalloc(buffer_size);
}

void SysParse::realloc_argv(void)
{
	delete argv;
	num_arg_alloc*=2;
	if (num_arg_alloc > 1024)
		xxx_fatal("SysParse::realloc_argv: num args is obnoxious");
	argv=(char **)xmalloc(sizeof(void *) * num_arg_alloc);
}
