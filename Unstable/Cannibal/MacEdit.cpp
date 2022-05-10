//****************************************************************************
//**
//**    MACEDIT.CPP
//**    Model Actor Editor
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#define KRNINC_WIN32
#include "Kernel.h"
#include "ObjMain.h"
#include "CpjMain.h"
#include "MacMain.h"
#include "WinCtrl.h"
#include "MacEdit.h"
#include "FileMain.h"
#include "IpcMain.h"

#define CPJVECTOR VVec3
#define CPJQUAT VQuat3
#pragma pack(push,1)
#include "CpjFmt.h"
#pragma pack(pop)

#include <direct.h>

#include "Res\resource.h"

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
/*
	OMacBrowserTree
*/
class OMacBrowserTree
: public OWinTreeView
{
	OBJ_CLASS_DEFINE(OMacBrowserTree, OWinTreeView);

	NBool OnNotify(NMHDR* inNotify)
	{
		if (Super::OnNotify(inNotify))
			return(1);

		return(0);
	}

	NBool SelectChunkItem(OCpjChunk* inItem, OWinTreeViewItem* inBaseTreeItem);
};
OBJ_CLASS_IMPLEMENTATION(OMacBrowserTree, OWinTreeView, 0);

/*
	OMacBrowserDialog
*/
class OMacBrowserDialog
: public OWinWindow
{
	OBJ_CLASS_DEFINE(OMacBrowserDialog, OWinWindow);

	OMacBrowserTree* mTree;
	OWinImageList *mImageList;
	OMacActor* mActor;
	OCpjConfig* mCurrentConfig;
	NDword mIpcHook;
	CCorString mTitleText;

	static BOOL CALLBACK StaticDialogProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam);
	NBool DialogProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam);
	
	void Create();
	void Destroy();
	
	void ActorRefresh();
	void BrowserRefresh();
	
	NBool Launch(NDword inIpcHook);
};
OBJ_CLASS_IMPLEMENTATION(OMacBrowserDialog, OWinWindow, 0);

/*
	OMacDetailsDialog
*/
class OMacDetailsDialog
: public OWinWindow
{
	OBJ_CLASS_DEFINE(OMacDetailsDialog, OWinWindow);

	OCpjChunk* mChunk;
	OMacBrowserDialog* mOwnerDialog;

	void Create()
	{
		Super::Create();
		mChunk = NULL;
	}

	virtual NDword GetDialogID()
	{
		return(0);
	}
	virtual NBool DialogProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
	{
		switch(msg)
		{		
		case WM_INITDIALOG:
			return(1);
			break;
		case WM_CLOSE:
			EndDialog(hWnd, 0);
			break;
		case WM_COMMAND:
			if (LOWORD(wParam)==IDCANCEL)
				EndDialog(hWnd, 0);
			break;
		}
		return(0);
	}
	
	static BOOL CALLBACK StaticDialogProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
	{
		OMacDetailsDialog* This = (OMacDetailsDialog*)GetWindowLong(hWnd, GWL_USERDATA);
		if (msg == WM_INITDIALOG)
		{			
			This = (OMacDetailsDialog*)lParam;
			This->mWnd = hWnd;

			SetWindowLong(hWnd, GWL_USERDATA, (LONG)This);
			/*
			RECT rect;
			GetWindowRect(hWnd, &rect);
			SetWindowPos(hWnd, HWND_TOP,
				(GetSystemMetrics(SM_CXSCREEN)-(rect.right-rect.left))/2,
				(GetSystemMetrics(SM_CYSCREEN)-(rect.bottom-rect.top))/2,
				rect.right-rect.left, rect.bottom-rect.top, SWP_SHOWWINDOW);
			*/
		}
		if (This)
			return(This->DialogProc(hWnd, msg, wParam, lParam));
		return(0);
	}
	NBool Launch(OMacBrowserDialog* inOwnerDialog, OCpjChunk* inChunk)
	{
		if (!GetDialogID() || !inOwnerDialog || !inChunk)
			return(0);
		mChunk = inChunk;
		mOwnerDialog = inOwnerDialog;
		NInt result = DialogBoxParam((HINSTANCE)KRN_GetModuleHandle(), MAKEINTRESOURCE(GetDialogID()), mOwnerDialog->mWnd, (DLGPROC)StaticDialogProc, (LPARAM)this);
		if (result == -1)
			return(0);
		return(1);
	}
};
OBJ_CLASS_IMPLEMENTATION(OMacDetailsDialog, OWinWindow, 0);

/*
	OMacBrowserItem
*/
class OMacBrowserItem
: public OWinTreeViewItem
{
	OBJ_CLASS_DEFINE(OMacBrowserItem, OWinTreeViewItem);

	OMacBrowserDialog* GetOwnerDialog();
};
OBJ_CLASS_IMPLEMENTATION(OMacBrowserItem, OWinTreeViewItem, 0);

/*
	OMacBrowserChunkItem
*/
class OMacBrowserChunkItem
: public OMacBrowserItem
{
protected:	
	OCpjChunk* mChunk;

	OBJ_CLASS_DEFINE(OMacBrowserChunkItem, OMacBrowserItem);

	virtual NDword GetImageResID() { return(0); }
	virtual const NChar* GetLabel() { return(NULL); }
	virtual NDword GetPopupIndex() { return(0); }
	virtual CObjClass* GetChunkClass() { return(NULL); }
	virtual CObjClass* GetDetailsClass() { return(NULL); }

	OCpjChunk* GetChunk() { return(mChunk); }
	void SetChunk(OCpjChunk* inChunk)
	{
		mChunk = inChunk;
		RefreshTree();
	}

	void RefreshTree();

	void OnDblClick();
	void OnRightClick();
	NBool OnCommand(NDword inCmdID);
	void OnKeyDown(NDword inKey);
};
OBJ_CLASS_IMPLEMENTATION(OMacBrowserChunkItem, OMacBrowserItem, 0);

/*
	OMacBrowserSequenceItem
*/
class OMacSequenceDetails
: public OMacDetailsDialog
{
	OBJ_CLASS_DEFINE(OMacSequenceDetails, OMacDetailsDialog);
	
	NDword mCurEvent;

	NDword GetDialogID() { return(IDD_MAC_PR_SEQ); }

	void UpdateCurEvent()
	{		
		char buf[256];
		OCpjSequence* seq = (OCpjSequence*)mChunk;
		if (mCurEvent >= seq->m_Events.GetCount())
		{
			SetDlgItemText(mWnd, IDC_EB_MAC_PR_SEQ_CUREVENT, "0");
			SetDlgItemText(mWnd, IDC_EB_MAC_PR_SEQ_EVENTTIME, "");
			SetDlgItemText(mWnd, IDC_EB_MAC_PR_SEQ_EVENTSTRING, "");
			SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SEQ_EVENTTYPE, CB_SETCURSEL, 0, 0);
			return;
		}
		sprintf(buf, "%d", mCurEvent+1); SetDlgItemText(mWnd, IDC_EB_MAC_PR_SEQ_CUREVENT, buf);
		sprintf(buf, "%.3f", seq->m_Events[mCurEvent].time * seq->m_Frames.GetCount());
		SetDlgItemText(mWnd, IDC_EB_MAC_PR_SEQ_EVENTTIME, buf);
		SetDlgItemText(mWnd, IDC_EB_MAC_PR_SEQ_EVENTSTRING, *seq->m_Events[mCurEvent].paramString);
		NDword typeItem = 0;
		if (seq->m_Events[mCurEvent].eventType == SEQEV_MARKER)
			typeItem = 1;
		else if (seq->m_Events[mCurEvent].eventType == SEQEV_TRIGGER)
			typeItem = 2;
		else if (seq->m_Events[mCurEvent].eventType == SEQEV_ACTORCMD)
			typeItem = 3;
		else if (seq->m_Events[mCurEvent].eventType == SEQEV_TRIFLAGS)
			typeItem = 4;
		SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SEQ_EVENTTYPE, CB_SETCURSEL, typeItem, 0);
	}

	NBool DialogProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
	{
		switch(msg)
		{
		case WM_INITDIALOG:
			{
				char buf[256];

				OCpjSequence* seq = (OCpjSequence*)mChunk;
				seq->CacheIn();
				sprintf(buf, "%d", seq->m_Frames.GetCount()); SetDlgItemText(mWnd, IDC_EB_MAC_PR_SEQ_NUMFRAMES, buf);
				sprintf(buf, "%d", seq->m_BoneInfo.GetCount()); SetDlgItemText(mWnd, IDC_EB_MAC_PR_SEQ_NUMBONES, buf);
				sprintf(buf, "%f", seq->m_Rate); SetDlgItemText(mWnd, IDC_EB_MAC_PR_SEQ_PLAYRATE, buf);
				for (NDword i=0;i<seq->m_BoneInfo.GetCount();i++)
					SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SEQ_BONES, CB_ADDSTRING, 0, (LPARAM)*seq->m_BoneInfo[i].name);
				SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SEQ_BONES, CB_SETCURSEL, 0, 0);

				SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SEQ_EVENTTYPE, CB_ADDSTRING, 0, (LPARAM)"Unknown");
				SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SEQ_EVENTTYPE, CB_ADDSTRING, 0, (LPARAM)"Marker");
				SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SEQ_EVENTTYPE, CB_ADDSTRING, 0, (LPARAM)"Trigger");
				SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SEQ_EVENTTYPE, CB_ADDSTRING, 0, (LPARAM)"Command");
				SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SEQ_EVENTTYPE, CB_ADDSTRING, 0, (LPARAM)"Triflags");
				SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SEQ_EVENTTYPE, CB_SETCURSEL, 0, 0);
				sprintf(buf, "%d", seq->m_Events.GetCount()); SetDlgItemText(mWnd, IDC_EB_MAC_PR_SEQ_NUMEVENTS, buf);
				mCurEvent = 0;
				UpdateCurEvent();

				return(1);
			}
			break;
		case WM_COMMAND:
			switch(LOWORD(wParam))
			{
			case IDC_BT_MAC_PR_SEQ_PLAYRATE:
				{
					OCpjSequence* seq = (OCpjSequence*)mChunk;
					char buf[256];
					sprintf(buf, "%f", seq->m_Rate);
					NChar* rate;
					if (!(rate = WIN_InputBox("Sequence Rate", buf, "Please enter the new rate in frames per second:")))
						break;
					seq->m_Rate = (NFloat)atof(rate);
					sprintf(buf, "%f", seq->m_Rate); SetDlgItemText(mWnd, IDC_EB_MAC_PR_SEQ_PLAYRATE, buf);
				}
				break;
			case IDC_BT_MAC_PR_SEQ_EVENTNEXT:
				{
					OCpjSequence* seq = (OCpjSequence*)mChunk;
					if (seq->m_Events.GetCount() && (mCurEvent < (seq->m_Events.GetCount() - 1)))
					{
						mCurEvent++;
						UpdateCurEvent();
					}
				}
				break;
			case IDC_BT_MAC_PR_SEQ_EVENTPREV:
				{
					OCpjSequence* seq = (OCpjSequence*)mChunk;
					if (mCurEvent > 0)
					{
						mCurEvent--;
						UpdateCurEvent();
					}
				}
				break;
			case IDC_BT_MAC_PR_SEQ_EVENTADD:
				{
					OCpjSequence* seq = (OCpjSequence*)mChunk;
					mCurEvent = seq->m_Events.Add();					
					UpdateCurEvent();
					char buf[256];
					sprintf(buf, "%d", seq->m_Events.GetCount()); SetDlgItemText(mWnd, IDC_EB_MAC_PR_SEQ_NUMEVENTS, buf);
				}
				break;
			case IDC_BT_MAC_PR_SEQ_EVENTDELETE:
				{
					OCpjSequence* seq = (OCpjSequence*)mChunk;

					if (mCurEvent < seq->m_Events.GetCount())
						seq->m_Events.Remove(mCurEvent);
					if (mCurEvent >= seq->m_Events.GetCount())
						mCurEvent = seq->m_Events.GetCount()-1;
					if (!seq->m_Events.GetCount())
						mCurEvent = 0;
					UpdateCurEvent();
					char buf[256];
					sprintf(buf, "%d", seq->m_Events.GetCount()); SetDlgItemText(mWnd, IDC_EB_MAC_PR_SEQ_NUMEVENTS, buf);
				}
				break;
			case IDC_BT_MAC_PR_SEQ_BONEREMOVE:
				{
					OCpjSequence* seq = (OCpjSequence*)mChunk;
					NInt selIndex = SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SEQ_BONES, CB_GETCURSEL, 0, 0);
					if (selIndex == CB_ERR)
						break;
					if ((selIndex < 0) || (selIndex >= (NInt)seq->m_BoneInfo.GetCount()))
						break;

					CCorString desc("Are you sure you want to remove all references to \""); desc += seq->m_BoneInfo[selIndex].name; desc += "\"?";
					if (MessageBox(mWnd, *desc, "Remove Bone References", MB_YESNO)!=IDYES)
						break;

					// remove this boneinfo item
					seq->m_BoneInfo.Remove(selIndex);

					// run through all frames and remove all elements that refer to this bone
					for (NDword i=0;i<seq->m_Frames.GetCount();i++)
					{
						CCpjSeqFrame* frame = &seq->m_Frames[i];
						for (NDword j=0;j<frame->rotates.GetCount();j++)
						{
							CCpjSeqRotate* r = &frame->rotates[j];
							if (r->boneIndex == (NDword)selIndex)
							{
								frame->rotates.Remove(j--);
								continue;
							}
							if (r->boneIndex > (NDword)selIndex)
								r->boneIndex--;
						}
						for (j=0;j<frame->translates.GetCount();j++)
						{
							CCpjSeqTranslate* t = &frame->translates[j];
							if (t->boneIndex == (NDword)selIndex)
							{
								frame->translates.Remove(j--);
								continue;
							}
							if (t->boneIndex > (NDword)selIndex)
								t->boneIndex--;
						}
						for (j=0;j<frame->scales.GetCount();j++)
						{
							CCpjSeqScale* s = &frame->scales[j];
							if (s->boneIndex == (NDword)selIndex)
							{
								frame->scales.Remove(j--);
								continue;
							}
							if (s->boneIndex > (NDword)selIndex)
								s->boneIndex--;
						}
					}

					// update listed bone info
					char buf[256];
					sprintf(buf, "%d", seq->m_BoneInfo.GetCount()); SetDlgItemText(mWnd, IDC_EB_MAC_PR_SEQ_NUMBONES, buf);
					SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SEQ_BONES, CB_RESETCONTENT, 0, 0);
					for (i=0;i<seq->m_BoneInfo.GetCount();i++)
						SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SEQ_BONES, CB_ADDSTRING, 0, (LPARAM)*seq->m_BoneInfo[i].name);
					SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SEQ_BONES, CB_SETCURSEL, 0, 0);
				}
				break;
			case IDC_CB_MAC_PR_SEQ_EVENTTYPE:
				{
					switch(HIWORD(wParam))
					{
					case CBN_SELCHANGE:
						{
							OCpjSequence* seq = (OCpjSequence*)mChunk;
							if (mCurEvent >= seq->m_Events.GetCount())
								break;
							NInt selIndex = SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SEQ_EVENTTYPE, CB_GETCURSEL, 0, 0);
							if (selIndex == CB_ERR)
								break;
							switch(selIndex)
							{
							case 1: seq->m_Events[mCurEvent].eventType = SEQEV_MARKER; break;
							case 2: seq->m_Events[mCurEvent].eventType = SEQEV_TRIGGER; break;
							case 3: seq->m_Events[mCurEvent].eventType = SEQEV_ACTORCMD; break;
							case 4: seq->m_Events[mCurEvent].eventType = SEQEV_TRIFLAGS; break;
							default: seq->m_Events[mCurEvent].eventType = 0;
							}
							UpdateCurEvent();
						}
						break;
					}
				}
				break;
			case IDC_EB_MAC_PR_SEQ_EVENTTIME:
				{
					switch(HIWORD(wParam))
					{
					case EN_CHANGE:
						{
							OCpjSequence* seq = (OCpjSequence*)mChunk;
							if (mCurEvent >= seq->m_Events.GetCount())
								break;
							char buf[256];
							GetDlgItemText(mWnd, IDC_EB_MAC_PR_SEQ_EVENTTIME, buf, 255);
							seq->m_Events[mCurEvent].time = (NFloat)atof(buf) / seq->m_Frames.GetCount();
						}
						break;
					}
				}
				break;
			case IDC_EB_MAC_PR_SEQ_EVENTSTRING:
				{
					switch(HIWORD(wParam))
					{
					case EN_CHANGE:
						{
							OCpjSequence* seq = (OCpjSequence*)mChunk;
							if (mCurEvent >= seq->m_Events.GetCount())
								break;
							char buf[4096];
							GetDlgItemText(mWnd, IDC_EB_MAC_PR_SEQ_EVENTSTRING, buf, 4096);
							seq->m_Events[mCurEvent].paramString = buf;
						}
						break;
					}
				}
				break;
			}
			break;
		}
		return(Super::DialogProc(hWnd, msg, wParam, lParam));
	}
};
OBJ_CLASS_IMPLEMENTATION(OMacSequenceDetails, OMacDetailsDialog, 0);

