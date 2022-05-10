/*=============================================================================
	UnEdClick.cpp: Editor click-detection code.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

#include <windows.h>
#pragma comment (lib,"user32.lib")

#include "EditorPrivate.h"
#include "UnRender.h"

extern TArray<FVertexHit> VertexHitList;
extern FVector GGridBase;
extern FRotator GSnappedRotation;
extern void vertexedit_GetBrushList( TArray<ABrush*>* BrushList );

// Counts the number of ClipMarkers currently in the world.
int NumClipMarkers(void)
{
	int markers = 0;
	for( int i = 0 ; i < GEditor->Level->Actors.Num() ; i++ )
	{
		AActor* Actor = GEditor->Level->Actors(i);
		if( Actor && Actor->IsA(AClipMarker::StaticClass()) )
			markers++;
	}
	return markers;
}

// Adds a AClipMarker actor at the click location.
void AddClipMarker()
{
	// If there are 3 (or more) clipmarkers, already in the level delete them so the user can start fresh.
	if( NumClipMarkers() > 2 )
		GEditor->Exec( TEXT("BRUSHCLIP DELETE") );
	else
	{
		// Loop through the existing clip markers and fix up any wrong texture assignments
		// (texture names can become wrong if the user manually deletes a marker)
		UTexture* Texture;
		FString Str;
		int ClipMarker = 0;
		for( int i = 0 ; i < GEditor->Level->Actors.Num() ; i++ )
		{
			AActor* Actor = GEditor->Level->Actors(i);
			if( Actor && Actor->IsA(AClipMarker::StaticClass()) )
			{
				ClipMarker++;
				Str = *(FString::Printf(TEXT("TEXTURE=S_ClipMarker%d"), ClipMarker ) );
				if( ParseObject<UTexture>( *Str, TEXT("TEXTURE="), Texture, ANY_PACKAGE ) )
					Actor->Texture = Texture;
			}
		}

		// Create new clip marker
		FString TextureName = *(FString::Printf(TEXT("S_ClipMarker%d"), NumClipMarkers()+1 ) );
		GEditor->Exec( *(FString::Printf(TEXT("ACTOR ADD CLASS=CLIPMARKER SNAP=1 TEXTURE=%s"), *TextureName) ) );
	}
}

/*-----------------------------------------------------------------------------
	Adding actors.
-----------------------------------------------------------------------------*/

AActor* UEditorEngine::AddActor( ULevel* Level, UClass* Class, FVector V, UBOOL bSilent )
{
	check(Class);
	if( !bSilent ) debugf( NAME_Log, TEXT("addactor") );

	// Validate everything.
	if( Class->ClassFlags & CLASS_Abstract )
	{
		GWarn->Logf( TEXT("Class %s is abstract.  You can't add actors of this class to the world."), Class->GetName() );
		return NULL;
	}
	if( Class->ClassFlags & CLASS_NoUserCreate )
	{
		GWarn->Logf( TEXT("You can't add actors of this class to the world."), Class->GetName() );
		return NULL;
	}
	else if( Class->ClassFlags & CLASS_Transient )
	{
		GWarn->Logf( TEXT("Class %s is transient.  You can't add actors of this class."), Class->GetName() );
		return NULL;
	}
	else if( Class->ClassFlags & CLASS_Obsolete )
	{
		GWarn->Logf( TEXT("Class %s is obsolete.  You can't add obsolete actors."), Class->GetName() );
		return NULL;
	}

	// Transactionally add the actor.
	Trans->Begin( TEXT("Add Actor") );
	SelectNone( Level, 0 );
	Level->Modify();
	AActor* Actor = Level->SpawnActor( Class, NAME_None, NULL, NULL, V );
	if( Actor )
	{
		Actor->bDynamicLight = 1;
		Actor->bSelected     = 1;
		if( !Level->FarMoveActor( Actor, V ) )//necessary??!!
		{
			GWarn->Logf( TEXT("Actor doesn't fit there") );
			Level->DestroyActor( Actor );
		}
		else if( !bSilent ) debugf( NAME_Log, TEXT("Added actor successfully") );
		if( Class->GetDefaultActor()->IsBrush() )
			csgCopyBrush( (ABrush*)Actor, (ABrush*)Class->GetDefaultActor(), 0, 0, 1 );
		Actor->PostEditMove();
	}
	else GWarn->Logf( TEXT("Actor doesn't fit there") );
	Trans->End();

	NoteSelectionChange( Level );

	return Actor;
}

