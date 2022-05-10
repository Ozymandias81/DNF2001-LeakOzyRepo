/*=============================================================================
	UMakeCommandlet.cpp: UnrealEd script recompiler.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

Revision history:
	* Created by Tim Sweeney.
=============================================================================*/

#include "EditorPrivate.h"

/*-----------------------------------------------------------------------------
	UMakeCommandlet.
-----------------------------------------------------------------------------*/

class UMakeCommandlet : public UCommandlet
{
	DECLARE_CLASS(UMakeCommandlet,UCommandlet,CLASS_Transient);
	void StaticConstructor()
	{
		LogToStdout     = 0;
		IsClient        = 1;
		IsEditor        = 1;
		IsServer        = 1;
		LazyLoad        = 1;
		ShowErrorCount  = 1;
	}
	INT Main( const TCHAR* Parms )
	{
		// Create the editor class.
		UClass* EditorEngineClass = UObject::StaticLoadClass( UEditorEngine::StaticClass(), NULL, TEXT("ini:Engine.Engine.EditorEngine"), NULL, LOAD_NoFail | LOAD_DisallowFiles, NULL );
		GEditor  = ConstructObject<UEditorEngine>( EditorEngineClass );
		GEditor->UseSound = 0;
		GEditor->InitEditor();
		GIsRequestingExit = 1; // Causes ctrl-c to immediately exit.

		// CDH...
		UBOOL Incremental = 0, IncrementalTree = 0;
		FString IncrementalCmd;
		DWORD IncrementalClassCount = 0;
		FString RootClassName;
		UClass* RootClass = NULL;
		if (ParseToken(Parms, IncrementalCmd, 0))
		{
			if (!appStricmp(*IncrementalCmd, TEXT("class")))
			{
				if (ParseToken(Parms, RootClassName, 0))
					Incremental = 1;
			}
			else if (!appStricmp(*IncrementalCmd, TEXT("tree")))
			{
				if (ParseToken(Parms, RootClassName, 0))
				{
					Incremental = 1;
					IncrementalTree = 1;
				}
			}
		}
		// ...CDH

		// Load classes for editing.
		UClassFactoryUC* ClassFactory = new UClassFactoryUC;
		for( INT i=0; i<GEditor->EditPackages.Num(); i++ )
		{
			// Try to load package.
			const TCHAR* Pkg = *GEditor->EditPackages( i );
			FString Filename = FString(Pkg) + TEXT(".u");
			GWarn->Log( NAME_Heading, Pkg );
			UPackage* PkgObject = NULL;
			PkgObject = (UPackage*)LoadPackage( NULL, *Filename, LOAD_NoWarn );
			if ( (!PkgObject) || (Incremental) )
			{
				if (Incremental && !PkgObject)
					appErrorf(TEXT("Incremental make requires that packages already exist"));
				
				if (!Incremental)
				{
					// Create package.
					GWarn->Log( TEXT("Analyzing...") );
					PkgObject = CreatePackage( NULL, Pkg );
				
					// Try reading from package's .ini file.
					PkgObject->PackageFlags &= ~(PKG_AllowDownload|PKG_ClientOptional|PKG_ServerSideOnly);
					FString IniName = FString(TEXT("..")) * Pkg * TEXT("Classes") * Pkg + TEXT(".upkg");
					UBOOL B=0;
					if( GConfig->GetBool(TEXT("Flags"), TEXT("AllowDownload"), B, *IniName) && B )
						PkgObject->PackageFlags |= PKG_AllowDownload;
					if( GConfig->GetBool(TEXT("Flags"), TEXT("ClientOptional"), B, *IniName) && B )
						PkgObject->PackageFlags |= PKG_ClientOptional;
					if( GConfig->GetBool(TEXT("Flags"), TEXT("ServerSideOnly"), B, *IniName) && B )
						PkgObject->PackageFlags |= PKG_ServerSideOnly; 
				}

				// Rebuild the classes from directory.
				FString Spec = FString(TEXT("..")) * Pkg * TEXT("Classes") * TEXT("*.uc");
				TArray<FString> Files = GFileManager->FindFiles( *Spec, 1, 0 );
				if( Files.Num() == 0 )
					appErrorf( TEXT("Can't find files matching %s"), *Spec );

				if (Incremental)
				{
					// Set our class count for this package to zero
					IncrementalClassCount = 0;

					// If we haven't found the root class yet, see if we have it in this package and reimport it if so
					if (!RootClass)
					{
						for( TObjectIterator<UClass> ItC; ItC; ++ItC )
						{
							if ((!appStricmp(ItC->GetName(), *RootClassName))
							 && (ItC->GetOuter() == PkgObject))
							{
								RootClass = *ItC;
								break;
							}
						}
						if (RootClass)
						{
							FString Filename = FString(TEXT("..")) * Pkg * TEXT("Classes") * RootClassName + TEXT(".uc");
							FString ClassName = Filename.LeftChop(3);
							RootClass = ImportObject<UClass>( PkgObject, *RootClassName, RF_Public|RF_Standalone, *Filename, NULL, ClassFactory );
							IncrementalClassCount++;
						}
					}
					// If we're doing a tree, reimport all classes in the directory underneath the root class
					if (IncrementalTree && RootClass)
					{
						for( INT j=0; j<Files.Num(); j++ )
						{
							FString Filename = FString(TEXT("..")) * Pkg * TEXT("Classes") * Files(j);
							FString ClassName = Files(j).LeftChop(3);

							// find existing class
							UClass* ExistingClass = NULL;
							for( TObjectIterator<UClass> ItC; ItC; ++ItC )
							{
								if ((!appStricmp(ItC->GetName(), *ClassName))
								 && (ItC->GetOuter() == PkgObject))
								{
									ExistingClass = *ItC;
									break;
								}
							}
							if (ExistingClass == RootClass)
								ExistingClass = NULL; // don't reimport the root
							if (ExistingClass && ExistingClass->IsChildOf(RootClass))
							{
								ExistingClass = ImportObject<UClass>( PkgObject, *ClassName, RF_Public|RF_Standalone, *Filename, NULL, ClassFactory );
								IncrementalClassCount++;
							}
						}
					}
				}
				else
				{
					// Import every class in the directory
					for( INT j=0; j<Files.Num(); j++ )
					{
						FString Filename = FString(TEXT("..")) * Pkg * TEXT("Classes") * Files(j);
						FString ClassName = Files(j).LeftChop(3);
						ImportObject<UClass>( PkgObject, *ClassName, RF_Public|RF_Standalone, *Filename, NULL, ClassFactory );
					}

					// Verify that all script declared superclasses exist.
					for( TObjectIterator<UClass> ItC; ItC; ++ItC )
						if( ItC->ScriptText && ItC->GetSuperClass() )
							if( !ItC->GetSuperClass()->ScriptText )
								appErrorf( TEXT("Superclass %s of class %s not found"), ItC->GetSuperClass()->GetName(), ItC->GetName() );
				}

				// if we're doing incremental and we don't yet have the root class, move on to next package
				if (Incremental && !RootClass)
					continue;

				// Bootstrap-recompile changed scripts.
				GEditor->Bootstrapping = 1;
				GEditor->MakeScripts( RootClass, GWarn, 0, 1, (!Incremental) || (IncrementalTree) );
				GEditor->Bootstrapping = 0;

				if (!Incremental)
				{
					// Tag native classes in this package for export.
					INT ClassCount=0;
					for( INT j=0; j<FName::GetMaxNames(); j++ )
						if( FName::GetEntry(j) )
							FName::GetEntry(j)->Flags &= ~RF_TagExp;
					for( TObjectIterator<UClass> It; It; ++It )
						It->ClearFlags( RF_TagImp | RF_TagExp );
					for( It=TObjectIterator<UClass>(); It; ++It )
						if( It->GetOuter()==PkgObject && It->ScriptText && (It->GetFlags()&RF_Native) && !(It->ClassFlags&CLASS_NoExport) )
							ClassCount++, It->SetFlags( RF_TagExp );

					// Export the C++ header.
					if( ClassCount )
					{
						Filename = FString(TEXT("..")) * Pkg * TEXT("Inc") * Pkg + TEXT("Classes.h");
						debugf( TEXT("Autogenerating C++ header: %s"), *Filename );

						// NJS: changed prompt from 1 to 0 to prevent header file exportation:
						if( !UExporter::ExportToFile( UObject::StaticClass(), NULL, *Filename, 1, 0/*1*/ ) )
							appErrorf( TEXT("Failed to export: %s"), *Filename );
					}
				}

				if (!Incremental || IncrementalClassCount)
				{
					// Save package.
					ULinkerLoad* Conform = NULL;
					if( !ParseParam(appCmdLine(),TEXT("NOCONFORM")) )
					{
						BeginLoad();
						Conform = UObject::GetPackageLinker( CreatePackage(NULL,*(US+Pkg+TEXT("_OLD"))), *(FString(TEXT("..")) * TEXT("SystemConform") * Pkg + TEXT(".u")), LOAD_NoWarn|LOAD_NoVerify, NULL, NULL );
						EndLoad();
						if( Conform )
							debugf( TEXT("Conforming: %s"), Pkg );
					}
					SavePackage( PkgObject, NULL, RF_Standalone, *(FString(Pkg)+TEXT(".u")), GError, Conform );
				}

				if (Incremental && !IncrementalTree && RootClass)
				{
					// Finish up if we're not doing a tree and we've processed our root
					GIsRequestingExit=1;
					return 0;
				}
			}
		}
		
		GIsRequestingExit=1;
		return 0;
	}
};
IMPLEMENT_CLASS(UMakeCommandlet)

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