class OMacBrowserSequenceItem
: public OMacBrowserChunkItem
{
	OBJ_CLASS_DEFINE(OMacBrowserSequenceItem, OMacBrowserChunkItem);

	NDword GetImageResID() { return(IDB_CPJ_SEQ); }
	const NChar* GetLabel() { return("Sequence"); }
	CObjClass* GetChunkClass() { return(OCpjSequence::GetStaticClass()); }
	NDword GetPopupIndex() { return(8); }
	CObjClass* GetDetailsClass() { return(OMacSequenceDetails::GetStaticClass()); }
};
OBJ_CLASS_IMPLEMENTATION(OMacBrowserSequenceItem, OMacBrowserChunkItem, 0);

/*
	OMacBrowserFramesItem
*/
class OMacFramesDetails
: public OMacDetailsDialog
{
	OBJ_CLASS_DEFINE(OMacFramesDetails, OMacDetailsDialog);
	
	NDword GetDialogID() { return(IDD_MAC_PR_FRM); }

	NBool DialogProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
	{
		switch(msg)
		{
		case WM_INITDIALOG:
			{
				char buf[256];

				if (!mOwnerDialog || !mOwnerDialog->mActor || !mOwnerDialog->mActor->mGeometry)
					EnableWindow(GetDlgItem(mWnd, IDC_CK_MAC_PR_FRM_FRAMECOMPRESSED), 0); // disable compress/decompress box if we can't recompress

				OCpjFrames* frm = (OCpjFrames*)mChunk;
				frm->CacheIn();
				sprintf(buf, "%d", frm->m_Frames.GetCount()); SetDlgItemText(mWnd, IDC_EB_MAC_PR_FRM_NUMFRAMES, buf);				
				for (NDword i=0;i<frm->m_Frames.GetCount();i++)
					SendDlgItemMessage(mWnd, IDC_LB_MAC_PR_FRM_FRAMES, LB_ADDSTRING, 0, (LPARAM)*frm->m_Frames[i].m_Name);
				SendDlgItemMessage(mWnd, IDC_LB_MAC_PR_FRM_FRAMES, LB_SETCURSEL, 0, 0);
				if (frm->m_Frames.GetCount())
				{
					sprintf(buf, "%d", frm->m_Frames[0].GetNumPositions());
					SetDlgItemText(mWnd, IDC_EB_MAC_PR_FRM_FRAMENUMVERTS, buf);
					SendDlgItemMessage(mWnd, IDC_CK_MAC_PR_FRM_FRAMECOMPRESSED, BM_SETCHECK, frm->m_Frames[0].m_isCompressed ? BST_CHECKED : BST_UNCHECKED, 0);
				}
				
				return(1);
			}
			break;
		case WM_COMMAND:
			switch(LOWORD(wParam))
			{
			case IDC_LB_MAC_PR_FRM_FRAMES:
				{
					switch(HIWORD(wParam))
					{
					case LBN_SELCHANGE:
						{
							char buf[256];
							OCpjFrames* frm = (OCpjFrames*)mChunk;
							NInt selIndex = SendDlgItemMessage(mWnd, IDC_LB_MAC_PR_FRM_FRAMES, LB_GETCURSEL, 0, 0);
							if (selIndex == LB_ERR)
								break;
							sprintf(buf, "%d", frm->m_Frames[selIndex].GetNumPositions());
							SetDlgItemText(mWnd, IDC_EB_MAC_PR_FRM_FRAMENUMVERTS, buf);
							SendDlgItemMessage(mWnd, IDC_CK_MAC_PR_FRM_FRAMECOMPRESSED, BM_SETCHECK, frm->m_Frames[selIndex].m_isCompressed ? BST_CHECKED : BST_UNCHECKED, 0);
						}
						break;
					}
				}
				break;
			case IDC_CK_MAC_PR_FRM_FRAMECOMPRESSED:
				{
					switch(HIWORD(wParam))
					{
					case BN_CLICKED:
						{
							OCpjFrames* frm = (OCpjFrames*)mChunk;
							NInt selIndex = SendDlgItemMessage(mWnd, IDC_LB_MAC_PR_FRM_FRAMES, LB_GETCURSEL, 0, 0);
							if (selIndex == LB_ERR)
								break;
							NBool isChecked = 0;
							if (SendDlgItemMessage(mWnd, IDC_CK_MAC_PR_FRM_FRAMECOMPRESSED, BM_GETCHECK, 0, 0) == BST_CHECKED)
								isChecked = 1;
							if (frm->m_Frames[selIndex].m_isCompressed && !isChecked)
								frm->m_Frames[selIndex].Decompress();
							else if (!frm->m_Frames[selIndex].m_isCompressed && isChecked)
							{
								if (mOwnerDialog->mActor && mOwnerDialog->mActor->mGeometry)
									frm->m_Frames[selIndex].Compress(mOwnerDialog->mActor->mGeometry);
							}
						}
						break;
					}
				}
				break;
			}
		}
		return(Super::DialogProc(hWnd, msg, wParam, lParam));
	}
};
OBJ_CLASS_IMPLEMENTATION(OMacFramesDetails, OMacDetailsDialog, 0);

class OMacBrowserFramesItem
: public OMacBrowserChunkItem
{
	OBJ_CLASS_DEFINE(OMacBrowserFramesItem, OMacBrowserChunkItem);

	NDword GetImageResID() { return(IDB_CPJ_FRM); }
	const NChar* GetLabel() { return("Frames"); }
	CObjClass* GetChunkClass() { return(OCpjFrames::GetStaticClass()); }
	NDword GetPopupIndex() { return(8); }
	CObjClass* GetDetailsClass() { return(OMacFramesDetails::GetStaticClass()); }
};
OBJ_CLASS_IMPLEMENTATION(OMacBrowserFramesItem, OMacBrowserChunkItem, 0);

/*
	OMacBrowserSkeletonItem
*/
class OMacSkeletonDetails
: public OMacDetailsDialog
{
	OBJ_CLASS_DEFINE(OMacSkeletonDetails, OMacDetailsDialog);
	
	NDword GetDialogID() { return(IDD_MAC_PR_SKL); }

	NBool DialogProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
	{
		switch(msg)
		{
		case WM_INITDIALOG:
			{
				char buf[256];

				OCpjSkeleton* skl = (OCpjSkeleton*)mChunk;
				skl->CacheIn();
				sprintf(buf, "%d", skl->m_Verts.GetCount()); SetDlgItemText(mWnd, IDC_EB_MAC_PR_SKL_NUMVERTS, buf);
				NDword weightCount = 0;
				for (NDword i=0;i<skl->m_Verts.GetCount();i++)
					weightCount += skl->m_Verts[i].weights.GetCount();
				sprintf(buf, "%d", weightCount); SetDlgItemText(mWnd, IDC_EB_MAC_PR_SKL_NUMWEIGHTS, buf);
				
				sprintf(buf, "%d", skl->m_Bones.GetCount()); SetDlgItemText(mWnd, IDC_EB_MAC_PR_SKL_NUMBONES, buf);
				for (i=0;i<skl->m_Bones.GetCount();i++)
					SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SKL_BONES, CB_ADDSTRING, 0, (LPARAM)*skl->m_Bones[i].name);
				SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SKL_BONES, CB_SETCURSEL, 0, 0);
				if (skl->m_Bones.GetCount())
				{
					sprintf(buf, "%f", skl->m_Bones[0].length);
					SetDlgItemText(mWnd, IDC_EB_MAC_PR_SKL_BONELENGTH, buf);
					SetDlgItemText(mWnd, IDC_EB_MAC_PR_SKL_BONEPARENT, skl->m_Bones[0].parentBone ? *skl->m_Bones[0].parentBone->name : "(None)");
				}
				
				sprintf(buf, "%d", skl->m_Mounts.GetCount()); SetDlgItemText(mWnd, IDC_EB_MAC_PR_SKL_NUMMOUNTS, buf);
				for (i=0;i<skl->m_Mounts.GetCount();i++)
					SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SKL_MOUNTS, CB_ADDSTRING, 0, (LPARAM)*skl->m_Mounts[i].name);
				SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SKL_MOUNTS, CB_SETCURSEL, 0, 0);
				
				return(1);
			}
			break;
		case WM_COMMAND:
			switch(LOWORD(wParam))
			{
			case IDC_BT_MAC_PR_SKL_MOUNTRENAME:
				{
					OCpjSkeleton* skl = (OCpjSkeleton*)mChunk;

					NInt selIndex = SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SKL_MOUNTS, CB_GETCURSEL, 0, 0);
					if (selIndex == CB_ERR)
						break;
					NChar* name;
					if (name = WIN_InputBox("Rename Mount Point", *skl->m_Mounts[selIndex].name, "Please enter the new name:"))
					{
						skl->m_Mounts[selIndex].name = name;
						SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SKL_MOUNTS, CB_RESETCONTENT, 0, 0);
						for (NDword i=0;i<skl->m_Mounts.GetCount();i++)
							SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SKL_MOUNTS, CB_ADDSTRING, 0, (LPARAM)*skl->m_Mounts[i].name);
						SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SKL_MOUNTS, CB_SETCURSEL, selIndex, 0);
					}
				}
				break;
			case IDC_BT_MAC_PR_SKL_BONERENAME:
				{
					OCpjSkeleton* skl = (OCpjSkeleton*)mChunk;

					NInt selIndex = SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SKL_BONES, CB_GETCURSEL, 0, 0);
					if (selIndex == CB_ERR)
						break;
					NChar* name;
					if (name = WIN_InputBox("Rename Bone", *skl->m_Bones[selIndex].name, "Please enter the new name:"))
					{
						skl->m_Bones[selIndex].name = name;
						skl->m_Bones[selIndex].nameHash = STR_CalcHash(name);
						SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SKL_BONES, CB_RESETCONTENT, 0, 0);
						for (NDword i=0;i<skl->m_Bones.GetCount();i++)
							SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SKL_BONES, CB_ADDSTRING, 0, (LPARAM)*skl->m_Bones[i].name);
						SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SKL_BONES, CB_SETCURSEL, selIndex, 0);
					}
				}
				break;
			case IDC_CB_MAC_PR_SKL_BONES:
				{
					switch(HIWORD(wParam))
					{
					case CBN_SELCHANGE:
						{
							OCpjSkeleton* skl = (OCpjSkeleton*)mChunk;
							NInt selIndex = SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SKL_BONES, CB_GETCURSEL, 0, 0);
							if (selIndex == CB_ERR)
								break;
							char buf[256];
							sprintf(buf, "%f", skl->m_Bones[selIndex].length);
							SetDlgItemText(mWnd, IDC_EB_MAC_PR_SKL_BONELENGTH, buf);
							SetDlgItemText(mWnd, IDC_EB_MAC_PR_SKL_BONEPARENT, skl->m_Bones[selIndex].parentBone ? *skl->m_Bones[selIndex].parentBone->name : "(None)");							
						}
						break;
					}
				}
				break;
			case IDC_EB_MAC_PR_SKL_BONELENGTH:
				{
					switch(HIWORD(wParam))
					{
					case EN_CHANGE:
						{
							OCpjSkeleton* skl = (OCpjSkeleton*)mChunk;
							NInt selIndex = SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SKL_BONES, CB_GETCURSEL, 0, 0);
							if (selIndex == CB_ERR)
								break;
							char buf[256];
							GetDlgItemText(mWnd, IDC_EB_MAC_PR_SKL_BONELENGTH, buf, 255);
							skl->m_Bones[selIndex].length = (NFloat)atof(buf);
						}
						break;
					}
				}
				break;
			}
			break;
		}
		return(Super::DialogProc(hWnd, msg, wParam, lParam));
	}
};
OBJ_CLASS_IMPLEMENTATION(OMacSkeletonDetails, OMacDetailsDialog, 0);

