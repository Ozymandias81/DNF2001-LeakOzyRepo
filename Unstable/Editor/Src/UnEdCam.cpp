/*=============================================================================
	UnEdCam.cpp: Unreal editor camera movement/selection functions
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

#include "EditorPrivate.h"
#include "UnRender.h"

extern void vertexedit_Click( ABrush* pBrush, FVector InLocation, UBOOL InCumulative, UBOOL InAllowDuplicates );

/*-----------------------------------------------------------------------------
	Globals.
-----------------------------------------------------------------------------*/

// Click flags.
enum EViewportClick
{
	CF_MOVE_ACTOR	= 1,	// Set if the actors have been moved since first click
	CF_MOVE_TEXTURE = 2,	// Set if textures have been adjusted since first click
	CF_MOVE_ALL     = (CF_MOVE_ACTOR | CF_MOVE_TEXTURE),
};

// Internal declarations.
void NoteTextureMovement( ULevel* Level );
void MoveActors( ULevel* Level, FVector Delta, FRotator DeltaRot, UBOOL Constrained, AActor* ViewActor, UBOOL bForceSnapping = 0 );

// Global variables.
__declspec(dllexport) INT GLastScroll=0;
INT GFixPanU=0, GFixPanV=0;
INT GFixScale=0;
INT GForceXSnap=0, GForceYSnap=0, GForceZSnap=0;
FString GTexNameFilter;

// Editor state.
UBOOL GPivotShown=0, GSnapping=0;
FVector GPivotLocation, GSnappedLocation, GGridBase;
FRotator GPivotRotation, GSnappedRotation;

// Temporary.
static TArray<INT> OriginalUVectors;
static TArray<INT> OriginalVVectors;
static INT OrigNumVectors=0;

/*-----------------------------------------------------------------------------
   Primitive mappings of input to axis movement and rotation.
-----------------------------------------------------------------------------*/

//
// Axial rotation.
//
void CalcAxialRot
( 
	UViewport*	Viewport, 
	SWORD		MouseX,
	SWORD		MouseY,
	DWORD		Buttons,
	FRotator&	Delta
)
{
	// Do single-axis movement.
	if	   ( (Buttons&(MOUSE_Left|MOUSE_Right))==(MOUSE_Left)             ) Delta.Pitch = +MouseX*4;
	else if( (Buttons&(MOUSE_Left|MOUSE_Right))==(MOUSE_Right)            )	Delta.Yaw   = +MouseX*4;
	else if( (Buttons&(MOUSE_Left|MOUSE_Right))==(MOUSE_Left|MOUSE_Right) ) Delta.Roll  = -MouseY*4;
}

//
// Freeform movement and rotation.
//
void CalcFreeMoveRot
(
	UViewport*	Viewport,
	FLOAT		MouseX,
	FLOAT		MouseY,
	DWORD		Buttons,
	FVector&	Delta,
	FRotator&	DeltaRot
)
{
	if( Viewport->IsOrtho() )
	{
		// Figure axes.
		FLOAT *OrthoAxis1, *OrthoAxis2, Axis2Sign, Axis1Sign, *OrthoAngle, AngleSign;
		FLOAT DeltaPitch = DeltaRot.Pitch;
		FLOAT DeltaYaw   = DeltaRot.Yaw;
		FLOAT DeltaRoll  = DeltaRot.Roll;
		if( Viewport->Actor->RendMap == REN_OrthXY )
		{
			OrthoAxis1 = &Delta.X;  	Axis1Sign = +1;
			OrthoAxis2 = &Delta.Y;  	Axis2Sign = +1;
			OrthoAngle = &DeltaYaw;		AngleSign = +1;
		}
		else if( Viewport->Actor->RendMap==REN_OrthXZ )
		{
			OrthoAxis1 = &Delta.X; 		Axis1Sign = +1;
			OrthoAxis2 = &Delta.Z; 		Axis2Sign = -1;
			OrthoAngle = &DeltaPitch; 	AngleSign = +1;
		}
		else if( Viewport->Actor->RendMap==REN_OrthYZ )
		{
			OrthoAxis1 = &Delta.Y; 		Axis1Sign = +1;
			OrthoAxis2 = &Delta.Z; 		Axis2Sign = -1;
			OrthoAngle = &DeltaRoll; 	AngleSign = +1;
		}
		else
		{
			appErrorf( TEXT("Invalid rendering mode") );
			return;
		}

		// Special movement controls.
		if( (Buttons&(MOUSE_Left|MOUSE_Right))==MOUSE_Left )
		{
			// Left button: Move up/down/left/right.
			*OrthoAxis1 = Viewport->Actor->OrthoZoom/30000.0f*(FLOAT)MouseX;
			if     ( MouseX<0 && *OrthoAxis1==0 ) *OrthoAxis1 = -Axis1Sign;
			else if( MouseX>0 && *OrthoAxis1==0 ) *OrthoAxis1 = +Axis1Sign;

			*OrthoAxis2 = Axis2Sign*Viewport->Actor->OrthoZoom/30000.0f*(FLOAT)MouseY;
			if     ( MouseY<0 && *OrthoAxis2==0 ) *OrthoAxis2 = -Axis2Sign;
			else if( MouseY>0 && *OrthoAxis2==0 ) *OrthoAxis2 = +Axis2Sign;
		}
		else if( (Buttons&(MOUSE_Left|MOUSE_Right))==(MOUSE_Left|MOUSE_Right) )
		{
			// Both buttons: Zoom in/out.
			Viewport->Actor->OrthoZoom -= Viewport->Actor->OrthoZoom/200.0f * (FLOAT)MouseY;
			if( Viewport->Actor->OrthoZoom<MIN_ORTHOZOOM ) Viewport->Actor->OrthoZoom = MIN_ORTHOZOOM;
			if( Viewport->Actor->OrthoZoom>MAX_ORTHOZOOM ) Viewport->Actor->OrthoZoom = MAX_ORTHOZOOM;
		}
		else if( (Buttons&(MOUSE_Left|MOUSE_Right))==MOUSE_Right )
		{
			// Right button: Rotate.
			if( OrthoAngle!=NULL )
				*OrthoAngle = -AngleSign*8.0f*(FLOAT)MouseX;
		}
		DeltaRot.Pitch	= appRound(DeltaPitch);
		DeltaRot.Yaw	= appRound(DeltaYaw);
		DeltaRot.Roll	= appRound(DeltaRoll);
	}
	else
	{
		APlayerPawn* Actor = Viewport->Actor;
		if( (Buttons&(MOUSE_Left|MOUSE_Right))==(MOUSE_Left) )
		{
			// Left button: move ahead and yaw.
			Delta.X      = -MouseY * GMath.CosTab(Actor->ViewRotation.Yaw);
			Delta.Y      = -MouseY * GMath.SinTab(Actor->ViewRotation.Yaw);
			DeltaRot.Yaw = +MouseX * 64.0f / 20.0f;
		}
		else if( (Buttons&(MOUSE_Left|MOUSE_Right))==(MOUSE_Left|MOUSE_Right) )
		{
			// Both buttons: Move up and left/right.
			Delta.X      = +MouseX * -GMath.SinTab(Actor->ViewRotation.Yaw);
			Delta.Y      = +MouseX *  GMath.CosTab(Actor->ViewRotation.Yaw);
			Delta.Z      = -MouseY;
		}
		else if( (Buttons&(MOUSE_Left|MOUSE_Right))==(MOUSE_Right) )
		{
			// Right button: Pitch and yaw.
			DeltaRot.Pitch = (64.0f/12.0f) * -MouseY;
			DeltaRot.Yaw   = (64.0f/20.0f) * +MouseX;
		}
	}
}

//
// Perform axial movement and rotation.
//
void CalcAxialMoveRot
(
	UViewport*	Viewport,
	FLOAT		MouseX,
	FLOAT		MouseY,
	DWORD		Buttons,
	FVector&	Delta,
	FRotator&	DeltaRot
)
{
	if( Viewport->IsOrtho() )
	{
		// Figure out axes.
		FLOAT *OrthoAxis1,*OrthoAxis2,Axis2Sign,Axis1Sign,*OrthoAngle,AngleSign;
		FLOAT DeltaPitch = DeltaRot.Pitch;
		FLOAT DeltaYaw   = DeltaRot.Yaw;
		FLOAT DeltaRoll  = DeltaRot.Roll;
		if( Viewport->Actor->RendMap == REN_OrthXY )
		{
			OrthoAxis1 = &Delta.X;  	Axis1Sign = +1;
			OrthoAxis2 = &Delta.Y;  	Axis2Sign = +1;
			OrthoAngle = &DeltaYaw;		AngleSign = +1;
		}
		else if( Viewport->Actor->RendMap == REN_OrthXZ )
		{
			OrthoAxis1 = &Delta.X; 		Axis1Sign = +1;
			OrthoAxis2 = &Delta.Z;		Axis2Sign = -1;
			OrthoAngle = &DeltaPitch; 	AngleSign = +1;
		}
		else if( Viewport->Actor->RendMap == REN_OrthYZ )
		{
			OrthoAxis1 = &Delta.Y; 		Axis1Sign = +1;
			OrthoAxis2 = &Delta.Z; 		Axis2Sign = -1;
			OrthoAngle = &DeltaRoll; 	AngleSign = +1;
		}
		else
		{
			appErrorf( TEXT("Invalid rendering mode") );
			return;
		}

		// Special movement controls.
		if( Buttons & (MOUSE_Left | MOUSE_Right) )
		{
			// Left, right, or both are pressed.
			if( Buttons & MOUSE_Left )
			{
				// Left button: Screen's X-Axis.
      			*OrthoAxis1 = Viewport->Actor->OrthoZoom/30000.0f*(FLOAT)MouseX;
      			if     ( MouseX<0 && *OrthoAxis1==0 ) *OrthoAxis1 = -Axis1Sign;
      			else if( MouseX>0 && *OrthoAxis1==0 ) *OrthoAxis1 = +Axis1Sign;
			}
			if( Buttons & MOUSE_Right )
			{
				// Right button: Screen's Y-Axis.
      			*OrthoAxis2 = Axis2Sign*Viewport->Actor->OrthoZoom/30000.0f*(FLOAT)MouseY;
      			if     ( MouseY<0 && *OrthoAxis2==0 ) *OrthoAxis2 = -Axis2Sign;
      			else if( MouseY>0 && *OrthoAxis2==0 ) *OrthoAxis2 = +Axis2Sign;
			}
		}
		else if( Buttons & MOUSE_Middle )
		{
			// Middle button: Zoom in/out.
			Viewport->Actor->OrthoZoom -= Viewport->Actor->OrthoZoom/200.0f * (FLOAT)MouseY;
			if	   ( Viewport->Actor->OrthoZoom<MIN_ORTHOZOOM ) Viewport->Actor->OrthoZoom = MIN_ORTHOZOOM;
			else if( Viewport->Actor->OrthoZoom>MAX_ORTHOZOOM ) Viewport->Actor->OrthoZoom = MAX_ORTHOZOOM;
		}
		DeltaRot.Pitch	= appRound(DeltaPitch);
		DeltaRot.Yaw	= appRound(DeltaYaw);
		DeltaRot.Roll	= appRound(DeltaRoll);
	}
	else
	{
		// Do single-axis movement.
		if		((Buttons&(MOUSE_Left|MOUSE_Right))==(MOUSE_Left))			   Delta.X = +MouseX;
		else if ((Buttons&(MOUSE_Left|MOUSE_Right))==(MOUSE_Right))			   Delta.Y = +MouseX;
		else if ((Buttons&(MOUSE_Left|MOUSE_Right))==(MOUSE_Left|MOUSE_Right)) Delta.Z = -MouseY;
	}
}

//
// Mixed movement and rotation.
//
void CalcMixedMoveRot
(
	UViewport*	Viewport,
	FLOAT		MouseX,
	FLOAT		MouseY,
	DWORD		Buttons,
	FVector&	Delta,
	FRotator&	DeltaRot
)
{
	if( Viewport->IsOrtho() )
		CalcFreeMoveRot( Viewport, MouseX, MouseY, Buttons, Delta, DeltaRot );
	else
		CalcAxialMoveRot( Viewport, MouseX, MouseY, Buttons, Delta, DeltaRot );
}

/*-----------------------------------------------------------------------------
   Viewport movement computation.
-----------------------------------------------------------------------------*/

extern FVector GBoxSelStart, GBoxSelEnd;
extern UBOOL GbIsBoxSel;
extern FVector GOldSnapScaleStart, GOldSnapScaleEnd, GSnapScaleStart, GSnapScaleEnd;
extern UBOOL GbIsSnapScaleBox;

//
// Move and rotate viewport freely.
//
void ViewportMoveRot
(
	UViewport*	Viewport,
	FVector&	Delta,
	FRotator&	DeltaRot
)
{
	Viewport->Actor->ViewRotation.AddBounded( DeltaRot.Pitch, DeltaRot.Yaw, DeltaRot.Roll );
	Viewport->Actor->Location.AddBounded( Delta, HALF_WORLD_MAX1 );
}

//
// Move and rotate viewport using gravity and collision where appropriate.
//
void ViewportMoveRotWithPhysics
(
	UViewport*	Viewport,
	FVector&	Delta,
	FRotator&	DeltaRot
)
{
	Viewport->Actor->ViewRotation.AddBounded( 4.0f*DeltaRot.Pitch, 4.0f*DeltaRot.Yaw, 4.0f*DeltaRot.Roll );
	Viewport->Actor->Location.AddBounded( Delta, HALF_WORLD_MAX1 );
}

/*-----------------------------------------------------------------------------
   Scale functions.
-----------------------------------------------------------------------------*/

//
// See if a scale is within acceptable bounds:
//
UBOOL ScaleIsWithinBounds( FVector* V, FLOAT Min, FLOAT Max )
{
	FLOAT Temp;

	Temp = Abs(V->X);
	if( Temp<Min || Temp>Max )
		return 0;

	Temp = Abs (V->Y);
	if( Temp<Min || Temp>Max )
		return 0;

	Temp = Abs (V->Z);
	if( Temp<Min || Temp>Max )
		return 0;

	return 1;
}

/*-----------------------------------------------------------------------------
   Change transacting.
-----------------------------------------------------------------------------*/

