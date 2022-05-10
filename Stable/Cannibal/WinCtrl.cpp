//****************************************************************************
//**
//**    WINCTRL.CPP
//**    Win32 Common Controls
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#define KRNINC_WIN32
#include "Kernel.h"
#include "ObjMain.h"
#include "WinCtrl.h"

#include "res\resource.h"

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
struct SWinInputBoxInfo
{
	const NChar* mCaption;
	const NChar* mDefInput;
	NChar* mText;
};

struct SWinSelectionBoxInfo
{
	const NChar* mCaption;
	NChar* mChoices;
	NChar* mText;
};

struct SWinVectorBoxInfo
{
	const NChar* mCaption;
	VVec3 mDefInput;
	const NChar* mLabelX;
	const NChar* mLabelY;
	const NChar* mLabelZ;
};

//============================================================================
//    PRIVATE DATA
//============================================================================
//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    PRIVATE FUNCTIONS
//============================================================================
static BOOL CALLBACK WIN_InputBoxDlgProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	static NChar outBuf[1024];
	SWinInputBoxInfo* info;
	RECT rect;

	switch(msg)
	{
	case WM_INITDIALOG:
		info = (SWinInputBoxInfo*)lParam;
		GetWindowRect(hWnd, &rect);
		SetWindowPos(hWnd, HWND_TOP,
			(GetSystemMetrics(SM_CXSCREEN)-(rect.right-rect.left))/2,
			(GetSystemMetrics(SM_CYSCREEN)-(rect.bottom-rect.top))/2,
			rect.right-rect.left, rect.bottom-rect.top, SWP_SHOWWINDOW);
		SetWindowText(hWnd, info->mCaption);
		SetDlgItemText(hWnd, IDC_ST_WIN_INPUTBOX, info->mText);
		SetDlgItemText(hWnd, IDC_EB_WIN_INPUTBOX, info->mDefInput);
		return(1);
		break;
	case WM_COMMAND:
		switch(GET_WM_COMMAND_ID(wParam, lParam))
		{
		case IDCANCEL:
			EndDialog(hWnd, (NDword)NULL);
			break;
		case IDOK:
			GetDlgItemText(hWnd, IDC_EB_WIN_INPUTBOX, outBuf, 1023);
			EndDialog(hWnd, (NDword)outBuf);
			break;
		default:
			break;
		}
		break;
	}
	return(0);
}

static BOOL CALLBACK WIN_SelectionBoxDlgProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	static NChar outBuf[1024];
	SWinSelectionBoxInfo* info;
	RECT rect;
	NChar* ptr;
	NInt selItem;

	switch(msg)
	{
	case WM_INITDIALOG:
		GetWindowRect(hWnd, &rect);
		SetWindowPos(hWnd, HWND_TOP,
			(GetSystemMetrics(SM_CXSCREEN)-(rect.right-rect.left))/2,
			(GetSystemMetrics(SM_CYSCREEN)-(rect.bottom-rect.top))/2,
			rect.right-rect.left, rect.bottom-rect.top, SWP_SHOWWINDOW);
		info = (SWinSelectionBoxInfo*)lParam;
		SetWindowText(hWnd, info->mCaption);
		SetDlgItemText(hWnd, IDC_ST_WIN_SELECTIONBOX, info->mText);
		for (ptr=info->mChoices; *ptr; ptr += strlen(ptr)+1)
			SendDlgItemMessage(hWnd, IDC_LB_WIN_SELECTIONBOX, LB_ADDSTRING, 0, (LPARAM)ptr);
		SendDlgItemMessage(hWnd, IDC_LB_WIN_SELECTIONBOX, LB_SETCURSEL, 0, 0);
		return(1);
		break;
	case WM_COMMAND:
		switch(GET_WM_COMMAND_ID(wParam, lParam))
		{
		case IDCANCEL:
			EndDialog(hWnd, (NDword)NULL);
			break;
		case IDOK:
			if ((selItem = SendDlgItemMessage(hWnd, IDC_LB_WIN_SELECTIONBOX, LB_GETCURSEL, 0, 0)) == LB_ERR)
				EndDialog(hWnd, (NDword)NULL);
			SendDlgItemMessage(hWnd, IDC_LB_WIN_SELECTIONBOX, LB_GETTEXT, selItem, (LPARAM)outBuf);
			EndDialog(hWnd, (NDword)outBuf);
			break;
		default:
			break;
		}
		break;
	}
	return(0);
}