class OMacBrowserSkeletonItem
: public OMacBrowserChunkItem
{
	OBJ_CLASS_DEFINE(OMacBrowserSkeletonItem, OMacBrowserChunkItem);

	NDword GetImageResID() { return(IDB_CPJ_SKL); }
	const NChar* GetLabel() { return("Skeleton"); }
	CObjClass* GetChunkClass() { return(OCpjSkeleton::GetStaticClass()); }
	NDword GetPopupIndex() { return(7); }
	CObjClass* GetDetailsClass() { return(OMacSkeletonDetails::GetStaticClass()); }

	NBool OnCommand(NDword inCmdID)
	{
		switch(inCmdID)
		{
		case ID_MAC_SKELETON_USE:
			{
				if (!GetChunk())
					break;
				if (GetOwnerDialog() && GetOwnerDialog()->mActor)
				{
					GetOwnerDialog()->mActor->SetSkeleton((OCpjSkeleton*)GetChunk());
					GetOwnerDialog()->ActorRefresh();
				}
			}
			break;
		}
		return(Super::OnCommand(inCmdID));
	}
};
OBJ_CLASS_IMPLEMENTATION(OMacBrowserSkeletonItem, OMacBrowserChunkItem, 0);

/*
	OMacBrowserLodDataItem
*/
class OMacLodDataDetails
: public OMacDetailsDialog
{
	OBJ_CLASS_DEFINE(OMacLodDataDetails, OMacDetailsDialog);
	
	NDword GetDialogID() { return(IDD_MAC_PR_LOD); }

	NBool DialogProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
	{
		switch(msg)
		{
		case WM_INITDIALOG:
			{
				if (!mOwnerDialog || !mOwnerDialog->mActor || !mOwnerDialog->mActor->mGeometry
				 || !mOwnerDialog->mActor->mSurfaces.GetCount() || !mOwnerDialog->mActor->mSurfaces[0])
					EnableWindow(GetDlgItem(mWnd, IDC_BT_MAC_PR_LOD_GENERATE), 0); // disable regeneration without valid working config

				return(1);
			}
			break;
		case WM_COMMAND:
			switch(LOWORD(wParam))
			{
			case IDC_BT_MAC_PR_LOD_GENERATE:
				{
					if (!mOwnerDialog->mActor)
						break;
					OCpjLodData* lod = (OCpjLodData*)mChunk;
					lod->CacheIn();
					OCpjGeometry* geo = mOwnerDialog->mActor->mGeometry;
					if (geo) geo->CacheIn();
					OCpjSurface* srf = NULL;
					if (mOwnerDialog->mActor->mSurfaces.GetCount())
						srf = mOwnerDialog->mActor->mSurfaces[0];
					if (srf) srf->CacheIn();

					if (!lod->Generate(geo, srf))
						MessageBox(mWnd, "LOD generation failure", "LOD Data", MB_OK);
					else
						MessageBox(mWnd, "LOD generated successfully", "LOD Data", MB_OK);
				}
				break;
			}
		}
		return(Super::DialogProc(hWnd, msg, wParam, lParam));
	}
};
OBJ_CLASS_IMPLEMENTATION(OMacLodDataDetails, OMacDetailsDialog, 0);

class OMacBrowserLodDataItem
: public OMacBrowserChunkItem
{
	OBJ_CLASS_DEFINE(OMacBrowserLodDataItem, OMacBrowserChunkItem);

	NDword GetImageResID() { return(IDB_CPJ_LOD); }
	const NChar* GetLabel() { return("LOD Data"); }
	CObjClass* GetChunkClass() { return(OCpjLodData::GetStaticClass()); }
	NDword GetPopupIndex() { return(6); }
	CObjClass* GetDetailsClass() { return(OMacLodDataDetails::GetStaticClass()); }

	NBool OnCommand(NDword inCmdID)
	{
		switch(inCmdID)
		{
		case ID_MAC_LODDATA_USE:
			{
				if (!GetChunk())
					break;
				if (GetOwnerDialog() && GetOwnerDialog()->mActor)
				{
					GetOwnerDialog()->mActor->SetLodData((OCpjLodData*)GetChunk());
					GetOwnerDialog()->ActorRefresh();
				}
			}
			break;
		}
		return(Super::OnCommand(inCmdID));
	}
};
OBJ_CLASS_IMPLEMENTATION(OMacBrowserLodDataItem, OMacBrowserChunkItem, 0);

/*
	OMacBrowserSurfaceItem
*/
class OMacSurfaceDetails
: public OMacDetailsDialog
{
	OBJ_CLASS_DEFINE(OMacSurfaceDetails, OMacDetailsDialog);
	
	NDword GetDialogID() { return(IDD_MAC_PR_SRF); }

	NBool DialogProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
	{
		switch(msg)
		{
		case WM_INITDIALOG:
			{
				char buf[256];

				if (!mOwnerDialog || !mOwnerDialog->mIpcHook)
					EnableWindow(GetDlgItem(mWnd, IDC_BT_MAC_PR_SRF_TEXTUREOBJUSE), 0);

				OCpjSurface* srf = (OCpjSurface*)mChunk;
				srf->CacheIn();
				sprintf(buf, "%d", srf->m_Tris.GetCount()); SetDlgItemText(mWnd, IDC_EB_MAC_PR_SRF_NUMTRIS, buf);
				sprintf(buf, "%d", srf->m_UV.GetCount()); SetDlgItemText(mWnd, IDC_EB_MAC_PR_SRF_NUMUV, buf);
				sprintf(buf, "%d", srf->m_Textures.GetCount()); SetDlgItemText(mWnd, IDC_EB_MAC_PR_SRF_NUMTEXTURES, buf);
				
				for (NDword i=0;i<srf->m_Textures.GetCount();i++)
					SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SRF_TEXTURES, CB_ADDSTRING, 0, (LPARAM)srf->m_Textures[i].name);
				SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SRF_TEXTURES, CB_SETCURSEL, 0, 0);
				if (srf->m_Textures.GetCount())
					SetDlgItemText(mWnd, IDC_EB_MAC_PR_SRF_TEXTUREOBJ, srf->m_Textures[0].refName);
				
				return(1);
			}
			break;
		case WM_COMMAND:
			switch(LOWORD(wParam))
			{
			case IDC_BT_MAC_PR_SRF_TEXTURERENAME:
				{
					OCpjSurface* srf = (OCpjSurface*)mChunk;

					NInt selIndex = SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SRF_TEXTURES, CB_GETCURSEL, 0, 0);
					if (selIndex == CB_ERR)
						break;
					NChar* name;
					if (name = WIN_InputBox("Rename Texture", srf->m_Textures[selIndex].name, "Please enter the new name:"))
					{
						strcpy(srf->m_Textures[selIndex].name, name);
						SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SRF_TEXTURES, CB_RESETCONTENT, 0, 0);
						for (NDword i=0;i<srf->m_Textures.GetCount();i++)
							SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SRF_TEXTURES, CB_ADDSTRING, 0, (LPARAM)srf->m_Textures[i].name);
						SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SRF_TEXTURES, CB_SETCURSEL, selIndex, 0);
						if (srf->m_Textures.GetCount())
							SetDlgItemText(mWnd, IDC_EB_MAC_PR_SRF_TEXTUREOBJ, srf->m_Textures[selIndex].refName);
					}
				}
				break;
			case IDC_BT_MAC_PR_SRF_TEXTUREOBJUSE:
				{
					OCpjSurface* srf = (OCpjSurface*)mChunk;
					NInt selIndex = SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SRF_TEXTURES, CB_GETCURSEL, 0, 0);
					if (selIndex == CB_ERR)
						break;
					if (!mOwnerDialog || !mOwnerDialog->mIpcHook)
						break;
					NChar refName[256]; refName[0] = 0;
					if (!IPC_SendMessage(mOwnerDialog->mIpcHook, MACEDIT_IPC_PROTOCOL_OUT, MACEDIT_IPC_OMSG_GETCURTEXREF, 0, NULL, refName))
						refName[0] = 0;
					SetDlgItemText(mWnd, IDC_EB_MAC_PR_SRF_TEXTUREOBJ, refName);
					strcpy(srf->m_Textures[selIndex].refName, refName);
					IPC_PostMessage(mOwnerDialog->mIpcHook, MACEDIT_IPC_PROTOCOL_OUT, MACEDIT_IPC_OMSG_TEXREFUPDATE, 0, NULL);
				}
				break;
			case IDC_CB_MAC_PR_SRF_TEXTURES:
				{
					switch(HIWORD(wParam))
					{
					case CBN_SELCHANGE:
						{
							OCpjSurface* srf = (OCpjSurface*)mChunk;
							NInt selIndex = SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SRF_TEXTURES, CB_GETCURSEL, 0, 0);
							if (selIndex == CB_ERR)
								break;
							SetDlgItemText(mWnd, IDC_EB_MAC_PR_SRF_TEXTUREOBJ, srf->m_Textures[selIndex].refName);
						}
						break;
					}
				}
				break;
			case IDC_EB_MAC_PR_SRF_TEXTUREOBJ:
				{
					switch(HIWORD(wParam))
					{
					case EN_CHANGE:
						{
							OCpjSurface* srf = (OCpjSurface*)mChunk;
							NInt selIndex = SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_SRF_TEXTURES, CB_GETCURSEL, 0, 0);
							if (selIndex == CB_ERR)
								break;
							char buf[256];
							GetDlgItemText(mWnd, IDC_EB_MAC_PR_SRF_TEXTUREOBJ, buf, 255);
							strcpy(srf->m_Textures[selIndex].refName, buf);
						}
						break;
					}
				}
				break;
			}
			break;
		}
		return(Super::DialogProc(hWnd, msg, wParam, lParam));
	}
};
OBJ_CLASS_IMPLEMENTATION(OMacSurfaceDetails, OMacDetailsDialog, 0);

class OMacBrowserSurfaceItem
: public OMacBrowserChunkItem
{
	OBJ_CLASS_DEFINE(OMacBrowserSurfaceItem, OMacBrowserChunkItem);

	NDword GetImageResID() { return(IDB_CPJ_SRF); }
	const NChar* GetLabel() { return("Surface"); }
	CObjClass* GetChunkClass() { return(OCpjSurface::GetStaticClass()); }
	NDword GetPopupIndex() { return(5); }
	CObjClass* GetDetailsClass() { return(OMacSurfaceDetails::GetStaticClass()); }

	NBool OnCommand(NDword inCmdID)
	{
		switch(inCmdID)
		{
		case ID_MAC_SURFACE_USE_PRIMARY:
			{
				if (!GetChunk())
					break;
				if (GetOwnerDialog() && GetOwnerDialog()->mActor)
				{
					GetOwnerDialog()->mActor->SetSurface(0, (OCpjSurface*)GetChunk());
					GetOwnerDialog()->ActorRefresh();
				}
			}
			break;
		case ID_MAC_SURFACE_USE_DECAL:
			{
				if (!GetChunk())
					break;
				if (GetOwnerDialog() && GetOwnerDialog()->mActor)
				{
					GetOwnerDialog()->mActor->SetSurface(1, (OCpjSurface*)GetChunk());
					GetOwnerDialog()->ActorRefresh();
				}
			}
			break;
		}
		return(Super::OnCommand(inCmdID));
	}
};
OBJ_CLASS_IMPLEMENTATION(OMacBrowserSurfaceItem, OMacBrowserChunkItem, 0);

