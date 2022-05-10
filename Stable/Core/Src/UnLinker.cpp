/*=============================================================================
	UnLinker.h: Unreal object linker.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

#include "..\..\Engine\Src\EnginePrivate.h"

/*-----------------------------------------------------------------------------
	Hash function.
-----------------------------------------------------------------------------*/

// JEP
static INT				GSpecialModelCase;

inline INT HashNames( FName A, FName B, FName C )
{
	/*
	if( C==NAME_UnrealShare )//oldver
		C=NAME_dnGame;
	if( C==NAME_UnrealI )
		C=NAME_dnGame;
	*/
	return A.GetIndex() + 7 * B.GetIndex() + 31*C.GetIndex();
}

/*----------------------------------------------------------------------------
	ULinker.
----------------------------------------------------------------------------*/

ULinker::ULinker( UObject* InRoot, const TCHAR* InFilename )
:	LinkerRoot( InRoot )
,	Summary()
,	Success( 123456 )
,	Filename( InFilename )
,	_ContextFlags( 0 )
{
	check(LinkerRoot);
	check(InFilename);

	// Set context flags.
	if( GIsEditor ) _ContextFlags |= RF_LoadForEdit;
	if( GIsClient ) _ContextFlags |= RF_LoadForClient;
	if( GIsServer ) _ContextFlags |= RF_LoadForServer;
}

// UObject interface.
void
ULinker::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );

	// Sizes.
	ImportMap.CountBytes( Ar );
	ExportMap.CountBytes( Ar );

	// Prevent garbage collecting of linker's names and package.
	Ar << NameMap << LinkerRoot;
	{for( INT i=0; i<ExportMap.Num(); i++ )
	{
		FObjectExport& E = ExportMap(i);
		Ar << E.ObjectName;
	}}
	{for( INT i=0; i<ImportMap.Num(); i++ )
	{
		FObjectImport& I = ImportMap(i);
		Ar << *(UObject**)&I.SourceLinker;
		Ar << I.ClassPackage << I.ClassName;
	}}
}

// ULinker interface.
FString
ULinker::GetImportFullName( INT i )
{
	FString S;
	for( INT j=-i-1; j!=0; j=ImportMap(-j-1).PackageIndex )
	{
		if( j != -i-1 )
			S = US + TEXT(".") + S;
		S = FString(*ImportMap(-j-1).ObjectName) + S;
	}
	return FString(*ImportMap(i).ClassName) + TEXT(" ") + S ;
}

FString
ULinker::GetExportFullName( INT i, const TCHAR* FakeRoot )
{
	FString S;
	for( INT j=i+1; j!=0; j=ExportMap(j-1).PackageIndex )
	{
		if( j != i+1 )
			S = US + TEXT(".") + S;
		S = FString(*ExportMap(j-1).ObjectName) + S;
	}
	INT ClassIndex = ExportMap(i).ClassIndex;
	FName ClassName = ClassIndex>0 ? ExportMap(ClassIndex-1).ObjectName : ClassIndex<0 ? ImportMap(-ClassIndex-1).ObjectName : NAME_Class;
	return FString(*ClassName) + TEXT(" ") + (FakeRoot ? FakeRoot : LinkerRoot->GetPathName()) + TEXT(".") + S;
}

/*----------------------------------------------------------------------------
	ULinkerLoad.
----------------------------------------------------------------------------*/