/*-----------------------------------------------------------------------------
	HTextureView.
-----------------------------------------------------------------------------*/

void HTextureView::Click( const FHitCause& Cause )
{
	check(Texture);
	Texture->Click( Cause.Buttons, Cause.MouseX*Texture->USize/ViewX, Cause.MouseY*Texture->VSize/ViewY );
}

/*-----------------------------------------------------------------------------
	HBackdrop.
-----------------------------------------------------------------------------*/

void HBackdrop::Click( const FHitCause& Cause )
{
	GEditor->ClickLocation = Location;
	GEditor->ClickPlane    = FPlane(0,0,0,0);

	if( Cause.Buttons&MOUSE_Middle && Cause.Buttons & MOUSE_Ctrl )
	{
		GEditor->Exec( *(FString::Printf( TEXT("CAMERA ALIGN X=%1.2f Y=%1.2f Z=%1.2f"), Location.X, Location.Y, Location.Z ) ) );
	}
	else if( GEditor->Mode == EM_BrushClip )
	{
		if( Cause.Buttons&MOUSE_Right && Cause.Buttons & MOUSE_Ctrl )
			AddClipMarker();
	}
	else if( GEditor->Mode == EM_Polygon && (Cause.Buttons&MOUSE_Right && Cause.Buttons & MOUSE_Ctrl) )
	{
		GEditor->Exec( TEXT("ACTOR ADD CLASS=POLYMARKER SNAP=1") );
	}
	else
	{
		if( (Cause.Buttons&MOUSE_Left) && Cause.Viewport->Input->KeyDown(IK_A) )
		{
			if( GEditor->CurrentClass )
			{
				TCHAR Cmd[256];
				appSprintf( Cmd, TEXT("ACTOR ADD CLASS=%s"), GEditor->CurrentClass->GetName() );
				GEditor->Exec( Cmd );
			}
		}
		else if( (Cause.Buttons&MOUSE_Left) && Cause.Viewport->Input->KeyDown(IK_L) )
		{
			GEditor->Exec( TEXT("ACTOR ADD CLASS=LIGHT") );
		}
		else if( Cause.Buttons & MOUSE_Right )
		{
			if( Cause.Viewport->IsOrtho() )
			{
				GEditor->EdCallback( EDC_RtClickWindowCanAdd, 0 );
			}
			else GEditor->EdCallback( EDC_RtClickWindow, 0 );
		}
		else if( Cause.Buttons & MOUSE_Left )
		{
			if( !(Cause.Buttons & MOUSE_Ctrl) )
			{
				GEditor->Trans->Begin( TEXT("Select None") );
				GEditor->SelectNone( Cause.Viewport->Actor->GetLevel(), 1 );
				GEditor->Trans->End();
			}
		}
	}
}

/*-----------------------------------------------------------------------------
	FEditorHitObserver implementation.
-----------------------------------------------------------------------------*/