/*
	OMacBrowserGeometryItem
*/
class OMacGeometryDetails
: public OMacDetailsDialog
{
	OBJ_CLASS_DEFINE(OMacGeometryDetails, OMacDetailsDialog);
	
	NDword GetDialogID() { return(IDD_MAC_PR_GEO); }

	NBool DialogProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
	{
		switch(msg)
		{
		case WM_INITDIALOG:
			{
				char buf[256];

				OCpjGeometry* geo = (OCpjGeometry*)mChunk;
				geo->CacheIn();
				sprintf(buf, "%d", geo->m_Verts.GetCount()); SetDlgItemText(mWnd, IDC_EB_MAC_PR_GEO_NUMVERTS, buf);
				NDword lockCount = 0;
				for (NDword i=0;i<geo->m_Verts.GetCount();i++)
					if (geo->m_Verts[i].flags & GEOVF_LODLOCK)
						lockCount++;
				sprintf(buf, "%d", lockCount); SetDlgItemText(mWnd, IDC_EB_MAC_PR_GEO_NUMVERTSLOCKED, buf);
				sprintf(buf, "%d", geo->m_Tris.GetCount()); SetDlgItemText(mWnd, IDC_EB_MAC_PR_GEO_NUMTRIS, buf);
				sprintf(buf, "%d", geo->m_Mounts.GetCount()); SetDlgItemText(mWnd, IDC_EB_MAC_PR_GEO_NUMMOUNTS, buf);
				for (i=0;i<geo->m_Mounts.GetCount();i++)
					SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_GEO_MOUNTS, CB_ADDSTRING, 0, (LPARAM)geo->m_Mounts[i].name);
				SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_GEO_MOUNTS, CB_SETCURSEL, 0, 0);
				
				return(1);
			}
			break;
		case WM_COMMAND:
			switch(LOWORD(wParam))
			{
			case IDC_BT_MAC_PR_GEO_MOUNTRENAME:
				{
					OCpjGeometry* geo = (OCpjGeometry*)mChunk;

					NInt selIndex = SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_GEO_MOUNTS, CB_GETCURSEL, 0, 0);
					if (selIndex == CB_ERR)
						break;
					NChar* name;
					if (name = WIN_InputBox("Rename Mount Point", geo->m_Mounts[selIndex].name, "Please enter the new name:"))
					{
						strcpy(geo->m_Mounts[selIndex].name, name);
						SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_GEO_MOUNTS, CB_RESETCONTENT, 0, 0);
						for (NDword i=0;i<geo->m_Mounts.GetCount();i++)
							SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_GEO_MOUNTS, CB_ADDSTRING, 0, (LPARAM)geo->m_Mounts[i].name);
						SendDlgItemMessage(mWnd, IDC_CB_MAC_PR_GEO_MOUNTS, CB_SETCURSEL, selIndex, 0);
					}
				}
				break;
			}
		}
		return(Super::DialogProc(hWnd, msg, wParam, lParam));
	}
};
OBJ_CLASS_IMPLEMENTATION(OMacGeometryDetails, OMacDetailsDialog, 0);

class OMacBrowserGeometryItem
: public OMacBrowserChunkItem
{
	OBJ_CLASS_DEFINE(OMacBrowserGeometryItem, OMacBrowserChunkItem);

	NDword GetImageResID() { return(IDB_CPJ_GEO); }
	const NChar* GetLabel() { return("Geometry"); }
	CObjClass* GetChunkClass() { return(OCpjGeometry::GetStaticClass()); }
	NDword GetPopupIndex() { return(4); }
	CObjClass* GetDetailsClass() { return(OMacGeometryDetails::GetStaticClass()); }

	NBool OnCommand(NDword inCmdID)
	{
		switch(inCmdID)
		{
		case ID_MAC_GEOMETRY_USE:
			{
				if (!GetChunk())
					break;
				if (GetOwnerDialog() && GetOwnerDialog()->mActor)
				{
					GetOwnerDialog()->mActor->SetGeometry((OCpjGeometry*)GetChunk());
					GetOwnerDialog()->ActorRefresh();
				}
			}
			break;
		}
		return(Super::OnCommand(inCmdID));
	}
};
OBJ_CLASS_IMPLEMENTATION(OMacBrowserGeometryItem, OMacBrowserChunkItem, 0);

/*
	OMacBrowserConfigItem
*/
class OMacConfigDetails
: public OMacDetailsDialog
{
	OBJ_CLASS_DEFINE(OMacConfigDetails, OMacDetailsDialog);
	
	NDword GetDialogID() { return(IDD_MAC_PR_MAC); }

	NBool DialogProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
	{
		switch(msg)
		{
		case WM_INITDIALOG:
			{
				char buf[256];

				OCpjConfig* cfg = (OCpjConfig*)mChunk;
				cfg->CacheIn();
				for (NDword i=0;i<cfg->m_Sections.GetCount();i++)
				{
					sprintf(buf, "[%s]", cfg->m_Sections[i].name);
					SendDlgItemMessage(mWnd, IDC_LB_MAC_PR_MAC_COMMANDS, LB_ADDSTRING, 0, (LPARAM)buf);
					for (NDword j=0;j<cfg->m_Sections[i].commands.GetCount();j++)
						SendDlgItemMessage(mWnd, IDC_LB_MAC_PR_MAC_COMMANDS, LB_ADDSTRING, 0, (LPARAM)*cfg->m_Sections[i].commands[j]);
					SendDlgItemMessage(mWnd, IDC_LB_MAC_PR_MAC_COMMANDS, LB_ADDSTRING, 0, (LPARAM)"");
				}
			}
			break;
		}
		return(Super::DialogProc(hWnd, msg, wParam, lParam));
	}
};
OBJ_CLASS_IMPLEMENTATION(OMacConfigDetails, OMacDetailsDialog, 0);

class OMacBrowserConfigItem
: public OMacBrowserChunkItem
{
	OBJ_CLASS_DEFINE(OMacBrowserConfigItem, OMacBrowserChunkItem);

	NDword GetImageResID() { return(IDB_CPJ_MAC); }
	const NChar* GetLabel() { return("Config"); }
	CObjClass* GetChunkClass() { return(OCpjConfig::GetStaticClass()); }
	NDword GetPopupIndex() { return(3); }
	CObjClass* GetDetailsClass() { return(OMacConfigDetails::GetStaticClass()); }

	NBool OnCommand(NDword inCmdID)
	{
		switch(inCmdID)
		{
		case ID_MAC_CONFIG_LOAD:
			{
				if (!GetChunk())
					break;
				if (GetOwnerDialog() && GetOwnerDialog()->mActor)
				{
					if (GetOwnerDialog()->mActor->LoadConfig((OCpjConfig*)GetChunk()))
						GetOwnerDialog()->mCurrentConfig = (OCpjConfig*)GetChunk();
					GetOwnerDialog()->ActorRefresh();
				}
			}
			break;
		case ID_MAC_CONFIG_SAVE:
			{
				if (!GetChunk())
					break;
				if (GetOwnerDialog() && GetOwnerDialog()->mActor)
				{
					if (GetOwnerDialog()->mActor->SaveConfig((OCpjConfig*)GetChunk()))
						GetOwnerDialog()->mCurrentConfig = (OCpjConfig*)GetChunk();
					GetOwnerDialog()->ActorRefresh();
				}
			}
			break;
		}
		return(Super::OnCommand(inCmdID));
	}
};
OBJ_CLASS_IMPLEMENTATION(OMacBrowserConfigItem, OMacBrowserChunkItem, 0);

/*
	OMacBrowserProjectItem
*/
class OMacBrowserProjectItem
: public OMacBrowserItem
{
	OBJ_CLASS_DEFINE(OMacBrowserProjectItem, OMacBrowserItem);

	OCpjProject* mProject;
	CCorString mProjectPath;

	OCpjProject* GetProject()
	{
		if (!mProject)
			mProject = CPJ_FindProject(*mProjectPath);
		return(mProject);
	}

	void RefreshTree();
	void MenuAddItem(CObjClass* inItemClass);
	void MenuRemoveItems(CObjClass* inItemClass);
	void MenuImportItems(CObjClass* inItemClass);

	NBool OnCommand(NDword inCmdID);
	void OnDblClick();
	void OnRightClick();
	void OnKeyDown(NDword inKey);
};
OBJ_CLASS_IMPLEMENTATION(OMacBrowserProjectItem, OMacBrowserItem, 0);

/*
	OMacBrowserFolderItem
*/
class OMacBrowserFolderItem
: public OMacBrowserItem
{
	OBJ_CLASS_DEFINE(OMacBrowserFolderItem, OMacBrowserItem);

	void RefreshTree(CCorString& inFullPath, CCorString& inPartialPath);

	NBool OnCommand(NDword inCmdID);
	void OnRightClick();
	void OnExpand();
	void OnCollapse();
	void OnKeyDown(NDword inKey);
};
OBJ_CLASS_IMPLEMENTATION(OMacBrowserFolderItem, OMacBrowserItem, 0);

//============================================================================
//    PRIVATE DATA
//============================================================================
//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    PRIVATE FUNCTIONS
//============================================================================
KRN_API void FILE_Deltree(const NChar* inPath)
{
	NChar* fileName;
	NInt isDir;

	if (!inPath)
		return;
	fileName = STR_FileFind(*(CCorString(inPath) + "\\*.*"), &isDir, NULL);
	while (fileName)
	{
		if (isDir)
		{
			STR_FileFindPushState();
			FILE_Deltree(fileName);
			STR_FileFindPopState();
		}
		else
		{
			remove(fileName);
		}
		fileName = STR_FileFind(NULL, &isDir, NULL);
	}
	_rmdir(inPath);
}

//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
KRN_API void MAC_EditBox(NDword inIpcHook)
{	
	InitCommonControls();

	/* TEST
	if (!inIpcHook)
		inIpcHook = IPC_GetCurrentProcess();
	*/

	OMacBrowserDialog* dlg = OMacBrowserDialog::New(OObject::GetRoot());
	dlg->Launch(inIpcHook);
	dlg->Destroy();
}

//============================================================================
//    CLASS METHODS
//============================================================================
/*
	OMacBrowserTree
*/
NBool OMacBrowserTree::SelectChunkItem(OCpjChunk* inItem, OWinTreeViewItem* inBaseTreeItem)
{
	if (!inItem)
		return(0);
	
	if (inBaseTreeItem && inBaseTreeItem->IsA(OMacBrowserChunkItem::GetStaticClass()))
	{
		OMacBrowserChunkItem* chunkItem = (OMacBrowserChunkItem*)inBaseTreeItem;
		if (chunkItem->GetChunk() == inItem)
		{
			TreeView_Select(mWnd, chunkItem->GetHandle(), TVGN_FIRSTVISIBLE);
			TreeView_Select(mWnd, chunkItem->GetHandle(), TVGN_CARET);
			return(1);
		}
	}
	else if (inBaseTreeItem && inBaseTreeItem->IsA(OMacBrowserProjectItem::GetStaticClass()))
	{
		OMacBrowserProjectItem* prjItem = (OMacBrowserProjectItem*)inBaseTreeItem;
		if (prjItem->GetProject() && (prjItem->GetProject()==inItem->GetParent()))
			prjItem->RefreshTree();
	}

	OObject* parent = inBaseTreeItem;
	if (!parent)
		parent = this;
	for (TObjIter<OWinTreeViewItem> i(parent); i; i++)
	{
		if (SelectChunkItem(inItem, *i))
			return(1);
	}
	return(0);
}

/*
	OMacBrowserDialog
*/
static NDword StaticIpcFuncInbound(NDword inSenderProcess, NDword inMessage, NDword inParamV, NChar* inParamS, void* inUserData)
{
	OMacBrowserDialog* This = (OMacBrowserDialog*)inUserData;

	switch(inMessage)
	{
	case MACEDIT_IPC_IMSG_CLOSE:
		//LOG_Logf("CLOSE");
		if (This->mWnd)
		{
			if (This->mTree)
			{
				This->mTree->Destroy();
				This->mTree = NULL;
			}
			EndDialog(This->mWnd, 0);
		}
		return(1);
		break;
	case MACEDIT_IPC_IMSG_SETTITLE:
		//LOG_Logf("SETTITLE %s", inParamS);
		This->mTitleText = inParamS;
		if (This->mWnd)
			SendMessage(This->mWnd, WM_SETTEXT, 0, (LPARAM)inParamS);
		return(1);
		break;
	case MACEDIT_IPC_IMSG_SELECTCONFIG:
		{
			//LOG_Logf("SELECTCONFIG %s", inParamS);
			OCpjConfig* cfg = (OCpjConfig*)CPJ_FindChunk(NULL, OCpjConfig::GetStaticClass(), inParamS);
			if (!cfg)
				return(1);
			if (This->mActor->LoadConfig(cfg))
			{
				This->mCurrentConfig = cfg;
				This->ActorRefresh();
			}
			if (This->mTree)
				This->mTree->SelectChunkItem(cfg, NULL);
		}
		return(1);
		break;
	}
	return(0);
}

