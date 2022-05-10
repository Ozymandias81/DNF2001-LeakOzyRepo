/*=============================================================================
	EdHook.cpp: UnrealEd VB hooks.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

Revision history:
	* Created by Tim Sweeney.
=============================================================================*/

// Includes.
#pragma warning( disable : 4201 )
#pragma warning( disable : 4310 )
#define STRICT
#include <windows.h>
#include <shlobj.h>
#include "EditorPrivate.h"
#include "Window.h"
#include "UnRender.h"
#include "DnMeshPrivate.h" // CDH
#include "..\..\Core\Inc\UnMsg.h"

// Thread exchange.
HANDLE			hEngineThreadStarted;
HANDLE			hEngineThread;
HWND			hWndEngine;
DWORD			EngineThreadId;
DLL_EXPORT FStringOutputDevice* GetPropResult;
const TCHAR*	GTopic;
const TCHAR*	GItem;
const TCHAR*	GValue;
TCHAR*			GCommand;

extern int GLastScroll;
extern FString GMapExt;

// Misc.
DWORD hWndCallback, hWndMain;
UEngine* Engine;

// Memory allocator.
#include "FMallocWindows.h"
FMallocWindows Malloc;

// Log file.
#include "FOutputDeviceFile.h"
FOutputDeviceFile Log;

// Error handler.
#include "FOutputDeviceWindowsError.h"
FOutputDeviceWindowsError Error;

// Feedback.
#include "FFeedbackContextWindows.h"
FFeedbackContextWindows Warn;

// File manager.
//#include "FFileManagerWindows.h"
//FFileManagerWindows FileManager;
#include <stdio.h>
#include <io.h>
#include <direct.h>
#include <errno.h>
#include <sys/stat.h>
#include "FFileManagerAnsi.h"
FFileManagerAnsi FileManager;

// Config.
#include "FConfigCacheIni.h"

/*-----------------------------------------------------------------------------
	Engine init.
-----------------------------------------------------------------------------*/

#define IDDIALOG_Splash 0

/*-----------------------------------------------------------------------------
	Editor hook exec.
-----------------------------------------------------------------------------*/
EXECVAR(UBOOL, editor_allproperties, 0); // show all class/object properties in the editor, not just editable ones (i.e. add the "None" category)

