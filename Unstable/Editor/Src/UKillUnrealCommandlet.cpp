/*=============================================================================
	UKillUnrealCommandlet.cpp: Dumps crap about bad map references.
	Copyright 2000 3D Realms, Inc. All Rights Reserved.

Revision history:
	* Created by Brandon Reinhart.
=============================================================================*/

#include "EditorPrivate.h"

/*-----------------------------------------------------------------------------
	UKillUnrealCommandlet
-----------------------------------------------------------------------------*/

class FArchiveCountMem : public FArchive
{
public:
	FArchiveCountMem( UObject* Src )
	: Num(0), Max(0)
	{
		Src->Serialize( *this );
	}
	SIZE_T GetNum()
	{
		return Num;
	}
	SIZE_T GetMax()
	{
		return Max;
	}
	void CountBytes( SIZE_T InNum, SIZE_T InMax )
	{
		Num += InNum;
		Max += InMax;
	}
protected:
	SIZE_T Num, Max;
};

struct FItem
{
	UClass*	Class;
	INT		Count;
	SIZE_T	Num, Max;
	FItem( UClass* InClass=NULL )
	: Class(InClass), Count(0), Num(0), Max(0)
	{}
	void Add( FArchiveCountMem& Ar )
	{Count++; Num+=Ar.GetNum(); Max+=Ar.GetMax();}
};
struct FSubItem
{
	UObject* Object;
	SIZE_T Num, Max;
	FSubItem( UObject* InObject, SIZE_T InNum, SIZE_T InMax )
	: Object( InObject ), Num( InNum ), Max( InMax )
	{}
};
static QSORT_RETURN CDECL CompareSubItems( const FSubItem* A, const FSubItem* B )
{
	return B->Max - A->Max;
}
static QSORT_RETURN CDECL CompareItems( const FItem* A, const FItem* B )
{
	return B->Max - A->Max;
}

class UKillUnrealCommandlet : public UCommandlet
{
	DECLARE_CLASS(UKillUnrealCommandlet,UCommandlet,CLASS_Transient);
	void StaticConstructor()
	{
		LogToStdout     = 0;
		IsClient        = 1;
		IsEditor        = 1;
		IsServer        = 1;
		LazyLoad        = 1;
		ShowErrorCount  = 1;
	}
	// ucc killunreal ..\maps\*.unr
	INT Main( const TCHAR* Parms )
	{
		FString Path;
		if( !ParseToken(Parms,Path,0) )
			Path=TEXT(".");

		// Get the classes we are searching for.
		UClass* TextureClass = FindObjectChecked<UClass>( ANY_PACKAGE, TEXT("texture") );
		UClass* SoundClass = FindObjectChecked<UClass>( ANY_PACKAGE, TEXT("sound") );

		// Search for everything and dump it out.
		TArray<FString> List = GFileManager->FindFiles(*Path,1,0);
		for( INT i=0; i<List.Num(); i++ )
		{
			GWarn->Logf(TEXT("Loading package %s..."), *List(i));
			LoadPackage(NULL,*List(i),LOAD_NoFail);
			TArray<FItem> List;
			TArray<FSubItem> Objects;
			FItem Total;
			for( FObjectIterator It; It; ++It )
			{
				if (It->IsA(TextureClass) || It->IsA(SoundClass))
				{
					FArchiveCountMem Count( *It );
					INT i;
					for( i=0; i<List.Num(); i++ )
						if( List(i).Class == It->GetClass() )
							break;
					if( i==List.Num() )
						i = List.AddItem(FItem( It->GetClass() ));
					new(Objects)FSubItem( *It, Count.GetNum(), Count.GetMax() );
					List(i).Add( Count );
					Total.Add( Count );
				}
			}
			if( Objects.Num() )
			{
				appQsort( &Objects(0), Objects.Num(), sizeof(Objects(0)), (QSORT_COMPARE)CompareSubItems );
				GWarn->Logf( TEXT("%60s % 10s % 10s"), TEXT("Object"), TEXT("NumBytes"), TEXT("MaxBytes") );
				for( INT i=0; i<Objects.Num(); i++ )
					GWarn->Logf( TEXT("%60s % 10i % 10i"), Objects(i).Object->GetFullName(), Objects(i).Num, Objects(i).Max );
				GWarn->Logf( TEXT("") );
			}
			if( List.Num() )
			{
				appQsort( &List(0), List.Num(), sizeof(List(0)), (QSORT_COMPARE)CompareItems );
				GWarn->Logf(TEXT(" %30s % 6s % 10s  % 10s "), TEXT("Class"), TEXT("Count"), TEXT("NumBytes"), TEXT("MaxBytes") );
				for( INT i=0; i<List.Num(); i++ )
					GWarn->Logf(TEXT(" %30s % 6i % 10iK % 10iK"), List(i).Class->GetName(), List(i).Count, List(i).Num/1024, List(i).Max/1024 );
				GWarn->Logf( TEXT("") );
			}
			GWarn->Logf( TEXT("%i Objects (%.3fM / %.3fM)"), Total.Count, (FLOAT)Total.Num/1024.0/1024.0, (FLOAT)Total.Max/1024.0/1024.0 );		
		}

		GIsRequestingExit=1;
		return 0;
	}
};
IMPLEMENT_CLASS(UKillUnrealCommandlet)

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