BOOL CALLBACK OMacBrowserDialog::StaticDialogProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	OMacBrowserDialog* This = (OMacBrowserDialog*)GetWindowLong(hWnd, GWL_USERDATA);
	if (msg == WM_INITDIALOG)
	{
		This = (OMacBrowserDialog*)lParam;
		SetWindowLong(hWnd, GWL_USERDATA, (LONG)This);
	}
	NBool result = 0;
	if (This)
	{
		static NBool mutex = 0;
		if (!mutex)
		{
			mutex = 1;
			IPC_GetMessages(StaticIpcFuncInbound, MACEDIT_IPC_PROTOCOL_IN, This);
			mutex = 0;
		}

		result = This->DialogProc(hWnd, msg, wParam, lParam);
	}

	return(result);
}
NBool OMacBrowserDialog::DialogProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	switch(msg)
	{
	case WM_INITDIALOG:
		{
			mWnd = hWnd;

			// move to center of screen
			RECT rect;
			GetWindowRect(hWnd, &rect);
			SetWindowPos(hWnd, HWND_TOP,
				(GetSystemMetrics(SM_CXSCREEN)-(rect.right-rect.left))/2,
				(GetSystemMetrics(SM_CYSCREEN)-(rect.bottom-rect.top))/2,
				rect.right-rect.left, rect.bottom-rect.top, SWP_SHOWWINDOW);

			if (!mTitleText.Len())
				mTitleText = "Cannibal Model Configuration Editor";
			SendMessage(hWnd, WM_SETTEXT, 0, (LPARAM)*mTitleText);

			// refresh browser tree
			BrowserRefresh();
			
			// refresh from actor configuration
			ActorRefresh();

			if (mCurrentConfig && mTree)
				mTree->SelectChunkItem(mCurrentConfig, NULL);

			return(1);
		}
		break;
	case WM_CLOSE:
		{
			if (mTree)
			{
				// have to kill the tree before the box closes so the items will still be valid when they're removed
				mTree->Destroy();
				mTree = NULL;
			}
			EndDialog(hWnd, 0);
		}
		break;
	/*
	case WM_SIZING:
		{
			RECT origRect;
			GetWindowRect(hWnd, &origRect);
			RECT* targRect = (RECT*)lParam;
			targRect->top = origRect.top;
			targRect->bottom = origRect.bottom;				
			return(1);
			break;
		}
		break;
	case WM_SIZE:
		{
			RECT rect;
			HWND treeWnd = GetDlgItem(hWnd, IDC_TV_MAC_BROWSER);
			GetClientRect(hWnd, &rect);
			SetWindowPos(treeWnd, HWND_TOP, 0, 0, rect.right-rect.left, rect.bottom-rect.top, SWP_NOZORDER);
		}
		break;
	*/
	case WM_COMMAND:
		{
			if (mActor)
			{
				switch(LOWORD(wParam))
				{
				case IDC_BT_MAC_REFRESH:
					{
						ActorRefresh();
					}
					break;
				case IDC_EB_MAC_AUTHOR:
					{
						switch(HIWORD(wParam))
						{
						case EN_CHANGE:
							{
								char buf[256];
								GetDlgItemText(hWnd, IDC_EB_MAC_AUTHOR, buf, 255);
								mActor->mAuthor = buf;
							}
							break;
						}
					}
					break;
				case IDC_EB_MAC_DESCRIPTION:
					{
						switch(HIWORD(wParam))
						{
						case EN_CHANGE:
							{
								char buf[256];
								GetDlgItemText(hWnd, IDC_EB_MAC_DESCRIPTION, buf, 255);
								mActor->mDescription = buf;
							}
							break;
						}
					}
					break;
				case IDC_BT_MAC_CONFIGSAVE:
					{
						if (!mCurrentConfig)
							break;
						mActor->SaveConfig(mCurrentConfig);
						ActorRefresh();

						NBool isChecked = 0;
						if (SendDlgItemMessage(hWnd, IDC_CK_MAC_CONFIGSAVECPJ, BM_GETCHECK, 0, 0) == BST_CHECKED)
							isChecked = 1;
						if (isChecked && mCurrentConfig->GetParent() && mCurrentConfig->GetParent()->IsA(OCpjProject::GetStaticClass()))
						{
							OCpjProject* prj = (OCpjProject*)mCurrentConfig->GetParent();
							CCorString fileName(prj->GetFileName());
							if (!prj->ExportFile(*fileName))
								LOG_Logf("Unable to export \"%s\".", *fileName);
							else
								LOG_Logf("\"%s\" saved.", *fileName);
						}
					}
					break;
				case IDC_BT_MAC_CONFIGSAVEAS:
					{
						if (!mCurrentConfig)
							break;
						NChar* name;
						if (!(name = WIN_InputBox("Save Configuration As", mCurrentConfig->GetName(), "Please enter the name of the configuration:")))
							break;
						OCpjConfig* cfg = NULL;
						for (TObjIter<OCpjConfig> i(mCurrentConfig->GetParent()); i; i++)
						{
							if (!stricmp(name, i->GetName()))
							{
								cfg = *i;
								break;
							}
						}
						if (!cfg)
						{
							cfg = OCpjConfig::New(mCurrentConfig->GetParent());
							cfg->SetName(name);
						}
						mCurrentConfig = cfg;
						mActor->SaveConfig(mCurrentConfig);
						ActorRefresh();

						NBool isChecked = 0;
						if (SendDlgItemMessage(hWnd, IDC_CK_MAC_CONFIGSAVECPJ, BM_GETCHECK, 0, 0) == BST_CHECKED)
							isChecked = 1;
						if (isChecked && mCurrentConfig->GetParent() && mCurrentConfig->GetParent()->IsA(OCpjProject::GetStaticClass()))
						{
							OCpjProject* prj = (OCpjProject*)mCurrentConfig->GetParent();
							CCorString fileName(prj->GetFileName());
							if (!prj->ExportFile(*fileName))
								LOG_Logf("Unable to export \"%s\".", *fileName);
							else
								LOG_Logf("\"%s\" saved.", *fileName);
						}
					}
					break;
				case IDC_BT_MAC_CLEARGEO:
					mActor->SetGeometry(NULL);
					ActorRefresh();
					break;
				case IDC_BT_MAC_CLEARSRF0:
					mActor->SetSurface(0, NULL);
					ActorRefresh();
					break;
				case IDC_BT_MAC_CLEARSRF1:
					mActor->SetSurface(1, NULL);
					ActorRefresh();
					break;
				case IDC_BT_MAC_CLEARLOD:
					mActor->SetLodData(NULL);
					ActorRefresh();
					break;
				case IDC_BT_MAC_CLEARSKL:
					mActor->SetSkeleton(NULL);
					ActorRefresh();
					break;
				case IDC_BT_MAC_CLEARFRM:
					{
						NInt selIndex = SendDlgItemMessage(hWnd, IDC_CB_MAC_FRAMES_FILES, CB_GETCURSEL, 0, 0);
						if (selIndex == CB_ERR)
							break;
						NChar buf[256]; memset(buf, 0, sizeof(buf));
						SendDlgItemMessage(hWnd, IDC_CB_MAC_FRAMES_FILES, CB_GETLBTEXT, selIndex, (LPARAM)buf);
						for (NDword i=0;i<mActor->mFramesFiles.GetCount();i++)
						{
							if (!stricmp(*mActor->mFramesFiles[i], buf))
								mActor->mFramesFiles.Remove(i--);
						}
						for (i=0;i<mActor->mFramesStarFiles.GetCount();i++)
						{
							if (!stricmp(*mActor->mFramesStarFiles[i], buf))
								mActor->mFramesStarFiles.Remove(i--);
						}
						ActorRefresh();
					}
					break;
				case IDC_BT_MAC_CLEARSEQ:
					{
						NInt selIndex = SendDlgItemMessage(hWnd, IDC_CB_MAC_SEQUENCES_FILES, CB_GETCURSEL, 0, 0);
						if (selIndex == CB_ERR)
							break;
						NChar buf[256]; memset(buf, 0, sizeof(buf));
						SendDlgItemMessage(hWnd, IDC_CB_MAC_SEQUENCES_FILES, CB_GETLBTEXT, selIndex, (LPARAM)buf);						
						for (NDword i=0;i<mActor->mSequencesFiles.GetCount();i++)
						{
							if (!stricmp(*mActor->mSequencesFiles[i], buf))
								mActor->mSequencesFiles.Remove(i--);
						}
						for (i=0;i<mActor->mSequencesStarFiles.GetCount();i++)
						{
							if (!stricmp(*mActor->mSequencesStarFiles[i], buf))
								mActor->mSequencesStarFiles.Remove(i--);
						}
						ActorRefresh();
					}
					break;
				case IDC_BT_MAC_ORIGIN:
					{
						mActor->mOrigin = WIN_VectorBox("Change Origin", mActor->mOrigin, "X", "Y", "Z");
						ActorRefresh();
					}
					break;
				case IDC_BT_MAC_ROTATION:
					{
						VVec3 v(M_RADTODEG(mActor->mRotation.r), M_RADTODEG(mActor->mRotation.p), M_RADTODEG(mActor->mRotation.y));
						v = WIN_VectorBox("Change Rotation", v, "Roll", "Pitch", "Yaw");
						mActor->mRotation = VEulers3(M_DEGTORAD(v.x), M_DEGTORAD(v.y), M_DEGTORAD(v.z));
						ActorRefresh();
					}
					break;
				case IDC_BT_MAC_SCALE:
					{
						mActor->mScale = WIN_VectorBox("Change Scale", mActor->mScale, "X", "Y", "Z");
						ActorRefresh();
					}
					break;
				case IDC_BT_MAC_BBMIN:
					{
						mActor->mBounds[0] = WIN_VectorBox("Change Bound Minimum", mActor->mBounds[0], "X", "Y", "Z");
						ActorRefresh();
					}
					break;
				case IDC_BT_MAC_BBMAX:
					{
						mActor->mBounds[1] = WIN_VectorBox("Change Bound Maximum", mActor->mBounds[1], "X", "Y", "Z");
						ActorRefresh();
					}
					break;
				case IDC_BT_MAC_BBAUTO:
					{
						if (!mActor->mGeometry || !mActor->mGeometry->m_Verts.GetCount())
							break;
						mActor->mBounds[0] = VVec3(FLT_MAX,FLT_MAX,FLT_MAX);
						mActor->mBounds[1] = VVec3(-FLT_MAX,-FLT_MAX,-FLT_MAX);
						for (NDword i=0;i<mActor->mGeometry->m_Verts.GetCount();i++)
						{
							VVec3 v = mActor->mGeometry->m_Verts[i].refPosition;
							for (NDword j=0;j<3;j++)
							{
								if (mActor->mBounds[0][j] > v[j])
									mActor->mBounds[0][j] = v[j];
								if (mActor->mBounds[1][j] < v[j])
									mActor->mBounds[1][j] = v[j];
							}
						}
						for (NDword iFrame=0;iFrame<mActor->mFrames.GetCount();iFrame++)
						{
							if (!mActor->mFrames[iFrame])
								continue;
							mActor->mFrames[iFrame]->UpdateBounds();
							for (NDword j=0;j<3;j++)
							{
								if (mActor->mBounds[0][j] > mActor->mFrames[iFrame]->m_Bounds[0][j])
									mActor->mBounds[0][j] = mActor->mFrames[iFrame]->m_Bounds[0][j];
								if (mActor->mBounds[1][j] < mActor->mFrames[iFrame]->m_Bounds[1][j])
									mActor->mBounds[1][j] = mActor->mFrames[iFrame]->m_Bounds[1][j];
							}
						}
						ActorRefresh();
					}
					break;
				case IDC_BT_MAC_AUTOCENTER:
					{
						VVec3 c = (mActor->mBounds[0] + mActor->mBounds[1]) * 0.5f;
						c.y = mActor->mBounds[0].y;
						mActor->mOrigin = c;
						ActorRefresh();
					}
					break;
				}
			}

			// pass it on to the tree
			if (mTree)
			{
				if (mTree->OnCommand(wParam, lParam))
					break;
			}
		}
		break;
	case WM_NOTIFY:
		{
			NMHDR* hdr = (NMHDR*)lParam;
			if ((mTree) && (hdr->hwndFrom == mTree->mWnd))
				mTree->OnNotify(hdr);
		}
		break;
	default:
		break;
	}
	return(0);
}

void OMacBrowserDialog::Create()
{
	Super::Create();

	mTree = NULL;
	mActor = OMacActor::New(NULL);
	mCurrentConfig = NULL;
	mIpcHook = 0;

	mImageList = OWinImageList::New(this);
	mImageList->Init(16, 16, 10);
	mImageList->AddImage(IDB_FILE_CLOSED);
	mImageList->AddImage(IDB_FILE_OPEN);
	mImageList->AddImage(IDB_CPJ_CPJ);
	mImageList->AddImage(IDB_CPJ_MAC);
	mImageList->AddImage(IDB_CPJ_GEO);
	mImageList->AddImage(IDB_CPJ_SRF);
	mImageList->AddImage(IDB_CPJ_LOD);
	mImageList->AddImage(IDB_CPJ_SKL);
	mImageList->AddImage(IDB_CPJ_FRM);
	mImageList->AddImage(IDB_CPJ_SEQ);
}

void OMacBrowserDialog::Destroy()
{
	if (mActor)
	{
		mActor->Destroy();
		mActor = NULL;
	}
	Super::Destroy();
}