//
// If this is the first time called since first click, note all selected actors.
//
void UEditorEngine::NoteActorMovement( ULevel* Level )
{
	UBOOL Found=0;
	if( !GUndo && !(GEditor->ClickFlags & CF_MOVE_ACTOR) )
	{
		GEditor->ClickFlags |= CF_MOVE_ACTOR;
		GEditor->Trans->Begin( TEXT("Actor movement") );
		GSnapping=0;
		for( INT i=0; i<Level->Actors.Num(); i++ )
		{
			AActor* Actor = Level->Actors(i);
			if( Actor && Actor->bSelected )
				break;
		}
		if( i==Level->Actors.Num() )
		{
			Level->Brush()->Modify();
			Level->Brush()->bSelected = 1;
			GEditor->NoteSelectionChange( Level );
		}
		for( i=0; i<Level->Actors.Num(); i++ )
		{
			AActor* Actor = Level->Actors(i);
			if( Actor && Actor->bSelected && Actor->bEdShouldSnap )
				GSnapping = 1;
		}
		for( i=0; i<Level->Actors.Num(); i++ )
		{
			AActor* Actor = Level->Actors(i);
			if( Actor && Actor->bSelected )
			{
				Actor->Modify();
				Actor->bEdSnap |= GSnapping;
				Found=1;
			}
		}
		GEditor->Trans->End();
	}
}

//
// Finish snapping all brushes in a level.
//
void UEditorEngine::FinishAllSnaps( ULevel* Level )
{
	ClickFlags &= ~CF_MOVE_ACTOR;
	for( INT i=0; i<Level->Actors.Num(); i++ )
		if( Level->Actors(i) && Level->Actors(i)->bSelected )
			Level->Actors(i)->PostEditMove();
}

//
// Set the editor's pivot location.
//
void UEditorEngine::SetPivot( FVector NewPivot, UBOOL SnapPivotToGrid, UBOOL DoMoveActors )
{
	// Set the pivot.
	GPivotLocation   = NewPivot;
	GPivotRotation   = FRotator(0,0,0);
	GGridBase        = FVector(0,0,0);
	GSnappedLocation = GPivotLocation;
	GSnappedRotation = GPivotRotation;
	if( GSnapping || SnapPivotToGrid )
		Constraints.Snap( Level, GSnappedLocation, GGridBase, GSnappedRotation );
	if( SnapPivotToGrid )
	{
		if( DoMoveActors )
			MoveActors( Level, GSnappedLocation-GPivotLocation, FRotator(0,0,0), 0, NULL );
		GPivotLocation = GSnappedLocation;
		GPivotRotation = GSnappedRotation;
	}
	else
	{
		GGridBase = GPivotLocation - GSnappedLocation;
		GSnappedLocation = GPivotLocation;
		Constraints.Snap( Level, GSnappedLocation, GGridBase, GSnappedRotation );
		GPivotLocation = GSnappedLocation;
	}

	// Check all actors.
	INT Count=0, SnapCount=0;
	AActor* SingleActor=NULL;
	for( INT i=0; i<Level->Actors.Num(); i++ )
	{
		if( Level->Actors(i) && Level->Actors(i)->bSelected )
		{
			Count++;
			SnapCount += Level->Actors(i)->bEdShouldSnap;
			SingleActor = Level->Actors(i);
		}
	}

	// Apply to actors.
	if( Count==1 )
	{
		ABrush* Brush=Cast<ABrush>( SingleActor );
		if( Brush )
		{
			if ( !Brush->IsA(ADoorMover::StaticClass()) ) // !BR Maybe change to a variable.
			{
				FModelCoords Coords, Uncoords;
				Brush->BuildCoords( &Coords, &Uncoords );
				Brush->Modify();
				Brush->PrePivot += (GSnappedLocation - Brush->Location).TransformVectorBy( Uncoords.PointXform );
				Brush->Location = GSnappedLocation;
				Brush->PostEditChange();
			}
		}
	}

	// Update showing.
	GPivotShown = SnapCount>0 || Count>1;
}

//
// Reset the editor's pivot location.
//
void UEditorEngine::ResetPivot()
{
	GPivotShown = 0;
	GSnapping   = 0;
}

//
// Move a single actors.
//
void MoveSingleActor( AActor* Actor, FVector Delta, FRotator DeltaRot )
{
	if( Delta != FVector(0,0,0) )
	{
		Actor->bDynamicLight = 1;
		Actor->bLightChanged = 1;
	}
	Actor->Location.AddBounded( Delta, HALF_WORLD_MAX1 );

	if( Actor->IsBrush() && !Actor->IsMovingBrush() )
	{
		if( !DeltaRot.IsZero() )
		{
			// Rotate brush vertices
			ABrush* Brush = (ABrush*)Actor;
			for( INT poly = 0 ; poly < Brush->Brush->Polys->Element.Num() ; poly++ )
			{
				FPoly* Poly = &(Brush->Brush->Polys->Element(poly));

				// Rotate the vertices
				for( INT vertex = 0 ; vertex < Poly->NumVertices ; vertex++ )
					Poly->Vertex[vertex] = Brush->PrePivot + ( Poly->Vertex[vertex] - Brush->PrePivot ).TransformVectorBy( GMath.UnitCoords * DeltaRot );
				Poly->Base = Brush->PrePivot + ( Poly->Base - Brush->PrePivot ).TransformVectorBy( GMath.UnitCoords * DeltaRot );

				// Rotate the texture vectors
				Poly->TextureU = Poly->TextureU.TransformVectorBy( GMath.UnitCoords * DeltaRot );
				Poly->TextureV = Poly->TextureV.TransformVectorBy( GMath.UnitCoords * DeltaRot );

				// Recalc the normal for the poly
				Poly->Normal = FVector(0,0,0);	// Force the normal to recalc
				Poly->Finalize(0);
			}

			Brush->Brush->BuildBound();
		}
	}
	else
		Actor->Rotation += DeltaRot;

	if( Cast<APawn>( Actor ) )
		Cast<APawn>( Actor )->ViewRotation = Actor->Rotation;
}

TArray<FVertexHit> VertexHitList;

//
// Move and rotate actors.
//
void MoveActors( ULevel* Level, FVector Delta, FRotator DeltaRot, UBOOL Constrained, AActor* ViewActor, UBOOL bForceSnapping )
{
	if( Delta.IsZero() && DeltaRot.IsZero() )
		return;

	// Transact the actors.
	GEditor->NoteActorMovement( Level );

	// Update global pivot.
	if( Constrained )
	{
		FVector   OldLocation = GSnappedLocation;
		FRotator OldRotation = GSnappedRotation;
		GSnappedLocation      = (GPivotLocation += Delta   );
		GSnappedRotation      = (GPivotRotation += DeltaRot);
		if( GSnapping || bForceSnapping )
			GEditor->Constraints.Snap( Level, GSnappedLocation, GGridBase, GSnappedRotation );
		Delta                 = GSnappedLocation - OldLocation;
		DeltaRot              = GSnappedRotation - OldRotation;
	}

	if( GbIsBoxSel )
	{
		GBoxSelEnd += Delta;
		return;
	}

	// Move the actors.
	if( Delta!=FVector(0,0,0) || DeltaRot!=FRotator(0,0,0) )
	{
		for( INT i=0; i<Level->Actors.Num(); i++ )
		{
			AActor* Actor = Level->Actors(i);
			if( Actor && (Actor->bSelected || Actor==ViewActor) )
			{
				// Cannot move brushes while in brush clip mode - only regular actors.
				// This allows you to adjust the clipping marker positions, but the brushes
				// will remain locked in place.
				if( GEditor->Mode == EM_BrushClip && Actor->IsBrush() )
					continue;

				// Can't move any actors while in vertex editing mode
				if( GEditor->Mode == EM_VertexEdit || GEditor->Mode == EM_FaceDrag )
				{
					for( INT vertex = 0 ; vertex < VertexHitList.Num() ; vertex++ )
					{
						FVector* Vtx = &(VertexHitList(vertex).pBrush->Brush->Polys->Element(VertexHitList(vertex).PolyIndex).Vertex[VertexHitList(vertex).VertexIndex]);

						FVector Vertex = Vtx->TransformPointBy( VertexHitList(vertex).pBrush->ToWorld() );
						Vertex += Delta;
						*Vtx = Vertex.TransformPointBy( VertexHitList(vertex).pBrush->ToLocal() );
					}
					continue;
				}

				FVector Arm   = GSnappedLocation - Actor->Location;
				FVector Rel   = Arm - Arm.TransformVectorBy(GMath.UnitCoords * DeltaRot);
				MoveSingleActor( Actor, Delta + Rel, DeltaRot );
			}
		}
	}
}

#if 1 //LEGEND
/*-----------------------------------------------------------------------------
   Vertex editing functions.
-----------------------------------------------------------------------------*/

struct FPolyVertex {
	FPolyVertex::FPolyVertex() {} // CDH: so TArray::Add will compile with constructor call
	FPolyVertex::FPolyVertex( INT i, INT j ) : PolyIndex(i), VertexIndex(j) {};
	INT PolyIndex;
	INT VertexIndex;
};

static AActor* VertexEditActor=NULL;
static TArray<FPolyVertex> VertexEditList;

//
// Find the selected brush and grab the closest vertex when <Alt> is pressed
//
void GrabVertex( ULevel* Level )
{
	if( VertexEditActor!=NULL )
		return;

	// Find the selected brush -- abort if none is found.
	AActor* Actor=NULL;
	for( INT i=0; i<Level->Actors.Num(); i++ )
	{
		Actor = Level->Actors(i);
		if( Actor && Actor->bSelected && Actor->IsBrush() )
		{
			VertexEditActor = Actor;
			break;
		}
	}
	if( VertexEditActor==NULL )
		return;

	//!! Tim, Undo doesn't seem to work for vertex editing.  Do I need to set RF_Transactional? LEGEND
	VertexEditActor->Brush->Modify();

	// examine all the points and grab those that are within range of the pivot location
	UPolys* Polys = VertexEditActor->Brush->Polys;
	for( i=0; i<Polys->Element.Num(); i++ ) 
	{
		FCoords BrushC(VertexEditActor->ToWorld());
		for( INT j=0; j<Polys->Element(i).NumVertices; j++ ) 
		{
			FVector Location = Polys->Element(i).Vertex[j].TransformPointBy(BrushC);
			// match GPivotLocation against Brush's vertex positions -- find "close" vertex
			if( FDist( Location, GPivotLocation ) < GEditor->Constraints.SnapDistance ) {
				VertexEditList.AddItem( FPolyVertex( i, j ) );
			}
		}
	}
}

void RecomputePoly( FPoly* Poly )
{
	// force recalculation of normal, and texture U and V coordinates in FPoly::Finalize()
	Poly->Normal = FVector(0,0,0);

	// catch normalization exceptions to warn about non-planar polys
	try
	{
		Poly->Finalize( 0 );
	}
	catch(...)
	{
		debugf( TEXT("WARNING: FPoly::Finalize() failed! (You broke the poly!)") );
	}
}

//
// Release the vertex when <Alt> is released, then update the brush
//
void ReleaseVertex( ULevel* Level )
{
	if( VertexEditActor==NULL )
		return;

	// finalize all the polys in the brush (recompute poly surface and TextureU/V normals)
	UPolys* Polys = VertexEditActor->Brush->Polys;
	for( INT i=0; i<Polys->Element.Num(); i++ ) 
		RecomputePoly( &Polys->Element(i) );

	VertexEditActor->Brush->BuildBound();

	VertexEditActor=NULL;
	VertexEditList.Empty();
}

//
// Move a vertex.
//
void MoveVertex( ULevel* Level, FVector Delta, UBOOL Constrained )
{
	// Transact the actors.
	GEditor->NoteActorMovement( Level );

	if( VertexEditActor==NULL )
		return;

	// Update global pivot.
	if( Constrained )
	{
		FVector OldLocation = GSnappedLocation;
		GSnappedLocation = ( GPivotLocation += Delta );
		if( GSnapping )
		{
			GGridBase = FVector(0,0,0);
			GEditor->Constraints.Snap( Level, GSnappedLocation, GGridBase, GSnappedRotation );
		}
		Delta = GSnappedLocation - OldLocation;
	}

	// Move the vertex.
	if( Delta!=FVector(0,0,0) )
	{
		// examine all the points
		UPolys* Polys = VertexEditActor->Brush->Polys;

		Polys->Element.ModifyAllItems();

		FModelCoords Uncoords;
		((ABrush*)VertexEditActor)->BuildCoords( NULL, &Uncoords );
		VertexEditActor->Brush->Modify();
		for( INT k=0; k<VertexEditList.Num(); k++ ) 
		{
			INT i = VertexEditList(k).PolyIndex;
			INT j = VertexEditList(k).VertexIndex;
			Polys->Element(i).Vertex[j] += Delta.TransformVectorBy( Uncoords.PointXform );
		}
		VertexEditActor->Brush->PostEditChange();
	}
}
#endif

/*-----------------------------------------------------------------------------
   Editor surface transacting.
-----------------------------------------------------------------------------*/

//
// If this is the first time textures have been adjusted since the user first
// pressed a mouse button, save selected polygons transactionally so this can
// be undone/redone:
//
void NoteTextureMovement( ULevel* Level )
{
	if( !GUndo && !(GEditor->ClickFlags & CF_MOVE_TEXTURE) )
	{
		GEditor->Trans->Begin( TEXT("Texture movement") );
		Level->Model->ModifySelectedSurfs(1);
		GEditor->Trans->End ();
		GEditor->ClickFlags |= CF_MOVE_TEXTURE;
	}
}

// Checks the array of vertices and makes sure that the brushes in that list are still selected.  If not,
// the vertex is removed from the list.
void vertexedit_Refresh()
{
	for( INT vertex = 0 ; vertex < VertexHitList.Num() ; vertex++ )
		if( !VertexHitList(vertex).pBrush->bSelected )
		{
			VertexHitList.Remove(vertex);
			vertex = 0;
		}
}

// Fills up an array with a unique list of brushes which have vertices selected on them.
void vertexedit_GetBrushList( TArray<ABrush*>* BrushList )
{
	UBOOL bExists;

	BrushList->Empty();

	// Build a list of unique brushes
	//
	for( INT vertex = 0 ; vertex < VertexHitList.Num() ; vertex++ )
	{
		bExists = 0;

		for( INT x = 0 ; x < BrushList->Num() && !bExists ; x++ )
		{
			if( VertexHitList(vertex).pBrush == (*BrushList)(x) )
			{
				bExists = 1;
				break;
			}
		}

		if( !bExists )
			(*BrushList)( BrushList->Add() ) = VertexHitList(vertex).pBrush;
	}
}