// Constructor; all errors here throw exceptions which are fully recoverable.
ULinkerLoad::ULinkerLoad( UObject* InParent, const TCHAR* InFilename, DWORD InLoadFlags )
:	ULinker( InParent, InFilename )
,	LoadFlags( InLoadFlags )
{
	guard(ULinkerLoad::ULinkerLoad);
	debugf( TEXT("Loading: %s"), InParent->GetFullName() );
	Loader = GFileManager->CreateFileReader( InFilename, 0, GError );
	if( !Loader )
		appThrowf( LocalizeError("OpenFailed") );

	ParentLinker = NULL;		// JEP
	ChildLinker = NULL;			// JEP

	// Error if linker already loaded.
	{for( INT i=0; i<GObjLoaders.Num(); i++ )
		if( GetLoader(i)->LinkerRoot == LinkerRoot )
			appThrowf( LocalizeError("LinkerExists"), LinkerRoot->GetName() );}

	// Begin.
	GWarn->StatusUpdatef( 0, 0, LocalizeProgress("Loading"), *Filename );

	// Set status info.
	guard(InitAr);
	ArVer       = PACKAGE_FILE_VERSION;
#if DNF
	ArMergeVer	= 63;
#endif
	ArIsLoading = ArIsPersistent = 1;
	ArForEdit   = GIsEditor;
	ArForClient = 1;
	ArForServer = 1;
	unguard;

	// Read summary from file.
	guard(LoadSummary);
	*this << Summary;
	ArVer = Summary.FileVersion;
	ArLVer = Summary.LicenseeVersion; // CDH
	if( Cast<UPackage>(LinkerRoot) )
		Cast<UPackage>(LinkerRoot)->PackageFlags = Summary.PackageFlags;
	unguard;

#if DNF
	// CDH: If we have the tempmerge flag set, use our mergever to handle the branch based on when DNF last branched from Unreal
	ArMergeVer = 63;
	if (LoadFlags & LOAD_TempMerge)
	{
		debugf(TEXT("DNF Debug: Merging..."));
		// merging, switch regular version and merge version
		ArMergeVer = ArVer;
		if (ArVer > 63)
			ArVer = 63;
	}
#endif

	// Check tag.
	guard(CheckTag);
	if( Summary.Tag != PACKAGE_FILE_TAG )
	{
		GWarn->Logf( LocalizeError("BinaryFormat"), *Filename );
		appThrowf( LocalizeError("Aborted") );
	}
	unguard;

	// Validate the summary.
	guard(ValidateSummary);
	if( Summary.FileVersion < PACKAGE_MIN_VERSION )
		if( !GWarn->YesNof( LocalizeQuery("OldVersion"), *Filename ) )
			appThrowf( LocalizeError("Aborted") );
	unguard;

	// Slack everything according to summary.
	ImportMap   .Empty( Summary.ImportCount   );
	ExportMap   .Empty( Summary.ExportCount   );
	NameMap		.Empty( Summary.NameCount     );

	// Load and map names.
	guard(LoadNames);
	if( Summary.NameCount > 0 )
	{
		Seek( Summary.NameOffset );
		
		for( INT i=0; i<Summary.NameCount; i++ )
		{
			// Read the name entry from the file.	
			FNameEntry NameEntry;
			
			appMemset(&NameEntry, 0, sizeof(NameEntry));		// JEP

			*this << NameEntry;
			
			// Add it to the name table if it's needed in this context.				
			NameMap.AddItem( (NameEntry.Flags & _ContextFlags) ? FName( NameEntry.Name, FNAME_Add ) : NAME_None );
		}
	}
	unguard;

	// Load import map.
	guard(ImportMap);
	if( Summary.ImportCount > 0 )
	{
		Seek( Summary.ImportOffset );
		for( INT i=0; i<Summary.ImportCount; i++ )
			*this << *new(ImportMap)FObjectImport;
	}
	unguard;

	// Load export map.
	guard(ExportMap);
	if( Summary.ExportCount > 0 )
	{
		Seek( Summary.ExportOffset );
		for( INT i=0; i<Summary.ExportCount; i++ )
			*this << *new(ExportMap)FObjectExport;
	}
	unguard;

	// Create export hash.
	//warning: Relies on import & export tables, so must be done here.
	{for( INT i=0; i<ARRAY_COUNT(ExportHash); i++ )
	{
		ExportHash[i] = INDEX_NONE;
	}}
	{for( INT i=0; i<ExportMap.Num(); i++ )
	{
		INT iHash = HashNames( ExportMap(i).ObjectName, GetExportClassName(i), GetExportClassPackage(i) ) & (ARRAY_COUNT(ExportHash)-1);
		ExportMap(i)._iHashNext = ExportHash[iHash];
		ExportHash[iHash] = i;
	}}

	// Add this linker to the object manager's linker array.
	GObjLoaders.AddItem( this );
	if( !(LoadFlags & LOAD_NoVerify) )
		Verify();

	// Success.
	Success = 1;
	unguard;
}

void ULinkerLoad::Verify()
{
	if( !Verified )
	{
		if( Cast<UPackage>(LinkerRoot) )
			Cast<UPackage>(LinkerRoot)->PackageFlags &= ~PKG_BrokenLinks;
		try
		{
			// Validate all imports and map them to their remote linkers.
			for( INT i=0; i<Summary.ImportCount; i++ )
				VerifyImport( i );
		}
		catch( TCHAR* Error )
		{
			GObjLoaders.RemoveItem( this );
			throw( Error );
		}
	}
	Verified=1;
}

FName ULinkerLoad::GetExportClassPackage( INT i )
{
	FName FoundClassPackage = NAME_None;

	FObjectExport& Export = ExportMap( i );
	if( Export.ClassIndex < 0 )
	{
		FObjectImport& Import = ImportMap( -Export.ClassIndex-1 );
		checkSlow(Import.PackageIndex<0);
		FoundClassPackage = ImportMap( -Import.PackageIndex-1 ).ObjectName;
	}
	else if( Export.ClassIndex > 0 )
	{
		FoundClassPackage = LinkerRoot->GetFName();
	}
	else
	{
		FoundClassPackage = NAME_Engine;
	}

	if ( FoundClassPackage == NAME_Core )
		return NAME_Engine;
	else
		return FoundClassPackage;
}

FName ULinkerLoad::GetExportClassName( INT i )
{
	FObjectExport& Export = ExportMap(i);
	if( Export.ClassIndex < 0 )
	{
		return ImportMap( -Export.ClassIndex-1 ).ObjectName;
	}
	else if( Export.ClassIndex > 0 )
	{
		return ExportMap( Export.ClassIndex-1 ).ObjectName;
	}
	else
	{
		return NAME_Class;
	}
}

