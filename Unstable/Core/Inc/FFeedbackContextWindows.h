/*=============================================================================
	FFeedbackContextWindows.h: Unreal Windows user interface interaction.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

/*-----------------------------------------------------------------------------
	FFeedbackContextWindows.
-----------------------------------------------------------------------------*/

//
// Feedback context.
//
class FFeedbackContextWindows : public FFeedbackContext
{
public:
	// Variables.
	INT SlowTaskCount;
	DWORD hWndProgressBar, hWndProgressText, hWndProgressDlg, hWndMapErrorsDlg;

	// Constructor.
	FFeedbackContextWindows()
	: SlowTaskCount( 0 )
	, hWndProgressBar( 0 )
	, hWndProgressText( 0 )
	, hWndProgressDlg( 0 )
	, hWndMapErrorsDlg( 0 )
	{}
	void Serialize( const TCHAR* V, EName Event )
	{
		if( Event==NAME_UserPrompt && (GIsClient || GIsEditor) )
			::MessageBox( NULL, V, LocalizeError("Warning",TEXT("Core")), MB_OK|MB_TASKMODAL );
		else
			debugf( NAME_Warning, TEXT("%s"), V );
	}
	UBOOL YesNof( const TCHAR* Fmt, ... )
	{
		TCHAR TempStr[4096];
		GET_VARARGS( TempStr, ARRAY_COUNT(TempStr), Fmt );

		if( GIsClient || GIsEditor )
			return( ::MessageBox( NULL, TempStr, LocalizeError("Question",TEXT("Core")), MB_YESNO|MB_TASKMODAL ) == IDYES);
		else
			return 0;
	}
	void MapErrors_Show()
	{
		SendMessageX( (HWND)hWndMapErrorsDlg, WM_COMMAND, WM_ME_SHOW, 0L );
	}
	void MapErrors_Clear()
	{
		SendMessageX( (HWND)hWndMapErrorsDlg, WM_COMMAND, WM_ME_CLEAR, 0L );
	}
	void MapErrors_Add( UBOOL InError, void* InActor, const TCHAR* InMessage )
	{
		MAPERROR MapError;
		MapError.bError = InError;
		MapError.Actor = (AActor*)InActor;
		MapError.Message = InMessage;
		SendMessageX( (HWND)hWndMapErrorsDlg, WM_COMMAND, WM_ME_ADD, (LPARAM)&MapError );
	}
	void BeginSlowTask( const TCHAR* Task, UBOOL StatusWindow, UBOOL Cancelable )
	{
		::ShowWindow( (HWND)hWndProgressDlg, SW_SHOW );
		if( hWndProgressBar && hWndProgressText )
		{
			SendMessageLX( (HWND)hWndProgressText, WM_SETTEXT, (WPARAM)0, Task );
			SendMessageX( (HWND)hWndProgressBar, PBM_SETRANGE, (WPARAM)0, MAKELPARAM(0, 100) );

			UpdateWindow( (HWND)hWndProgressDlg );
			UpdateWindow( (HWND)hWndProgressText );
			UpdateWindow( (HWND)hWndProgressText );

			{	// flush all messages
				MSG mfm_msg;
				while(::PeekMessage(&mfm_msg, (HWND)hWndProgressDlg, 0, 0, PM_REMOVE))
				{
					TranslateMessage(&mfm_msg);
					DispatchMessage(&mfm_msg);
				}
			}
		}
		GIsSlowTask = ++SlowTaskCount>0;
	}
	void EndSlowTask()
	{
		check(SlowTaskCount>0);
		GIsSlowTask = --SlowTaskCount>0;
		if( !GIsSlowTask )
			::ShowWindow( (HWND)hWndProgressDlg, SW_HIDE );
	}
	UBOOL VARARGS StatusUpdatef( INT Numerator, INT Denominator, const TCHAR* Fmt, ... )
	{
		TCHAR TempStr[4096];
		GET_VARARGS( TempStr, ARRAY_COUNT(TempStr), Fmt );
		if( GIsSlowTask && hWndProgressBar && hWndProgressText )
		{
			SendMessageLX( (HWND)hWndProgressText, WM_SETTEXT, (WPARAM)0, TempStr );
			SendMessageX( (HWND)hWndProgressBar, PBM_SETPOS, (WPARAM)(Denominator ? 100*Numerator/Denominator : 0), (LPARAM)0 );
			UpdateWindow( (HWND)hWndProgressDlg );
			UpdateWindow( (HWND)hWndProgressText );
			UpdateWindow( (HWND)hWndProgressBar );

			{	// flush all messages
				MSG mfm_msg;
				while(::PeekMessage(&mfm_msg, (HWND)hWndProgressDlg, 0, 0, PM_REMOVE)) {
					TranslateMessage(&mfm_msg);
					DispatchMessage(&mfm_msg);
				}
			}
		}
		return 1;
	}
	void SetContext( FContextSupplier* InSupplier )
	{}
};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