static FBspSurf GSaveSurf;
void FEditorHitObserver::Click( const FHitCause& Cause, const struct HBspSurf& Hit )
{
	UModel*   Model = Cause.Viewport->Actor->GetLevel()->Model;
	FBspSurf& Surf  = Model->Surfs(Hit.iSurf);

	// Adding actor.
	check(Hit.Parent);
	check(Hit.Parent->IsA(TEXT("HCoords")));
	HCoords* HitCoords     = (HCoords*)Hit.Parent;
	FPlane	Plane		   = FPlane(Model->Points(Surf.pBase),Model->Vectors(Surf.vNormal));

	// Remember hit location for actor-adding.
	GEditor->ClickLocation = FLinePlaneIntersection( HitCoords->Coords.Origin, HitCoords->Coords.Origin + HitCoords->Direction, Plane );
	GEditor->ClickPlane    = Plane;

	if( (Cause.Buttons&MOUSE_Left) && (Cause.Buttons & MOUSE_Shift) && (Cause.Buttons & MOUSE_Ctrl) )
	{
		// Select the brush actor that belongs to this BSP surface.
		check( Surf.Actor );
		Surf.Actor->bSelected = 1;
		GEditor->NoteSelectionChange( Cause.Viewport->Actor->GetLevel() );
	}
	else if( (Cause.Buttons&MOUSE_Left) && (Cause.Buttons & MOUSE_Shift) )
	{
		// Apply texture to all selected.
		GEditor->Trans->Begin( TEXT("apply texture to selected surfaces") );
		for( INT i=0; i<Model->Surfs.Num(); i++ )
		{
			if( Model->Surfs(i).PolyFlags & PF_Selected )
			{
				Model->ModifySurf( i, 1 );
				Model->Surfs(i).Texture = GEditor->CurrentTexture;
				GEditor->polyUpdateMaster( Model, i, 0, 0 );
			}
		}
		GEditor->Trans->End();
	}
	else if( (Cause.Buttons&MOUSE_Left) && Cause.Viewport->Input->KeyDown(IK_A) )
	{
		if( GEditor->CurrentClass )
		{
			TCHAR Cmd[256];
			appSprintf( Cmd, TEXT("ACTOR ADD CLASS=%s"), GEditor->CurrentClass->GetName() );
			GEditor->Exec( Cmd );
		}
	}
	else if( (Cause.Buttons&MOUSE_Left) && Cause.Viewport->Input->KeyDown(IK_L) )
	{
		GEditor->Exec( TEXT("ACTOR ADD CLASS=LIGHT") );
	}
	else if( (Cause.Buttons&MOUSE_Alt) && (Cause.Buttons&MOUSE_Right) )
	{
		// Grab the texture.
		GEditor->CurrentTexture = Surf.Texture;
		GSaveSurf = Surf;
		GEditor->EdCallback( EDC_CurTexChange, 0 );
	}
	else if( (Cause.Buttons&MOUSE_Alt) && (Cause.Buttons&MOUSE_Left) )
	{
		// Apply texture to the one polygon clicked on.
		GEditor->Trans->Begin( TEXT("apply texture to surface") );
		Model->ModifySurf( Hit.iSurf, 1 );
		Surf.Texture = GEditor->CurrentTexture;
		if( Cause.Buttons & MOUSE_Ctrl )
		{
			Surf.vTextureU	= GSaveSurf.vTextureU;
			Surf.vTextureV	= GSaveSurf.vTextureV;
			if( Surf.vNormal == GSaveSurf.vNormal )
			{
				GLog->Logf( TEXT("WARNING: the texture coordinates were not parallel to the surface.") );
			}
			Surf.PolyFlags	= GSaveSurf.PolyFlags;
			Surf.PanU		= GSaveSurf.PanU;
			Surf.PanV		= GSaveSurf.PanV;
			
			// DNF Extensions:
			Surf.PolyFlags2 = GSaveSurf.PolyFlags2;
			Surf.SurfaceTag = GSaveSurf.SurfaceTag;

			GEditor->polyUpdateMaster( Model, Hit.iSurf, 1, 1 );
		}
		else
		{
			GEditor->polyUpdateMaster( Model, Hit.iSurf, 0, 0 );
		}
		GEditor->Trans->End();
	}
	else if( Cause.Buttons & MOUSE_Right ) 
	{
		// Edit surface properties.
		GEditor->Trans->Begin( TEXT("select surface for editing") );
		Model->ModifySurf( Hit.iSurf, 0 );
		Surf.PolyFlags |= PF_Selected;
		GEditor->NoteSelectionChange( Cause.Viewport->Actor->GetLevel() );
		GEditor->EdCallback( EDC_RtClickPoly, 0 );
		GEditor->Trans->End();
	}
	else
	{
		// Select or deselect surfaces.
		GEditor->Trans->Begin( TEXT("select surfaces") );
		DWORD SelectMask = Surf.PolyFlags & PF_Selected;
		if( !(Cause.Buttons & MOUSE_Ctrl) )
			GEditor->SelectNone( Cause.Viewport->Actor->GetLevel(), 0 );
		Model->ModifySurf( Hit.iSurf, 0 );
		Surf.PolyFlags = (Surf.PolyFlags & ~PF_Selected) | (SelectMask ^ PF_Selected);
		GEditor->NoteSelectionChange( Cause.Viewport->Actor->GetLevel() );
		GEditor->Trans->End();
	}
}
void FEditorHitObserver::Click( const FHitCause& Cause, const struct HActor& Hit )
{
	GEditor->Trans->Begin( TEXT("clicking on actors") );

	if( GEditor->Mode == EM_Polygon )
	{
		if( Hit.Actor->IsA(APolyMarker::StaticClass())
				|| (Cause.Buttons & MOUSE_Left && Hit.Actor->IsBrush()) )
		{
			// Toggle actor selection.
			Hit.Actor->Modify();
			if( Cause.Buttons & MOUSE_Ctrl )
			{
				Hit.Actor->bSelected ^= 1;
			}
			else
			{
				GEditor->SelectNone( Cause.Viewport->Actor->GetLevel(), 0 );
				Hit.Actor->bSelected = 1;
			}
			GEditor->NoteSelectionChange( Cause.Viewport->Actor->GetLevel() );
		}
		else
			if( Cause.Buttons & MOUSE_Right )
				if( Cause.Buttons & MOUSE_Ctrl )
					GEditor->Exec( TEXT("ACTOR ADD CLASS=POLYMARKER SNAP=1") );
				else
					GEditor->EdCallback( EDC_RtClickActor, 0 );
	}
	else if( GEditor->Mode == EM_BrushClip )
	{
		if( Hit.Actor->IsA(AClipMarker::StaticClass())
				|| (Cause.Buttons & MOUSE_Left && Hit.Actor->IsBrush()) )
		{
			// Toggle actor selection.
			Hit.Actor->Modify();
			if( Cause.Buttons & MOUSE_Ctrl )
			{
				Hit.Actor->bSelected ^= 1;
			}
			else
			{
				GEditor->SelectNone( Cause.Viewport->Actor->GetLevel(), 0 );
				Hit.Actor->bSelected = 1;
			}
			GEditor->NoteSelectionChange( Cause.Viewport->Actor->GetLevel() );
		}
		else
			if( Cause.Buttons & MOUSE_Right )
				if( Cause.Buttons & MOUSE_Ctrl )
					AddClipMarker();
				else
					GEditor->EdCallback( EDC_RtClickActor, 0 );
	}
	else
	{
		// Click on a non-vertex clears the current list of vertices.
		VertexHitList.Empty();

		// Handle selection.
		if( Cause.Buttons & MOUSE_Right )
		{
			// Bring up properties of this actor and other selected actors.
			Hit.Actor->Modify();
			Hit.Actor->bSelected = 1;
			GEditor->NoteSelectionChange( Cause.Viewport->Actor->GetLevel() );
			GEditor->EdCallback( EDC_RtClickActor, 0 );
		}
		else if( Cause.Buttons & MOUSE_LeftDouble )
		{
			if( !(Cause.Buttons & MOUSE_Ctrl) )
				GEditor->SelectNone( Cause.Viewport->Actor->GetLevel(), 0 );
			Hit.Actor->Modify();
			Hit.Actor->bSelected = 1;
			GEditor->NoteSelectionChange( Cause.Viewport->Actor->GetLevel() );
			GEditor->Exec( TEXT("HOOK ACTORPROPERTIES") );
		}
		else
		{
			// Toggle actor selection.
			Hit.Actor->Modify();
			if( Cause.Buttons & MOUSE_Ctrl )
			{
				if((GetAsyncKeyState('Q')&0x8000)||(GetAsyncKeyState('F')&0x8000)||(GetAsyncKeyState('M')&0x8000))
				{
					FName newTag=Hit.Actor->Tag;
					TCHAR newTagBuffer[1024];

					/* Do I need to generate a unique tag? */ 
					if(GetAsyncKeyState('Q')&0x8000||(((GetAsyncKeyState('F')&0x8000)||(GetAsyncKeyState('M')&0x8000))&&(newTag==Hit.Actor->GetClass()->GetFName())))
					{
						// Generate a unique ID for this class:
						for(INT i=1;i<100000;i++)
						{	
							appSprintf(newTagBuffer,TEXT("%s%i"),Hit.Actor->GetClass()->GetName(),i);
							newTag=FName(newTagBuffer);

							// Determine if tag is unique:
						
							ULevel *Level=Cause.Viewport->Actor->GetLevel();

							// Unselect all actors.
							for( INT j=0; j<Level->Actors.Num(); j++ )
							{
								AActor* Actor = Level->Actors(j);
								if( Actor && ( Actor->Tag==newTag || Actor->Event==newTag ))
									break;

							}

							/* Did I find an unused ID?: */
							if(j==Level->Actors.Num())
								break;
						}
					}

					// NJS: CTRL-Q/CTRL-F Code
					Hit.Actor->bSelected = 0;
					Hit.Actor->Tag=newTag;
					if(GetAsyncKeyState('M')&0x8000) GEditor->SelectSetMountParents( newTag, Cause.Viewport->Actor->GetLevel(), 0 );
					else							
						GEditor->SelectSetEvents( newTag, Cause.Viewport->Actor->GetLevel(), 0 );
					
					GEditor->SelectNone( Cause.Viewport->Actor->GetLevel(), 0 );
					Hit.Actor->bSelected = 1;
				}
				else
				{
					Hit.Actor->bSelected ^= 1;
				}
			}
			else
			{
				GEditor->SelectNone( Cause.Viewport->Actor->GetLevel(), 0 );
				Hit.Actor->bSelected = 1;
			}
			GEditor->NoteSelectionChange( Cause.Viewport->Actor->GetLevel() );
		}
	}
	GEditor->Trans->End();
}