#if 0

> > Matthias writes:
> > > If something could be done to fix this (still load the level
> > > and discard all
> > > the classes that couldn't be found - does that work?) that would be
> > > EXTREMELY helpful and welcome :)
> >
> > Sweeney writes:
> > > [easy evil solution]
> >
> > Aspolito writes:
> > > I tried [Sweeney's suggestion] and it is making the level editor crash
> > a little
> > > ways down the line with a Bad import index inside IndexToObject.
> > >
> > > Any idea how to fix this?
> >
> > unprog writes:
> > > [several days of silence]
> >
> > Here is Paul's easy evil tested solution; it is something of a hack
> > because I tried not to mess too much with things I didn't understand so
> > well.  It replaces references to nonexistent classes with references to
> > class Engine.DeleteMe.  You should create that for yourself.  Ours is
> > just a big sprite.
> >
> > enjoy,
> > p
> >
> > ***************
> > *** 354,361 ****
> > --- 354,366 ----
> >   ULinkerLoad::VerifyImport( INT i )
> >   {
> > + #if IM
> > +     bool bAllowIMRehack = true; // to prevent possible infinite loop
> > + #endif
> > +
> >   SharewareHack://oldver
> > ***************
> > *** 511,519 ****
> > --- 516,539 ----
> >   debugf( TEXT("Broken import: %s %s (file
> > %s)"), *Import.ClassName, *GetImportFullName(i),
> > *Import.SourceLinker->Filename );
> >   return;
> >   }
> > + #if IM
> > +             if( GCheckConflicts && bAllowIMRehack )
> > +             {
> > +                 bAllowIMRehack = false;
> > +                 debugf( TEXT("Replacing %s with Engine.DeleteMe"),
> > *Import.ObjectName );
> > +
> > +                 Import.SourceLinker = GetPackageLinker
> > +                     ( CreatePackage(NULL,TEXT("Engine")),
> > +                       NULL, LOAD_Throw | (LoadFlags & LOAD_Propagate),
> > NULL, NULL );
> > +                 Import.ObjectName=FName(TEXT("DeleteMe"));
> > +                 goto Rehack;    // considered harmful
> > +             }
> > + #endif
> > +
> >   appThrowf( LocalizeError("FailedImport"),
> > *Import.ClassName, *GetImportFullName(i) );
> >   }
> >   }
> > +
> >   }
#endif