void UEditorEngine::NotifyDestroy( void* Src )
{
	if( Src==ActorProperties )	ActorProperties = NULL;
	if( Src==LevelProperties )	LevelProperties = NULL;
	if( Src==Preferences )		Preferences = NULL;
	if( Src==UseDest )			UseDest = NULL;
}
void UEditorEngine::NotifyPreChange( void* Src )
{
	Trans->Begin( TEXT("Edit Properties") );
}
void UEditorEngine::NotifyPostChange( void* Src )
{
	Trans->End();
	if( Src==Preferences )
	{
		GCache.Flush();
		for( TObjectIterator<UViewport> It; It; ++It )
			It->Actor->FovAngle = FovAngle;
	}
	RedrawLevel( Level );
}
AUTOREGISTER_TOPIC(TEXT("Obj"),ObjTopicHandler);
void ObjTopicHandler::Get( ULevel* Level, const TCHAR* Item, FOutputDevice& Ar )
{
	if( ParseCommand(&Item,TEXT("QUERY")) )
	{
		UClass* Class;
		if( ParseObject<UClass>(Item,TEXT("TYPE="),Class,ANY_PACKAGE) )
		{
			UPackage* BasePackage;
			UPackage* RealPackage;
			TArray<UObject*> Results;
			if( !ParseObject<UPackage>( Item, TEXT("PACKAGE="), BasePackage, NULL ) )
			{
				// Objects in any package.
				for( FObjectIterator It; It; ++It )
					if( It->IsA(Class) )
						Results.AddItem( *It );
			}
			else if( !ParseObject<UPackage>( Item, TEXT("GROUP="), RealPackage, BasePackage ) )
			{
				// All objects beneath BasePackage.
				for( FObjectIterator It; It; ++It )
					if( It->IsA(Class) && It->IsIn(BasePackage) )
						Results.AddItem( *It );
			}
			else
			{
				// All objects within RealPackage.
				for( FObjectIterator It; It; ++It )
					if( It->IsA(Class) && It->IsIn(RealPackage) )
						Results.AddItem( *It );
			}
			for( INT i=0; i<Results.Num(); i++ )
			{
				if( i )
					Ar.Log( TEXT(" ") );
				Ar.Log( Results(i)->GetName() );
			}
		}
	}
	else if( ParseCommand(&Item,TEXT("PACKAGES")) )
	{
		UClass* Class;
		if( ParseObject<UClass>(Item,TEXT("CLASS="),Class,ANY_PACKAGE) )
		{
			TArray<UObject*> List;
			for( FObjectIterator It; It; ++It )
			{
				if( It->IsA(Class) && It->GetOuter()!=UObject::GetTransientPackage() )
				{
					check(It->GetOuter());
					for( UObject* TopParent=It->GetOuter(); TopParent->GetOuter()!=NULL; TopParent=TopParent->GetOuter() );
					if( Cast<UPackage>(TopParent) )
						List.AddUniqueItem( TopParent );
				}
			}
			for( INT i=0; i<List.Num(); i++ )
			{
				if( i )
					Ar.Log( TEXT(",") );
				Ar.Log( List(i)->GetName() );
			}
		}
	}
	else if( ParseCommand(&Item,TEXT("DELETE")) )
	{
		//Ar.Logf(_T("Command Line:%s"),Item);
		UPackage* Pkg=ANY_PACKAGE;
		UClass*   Class;
		UObject*  Object;
		ParseObject<UPackage>( Item, TEXT("PACKAGE="), Pkg, NULL );
		if
		(	!ParseObject<UClass>( Item,TEXT("CLASS="), Class, ANY_PACKAGE )
		||	!ParseObject(Item,TEXT("OBJECT="),Class,Object,Pkg) )
			Ar.Logf( TEXT("Object not found") );
		else 
		{
			GEditor->CurrentTexture=NULL;	// NJS Was a test 
			if( UObject::IsReferenced( Object, RF_Native | RF_Public, 0 ) )
				Ar.Logf( TEXT("%s is in use"), Object->GetFullName() );
			else delete Object;
		}
	}
	else if( ParseCommand(&Item,TEXT("GROUPS")) )
	{
		UClass* Class;
		UPackage* Pkg;
		if
		(	ParseObject<UPackage>(Item,TEXT("PACKAGE="),Pkg,NULL)
		&&	ParseObject<UClass>(Item,TEXT("CLASS="),Class,ANY_PACKAGE) )
		{
			TArray<UObject*> List;
			for( FObjectIterator It; It; ++It )
				if( It->IsA(Class) && It->GetOuter() && It->GetOuter()->GetOuter()==Pkg )
					List.AddUniqueItem( It->GetOuter() );
			for( INT i=0; i<List.Num(); i++ )
			{
				if( i )
					Ar.Log( TEXT(",") );
				Ar.Log( List(i)->GetName() );
			}
		}
	}
	else if( ParseCommand(&Item,TEXT("BROWSECLASS")) )
	{
		Ar.Log( GEditor->BrowseClass->GetName() );
	}
}
void ObjTopicHandler::Set( ULevel* Level, const TCHAR* Item, const TCHAR* Data )
{
	if( ParseCommand(&Item,TEXT("NOTECURRENT")) )
	{
		UClass* Class;
		UObject* Object;
		if
		(	GEditor->UseDest
		&&  ParseObject<UClass>( Data, TEXT("CLASS="), Class, ANY_PACKAGE )
		&&	ParseObject( Data, TEXT("OBJECT="), Class, Object, ANY_PACKAGE ) )
		{
			LastUseObject = Object; // CDH
			TCHAR Temp[256];
			appSprintf( Temp, TEXT("%s'%s'"), Object->GetClass()->GetName(), Object->GetName() );
			GEditor->UseDest->SetValue( Temp );
		}
	}
}
void UEditorEngine::NotifyExec( void* Src, const TCHAR* Cmd )
{
	if( ParseCommand(&Cmd,TEXT("BROWSECLASS")) )
	{
		ParseObject( Cmd, TEXT("CLASS="), BrowseClass, ANY_PACKAGE );
		UseDest = (WProperties*)Src;
		EdCallback( EDC_Browse, 1 );
	}
	else if( ParseCommand(&Cmd,TEXT("USECURRENT")) )
	{
		ParseObject( Cmd, TEXT("CLASS="), BrowseClass, ANY_PACKAGE );
		UseDest = (WProperties*)Src;
		EdCallback( EDC_UseCurrent, 1 );
	}
}
void UEditorEngine::UpdatePropertiesWindows()
{
	if( ActorProperties )
	{
		TArray<UObject*> SelectedActors;
		for( INT i=0; i<Level->Actors.Num(); i++ )
			if( Level->Actors(i) && Level->Actors(i)->bSelected )
			{
				SelectedActors.AddItem( Level->Actors(i) );
				if(Level->Actors(i)->IsA(ALight::StaticClass()))
				{
					Level->Actors(i)->bLightChanged = 1;
					Level->Actors(i)->bDynamicLight = 1;
				}

			}
		ActorProperties->Root.SetObjects( &SelectedActors(0), SelectedActors.Num() );
	}
	for( INT i=0; i<WProperties::PropertiesWindows.Num(); i++ )
	{
		WProperties* Properties=WProperties::PropertiesWindows(i);
		if( Properties!=ActorProperties && Properties!=Preferences )
			Properties->ForceRefresh();
	}
}
UBOOL UEditorEngine::HookExec( const TCHAR* Cmd, FOutputDevice& Ar )
{
	if( ParseCommand(&Cmd,TEXT("PLAYMAP")) )
	{
		EdCallback( EDC_ViewportsDisableRealtime, 1 );
		ShowWindow((HWND)hWndMain,SW_MINIMIZE);
		Sleep(0);
		//EdCallback( EDC_FlushAllViewports, 1);

		TCHAR Parms[256];
		Exec( TEXT("MAP SAVE FILE=..\\Maps\\Autoplay.dnf"), Ar );
		appSprintf( Parms, TEXT("Autoplay.dnf HWND=%i %s"), (INT)hWndMain, GameCommandLine );
		appLaunchURL( TEXT("DukeForever.exe"), Parms );
		//appSprintf( Parms, TEXT("Autoplay.dnf %s"), GameCommandLine );
		//appLaunchURL( TEXT("DukeForever.exe"), Parms );
		//Sleep(2500);
		//while(!FindWindow(NULL,_T("Duke Nukem")))
		//{
		//	Sleep(1000);
		//}
		//Sleep(0);
		//ShowWindow((HWND)hWndMain,SW_MAXIMIZE);

		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("APP")) )
	{
		if( ParseCommand(&Cmd,TEXT("SET")) )
		{
			Parse( Cmd, TEXT("PROGRESSBAR="),  Warn.hWndProgressBar );
			Parse( Cmd, TEXT("PROGRESSTEXT="), Warn.hWndProgressText );
			Parse( Cmd, TEXT("PROGRESSDLG="), Warn.hWndProgressDlg );
			Parse( Cmd, TEXT("MAPERRORSDLG="), Warn.hWndMapErrorsDlg );
			return 1;
		}
		else return 0;
	}
	else if( ParseCommand(&Cmd,TEXT("ACTORPROPERTIES")) )
	{
		if( !ActorProperties )
		{
			ActorProperties = new WObjectProperties( TEXT("ActorProperties"), CPF_Edit, TEXT(""), NULL, 1 );
			ActorProperties->OpenWindow( (HWND)hWndMain );
			ActorProperties->SetNotifyHook( GEditor );
		}
		UpdatePropertiesWindows();
		ActorProperties->Show(1);
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("PREFERENCES")) )
	{
		if( !Preferences )
		{
			Preferences = new WConfigProperties( TEXT("Preferences"), LocalizeGeneral("AdvancedOptionsTitle",TEXT("Window")) );
			Preferences->OpenWindow( (HWND)hWndMain );
			Preferences->SetNotifyHook( GEditor );
			Preferences->ForceRefresh();
		}
		Preferences->Show(1);
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("LEVELPROPERTIES")) )
	{
		if( !LevelProperties )
		{
			LevelProperties = new WObjectProperties( TEXT("LevelProperties"), CPF_Edit, TEXT("Level Properties"), NULL, 1 );
			LevelProperties->OpenWindow( (HWND)hWndMain );
			LevelProperties->SetNotifyHook( GEditor );
		}
		LevelProperties->Root.SetObjects( (UObject**)&Level->Actors(0), 1 );
		LevelProperties->Show(1);
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("TEXTUREPROPERTIES")) )
	{
		UTexture* Texture;
		if( ParseObject<UTexture>( Cmd, TEXT("TEXTURE="), Texture, ANY_PACKAGE ) )
		{
			TCHAR Title[256];
			appSprintf( Title, TEXT("Texture %s"), Texture->GetPathName() );
			WObjectProperties* TextureProperties = new WObjectProperties( TEXT("TextureProperties"), CPF_Edit, Title, NULL, 1 );
			TextureProperties->OpenWindow( (HWND)hWndMain );
			TextureProperties->Root.SetObjects( (UObject**)&Texture, 1 );
			TextureProperties->SetNotifyHook( GEditor );
			TextureProperties->Show(1);
		}
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("CLASSPROPERTIES")) )
	{
		UClass* Class;
		if( ParseObject<UClass>( Cmd, TEXT("Class="), Class, ANY_PACKAGE ) )
		{
			TCHAR Title[256];
			appSprintf( Title, TEXT("Default %s Properties"), Class->GetPathName() );
			WClassProperties* ClassProperties = new WClassProperties( TEXT("ClassProperties"), CPF_Edit, Title, Class );
			ClassProperties->OpenWindow( (HWND)hWndMain );
			ClassProperties->SetNotifyHook( GEditor );
			ClassProperties->ForceRefresh();
			ClassProperties->Show(1);
		}
		return 1;
	}
	return 0;
}

