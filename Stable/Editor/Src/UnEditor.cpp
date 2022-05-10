/*=============================================================================
	UnEditor.cpp: Unreal editor main file
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/
#include <windows.h>
#include <mmsystem.h>

#pragma comment(lib,"winmm.lib")

#include "EditorPrivate.h"
#include "UnRender.h"


/*-----------------------------------------------------------------------------
	Globals.
-----------------------------------------------------------------------------*/

EDITOR_API class UEditorEngine* GEditor;

/*-----------------------------------------------------------------------------
	UEditorEngine.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(UEditorEngine);

/*-----------------------------------------------------------------------------
	UnrealEd Options.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(UOptionsProxy);
IMPLEMENT_CLASS(UOptionsBrushScale);
IMPLEMENT_CLASS(UOptionsTexAlign);
IMPLEMENT_CLASS(UOptionsTexAlignFace);
IMPLEMENT_CLASS(UOptionsTexAlignPlanar);
IMPLEMENT_CLASS(UOptions2DShaper);
IMPLEMENT_CLASS(UOptions2DShaperExtrude);
IMPLEMENT_CLASS(UOptions2DShaperExtrudeToPoint);
IMPLEMENT_CLASS(UOptions2DShaperExtrudeToBevel);
IMPLEMENT_CLASS(UOptions2DShaperSheet);
IMPLEMENT_CLASS(UOptions2DShaperRevolve);
IMPLEMENT_CLASS(UOptions2DShaperBezierDetail);
IMPLEMENT_CLASS(UOptionsSurfBevel);

/*-----------------------------------------------------------------------------
	Init & Exit.
-----------------------------------------------------------------------------*/

//
// Construct the UEditorEngine class.
//
void UEditorEngine::StaticConstructor()
{
	UArrayProperty* A = new(GetClass(),TEXT("EditPackages"),RF_Public)UArrayProperty( CPP_PROPERTY(EditPackages), TEXT("Advanced"), CPF_Config );
	A->Inner = new(A,TEXT("StrProperty0"),RF_Public)UStrProperty;
}

//
// Construct the editor.
//
UEditorEngine::UEditorEngine()
: EditPackages( E_NoInit )
{}

//
// Editor early startup.
//
void UEditorEngine::InitEditor()
{
	// Init names.
	#define NAMES_ONLY
	#define AUTOGENERATE_NAME(name) extern EDITOR_API FName EDITOR_##name; EDITOR_##name=FName(TEXT(#name),FNAME_Intrinsic);
	#define AUTOGENERATE_FUNCTION(cls,idx,name)
	#include "EditorClasses.h"
	#undef DECLARE_NAME
	#undef NAMES_ONLY

	// Call base.
	UEngine::Init();
	InitAudio();

	// Topics.
	GTopics.Init();

	// Make sure properties match up.
	VERIFY_CLASS_OFFSET(A,Actor,Owner);
	VERIFY_CLASS_OFFSET(A,PlayerPawn,Player);

	// Allocate temporary model.
	TempModel = new UModel( NULL, 1 );

	// Settings.
	Mode			= EM_None;
	MovementSpeed	= 4.0;
	FastRebuild		= 0;
	Bootstrapping	= 0;
	LockMeshView	= 1;
}