// Safely verify an import.
void ULinkerLoad::VerifyImport( INT i )
{
	#define IM 1
	#if IM
		bool bAllowIMRehack = true; // to prevent possible infinite loop
	#endif

	SharewareHack://oldver
	FObjectImport& Import = ImportMap(i);
	if
	(	Import.SourceIndex	!= INDEX_NONE
	||	Import.ClassPackage	== NAME_None
	||	Import.ClassName	== NAME_None
	||	Import.ObjectName	== NAME_None )
	{
		// Already verified, or not relevent in this context.
		return;
	}

	// Forward references from core to engine.
	if ( Import.ClassPackage == NAME_Core )
		Import.ClassPackage = NAME_Engine;
	if ( Import.ObjectName == NAME_Core )
		Import.ObjectName = NAME_Engine;

	// Find or load this import's linker.
	INT Depth=0;
	UObject* Pkg=NULL;
	if( Import.PackageIndex == 0 )
	{
		check(Import.ClassName==NAME_Package);
		check(Import.ClassPackage==NAME_Engine);
		UPackage* TmpPkg = CreatePackage( NULL, *Import.ObjectName );
		Import.SourceLinker = GetPackageLinker( TmpPkg, NULL, LOAD_Throw | (LoadFlags & LOAD_Propagate), NULL, NULL );
	}
	else
	{
		check(Import.PackageIndex<0);
		VerifyImport( -Import.PackageIndex-1 );
		Import.SourceLinker = ImportMap(-Import.PackageIndex-1).SourceLinker;
		check(Import.SourceLinker);
		FObjectImport* Top;
		for
		(	Top = &Import
		;	Top->PackageIndex<0
		;	Top = &ImportMap(-Top->PackageIndex-1),Depth++ );
		Pkg = CreatePackage( NULL, *Top->ObjectName );
	}

	// JEP ...
	if(Import.ClassName == TEXT("Model"))
	{
		check(Import.SourceLinker);
		// We should only be doing this during a level load
		check(GSaveLoadHack);
		
		if (!Import.SourceLinker->ParentLinker)
		{
			check(!ChildLinker);
			// Connect them
			Import.SourceLinker->ParentLinker = this;
			this->ChildLinker = Import.SourceLinker;
		}
		else
		{
			check(Import.SourceLinker->ParentLinker == this);
			check(this->ChildLinker == Import.SourceLinker);
		}
	}
	// ... JEP

	// Find this import within its existing linker.
	UBOOL SafeReplace = 0;
Rehack://oldver
	//new:
	INT iHash = HashNames( Import.ObjectName, Import.ClassName, Import.ClassPackage) & (ARRAY_COUNT(ExportHash)-1);
	for( INT j=Import.SourceLinker->ExportHash[iHash]; j!=INDEX_NONE; j=Import.SourceLinker->ExportMap(j)._iHashNext )
	//old:
	//for( INT j=0; j<Import.SourceLinker->ExportMap.Num(); j++ )
	{
		FObjectExport& Source = Import.SourceLinker->ExportMap( j );
//			UBOOL ClassHack = Import.ClassPackage==NAME_UnrealI && Import.SourceLinker->GetExportClassPackage(j)==NAME_UnrealShare;//oldver
		if
		(	(Source.ObjectName	                          ==Import.ObjectName               )
		&&	(Import.SourceLinker->GetExportClassName   (j)==Import.ClassName                )
//			&&  (Import.SourceLinker->GetExportClassPackage(j)==Import.ClassPackage || ClassHack) )
		&&  (Import.SourceLinker->GetExportClassPackage(j)==Import.ClassPackage) )
		{
			if( Import.PackageIndex<0 )
			{
				FObjectImport& ParentImport = ImportMap(-Import.PackageIndex-1);
				if( ParentImport.SourceLinker )
				{
					if( ParentImport.SourceIndex==INDEX_NONE )
					{
						if( Source.PackageIndex!=0 )
						{
							continue;
						}
					}
					else if( ParentImport.SourceIndex+1 != Source.PackageIndex )
					{
						if( Source.PackageIndex!=0 )
						{
							continue;
						}
					}
				}
			}
		
			//	JEP modified so models can be imported
			if( !(Source.ObjectFlags & RF_Public) && Import.ClassName != TEXT("Model"))
			//if( !(Source.ObjectFlags & RF_Public) && Import.ClassName != TEXT("Model") && Import.ClassName != TEXT("Brush"))
			{
				if( LoadFlags & LOAD_Forgiving )
				{
					if( Cast<UPackage>(LinkerRoot) )
						Cast<UPackage>(LinkerRoot)->PackageFlags |= PKG_BrokenLinks;
					debugf( TEXT("Broken import: %s %s (file %s)"), *Import.ClassName, *GetImportFullName(i), *Import.SourceLinker->Filename );
					return;
				}
				//appThrowf( LocalizeError("FailedImportPrivate"), *Import.ClassName, *GetImportFullName(i) );
			}
			
			Import.SourceIndex = j;
			break;
		}
	}
	/*
	if( appStricmp(*Import.ClassName,TEXT("Mesh"))==0 )//oldver
	{
		if (LoadFlags & LOAD_TempMerge)
			Import.ClassName=FName(TEXT("DukeMesh"));
		else
			Import.ClassName=FName(TEXT("UnrealMesh"));
		goto Rehack;
	}
	if( appStricmp(*Import.ClassName,TEXT("UnrealMesh"))==0 )//oldver
	{
		Import.ClassName=FName(TEXT("UnrealLodMesh"));
		goto Rehack;
	}
	*/

	// If not found in file, see if it's a public native transient class.
	if( Import.SourceIndex==INDEX_NONE && Pkg!=NULL )
	{
		UObject* ClassPackage = FindObject<UPackage>( NULL, *Import.ClassPackage );
		if( ClassPackage )
		{
			UClass* FindClass = FindObject<UClass>( ClassPackage, *Import.ClassName );
			if( FindClass )
			{
				UObject* FindObject = StaticFindObject( FindClass, Pkg, *Import.ObjectName );
				if
				(	(FindObject)
				&&	(FindObject->GetFlags() & RF_Public)
				&&	(FindObject->GetFlags() & RF_Native)
				&&	(FindObject->GetFlags() & RF_Transient) )
				{
					Import.XObject = FindObject;
					GImportCount++;
				}
				else if( FindClass->ClassFlags & CLASS_SafeReplace )
				{
					if( GCheckConflicts )
						debugf( TEXT("Missing %s %s"), FindClass->GetName(), *GetImportFullName(i) );
					SafeReplace = 1;
				}
			}
		}
		if( !Import.XObject && Pkg!=NULL && ((Pkg->GetFName()==NAME_UnrealI) || (Pkg->GetFName()==NAME_UnrealShare)) && Depth==1 )//oldver
		{
			Import.PackageIndex = -ImportMap.Num()-1;
			FObjectImport& New  = *new(ImportMap)FObjectImport;
			New.ClassPackage	= NAME_Engine;
			New.ClassName		= NAME_Package;
			New.PackageIndex	= 0;
			New.ObjectName		= NAME_dnGame;
			New.XObject			= NULL;
			New.SourceLinker	= NULL;
			New.SourceIndex		= INDEX_NONE;
			VerifyImport(ImportMap.Num()-1);
			goto SharewareHack;
		}
		if( !Import.XObject && !SafeReplace )
		{
			//LoadFlags|=LOAD_Forgiving;
			if( LoadFlags & LOAD_Forgiving )
			{
				if( Cast<UPackage>(LinkerRoot) )
					Cast<UPackage>(LinkerRoot)->PackageFlags |= PKG_BrokenLinks;
				debugf( TEXT("Broken import: %s %s (file %s)"), *Import.ClassName, *GetImportFullName(i), *Import.SourceLinker->Filename );
				return;
			}

			#if IM
			if( bAllowIMRehack )
			{
				bAllowIMRehack = false;
				if (Import.ClassName == FName(TEXT("DukeMesh")))
				{
					debugf( TEXT("Replacing %s (%s) with c_generic.BigError."),*Import.ObjectName,*Import.ClassName );
					Import.SourceLinker = GetPackageLinker( CreatePackage(NULL,TEXT("c_generic")),
				       NULL, LOAD_Throw | (LoadFlags & LOAD_Propagate), NULL, NULL );
					Import.ObjectName=FName(TEXT("BigError"));
				} else 
				{
					debugf( TEXT("Replacing %s (%s) with Engine.DeleteMe."),*Import.ObjectName,*Import.ClassName );
					Import.SourceLinker = GetPackageLinker( CreatePackage(NULL,TEXT("Engine")),
				       NULL, LOAD_Throw | (LoadFlags & LOAD_Propagate), NULL, NULL );
					Import.ObjectName=FName(TEXT("DeleteMe"));
				}
				goto Rehack;    // considered harmful
			}
			#endif

			//appThrowf( LocalizeError("FailedImport"), *Import.ClassName, *GetImportFullName(i) );
		}
	}
}

