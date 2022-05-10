//****************************************************************************
//**
//**    SYS_MAIN.CPP
//**    System Control - Main Operations
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include <windows.h>
#include <windowsx.h>
#include <commctrl.h>

#include "cbl_defs.h"
#include "sys_main.h"
#include "ovl_work.h"
//----------------------------------------------------------------------------
//    Private Definitions
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Structures
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Additional External References
//----------------------------------------------------------------------------
extern HINSTANCE sys_hInst;
extern HWND sys_hwnd;
extern HWND sys_statusBarHwnd;
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
float sys_curTime=0.0;
float sys_frameTime;
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
	BITMAPFILEHEADER fhdr;
	BITMAPINFOHEADER ihdr;
	FILE *fp;
	int i, k;
	unsigned long val, r, g, b;
	char filebuf[_MAX_PATH];
	//GrLfbInfo_t lfbInfo;
	unsigned short *pbuffer;
	int pitch;
	int width = vid.resolution->width;
	int height = vid.resolution->height;

	strcpy(filebuf, filename);
	SYS_ForceFileExtention(filebuf, "BMP");
	fp = fopen(filebuf, "wb");
	if (!fp)
		return;

	//GLI_WriteBMP16(filename, (word *)lfbInfo.lfbPtr, 640, 480);
	
	fhdr.bfType = 0x4D42; // BM
	fhdr.bfSize = 0; // recalc
	fhdr.bfReserved1 = fhdr.bfReserved2 = 0;
	fhdr.bfOffBits = 0; // recalc
	SYS_SafeWrite(&fhdr, sizeof(BITMAPFILEHEADER), 1, fp);
	ihdr.biSize = sizeof(BITMAPINFOHEADER);
	ihdr.biWidth = width;
	ihdr.biHeight = height;
	ihdr.biPlanes = 1;
	ihdr.biBitCount = 24;
	ihdr.biCompression = BI_RGB;
	ihdr.biSizeImage = width*height*3;
	ihdr.biXPelsPerMeter = 0;
	ihdr.biYPelsPerMeter = 0;
	ihdr.biClrUsed = 0;
	ihdr.biClrImportant = 0;
	SYS_SafeWrite(&ihdr, sizeof(BITMAPINFOHEADER), 1, fp);
	fhdr.bfOffBits = ftell(fp);

	if (!vid.LockScreen(VLS_READFRONT, &pbuffer, &pitch))
		SYS_Error("SYS_Screenshot: LFB lock failure");

	for (i=height-1;i>=0;i--)
	{
		for (k=0;k<(width>>1);k++)
		{
			//val = data[i*width+k];
			val = *((unsigned long *)pbuffer + (i << 9) + k);
			r = (val >> 11) & 31; g = (val >> 5) & 63; b = val & 31;
			r <<= 3; g <<= 2; b <<= 3;
			SYS_SafeWrite(&b, 1, 1, fp);
			SYS_SafeWrite(&g, 1, 1, fp);
			SYS_SafeWrite(&r, 1, 1, fp);
			val >>= 16;
			r = (val >> 11) & 31; g = (val >> 5) & 63; b = val & 31;
			r <<= 3; g <<= 2; b <<= 3;
			SYS_SafeWrite(&b, 1, 1, fp);
			SYS_SafeWrite(&g, 1, 1, fp);
			SYS_SafeWrite(&r, 1, 1, fp);
		}
	}

	fhdr.bfSize = ftell(fp);
	fseek(fp, 0, SEEK_SET);
	SYS_SafeWrite(&fhdr, sizeof(BITMAPFILEHEADER), 1, fp);
	fclose(fp);

	vid.UnlockScreen();
	return;	
}

CONFUNC(Quit, NULL, 0)
{
	if ((argNum >= 2) && (!_stricmp(argList[1], "/Y")))
		SYS_Quit();
	if (SYS_MessageBox("Confirm Quit", MB_YESNO, "Are you sure you want to exit Cannibal?") == IDYES)
		SYS_Quit();
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
	int len = strlen(tbuffer);
	for (i=0;i<=99;i++)
	{
		sprintf(&tbuffer[len], "%d.bmp", i);
		sprintf(filebuf, "%s\\scrshots\\%s", sys_programPath, tbuffer);
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

void SYS_Init()
{
	char tbuffer[256];

	VID_Init();
	IN_Init();
	OVL_Init();

	CON->ExecuteFile(NULL, "cannibal.cfg", true);
	if ((SYS_CheckParm("backup", 0)) || (SYS_CheckParm("loadbackup", 0)))
		sprintf(tbuffer, "loadproject %s\\_backup_.mdx", sys_programPath);
	CON->ExecuteCmdLine(NULL, sys_argc, sys_argv);
	CON->Execute(NULL, tbuffer, 0);
}

void SYS_Frame()
{
	char tbuffer[128];
	static float lastTime=0;
	sys_curTime = SYS_GetTimeFloat();
	sys_frameTime = sys_curTime - lastTime;
	lastTime = sys_curTime;

	vid.ResetPolyCounts();
	IN_Process();
	OVL_Frame();
	IN_DrawCursor();
	vid.GetPolyCounts(&sys_polysPerFrame, &sys_linesPerFrame);
	if (sys_polycounts)
	{
		sprintf(tbuffer, "Lines: %d, Polys: %d", sys_linesPerFrame, sys_polysPerFrame);
		vid.DrawString(5, 20, 8, 8, tbuffer, true, 128, 128, 128);
	}
	if (sys_framerate)
	{
		vector_t p[4];
		p[0].Set(3, 3, 0);
		p[2].Set(p[0].x+(6.0/sys_frameTime), 13, 0);
		p[1].Set(p[2].x, p[0].y, 0);
		p[3].Set(p[0].x, p[2].y, 0);
		vid.ColorMode(VCM_FLAT);
		vid.FlatColor(255, 0, 0);
		vid.DrawPolygon(4, p, NULL, NULL, NULL, false);
		sprintf(tbuffer, "%.4f", 1.0/sys_frameTime);
		vid.DrawString(3, 5, 6, 6, tbuffer, true, 128, 128, 128);
	}
	vid.Swap();
//	vid.ClearScreen();
}

void SYS_Shutdown()
{
	OVL_Shutdown();
	IN_Shutdown();
	VID_Shutdown();
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

void SYS_Quit()
{
	char tbuffer[256];
	if ((SYS_CheckParm("backup", 0)) || (SYS_CheckParm("savebackup", 0)))
		sprintf(tbuffer, "saveproject %s\\_backup_.mdx", sys_programPath);
	CON->Execute(NULL, tbuffer, 0);
	SYS_Shutdown();
	exit(0);
}

int SYS_MessageBox(char *caption, unsigned long boxType, char *text, ... )
{
	static char textBuffer[512];
	va_list args;
	va_start(args, text);
	vsprintf(textBuffer, text, args);
	va_end(args);
	return(MessageBox(sys_hwnd, textBuffer, caption, boxType));
}

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

char *SYS_GetFilePath(char *filename)
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

char *SYS_GetFileName(char *filename)
{
	static char rootBuf[_MAX_PATH];
	char *ptr;
	ptr = strrchr(filename, '\\');
	if (!ptr) ptr = strrchr(filename, ':');
	if (!ptr) ptr = filename-1;
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
		U32 len=strlen(pathname);
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

//----------------------------------------------------------------------------
//    Class Member Code
//----------------------------------------------------------------------------


//****************************************************************************
//**
//**    END MODULE SYS_MAIN.CPP
//**
//****************************************************************************