//
// Init the editor.
//
void UEditorEngine::Init()
{
	// Init editor.
	GEditor = this;
	InitEditor();

	// Init transactioning.
	Trans = CreateTrans();

	// Load classes for editing.
	BeginLoad();
	for( INT i=0; i<EditPackages.Num(); i++ )
		if( !LoadPackage( NULL, *EditPackages(i), LOAD_NoWarn ) )
				appErrorf( TEXT("Can't find edit package '%s'"), *EditPackages(i) );
	EndLoad();

	// Init the client.
	UClass* ClientClass = StaticLoadClass( UClient::StaticClass(), NULL, TEXT("ini:Engine.Engine.ViewportManager"), NULL, LOAD_NoFail, NULL );
	Client = (UClient*)StaticConstructObject( ClientClass );
	Client->Init( this );
	check(Client);

	// Checks.
	VERIFY_CLASS_OFFSET(U,EditorEngine,ParentContext);
	//!!if( sizeof(*this) !=GetClass()->GetPropertiesSize() )
	//	appErrorf( "Editor size mismatch: C++ %i / UnrealScript %i", sizeof(*this), GetClass()->GetPropertiesSize() );
	//!!check(sizeof(*this)==GetClass()->GetPropertiesSize());

	// Init rendering.
	UClass* RenderClass = URender::StaticClass(); //LoadClass<URenderBase>( NULL, TEXT("ini:Engine.Engine.Render"), NULL, LOAD_NoFail, NULL );
	Render = (URender*)StaticConstructObject( RenderClass );
	Render->Init( this );

	// Set editor mode.
	edcamSetMode( EM_ViewportMove );

	// Info.
	UPackage* LevelPkg = CreatePackage( NULL, TEXT("MyLevel") );
	Level = new( LevelPkg, TEXT("MyLevel") )ULevel( this, 0 );

	// Objects.
	Cylinder = new UPrimitive;
	Results  = new( GetTransientPackage(), TEXT("Results") )UTextBuffer;

	// Purge garbage.
	Cleanse( 0, TEXT("startup") );

	// Subsystem init messsage.
	debugf( NAME_Init, TEXT("Editor engine initialized") ); 
};
void UEditorEngine::Destroy()
{
	// Shut down transaction tracking system.
	if( Trans )
	{
		if( GUndo )
			debugf( NAME_Warning, TEXT("Warning: A transaction is active") );
		Trans->Reset( TEXT("shutdown") );
	}

	// Topics.
	GTopics.Exit();
	Level = NULL;

	// Remove editor array from root.
	debugf( NAME_Exit, TEXT("Editor shut down") );

	Super::Destroy();
}
void UEditorEngine::Serialize( FArchive& Ar )
{
	Super::Serialize(Ar);
	Ar << Tools;
}
void UEditorEngine::RedrawLevel( ULevel* Level )
{
	if( Client && !ParentContext )
		for( INT i=0; i<Client->Viewports.Num(); i++ )
			if( Client->Viewports(i)->Actor->GetLevel()==Level || Level==NULL )
				Client->Viewports(i)->Repaint( 1 );
}
void UEditorEngine::ResetSound()
{
	if( Audio )
		for( int i=0; i<Client->Viewports.Num(); i++ )
			if( appStricmp(Client->Viewports(i)->GetName(), TEXT("Standard3V"))==0 )
				Audio->SetViewport( Client->Viewports(i) );
}

/*-----------------------------------------------------------------------------
	Tick.
-----------------------------------------------------------------------------*/

//
// Time passes...
//
void __fastcall UEditorEngine::Tick( float DeltaSeconds )
{
	// Update subsystems.
	StaticTick();				
	GCache.Tick();

	// Find active realtime camera.
	UViewport* RealtimeViewport = NULL;
	for( INT i=0; i<Client->Viewports.Num(); i++ )
	{
		UViewport* Viewport = Client->Viewports(i);
		if( Viewport->Current && Viewport->IsRealtime() )
			RealtimeViewport = Viewport;
	}

	// Update the level.
	if( Level )
		Level->Tick( RealtimeViewport ? LEVELTICK_ViewportsOnly : LEVELTICK_TimeOnly, DeltaSeconds );

	// Update audio.
	if( Audio )
	{
		clock(Level->AudioTickCycles);
		UViewport* AudioViewport = FindObject<UViewport>( ANY_PACKAGE, TEXT("Standard3V") );
		FCoords C = GMath.ViewCoords;
		FPointRegion Region(NULL);
		if( AudioViewport )
		{
			C = C / AudioViewport->Actor->Rotation  / AudioViewport->Actor->Location;
			Region = AudioViewport->Actor->Region;
		}
		Audio->Update( Region, C );
		unclock(Level->AudioTickCycles);
	}

	// Render everything.
	if( Client )
		Client->Tick();
}

