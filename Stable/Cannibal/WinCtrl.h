#ifndef __WINCTRL_H__
#define __WINCTRL_H__
//****************************************************************************
//**
//**    WINCTRL.H
//**    Header - Win32 Common Controls
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#define KRNINC_WIN32
#include "Kernel.h"
#include "VecMain.h"
#include "ObjMain.h"
#include <commctrl.h>

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
/*
	OWinImageList
*/
struct SWinImageListImage
{
	NInt mIndex; // image list index
	NDword mResID; // resource id the image came from
};

class OWinImageList
: public OObject
{
protected:
	HIMAGELIST mList;
	TCorArray<SWinImageListImage> mImages;

	OBJ_CLASS_DEFINE(OWinImageList, OObject);

	// OObject
	void Create();
	void Destroy();

	HIMAGELIST GetHandle();
	NBool Init(NDword inImageWidth, NDword inImageHeight, NDword inInitialCount);
	SWinImageListImage* AddImage(NDword inResID);
	SWinImageListImage* FindImage(NDword inResID);
};

/*
	OWinWindow
*/
class OWinWindow
: public OObject
{
	OBJ_CLASS_DEFINE(OWinWindow, OObject);

	HWND mWnd;

	void Create();
	
	OWinWindow* GetWindowParent();
};

/*
	OWinTreeViewItem
*/
class OWinTreeView;

class OWinTreeViewItem
: public OObject
{
protected:
	HTREEITEM mItem;
	SWinImageListImage* mImage;
	OWinTreeView* mOwnerTree;

	OBJ_CLASS_DEFINE(OWinTreeViewItem, OObject);

	void Create();
	void Destroy();

	NBool Init(OWinTreeView* inTree, const NChar* inText, SWinImageListImage* inImage);
	virtual SWinImageListImage* GetImage();
	virtual void SetImage(SWinImageListImage* inImage);
	virtual const NChar* GetText();
	virtual void SetText(const NChar* inText);

	HTREEITEM GetHandle();
	OWinTreeView* GetOwnerTree();
	OWinTreeViewItem* GetItemParent();
	void DeleteAllChildren();

	virtual NBool OnCommand(NDword inCmdID) { return(0); }
	virtual void OnKeyDown(NDword inKey) {}
	virtual void OnClick() {}
	virtual void OnDblClick() {}
	virtual void OnRightClick() {}
	virtual void OnRightDblClick() {}
	virtual void OnExpand() {}
	virtual void OnCollapse() {}

	friend class OWinTreeView;
};

/*
	OWinTreeView
*/
class OWinTreeView
: public OWinWindow
{
	OWinImageList* mImageList;

	OBJ_CLASS_DEFINE(OWinTreeView, OWinWindow);

	void Init(HWND inWnd, OWinImageList* inImageList);
	OWinImageList* GetImageList();
	void SetImageList(OWinImageList* inImageList);
	OWinTreeViewItem* GetHandleItem(HTREEITEM inHandle);
	OWinTreeViewItem* GetSelectedItem();
	OWinTreeViewItem* GetMouseItem();

	virtual NBool OnCommand(WPARAM wParam, LPARAM lParam);
	virtual NBool OnNotify(NMHDR* inNotify);
};

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
KRN_API NChar* WIN_InputBox(const NChar* inCaption, const NChar* inDefInput, NChar* inFmt, ... );
KRN_API NChar* WIN_SelectionBox(const NChar* inCaption, const NChar* inChoices, NChar* inFmt, ... );
KRN_API NBool WIN_SelectionBoxMulti(const NChar* inCaption, const NChar* inChoices, NChar* inFmt, ... );
KRN_API NChar* WIN_SelectionBoxMultiGet();
KRN_API VVec3 WIN_VectorBox(const NChar* inCaption, const VVec3& inDefInput,
							const NChar* inX, const NChar* inY, const NChar* inZ);

//============================================================================
//    INLINE CLASS METHODS
//============================================================================
//============================================================================
//    TRAILING HEADERS
//============================================================================

//****************************************************************************
//**
//**    END HEADER WINCTRL.H
//**
//****************************************************************************
#endif // __WINCTRL_H__