// Attempts to add a vertex position to the list.
void vertexedit_AddPosition( ABrush* pBrush, INT PolyIndex, INT VertexIndex )
{
	// If this position is already in the list, leave.
	for( int vertex = 0 ; vertex < VertexHitList.Num() ; vertex++ )
		if( VertexHitList(vertex) == FVertexHit( pBrush, PolyIndex, VertexIndex ) )
			return;

	// Add it to the list.
	new(VertexHitList)FVertexHit( pBrush, PolyIndex, VertexIndex );

	// Save the polygons normal.  This is used for comparison purposes later on.
	pBrush->Brush->Polys->Element(PolyIndex).SaveNormal = pBrush->Brush->Polys->Element(PolyIndex).Normal;
	FVector blah = pBrush->Brush->Polys->Element(PolyIndex).SaveNormal;
}

void vertexedit_HandlePosition( ABrush* pBrush, INT PolyIndex, INT VertexIndex, UBOOL InCumulative, UBOOL InAllowDuplicates )
{
	if( InCumulative )
		for( INT vertex = 0 ; vertex < VertexHitList.Num() ; vertex++ )
			if( VertexHitList(vertex) == FVertexHit( pBrush, PolyIndex, VertexIndex ) )
			{
				if( !InAllowDuplicates )
					VertexHitList.Remove( vertex );
				return;
			}

	vertexedit_AddPosition( pBrush, PolyIndex, VertexIndex );
}