static BOOL CALLBACK WIN_SelectionBoxMultiDlgProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	static NChar outBuf[4096], tempBuf[256];
	SWinSelectionBoxInfo* info;
	RECT rect;
	NChar* ptr;
	NInt i, itemCount;

	switch(msg)
	{
	case WM_INITDIALOG:
		GetWindowRect(hWnd, &rect);
		SetWindowPos(hWnd, HWND_TOP,
			(GetSystemMetrics(SM_CXSCREEN)-(rect.right-rect.left))/2,
			(GetSystemMetrics(SM_CYSCREEN)-(rect.bottom-rect.top))/2,
			rect.right-rect.left, rect.bottom-rect.top, SWP_SHOWWINDOW);
		info = (SWinSelectionBoxInfo*)lParam;
		SetWindowText(hWnd, info->mCaption);
		SetDlgItemText(hWnd, IDC_ST_WIN_SELECTIONBOX, info->mText);
		for (ptr=info->mChoices; *ptr; ptr += strlen(ptr)+1)
			SendDlgItemMessage(hWnd, IDC_LB_WIN_SELECTIONBOX, LB_ADDSTRING, 0, (LPARAM)ptr);
		return(1);
		break;
	case WM_COMMAND:
		switch(GET_WM_COMMAND_ID(wParam, lParam))
		{
		case IDCANCEL:
			EndDialog(hWnd, (NDword)NULL);
			break;
		case IDOK:
			ptr = outBuf;
			ptr[0] = ptr[1] = 0;
			itemCount = SendDlgItemMessage(hWnd, IDC_LB_WIN_SELECTIONBOX, LB_GETCOUNT, 0, 0);
			for (i=0;i<itemCount;i++)
			{
				if (!SendDlgItemMessage(hWnd, IDC_LB_WIN_SELECTIONBOX, LB_GETSEL, i, 0))
					continue; // item not selected, skip it
				if (SendDlgItemMessage(hWnd, IDC_LB_WIN_SELECTIONBOX, LB_GETTEXT, i, (LPARAM)tempBuf) == LB_ERR)
					continue; // error, skip it
				strcpy(ptr, tempBuf);
				ptr += strlen(ptr)+1;
			}
			ptr[0] = 0;
			EndDialog(hWnd, (NDword)outBuf);
			break;
		case IDC_BT_WIN_SELECTIONBOXMULTI_SELALL:
			itemCount = SendDlgItemMessage(hWnd, IDC_LB_WIN_SELECTIONBOX, LB_GETCOUNT, 0, 0);
			for (i=0;i<itemCount;i++)
				SendDlgItemMessage(hWnd, IDC_LB_WIN_SELECTIONBOX, LB_SETSEL, 1, i);
			break;
		case IDC_BT_WIN_SELECTIONBOXMULTI_SELNONE:
			itemCount = SendDlgItemMessage(hWnd, IDC_LB_WIN_SELECTIONBOX, LB_GETCOUNT, 0, 0);
			for (i=0;i<itemCount;i++)
				SendDlgItemMessage(hWnd, IDC_LB_WIN_SELECTIONBOX, LB_SETSEL, 0, i);
			break;
		default:
			break;
		}
		break;
	}
	return(0);
}

