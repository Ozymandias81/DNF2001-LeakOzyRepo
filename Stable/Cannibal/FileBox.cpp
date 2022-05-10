//****************************************************************************
//**
//**    FILEBOX.CPP
//**    Files - Dialog Boxes
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#define KRNINC_WIN32
#include "Kernel.h"
#include <direct.h>
//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
//============================================================================
//    PRIVATE DATA
//============================================================================
static NChar ofnMfbPath[_MAX_PATH] = {0};
static NChar *ofnMfbFileList = NULL;
static NBool ofnMfbFirstFile = 0;
static NChar ofnLastPath[_MAX_PATH] = {0};
static NChar ofnFileNameBuf[_MAX_PATH*64];
static char ofnDirBoxPath[_MAX_PATH] = {0};

static HWND ofnAppWindow = NULL;

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    PRIVATE FUNCTIONS
//============================================================================
static UINT APIENTRY FileBoxHook(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	switch(msg)
	{
	case WM_CREATE:
		if (ofnAppWindow)
		{
			SendMessage(ofnAppWindow, WM_KILLFOCUS, (WPARAM)hwnd, 0);
			return(0);
		}
		break;
	case WM_DESTROY:
		if (ofnAppWindow)
		{
			SendMessage(ofnAppWindow, WM_SETFOCUS, 0, 0);
			return(0);
		}
		break;
	default:
		break;
	}
	return(0);
}

static DLGPROC ofnDirBoxOrigDlgProc;
#define FILE_OFNDIRBOX_BUTTONID 0x1234

static BOOL CALLBACK DirBoxDlgProcOverride(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	switch(msg)
	{
	case WM_COMMAND:
		if (HIWORD(wParam) != BN_CLICKED)
			break;
		switch(LOWORD(wParam))
		{
		case FILE_OFNDIRBOX_BUTTONID:
			{
				SetDlgItemText(hwnd, edt1, "abcdefgh.ikj");
				wParam = IDOK;
				//HWND h = GetDlgItem(GetParent(hwnd), FILE_OFNDIRBOX_BUTTONID);
				//SetWindowLong(h, GWL_ID, IDOK);
			}
			break;
		default:
			break;
		}
		break;
	}
	return(ofnDirBoxOrigDlgProc(hwnd, msg, wParam, lParam));
}

static UINT APIENTRY DirBoxHook(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	switch(msg)
	{
	case WM_NOTIFY:
		{
			LPOFNOTIFY notify = (LPOFNOTIFY)lParam;
			switch(notify->hdr.code)
			{
			case CDN_INITDONE:
				{
					HWND parent=GetParent(hwnd);
					HWND h = GetDlgItem(parent, cmb1); EnableWindow(h, 0);
					
					h = GetDlgItem(parent, stc2); EnableWindow(h, 0);
					SetDlgItemText(parent, stc3, "Folder &name:");
					
					ofnDirBoxPath[0] = 0;
					SendMessage(parent, CDM_GETFOLDERPATH, 255, (LPARAM)ofnDirBoxPath);
					SetDlgItemText(parent, edt1, ofnDirBoxPath);

					//ofnDirBoxOrigDlgProc = (DLGPROC)GetWindowLong(parent, DWL_DLGPROC);
					//SetWindowLong(parent, DWL_DLGPROC, (LONG)DirBoxDlgProcOverride);

					//h = GetDlgItem(parent, IDOK);
					//SetWindowLong(h, GWL_ID, FILE_OFNDIRBOX_BUTTONID);
					//SendMessage(parent,CDM_SETCONTROLTEXT,IDOK,(DWORD)"pisser");
				}
				return(1);
				break;
			/*
			case CDN_FILEOK:
				SetWindowLong(hwnd, DWL_MSGRESULT, 1);
				return(1);
				break;
			*/
			case CDN_FOLDERCHANGE:
				{
					ofnDirBoxPath[0] = 0;
					SendMessage(GetParent(hwnd), CDM_GETFOLDERPATH, 255, (LPARAM)ofnDirBoxPath);
					SetDlgItemText(GetParent(hwnd), edt1, ofnDirBoxPath);
					//LOG_Logf("%s", ofnDirBoxPath);
				}
				return(0);
				break;
			default:
				break;
			}
		}
		break;
	case WM_CREATE:
		if (ofnAppWindow)
		{
			SendMessage(ofnAppWindow, WM_KILLFOCUS, (WPARAM)hwnd, 0);
			return(0);
		}
		break;
	case WM_DESTROY:
		if (ofnAppWindow)
		{
			SendMessage(ofnAppWindow, WM_SETFOCUS, 0, 0);
			return(0);
		}
		break;
	default:
		break;
	}
	return(0);
}

