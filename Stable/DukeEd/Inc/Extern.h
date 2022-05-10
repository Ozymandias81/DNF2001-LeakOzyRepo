/*=============================================================================
	Extern.h: External declarations that we need to communicate with editor.dll
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall
=============================================================================*/

__declspec(dllimport) void __stdcall NE_EdInit( HWND hInWndMain, HWND hInWndCallback );
__declspec(dllimport) FStringOutputDevice* GetPropResult;
CORE_API extern DWORD GCurrentViewport;

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