/*-----------------------------------------------------------------------------
	Garbage collection.
-----------------------------------------------------------------------------*/

//
// Clean up after a major event like loading a file.
//
void UEditorEngine::Cleanse( UBOOL Redraw, const TCHAR* TransReset )
{
	check(TransReset);
	if( GIsRunning && !Bootstrapping )
	{
		// Collect garbage.
		CollectGarbage( RF_Native | RF_Standalone );

		// Reset the transaction tracking system if desired.
		Trans->Reset( TransReset );

		// Flush the cache.
		GCache.Flush();

		// Redraw the levels.
		if( Redraw )
		{
			GEditor->LockMeshView = 1;
			RedrawLevel( Level );
			GEditor->LockMeshView = 0;
		}
	}
}

/*---------------------------------------------------------------------------------------
	Topics.
---------------------------------------------------------------------------------------*/

void UEditorEngine::Get( const TCHAR* Topic, const TCHAR* Item, FOutputDevice& Ar )
{
	GTopics.Get( Level, Topic, Item, Ar );
}
void UEditorEngine::Set( const TCHAR* Topic, const TCHAR* Item, const TCHAR* Value )
{
	GTopics.Set( Level, Topic, Item, Value );
}

/*---------------------------------------------------------------------------------------
	Link topics.
---------------------------------------------------------------------------------------*/

// Enum.
AUTOREGISTER_TOPIC(TEXT("Enum"),EnumTopicHandler);
void EnumTopicHandler::Get( ULevel* Level, const TCHAR* Item, FOutputDevice& Ar )
{
	UEnum* Enum = FindObject<UEnum>( ANY_PACKAGE, Item );
	if( Enum )
	{
		for( int i=0; i<Enum->Names.Num(); i++ )
		{
			if( i > 0 )
				Ar.Logf(TEXT(","));
			Ar.Logf( TEXT("%i - %s"), i, *Enum->Names(i) );
		}
	}
}
void EnumTopicHandler::Set( ULevel* Level, const TCHAR* Item, const TCHAR* Value )
{}

// Music.
AUTOREGISTER_TOPIC(TEXT("Music"),MusicTopicHandler);
void MusicTopicHandler::Get( ULevel* Level, const TCHAR* Item, FOutputDevice& Ar )
{
	if( ParseCommand(&Item,TEXT("FILETYPE")) )
	{
		TCHAR Name[NAME_SIZE];
		UPackage* Package=ANY_PACKAGE;
		ParseObject<UPackage>( Item, TEXT("PACKAGE="), Package, NULL );
		if( Parse( Item, TEXT("NAME="), Name, ARRAY_COUNT(Name) ) )
		{
			UMusic* Music = FindObject<UMusic>( Package, Name );
			if( Music )
				Ar.Log( *Music->FileType );
		}
	}
}
void MusicTopicHandler::Set( ULevel* Level, const TCHAR* Item, const TCHAR* Data )
{}

// Sound.
AUTOREGISTER_TOPIC(TEXT("Sound"),SoundTopicHandler);
void SoundTopicHandler::Get( ULevel* Level, const TCHAR* Item, FOutputDevice& Ar )
{
	if( ParseCommand(&Item,TEXT("FILETYPE")) )
	{
		TCHAR Name[NAME_SIZE];
		UPackage* Package=ANY_PACKAGE;
		ParseObject<UPackage>( Item, TEXT("PACKAGE="), Package, NULL );
		if( Parse( Item, TEXT("NAME="), Name, ARRAY_COUNT(Name) ) )
		{
			USound* Sound = FindObject<USound>( Package, Name );
			if( Sound )
				Ar.Log( *Sound->FileType );
		}
	}
}
void SoundTopicHandler::Set(ULevel *Level, const TCHAR* Item, const TCHAR* Data)
{}