/*-----------------------------------------------------------------------------
   Editor viewport movement.
-----------------------------------------------------------------------------*/

//
// Move the edit-viewport.
//
void UEditorEngine::MouseDelta
(
	UViewport*	Viewport,
	DWORD		Buttons,
	FLOAT		MouseX,
	FLOAT		MouseY
)
{
	FVector     	Delta,Vector,SnapMin,SnapMax,DeltaMin,DeltaMax,DeltaFree;
	FRotator		DeltaRot;
	FLOAT			TempFloat,Speed;
//	INT				i;
	static FLOAT	TextureAngle=0.0;

	if( Viewport->Actor->RendMap==REN_TexView )
	{
		if( Buttons & MOUSE_FirstHit )
		{
			Viewport->SetMouseCapture( 0, 1 );
		}
		else if( Buttons & MOUSE_LastRelease )
		{
			Viewport->SetMouseCapture( 0, 0 );
		}
		return;
	}
	else if( Viewport->Actor->RendMap==REN_TexBrowser )
	{
		return;
	}

	ABrush* BrushActor = Viewport->Actor->GetLevel()->Brush();

	Delta.X    		= 0.0;  Delta.Y  		= 0.0;  Delta.Z   		= 0.0;
	DeltaRot.Pitch	= 0.0;  DeltaRot.Yaw	= 0.0;  DeltaRot.Roll	= 0.0;
	//
	if( Buttons & MOUSE_FirstHit )
	{
		// Reset flags that last for the duration of the click.
		Viewport->SetMouseCapture( 1, 1 );
		ClickFlags &= ~(CF_MOVE_ALL);
		BrushActor->Modify();

		if( Mode==EM_VertexEdit )
		{
			GEditor->Trans->Begin( TEXT("Vertex Editing") );

			for( INT vertex = 0 ; vertex < VertexHitList.Num() ; vertex++ )
			{
				VertexHitList(vertex).pBrush->Modify();
				VertexHitList(vertex).pBrush->Brush->Polys->Modify();
			}

			// Move the pivot point to the first vertex in the selection list.
			if( VertexHitList.Num() )
			{
				FCoords BrushW(VertexHitList(0).pBrush->ToWorld());
				FVector Vertex = VertexHitList(0).pBrush->Brush->Polys->Element(VertexHitList(0).PolyIndex).Vertex[VertexHitList(0).VertexIndex].TransformPointBy(BrushW);
				SetPivot( Vertex, 1, 0 );
			}
		}
		else if( Mode==EM_FaceDrag )
		{
			GEditor->Trans->Begin( TEXT("Face Dragging") );

			VertexHitList.Empty();

			if( Viewport->IsOrtho() )
			{
				// Loop through all the faces on the selected brushes.  For each one that qualifies to
				// be dragged, add it's vertices to the vertex editing list.
				for( INT i = 0 ; i < Level->Actors.Num() ; i++ )
				{
					AActor* Actor = Level->Actors(i);
					if( Actor && Actor->bSelected && Actor->IsBrush() )
					{
						FVector ClickLocation = GEditor->ClickLocation.TransformPointBy( Actor->ToLocal() );

						if( Viewport->Actor->RendMap == REN_OrthXY )
							ClickLocation.Z = 0;
						else if( Viewport->Actor->RendMap == REN_OrthXZ )
							ClickLocation.Y = 0;
						else
							ClickLocation.X = 0;
	
						for( INT poly = 0 ; poly < Actor->Brush->Polys->Element.Num() ; poly++ )
						{
							FPoly* Poly = &(Actor->Brush->Polys->Element(poly));

							FVector TestVector = Poly->Base - ClickLocation;
							TestVector.Normalize();

							FLOAT Dot = TestVector | Poly->Normal;
							if( Dot < 0.0f
									&& !Poly->IsBackfaced( ClickLocation ) )
							{
								UBOOL bOK = 0;

								// As a final test, attempt to trace a line to the each vertex of the face from the
								// click location.  If we can reach any one of it's vertices, include it.
								for( INT cmppoly = 0 ; cmppoly < Actor->Brush->Polys->Element.Num() && !bOK ; cmppoly++ )
								{
									FPoly* CmpPoly = &(Actor->Brush->Polys->Element(cmppoly));

									if( CmpPoly == Poly )
										continue;

									FVector Center = FVector(0,0,0);
									for( INT cmpvtx = 0 ; cmpvtx < CmpPoly->NumVertices ; cmpvtx++ )
										Center += CmpPoly->Vertex[cmpvtx];
									Center /= CmpPoly->NumVertices;

									FVector Dir = Center - ClickLocation;
									Dir.Normalize();
									if( CmpPoly->DoesLineIntersect( ClickLocation, ClickLocation + (Dir * 16384 ), NULL ) )
									{
										bOK = 1;
										break;
									}
								}

								// We've passed all the tests, so add this face to the hit list.
								if( bOK )
									for( INT vertex = 0 ; vertex < Poly->NumVertices ; vertex++ )
										vertexedit_Click( (ABrush*)Actor, Poly->Vertex[vertex], 1, 1 );
							}
						}
					}
				}
			}
		}
		else if( Mode==EM_BrushSnap )
		{
			GbIsSnapScaleBox = 1;

			// Grab an initial bounding box for all selected actors.
			FBox BBox;
			BBox.Init();
			for( INT i = 0 ; i < Level->Actors.Num() ; i++ )
			{
				AActor* Actor = Level->Actors(i);
				if( Actor && Actor->bSelected && Actor->IsBrush() )
					BBox += ((ABrush*)Actor)->Brush->GetRenderBoundingBox( ((ABrush*)Actor), 1 );
			}

			GOldSnapScaleStart = GSnapScaleStart = BBox.Min;
			GOldSnapScaleEnd = GSnapScaleEnd = BBox.Max;
		}
		else if( Mode==EM_TextureRotate )
		{
			// Guarantee that each texture u and v vector on each selected polygon
			// is unique in the world.
			OriginalUVectors.Empty( Viewport->Actor->GetLevel()->Model->Surfs.Num() );
			OriginalVVectors.Empty( Viewport->Actor->GetLevel()->Model->Surfs.Num() );
			OrigNumVectors = Viewport->Actor->GetLevel()->Model->Vectors.Num();
			for( INT i=0; i<Viewport->Actor->GetLevel()->Model->Surfs.Num(); i++ )
			{
				FBspSurf* Surf = &Viewport->Actor->GetLevel()->Model->Surfs(i);
				OriginalUVectors.AddItem( Surf->vTextureU );
				OriginalVVectors.AddItem( Surf->vTextureV );
				if( Surf->PolyFlags & PF_Selected )
				{
					INT n			=  Viewport->Actor->GetLevel()->Model->Vectors.Add();
					FVector *V		= &Viewport->Actor->GetLevel()->Model->Vectors(n);
					*V				=  Viewport->Actor->GetLevel()->Model->Vectors(Surf->vTextureU);
					Surf->vTextureU = n;
					n				=  Viewport->Actor->GetLevel()->Model->Vectors.Add();
					V				= &Viewport->Actor->GetLevel()->Model->Vectors(n);
					*V				=  Viewport->Actor->GetLevel()->Model->Vectors(Surf->vTextureV);
					Surf->vTextureV = n;
					Surf->iLightMap = INDEX_NONE;
				}
			}
			TextureAngle = 0.0;
		}
		if( Viewport->IsOrtho()
				&& (Viewport->Input->KeyDown(IK_Alt)
				&& Viewport->Input->KeyDown(IK_Ctrl) ) ) 
		{
			// Start box selection
			GbIsBoxSel = 1;
			GBoxSelStart = GBoxSelEnd = GEditor->ClickLocation;
		}
	}
	if( Buttons & MOUSE_LastRelease )
	{
		Viewport->SetMouseCapture( 0, 0 );
		FinishAllSnaps( Viewport->Actor->GetLevel() );

		if( Mode==EM_VertexEdit || Mode==EM_FaceDrag )
		{
			TArray<ABrush*> Brushes;
			vertexedit_GetBrushList( &Brushes );

			// Do clean up work on the final list of brushes.
			for( INT brush = 0 ; brush < Brushes.Num() ; brush++ )
			{
				UPolys* Polys = Brushes(brush)->Brush->Polys;

				for( INT x = 0 ; x < Polys->Element.Num() ; x++ ) 
				{
					if( Polys->Element(x).Fix() < 3 )
					{
						// This poly is no longer valid, remove it from the brush.
						debugf( TEXT("Warning : Not enough vertices, poly removed"));
						Polys->Element.Remove(x);
						x = 0;
					}
					else
						Polys->Element(x).Base = Polys->Element(x).Vertex[0];
				}
				Brushes(brush)->Brush->BuildBound();
				edactApplyTransformToBrush( Brushes(brush) );
			}

			// Check for necessary texture vector recalcs
			for( brush = 0 ; brush < Brushes.Num() ; brush++ )
			{
				UPolys* Polys = Brushes(brush)->Brush->Polys;

				for( INT x = 0 ; x < Polys->Element.Num() ; x++ ) 
				{
					Polys->Element(x).Base = Polys->Element(x).Vertex[0];

					// If the polys normal has changed, we have to compute new texture vectors for it.
					// Due to the nature of vertex editing, compensating automatically for vertex
					// adjustment is almost impossible.
					if( !Polys->Element(x).SaveNormal.IsZero() && Polys->Element(x).SaveNormal != Polys->Element(x).Normal )
					{
						Polys->Element(x).TextureU = FVector(0,0,0);
						Polys->Element(x).TextureV = FVector(0,0,0);
						RecomputePoly( &Polys->Element(x) );
						Polys->Element(x).SaveNormal = Polys->Element(x).Normal;
					}
				}
			}

			GEditor->Trans->End();
		}
		else if( Mode==EM_TextureRotate )
		{
			if( OriginalUVectors.Num() )
			{
				// Finishing up texture rotate mode.  Go through and minimize the set of
				// vectors we've been adjusting by merging the new vectors in and eliminating
				// duplicates.
				FMemMark Mark(GMem);
				for( INT i=0; i<Viewport->Actor->GetLevel()->Model->Surfs.Num(); i++ )
				{
					FBspSurf *Surf = &Viewport->Actor->GetLevel()->Model->Surfs(i);
					if( Surf->PolyFlags & PF_Selected )
					{
						// Update master texture coordinates but not base.
						polyUpdateMaster (Viewport->Actor->GetLevel()->Model,i,1,0);

						// Add this poly's vectors, merging with the level's existing vectors.
						Surf->vTextureU = bspAddVector(Viewport->Actor->GetLevel()->Model,&Viewport->Actor->GetLevel()->Model->Vectors(Surf->vTextureU),0);
						Surf->vTextureV = bspAddVector(Viewport->Actor->GetLevel()->Model,&Viewport->Actor->GetLevel()->Model->Vectors(Surf->vTextureV),0);
					}
				}
				Mark.Pop();
				OriginalUVectors.Empty();
				OriginalVVectors.Empty();
			}
		}
		else if( Mode==EM_BrushSnap )
		{
			Trans->Begin( TEXT("Brush Snap Scale") );

			GbIsSnapScaleBox = 0;

			FVector Dist = GSnapScaleStart - GSnapScaleEnd,
				DistOld = GOldSnapScaleStart - GOldSnapScaleEnd;

			if( !Dist.X ) Dist.X = 1;
			if( !Dist.Y ) Dist.Y = 1;
			if( !Dist.Z ) Dist.Z = 1;
			if( !DistOld.X ) DistOld.X = Dist.X;
			if( !DistOld.Y ) DistOld.Y = Dist.Y;
			if( !DistOld.Z ) DistOld.Z = Dist.Z;

			FVector Scale = FVector( Dist.X / DistOld.X, Dist.Y / DistOld.Y, Dist.Z / DistOld.Z );
			FVector InvScale( 1 / Scale.X, 1 / Scale.Y, 1 / Scale.Z );

			for( INT i = 0 ; i < Level->Actors.Num() ; i++ )
			{
				ABrush* Brush = Cast<ABrush>(Level->Actors(i));
				if( Brush && Brush->bSelected && Brush->IsBrush() )
				{
					Brush->Brush->Modify();
					FCoords Coords = Brush->ToLocal();
					FVector Adjust = GSnappedLocation.TransformPointBy( Coords );

					for( INT poly = 0 ; poly < Brush->Brush->Polys->Element.Num() ; poly++ )
					{
						FPoly* Poly = &(Brush->Brush->Polys->Element(poly));
						Brush->Brush->Polys->Element.ModifyAllItems();

						Poly->TextureU *= InvScale;
						Poly->TextureV *= InvScale;
						Poly->Base = ((Poly->Base - Adjust) * Scale) + Adjust;

						for( INT vtx = 0 ; vtx < Poly->NumVertices ; vtx++ )
							Poly->Vertex[vtx] = ((Poly->Vertex[vtx] - Adjust) * Scale) + Adjust;

						Poly->CalcNormal();
					}

					Brush->Brush->BuildBound();
				}
			}

			Trans->End();
			EdCallback( EDC_RedrawAllViewports, 0 );
		}
		if( GbIsBoxSel )
		{
			GbIsBoxSel = 0;
			GEditor->edactBoxSelect( Viewport, GEditor->Level, GBoxSelStart, GBoxSelEnd );
			EdCallback( EDC_RedrawAllViewports, 0 );
		}
	}

	switch( Mode )
	{
		case EM_None:
			debugf( NAME_Warning, TEXT("Editor is disabled") );
			break;
		case EM_BrushClip:
		case EM_Polygon:
			goto ViewportMove;
		case EM_VertexEdit:
		case EM_FaceDrag:
			{
				if( !Viewport->Input->KeyDown(IK_Ctrl) 
						|| GbIsBoxSel )
					goto ViewportMove;

				CalcFreeMoveRot( Viewport, MouseX, MouseY, Buttons, Delta, DeltaRot );
				MoveActors( Level, Delta, DeltaRot, 1, (Buttons & MOUSE_Shift) ? Viewport->Actor : NULL, 1 );

				// If we're using the sizingbox, the brush bounding boxes need to be constantly
				// updated so the size will be shown properly while dragging vertices.
				if( GEditor->Constraints.UseSizingBox )
				{
					TArray<ABrush*> Brushes;
					vertexedit_GetBrushList( &Brushes );
					for( INT brush = 0 ; brush < Brushes.Num() ; brush++ )
						Brushes(brush)->Brush->BuildBound();
				}
			}
			break;
		case EM_ViewportMove:
			if( Buttons & MOUSE_Alt )
			{
				GrabVertex( Viewport->Actor->GetLevel() );
			}
			// release the vertex if either the mouse button or <Alt> key is released
			else if( Buttons & MOUSE_LastRelease || !( Buttons & MOUSE_Alt ) )
			{
				ReleaseVertex( Viewport->Actor->GetLevel() );
			}
		case EM_ViewportZoom:
			ViewportMove:
			if( GbIsBoxSel )
			{
				/*
				CalcFreeMoveRot( Viewport, MouseX, MouseY, Buttons, Delta, DeltaRot );
				Delta *= MovementSpeed;
				Delta *= 10000.0/Viewport->Actor->OrthoZoom;
				GBoxSelEnd += Delta;
				*/

				CalcFreeMoveRot( Viewport, MouseX, MouseY, Buttons, Delta, DeltaRot );
				MoveActors( Level, Delta, DeltaRot, 0, NULL );
			}
			else if( Buttons & (MOUSE_FirstHit | MOUSE_LastRelease | MOUSE_SetMode | MOUSE_ExitMode) )
			{
				Viewport->Actor->Velocity = FVector(0,0,0);
			}
			else
			{
				if( Buttons & MOUSE_Alt )
				{
					if( !GbIsBoxSel )
					{
						// Move selected vertex.
						CalcFreeMoveRot( Viewport, MouseX, MouseY, Buttons, Delta, DeltaRot );
						Delta *= 0.25f*MovementSpeed;
					}
				}
				else
   				if( !(Buttons & (MOUSE_Ctrl | MOUSE_Shift) ) )
				{
					// Move camera.
					Speed = 0.30*MovementSpeed;
					if( Viewport->IsOrtho() && Buttons==MOUSE_Right )
					{
						Buttons = MOUSE_Left;
						Speed   = 0.60*MovementSpeed;
					}
					CalcFreeMoveRot( Viewport, MouseX, MouseY, Buttons, Delta, DeltaRot );
					Delta *= Speed;
				}
				else
				{
					// Move actors.
					CalcMixedMoveRot( Viewport, MouseX, MouseY, Buttons, Delta, DeltaRot );
					Delta *= 0.25*MovementSpeed;
				}
				if( Mode==EM_ViewportZoom )
				{
					Delta = (Viewport->Actor->Velocity += Delta);
				}
				if( Buttons & MOUSE_Alt )
				{
					if( !GbIsBoxSel )
					{
						// Move selected vertex.
						MoveVertex( Level, Delta, 1 );
					}
				}
				else
				if( !(Buttons & (MOUSE_Ctrl | MOUSE_Shift) ) )
				{
					// Move camera.
					ViewportMoveRotWithPhysics( Viewport, Delta, DeltaRot );
				}
				else
				{
					// Move actors.
					MoveActors( Level, Delta, DeltaRot, 1, (Buttons & MOUSE_Shift) ? Viewport->Actor : NULL );
				}
			}
			break;
		case EM_BrushRotate:
			if( !(Buttons&MOUSE_Ctrl) )
				goto ViewportMove;
			CalcAxialRot( Viewport, MouseX, MouseY, Buttons, DeltaRot );
			if( DeltaRot != FRotator(0,0,0) )
			{
				NoteActorMovement( Level );
 				MoveActors( Level, FVector(0,0,0), DeltaRot, 1, (Buttons & MOUSE_Shift) ? Viewport->Actor : NULL );
			}
			break;
		case EM_BrushScale:
			{
				if (!(Buttons&MOUSE_Ctrl))
					goto ViewportMove;

				NoteActorMovement( Level );
				CalcAxialMoveRot( Viewport, MouseX, MouseY, Buttons, Delta, DeltaRot );
				if( Delta.IsZero() )
					break;

				FVector Scale( 1 + Delta.X / 256.0f, 1 + Delta.Y / 256.0f, 1 + Delta.Z / 256.0f );
				for( INT i = 0 ; i < Level->Actors.Num() ; i++ )
				{
					AActor* Actor = Level->Actors(i);
					if( Actor && Actor->bSelected && Actor->IsBrush() )
					{
						for( INT poly = 0 ; poly < Actor->Brush->Polys->Element.Num() ; poly++ )
						{
							FPoly* Poly = &(Actor->Brush->Polys->Element(poly));

							for( INT vertex = 0 ; vertex < Poly->NumVertices ; vertex++ )
								Poly->Vertex[vertex] *= Scale;

							Poly->Finalize(0);
						}

						Actor->Brush->BuildBound();
					
						// If the user is hold down ALT, scale the locations as well.  This allows you to
						// scale a group of brushes as one.
						if( Buttons & MOUSE_Alt )
							Actor->Location *= Scale;
					}
				}
			}
			break;
		case EM_BrushSnap:
			if( !(Buttons&MOUSE_Ctrl) )
				goto ViewportMove;
			{
				NoteActorMovement( Level );

				CalcAxialMoveRot( Viewport, MouseX, MouseY, Buttons, Delta, DeltaRot );
				Constraints.Snap(Delta,FVector(0,0,0));

				if( Delta.X )
				{
					FPlane Plane( GSnappedLocation, GSnappedLocation + (FVector(0,1,0) * 16), GSnappedLocation + (FVector(0,0,1) * 16) );
					FLOAT StartDist = FPointPlaneDist( GSnapScaleStart, GSnappedLocation, FVector(1,0,0) );
					FLOAT EndDist = FPointPlaneDist( GSnapScaleEnd, GSnappedLocation, FVector(1,0,0) );

					if( ::fabs(StartDist) > THRESH_POINT_ON_PLANE ) GSnapScaleStart.X -= Delta.X;
					if( ::fabs(EndDist) > THRESH_POINT_ON_PLANE ) GSnapScaleEnd.X += Delta.X;
				}
				if( Delta.Y )
				{
					FPlane Plane( GSnappedLocation, GSnappedLocation + (FVector(1,0,0) * 16), GSnappedLocation + (FVector(0,0,1) * 16) );
					FLOAT StartDist = FPointPlaneDist( GSnapScaleStart, GSnappedLocation, FVector(0,1,0) );
					FLOAT EndDist = FPointPlaneDist( GSnapScaleEnd, GSnappedLocation, FVector(0,1,0) );

					if( ::fabs(StartDist) > THRESH_POINT_ON_PLANE ) GSnapScaleStart.Y -= Delta.Y;
					if( ::fabs(EndDist) > THRESH_POINT_ON_PLANE ) GSnapScaleEnd.Y += Delta.Y;
				}
				if( Delta.Z )
				{
					FPlane Plane( GSnappedLocation, GSnappedLocation + (FVector(1,0,0) * 16), GSnappedLocation + (FVector(0,1,0) * 16) );
					FLOAT StartDist = FPointPlaneDist( GSnapScaleStart, GSnappedLocation, FVector(0,0,1) );
					FLOAT EndDist = FPointPlaneDist( GSnapScaleEnd, GSnappedLocation, FVector(0,0,1) );

					if( ::fabs(StartDist) > THRESH_POINT_ON_PLANE ) GSnapScaleStart.Z -= Delta.Z;
					if( ::fabs(EndDist) > THRESH_POINT_ON_PLANE ) GSnapScaleEnd.Z += Delta.Z;
				}
			}
			break;
		case EM_TexturePan:
		{
			if( !(Buttons&MOUSE_Ctrl) )
				goto ViewportMove;
			NoteTextureMovement( Level );
			if( (Buttons & MOUSE_Left) && (Buttons & MOUSE_Right) )
			{
				GFixScale += Fix(MouseY) / 32;
				TempFloat = 1.0;
				INT Temp = Unfix(GFixScale); 
				if( Constraints.GridEnabled )
				{
					while( Temp > 0 ) { TempFloat *= 0.5; Temp--; }
					while( Temp < 0 ) { TempFloat *= 2.0; Temp++; }
				}
				else
				{
					while( Temp > 0 ) { TempFloat *= 0.95f; Temp--; }
					while( Temp < 0 ) { TempFloat *= 1.05f; Temp++; }
				}
				if( TempFloat != 1.0 )
					polyTexScale(Viewport->Actor->GetLevel()->Model,TempFloat,0.0,0.0,TempFloat,0);
				GFixScale &= 0xffff;
			}
			else if( Buttons & MOUSE_Left )
			{
				GFixPanU += Fix(MouseX)/16;  GFixPanV += Fix(MouseY)/16;
				polyTexPan(Viewport->Actor->GetLevel()->Model,Unfix(GFixPanU),Unfix(0),0);
				GFixPanU &= 0xffff; GFixPanV &= 0xffff;
			}
			else
			{
				GFixPanU += Fix(MouseX)/16;  GFixPanV += Fix(MouseY)/16;
				polyTexPan(Viewport->Actor->GetLevel()->Model,Unfix(0),Unfix(GFixPanV),0);
				GFixPanU &= 0xffff; GFixPanV &= 0xffff;
			}
			break;
		}
		case EM_TextureRotate:
		{
			if( !(Buttons&MOUSE_Ctrl) )
				goto ViewportMove;
			check(OriginalUVectors.Num()==Viewport->Actor->GetLevel()->Model->Surfs.Num());
			check(OriginalVVectors.Num()==Viewport->Actor->GetLevel()->Model->Surfs.Num());
			NoteTextureMovement( Level );
			TextureAngle += (FLOAT)MouseX / ( Constraints.RotGridEnabled ? 256.0 : 8192.0 );
			for( INT i=0; i<Viewport->Actor->GetLevel()->Model->Surfs.Num(); i++ )
			{
				FBspSurf* Surf = &Viewport->Actor->GetLevel()->Model->Surfs(i);
				if( Surf->PolyFlags & PF_Selected )
				{
					FVector U		=  Viewport->Actor->GetLevel()->Model->Vectors(OriginalUVectors(i));
					FVector V		=  Viewport->Actor->GetLevel()->Model->Vectors(OriginalVVectors(i));
					FVector* NewU	= &Viewport->Actor->GetLevel()->Model->Vectors(Surf->vTextureU);
					FVector* NewV	= &Viewport->Actor->GetLevel()->Model->Vectors(Surf->vTextureV);
					*NewU			= U * appCos(TextureAngle) + V * appSin(TextureAngle);
					*NewV			= V * appCos(TextureAngle) - U * appSin(TextureAngle);
				}
			}
			break;
		}
		case EM_TerrainEdit:
		{
			/*
			if (!(Buttons&MOUSE_Ctrl))
				goto ViewportMove;

			if( Buttons&MOUSE_Left && Buttons&MOUSE_Right && Buttons&MOUSE_Ctrl )
			{
				debugf(TEXT("MouseX=%f, MouseY=%f"), MouseX, MouseY);
				
				for( INT i=0;i<Level->Actors.Num();i++ )
				{
					AActor* A = Level->Actors(i);
					if( A && A->IsA(ATerrainInfo::StaticClass()) && A->bSelected )
						Cast<ATerrainInfo>(A)->MoveVertices( MouseY );
				}
			}		
			break;
			*/
		}
		default:
			debugf( NAME_Warning, TEXT("Unknown editor mode %i"), Mode );
			goto ViewportMove;
			break;
	}
	if( Viewport->Actor->RendMap != REN_MeshView )
	{
		Viewport->Actor->Rotation = Viewport->Actor->ViewRotation;
		Viewport->Actor->GetLevel()->SetActorZone( Viewport->Actor, 0, 0 );
	}
}