static BOOL CALLBACK WIN_VectorBoxDlgProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	static VVec3 outVec;
	SWinVectorBoxInfo* info;
	RECT rect;
	char buf[256];

	switch(msg)
	{
	case WM_INITDIALOG:
		info = (SWinVectorBoxInfo*)lParam;
		GetWindowRect(hWnd, &rect);
		SetWindowPos(hWnd, HWND_TOP,
			(GetSystemMetrics(SM_CXSCREEN)-(rect.right-rect.left))/2,
			(GetSystemMetrics(SM_CYSCREEN)-(rect.bottom-rect.top))/2,
			rect.right-rect.left, rect.bottom-rect.top, SWP_SHOWWINDOW);
		SetWindowText(hWnd, info->mCaption);
		SetDlgItemText(hWnd, IDC_ST_WIN_VECTORBOX_X, info->mLabelX);
		SetDlgItemText(hWnd, IDC_ST_WIN_VECTORBOX_Y, info->mLabelY);
		SetDlgItemText(hWnd, IDC_ST_WIN_VECTORBOX_Z, info->mLabelZ);
		sprintf(buf, "%f", info->mDefInput.x); SetDlgItemText(hWnd, IDC_EB_WIN_VECTORBOX_X, buf);
		sprintf(buf, "%f", info->mDefInput.y); SetDlgItemText(hWnd, IDC_EB_WIN_VECTORBOX_Y, buf);
		sprintf(buf, "%f", info->mDefInput.z); SetDlgItemText(hWnd, IDC_EB_WIN_VECTORBOX_Z, buf);
		return(1);
		break;
	case WM_COMMAND:
		switch(GET_WM_COMMAND_ID(wParam, lParam))
		{
		case IDCANCEL:
			EndDialog(hWnd, (NDword)NULL);
			break;
		case IDOK:			
			GetDlgItemText(hWnd, IDC_EB_WIN_VECTORBOX_X, buf, 255); outVec.x = (NFloat)atof(buf);
			GetDlgItemText(hWnd, IDC_EB_WIN_VECTORBOX_Y, buf, 255); outVec.y = (NFloat)atof(buf);
			GetDlgItemText(hWnd, IDC_EB_WIN_VECTORBOX_Z, buf, 255); outVec.z = (NFloat)atof(buf);
			EndDialog(hWnd, (NDword)&outVec);
			break;
		default:
			break;
		}
		break;
	}
	return(0);
}

//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
KRN_API NChar* WIN_InputBox(const NChar* inCaption, const NChar* inDefInput, NChar* inFmt, ... )
{
	static NChar buf[1024];
	SWinInputBoxInfo info;

	info.mCaption = inCaption;
	info.mDefInput = inDefInput;
	strcpy(buf, STR_Va(inFmt));
	info.mText = buf;
	NChar* result = (NChar*)DialogBoxParam((HINSTANCE)KRN_GetModuleHandle(), MAKEINTRESOURCE(IDD_WIN_INPUTBOX),
		NULL, (DLGPROC)WIN_InputBoxDlgProc, (LPARAM)&info);
	if (!result || !result[0])
		return(NULL);
	return(result);
}

KRN_API NChar* WIN_SelectionBox(const NChar* inCaption, const NChar* inChoices, NChar* inFmt, ... )
{
	static NChar buf[4096];
	SWinSelectionBoxInfo info;

	info.mCaption = inCaption;
	info.mChoices = (NChar*)inChoices;
	strcpy(buf, STR_Va(inFmt));
	info.mText = buf;
	NChar* result = (NChar*)DialogBoxParam((HINSTANCE)KRN_GetModuleHandle(), MAKEINTRESOURCE(IDD_WIN_SELECTIONBOX),
		NULL, (DLGPROC)WIN_SelectionBoxDlgProc, (LPARAM)&info);
	if (!result || !result[0])
		return(NULL);
	return(result);
}

static NChar* win_SelectionBoxMultiResult = NULL;
KRN_API NBool WIN_SelectionBoxMulti(const NChar* inCaption, const NChar* inChoices, NChar* inFmt, ... )
{
	static NChar buf[4096];
	SWinSelectionBoxInfo info;

	info.mCaption = inCaption;
	info.mChoices = (NChar*)inChoices;
	strcpy(buf, STR_Va(inFmt));
	info.mText = buf;
	NChar* result = (NChar*)DialogBoxParam((HINSTANCE)KRN_GetModuleHandle(), MAKEINTRESOURCE(IDD_WIN_SELECTIONBOXMULTI),
		NULL, (DLGPROC)WIN_SelectionBoxMultiDlgProc, (LPARAM)&info);
	win_SelectionBoxMultiResult = NULL;
	if (!result || !result[0])
		return(0);
	win_SelectionBoxMultiResult = result;
	return(1);
}
KRN_API NChar* WIN_SelectionBoxMultiGet()
{
	if (!win_SelectionBoxMultiResult)
		return(NULL);
	NChar* result = win_SelectionBoxMultiResult;
	win_SelectionBoxMultiResult += strlen(win_SelectionBoxMultiResult)+1;
	if (!win_SelectionBoxMultiResult[0])
		win_SelectionBoxMultiResult = NULL;
	return(result);
}