// Text.
AUTOREGISTER_TOPIC(TEXT("Text"),TextTopicHandler);
void TextTopicHandler::Get( ULevel* Level, const TCHAR* Item, FOutputDevice& Ar )
{
	UTextBuffer* Text = FindObject<UTextBuffer>( ANY_PACKAGE, Item );
	if( Text && Text->Text.Len() )
		Ar.Log( *Text->Text );
}
void TextTopicHandler::Set( ULevel* Level, const TCHAR* Item, const TCHAR* Data )
{
	UTextBuffer* Text = FindObject<UTextBuffer>( ANY_PACKAGE, Item );
	if( Text )
	{
		Text->SetFlags( RF_SourceModified );
		Text->Text.Empty();
		Text->Log( Data );
	}
}

// Script.
AUTOREGISTER_TOPIC(TEXT("Script"),ScriptTopicHandler);
void ScriptTopicHandler::Get( ULevel* Level, const TCHAR* Item, FOutputDevice& Ar )
{
	UClass* Class = FindObject<UClass>( ANY_PACKAGE, Item );
	UTextBuffer* Text = Class ? Class->ScriptText : NULL;
	if( Text && Text->Text.Len() )
		Ar.Log( *Text->Text );
}
void ScriptTopicHandler::Set( ULevel* Level, const TCHAR* Item, const TCHAR* Data )
{
	UClass* Class = FindObject<UClass>( ANY_PACKAGE, Item );
	if( Class && Class->ScriptText )
	{
		if( appStrcmp( *Class->ScriptText->Text, Data ) )
		{
			Class->ScriptText->Text = Data;
			Class->SetFlags( RF_SourceModified );
		}
	}
}

// ScriptPos.
AUTOREGISTER_TOPIC(TEXT("ScriptPos"),ScriptPosTopicHandler);
void ScriptPosTopicHandler::Get( ULevel* Level, const TCHAR* Item, FOutputDevice& Ar )
{
	UClass* Class = FindObject<UClass>( ANY_PACKAGE, Item );
	UTextBuffer* Text = Class ? Class->ScriptText : NULL;
	if( Text )
		Ar.Logf( TEXT("%i"), Text->Pos );
}
void ScriptPosTopicHandler::Set( ULevel* Level, const TCHAR* Item, const TCHAR* Data )
{
	UClass* Class = FindObject<UClass>( ANY_PACKAGE, Item );
	UTextBuffer* Text = Class ? Class->ScriptText : NULL;
	if( Text ) Text->Pos = appAtoi(Data);
}


// ScriptTop.
AUTOREGISTER_TOPIC(TEXT("ScriptTop"),ScriptTopTopicHandler);
void ScriptTopTopicHandler::Get( ULevel* Level, const TCHAR* Item, FOutputDevice& Ar )
{
	UClass* Class = FindObject<UClass>( ANY_PACKAGE, Item );
	UTextBuffer* Text = Class ? Class->ScriptText : NULL;
	if( Text ) Ar.Logf(TEXT("%i"),Text->Top);
}
void ScriptTopTopicHandler::Set( ULevel* Level, const TCHAR* Item, const TCHAR* Data )
{
	UClass* Class = FindObject<UClass>( ANY_PACKAGE, Item );
	UTextBuffer* Text = Class ? Class->ScriptText : NULL;
	if( Text ) Text->Top = appAtoi(Data);
}