//
// Mouse position.
//
void UEditorEngine::MousePosition( UViewport* Viewport, DWORD Buttons, FLOAT X, FLOAT Y )
{
	if( edcamMode(Viewport)==EM_TexView )
	{
		UTexture* Texture = (UTexture *)Viewport->MiscRes;
		X *= (FLOAT)Texture->USize/Viewport->SizeX;
		Y *= (FLOAT)Texture->VSize/Viewport->SizeY;
		if( X>=0 && X<Texture->USize && Y>=0 && Y<Texture->VSize )
			Texture->MousePosition( Buttons, X, Y );
	}
}

/*-----------------------------------------------------------------------------
   Keypress handling.
-----------------------------------------------------------------------------*/

//
// Handle a regular ASCII key that was pressed in UnrealEd.
// Returns 1 if proceesed, 0 if not.
//
INT UEditorEngine::Key( UViewport* Viewport, EInputKey Key )
{
	if( Viewport->Input->KeyDown(IK_Alt) )
	{
		FString Cmd;
		switch( Key )
		{
			case IK_1:	Cmd = TEXT("RMODE 1");	break;
			case IK_2:	Cmd = TEXT("RMODE 2");	break;
			case IK_3:	Cmd = TEXT("RMODE 3");	break;
			case IK_4:	Cmd = TEXT("RMODE 4");	break;
			case IK_5:	Cmd = TEXT("RMODE 5");	break;
			case IK_6:	Cmd = TEXT("RMODE 6");	break;
			case IK_7:	Cmd = TEXT("RMODE 13");	break;
			case IK_8:	Cmd = TEXT("RMODE 14");	break;
			case IK_9:	Cmd = TEXT("RMODE 15");	break;
			default:	return 0;
		}

		INT iRet = Viewport->Exec( *Cmd );
		EdCallback( EDC_ViewportUpdateWindowFrame, 1 );
		return iRet;
	}
	if( UEngine::Key( Viewport, Key ) )
	{
		return 1;
	}
	else if( Viewport->Actor->RendMap==REN_TexView )
	{
		debugf( TEXT("!TEX") );
		return 0;
	}
	else if( Viewport->Actor->RendMap==REN_MeshView )
	{
		return 0;
	}
	else if( Viewport->Input->KeyDown(IK_Shift) )
	{
		if( Viewport->Input->KeyDown(IK_A) ) {  Exec( TEXT("ACTOR SELECT ALL") ); return 1; }
		if( Viewport->Input->KeyDown(IK_B) ) {  Exec( TEXT("POLY SELECT MATCHING BRUSH") ); return 1; }
		if( Viewport->Input->KeyDown(IK_C) ) {  Exec( TEXT("POLY SELECT ADJACENT COPLANARS") ); return 1; }
		if( Viewport->Input->KeyDown(IK_D) ) {  Exec( TEXT("ACTOR DUPLICATE") ); return 1; }
		if( Viewport->Input->KeyDown(IK_F) ) {  Exec( TEXT("POLY SELECT ADJACENT FLOORS") ); return 1; }
		if( Viewport->Input->KeyDown(IK_G) ) {  Exec( TEXT("POLY SELECT MATCHING GROUPS") ); return 1; }
		if( Viewport->Input->KeyDown(IK_I) ) {  Exec( TEXT("POLY SELECT MATCHING ITEMS") ); return 1; }
		if( Viewport->Input->KeyDown(IK_J) ) {  Exec( TEXT("POLY SELECT ADJACENT ALL") ); return 1; }
		if( Viewport->Input->KeyDown(IK_M) ) {  Exec( TEXT("POLY SELECT MEMORY SET") ); return 1; }
		if( Viewport->Input->KeyDown(IK_N) ) {  Exec( TEXT("SELECT NONE") ); return 1; }
		if( Viewport->Input->KeyDown(IK_O) ) {  Exec( TEXT("POLY SELECT MEMORY INTERSECT") ); return 1; }
		if( Viewport->Input->KeyDown(IK_Q) ) {  Exec( TEXT("POLY SELECT REVERSE") ); return 1; }
		if( Viewport->Input->KeyDown(IK_R) ) {  Exec( TEXT("POLY SELECT MEMORY RECALL") ); return 1; }
		if( Viewport->Input->KeyDown(IK_S) ) {  Exec( TEXT("POLY SELECT ALL") ); return 1; }
		if( Viewport->Input->KeyDown(IK_T) ) {  Exec( TEXT("POLY SELECT MATCHING TEXTURE") ); return 1; }
		if( Viewport->Input->KeyDown(IK_U) ) {  Exec( TEXT("POLY SELECT MEMORY UNION") ); return 1; }
		if( Viewport->Input->KeyDown(IK_W) ) {  Exec( TEXT("POLY SELECT ADJACENT WALLS") ); return 1; }
		if( Viewport->Input->KeyDown(IK_Y) ) {  Exec( TEXT("POLY SELECT ADJACENT SLANTS") ); return 1; }
		if( Viewport->Input->KeyDown(IK_X) ) {  Exec( TEXT("POLY SELECT MEMORY XOR") ); return 1; }

		return 0;
	}
	else if( Viewport->Input->KeyDown(IK_Ctrl) )
	{
		if( Viewport->Input->KeyDown(IK_C) ) { Exec( TEXT("EDIT COPY") );	return 1; }
		if( Viewport->Input->KeyDown(IK_V) ) { Exec( TEXT("EDIT PASTE") );	return 1; }
		if( Viewport->Input->KeyDown(IK_W) ) { Exec( TEXT("ACTOR DUPLICATE") );	return 1; }
		if( Viewport->Input->KeyDown(IK_X) ) { Exec( TEXT("EDIT CUT") );	return 1; }
		if( Viewport->Input->KeyDown(IK_Y) ) { Exec( TEXT("TRANSACTION REDO") );	return 1; }
		if( Viewport->Input->KeyDown(IK_Z) ) { Exec( TEXT("TRANSACTION UNDO") );	return 1; }
		if( Viewport->Input->KeyDown(IK_A) ) { Exec( TEXT("BRUSH ADD") );	return 1; }
		if( Viewport->Input->KeyDown(IK_S) ) { Exec( TEXT("BRUSH SUBTRACT") );	return 1; }
		if( Viewport->Input->KeyDown(IK_I) ) { Exec( TEXT("BRUSH FROM INTERSECTION") );	return 1; }
		if( Viewport->Input->KeyDown(IK_D) ) { Exec( TEXT("BRUSH FROM DEINTERSECTION") );	return 1; }
		if( Viewport->Input->KeyDown(IK_L) ) { GEditor->EdCallback( EDC_SaveMap, 1 );	return 1; }
		if( Viewport->Input->KeyDown(IK_E) ) { GEditor->EdCallback( EDC_SaveMapAs, 1 );	return 1; }
		if( Viewport->Input->KeyDown(IK_O) ) { GEditor->EdCallback( EDC_LoadMap, 1 );	return 1; }
		if( Viewport->Input->KeyDown(IK_P) ) { GEditor->EdCallback( EDC_PlayMap, 1 );	return 1; }

		return 0;
	}
	else if( !Viewport->Input->KeyDown(IK_Alt) )
	{
//		if( Viewport->Input->KeyDown(IK_Delete) )
//		{
//			GEditor->EdCallback( EDC_ConfirmDelete, 0 );
//			return 1;
//		}
		if( Viewport->Input->KeyDown(IK_B) ) {  Viewport->Actor->ShowFlags ^= SHOW_Brush; return 1; }
		if( Viewport->Input->KeyDown(IK_H) ) {  Viewport->Actor->ShowFlags ^= SHOW_Actors; return 1; }
		if( Viewport->Input->KeyDown(IK_K) ) {  Viewport->Actor->ShowFlags ^= SHOW_Backdrop; return 1; }
		if( Viewport->Input->KeyDown(IK_P) ) {  Viewport->Actor->ShowFlags ^= SHOW_PlayerCtrl; EdCallback( EDC_ViewportUpdateWindowFrame, 1 ); return 1; }
		if( Viewport->Input->KeyDown(IK_W) ) {  Viewport->Actor->ShowFlags ^= SHOW_HardwareBrushes; return 1; }

		return 0;
	}

	return 0;
}