/*-----------------------------------------------------------------------------
	UnrealEd 2
-----------------------------------------------------------------------------*/
void UEditorEngine::EdCallback( DWORD Code, UBOOL Send )
{
	if( hWndCallback )
	{
		int Msg = 0;

		switch( Code )
		{
			case EDC_Browse:					Msg = WM_EDC_BROWSE;					break;
			case EDC_UseCurrent:				Msg = WM_EDC_USECURRENT;				break;
			case EDC_CurTexChange:				Msg = WM_EDC_CURTEXCHANGE;				break;
			case EDC_SelPolyChange:				Msg = WM_EDC_SELPOLYCHANGE;				break;
			case EDC_SelChange:					Msg = WM_EDC_SELCHANGE;					break;
			case EDC_RtClickTexture:			Msg = WM_EDC_RTCLICKTEXTURE;			break;
			case EDC_RtClickPoly:				Msg = WM_EDC_RTCLICKPOLY;				break;
			case EDC_RtClickActor:				Msg = WM_EDC_RTCLICKACTOR;				break;
			case EDC_RtClickWindow:				Msg = WM_EDC_RTCLICKWINDOW;				break;
			case EDC_RtClickWindowCanAdd:		Msg = WM_EDC_RTCLICKWINDOWCANADD;		break;
			case EDC_MapChange:					Msg = WM_EDC_MAPCHANGE;					break;
			case EDC_ViewportUpdateWindowFrame:	Msg = WM_EDC_VIEWPORTUPDATEWINDOWFRAME;	break;
			case EDC_SurfProps:					Msg = WM_EDC_SURFPROPS;					break;
			case EDC_SaveMap:					Msg = WM_EDC_SAVEMAP;					break;
			case EDC_SaveMapAs:					Msg = WM_EDC_SAVEMAPAS;					break;
			case EDC_LoadMap:					Msg = WM_EDC_LOADMAP;					break;
			case EDC_PlayMap:					Msg = WM_EDC_PLAYMAP;					break;
			case EDC_CamModeChange:				Msg = WM_EDC_CAMMODECHANGE;				break;
			case EDC_RedrawAllViewports:		Msg = WM_REDRAWALLVIEWPORTS;			break;
			case EDC_ViewportsDisableRealtime:	Msg = WM_EDC_VIEWPORTSDISABLEREALTIME;	break;
			case EDC_MasterBrowser:				Msg = WM_EDC_MASTERBROWSER;				break;
			case EDC_ConfirmDelete:				Msg = WM_EDC_CONFIRMDELETE;				break;
			case EDC_FlushAllViewports:			Msg = WM_EDC_FLUSHALLVIEWPORTS; 		break;
		}
		if( Msg )
		{
			if( Send ) 
			{
				// NJS: a 7 second timeout added here to help resolve deadlocks.
				DWORD Bogus;
				SendMessageTimeout((HWND)hWndCallback,WM_COMMAND,Msg,0,SMTO_ABORTIFHUNG/*|SMTO_NOTIMEOUTIFNOTHUNG*/,7000,&Bogus);
 
				//SendMessageX( (HWND)hWndCallback, WM_COMMAND, Msg, 0 );
			} else PostMessageX( (HWND)hWndCallback, WM_COMMAND, Msg, 0 );
		}
	}
}

// This function executes stuff that used to happen in ThreadEntry.
__declspec(dllexport) void __stdcall NE_EdInit( HWND hInWndMain, HWND hInWndCallback )
{
	try
	{
		if (!GetPropResult)
			GetPropResult = new FStringOutputDevice;
		hWndMain     = (DWORD)hInWndMain;
		hWndCallback = (DWORD)hInWndCallback;
	}
	catch(...)
	{
		Error.HandleError();
		appRequestExit( 1 );
	}

}

/*-----------------------------------------------------------------------------
	The end.
-----------------------------------------------------------------------------*/