// Class.
int CDECL ClassSortCompare( const void *elem1, const void *elem2 )
{
	return appStricmp((*(UClass**)elem1)->GetName(),(*(UClass**)elem2)->GetName());
}
AUTOREGISTER_TOPIC( TEXT("Class"), ClassTopicHandler );
void ClassTopicHandler::Get( ULevel* Level, const TCHAR* Item, FOutputDevice& Ar )
{
	enum	{MAX_RESULTS=1024};
	int		NumResults = 0;
	UClass	*Results[MAX_RESULTS];

	if( ParseCommand(&Item,TEXT("PACKAGE")) )
	{
		UClass* Class = NULL;
		if( ParseObject<UClass>(Item,TEXT("CLASS="),Class,ANY_PACKAGE) )
			Ar.Log( Class->GetOuter()->GetName() );
	}
	else if( ParseCommand(&Item,TEXT("QUERY")) )
	{
		UClass *Parent = NULL;
		ParseObject<UClass>(Item,TEXT("PARENT="),Parent,ANY_PACKAGE);

		// Make a list of all child classes.
		for( TObjectIterator<UClass> It; It && NumResults<MAX_RESULTS; ++It )
			if( It->GetSuperClass()==Parent )
				Results[NumResults++] = *It;

		// Sort them by name.
		appQsort( Results, NumResults, sizeof(UClass*), ClassSortCompare );

		// Return the results.
		for( INT i=0; i<NumResults; i++ )
		{
			// See if this item has children.
			INT Children = 0;
			for( TObjectIterator<UClass> It; It; ++It )
				if( It->GetSuperClass()==Results[i] )
					Children++;

			// Add to result string.
			if( i>0 ) Ar.Log(TEXT(","));
			Ar.Logf
			(
				TEXT("%s%s|%s"),
				(	Results[i]->GetOuter()->GetFName()==NAME_Engine
				||	Results[i]->GetOuter()->GetFName()==NAME_UnrealI
				||	Results[i]->GetOuter()->GetFName()==NAME_Core) ? TEXT("*") : TEXT(""),
				Results[i]->GetName(),
				Children ? TEXT("C") : TEXT("X")
			);
		}
	}
	if( ParseCommand(&Item,TEXT("GETCHILDREN")) )
	{
		UClass *Parent = NULL;
		ParseObject<UClass>(Item,TEXT("CLASS="),Parent,ANY_PACKAGE);
		UBOOL Concrete=0; ParseUBOOL( Item, TEXT("CONCRETE="), Concrete );

		// Make a list of all child classes.
		for( TObjectIterator<UClass> It; It && NumResults<MAX_RESULTS; ++It )
			if( It->IsChildOf(Parent) && (!Concrete || !(It->ClassFlags & CLASS_Abstract)) )
				Results[NumResults++] = *It;

		// Sort them by name.
		appQsort( Results, NumResults, sizeof(UClass*), ClassSortCompare );

		// Return the results.
		for( int i=0; i<NumResults; i++ )
		{
			if( i>0 )
				Ar.Log( TEXT(" ") );
			Ar.Log( Results[i]->GetName() );
		}
	}
	else if( ParseCommand(&Item,TEXT("EXISTS")) )
	{
		UClass* Class;
		if (ParseObject<UClass>(Item,TEXT("NAME="),Class,ANY_PACKAGE)) Ar.Log(TEXT("1"));
		else Ar.Log(TEXT("0"));
	}
	else if( ParseCommand(&Item,TEXT("PACKAGE")) )
	{
		UClass *Class;
		if( ParseObject<UClass>( Item, TEXT("CLASS="), Class, ANY_PACKAGE ) )
			Ar.Log( Class->GetOuter()->GetName() );
	}
}
void ClassTopicHandler::Set( ULevel* Level, const TCHAR* Item, const TCHAR* Data )
{}

// Actor.
AUTOREGISTER_TOPIC(TEXT("Actor"),ActorTopicHandler);
void ActorTopicHandler::Get( ULevel* Level, const TCHAR* Item, FOutputDevice& Ar )
{
	// Summarize the level actors.
	int		 n			= 0;
	INT	    AnyClass	= 0;
	UClass*	AllClass	= NULL;
	for( int i=0; i<Level->Actors.Num(); i++ )
	{
		if( Level->Actors(i) && Level->Actors(i)->bSelected )
		{
			if( AnyClass && Level->Actors(i)->GetClass()!=AllClass ) 
				AllClass = NULL;
			else 
				AllClass = Level->Actors(i)->GetClass();
			AnyClass=1;
			n++;
		}
	}
	if( !appStricmp(Item,TEXT("NumSelected")) )
	{
		Ar.Logf( TEXT("%i"), n );
	}
	else if( !appStricmp(Item,TEXT("ClassSelected")) )
	{
		if( AnyClass && AllClass )
			Ar.Logf( TEXT("%s"), AllClass->GetName() );
	}
	else if( !appStrnicmp(Item,TEXT("IsKindOf"),8) )
	{
		// Sees if the one selected actor belongs to a class.
		UClass *Class;
		Ar.Logf( TEXT("%i"), ParseObject<UClass>(Item,TEXT("CLASS="),Class,ANY_PACKAGE) && AllClass && AllClass->IsChildOf(Class) );
	}
}
void ActorTopicHandler::Set( ULevel* Level, const TCHAR* Item, const TCHAR* Data )
{}