void OMacBrowserDialog::ActorRefresh()
{
	const NChar* text;
	NInt textLen;
	NDword i;

	if (!mActor)
		return;

	// create a temporary config to flush removed data
	OCpjConfig* cfg = OCpjConfig::New(NULL);
	mActor->SaveConfig(cfg);
	mActor->LoadConfig(cfg);
	cfg->SaveFile("tempedit.mac");
/*
	{
		for (NDword i=0;i<cfg->m_Sections.GetCount();i++)
		{
			LOG_Logf("Section: %s", *cfg->m_Sections[i].name);
			for (NDword j=0;j<cfg->m_Sections[i].commands.GetCount();j++)
				LOG_Logf("  %s", *cfg->m_Sections[i].commands[j]);
		}
	}
*/
	cfg->Destroy();

	// current configuration
	text = CPJ_GetChunkPath(NULL, mCurrentConfig);
	SetDlgItemText(mWnd, IDC_EB_MAC_CONFIG, text ? text : "None");
	textLen = text ? strlen(text) : 0;
	SendDlgItemMessage(mWnd, IDC_EB_MAC_CONFIG, EM_SETSEL, textLen, textLen);

	// author and description
	SetDlgItemText(mWnd, IDC_EB_MAC_AUTHOR, *mActor->mAuthor);
	SendDlgItemMessage(mWnd, IDC_EB_MAC_AUTHOR, EM_SETSEL, mActor->mAuthor.Len(), mActor->mAuthor.Len());
	SetDlgItemText(mWnd, IDC_EB_MAC_DESCRIPTION, *mActor->mDescription);
	SendDlgItemMessage(mWnd, IDC_EB_MAC_DESCRIPTION, EM_SETSEL, mActor->mDescription.Len(), mActor->mDescription.Len());

	// vectors/rotations
	NChar buf[256]; 
	sprintf(buf, "X= %.3f, Y= %.3f, Z= %.3f", mActor->mOrigin.x, mActor->mOrigin.y, mActor->mOrigin.z); SetDlgItemText(mWnd, IDC_ST_MAC_ORIGIN, buf);
	sprintf(buf, "Roll= %.1f, Pitch= %.1f, Yaw= %.1f", M_RADTODEG(mActor->mRotation.r), M_RADTODEG(mActor->mRotation.p), M_RADTODEG(mActor->mRotation.y)); SetDlgItemText(mWnd, IDC_ST_MAC_ROTATION, buf);
	sprintf(buf, "X= %.3f, Y= %.3f, Z= %.3f", mActor->mScale.x, mActor->mScale.y, mActor->mScale.z); SetDlgItemText(mWnd, IDC_ST_MAC_SCALE, buf);
	sprintf(buf, "X= %.3f, Y= %.3f, Z= %.3f", mActor->mBounds[0].x, mActor->mBounds[0].y, mActor->mBounds[0].z); SetDlgItemText(mWnd, IDC_ST_MAC_BBMIN, buf);
	sprintf(buf, "X= %.3f, Y= %.3f, Z= %.3f", mActor->mBounds[1].x, mActor->mBounds[1].y, mActor->mBounds[1].z); SetDlgItemText(mWnd, IDC_ST_MAC_BBMAX, buf);

	// geometry
	text = CPJ_GetChunkPath(NULL, mActor->mGeometry);
	SetDlgItemText(mWnd, IDC_EB_MAC_GEOMETRY, text ? text : "None");
	textLen = text ? strlen(text) : 0;
	SendDlgItemMessage(mWnd, IDC_EB_MAC_GEOMETRY, EM_SETSEL, textLen, textLen);
	
	// primary surface
	text = NULL;
	if (mActor->mSurfaces.GetCount() > 0)
		text = CPJ_GetChunkPath(NULL, mActor->mSurfaces[0]);
	SetDlgItemText(mWnd, IDC_EB_MAC_SURFACE0, text ? text : "None");
	textLen = text ? strlen(text) : 0;
	SendDlgItemMessage(mWnd, IDC_EB_MAC_SURFACE0, EM_SETSEL, textLen, textLen);

	// decal surface
	text = NULL;
	if (mActor->mSurfaces.GetCount() > 1)
		text = CPJ_GetChunkPath(NULL, mActor->mSurfaces[1]);
	SetDlgItemText(mWnd, IDC_EB_MAC_SURFACE1, text ? text : "None");
	textLen = text ? strlen(text) : 0;
	SendDlgItemMessage(mWnd, IDC_EB_MAC_SURFACE1, EM_SETSEL, textLen, textLen);

	// lod data
	text = CPJ_GetChunkPath(NULL, mActor->mLodData);
	SetDlgItemText(mWnd, IDC_EB_MAC_LODDATA, text ? text : "None");
	textLen = text ? strlen(text) : 0;
	SendDlgItemMessage(mWnd, IDC_EB_MAC_LODDATA, EM_SETSEL, textLen, textLen);

	// skeleton
	text = CPJ_GetChunkPath(NULL, mActor->mSkeleton);
	SetDlgItemText(mWnd, IDC_EB_MAC_SKELETON, text ? text : "None");
	textLen = text ? strlen(text) : 0;
	SendDlgItemMessage(mWnd, IDC_EB_MAC_SKELETON, EM_SETSEL, textLen, textLen);
	
	// frames
	SendDlgItemMessage(mWnd, IDC_CB_MAC_FRAMES_FILES, CB_RESETCONTENT, 0, 0);
	for (i=0;i<mActor->mFramesFiles.GetCount();i++)
		SendDlgItemMessage(mWnd, IDC_CB_MAC_FRAMES_FILES, CB_ADDSTRING, 0, (LPARAM)*mActor->mFramesFiles[i]);
	for (i=0;i<mActor->mFramesStarFiles.GetCount();i++)
		SendDlgItemMessage(mWnd, IDC_CB_MAC_FRAMES_FILES, CB_ADDSTRING, 0, (LPARAM)*mActor->mFramesStarFiles[i]);
	SendDlgItemMessage(mWnd, IDC_CB_MAC_FRAMES_FILES, CB_SETCURSEL, 0, 0);
	SendDlgItemMessage(mWnd, IDC_CB_MAC_FRAMES_OBJECTS, CB_RESETCONTENT, 0, 0);
	for (i=0;i<mActor->mFrames.GetCount();i++)
	{
		if (!mActor->mFrames[i])
			continue;
		mActor->mFrames[i]->CacheIn();
		for (NDword j=0;j<mActor->mFrames[i]->m_Frames.GetCount();j++)
			SendDlgItemMessage(mWnd, IDC_CB_MAC_FRAMES_OBJECTS, CB_ADDSTRING, 0, (LPARAM)*mActor->mFrames[i]->m_Frames[j].m_Name);
	}
	SendDlgItemMessage(mWnd, IDC_CB_MAC_FRAMES_OBJECTS, CB_SETCURSEL, 0, 0);

	// sequences
	SendDlgItemMessage(mWnd, IDC_CB_MAC_SEQUENCES_FILES, CB_RESETCONTENT, 0, 0);
	for (i=0;i<mActor->mSequencesFiles.GetCount();i++)
		SendDlgItemMessage(mWnd, IDC_CB_MAC_SEQUENCES_FILES, CB_ADDSTRING, 0, (LPARAM)*mActor->mSequencesFiles[i]);
	for (i=0;i<mActor->mSequencesStarFiles.GetCount();i++)
		SendDlgItemMessage(mWnd, IDC_CB_MAC_SEQUENCES_FILES, CB_ADDSTRING, 0, (LPARAM)*mActor->mSequencesStarFiles[i]);
	SendDlgItemMessage(mWnd, IDC_CB_MAC_SEQUENCES_FILES, CB_SETCURSEL, 0, 0);
	SendDlgItemMessage(mWnd, IDC_CB_MAC_SEQUENCES_OBJECTS, CB_RESETCONTENT, 0, 0);
	for (i=0;i<mActor->mSequences.GetCount();i++)
	{
		if (mActor->mSequences[i])
			SendDlgItemMessage(mWnd, IDC_CB_MAC_SEQUENCES_OBJECTS, CB_ADDSTRING, 0, (LPARAM)mActor->mSequences[i]->GetName());
	}
	SendDlgItemMessage(mWnd, IDC_CB_MAC_SEQUENCES_OBJECTS, CB_SETCURSEL, 0, 0);

	// let the hook know, if it exists
	if (mIpcHook)
	{
		if (mCurrentConfig)
		{
			const NChar* path = CPJ_GetChunkPath(NULL, mCurrentConfig);
			if (path)
				IPC_PostMessage(mIpcHook, MACEDIT_IPC_PROTOCOL_OUT, MACEDIT_IPC_OMSG_SETCONFIG, 0, (NChar*)path);
		}
		
		IPC_PostMessage(mIpcHook, MACEDIT_IPC_PROTOCOL_OUT, MACEDIT_IPC_OMSG_ACTORUPDATE, 0, "tempedit.mac");
	}
}
void OMacBrowserDialog::BrowserRefresh()
{
	if (mTree)
		mTree->Destroy();

	HWND treeWnd = GetDlgItem(mWnd, IDC_TV_MAC_BROWSER);
	mTree = OMacBrowserTree::New(this);
	mTree->Init(treeWnd, mImageList);

	char basePath[256];
	strcpy(basePath, CPJ_GetBasePath());
	basePath[strlen(basePath)-1] = 0; // strip trailing backslash

	OMacBrowserFolderItem* item = OMacBrowserFolderItem::New(mTree);
	item->Init(mTree, basePath, NULL);
	item->RefreshTree(CCorString(basePath), CCorString());
}

NBool OMacBrowserDialog::Launch(NDword inIpcHook)
{
	mIpcHook = inIpcHook;
	HINSTANCE hInst = (HINSTANCE)KRN_GetModuleHandle();
	NInt result = DialogBoxParam(hInst, MAKEINTRESOURCE(IDD_MAC_EDITOR), NULL, (DLGPROC)StaticDialogProc, (LPARAM)this);
	if (result == -1)
		return(0);
	return(1);
}

/*
	OMacBrowserItem
*/
OMacBrowserDialog* OMacBrowserItem::GetOwnerDialog()
{
	OWinWindow* parentWnd = NULL;
	if (!GetOwnerTree() || !(parentWnd = GetOwnerTree()->GetWindowParent()))
		return(NULL);
	if (!parentWnd->IsA(OMacBrowserDialog::GetStaticClass()))
		return(NULL);
	return((OMacBrowserDialog*)parentWnd);
}

/*
	OMacBrowserChunkItem
*/
void OMacBrowserChunkItem::RefreshTree()
{
	if (!GetChunk())
		return;
	OWinTreeView* tree = GetOwnerTree();
	if (!tree)
		return;
	if (tree->GetImageList() && GetImageResID())
		SetImage(tree->GetImageList()->FindImage(GetImageResID()));
	CCorString label(GetChunk()->GetName());
	if (GetLabel())
		label += CCorString(" (") + GetLabel() + ") ";
	///*
	NDword tempSize;
	GetChunk()->CacheIn();
	GetChunk()->SaveChunk(NULL, &tempSize);
	NChar buf[64]; sprintf(buf, "%d", tempSize);
	label += buf;
	//*/
	SetText(*label);
}

void OMacBrowserChunkItem::OnDblClick()
{
	OnCommand(ID_MAC_CHUNK_DETAILS);
}
void OMacBrowserChunkItem::OnRightClick()
{
	if (!GetPopupIndex())
		return;
	HMENU mainMenu = LoadMenu((HINSTANCE)KRN_GetModuleHandle(), MAKEINTRESOURCE(IDM_MAC_TREEPOPUPS));
	HMENU menu = GetSubMenu(mainMenu, GetPopupIndex()-1);
	//AppendMenu(menu, MF_STRING, ID_MENU_FILE_SAVE, "Save");
	//AppendMenu(menu, MF_STRING, ID_MENU_FILE_SAVEAS, "Save As...");
	//SetMenuDefaultItem(menu, ID_MENU_FILE_SAVE, false);
	POINT pt; GetCursorPos(&pt);
	if (GetOwnerTree() && GetOwnerTree()->GetWindowParent())
		TrackPopupMenu(menu, TPM_LEFTALIGN|TPM_RIGHTBUTTON, pt.x, pt.y, 0, GetOwnerTree()->GetWindowParent()->mWnd, NULL);
	//DestroyMenu(menu);
	DestroyMenu(mainMenu);
}
NBool OMacBrowserChunkItem::OnCommand(NDword inCmdID)
{
	switch(inCmdID)
	{
	case ID_MAC_CHUNK_IMPORT:
		{
			if (!GetChunk())
				break;
			NChar* spec = GetChunk()->GetImportSpec();
			if (!spec || !spec[0])
				break;
			NChar* fileName;
			if (!(fileName = FILE_OpenBox(spec, "Import File", GetChunk()->GetFileExtension())))
				break;
			if (!GetChunk()->ImportFile(fileName))
				LOG_Logf("Unable to import \"%s\".", fileName);
			else
				LOG_Logf("\"%s\" loaded.", fileName);
			RefreshTree();
		}
		break;
	case ID_MAC_CHUNK_EXPORT:
		{
			if (!GetChunk())
				break;
			NChar* spec = GetChunk()->GetExportSpec();
			if (!spec || !spec[0])
				break;
			NChar* fileName;
			CCorString defFile(GetChunk()->GetName()); defFile += "."; defFile += GetChunk()->GetFileExtension();
			if (!(fileName = FILE_SaveBox(spec, "Export File", GetChunk()->GetFileExtension(), *defFile)))
				break;
			if (!GetChunk()->ExportFile(fileName))
				LOG_Logf("Unable to export \"%s\".", fileName);
			else
				LOG_Logf("\"%s\" saved.", fileName);
			RefreshTree();
		}
		break;
	case ID_MAC_CHUNK_RENAME:
		{
			if (!GetChunk())
				break;
			CCorString caption("Rename ");
			if (GetLabel())
				caption += GetLabel();
			NChar* name;
			if (name = WIN_InputBox(*caption, GetChunk()->GetName(), "Please enter the new name:"))
			{
				GetChunk()->SetName(name);
				RefreshTree();
				if (GetOwnerDialog())
					GetOwnerDialog()->ActorRefresh();
			}
		}
		break;
	case ID_MAC_CHUNK_DELETE:
		{			
			if (!GetChunk())
				break;
			CCorString caption("Delete ");
			if (GetLabel())
				caption += GetLabel();
			CCorString desc = CCorString("Are you sure you want to delete \"") + GetChunk()->GetName() + "\"?";
			if (MessageBox(GetOwnerDialog() ? GetOwnerDialog()->mWnd : NULL, *desc, *caption, MB_YESNO)==IDYES)
			{
				// break links to any loaded actors
				OMacActor::RemoveAllReferencesTo(GetChunk());
				
				if (GetOwnerDialog())
				{
					// break link to loaded configuration
					if (GetChunk()==GetOwnerDialog()->mCurrentConfig)
						GetOwnerDialog()->mCurrentConfig = NULL;					
				}

				GetChunk()->Destroy();
				SetChunk(NULL);
				if (GetOwnerDialog())
					GetOwnerDialog()->ActorRefresh();
				if (GetItemParent() && GetItemParent()->IsA(OMacBrowserProjectItem::GetStaticClass()))
					((OMacBrowserProjectItem*)GetItemParent())->RefreshTree();
			}
		}
		break;
	case ID_MAC_CHUNK_DETAILS:
		{
			if (!GetDetailsClass() || !GetOwnerDialog())
				break;
			OMacDetailsDialog* details = (OMacDetailsDialog*)GetDetailsClass()->New(this);
			details->Launch(GetOwnerDialog(), GetChunk());
			details->Destroy();
		}
		break;
	default:
		break;
	}
	return(0);
}
void OMacBrowserChunkItem::OnKeyDown(NDword inKey)
{
	switch(inKey)
	{
	case VK_DELETE:
		OnCommand(ID_MAC_CHUNK_DELETE);
		break;
	}
}