// Load all objects; all errors here are fatal.
void ULinkerLoad::LoadAllObjects()
{
	for( INT i=0; i<Summary.ExportCount; i++ )
		CreateExport( i );
}

// Find the index of a specified object.
//!!without regard to specific package
INT ULinkerLoad::FindExportIndex( FName ClassName, FName ClassPackage, FName ObjectName, INT PackageIndex )
{
	//Rehack://oldver
	while(1)
	{
		INT iHash = HashNames( ObjectName, ClassName, ClassPackage ) & (ARRAY_COUNT(ExportHash)-1);
		for( INT i=ExportHash[iHash]; i!=INDEX_NONE; i=ExportMap(i)._iHashNext )
		{
			if
			(  (ExportMap(i).ObjectName  ==ObjectName                              )
			&& (ExportMap(i).PackageIndex==PackageIndex || PackageIndex==INDEX_NONE)
			&& (GetExportClassPackage(i) ==ClassPackage                            )
			&& (GetExportClassName   (i) ==ClassName                               ) )
			{
				return i;
			}
		}
		if( appStricmp(*ClassName,TEXT("Mesh"))==0 )//oldver.
		{
			ClassName = FName(TEXT("UnrealMesh"));
			continue;
		}
		if( appStricmp(*ClassName,TEXT("UnrealMesh"))==0 )//oldver.
		{
			ClassName = FName(TEXT("UnrealLodMesh"));
			continue;
		}
		return INDEX_NONE;
	} 
}

// Create a single object.
UObject* ULinkerLoad::Create( UClass* ObjectClass, FName ObjectName, DWORD LoadFlags, UBOOL Checked )
{
	INT Index = FindExportIndex( ObjectClass->GetFName(), ObjectClass->GetOuter()->GetFName(), ObjectName, INDEX_NONE );
	if( Index!=INDEX_NONE )
		return (LoadFlags & LOAD_Verify) ? (UObject*)-1 : CreateExport(Index);
	if( Checked )
		appThrowf( LocalizeError("FailedCreate"), ObjectClass->GetName(), *ObjectName );
	return NULL;
}

void ULinkerLoad::Preload( UObject* Object )
{
	const ANSICHAR *Str = appToAnsi(*Filename);

	check(IsValid());
	check(Object);
	
	if( Object->GetFlags() & RF_Preloading )
	{
		// Warning for internal development.
		debugf( TEXT("Object preload reentrancy: %s"), Object->GetFullName() );
	}
	if( Object->GetLinker()==this )
	{
		// Preload the object if necessary.
		if( Object->GetFlags() & RF_NeedLoad )
		{
			// If this is a struct, preload its super.
			if(	Object->IsA(UStruct::StaticClass()) )
				if( ((UStruct*)Object)->SuperField )
					Preload( ((UStruct*)Object)->SuperField );

			// Load the local object now.
			FObjectExport& Export = ExportMap( Object->_LinkerIndex );
			check(Export._Object==Object);
			INT SavedPos = Loader->Tell();
			Loader->Seek( Export.SerialOffset );

			Loader->Precache( Export.SerialSize );

			GNumPreloads++;
			GPreloadSize += Export.SerialSize;

			// Load the object.
			Object->ClearFlags ( RF_NeedLoad );
			Object->SetFlags   ( RF_Preloading );
			if(	Object->IsA(UModel::StaticClass()) && GSaveLoadHack)		// JEP
				GSpecialModelCase++;										// JEP
			double StartTime = 	appSeconds();								// JEP
			Object->Serialize  ( *this );
			GPreloadSerializeTime += appSeconds() - StartTime;						// JEP
			if(	Object->IsA(UModel::StaticClass()) && GSaveLoadHack)		// JEP
				GSpecialModelCase--;										// JEP
			check(GSpecialModelCase >= 0)									// JEP
			Object->ClearFlags ( RF_Preloading );

			//debugf(NAME_Log,TEXT("    %s: %i"), Object->GetFullName(), Export.SerialSize );

			if (Object->IsA(UTexture::StaticClass()))						// JEP
				GTexturePreloadSize += Export.SerialSize;
			
			// Make sure we serialized the right amount of stuff.
		#if 1		// JEP It's ok to not load the exact amount, just make sure we stay in bounds
			if( (Tell()-Export.SerialOffset) > Export.SerialSize )
				appErrorf( LocalizeError("SerialSize"), Object->GetFullName(), Tell()-Export.SerialOffset, Export.SerialSize );
		#else
			if( Tell()-Export.SerialOffset != Export.SerialSize )
			{
			#if DNF
				//Loader->Seek(Export.SerialOffset + Export.SerialSize); // CDH: if an object doesn't want to serialize its whole thing, who cares
			#else
				appErrorf( LocalizeError("SerialSize"), Object->GetFullName(), Tell()-Export.SerialOffset, Export.SerialSize );
			#endif
			}
		#endif

			Loader->Seek( SavedPos );
		}
	}
	else if( Object->GetLinker() )
	{
		// Send to the object's linker.
		Object->GetLinker()->Preload( Object );
	}
}