// Lev.
AUTOREGISTER_TOPIC(TEXT("Lev"),LevTopicHandler);
void LevTopicHandler::Get( ULevel* Level, const TCHAR* Item, FOutputDevice& Ar )
{

	INT ItemNum = appAtoi( Item );
	if( ItemNum>=0 && ItemNum<ULevel::NUM_LEVEL_TEXT_BLOCKS && Level->TextBlocks[ItemNum] )
		Ar.Log( *Level->TextBlocks[ItemNum]->Text );
}
void LevTopicHandler::Set( ULevel* Level, const TCHAR* Item, const TCHAR* Data )
{
	if( !appIsDigit(Item[0]) )
		return; // Item isn't a number.

	int ItemNum = appAtoi( Item );
	if ((ItemNum < 0) || (ItemNum >= ULevel::NUM_LEVEL_TEXT_BLOCKS)) return; // Invalid text block number

	if( !Level->TextBlocks[ItemNum] )
		Level->TextBlocks[ItemNum] = new( Level->GetOuter(), NAME_None, RF_NotForClient|RF_NotForServer )UTextBuffer;
	
	Level->TextBlocks[ItemNum]->Text = Data;
}

// Mesh.
AUTOREGISTER_TOPIC(TEXT("Mesh"),MeshTopicHandler);
void MeshTopicHandler::Get( ULevel* Level, const TCHAR* Item, FOutputDevice& Ar )
{
	// CDH: FIXME: need another way for editor mesh viewer to get sequences, cannot do so by index with Duke meshes
	if (!appStrnicmp(Item,TEXT("GETPROP"),7))
	{
		UMesh *Mesh;
		TCHAR PropName[256];
		if(( ParseObject<UMesh>(Item,TEXT("NAME="),Mesh,ANY_PACKAGE) )
		 && (Parse(Item, TEXT("PROP="), PropName, 256)))
		{
			INT Index;
			if (!Parse(Item, TEXT("INDEX="), Index))
				Index = 0;
			UMeshInstance* MeshInst = Mesh->GetInstance(NULL);
			MeshInst->GetStringValue(Ar, PropName, Index);
		}
	}
}
void MeshTopicHandler::Set( ULevel* Level, const TCHAR* Item, const TCHAR* Data )
{
}

// Texture.
AUTOREGISTER_TOPIC(TEXT("Texture"),TextureTopicHandler);
void TextureTopicHandler::Get( ULevel* Level, const TCHAR* Item, FOutputDevice& Ar )
{
	UTexture* Texture;
	if( ParseCommand(&Item,TEXT("CURRENTTEXTURE")) )
	{
		if( GEditor->CurrentTexture )
			Ar.Log( GEditor->CurrentTexture->GetPathName() );
	}
	else if( ParseObject<UTexture>(Item,TEXT("TEXTURE="),Texture,ANY_PACKAGE) )
	{
		if( ParseCommand(&Item,TEXT("PALETTE")) )
		{
			Ar.Logf( TEXT("%s"), Texture->Palette->GetPathName() );
		}
		else if( ParseCommand(&Item,TEXT("SIZE")) )
		{
			Ar.Logf( TEXT("%i,%i"), Texture->USize, Texture->VSize );
		}
	}
}
void TextureTopicHandler::Set( ULevel* Level, const TCHAR* Item, const TCHAR* Value )
{}

/*-----------------------------------------------------------------------------
	Object property porting.
-----------------------------------------------------------------------------*/