//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
KRN_API NBool FILE_BoxInit(void* inWindow)
{
	ofnAppWindow = (HWND)inWindow;
	return(1);
}

/* win2k updated */
typedef struct
{
	DWORD         lStructSize; 
	HWND          hwndOwner; 
	HINSTANCE     hInstance; 
	LPCTSTR       lpstrFilter; 
	LPTSTR        lpstrCustomFilter; 
	DWORD         nMaxCustFilter; 
	DWORD         nFilterIndex; 
	LPTSTR        lpstrFile; 
	DWORD         nMaxFile; 
	LPTSTR        lpstrFileTitle; 
	DWORD         nMaxFileTitle; 
	LPCTSTR       lpstrInitialDir; 
	LPCTSTR       lpstrTitle; 
	DWORD         Flags; 
	WORD          nFileOffset; 
	WORD          nFileExtension; 
	LPCTSTR       lpstrDefExt; 
	LPARAM        lCustData; 
	LPOFNHOOKPROC lpfnHook; 
	LPCTSTR       lpTemplateName; 
	void *        pvReserved;
	DWORD         dwReserved;
	DWORD         FlagsEx;
}SYS_OPENFILENAME_EX;


KRN_API NChar *FILE_OpenBox(NChar* inMaskInfo, NChar* inBoxTitle, NChar* inDefExt)
{
	SYS_OPENFILENAME_EX opfn;

	opfn.lStructSize=sizeof(SYS_OPENFILENAME_EX);
	opfn.FlagsEx=0;
	if (!is_win2k)
		opfn.lStructSize-=12;

	opfn.hwndOwner = ofnAppWindow;
	opfn.lpstrFilter = inMaskInfo;
	opfn.lpstrCustomFilter = NULL;
	opfn.nFilterIndex = 1;
	ofnFileNameBuf[0] = 0;
	opfn.lpstrFile = ofnFileNameBuf;
	opfn.nMaxFile = _MAX_PATH;
	opfn.lpstrFileTitle = NULL;
    if (!ofnLastPath[0])
		_getcwd(ofnLastPath, _MAX_PATH);
	opfn.lpstrInitialDir = ofnLastPath;
	opfn.lpstrTitle = inBoxTitle;
	opfn.Flags = OFN_LONGNAMES | OFN_FILEMUSTEXIST | OFN_PATHMUSTEXIST | OFN_EXPLORER | OFN_HIDEREADONLY | OFN_ENABLEHOOK;
	opfn.lpfnHook = FileBoxHook;
	opfn.lpstrDefExt = inDefExt;
	if (!GetOpenFileName((OPENFILENAME *)&opfn))
        return(NULL);
	strcpy(ofnLastPath, STR_FilePath(ofnFileNameBuf));
    if (ofnLastPath[strlen(ofnLastPath)-1] == '\\')
        ofnLastPath[strlen(ofnLastPath)-1] = 0;
    return(ofnFileNameBuf);
}