// Return the loaded object corresponding to an export index; any errors are fatal.
UObject* ULinkerLoad::CreateExport( INT Index )
{
	// Map the object into our table.
	FObjectExport& Export = ExportMap( Index );
	
	const ANSICHAR *Str1 = appToAnsi(*Filename);
	const ANSICHAR *Str2 = appToAnsi(*Export.ObjectName);

	// JEP ...
	// Try to send the export back to the original package if this object is being serialized by a model
	if (GSpecialModelCase && !Export._Object && ( Export.ObjectFlags & _ContextFlags))		
	{
		if (this->ParentLinker)// && this != this->ParentLinker)
		{
			check(this->ParentLinker->ChildLinker == this);		// Make sure they are still properly connected

			ULinkerLoad		*Linker = this->ParentLinker;
		
			INT Index2 = Linker->FindExportIndex(GetExportClassName(Index), GetExportClassPackage(Index), Export.ObjectName, INDEX_NONE );

			if (Index2 != INDEX_NONE)
			{
				Export._Object = Linker->CreateExport(Index2);

				if (Export._Object)
				{
					Export.ExportObjFlags |= EF_CachedObject;		// Mark as cached, so this linker doesn't think it is the owner
					//debugf(NAME_Log,TEXT("Loading export from parent linker: %s, %s"), Export._Object->GetFullName(), *GetExportClassPackage(Index));
				}
			}
		}
	}
	// ... JEP

	// NJS:
	//if(Export.ObjectFlags & ~(RF_NotForServer|RF_NotForClient))
	//{
	//	Export.ObjectFlags&=~(RF_NotForServer|RF_NotForClient);
	//	Export.ObjectFlags|=(_ContextFlags&(RF_LoadForClient|RF_LoadForServer|RF_LoadForEdit));
	//}
	// .. NJS

	if( !Export._Object  && ( Export.ObjectFlags & _ContextFlags) )
	{
		check(Export.ObjectName!=NAME_None || !(Export.ObjectFlags&RF_Public));

		// Get the object's class.
		UClass* LoadClass = (UClass*)IndexToObject( Export.ClassIndex );
		if( !LoadClass )
			LoadClass = UClass::StaticClass();
		check(LoadClass);
		check(LoadClass->GetClass()==UClass::StaticClass());
		if( LoadClass->GetFName()==NAME_Camera )//oldver
			return NULL;

#if DNF
		// CDH: Temporary hack to convert meshes
		if (LoadFlags & LOAD_TempMerge)
		{			
			if (LoadClass->GetFName()==FName(TEXT("Mesh")))
			{
				static UClass* DukeMeshClass=NULL;
				for (TObjectIterator<UClass> It; It; ++It)
				{
					if (It->GetFName()==FName(TEXT("DukeMesh")))
					{
						DukeMeshClass = *It;
						break;
					}
				}
				if (DukeMeshClass)
					LoadClass = DukeMeshClass;
			}
		}
#endif

		Preload( LoadClass );

		// Get the outer object. If that caused the object to load, return it.
		UObject* ThisParent = Export.PackageIndex ? IndexToObject(Export.PackageIndex) : LinkerRoot;
		if( Export._Object )
			return Export._Object;

			//oldver: Move actors from root to level.
			/*if( Ver() <= 61 )
			{
				static UClass* ActorClass = FindObject<UClass>(ANY_PACKAGE,"Actor");
				static UClass* LevelClass = FindObject<UClass>(ANY_PACKAGE,"Level");
				if( ActorClass && LoadClass->IsChildOf(ActorClass) && ThisParent==LinkerRoot )
					ThisParent = StaticFindObjectChecked( LevelClass, LinkerRoot, "MyLevel" );
			}*/

		FName CreateName = Export.ObjectName;

		INT IsActor = 0;
		for( UClass* TempClass=LoadClass; TempClass; TempClass=(UClass*)TempClass->SuperField )
			if( TempClass==AActor::StaticClass() )
				IsActor = 1;

		if ( IsActor )
		{
			// See if we need to fix up the name.
			// If we are using an existing name, see if it is old style.
			TCHAR* c = appStrstr( *Export.ObjectName, TEXT("___") );
			if ( !c )
			{
				// Oldstyle name.  Copy into a buffer.
				TCHAR NewName[NAME_SIZE];
				appStrcpy( NewName, *Export.ObjectName );

				// Find out the are number on the end.
				TCHAR* End = NewName + appStrlen(NewName);
				while( End>NewName && appIsDigit(End[-1]) )
					End--;

				// Save the number on the end.
				TCHAR InstanceNum[NAME_SIZE];
				appStrcpy( InstanceNum, End );

				// Create a new name.
				appStrcpy( NewName, LoadClass->GetName() );
				appStrcat( NewName, TEXT("___") );
				appStrcat( NewName, InstanceNum );

				CreateName = FName( NewName );
			}
		}

		// Create the export object.
		Export._Object = StaticConstructObject
		(
			LoadClass,
			ThisParent,
			CreateName,
			(Export.ObjectFlags & RF_Load) | RF_NeedLoad | RF_NeedPostLoad
		);
		Export._Object->SetLinker( this, Index );
		GObjLoaded.AddItem( Export._Object );
		debugfSlow( NAME_DevLoad, TEXT("Created %s"), Export._Object->GetFullName() );

		// If it's a struct or class, set its parent.
		if( Export._Object->IsA(UStruct::StaticClass()) && Export.SuperIndex!=0 )
			((UStruct*)Export._Object)->SuperField = (UStruct*)IndexToObject( Export.SuperIndex );

		// If it's a class, bind it to C++.
		if( Export._Object->IsA( UClass::StaticClass() ) )
			((UClass*)Export._Object)->Bind();
	}
	return Export._Object;
}