/*-----------------------------------------------------------------------------
   Mesh View
-----------------------------------------------------------------------------*/

void DrawMeshView( FSceneNode* Frame )
{
	if (!Frame)
		return;

	UViewport* Viewport = Frame->Viewport;
	if (!Viewport)
		return;

	APlayerPawn* Actor = Viewport->Actor;
	if (!Actor)
		return;

	FLOAT DeltaTime = Viewport->CurrentTime - Viewport->LastUpdateTime;

	// Rotate the view.
	FVector NewLocation = Viewport->Actor->ViewRotation.Vector() * (-Viewport->Actor->Location.Size());
	if( FDist(Actor->Location, NewLocation) > 0.05 )
		Actor->Location = NewLocation;

	// Get animation.
	Actor->AnimSequence = NAME_None;
	UMesh* Mesh = (UMesh*)Viewport->MiscRes;

	// Get the mesh instance.
	UMeshInstance* MeshInst = Mesh->GetInstance(Actor);
	MeshInst->SetActor( Actor );
	Actor->MeshInstance = MeshInst;
	
	// Set our animation sequence.
	HMeshSequence Seq = 0;
	if ( MeshInst->GetNumSequences() )
	{
		Actor->AnimSequence = FName( FName::GetEntry( Actor->Misc1 )->Name );
		Seq = MeshInst->FindSequence( Actor->AnimSequence );
	}

	// Auto rotate if wanted.
	if( Actor->ShowFlags & SHOW_Brush )
		Actor->ViewRotation.Yaw += Clamp(DeltaTime,0.f,0.2f) * 8192.0;

	// Do coordinates.
	Frame->ComputeRenderCoords( Viewport->Actor->Location, Viewport->Actor->ViewRotation );
	PUSH_HIT(Frame,HCoords(Frame));

	// Remember.
	FVector OriginalLocation;
	OriginalLocation		= Actor->Location;
	Actor->Location			= FVector(0,0,0);
//	OriginalRotation		= Actor->ViewRotation;
//	Actor->bHiddenEd		= 0;
//	Actor->bHidden			= 0;
	Actor->bSelected        = 0;
	Actor->bMeshCurvy       = 0;
	Actor->DrawType			= DT_Mesh;
	Actor->Mesh				= Mesh;
//	Actor->Region			= FPointRegion(NULL,INDEX_NONE,0);
	Actor->bCollideWorld	= 0;
	Actor->bCollideActors	= 0;
	Actor->bIgnoreBList		= 1;
	Actor->AmbientGlow      = 255;
	Actor->CollisionHeight	= 0;

	// Update mesh.
	FLOAT NumFrames = Seq ? MeshInst->GetSeqNumFrames(Seq) : 1.0;
	if( Actor->ShowFlags & SHOW_Backdrop )
	{
		static FLOAT oldAnimFrame = 0;
		Actor->AnimFrame  = oldAnimFrame;
		FLOAT Rate        = Seq ? MeshInst->GetSeqRate(Seq) / NumFrames : 1.0;
		Actor->AnimFrame += Clamp(Rate*DeltaTime,0.f,1.f);
		Actor->AnimFrame -= appFloor(Actor->AnimFrame);
		oldAnimFrame	  = Actor->AnimFrame;
		Actor->Misc2	  = appFloor(oldAnimFrame * NumFrames);
	}
	else Actor->AnimFrame = Actor->Misc2 / NumFrames;

	if     ( Actor->ShowFlags & SHOW_Frame  )	Viewport->Actor->RendMap = REN_Wire;
	else if( Actor->ShowFlags & SHOW_Coords )	Viewport->Actor->RendMap = REN_Polys;
	else										Viewport->Actor->RendMap = REN_PlainTex;
	Viewport->Actor->RendMap = REN_PlainTex;

	// Draw it.
	GRender->DrawActor( Frame, Actor );
	
	// Draw axes
	Viewport->RenDev->Queue3DLine(Frame, FPlane(1,0,0,0), LINE_DepthCued, FVector(0,0,0), FVector(25,0,0));
	Viewport->RenDev->Queue3DLine(Frame, FPlane(0,1,0,0), LINE_DepthCued, FVector(0,0,0), FVector(0,25,0));
	Viewport->RenDev->Queue3DLine(Frame, FPlane(0,0,1,0), LINE_DepthCued, FVector(0,0,0), FVector(0,0,25));

	// Draw bounding box
	FBox tempBox = Mesh->GetRenderBoundingBox(Viewport->Actor, 1);
	FVector Min = tempBox.Min;
	FVector Max = tempBox.Max;
	
	Viewport->RenDev->Queue3DLine(Frame, FPlane(1,0,1,0), LINE_DepthCued, FVector(Min.X, Min.Y, Min.Z), FVector(Min.X, Min.Y, Max.Z));
	Viewport->RenDev->Queue3DLine(Frame, FPlane(1,0,1,0), LINE_DepthCued, FVector(Max.X, Min.Y, Min.Z), FVector(Max.X, Min.Y, Max.Z));
	Viewport->RenDev->Queue3DLine(Frame, FPlane(1,0,1,0), LINE_DepthCued, FVector(Min.X, Max.Y, Min.Z), FVector(Min.X, Max.Y, Max.Z));
	Viewport->RenDev->Queue3DLine(Frame, FPlane(1,0,1,0), LINE_DepthCued, FVector(Max.X, Max.Y, Min.Z), FVector(Max.X, Max.Y, Max.Z));

	Viewport->RenDev->Queue3DLine(Frame, FPlane(1,0,1,0), LINE_DepthCued, FVector(Min.X, Min.Y, Min.Z), FVector(Min.X, Max.Y, Min.Z));
	Viewport->RenDev->Queue3DLine(Frame, FPlane(1,0,1,0), LINE_DepthCued, FVector(Max.X, Min.Y, Min.Z), FVector(Max.X, Max.Y, Min.Z));
	Viewport->RenDev->Queue3DLine(Frame, FPlane(1,0,1,0), LINE_DepthCued, FVector(Min.X, Min.Y, Max.Z), FVector(Min.X, Max.Y, Max.Z));
	Viewport->RenDev->Queue3DLine(Frame, FPlane(1,0,1,0), LINE_DepthCued, FVector(Max.X, Min.Y, Max.Z), FVector(Max.X, Max.Y, Max.Z));

	Viewport->RenDev->Queue3DLine(Frame, FPlane(1,0,1,0), LINE_DepthCued, FVector(Min.X, Min.Y, Min.Z), FVector(Max.X, Min.Y, Min.Z));
	Viewport->RenDev->Queue3DLine(Frame, FPlane(1,0,1,0), LINE_DepthCued, FVector(Min.X, Max.Y, Min.Z), FVector(Max.X, Max.Y, Min.Z));
	Viewport->RenDev->Queue3DLine(Frame, FPlane(1,0,1,0), LINE_DepthCued, FVector(Min.X, Min.Y, Max.Z), FVector(Max.X, Min.Y, Max.Z));
	Viewport->RenDev->Queue3DLine(Frame, FPlane(1,0,1,0), LINE_DepthCued, FVector(Min.X, Max.Y, Max.Z), FVector(Max.X, Max.Y, Max.Z));
	
	Viewport->RenDev->Queued3DLinesFlush(Frame);

	Viewport->Actor->RendMap = REN_MeshView;
	Actor->Location		   = OriginalLocation;
	Actor->DrawType		   = DT_None;

	POP_HIT(Frame);

	Actor->bHiddenEd		= 1;
	Actor->bHidden			= 1;
	Actor->AnimSequence		= NAME_None;
	Actor->MeshInstance = NULL;
	Actor->AnimFrame = 0;
	MeshInst->SetActor(NULL);
	Actor->Mesh = NULL;
}


/*-----------------------------------------------------------------------------
   Texture browser routines.
-----------------------------------------------------------------------------*/

void DrawViewerBackground( FSceneNode* Frame )
{
	Frame->Viewport->Canvas->DrawPattern( GEditor->Bkgnd, 0, 0, Frame->X, Frame->Y, 1.f, 0.f, 0.f, NULL, 1.f, FPlane(1.f,1.f,1.f,0), FPlane(0,0,0,0), 0 );
}

INT CDECL ResNameCompare(const void *A, const void *B)
{
	return appStricmp((*(UObject **)A)->GetName(),(*(UObject **)B)->GetName());
}