KRN_API VVec3 WIN_VectorBox(const NChar* inCaption, const VVec3& inDefInput,
							const NChar* inX, const NChar* inY, const NChar* inZ)
{
	SWinVectorBoxInfo info;
	info.mCaption = inCaption;
	info.mDefInput = inDefInput;
	if (!inX) inX = "X";
	info.mLabelX = inX;
	if (!inY) inY = "Y";
	info.mLabelY = inY;
	if (!inZ) inZ = "Z";
	info.mLabelZ = inZ;
	VVec3* result = (VVec3*)DialogBoxParam((HINSTANCE)KRN_GetModuleHandle(), MAKEINTRESOURCE(IDD_WIN_VECTORBOX),
		NULL, (DLGPROC)WIN_VectorBoxDlgProc, (LPARAM)&info);
	if (!result)
		return(inDefInput);
	return(*result);
}

//============================================================================
//    CLASS METHODS
//============================================================================
/*
	OWinImageList
*/
OBJ_CLASS_IMPLEMENTATION(OWinImageList, OObject, 0);

void OWinImageList::Create()
{
	Super::Create();
	mList = NULL;
}
void OWinImageList::Destroy()
{
	if (mList)
		ImageList_Destroy(mList);
	Super::Destroy();
}

HIMAGELIST OWinImageList::GetHandle()
{
	return(mList);
}
NBool OWinImageList::Init(NDword inImageWidth, NDword inImageHeight, NDword inInitialCount)
{
	if (mList = ImageList_Create(inImageWidth, inImageWidth, ILC_COLOR, inInitialCount, 1))
		return(1);
	return(0);
}
SWinImageListImage* OWinImageList::AddImage(NDword inResID)
{
	HINSTANCE hInst = (HINSTANCE)KRN_GetModuleHandle();
	HBITMAP hbmp = (HBITMAP)LoadImage(hInst, MAKEINTRESOURCE(inResID), IMAGE_BITMAP, 0, 0, LR_LOADTRANSPARENT);
	if (!hbmp)
		return(0);
	SWinImageListImage* result = &mImages[mImages.Add()];
	result->mIndex = ImageList_Add(mList, hbmp, (HBITMAP)NULL);
	result->mResID = inResID;
	DeleteObject(hbmp);
	return(result);
}
SWinImageListImage* OWinImageList::FindImage(NDword inResID)
{
	for (NDword i=0;i<mImages.GetCount();i++)
	{
		if (mImages[i].mResID == inResID)
			return(&mImages[i]);
	}
	return(NULL);
}

/*
	OWinWindow
*/
OBJ_CLASS_IMPLEMENTATION(OWinWindow, OObject, 0);

void OWinWindow::Create()
{
	Super::Create();
	mWnd = NULL;
}

OWinWindow* OWinWindow::GetWindowParent()
{
	if (!GetParent() || !GetParent()->IsA(OWinWindow::GetStaticClass()))
		return(NULL);
	return((OWinWindow*)GetParent());
}


/*
	OWinTreeViewItem
*/
OBJ_CLASS_IMPLEMENTATION(OWinTreeViewItem, OObject, 0);

void OWinTreeViewItem::Create()
{
	Super::Create();
	mItem = NULL;
	mImage = NULL;
	mOwnerTree = NULL;
}
void OWinTreeViewItem::Destroy()
{
    // have to manually wipe the children first in this case before i kill my item
	for (CObjIter i(this); i; i++)
		i->Destroy();
	
	OWinTreeView* tree = GetOwnerTree();
	if (tree && mItem)
		TreeView_DeleteItem(tree->mWnd, mItem);

	Super::Destroy();
}