/*
	OMacBrowserProjectItem
*/
void OMacBrowserProjectItem::RefreshTree()
{
	if (!GetProject())
		return;
	OWinTreeView* tree = GetOwnerTree();
	if (!tree)
		return;
	
	for (TObjIter<OWinTreeViewItem> tvi(this); tvi; tvi++)
		tvi->Destroy();

/*	
	for (TObjIter<OCpjChunk> i(GetProject()); i; i++)
	{
		for (CObjClass* cls = CObjClass::GetFirstClass(); cls; cls = cls->GetNextClass())
		{
			if (!cls->IsDerivedFrom(OMacBrowserChunkItem::GetStaticClass()))
				continue;
			OMacBrowserChunkItem* defItem = OBJ_GetStaticInstance<OMacBrowserChunkItem>(cls);
			if (!defItem->GetChunkClass() || !i->IsA(defItem->GetChunkClass()))
				continue;
			OMacBrowserChunkItem* item = (OMacBrowserChunkItem*)cls->New(this);
			item->Init(tree, i->GetName(), NULL);
			if (item)
				item->SetChunk(*i);
			break;
		}
	}
*/
	for (CObjClass* cls = CObjClass::GetFirstClass(); cls; cls = cls->GetNextClass())
	{
		if (!cls->IsDerivedFrom(OMacBrowserChunkItem::GetStaticClass()))
			continue;
		OMacBrowserChunkItem* defItem = OBJ_GetStaticInstance<OMacBrowserChunkItem>(cls);
		if (!defItem->GetChunkClass())
			continue;
		for (TObjIter<OCpjChunk> i(GetProject(), true); i; i++)
		{
			if (!i->IsA(defItem->GetChunkClass()))
				continue;
			OMacBrowserChunkItem* item = (OMacBrowserChunkItem*)cls->New(this);
			item->Init(tree, i->GetName(), NULL);
			if (item)
				item->SetChunk(*i);
		}
	}
}

void OMacBrowserProjectItem::MenuAddItem(CObjClass* inItemClass)
{
	if (!inItemClass || !inItemClass->IsDerivedFrom(OMacBrowserChunkItem::GetStaticClass()))
		return;
	if (!GetProject())
		return;
	OMacBrowserChunkItem* defItem = OBJ_GetStaticInstance<OMacBrowserChunkItem>(inItemClass);
	if (!defItem->GetChunkClass())
		return;
	CCorString caption("New ");
	if (defItem->GetLabel())
		caption += defItem->GetLabel();
	NChar* name;
	if (!(name = WIN_InputBox(*caption, "Noname", "Please enter the name of the new item:")))
		return;
	OCpjChunk* chunk = (OCpjChunk*)defItem->GetChunkClass()->New(GetProject());
	chunk->SetName(name);
	chunk->mIsLoaded = 1;
	RefreshTree();
}

void OMacBrowserProjectItem::MenuRemoveItems(CObjClass* inItemClass)
{
	if (!inItemClass || !inItemClass->IsDerivedFrom(OMacBrowserChunkItem::GetStaticClass()))
		return;
	if (!GetProject())
		return;
	OMacBrowserChunkItem* defItem = OBJ_GetStaticInstance<OMacBrowserChunkItem>(inItemClass);
	if (!defItem->GetChunkClass())
		return;
	
	CCorString caption("Remove ");
	if (defItem->GetLabel())
		caption += defItem->GetLabel();
	
	CCorString text("This will remove all \"");
	if (defItem->GetLabel())
		text += defItem->GetLabel();
	else
		text += "Unknown";
	text += "\" items from this project.  Are you sure you want to delete all these items?";
	
	if (MessageBox(GetOwnerDialog() ? GetOwnerDialog()->mWnd : NULL, *text, *caption, MB_YESNO)!=IDYES)
		return;

	for (TObjIter<OCpjChunk> i(GetProject()); i; i++)
	{
		if (i->IsA(defItem->GetChunkClass()))
			i->Destroy();
	}
	RefreshTree();
}

void OMacBrowserProjectItem::MenuImportItems(CObjClass* inItemClass)
{
	if (!inItemClass || !inItemClass->IsDerivedFrom(OMacBrowserChunkItem::GetStaticClass()))
		return;
	if (!GetProject())
		return;
	OMacBrowserChunkItem* defItem = OBJ_GetStaticInstance<OMacBrowserChunkItem>(inItemClass);
	if (!defItem->GetChunkClass())
		return;
	OCpjChunk* defChunk = OBJ_GetStaticInstance<OCpjChunk>(defItem->GetChunkClass());
	NChar* spec = defChunk->GetImportSpec();
	if (!spec || !spec[0])
		return;

	if (!FILE_OpenBoxMulti(spec, "Import Files", defChunk->GetFileExtension()))
		return;
	NChar* fileName;
	NBool keepConfiguration = false;
	while (fileName = FILE_OpenBoxMultiGet())
	{
		OCpjChunk* chunk = (OCpjChunk*)defItem->GetChunkClass()->New(GetProject());
		if (!chunk->ImportFile(fileName, keepConfiguration))
		{
			LOG_Logf("Unable to import \"%s\".", fileName);
			chunk->Destroy();
			keepConfiguration = true;
			continue;
		}
		LOG_Logf("\"%s\" loaded.", fileName);
		chunk->SetName(STR_FileRoot(fileName));
		chunk->mIsLoaded = 1;
		keepConfiguration = true;
	}
	RefreshTree();
}

NBool OMacBrowserProjectItem::OnCommand(NDword inCmdID)
{
	switch(inCmdID)
	{
	case ID_MAC_PROJECT_NEW_CONFIG: MenuAddItem(OMacBrowserConfigItem::GetStaticClass()); break;
	case ID_MAC_PROJECT_NEW_GEOMETRY: MenuAddItem(OMacBrowserGeometryItem::GetStaticClass()); break;
	case ID_MAC_PROJECT_NEW_SKELETON: MenuAddItem(OMacBrowserSkeletonItem::GetStaticClass()); break;
	case ID_MAC_PROJECT_NEW_LODDATA: MenuAddItem(OMacBrowserLodDataItem::GetStaticClass()); break;
	case ID_MAC_PROJECT_NEW_SURFACE: MenuAddItem(OMacBrowserSurfaceItem::GetStaticClass()); break;
	case ID_MAC_PROJECT_NEW_FRAMES: MenuAddItem(OMacBrowserFramesItem::GetStaticClass()); break;
	case ID_MAC_PROJECT_NEW_SEQUENCE: MenuAddItem(OMacBrowserSequenceItem::GetStaticClass()); break;
	case ID_MAC_PROJECT_REMOVE_CONFIG: MenuRemoveItems(OMacBrowserConfigItem::GetStaticClass()); break;
	case ID_MAC_PROJECT_REMOVE_GEOMETRY: MenuRemoveItems(OMacBrowserGeometryItem::GetStaticClass()); break;
	case ID_MAC_PROJECT_REMOVE_SKELETON: MenuRemoveItems(OMacBrowserSkeletonItem::GetStaticClass()); break;
	case ID_MAC_PROJECT_REMOVE_LODDATA: MenuRemoveItems(OMacBrowserLodDataItem::GetStaticClass()); break;
	case ID_MAC_PROJECT_REMOVE_SURFACE: MenuRemoveItems(OMacBrowserSurfaceItem::GetStaticClass()); break;
	case ID_MAC_PROJECT_REMOVE_FRAMES: MenuRemoveItems(OMacBrowserFramesItem::GetStaticClass()); break;
	case ID_MAC_PROJECT_REMOVE_SEQUENCE: MenuRemoveItems(OMacBrowserSequenceItem::GetStaticClass()); break;
	case ID_MAC_PROJECT_IMPORT_FRAMES: MenuImportItems(OMacBrowserFramesItem::GetStaticClass()); break;
	case ID_MAC_PROJECT_IMPORT_SEQUENCES: MenuImportItems(OMacBrowserSequenceItem::GetStaticClass()); break;

	case ID_MAC_PROJECT_USE_FRAMES:
		{
			if (!GetProject())
				break;
			const NChar* path = CPJ_GetProjectPath(GetProject());
			if (!path)
				break;
			if (GetOwnerDialog() && GetOwnerDialog()->mActor)
			{
				GetOwnerDialog()->mActor->Msgf("AddFrames \"%s\"", path);
				GetOwnerDialog()->ActorRefresh();
			}
		}
		break;
	case ID_MAC_PROJECT_USE_SEQUENCES:
		{
			if (!GetProject())
				break;
			const NChar* path = CPJ_GetProjectPath(GetProject());
			if (!path)
				break;
			if (GetOwnerDialog() && GetOwnerDialog()->mActor)
			{
				GetOwnerDialog()->mActor->Msgf("AddSequences \"%s\"", path);
				GetOwnerDialog()->ActorRefresh();
			}
		}
		break;
	case ID_MAC_PROJECT_SAVE:
		{
			if (!GetProject())
				break;
			CCorString fileName(GetProject()->GetFileName());
			if (!GetProject()->ExportFile(*fileName))
				LOG_Logf("Unable to export \"%s\".", *fileName);
			else
				LOG_Logf("\"%s\" saved.", *fileName);
		}
		break;
	case ID_MAC_PROJECT_IMPORT:
		{
			if (!GetProject())
				break;
			NChar* spec = GetProject()->GetImportSpec();
			if (!spec || !spec[0])
				break;
			NChar* fileName;
			if (!(fileName = FILE_OpenBox(spec, "Import File", GetProject()->GetFileExtension())))
				break;
			CCorString oldFileName(GetProject()->GetFileName());
			if (!GetProject()->ImportFile(fileName))
				LOG_Logf("Unable to import \"%s\".", fileName);
			else
				LOG_Logf("\"%s\" loaded.", fileName);
			GetProject()->SetFileName(*oldFileName);
			RefreshTree();
		}
		break;
	case ID_MAC_PROJECT_EXPORT:
		{
			if (!GetProject())
				break;
			NChar* spec = GetProject()->GetExportSpec();
			if (!spec || !spec[0])
				break;
			NChar* fileName;
			if (!(fileName = FILE_SaveBox(spec, "Export File", GetProject()->GetFileExtension(), NULL)))
				break;
			CCorString oldFileName(GetProject()->GetFileName());
			if (!GetProject()->ExportFile(fileName))
				LOG_Logf("Unable to export \"%s\".", fileName);
			else
				LOG_Logf("\"%s\" saved.", fileName);
			GetProject()->SetFileName(*oldFileName);
		}
		break;
	case ID_MAC_PROJECT_EXPAND:
		RefreshTree();
		break;
	case ID_MAC_PROJECT_RENAME:
		{
			if (!GetProject())
				break;

			// check drive type to make sure this should be permitted
			const NChar* drivePath = CPJ_GetBasePath();
			if (drivePath && (strlen(drivePath)>1) && drivePath[1]==':')
			{
				static char buf[3];
				buf[0]=drivePath[0];
				buf[1]=drivePath[1];
				buf[2]='\\';
				drivePath = buf;
			}
			else
			{
				drivePath = NULL;
			}
			NDword dtype = GetDriveType(drivePath);
			if (dtype == DRIVE_REMOTE)
			{
				MessageBox(GetOwnerDialog() ? GetOwnerDialog()->mWnd : NULL, "Cannot rename project files on remote/network drives", "Rename Project", MB_OK);
				break;
			}
			if (dtype == DRIVE_CDROM)
			{
				MessageBox(GetOwnerDialog() ? GetOwnerDialog()->mWnd : NULL, "Cannot rename project files on CD-ROM drives", "Rename Project", MB_OK);
				break;
			}

			NChar* name;
			if (name = WIN_InputBox("Rename Project", STR_FileRoot((NChar*)GetProject()->GetFileName()), "Please enter the new name:"))
			{
				CCorString fileName(STR_FileRoot(name)); fileName += "."; fileName += STR_FileExtension((NChar*)GetProject()->GetFileName());
				CCorString path(STR_FilePath((NChar*)GetProject()->GetFileName())); path += fileName;
				if (!rename(GetProject()->GetFileName(), *path))
				{
					GetProject()->SetFileName(*path);
					SetText(*fileName);
					if (GetOwnerDialog())
						GetOwnerDialog()->ActorRefresh();
				}
			}
		}
		break;
	case ID_MAC_PROJECT_DELETE:
		{
			if (!GetProject())
				break;

			// check drive type to make sure this should be permitted
			const NChar* drivePath = CPJ_GetBasePath();
			if (drivePath && (strlen(drivePath)>1) && drivePath[1]==':')
			{
				static char buf[3];
				buf[0]=drivePath[0];
				buf[1]=drivePath[1];
				buf[2]='\\';
				drivePath = buf;
			}
			else
			{
				drivePath = NULL;
			}
			NDword dtype = GetDriveType(drivePath);
			if (dtype == DRIVE_REMOTE)
			{
				MessageBox(GetOwnerDialog() ? GetOwnerDialog()->mWnd : NULL, "Cannot delete project files on remote/network drives", "Delete Project", MB_OK);
				break;
			}
			if (dtype == DRIVE_CDROM)
			{
				MessageBox(GetOwnerDialog() ? GetOwnerDialog()->mWnd : NULL, "Cannot delete project files on CD-ROM drives", "Delete Project", MB_OK);
				break;
			}

			CCorString desc = CCorString("This will delete the project file \"") + GetProject()->GetFileName() + "\".\n\nAre you sure you want to delete this?";
			if (MessageBox(GetOwnerDialog() ? GetOwnerDialog()->mWnd : NULL, *desc, "Delete Project", MB_YESNO)==IDYES)
			{
				const NChar* fileName = GetProject()->GetFileName();
				if (fileName && fileName[0])
					remove(fileName);
				for (TObjIter<OCpjChunk> i(GetProject()); i; i++)
					OMacActor::RemoveAllReferencesTo(*i);
				if (GetOwnerDialog())
					GetOwnerDialog()->ActorRefresh();
				GetProject()->Destroy();
				Destroy();
			}
		}
		break;
	default:
		break;
	}
	return(0);
}
void OMacBrowserProjectItem::OnDblClick()
{
	OnCommand(ID_MAC_PROJECT_EXPAND);
}
void OMacBrowserProjectItem::OnRightClick()
{
	HMENU mainMenu = LoadMenu((HINSTANCE)KRN_GetModuleHandle(), MAKEINTRESOURCE(IDM_MAC_TREEPOPUPS));
	HMENU menu = GetSubMenu(mainMenu, 1);
	POINT pt; GetCursorPos(&pt);
	if (GetOwnerTree() && GetOwnerTree()->GetWindowParent())
		TrackPopupMenu(menu, TPM_LEFTALIGN|TPM_RIGHTBUTTON, pt.x, pt.y, 0, GetOwnerTree()->GetWindowParent()->mWnd, NULL);	
	DestroyMenu(mainMenu);
}
void OMacBrowserProjectItem::OnKeyDown(NDword inKey)
{
	switch(inKey)
	{
	case VK_RETURN:
		OnCommand(ID_MAC_PROJECT_EXPAND);
		break;
	case VK_DELETE:
		OnCommand(ID_MAC_PROJECT_DELETE);
		break;
	}
}