KRN_API NBool FILE_OpenBoxMulti(NChar* inMaskInfo, NChar* inBoxTitle, NChar* inDefExt)
{
	SYS_OPENFILENAME_EX opfn;

	opfn.lStructSize=sizeof(SYS_OPENFILENAME_EX);
	opfn.FlagsEx=0;
	if (!is_win2k)
		opfn.lStructSize-=12;

	opfn.hwndOwner = ofnAppWindow;
	opfn.lpstrFilter = inMaskInfo;
	opfn.lpstrCustomFilter = NULL;
	opfn.nFilterIndex = 1;
	ofnFileNameBuf[0] = 0;
	opfn.lpstrFile = ofnFileNameBuf;
	opfn.nMaxFile = _MAX_PATH*64;
	opfn.lpstrFileTitle = NULL;
    if (!ofnLastPath[0])
		_getcwd(ofnLastPath, _MAX_PATH);
	opfn.lpstrInitialDir = ofnLastPath;
	opfn.lpstrTitle = inBoxTitle;
	opfn.Flags = OFN_LONGNAMES | OFN_FILEMUSTEXIST | OFN_PATHMUSTEXIST
		| OFN_ALLOWMULTISELECT | OFN_EXPLORER | OFN_HIDEREADONLY;
	opfn.lpstrDefExt = inDefExt;
	if (!GetOpenFileName((OPENFILENAME *)&opfn))
		return(0);
	ofnMfbFileList = ofnFileNameBuf+strlen(ofnFileNameBuf)+1;
	strcpy(ofnMfbPath, ofnFileNameBuf);
	ofnFileNameBuf[0] = 0;
	ofnMfbFirstFile = true;
	strcpy(ofnLastPath, ofnMfbPath);
    if (ofnLastPath[strlen(ofnLastPath)-1] == '\\')
        ofnLastPath[strlen(ofnLastPath)-1] = 0;
	return(1);
}

KRN_API NChar* FILE_OpenBoxMultiGet()
{
	static char nameBuffer[_MAX_PATH];
	if (!ofnMfbFirstFile)
	{
		if (!ofnMfbFileList[0])
			return(NULL);
	}
	else
	{
		ofnMfbFirstFile = false;
		if (!ofnMfbFileList[0])
			return(ofnMfbPath);
	}
	strcpy(nameBuffer, ofnMfbPath);
	strcat(nameBuffer, "\\");
	strcat(nameBuffer, ofnMfbFileList);
	ofnMfbFileList += strlen(ofnMfbFileList)+1;
	return(nameBuffer);
}

KRN_API NChar* FILE_SaveBox(NChar* inMaskInfo, NChar* inBoxTitle, NChar* inDefExt, NChar* inDefFile)
{
	SYS_OPENFILENAME_EX opfn;

	opfn.lStructSize=sizeof(SYS_OPENFILENAME_EX);
	opfn.FlagsEx=0;
	if (!is_win2k)
		opfn.lStructSize-=12;

	opfn.hwndOwner = ofnAppWindow;
	opfn.lpstrFilter = inMaskInfo;
	opfn.lpstrCustomFilter = NULL;
	opfn.nFilterIndex = 1;
	ofnFileNameBuf[0] = 0;
	if (inDefFile)
		strcpy(ofnFileNameBuf, inDefFile);
	opfn.lpstrFile = ofnFileNameBuf;
	opfn.nMaxFile = _MAX_PATH;
	opfn.lpstrFileTitle = NULL;
    if (!ofnLastPath[0])
		_getcwd(ofnLastPath, _MAX_PATH);
	opfn.lpstrInitialDir = ofnLastPath;
	opfn.lpstrTitle = inBoxTitle;
	opfn.Flags = OFN_LONGNAMES | OFN_EXPLORER | OFN_OVERWRITEPROMPT | OFN_HIDEREADONLY | OFN_ENABLEHOOK;
	opfn.lpfnHook = FileBoxHook;
	opfn.lpstrDefExt = inDefExt;
	if (!GetSaveFileName((OPENFILENAME *)&opfn))
		return(NULL);
	strcpy(ofnLastPath, STR_FilePath(ofnFileNameBuf));
    if (ofnLastPath[strlen(ofnLastPath)-1] == '\\')
        ofnLastPath[strlen(ofnLastPath)-1] = 0;
    return(ofnFileNameBuf);
}