NBool OWinTreeViewItem::Init(OWinTreeView* inTree, const NChar* inText, SWinImageListImage* inImage)
{
	TV_INSERTSTRUCT tvIns;
	HTREEITEM parentItem = TVI_ROOT;
	HTREEITEM afterItem = TVI_LAST; // TVI_SORT

	if (!inTree)
		return(0);
	if (!inText)
		inText = "";

	SetName(inText);
	mImage = inImage;
	mOwnerTree = inTree;
	if (GetItemParent())
		parentItem = GetItemParent()->mItem;
	tvIns.hParent = parentItem;
	tvIns.hInsertAfter = afterItem;
	tvIns.item.mask = TVIF_CHILDREN | TVIF_TEXT | TVIF_PARAM;
	if (inImage)
	{
		tvIns.item.mask |= TVIF_IMAGE | TVIF_SELECTEDIMAGE;
		tvIns.item.iImage = inImage->mIndex;
		tvIns.item.iSelectedImage = inImage->mIndex;
	}
	tvIns.item.cChildren = 0;
	tvIns.item.pszText = (NChar*)inText;
	tvIns.item.cchTextMax = strlen(inText)+1;
	tvIns.item.lParam = (LPARAM)this;
	mItem = TreeView_InsertItem(inTree->mWnd, &tvIns);
	if (!mItem)
		return(0);
	if (parentItem != TVI_ROOT)
	{
		tvIns.item.hItem = parentItem;
		tvIns.item.mask = TVIF_CHILDREN;
		TreeView_GetItem(inTree->mWnd, &tvIns.item);
		tvIns.item.cChildren++;
		tvIns.item.hItem = parentItem;
		tvIns.item.mask = TVIF_CHILDREN;
		TreeView_SetItem(inTree->mWnd, &tvIns.item);
	}
	return(1);
}

SWinImageListImage* OWinTreeViewItem::GetImage()
{
	return(mImage);
}
void OWinTreeViewItem::SetImage(SWinImageListImage* inImage)
{
	if (!inImage)
		return;
	OWinTreeView* tree = GetOwnerTree();
	if (!tree)
		return;
	TVITEM tvi;
	tvi.hItem = mItem;
	tvi.mask = TVIF_IMAGE | TVIF_SELECTEDIMAGE;
	tvi.iImage = inImage->mIndex;
	tvi.iSelectedImage = inImage->mIndex;
	TreeView_SetItem(tree->mWnd, &tvi);
}
const NChar* OWinTreeViewItem::GetText()
{
	return(GetName());
}
void OWinTreeViewItem::SetText(const NChar* inText)
{
	OWinTreeView* tree = GetOwnerTree();
	if (!tree)
		return;
	SetName(inText);
	TVITEM tvi;
	tvi.hItem = mItem;
	tvi.mask = TVIF_TEXT;
	tvi.pszText = (NChar*)GetName();
	tvi.cchTextMax = strlen(GetName())+1;
	TreeView_SetItem(tree->mWnd, &tvi);
}

HTREEITEM OWinTreeViewItem::GetHandle()
{
	return(mItem);
}	
OWinTreeView* OWinTreeViewItem::GetOwnerTree()
{
	return(mOwnerTree);
}
OWinTreeViewItem* OWinTreeViewItem::GetItemParent()
{
	if (GetParent() && GetParent()->IsA(OWinTreeViewItem::GetStaticClass()))
		return((OWinTreeViewItem*)GetParent());
	return(NULL);
}

/*
	OWinTreeView
*/
OBJ_CLASS_IMPLEMENTATION(OWinTreeView, OWinWindow, 0);