// Return the loaded object corresponding to an import index; any errors are fatal.
UObject* ULinkerLoad::CreateImport( INT Index )
{
	FObjectImport& Import = ImportMap( Index );

	if( !Import.XObject && Import.SourceIndex>=0 )
	{
		//debugf( "Imported new %s %s.%s", *Import.ClassName, *Import.ObjectPackage, *Import.ObjectName );
		check(Import.SourceLinker);
		Import.XObject = Import.SourceLinker->CreateExport( Import.SourceIndex );
		GImportCount++;
	}
	return Import.XObject;
}

// Map an import/export index to an object; all errors here are fatal.
UObject* ULinkerLoad::IndexToObject( INT Index )
{
	if( Index > 0 )
	{
		if( !ExportMap.IsValidIndex( Index-1 ) )
			appErrorf( LocalizeError("ExportIndex"), Index-1, ExportMap.Num() );			
		return CreateExport( Index-1 );
	}
	else if( Index < 0 )
	{
		if( !ImportMap.IsValidIndex( -Index-1 ) )
			appErrorf( LocalizeError("ImportIndex"), -Index-1, ImportMap.Num() );
		return CreateImport( -Index-1 );
	}
	else return NULL;
}

// Detach an export from this linker.
void ULinkerLoad::DetachExport( INT i )
{
	FObjectExport& E = ExportMap( i );
	check(E._Object);
	if( !E._Object->IsValid() )
		appErrorf( TEXT("Linker object %s %s.%s is invalid"), *GetExportClassName(i), LinkerRoot->GetName(), *E.ObjectName );

	// JEP...
	if (E.ExportObjFlags & EF_CachedObject)		// JEP: Object was really loaded by another linker
	{
		check(!E._Object->GetLinker() || E._Object->GetLinker()!=this);
		E._Object = NULL;
		E.ExportObjFlags = 0;
		return;
	}
	// ... JEP

	if( E._Object->GetLinker()!=this)
		appErrorf( TEXT("Linker object %s %s.%s mislinked"), *GetExportClassName(i), LinkerRoot->GetName(), *E.ObjectName );
	if( E._Object->_LinkerIndex!=i)
		appErrorf( TEXT("Linker object %s %s.%s misindexed"), *GetExportClassName(i), LinkerRoot->GetName(), *E.ObjectName );

	ExportMap(i)._Object->SetLinker( NULL, INDEX_NONE );
}

// UObject interface.
void ULinkerLoad::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );
	LazyLoaders.CountBytes( Ar );
}

void ULinkerLoad::Destroy()
{
	debugf( TEXT("Unloading: %s"), LinkerRoot->GetFullName() );

	// Detach all lazy loaders.
	DetachAllLazyLoaders( 0 );

	// Detach all objects linked with this linker.
	for( INT i=0; i<ExportMap.Num(); i++ )
		if( ExportMap(i)._Object )
			DetachExport( i );

	// Remove from object manager, if it has been added.
	GObjLoaders.RemoveItem( this );
	if( Loader )
		delete Loader;
	Loader = NULL;

	Super::Destroy();
}

