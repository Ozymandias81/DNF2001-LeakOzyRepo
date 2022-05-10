/*=============================================================================
	UMapConvertCommandlet.cpp: Converts old maps to the new format.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

Revision history:
	* Created by Warren Marshall.
=============================================================================*/

#include "EditorPrivate.h"

void RecomputePoly( FPoly* Poly );

/*-----------------------------------------------------------------------------
	UMapConvertCommandlet.
-----------------------------------------------------------------------------*/

void OldApplyTransformToBrush( ABrush* InBrush )
{
	if (InBrush->IsMovingBrush())
		return;

	FModelCoords Coords;
	FLOAT Orientation = InBrush->OldBuildCoords( &Coords, NULL );
	InBrush->Modify();

	// recompute new locations for all vertices based on the current transformations
	UPolys* Polys = InBrush->Brush->Polys;
	Polys->Element.ModifyAllItems();
	for( INT j=0; j<Polys->Element.Num(); j++ )
		Polys->Element(j).Transform( Coords, FVector(0,0,0), FVector(0,0,0), Orientation );

	// reset the transformations
	InBrush->PrePivot = InBrush->PrePivot.TransformVectorBy( Coords.PointXform );

	InBrush->MainScale = GMath.UnitScale;
	InBrush->PostScale = GMath.UnitScale;
	InBrush->Rotation  = FRotator(0,0,0);

	InBrush->Brush->BuildBound();
	InBrush->PostEditChange();
}

class UMapConvertCommandlet : public UCommandlet
{
	DECLARE_CLASS(UMapConvertCommandlet,UCommandlet,CLASS_Transient);
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
		GWarn->Logf( TEXT("Security clearance confirmed.\nInitiating map conversion.\n") );

		// Create the editor class.
		UClass* EditorEngineClass = UObject::StaticLoadClass( UEditorEngine::StaticClass(), NULL, TEXT("ini:Engine.Engine.EditorEngine"), NULL, LOAD_NoFail | LOAD_DisallowFiles, NULL );
		GEditor  = ConstructObject<UEditorEngine>( EditorEngineClass );
		GEditor->UseSound = 1;
		GEditor->Init();
		GIsRequestingExit = 1; // Causes ctrl-c to immediately exit.

		// Uses a path now.
		FString Path;
		if( !ParseToken(Parms,Path,0) )
			Path=TEXT(".");

		/*
		// Make sure we got all params.
		FString SrcFilename, DstFilename;
		if( !ParseToken(Parms,SrcFilename,0) )
			appErrorf(TEXT("Source filename not specified."));
		if( !ParseToken(Parms,DstFilename,0) )
			appErrorf(TEXT("Destination filename not specified."));
		*/

		// Convert all maps in this directory.
		TArray<FString> List = GFileManager->FindFiles(*Path,1,0);
		for( INT j=0; j<List.Num(); j++ )
		{
			// Load the map
			GWarn->Logf( TEXT("\nLoading: %s\n"), *List(j));
			GEditor->Exec( *FString::Printf(TEXT("MAP LOAD FILE=\"%s\""), *List(j)) );

			// Loop through all brushes and apply their transforms permanently.
			for( int i = 0 ; i < GEditor->Level->Actors.Num() ; i++ )
			{
				if( GEditor->Level->Actors(i) && GEditor->Level->Actors(i)->IsBrush() )
				{
					ABrush* Brush = (ABrush*)GEditor->Level->Actors(i);

					if (Brush->IsMovingBrush())
					{
						GWarn->Logf( TEXT("Skipping Mover......%s"), Brush->GetName() );
					} else {
						GWarn->Logf( TEXT("Converting Brush....%s"), Brush->GetName() );
						OldApplyTransformToBrush( Brush );
					}
				}
			}

			// Save the updated map
			GWarn->Logf( TEXT("\nSaving: %s"), *List(j));
			GEditor->Exec( *FString::Printf(TEXT("MAP SAVE FILE=\"%s\""), *List(j)) );
		}
		GWarn->Logf( TEXT("\nAll maps converted.  Praise the Golden Throne.  Praise the Emperor.\n") );
		GWarn->Logf( TEXT("Thought for the day:") );
		FLOAT WH40K = appFrand();
		if (WH40K < 0.2)
			GWarn->Logf( TEXT("  Philosophy is impious.  Thought is impure.  Obedience alone shall save you.") );
		else if (WH40K < 0.4)
			GWarn->Logf( TEXT("  Only when all enemy homeworlds are cleansed of life shall we celebrate victory.") );
		else if (WH40K < 0.6)
			GWarn->Logf( TEXT("  Kill the heretic with the Emperor's praise on your lips and you shall be blessed.") );
		else if (WH40K < 0.8)
			GWarn->Logf( TEXT("  Do not ponder your enemy.  Ponder his corpse.") );
		else
			GWarn->Logf( TEXT("  The bolter and the clip are holy.  Place them not on unclean earth.") );

		GIsRequestingExit=1;
		return 0;
	}
};
IMPLEMENT_CLASS(UMapConvertCommandlet)

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/