void OWinTreeView::Init(HWND inWnd, OWinImageList* inImageList)
{
	mWnd = inWnd;
	SetImageList(inImageList);
}
OWinImageList* OWinTreeView::GetImageList()
{
	return(mImageList);
}
void OWinTreeView::SetImageList(OWinImageList* inImageList)
{
	mImageList = inImageList;
	if (mImageList)
		TreeView_SetImageList(mWnd, mImageList->GetHandle(), TVSIL_NORMAL);
}
OWinTreeViewItem* OWinTreeView::GetHandleItem(HTREEITEM inHandle)
{
	TVITEM tvi;
	tvi.hItem = inHandle;
	tvi.mask = TVIF_PARAM;
	TreeView_GetItem(mWnd, &tvi);
	return((OWinTreeViewItem*)tvi.lParam);
}
OWinTreeViewItem* OWinTreeView::GetSelectedItem()
{
	HTREEITEM selItem = TreeView_GetSelection(mWnd);
	if (selItem)
		return(GetHandleItem(selItem));
	return(NULL);
}
OWinTreeViewItem* OWinTreeView::GetMouseItem()
{
	TVHITTESTINFO hti;
	GetCursorPos(&hti.pt);
	ScreenToClient(mWnd, &hti.pt);
	if (!TreeView_HitTest(mWnd, &hti))
		return(NULL);
	return(GetHandleItem(hti.hItem));
}

NBool OWinTreeView::OnCommand(WPARAM wParam, LPARAM lParam)
{
	switch(LOWORD(wParam))
	{
	case IDOK:
		{
			OWinTreeViewItem* item;
			if (item = GetSelectedItem())
				item->OnKeyDown(VK_RETURN);
			return(1);
		}
		break;
	case IDCANCEL:
		{
			OWinTreeViewItem* item;
			if (item = GetSelectedItem())
				item->OnKeyDown(VK_ESCAPE);
			return(1);
		}
		break;
	}
	OWinTreeViewItem* item = GetSelectedItem();
	if (item && (item->OnCommand(LOWORD(wParam))))
		return(1);
	return(0);
}
NBool OWinTreeView::OnNotify(NMHDR* inNotify)
{
	NMTREEVIEW* inNotifyTree = (NMTREEVIEW*)inNotify;

	switch(inNotify->code)
	{
	case NM_CLICK:
		{
			OWinTreeViewItem* item;
			if (item = GetMouseItem())
				item->OnClick();
			return(1);
		}
		break;
	case NM_DBLCLK:
		{
			OWinTreeViewItem* item;
			if (item = GetMouseItem())
				item->OnDblClick();
			return(1);
		}
		break;
	case NM_RCLICK:
		{
			OWinTreeViewItem* item;
			if (item = GetMouseItem())
			{
				TreeView_SelectItem(mWnd, item->GetHandle()); // since right-clicking looks like it changes selection but doesn't
				item->OnRightClick();
			}
			return(1);
		}
		break;
	case NM_RDBLCLK:
		{
			OWinTreeViewItem* item;
			if (item = GetMouseItem())
				item->OnRightDblClick();
			return(1);
		}
		break;	
	case TVN_ITEMEXPANDED:
		{
			OWinTreeViewItem* item = GetHandleItem(inNotifyTree->itemNew.hItem);
			if (item)
			{
				if (inNotifyTree->action == TVE_EXPAND)
					item->OnExpand();
				else if (inNotifyTree->action == TVE_COLLAPSE)
					item->OnCollapse();
			}
			return(1);
		}
		break;
	case TVN_KEYDOWN:
		{
			NMTVKEYDOWN* tvk = (NMTVKEYDOWN*)inNotify;
			OWinTreeViewItem* item;
			if (item = GetSelectedItem())
				item->OnKeyDown(tvk->wVKey);
			return(1);
		}
		break;
	/*
	case NM_RETURN:
		{ // why the heck is this a separate message? hello, microsoft? bueller?
			OWinTreeViewItem* item;
			if (item = GetSelectedItem())
				item->OnKeyDown(VK_RETURN);
			return(1);
		}
		break;
	*/
	/*
	case TVN_BEGINDRAG:
		{
			OWinTreeViewItem* item = GetHandleItem(inNotifyTree->itemNew.hItem);
			if (item)
			{
				LOG_Logf("BeginDrag on %s", item->GetName());
			}
			return(1);
		}
		break;
	*/
	default:
		break;
	}
	return(0);
}

//****************************************************************************
//**
//**    END MODULE WINCTRL.CPP
//**
//****************************************************************************