//
// Import text properties.
//
EDITOR_API const TCHAR* ImportProperties
(
	UClass*				ObjectClass,
	BYTE*	    		Object,
	ULevel*				Level,
	const TCHAR*		Data,
	UObject*			InParent,
	FFeedbackContext*	Warn
)
{
	check(ObjectClass!=NULL);
	//check(Object!=NULL);

	// Parse all objects stored in the actor.
	// Build list of all text properties.
	TCHAR StrLine[4096];
	UBOOL ImportedBrush = 0;
	while( ParseLine( &Data, StrLine, ARRAY_COUNT(StrLine) ) )
	{
		const TCHAR* Str = StrLine;
		if( GetBEGIN(&Str,TEXT("Brush")) && ObjectClass->IsChildOf(ABrush::StaticClass()) )
		{
			// Parse brush on this line.
			TCHAR BrushName[NAME_SIZE];
			if( Parse( Str, TEXT("Name="), BrushName, NAME_SIZE ) )
			{
				// If a brush with this name already exists in the
				// level, rename the existing one.  This is necessary
				// because we can't rename the brush we're importing without
				// losing our ability to associate it with the actor properties
				// that reference it.
				UModel* ExistingBrush = FindObject<UModel>( InParent, BrushName );
				if( ExistingBrush )
					ExistingBrush->Rename();

				// Create model.
				UModelFactory* ModelFactory = new UModelFactory;
				ModelFactory->FactoryCreateText( UModel::StaticClass(), InParent, BrushName, 0, NULL, TEXT("t3d"), Data, Data+appStrlen(Data), GWarn );
				ImportedBrush = 1;
			}
		}
		else if( GetBEGIN(&Str,TEXT("StaticMesh")))
		{
			/*
			// Parse static mesh on this line.
			TCHAR	StaticMeshName[NAME_SIZE];

			if(Parse(Str,TEXT("Name="),StaticMeshName,NAME_SIZE))
			{
				// Rename any static meshes that have the desired name.

				UStaticMesh*	ExistingStaticMesh = FindObject<UStaticMesh>(InParent,StaticMeshName);

				if(ExistingStaticMesh)
					ExistingStaticMesh->Rename();

				// Parse the static mesh.
				UStaticMeshFactory*	StaticMeshFactory = new UStaticMeshFactory;
				StaticMeshFactory->FactoryCreateText(UModel::StaticClass(),InParent,StaticMeshName,0,NULL,TEXT("t3d"),Data,Data + appStrlen(Data),GWarn);

				delete StaticMeshFactory;
			}
			*/
		}
		else if( GetEND(&Str,TEXT("Actor")) || GetEND(&Str,TEXT("DefaultProperties")) )
		{
			// End of properties.
			break;
		}
		else
		{
			// Property.
			TCHAR Token[4096];
			while( *Str==' ' || *Str==9 )
				Str++;
			const TCHAR* Start=Str;
			while( *Str && *Str!='=' && *Str!='(' && *Str!='[' )
				Str++;

			if( *Str )
			{
				appStrncpy( Token, Start, Str-Start+1 );
				// strip trailing whitespace on token
				INT l = appStrlen(Token);
				while( l && (Token[l-1]==' ' || Token[l-1]==9) )
				{
					Token[l-1] = 0;
					--l;
				}
				INT Index=-1;
				if( *Str=='(' || *Str=='[' )
				{
					Str++;
					Index = appAtoi(Str);
					while( *Str && *Str!=')' && *Str!=']' )
						Str++;
					if( !*Str++ )
					{
						Warn->Logf( NAME_ExecWarning, TEXT("%s: Missing ')' or ']' in default properties subscript: %s"), ObjectClass->GetPathName(), StrLine );
						continue;
					}
				}
				// strip whitespace before =
				while( *Str==' ' || *Str == 9 )
					Str++;
				if( *Str++!='=' )
				{
					Warn->Logf( NAME_ExecWarning, TEXT("%s: Missing '=' in default properties assignment: %s"), ObjectClass->GetPathName(), StrLine );
					continue;
				}
				// strip whitespace after =
				while( *Str==' ' || *Str == 9 )
					Str++;

				UProperty* Property = FindField<UProperty>( ObjectClass, Token );
				if( !Property )
				{
					Warn->Logf( NAME_ExecWarning, TEXT("%s: Unknown property in defaults: %s"), ObjectClass->GetPathName(), StrLine );
					continue;
				}
				if( ( Index>=Property->ArrayDim && !Property->IsA(UArrayProperty::StaticClass()) ) )
				{
					Warn->Logf( NAME_ExecWarning, TEXT("%s: Out of bound array default property (%i/%i)"), ObjectClass->GetPathName(), Index, Property->ArrayDim );
					continue;
				}
				if( appStricmp(Property->GetName(),TEXT("Name"))!=0 )
				{
					l = appStrlen(Str);
					while( l && (Str[l-1]==';' || Str[l-1]==' ' || Str[l-1]==9) )
					{
						*(TCHAR*)(&Str[l-1]) = 0;
						--l;
					}
					if( Property->IsA(UStrProperty::StaticClass()) && (!l || *Str != '"' || Str[l-1] != '"') )
						Warn->Logf( NAME_ExecWarning, TEXT("%s: Missing '\"' in string default properties : %s"), ObjectClass->GetPathName(), StrLine );

					if (Index > -1 && Property->IsA(UArrayProperty::StaticClass())) //set single dynamic array element
					{
						FArray* Array=(FArray*)(Object + Property->Offset);
						UArrayProperty* ArrayProp = (UArrayProperty*)Property;
						if (Index>=Array->Num())
							Array->AddZeroed(ArrayProp->Inner->ElementSize,Index-Array->Num()+1);
						ArrayProp->Inner->ImportText( Str, (BYTE*)Array->GetData() + Index * ArrayProp->Inner->ElementSize, PPF_Delimited );
					}
					else
					{
						if (Index == -1) Index = 0;
						Property->ImportText( Str, Object + Property->Offset + Index*Property->ElementSize, PPF_Delimited );
					}
				}
			}
				
				/*
			if( *Str )
			{
				appStrncpy( Token, Start, Str-Start+1 );
				INT Index=0;

				if( *Str=='(' )
				{
					Str++;
					Index = appAtoi(Str);
					while( *Str && *Str!=')' )
						Str++;
					if( !*Str++ )
					{
						Warn->Logf( NAME_ExecWarning, TEXT("%s: Missing ')' in default properties subscript: %s"), ObjectClass->GetPathName(), StrLine );
						continue;
					}
				}
				if( *Str++!='=' )
				{
					Warn->Logf( NAME_ExecWarning, TEXT("%s: Missing '=' in default properties assignment: %s"), ObjectClass->GetPathName(), StrLine );
					continue;
				}
				UProperty* Property = FindField<UProperty>( ObjectClass, Token );
				if( !Property )
				{
					Warn->Logf( NAME_ExecWarning, TEXT("%s: Unknown property in defaults: %s"), ObjectClass->GetPathName(), StrLine );
					continue;
				}
				if( Index>=Property->ArrayDim )
				{
					Warn->Logf( NAME_ExecWarning, TEXT("%s: Out of bound array default property (%i/%i)"), ObjectClass->GetPathName(), Index, Property->ArrayDim );
					continue;
				}
				if( appStricmp(Property->GetName(),TEXT("Name"))!=0 )
                {
                    Property->ImportText( Str, (BYTE *)Object + Property->Offset + Index*Property->ElementSize, PPF_Delimited );
                }
			}
			*/
		}
	}

	// Prepare brush.
	if( ImportedBrush && ObjectClass->IsChildOf(ABrush::StaticClass()) )
	{
		check(GIsEditor);
		ABrush* Actor = (ABrush*)Object;
		if( Actor->bStatic )
		{
			// Prepare static brush.
			Actor->SetFlags       ( RF_NotForClient | RF_NotForServer );
			Actor->Brush->SetFlags( RF_NotForClient | RF_NotForServer );
		}
		else
		{
			// Prepare moving brush.
			GEditor->csgPrepMovingBrush( Actor );
		}
	}
	return Data;
}

/*---------------------------------------------------------------------------------------
	The End.
---------------------------------------------------------------------------------------*/