void DrawTextureBrowser( FSceneNode* Frame )
{
	UObject* Pkg = Frame->Viewport->MiscRes;
	if( Pkg && Frame->Viewport->Group!=NAME_None )
		Pkg = FindObject<UPackage>( Pkg, *Frame->Viewport->Group );

	FMemMark Mark(GMem);
	enum {MAX=16384};
	UTexture**  List    = new(GMem,MAX)UTexture*;

	// Make a short list of filtered textures.
	INT n = 0;
	for( TObjectIterator<UTexture> It; It && n<MAX; ++It )
		if( It->IsIn(Pkg) )
		{
			FString TexName = It->GetName();

			if( appStrstr( *(TexName.Caps()), *(GTexNameFilter.Caps()) ) )
				List[n++] = *It;
		}

	// Sort textures by name.
	appQsort( &List[0], n, sizeof(UTexture *), ResNameCompare );

	Frame->Viewport->Canvas->Color = FColor(255,255,255);

	// This is how I hacked up the 2 versions of the texture browser.  If you set the
	// zoom (Misc1) to more than 1000, then it goes into "variable size" mode.  Subtracting 1000
	// from the zoom will give you the scaling percentage to use.
	//
	if( Frame->Viewport->Actor->Misc1 > 1000 )	// New way
	{
		INT YL = 1;
		INT TextBuffer = -1;
		INT X, Y, HighYInRow = 0;
		float Scale = 1.0f * ((float)(Frame->Viewport->Actor->Misc1 - 1000) / 100.f);
		GLastScroll = 0;
		if( YL > 0 )
		{
			X = 4;
			Y = 4 - Frame->Viewport->Actor->Misc2;
			HighYInRow = -1;

			for( INT i = 0 ; i < n ; i++ )
			{
				UTexture* Texture = List[i];

				// CREATE TEXT LABELS

				// Create and measure the 2 labels.
				FString TextLabel = Texture->GetName();
				INT LabelWidth, LabelHeight;
				Frame->Viewport->Canvas->WrappedStrLenf( Frame->Viewport->Canvas->SmallFont, LabelWidth, LabelHeight, TEXT("%s"), *TextLabel );

				// NJS: Draw the material and surface flags:
				FString FlagsLabel = TEXT("");
				if( Texture->MacroTexture || Texture->DetailTexture || Texture->BumpMap || (Texture->MaterialName!=NAME_None) )
				{
					if (Texture->MaterialName!=NAME_None)	FlagsLabel+=TEXT("M ");
					if (Texture->BumpMap)					FlagsLabel+=TEXT("B ");
					if (Texture->MacroTexture)				FlagsLabel+=TEXT("A ");
					if (Texture->DetailTexture)				FlagsLabel+=TEXT("D ");
				}

				INT SizeWidth, SizeHeight;
				FString SizeLabel = FString::Printf( TEXT("(%ix%i) %s"), Texture->USize, Texture->VSize, *FlagsLabel );
				Frame->Viewport->Canvas->WrappedStrLenf( Frame->Viewport->Canvas->SmallFont, SizeWidth, SizeHeight, TEXT("%s"), *SizeLabel );

				if( TextBuffer == -1)
					TextBuffer = LabelHeight + SizeHeight + 4;

				// Display the texture wide enough to show it's entire text label without wrapping.
				INT TextureWidth = Max( (INT)(Texture->USize*Scale), (LabelWidth > SizeWidth) ? LabelWidth : SizeWidth );

				// Now that we've measured the length of the text label, stick the texture size
				// on the end.  The texture size will wrap to the next line and look nice.

				// Do we need to create a new line?
				if( X + TextureWidth > Frame->X )
				{
					X = 4;
					Y += HighYInRow + TextBuffer + 8;
					GLastScroll += HighYInRow + TextBuffer + 8;
					HighYInRow = -1;
				}
				if( (Texture->VSize*Scale) > HighYInRow ) HighYInRow = (Texture->VSize*Scale);

				PUSH_HIT(Frame,HBrowserTexture(Texture));

				// SELECTION HIGHLIGHT
				if( Texture == GEditor->CurrentTexture )
					Frame->Viewport->Canvas->DrawPattern( GEditor->BkgndHi,
						X-4, Y-4,
						TextureWidth+8, (Texture->VSize*Scale)+TextBuffer+8,
						1.0, 0.0, 0.0, NULL, 1.0, FPlane(1.,1.,1.,0), FPlane(0,0,0,0), 0 );

				// THE TEXTURE ITSELF
				Frame->Viewport->Canvas->DrawIcon( Texture,
					X, Y,
					(Texture->USize*Scale), (Texture->VSize*Scale),
					NULL, 1.0, FPlane(1.,1.,1.,0), FPlane(0,0,0,0), 0 );


				// TEXT LABELS
				// If this texture is the current texture, draw a black border around the
				// text to make it more readable against the background.
				if( Texture == GEditor->CurrentTexture )
				{
					INT Offsets[] = { 1, 0, -1, 0, 0, 1, 0, -1 };
					Frame->Viewport->Canvas->Color = FColor(0,0,0);
					for( INT x = 0 ; x < 4 ; x++ )
					{
						Frame->Viewport->Canvas->SetClip( X+Offsets[x*2], Y+(Texture->VSize*Scale)+2+Offsets[(x*2)+1], TextureWidth, TextBuffer );
						Frame->Viewport->Canvas->WrappedPrintf( Frame->Viewport->Canvas->SmallFont, 0, TEXT("%s"), *TextLabel );

						Frame->Viewport->Canvas->SetClip( X+Offsets[x*2], Y+(Texture->VSize*Scale)+LabelHeight+4+Offsets[(x*2)+1], TextureWidth, TextBuffer );
						Frame->Viewport->Canvas->WrappedPrintf( Frame->Viewport->Canvas->SmallFont, 0, TEXT("%s"), *SizeLabel );
					}
				}

				Frame->Viewport->Canvas->Color = FColor(255,255,255);
				Frame->Viewport->Canvas->SetClip( X, Y+(Texture->VSize*Scale)+2, TextureWidth, TextBuffer );
				Frame->Viewport->Canvas->WrappedPrintf( Frame->Viewport->Canvas->SmallFont, 0, TEXT("%s"), *TextLabel );

				// Render the size in white if this is the selected texture
				if( Texture != GEditor->CurrentTexture )
					Frame->Viewport->Canvas->Color = FColor(192,192,192);
				Frame->Viewport->Canvas->SetClip( X, Y+(Texture->VSize*Scale)+LabelHeight+4, TextureWidth, TextBuffer );
				Frame->Viewport->Canvas->WrappedPrintf( Frame->Viewport->Canvas->SmallFont, 0, TEXT("%s"), *SizeLabel );

				Frame->Viewport->Canvas->Color = FColor(255,255,255);
				Frame->Viewport->Canvas->SetClip( 0, 0, Frame->X, Frame->Y );

				// Update position
				X += TextureWidth + 8;

				POP_HIT(Frame);
			}
		}
		GLastScroll += HighYInRow + TextBuffer + 8;
		GLastScroll = Max(0, GLastScroll - Frame->Y);
	}
	else	// Old way
	{
		INT			Size	= Frame->Viewport->Actor->Misc1;
		INT			PerRow	= Frame->X/Size;
		if( PerRow < 1 ) return;
		INT			Space	= (Frame->X - Size*PerRow)/(PerRow+1);
		INT			VSkip	= (Size>=64) ? 10 : 0;

		INT YL = Space+(Size+Space+VSkip)*((n+PerRow-1)/PerRow);
		if( YL > 0 )
		{
			INT YOfs = -((Frame->Viewport->Actor->Misc2*Frame->Y)/512);
			for( INT i=0; i<n; i++ )
			{
				UTexture* Texture = List[i];
				INT X = (Size+Space)*(i%PerRow);
				INT Y = (Size+Space+VSkip)*(i/PerRow)+YOfs;
				if( Y+Size+Space+VSkip>0 && Y<Frame->Y )
				{
					PUSH_HIT(Frame,HBrowserTexture(Texture));
					if( Texture==GEditor->CurrentTexture )
						Frame->Viewport->Canvas->DrawPattern( GEditor->BkgndHi, X+1, Y+1, Size+Space*2-2, Size+Space*2+VSkip-2, 1.0, 0.0, 0.0, NULL, 1.0, FPlane(1.,1.,1.,0), FPlane(0,0,0,0), 0 );
					FLOAT Scale=0.125;
					while( Texture->USize/Scale>Size || Texture->VSize/Scale>Size )
						Scale *= 2;
					Frame->Viewport->Canvas->DrawPattern( Texture, X+Space, Y+Space, Size, Size, Scale, X+Space, Y+Space, NULL, 1.0, FPlane(1.,1.,1.,0), FPlane(0,0,0,0), 0 );
					if( Size>=64 )
					{
						FString Temp = Texture->GetName();
						if( Size>=128 )
							Temp += FString::Printf( TEXT(" (%ix%i)"), Texture->USize, Texture->VSize );

						Frame->Viewport->Canvas->Color = FColor(255,255,255);
						Frame->Viewport->Canvas->SetClip( X+Space, Y+Space+Size, Size, Frame->Y-Y-Size-Space-1 );
						Frame->Viewport->Canvas->WrappedPrintf( Frame->Viewport->Canvas->SmallFont, 1, TEXT("%s"), *Temp );

						Frame->Viewport->Canvas->SetClip( 0, 0, Frame->X, Frame->Y );
					}
					POP_HIT(Frame);
				}
			}
		}
		GLastScroll = Max(0,(512*(YL-Frame->Y))/Frame->Y);
	}
	Mark.Pop();
}

/*-----------------------------------------------------------------------------
   Viewport frame drawing.
-----------------------------------------------------------------------------*/

#if 1
//!! hack to avoid modifying EditorEngine.uc, and rebuilding Editor.u
// (see UnEdRend.cpp for further details).
extern FLOAT EdClipZ;
#endif

