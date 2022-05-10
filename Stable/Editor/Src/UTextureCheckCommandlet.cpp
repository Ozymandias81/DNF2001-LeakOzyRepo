/*=============================================================================
	UTextureCheckCommandlet
	Copyright 2001 3D Realms. All Rights Reserved.

Revision history:
	* Created by Brandon Reinhart.
=============================================================================*/

#include "EditorPrivate.h"

class UTextureCheckCommandlet : public UCommandlet
{
	DECLARE_CLASS(UTextureCheckCommandlet,UCommandlet,CLASS_Transient);
	void StaticConstructor()
	{
		LogToStdout     = 0;
		IsClient        = 1;
		IsEditor        = 1;
		IsServer        = 1;
		LazyLoad        = 1;
		ShowErrorCount  = 0;
	}
	INT Main( const TCHAR* Parms )
	{
		// Print a banner.
		GWarn->Logf( TEXT("\nChecking textures for materials and detail textures.") );
		GWarn->Logf( TEXT("Loading editor engine...") );

		// Create the editor class.
		UClass* EditorEngineClass = UObject::StaticLoadClass( UEditorEngine::StaticClass(), NULL, TEXT("ini:Engine.Engine.EditorEngine"), NULL, LOAD_NoFail | LOAD_DisallowFiles, NULL );
		GEditor  = ConstructObject<UEditorEngine>( EditorEngineClass );
		GEditor->UseSound = 1;
		GEditor->Init();
		GIsRequestingExit = 1; // Causes ctrl-c to immediately exit.

		// Make sure we got all params.
		FString Pkg, Path;
		if( !ParseToken(Parms,Pkg,0) )
			appErrorf(TEXT("You must specify a package to check."));

		GWarn->Logf( TEXT("Loading package %s"), *Pkg );
		UObject* Package = LoadPackage(NULL,*Pkg,LOAD_NoFail);

		// Check all textures that are loaded.
		for( TObjectIterator<UTexture> It; It; ++It )
		{
			if( It->IsIn(Package) )
			{
				if (It->MaterialName==NAME_None)	GWarn->Logf( TEXT("%s has no material."), It->GetFullName() );
				if (It->DetailTexture==NULL)		GWarn->Logf( TEXT("%s has no detail texture."), It->GetFullName() );
			}
		}

		GIsRequestingExit=1;
		return 0;
	}
};
IMPLEMENT_CLASS(UTextureCheckCommandlet)