// FArchive interface.
void ULinkerLoad::AttachLazyLoader( FLazyLoader* LazyLoader )
{
	checkSlow(LazyLoader->SavedAr==NULL);
	checkSlow(LazyLoaders.FindItemIndex(LazyLoader)==INDEX_NONE);

	LazyLoaders.AddItem( LazyLoader );
	LazyLoader->SavedAr  = this;
	LazyLoader->SavedPos = Tell();
}

void ULinkerLoad::DetachLazyLoader( FLazyLoader* LazyLoader )
{
	checkSlow(LazyLoader->SavedAr==this);

	INT RemovedCount = LazyLoaders.RemoveItem(LazyLoader);
	if( RemovedCount!=1 )
		appErrorf( TEXT("Detachment inconsistency: %i (%s)"), RemovedCount, *Filename );
	LazyLoader->SavedAr = NULL;
	LazyLoader->SavedPos = 0;
}

void ULinkerLoad::DetachAllLazyLoaders( UBOOL Load )
{
	for( INT i=0; i<LazyLoaders.Num(); i++ )
	{
		FLazyLoader* LazyLoader = LazyLoaders( i );
		if( Load )
			LazyLoader->Load();
		LazyLoader->SavedAr  = NULL;
		LazyLoader->SavedPos = 0;
	}
	LazyLoaders.Empty();
}

// FArchive interface.
void ULinkerLoad::Seek( INT InPos )
{
	Loader->Seek( InPos );
}

INT ULinkerLoad::Tell()
{
	return Loader->Tell();
}

INT ULinkerLoad::TotalSize()
{
	return Loader->TotalSize();
}

void ULinkerLoad::Serialize( void* V, INT Length )
{
	Loader->Serialize( V, Length );
}

FArchive& ULinkerLoad::operator<<( UObject*& Object )
{
	INT Index;
	*Loader << AR_INDEX(Index);
	Object = IndexToObject( Index );

	return *this;
}

FArchive& ULinkerLoad::operator<<( FName& Name )
{
	NAME_INDEX NameIndex;
	*Loader << AR_INDEX(NameIndex);

	if( !NameMap.IsValidIndex(NameIndex) )
		appErrorf( TEXT("Bad name index %i/%i"), NameIndex, NameMap.Num() );	
	Name = NameMap( NameIndex );

	return *this;
}

/*----------------------------------------------------------------------------
	ULinkerSave.
----------------------------------------------------------------------------*/

ULinkerSave::ULinkerSave( UObject* InParent, const TCHAR* InFilename )
:	ULinker( InParent, InFilename )
,	Saver( NULL )
{
	// Create file saver.
	Saver = GFileManager->CreateFileWriter( InFilename, 0, GThrow );
	if( !Saver )
		appThrowf( LocalizeError("OpenFailed") );

	// Set main summary info.
	Summary.Tag				= PACKAGE_FILE_TAG;
	Summary.FileVersion		= PACKAGE_FILE_VERSION;
	Summary.LicenseeVersion	= PACKAGE_LICENSEE_VERSION; // CDH
	Summary.PackageFlags  = Cast<UPackage>(LinkerRoot) ? Cast<UPackage>(LinkerRoot)->PackageFlags : 0;

	// Set status info.
	ArIsSaving     = 1;
	ArIsPersistent = 1;
	ArForEdit      = GIsEditor;
	ArForClient    = 1;
	ArForServer    = 1;

	// Allocate indices.
	ObjectIndices.AddZeroed( UObject::GObjObjects.Num() );
	NameIndices  .AddZeroed( FName::GetMaxNames() );

	// Success.
	Success=1;
}

void ULinkerSave::Destroy()
{
	if( Saver )
		delete Saver;
	Saver = NULL;
	Super::Destroy();
}

// FArchive interface.
INT ULinkerSave::MapName( FName* Name )
{
	return NameIndices(Name->GetIndex());
}

INT ULinkerSave::MapObject( UObject* Object )
{
	return Object ? ObjectIndices(Object->GetIndex()) : 0;
}

// FArchive interface.
FArchive& ULinkerSave::operator<<( FName& Name )
{
	INT Save = NameIndices(Name.GetIndex());
	return *this << AR_INDEX(Save);
}

FArchive& ULinkerSave::operator<<( UObject*& Obj )
{
	INT Save = Obj ? ObjectIndices(Obj->GetIndex()) : 0;
	return *this << AR_INDEX(Save);
}

void ULinkerSave::Seek( INT InPos )
{
	Saver->Seek( InPos );
}

INT ULinkerSave::Tell()
{
	return Saver->Tell();
}

void ULinkerSave::Serialize( void* V, INT Length )
{
	Saver->Serialize( V, Length );
}

/*----------------------------------------------------------------------------
	The End.
----------------------------------------------------------------------------*/