#include <shlobj.h>

void test_hack(void)
{
	BROWSEINFO browse;
	LPMALLOC pmalloc=null;
	OLECHAR olePath[MAX_PATH];
	IShellFolder *pDesktopFolder;
	U32 garbage, garbage2;
	LPITEMIDLIST pidl;

	CC8 *text="f:\\duke4\\meshes";

	SHGetDesktopFolder(&pDesktopFolder);
	MultiByteToWideChar(CP_ACP,MB_PRECOMPOSED,text,-1,olePath,MAX_PATH);

	HRESULT hr = pDesktopFolder->ParseDisplayName(NULL,NULL,olePath,&garbage,&pidl,&garbage2);
	
	SHGetMalloc(&pmalloc);
	
	browse.hwndOwner=ofnAppWindow;
	browse.pidlRoot=pidl;
	browse.lpszTitle="This blows";
	browse.ulFlags=0;
	if (is_new_gui)
		browse.ulFlags=0x50;
	browse.lpfn=null;
	browse.iImage=0;
	OleInitialize(null);
	LPITEMIDLIST sel=SHBrowseForFolder(&browse);
	if (sel)
		pmalloc->Free(sel);
	pDesktopFolder->Release();
}

int CALLBACK browse_callback(HWND hwnd,UINT umsg,LPARAM lparam,LPARAM lpdata)
{
	TCHAR szDir[MAX_PATH];

	switch (umsg)
	{
		case BFFM_INITIALIZED:
		{
			if (lpdata)
				SendMessage(hwnd,BFFM_SETSELECTION,TRUE,(LPARAM)lpdata);
			else if (GetCurrentDirectory(sizeof(szDir)/sizeof(TCHAR),szDir))
			{
				// WParam is TRUE since you are passing a path.
				// It would be FALSE if you were passing a pidl.
				SendMessage(hwnd,BFFM_SETSELECTION,TRUE,(LPARAM)szDir);
			}
			break;
		}
		case BFFM_SELCHANGED:
		{
			// Set the status window to the currently selected path.
			if (SHGetPathFromIDList((LPITEMIDLIST)lparam,szDir))
			{
				SendMessage(hwnd,BFFM_SETSTATUSTEXT,0,(LPARAM)szDir);
			}
			break;
		}
		default:
			break;
	}
	return 0;
}

KRN_API CC8 *FILE_DirSelect(CC8 *title,CC8 *base_path)
{
	BROWSEINFO browse;
	LPMALLOC pmalloc=null;
	char dir_name[MAX_PATH];

	SHGetMalloc(&pmalloc);

	browse.hwndOwner=ofnAppWindow;
	browse.pszDisplayName=dir_name;
	browse.pidlRoot=null;
	browse.lpszTitle=title;
	if (!title)
		browse.lpszTitle="Select Folder";
	browse.ulFlags=0x50;
	browse.lpfn=browse_callback;
	browse.iImage=0;
	browse.lParam=(U32)base_path;
	LPITEMIDLIST sel=SHBrowseForFolder(&browse);
	if (sel)
	{
		SHGetPathFromIDList(sel,dir_name);
		pmalloc->Free(sel);
	}
	pmalloc->Release();

	strcpy(ofnLastPath,dir_name);
    if (ofnLastPath[strlen(ofnLastPath)-1] == '\\')
        ofnLastPath[strlen(ofnLastPath)-1] = 0;
	return(ofnLastPath);
}

KRN_API NChar* FILE_DirBox(NChar* inBoxTitle)
{
	return (char *)FILE_DirSelect(inBoxTitle,null);
}

//============================================================================
//    CLASS METHODS
//============================================================================

//****************************************************************************
//**
//**    END MODULE FILEBOX.CPP
//**
//****************************************************************************