//
// Draw the camera view.
//
void UEditorEngine::Draw( UViewport* Viewport, UBOOL Blit, BYTE* HitData, INT* HitCount )
{
	FVector			OriginalLocation;
	FRotator		OriginalRotation;
	DWORD			ShowFlags=0;
	APlayerPawn* Actor = Viewport->Actor;
	ShowFlags = Actor->ShowFlags;

	// Lock the camera.
	DWORD LockFlags = 0;
	FPlane ScreenClear(0,0,0,0);
	if( Actor->RendMap==REN_MeshView )
	{
		LockFlags |= LOCKR_ClearScreen;
	}
	if(	Viewport->IsOrtho()
	||	Viewport->IsWire()
	|| !(Viewport->Actor->ShowFlags & SHOW_Backdrop) )
	{
		ScreenClear = Viewport->IsOrtho() ? C_OrthoBackground.Plane() : C_WireBackground.Plane();
		LockFlags |= LOCKR_ClearScreen;
	}
	if( !Viewport->Lock(FPlane(0,0,0,0),0,0,FVector(.5,.5,.5),FVector(0,0,0),ScreenClear,LockFlags,HitData,HitCount) )
	{
		return;
	}

	FSceneNode* Frame = Render->CreateMasterFrame( Viewport, Viewport->Actor->Location, Viewport->Actor->ViewRotation, NULL );
	Render->PreRender( Frame );
	Viewport->Canvas->Update( Frame );
	switch( Actor->RendMap )
	{
		case REN_TexView:
		{
			check(Viewport->MiscRes!=NULL);
			Actor->bHiddenEd = 1;
			Actor->bHidden   = 1;
			UTexture* Texture = (UTexture*)Viewport->MiscRes;
			PUSH_HIT(Frame,HTextureView(Texture,Frame->X,Frame->Y));
			Viewport->Canvas->DrawIcon( 
				Texture->Get(Viewport->CurrentTime), 
				0, 0, 
				Frame->X, Frame->Y, 
				NULL, 
				1.0, 
				FPlane(1,1,1,0), 
				FPlane(0,0,0,0), 
				PF_TwoSided,
				0
			);
			POP_HIT(Frame);
			break;
		}
		case REN_TexBrowser:
		{
			Actor->bHiddenEd = 1;
			Actor->bHidden   = 1;
			DrawViewerBackground( Frame );
			DrawTextureBrowser( Frame );
			break;
		}
		case REN_MeshView:
		{
			if ( LockMeshView == 0 )
				DrawMeshView( Frame );
			break;
		}
		default:
		{
			Actor->bHiddenEd = Viewport->IsOrtho();

			// Draw background.
			if
			(	Viewport->IsOrtho()
				||	Viewport->IsWire()
				|| !(Viewport->Actor->ShowFlags & SHOW_Backdrop) )
			{
				DrawWireBackground( Frame );
				// Clearing the ZBuffer makes the world grid lines in the 3D view ALWAYS appear
				// behind world geometry ... this is to make other renderers (which have ZBuffers) 
				// act like the software renderer in this respect.
				if( !Viewport->IsOrtho() )
					Viewport->RenDev->ClearZ( Frame );
			}

			PUSH_HIT(Frame,HCoords(Frame));

			// Draw the level.
			UBOOL bStaticBrushes = Viewport->IsWire();
			UBOOL bMovingBrushes = (Viewport->Actor->ShowFlags & SHOW_MovingBrushes)!=0;
			UBOOL bActiveBrush   = (Viewport->Actor->ShowFlags & SHOW_Brush)!=0;
			if( !Viewport->IsWire() )
				Render->DrawWorld( Frame );
//			if( bStaticBrushes || bMovingBrushes || bActiveBrush )
			DrawLevelBrushes( Frame, bStaticBrushes, bMovingBrushes, bActiveBrush );

			// Draw all paths.
			if( (Viewport->Actor->ShowFlags&SHOW_Paths) )
			{
				for( INT i=0; i<Viewport->Actor->GetLevel()->ReachSpecs.Num(); i++ )
				{
					FReachSpec& ReachSpec = Viewport->Actor->GetLevel()->ReachSpecs( i );
					if( ReachSpec.Start && ReachSpec.End && !ReachSpec.bPruned )
					{
						Viewport->RenDev->Queue3DLine
						(
							Frame,
							ReachSpec.PathColor(),
							LINE_DepthCued,
							ReachSpec.Start->Location + FVector(0,0,8.f), 
							ReachSpec.End->Location
						);

						// make arrowhead to show L.D direction of path
						FVector Dir = ReachSpec.End->Location - ReachSpec.Start->Location - FVector(0,0,8.f);
						Dir.Normalize();
						Viewport->RenDev->Queue3DLine
						(
							Frame,
							ReachSpec.PathColor(),
							LINE_DepthCued,
							ReachSpec.End->Location - 12 * Dir + FVector(0,0,3.f), 
							ReachSpec.End->Location - 6 * Dir
						);
						Viewport->RenDev->Queue3DLine
						(
							Frame,
							ReachSpec.PathColor(),
							LINE_DepthCued,
							ReachSpec.End->Location - 12 * Dir - FVector(0,0,3.f), 
							ReachSpec.End->Location - 6 * Dir
						);
					}
				}
				Viewport->RenDev->Queued3DLinesFlush(Frame);
			}

			// Draw actors.
			if( Viewport->Actor->ShowFlags & SHOW_Actors )
			{
				// Draw actor extras.
				for( INT iActor=0; iActor<Viewport->Actor->GetLevel()->Actors.Num(); iActor++ )
				{
					AActor* Actor = Viewport->Actor->GetLevel()->Actors(iActor);
					if(!Actor||Actor->bHiddenEd) continue;

					
#if 1
					// if far-plane (Z) clipping is enabled, consider aborting this actor
					if( EdClipZ > 0.f && !Frame->Viewport->IsOrtho() )
					{
						FVector	Temp = Actor->Location - Frame->Coords.Origin;
						Temp     = Temp.TransformVectorBy( Frame->Coords );
						FLOAT Z  = Temp.Z; if (Abs (Z)<0.01f) Z+=0.02f;

						if( Z < 1.0f || Z > EdClipZ )
							continue;
					}
#endif
					PUSH_HIT(Frame,HActor(Actor));

						

						// If this actor is an event source, draw event lines connecting it to
						// all corresponding event sinks.
						if(	Actor->Event!=NAME_None && !Actor->bHiddenEd
						&&	Viewport->IsWire()
						&& ((!Actor->bNoDrawEditorLines || Actor->IsOwnedBy(Viewport->Actor))))
						{
							/* See if this is an interpolation point, and if I should draw it with splines: */
							if(!Actor->IsA(AInterpolationPoint::StaticClass()))
							{
															/* Just draw a line connecting the source and destination */
								
								int Count=Viewport->Actor->GetLevel()->Actors.Num();
								for( INT iOther=0; iOther<Count; iOther++ )
								{
									AActor* OtherActor = Viewport->Actor->GetLevel()->Actors( iOther );
									if((OtherActor)&&(OtherActor->Tag==Actor->Event))
									{
										Viewport->RenDev->Queue3DLine( Frame, C_ActorArrow.Plane(), LINE_None, Actor->Location, OtherActor->Location );
									}
								}

							} else
							{
								// Handle interpolation points:
								AInterpolationPoint *Source = Cast<AInterpolationPoint>( Actor );
								if(Source->MotionType==MOTION_Spline)
								{
									int Count=Viewport->Actor->GetLevel()->Actors.Num();

									for( INT iOther=0; iOther<Count; iOther++ )
									{
										AInterpolationPoint* Dest = Cast<AInterpolationPoint>(Viewport->Actor->GetLevel()->Actors( iOther ));
										if
										(	(Dest)
										&&	(Dest->Tag == Actor->Event) 
										&&	(GIsEditor ? !Actor->bHiddenEd : !Actor->bHidden)
										&&  (!Actor->bNoDrawEditorLines || Actor->IsOwnedBy(Viewport->Actor)) )
										{
											UBOOL DrewOne=false;
											for(INT iPrev=0;iPrev<Count; iPrev++ )
											{
												AInterpolationPoint *Prev=Cast<AInterpolationPoint>(Viewport->Actor->GetLevel()->Actors( iPrev ));
												
												if(!Prev) continue;
												if(Prev->Event!=Source->Event) continue;

												for(INT iNextNext=0;iNextNext<Count; iNextNext++ )
												{
													AInterpolationPoint *NextNext=Cast<AInterpolationPoint>(Viewport->Actor->GetLevel()->Actors( iNextNext ));

													if(!NextNext) continue;
													if(NextNext->Tag!=Dest->Event) continue;
												
													FVector TempVector=Dest->Location-Source->Location;

													Viewport->RenDev->Draw3DSplineSection( Frame, C_ActorArrow.Plane(), LINE_None,
														   						 Clamp(((((INT)TempVector.Size())/12)+1),6,15),
																				 Prev->Location,		Prev->Rotation,
																				 Source->Location,		Source->Rotation,
																				 Dest->Location,		Dest->Rotation,
																				 NextNext->Location,    NextNext->Rotation
																			   );
													DrewOne=true;
												}

												break; // Only try one previous
											}

											// If I didn't have a previous or next, just draw a line: 
											if(!DrewOne)
												Viewport->RenDev->Queue3DLine( Frame, C_ActorArrow.Plane(), LINE_None, Actor->Location, Dest->Location );

										}
									}
								} 							
							}
						}

						// If this actor is connected to an interpolation point, draw lines connecting it to
						// all corresponding destination interpolation points.
						if
						(	Actor->StartingInterpolationPoint!=NAME_None
						&&	Viewport->IsWire() )//SHOW_Events!!
						{
							for( INT iOther=0; iOther<Viewport->Actor->GetLevel()->Actors.Num(); iOther++ )
							{
								AActor* OtherActor = Viewport->Actor->GetLevel()->Actors( iOther );
								if
								(	(OtherActor)
								&&	(OtherActor->Tag == Actor->StartingInterpolationPoint) 
								&&	(GIsEditor ? !Actor->bHiddenEd : !Actor->bHidden)
								&&  (!Actor->bNoDrawEditorLines || Actor->IsOwnedBy(Viewport->Actor)) )
								{
									Viewport->RenDev->Queue3DLine( Frame, C_ActorArrow.Plane()/*C_ActorInterpolationArrow.Plane()*/, LINE_None, Actor->Location, OtherActor->Location );
								}
							}
						}

						// Radii.
						if( (Viewport->Actor->ShowFlags & SHOW_ActorRadii) && Actor->bSelected )
						{
							if( !Actor->IsBrush() )
							{
								if( Viewport->IsOrtho() )
								{
									if( Actor->bCollideActors )
									{
										// Show collision radius
										if( Viewport->Actor->RendMap==REN_OrthXY )
											Render->DrawCircle( Frame, C_ActorArrow.Plane(), LINE_None, Actor->Location, Actor->CollisionRadius );

										// Show collision height.
										FVector Ext(Actor->CollisionRadius,Actor->CollisionRadius,Actor->CollisionHeight);
										FVector Min(Actor->Location - Ext);
										FVector Max(Actor->Location + Ext);
										if( Viewport->Actor->RendMap!=REN_OrthXY )
											Render->DrawBox( Frame, C_ActorArrow.Plane(), LINE_Transparent, Min, Max );
									}
								}
								else
								{
									if( Actor->bCollideActors )
										Render->DrawCylinder( Frame, C_BrushWire.Plane(), LINE_Transparent, Actor->Location, Actor->CollisionRadius, Actor->CollisionHeight );
								}
							}
							else if( Actor->IsMovingBrush() )
							{
								FBox Box = Actor->GetPrimitive()->GetRenderBoundingBox(Actor,0);
								Render->DrawBox( Frame, C_ActorArrow.Plane(), LINE_Transparent, Box.Min, Box.Max );
							}

							// Show light radius.
							if( Actor->LightType!=LT_None && Actor->bSelected && GIsEditor && Actor->LightBrightness && Actor->LightRadius )
								Render->DrawCircle( Frame, C_ActorArrow.Plane(), LINE_None, Actor->Location, Actor->WorldLightRadius() );

							// Show light radius.
							if( Actor->LightType!=LT_None && Actor->bSelected && GIsEditor && Actor->VolumeBrightness && Actor->VolumeRadius )
								Render->DrawCircle( Frame, C_Mover.Plane(), LINE_None, Actor->Location, Actor->WorldVolumetricRadius() );

							// Show sound radius.
							if( Actor->AmbientSound && Actor->bSelected && GIsEditor )
								Render->DrawCircle( Frame, C_GroundHighlight.Plane(), LINE_None, Actor->Location, Actor->WorldSoundRadius() );
						}

						// Direction arrow.
						if
						(  Actor->bDirectional
						&& Viewport->IsOrtho()
						&& (Actor->bSelected || Cast<ACamera>(Actor)) )
						{
							PUSH_HIT(Frame,HActor(Actor));
							FVector V = Actor->Location, A(0,0,0), B(0,0,0);
							FCoords C = GMath.UnitCoords / Actor->Rotation;
							Viewport->RenDev->Queue3DLine( Frame, C_ActorArrow.Plane(), LINE_None, V + C.XAxis * 48, V );
							Viewport->RenDev->Queue3DLine( Frame, C_ActorArrow.Plane(), LINE_None, V + C.XAxis * 48, V + C.XAxis * 16 + C.YAxis * 16 );
							Viewport->RenDev->Queue3DLine( Frame, C_ActorArrow.Plane(), LINE_None, V + C.XAxis * 48, V + C.XAxis * 16 - C.YAxis * 16 );
							Viewport->RenDev->Queue3DLine( Frame, C_ActorArrow.Plane(), LINE_None, V + C.XAxis * 48, V + C.XAxis * 16 + C.ZAxis * 16 );
							Viewport->RenDev->Queue3DLine( Frame, C_ActorArrow.Plane(), LINE_None, V + C.XAxis * 48, V + C.XAxis * 16 - C.ZAxis * 16 );
							POP_HIT(Frame);
						}

						if( Viewport->IsOrtho() && Cast<AClipMarker>(Actor) )
							Render->DrawCircle( Frame, C_BrushWire.Plane(), LINE_None, Actor->Location, 8, 1 );

						POP_HIT(Frame);

						// Draw him.
						if( Viewport->IsWire() )
							Render->DrawActor( Frame, Actor );
					
				}
			}
			Viewport->RenDev->Queued3DLinesFlush(Frame);

			// Show pivot.
			if( GPivotShown && GEditor->Mode != EM_VertexEdit )
			{
				FLOAT X, Y;
				FVector Location = GSnappedLocation;
				if( Render->Project( Frame, Location, X, Y, NULL ) )
				{
					PUSH_HIT(Frame,HGlobalPivot(Location));
         			Viewport->RenDev->Draw2DPoint( Frame, C_BrushWire.Plane(), LINE_None, X-1, Y-1, X+1, Y+1, Location.Z );
        			Viewport->RenDev->Draw2DPoint( Frame, C_BrushWire.Plane(), LINE_None, X,   Y-4, X,   Y+4, Location.Z );
         			Viewport->RenDev->Draw2DPoint( Frame, C_BrushWire.Plane(), LINE_None, X-4, Y,   X+4, Y,   Location.Z );
					POP_HIT(Frame);
				}
			}

#if 0 //Interpolation Paths (from Ion Storm, Austin) added by Legend on 4/12/2000
			//
			// DEUS_EX CNN - Draw the spline curves for InterpolationPoints
			//
			
			// get the tag of the selected point
			FName matchTag = NAME_None;
			AActor* Actor;
			for (INT iActor=0; iActor<Viewport->Actor->GetLevel()->Actors.Num();
			iActor++)
			{
				Actor = Viewport->Actor->GetLevel()->Actors(iActor);
				if (Actor && Actor->IsA(AInterpolationPoint::StaticClass()) &&
					Actor->bSelected)
				{
					matchTag = Actor->Tag;
					break;
				}
			}
			
			// generate a list of all matching points
#define MAX_INTERP_POINTS 128
			AInterpolationPoint* PointList[MAX_INTERP_POINTS];
			INT numPoints = -1;
			for (INT i=0; i<MAX_INTERP_POINTS; i++)
				PointList[i] = NULL;
			for (iActor=0; iActor<Viewport->Actor->GetLevel()->Actors.Num(); iActor++)
			{
				Actor = Viewport->Actor->GetLevel()->Actors(iActor);
				if (Actor && Actor->IsA(AInterpolationPoint::StaticClass()) && (Actor->Tag == matchTag))
				{
					AInterpolationPoint* Dest = Cast<AInterpolationPoint>(Actor);
					if (Dest->Position < MAX_INTERP_POINTS)
					{
						PointList[Dest->Position] = Dest;
						if (Dest->Position > numPoints)
							numPoints = Dest->Position;
					}
				}
			}
			
			numPoints++;
			if (numPoints > 2)
			{
				if (numPoints < MAX_INTERP_POINTS-2)
				{
					// if this path should loop, link the points back to the beginning
					if (!PointList[numPoints-1]->bEndOfPath)
					{
						PointList[numPoints] = PointList[0];
						PointList[numPoints+1] = PointList[1];
						PointList[numPoints+2] = PointList[2];
					}
				}
				
				// draw the entire chain if something is selected
				INT cur = 1;
				
				while (PointList[cur])
				{
					FVector v1, v2;
					FRotator r1;
					FCoords C;
					if (PointList[cur-1] && PointList[cur+1] && PointList[cur+2])
					{
						FLOAT alpha = 0.0f;
						FLOAT alphastep = 0.02f;
						FLOAT arrow = 0.0f;
						FLOAT arrowstep = PointList[cur]->RateModifier / 5.0f;
						FLOAT W0, W1, W2, W3, RW;
						
						while (alpha < 1.0-alphastep)
						{
							// Cubic spline interpolation.
							W0 = Splerp(alpha+1.0f);
							W1 = Splerp(alpha+0.0f);
							W2 = Splerp(alpha-1.0f);
							W3 = Splerp(alpha-2.0f);
							RW = 1.0f / (W0 + W1 + W2 + W3);
							v1 = (W0*PointList[cur-1]->Location + W1*PointList[cur]->Location +
								W2*PointList[cur+1]->Location + W3*PointList[cur+2]->Location)*RW;
							r1 = (W0*PointList[cur-1]->Rotation + W1*PointList[cur]->Rotation +
								W2*PointList[cur+1]->Rotation + W3*PointList[cur+2]->Rotation)*RW;
							
							W0 = Splerp(alpha+alphastep+1.0f);
							W1 = Splerp(alpha+alphastep+0.0f);
							W2 = Splerp(alpha+alphastep-1.0f);
							W3 = Splerp(alpha+alphastep-2.0f);
							RW = 1.0f / (W0 + W1 + W2 + W3);
							v2 = (W0*PointList[cur-1]->Location + W1*PointList[cur]->Location +
								W2*PointList[cur+1]->Location + W3*PointList[cur+2]->Location)*RW;
							
							// draw the path in white
							Viewport->RenDev->Queue3DLine(Frame, FPlane(1,1,1,0), LINE_None, v1, v2);
							
							// draw orientation axes on the path (Xfront = green, Yright = blue, Zup = red)
							if (arrow <= alpha)
							{
								C = GMath.UnitCoords / r1;
								Viewport->RenDev->Queue3DLine(Frame, FPlane(0,1,0,0), LINE_None, v1, v1 + C.XAxis * 32);
								Viewport->RenDev->Queue3DLine(Frame, FPlane(0,0,1,0), LINE_None, v1, v1 + C.YAxis * 32);
								Viewport->RenDev->Queue3DLine(Frame, FPlane(1,0,0,0), LINE_None, v1, v1 + C.ZAxis * 32);
								arrow += arrowstep;
							}
							
							// inc the alpha
							alpha += alphastep;
						}
						Viewport->RenDev->Queued3DLinesFlush(Frame);
					}
					
					// get the next point, but don't pass the end of the list
					cur++;
					if (cur >= MAX_INTERP_POINTS-2)
						break;
				}
			}
			
			//
			// DEUS_EX CNN - end changes
			//
			
#endif

			//
			// SIZING BOX
			//

			if( GEditor->Constraints.UseSizingBox
					&& (GEditor->Mode == EM_BrushSnap || GEditor->Mode == EM_VertexEdit ) )
			{

				FBox SizingBox;
				SizingBox.Init();

				for( INT i = 0 ; i < GEditor->Level->Actors.Num() ; i++ )
				{
					AActor* pActor = GEditor->Level->Actors(i);
					if( pActor && pActor->IsBrush() && pActor->bSelected )
						SizingBox += Cast<ABrush>(pActor)->Brush->GetCollisionBoundingBox( pActor );
				}

				if( SizingBox.IsValid )
				{
					FString Line1, Line2, Line3;

					Line1 = FString::Printf(TEXT("Width  : %d"), (INT)(SizingBox.Max.X - SizingBox.Min.X) );
					Line2 = FString::Printf(TEXT("Height : %d"), (INT)(SizingBox.Max.Z - SizingBox.Min.Z) );
					Line3 = FString::Printf(TEXT("Depth  : %d"), (INT)(SizingBox.Max.Y - SizingBox.Min.Y) );

					SizingBox.Min -= FVector( 8,8,8 );
					SizingBox.Max += FVector( 8,8,8 );
					if( GEditor->Mode != EM_BrushSnap )
						GEditor->DrawBoundingBox( Frame, &SizingBox, NULL );

					INT XL, YL;
					Viewport->Canvas->WrappedStrLenf( Viewport->Canvas->SmallFont, XL, YL, *(Line1.Len() > Line2.Len() ? (Line1.Len() > Line3.Len() ? Line1 : Line3) : Line2) );

					Viewport->Canvas->DrawPattern( GEditor->Bkgnd,
						0, 0, XL+2, (YL*3)+2,
						1.0, 0.0, 0.0, NULL, 1.0, FPlane(1.,1.,1.,0), FPlane(0,0,0,0), 0 );

					Viewport->Canvas->Color = FColor(255,255,255);
					Viewport->Canvas->SetClip( 1, 1, 256, YL );
					Viewport->Canvas->WrappedPrintf( Viewport->Canvas->SmallFont, 0, *Line1 );
					Viewport->Canvas->SetClip( 1, YL+1, 256, YL );
					Viewport->Canvas->WrappedPrintf( Viewport->Canvas->SmallFont, 0, *Line2 );
					Viewport->Canvas->SetClip( 1, (YL*2)+1, 256, YL );
					Viewport->Canvas->WrappedPrintf( Viewport->Canvas->SmallFont, 0, *Line3 );
				}
			}

			//
			// BOX SELECTION
			//

			// If the user is doing a box selection in this viewport, draw the current selection box.
			//
			if( Viewport->IsOrtho() && GbIsBoxSel )
				Render->DrawBox( Frame, C_BrushWire.Plane(), LINE_None, GBoxSelStart, GBoxSelEnd );

			//
			// SNAP SCALING
			//

			if( GbIsSnapScaleBox )
			{
				FBox BBox( GSnapScaleStart, GSnapScaleEnd );
				DrawBoundingBox( Frame, &BBox, NULL );
			}

			//
			// CLIP MARKERS
			//

			// If the user is brush clipping, draw lines to show them what's going on.
			//
			TArray<AActor*> ClipMarkers;

			// Gather a list of all the ClipMarkers in the level.
			//
			for( INT i = 0 ; i < GEditor->Level->Actors.Num() ; i++ )
			{
				AActor* pActor = GEditor->Level->Actors(i);
				if( pActor && pActor->IsA(AClipMarker::StaticClass()) )
					ClipMarkers.AddItem( pActor );
			}

			if( ClipMarkers.Num() > 1 )
			{
				// Draw a connecting line between them all.
				//
				for( INT x = 1 ; x < ClipMarkers.Num() ; x++ )
					Viewport->RenDev->Queue3DLine(Frame, C_BrushWire.Plane(), LINE_None/*LINE_DepthCued*/, ClipMarkers(x - 1)->Location, ClipMarkers(x)->Location);

				// Draw an arrow that shows the direction of the clipping plane.  This arrow should
				// appear halfway between the first and second markers.
				//
				FVector vtx1, vtx2, vtx3;
				FPoly NormalPoly;
				UBOOL bDrawOK = 1;

				vtx1 = ClipMarkers(0)->Location;
				vtx2 = ClipMarkers(1)->Location;

				if( ClipMarkers.Num() == 3 )
				{
					// If we have 3 points, just grab the third one to complete the plane.
					//
					vtx3 = ClipMarkers(2)->Location;
				}
				else
				{
					// If we only have 2 points, we will assume the third based on the viewport.
					// (With only 2 points, we can only render into the ortho viewports)
					//
					vtx3 = vtx1;
					if( Viewport->IsOrtho() )
					{
						switch( Viewport->Actor->RendMap )
						{
							case REN_OrthXY:
								vtx3.Z -= 64;
								break;

							case REN_OrthXZ:
								vtx3.Y -= 64;
								break;

							case REN_OrthYZ:
								vtx3.X -= 64;
								break;
						}
					}
					else
						bDrawOK = 0;
				}

				NormalPoly.NumVertices = 3;
				NormalPoly.Vertex[0] = vtx1;
				NormalPoly.Vertex[1] = vtx2;
				NormalPoly.Vertex[2] = vtx3;

				if( bDrawOK && !NormalPoly.CalcNormal(1) )
				{
					FVector Start = vtx1 + (( vtx2 - vtx1 ) / 2);
					Viewport->RenDev->Queue3DLine( Frame, C_BrushWire.Plane(), LINE_None, Start, Start + (NormalPoly.Normal * 48 ));
				}
			}

			//
			// POLYGON DRAWING
			//

			TArray<AActor*> PolyMarkers;

			// Gather a list of all the PolyMarkers in the level.
			//
			for( i = 0 ; i < GEditor->Level->Actors.Num() ; i++ )
			{
				AActor* pActor = GEditor->Level->Actors(i);
				if( pActor && pActor->IsA(APolyMarker::StaticClass()) )
					PolyMarkers.AddItem( pActor );
			}
			// Draw a connecting line between them all.
			//
			for( INT x = 1 ; x < PolyMarkers.Num() ; x++ )
				Viewport->RenDev->Queue3DLine(Frame, C_BrushWire.Plane(), LINE_None, PolyMarkers(x - 1)->Location, PolyMarkers(x)->Location);

			Viewport->RenDev->Queued3DLinesFlush(Frame);
			POP_HIT(Frame);
			break;
		}
	}

	Render->PostRender( Frame );
	Viewport->Unlock( Blit );
	Render->FinishMasterFrame();
}