void vertexedit_Click( ABrush* pBrush, FVector InLocation, UBOOL InCumulative, UBOOL InAllowDuplicates )
{
	// If user is not doing a cumulative selection, empty out the current list.
	if( !InCumulative )
		VertexHitList.Empty();

	for( INT poly = 0 ; poly < pBrush->Brush->Polys->Element.Num() ; poly++ )
	{
		FPoly pPoly = pBrush->Brush->Polys->Element(poly);
		for( INT vertex = 0 ; vertex < pPoly.NumVertices ; vertex++ )
			if( FPointsAreSame( pPoly.Vertex[vertex], InLocation ) )
				vertexedit_HandlePosition( pBrush, poly, vertex, InCumulative, InAllowDuplicates );
	}
}

void FEditorHitObserver::Click( const FHitCause& Cause, const struct HActorVertex& Hit )
{
	// Set new pivot point.
	GEditor->Trans->Begin( TEXT("actor vertex selection") );
	GEditor->SetPivot( Hit.Location, (Cause.Buttons&MOUSE_Right)!=0, 1 );
	GEditor->Trans->End();
}
void FEditorHitObserver::Click( const FHitCause& Cause, const struct HBrushVertex& Hit )
{
	if( GEditor->Mode == EM_FaceDrag )
		return;
	else if( GEditor->Mode == EM_BrushClip )
	{
		AddClipMarker();
		return;
	}
	else if( GEditor->Mode == EM_Polygon )
	{
		GEditor->Exec( TEXT("ACTOR ADD CLASS=POLYMARKER SNAP=1") );
		return;
	}
	else if( GEditor->Mode == EM_VertexEdit )
	{
		if( Cause.Buttons & MOUSE_Right )
		{
			// Snap the vertex group to the grid.
			FVector NewLocation = Hit.Location;
			GEditor->Constraints.Snap( GEditor->Level, NewLocation, GGridBase, GSnappedRotation );
			FVector Delta = Hit.Location - NewLocation;

			for( INT x = 0 ; x < VertexHitList.Num() ; x++ )
			{
				FVector* Vertex = &(VertexHitList(x).pBrush->Brush->Polys->Element(VertexHitList(x).PolyIndex).Vertex[VertexHitList(x).VertexIndex]);
				*Vertex += Delta;
			}
			if( GEditor->Constraints.UseSizingBox )
			{
				TArray<ABrush*> Brushes;
				vertexedit_GetBrushList( &Brushes );
				for( INT brush = 0 ; brush < Brushes.Num() ; brush++ )
					Brushes(brush)->Brush->BuildBound();
			}
		}
		else
			vertexedit_Click( Hit.Brush, Hit.Location, (Cause.Buttons & MOUSE_Ctrl), 0 );
	}
	if( GEditor->Mode != EM_VertexEdit )
	{
		// Set new pivot point.
		GEditor->Trans->Begin( TEXT("brush vertex selection") );
		GEditor->SetPivot( Hit.Location, (Cause.Buttons&MOUSE_Right)!=0, 1 );
		GEditor->Trans->End();
	}
}
void FEditorHitObserver::Click( const FHitCause& Cause, const struct HGlobalPivot& Hit )
{
	if( GEditor->Mode == EM_Polygon )
	{
		GEditor->Exec( TEXT("ACTOR ADD CLASS=POLYMARKER SNAP=1") );
		return;
	}
	else if( GEditor->Mode == EM_BrushClip )
	{
		AddClipMarker();
		return;
	}
	else if( GEditor->Mode == EM_FaceDrag )
		return;

	// Set new pivot point.
	GEditor->Trans->Begin( TEXT("brush vertex selection") );
	GEditor->SetPivot( Hit.Location, (Cause.Buttons&MOUSE_Right)!=0, 1 );
	GEditor->Trans->End();
}
void FEditorHitObserver::Click( const FHitCause& Cause, const struct HBrowserTexture& Hit )
{
	if( Cause.Buttons==MOUSE_Left )
	{
		// Select textures.
		TCHAR Temp[256];
		appSprintf( Temp, TEXT("POLY DEFAULT TEXTURE=%s"), Hit.Texture->GetName() );
		GEditor->Exec( Temp );
		appSprintf( Temp, TEXT("POLY SET TEXTURE=%s"), Hit.Texture->GetName() );
		GEditor->Exec( Temp );
		GEditor->EdCallback( EDC_CurTexChange, 0 );
	}
	else if( Cause.Buttons==MOUSE_Right )
	{
		// Bring up texture popup menu.
		GEditor->CurrentTexture = Hit.Texture;
		GEditor->EdCallback( EDC_RtClickTexture, 0 );
	}
}
/*
void FEditorHitObserver::Click( const FHitCause& Cause, const struct HTerrain& Hit )
{
	check(Hit.Parent);
	check(Hit.Parent->IsA(TEXT("HCoords")));
	HCoords* HitCoords     = (HCoords*)Hit.Parent;
	FCheckResult Check;
	if( Hit.TerrainInfo->LineCheck( Check, HitCoords->Coords.Origin + HitCoords->Direction*1000, HitCoords->Coords.Origin, FVector(0,0,0) ) )
	{	
		GEditor->ClickLocation = Check.Location;
		GEditor->ClickPlane    = FPlane( Check.Location, Check.Normal );

		if( GEditor->Mode == EM_TerrainEdit && Cause.Buttons & MOUSE_Left ) 
		{
			GEditor->Trans->Begin( TEXT("terrain vertex selection") );
			Hit.TerrainInfo->bSelected = 1;
			Hit.TerrainInfo->SelectVertex( Check.Location );
			GEditor->Trans->End();
		}
		else
		if( Cause.Buttons & MOUSE_Right ) 
		{
			// Edit surface properties.
			Hit.TerrainInfo->bSelected ^= 1;
			GEditor->NoteSelectionChange( Cause.Viewport->Actor->GetLevel() );
			GEditor->EdCallback( EDC_RtClickWindowCanAdd, 0 );
		}
	}
}
*/

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