/*
	OMacBrowserFolderItem
*/
void OMacBrowserFolderItem::RefreshTree(CCorString& inFullPath, CCorString& inPartialPath)
{
	OWinTreeView* tree = GetOwnerTree();
	if (!tree)
		return;
	
	for (TObjIter<OWinTreeViewItem> tvi(this); tvi; tvi++)
		tvi->Destroy();

	SetText(STR_FileRoot(*inFullPath));
	if (tree->GetImageList())
		SetImage(tree->GetImageList()->FindImage(IDB_FILE_CLOSED));

	inFullPath += "\\";

	NChar* fileName;
	NInt isDir;

	// add all subfolders
	fileName = STR_FileFind(*(inFullPath + "*.*"), &isDir, NULL);
	while (fileName)
	{
		if (!isDir)
		{
			fileName = STR_FileFind(NULL, &isDir, NULL);
			continue;
		}
		STR_FileFindPushState();
					
		OMacBrowserFolderItem* item = OMacBrowserFolderItem::New(this);
		item->Init(tree, STR_FileRoot(fileName), NULL);
		item->RefreshTree(CCorString(fileName), CCorString(inPartialPath + STR_FileRoot(fileName) + "\\"));
		
		STR_FileFindPopState();
		fileName = STR_FileFind(NULL, &isDir, NULL);
	}

	// add all projects
	fileName = STR_FileFind(*(inFullPath + "*.cpj"), &isDir, NULL);
	while (fileName)
	{
		if (isDir)
		{
			fileName = STR_FileFind(NULL, &isDir, NULL);
			continue;
		}
		
		OMacBrowserProjectItem* item = OMacBrowserProjectItem::New(this);
		item->Init(tree, *(CCorString(STR_FileRoot(fileName)) + "." + STR_FileExtension(fileName)), NULL);
		item->mProjectPath = inPartialPath + STR_FileRoot(fileName) + "." + STR_FileExtension(fileName);
		item->mProject = NULL;
		if (tree->GetImageList())
			item->SetImage(tree->GetImageList()->FindImage(IDB_CPJ_CPJ));
		fileName = STR_FileFind(NULL, &isDir, NULL);
	}
}

NBool OMacBrowserFolderItem::OnCommand(NDword inCmdID)
{
	switch(inCmdID)
	{
	case ID_MAC_FOLDER_USE_FRAMES:
		{
			CCorString path(GetName());
			for (OWinTreeViewItem* item = GetItemParent(); item && item->GetItemParent(); item = item->GetItemParent())
				path = CCorString(item->GetName()) + "\\" + path;
			path += "\\*.cpj";
			if (GetOwnerDialog() && GetOwnerDialog()->mActor)
			{
				GetOwnerDialog()->mActor->Msgf("AddFrames \"%s\"", *path);
				GetOwnerDialog()->ActorRefresh();
			}
		}
		break;
	case ID_MAC_FOLDER_USE_SEQUENCES:
		{
			CCorString path(GetName());
			for (OWinTreeViewItem* item = GetItemParent(); item && item->GetItemParent(); item = item->GetItemParent())
				path = CCorString(item->GetName()) + "\\" + path;
			path += "\\*.cpj";
			if (GetOwnerDialog() && GetOwnerDialog()->mActor)
			{
				GetOwnerDialog()->mActor->Msgf("AddSequences \"%s\"", *path);
				GetOwnerDialog()->ActorRefresh();
			}
		}
		break;
	case ID_MAC_FOLDER_RENAME:
		{
			if (!GetItemParent())
			{
				MessageBox(GetOwnerDialog() ? GetOwnerDialog()->mWnd : NULL, "This is the base project folder and cannot be renamed.", "Rename Folder", MB_OK);
				break;
			}

			// check drive type to make sure this should be permitted
			const NChar* drivePath = CPJ_GetBasePath();
			if (drivePath && (strlen(drivePath)>1) && drivePath[1]==':')
			{
				static char buf[3];
				buf[0]=drivePath[0];
				buf[1]=drivePath[1];
				buf[2]='\\';
				drivePath = buf;
			}
			else
			{
				drivePath = NULL;
			}
			NDword dtype = GetDriveType(drivePath);
			if (dtype == DRIVE_REMOTE)
			{
				MessageBox(GetOwnerDialog() ? GetOwnerDialog()->mWnd : NULL, "Cannot rename folders on remote/network drives", "Rename Folder", MB_OK);
				break;
			}
			if (dtype == DRIVE_CDROM)
			{
				MessageBox(GetOwnerDialog() ? GetOwnerDialog()->mWnd : NULL, "Cannot rename folders on CD-ROM drives", "Rename Folder", MB_OK);
				break;
			}
			
			NChar* name;
			if (name = WIN_InputBox("Rename Folder", GetName(), "Please enter the new name:"))
			{
				CCorString path(GetName());
				for (OWinTreeViewItem* item = GetItemParent(); item && item->GetItemParent(); item = item->GetItemParent())
					path = CCorString(item->GetName()) + "\\" + path;
				path = CCorString(CPJ_GetBasePath()) + path;
				CCorString path2(STR_FilePath(*path));
				path2 += name;
				if (!rename(*path, *path2))
				{
					SetText(name);
					if (GetOwnerDialog())
						GetOwnerDialog()->ActorRefresh();
				}
			}
		}
		break;
	case ID_MAC_FOLDER_DELETE:
		{
			if (!GetItemParent())
			{
				MessageBox(GetOwnerDialog() ? GetOwnerDialog()->mWnd : NULL, "This is the base project folder and cannot be deleted.", "Delete Folder", MB_OK);
				break;
			}

			// check drive type to make sure this should be permitted
			const NChar* drivePath = CPJ_GetBasePath();
			if (drivePath && (strlen(drivePath)>1) && drivePath[1]==':')
			{
				static char buf[3];
				buf[0]=drivePath[0];
				buf[1]=drivePath[1];
				buf[2]='\\';
				drivePath = buf;
			}
			else
			{
				drivePath = NULL;
			}
			NDword dtype = GetDriveType(drivePath);
			if (dtype == DRIVE_REMOTE)
			{
				MessageBox(GetOwnerDialog() ? GetOwnerDialog()->mWnd : NULL, "Cannot delete folders on remote/network drives", "Delete Folder", MB_OK);
				break;
			}
			if (dtype == DRIVE_CDROM)
			{
				MessageBox(GetOwnerDialog() ? GetOwnerDialog()->mWnd : NULL, "Cannot delete folders on CD-ROM drives", "Delete Folder", MB_OK);
				break;
			}
			
			CCorString desc = CCorString("This will delete the folder \"") + GetName() + "\" and all of its contents.\n\nAre you sure you want to delete this?";
			if (MessageBox(GetOwnerDialog() ? GetOwnerDialog()->mWnd : NULL, *desc, "Delete Folder", MB_YESNO)==IDYES)
			{
				CCorString path(GetName());
				for (OWinTreeViewItem* item = GetItemParent(); item && item->GetItemParent(); item = item->GetItemParent())
					path = CCorString(item->GetName()) + "\\" + path;
				path = CCorString(CPJ_GetBasePath()) + path;
				FILE_Deltree(*path);
				if (GetOwnerDialog())
					GetOwnerDialog()->ActorRefresh();
				Destroy();
			}
		}
		break;
	case ID_MAC_FOLDER_NEW_FOLDER:
		{
			NChar* name;
			if (name = WIN_InputBox("New Folder", "MyFolder", "Please enter the name of the new folder:"))
			{
				CCorString path(STR_FileRoot(name));
				for (OWinTreeViewItem* item = this; item && item->GetItemParent(); item = item->GetItemParent())
					path = CCorString(item->GetName()) + "\\" + path;
				path = CCorString(CPJ_GetBasePath()) + path;
				if (GetOwnerTree() && (!_mkdir(*path)))
				{
					OMacBrowserFolderItem* item = OMacBrowserFolderItem::New(this);
					item->Init(GetOwnerTree(), STR_FileRoot(name), NULL);
					if (GetOwnerTree()->GetImageList())
						item->SetImage(GetOwnerTree()->GetImageList()->FindImage(IDB_FILE_CLOSED));
				}
			}
		}
		break;
	case ID_MAC_FOLDER_NEW_PROJECT:
		{
			NChar* name;
			if (name = WIN_InputBox("New Project", "Noname", "Please enter the name of the new project:"))
			{
				CCorString path(STR_FileRoot(name));
				for (OWinTreeViewItem* item = this; item && item->GetItemParent(); item = item->GetItemParent())
					path = CCorString(item->GetName()) + "\\" + path;
				OCpjProject* prj = OCpjProject::New(NULL);
				path = CCorString(CPJ_GetBasePath()) + path + "." + prj->GetFileExtension();
				if (GetOwnerTree())
				{
					prj->SetFileName(*path);
					OMacBrowserProjectItem* item = OMacBrowserProjectItem::New(this);
					item->Init(GetOwnerTree(), *(CCorString(STR_FileRoot(name)) + "." + prj->GetFileExtension()), NULL);
					item->mProjectPath = prj->GetFileName();
					item->mProject = prj;
					if (GetOwnerTree()->GetImageList())
						item->SetImage(GetOwnerTree()->GetImageList()->FindImage(IDB_CPJ_CPJ));
				}
				else
				{
					prj->Destroy();
				}
			}
		}
		break;
	default:
		break;
	}
	return(0);
}
void OMacBrowserFolderItem::OnRightClick()
{
	HMENU mainMenu = LoadMenu((HINSTANCE)KRN_GetModuleHandle(), MAKEINTRESOURCE(IDM_MAC_TREEPOPUPS));
	HMENU menu = GetSubMenu(mainMenu, 0);
	POINT pt; GetCursorPos(&pt);
	if (GetOwnerTree() && GetOwnerTree()->GetWindowParent())
		TrackPopupMenu(menu, TPM_LEFTALIGN|TPM_RIGHTBUTTON, pt.x, pt.y, 0, GetOwnerTree()->GetWindowParent()->mWnd, NULL);
	DestroyMenu(mainMenu);
}
void OMacBrowserFolderItem::OnExpand()
{
	OWinTreeView* tree = GetOwnerTree();
	if (!tree || !tree->GetImageList())
		return;
	SetImage(tree->GetImageList()->FindImage(IDB_FILE_OPEN));
}
void OMacBrowserFolderItem::OnCollapse()
{
	OWinTreeView* tree = GetOwnerTree();
	if (!tree || !tree->GetImageList())
		return;
	SetImage(tree->GetImageList()->FindImage(IDB_FILE_CLOSED));
}
void OMacBrowserFolderItem::OnKeyDown(NDword inKey)
{
	switch(inKey)
	{
	case VK_DELETE:
		OnCommand(ID_MAC_FOLDER_DELETE);
		break;
	}
}

//****************************************************************************
//**
//**    END MODULE MACEDIT.CPP
//**
//****************************************************************************