/*-----------------------------------------------------------------------------
   Viewport mouse click handling.
-----------------------------------------------------------------------------*/

//
// Handle a mouse click in the camera window.
//
void UEditorEngine::Click
(
	UViewport*	Viewport, 
	DWORD		Buttons,
	FLOAT		MouseX,
	FLOAT		MouseY
)
{
	// Set hit-test location.
	Viewport->HitX  = Clamp(appFloor(MouseX)-2,0,Viewport->SizeX);
	Viewport->HitY  = Clamp(appFloor(MouseY)-2,0,Viewport->SizeY);
	Viewport->HitXL = Clamp(appFloor(MouseX)+3,0,Viewport->SizeX) - Viewport->HitX;
	Viewport->HitYL = Clamp(appFloor(MouseY)+3,0,Viewport->SizeY) - Viewport->HitY;

	// Draw with hit-testing.
	BYTE HitData[1024];
	INT HitCount=ARRAY_COUNT(HitData);
	Draw( Viewport, 0, HitData, &HitCount );

	// Update buttons.
	if( Viewport->Input->KeyDown(IK_Shift) )
		Buttons |= MOUSE_Shift;
	if( Viewport->Input->KeyDown(IK_Ctrl) )
		Buttons |= MOUSE_Ctrl;
	if( Viewport->Input->KeyDown(IK_Alt) )
		Buttons |= MOUSE_Alt;

	// Perform hit testing.
	FEditorHitObserver Observer;
	Viewport->ExecuteHits( FHitCause(&Observer,Viewport,Buttons,MouseX,MouseY), HitData, HitCount );
}

// A convenience function so that Viewports can set the click location manually.
void UEditorEngine::edSetClickLocation( FVector& InLocation )
{
	ClickLocation = InLocation;
}

/*-----------------------------------------------------------------------------
   Editor camera mode.
-----------------------------------------------------------------------------*/

//
// Set the editor mode.
//
void UEditorEngine::edcamSetMode( INT InMode )
{
	// Clear old mode.
	if( Mode != EM_None )
		for( INT i=0; i<Client->Viewports.Num(); i++ )
			MouseDelta( Client->Viewports(i), MOUSE_ExitMode, 0, 0 );

	// Set new mode.
	Mode = InMode;
	if( Mode != EM_None )
		for( INT i=0; i<Client->Viewports.Num(); i++ )
			MouseDelta( Client->Viewports(i), MOUSE_SetMode, 0, 0 );

	EdCallback( EDC_RedrawAllViewports, 0 );
	RedrawLevel( Level );
}

//
// Return editor camera mode given Mode and state of keys.
// This handlers special keyboard mode overrides which should
// affect the appearance of the mouse cursor, etc.
//
INT UEditorEngine::edcamMode( UViewport* Viewport )
{
	check(Viewport);
	check(Viewport->Actor);
	switch( Viewport->Actor->RendMap )
	{
		case REN_TexView:    return EM_TexView;
		case REN_TexBrowser: return EM_TexBrowser;
		case REN_MeshView:   return EM_MeshView;
	}
	return Mode;
}

/*-----------------------------------------------------------------------------
	Selection.
-----------------------------------------------------------------------------*/

//
// Selection change.
//
void UEditorEngine::NoteSelectionChange( ULevel* Level )
{
	// Notify the editor.
	EdCallback( EDC_SelChange, 0 );

	// Pick a new common pivot, or not.
	INT Count=0;
	AActor* SingleActor=NULL;
	for( INT i=0; i<Level->Actors.Num(); i++ )
	{
		if( Level->Actors(i) && Level->Actors(i)->bSelected )
		{
			SingleActor=Level->Actors(i);
			Count++;
		}
	}
	if( Count==0 ) ResetPivot();
	else if( Count==1 ) SetPivot( SingleActor->Location, 0, 0 );

	// Update properties window.
	UpdatePropertiesWindows();

	vertexedit_Refresh();
}

//
// Select none.
//
void UEditorEngine::SelectNone( ULevel *Level, UBOOL Notify )
{
	if( Mode == EM_VertexEdit )
		VertexHitList.Empty();

	// Unselect all actors.
	for( INT i=0; i<Level->Actors.Num(); i++ )
	{
		AActor* Actor = Level->Actors(i);
		if( Actor && Actor->bSelected )
		{
			// We don't do this in certain modes.  This allows the user to select
			// the brushes they want and not have them get deselected while trying to
			// work with them.
			if( Actor->IsBrush() && ( Mode == EM_BrushClip ) )
				continue;

			Actor->Modify();
			Actor->bSelected = 0;
		}
	}

	// Unselect all surfaces.
	for( i=0; i<Level->Model->Surfs.Num(); i++ )
	{
		FBspSurf& Surf = Level->Model->Surfs(i);
		if( Surf.PolyFlags & PF_Selected )
		{
			Level->Model->ModifySurf( i, 0 );
			Surf.PolyFlags &= ~PF_Selected;
		}
	}

	if( Notify )
		NoteSelectionChange( Level );
}

void UEditorEngine::SelectSetEvents( FName NewEvent, ULevel *Level, UBOOL Notify )
{
	// Set all events to this actor's event:
	for( INT i=0; i<Level->Actors.Num(); i++ )
	{
		AActor* Actor = Level->Actors(i);
		if( Actor && Actor->bSelected )
		{
			Actor->Modify();
			Actor->Event=NewEvent;
		}
	}

	if( Notify )
		NoteSelectionChange( Level );
}

void UEditorEngine::SelectSetMountParents( FName NewMountParent, ULevel *Level, UBOOL Notify )
{
	// Set all events to this actor's event:
	for( INT i=0; i<Level->Actors.Num(); i++ )
	{
		AActor* Actor = Level->Actors(i);
		if( Actor && Actor->bSelected )
		{
			Actor->Modify();
			Actor->MountParentTag=NewMountParent;
			Actor->MountType=MOUNT_Actor;
			Actor->setPhysics(PHYS_MovingBrush);
		}
	}

	if( Notify )
		NoteSelectionChange( Level );
}
/*-----------------------------------------------------------------------------
	Ed link topic function.
-----------------------------------------------------------------------------*/

AUTOREGISTER_TOPIC(TEXT("Ed"),EdTopicHandler);
void EdTopicHandler::Get( ULevel* Level, const TCHAR* Item, FOutputDevice& Ar )
{
	if		(!appStricmp(Item,TEXT("LASTSCROLL")))	Ar.Logf(TEXT("%i"),GLastScroll);
	else if (!appStricmp(Item,TEXT("CURTEX")))		Ar.Log(GEditor->CurrentTexture ? GEditor->CurrentTexture->GetName() : TEXT("None"));
}
void EdTopicHandler::Set( ULevel* Level, const TCHAR* Item, const TCHAR* Data )
{}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
