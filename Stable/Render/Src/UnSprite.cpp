/*=============================================================================
	UnSprite.cpp: DukeForever sprite rendering functions.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

#include "..\..\Engine\Src\EnginePrivate.h"

#define FILTER_OPTIMIZATION		// JEP

/*------------------------------------------------------------------------------
	FDynamicItem implementation.
------------------------------------------------------------------------------*/

FDynamicItem::FDynamicItem( INT iNode )
{
	if( !GRender->Dynamic(iNode,0) && !GRender->Dynamic(iNode,1) )
		GRender->PostDynamics[GRender->NumPostDynamics++] = &GRender->DynamicsCache[iNode];
}
 
/*------------------------------------------------------------------------------
	FDynamicSprite implementation.
------------------------------------------------------------------------------*/

FDynamicSprite::FDynamicSprite( FSceneNode* Frame, INT iNode, AActor* InActor )
:	FDynamicItem	( iNode )
,	Actor			( InActor )
,	SpanBuffer		( NULL )
,	RenderNext		( NULL )
,	Volumetrics		( NULL )
,	LeafLights		( NULL )
{
	if( Setup( Frame ) )
	{
		// Add at start of list.
		FilterNext = GRender->Dynamic( iNode, 0 );
		GRender->Dynamic( iNode, 0 ) = this;

		// Compute four projection-plane points from sprite extents and viewport.
		FLOAT FloatX1 = X1; 
		FLOAT FloatX2 = X2;
		FLOAT FloatY1 = Y1; 
		FLOAT FloatY2 = Y2;

		// Move closer to prevent actors from slipping into floor.
		FLOAT PlaneZRD	= Z * Frame->RProj.Z;
		FLOAT PlaneX1   = PlaneZRD * (FloatX1 - Frame->FX2);
		FLOAT PlaneX2   = PlaneZRD * (FloatX2 - Frame->FX2);
		FLOAT PlaneY1   = PlaneZRD * (FloatY1 - Frame->FY2);
		FLOAT PlaneY2   = PlaneZRD * (FloatY2 - Frame->FY2);

		// Generate four screen-aligned box vertices.
		ProxyVerts[0].Point = FVector(PlaneX1, PlaneY1, Z).TransformPointBy( Frame->Uncoords );
		ProxyVerts[1].Point = FVector(PlaneX2, PlaneY1, Z).TransformPointBy( Frame->Uncoords );
		ProxyVerts[2].Point = FVector(PlaneX2, PlaneY2, Z).TransformPointBy( Frame->Uncoords );
		ProxyVerts[3].Point = FVector(PlaneX1, PlaneY2, Z).TransformPointBy( Frame->Uncoords );

		// Screen coords.
		ProxyVerts[0].ScreenX = FloatX1; ProxyVerts[0].ScreenY = FloatY1;
		ProxyVerts[1].ScreenX = FloatX2; ProxyVerts[1].ScreenY = FloatY1;
		ProxyVerts[2].ScreenX = FloatX2; ProxyVerts[2].ScreenY = FloatY2;
		ProxyVerts[3].ScreenX = FloatX1; ProxyVerts[3].ScreenY = FloatY2;

		// Generate a full rasterization for this box, which we'll filter down the Bsp.
		//!!inefficient when in box
		if(Y2>Frame->Y
		 &&!(!GIsEditor&&Actor->IsA(ASoftParticleSystem::StaticClass())&&!((ASoftParticleSystem *)Actor)->ParticleRecursing)
		 &&!(!GIsEditor&&Actor->IsA(ABeamSystem::StaticClass()))
		 )
		{
			check(Y1>=0);
			check(Y2<=Frame->Y);
		}
		check(Y1<Y2);

		FRasterPoly* Raster = (FRasterPoly *)New<BYTE>(GDynMem,sizeof(FRasterPoly) + (Y2-Y1)*sizeof(FRasterSpan));
		Raster->StartY	    = Y1;
		Raster->EndY	    = Y2;

		FRasterSpan* Line = &Raster->Lines[0];
		for( INT i=Raster->StartY; i<Raster->EndY; i++ )
		{
			Line->X[0] = X1;
			Line->X[1] = X2;
			Line++;
		}

		// Add first sprite chunk at end of dynamics list, and cause it to be filtered, since
		// it's being added at the start.
		new(GDynMem)FDynamicChunk( iNode, this, Raster );

		GStat.MeshSubCount++;
	}
	STAT(GStat.NumSprites++);
}

UBOOL FDynamicSprite::Setup( FSceneNode* Frame )
{
	// NJS: Draw particle systems when not in the editor:
	if(!GIsEditor
	  &&Actor->IsA(ASoftParticleSystem::StaticClass())
	  &&!((ASoftParticleSystem *)Actor)->ParticleRecursing)
	{
		ASoftParticleSystem *p=(ASoftParticleSystem *)Actor;
		// Set up for the particle system actor itself:

		if(!p->BSPOcclude) return 0;	// Don't filter through BSP if not using BSP occlusion.

		// Setup projection plane.
		// JEP commented out
		//Z = ((Actor->Location - Frame->Coords.Origin) | Frame->Coords.ZAxis)/* - SPRITE_PROJECTION_FORWARD*/;

		FScreenBounds ScreenBounds;
		FBox Bounds;
		Bounds.Min=p->BoundingBoxMin;
		Bounds.Max=p->BoundingBoxMax;

		if(p->RelativeRotation)
		{
			Bounds.Min=p->Location-FVector(5,5,5);
			Bounds.Max=p->Location+FVector(5,5,5);
		}

		if((!GRender->BoundVisible( Frame, &Bounds, NULL, ScreenBounds ) )
		 && (!Actor->bAlwaysVisible))
			return 0;

		// JEP ...
		Z = ScreenBounds.MinZ;

		if (Z < 1.0)
			Z = 1.0;
		// ... JEP

		X1 = (INT) ScreenBounds.MinX;
		X2 = (INT) ScreenBounds.MaxX;
		Y1 = (INT) ScreenBounds.MinY;
		Y2 = (INT) ScreenBounds.MaxY;

		// NJS: Try to get rid of this check:
		if( Y1>=Y2 )
		{
			X1=Y1=0;
			X2=Y2=1;
			return 0;	// NJS: Occlusion fix?
		}

		return 1;
	} 
	//else if (!GIsEditor && Actor->IsA(ABreakableGlass::StaticClass()))
	else if (Actor->IsA(ABreakableGlass::StaticClass()))// && !Frame->Viewport->IsOrtho())
	{
		UPrimitive *Prim = Actor->GetPrimitive();

		check(Prim);

		FScreenBounds ScreenBounds;
		FBox Bounds = Prim->GetRenderBoundingBox( Actor, 0 );

		if (!GRender->BoundVisible( Frame, &Bounds, NULL, ScreenBounds ))
			return 0;

		Z = ScreenBounds.MinZ;

		if (Z < 1.0)
			Z = 1.0;

		X1 = appRound(ScreenBounds.MinX);
		X2 = appRound(ScreenBounds.MaxX);
		Y1 = appRound(ScreenBounds.MinY);
		Y2 = appRound(ScreenBounds.MaxY);
		
		if( Y1>=Y2 )
			return 0;

		return 1;
	}
	else if(!GIsEditor&&Actor->IsA(ABeamSystem::StaticClass()))
	{
	// JEP ...
	#if 1
		ABeamSystem *p=(ABeamSystem *)Actor;

		FScreenBounds ScreenBounds;
		FBox Bounds=p->ComputeBoundingBox();

		if((!GRender->BoundVisible( Frame, &Bounds, NULL, ScreenBounds ) )
		 && (!Actor->bAlwaysVisible))
			return 0;

		Z = ScreenBounds.MinZ;

		if (Z < 1.0)
			Z = 1.0;

		X1 = (INT) ScreenBounds.MinX;
		X2 = (INT) ScreenBounds.MaxX;
		Y1 = (INT) ScreenBounds.MinY;
		Y2 = (INT) ScreenBounds.MaxY;

		// NJS: Try to get rid of this check:
		if( Y1>=Y2 )
		{
			X1=Y1=0;
			X2=Y2=1;
			return 0; // NJS: Occlusion fix? 
		}

		return 1;
	#else
	// JEP ...
		ABeamSystem *p=(ABeamSystem *)Actor;
		// Set up for the particle system actor itself:

		// Setup projection plane.
		Z = ((Actor->Location - Frame->Coords.Origin) | Frame->Coords.ZAxis)/* - SPRITE_PROJECTION_FORWARD*/;

		FScreenBounds ScreenBounds;
		FBox Bounds=p->ComputeBoundingBox();

		if((!GRender->BoundVisible( Frame, &Bounds, NULL, ScreenBounds ) )
		 && (!Actor->bAlwaysVisible))
			return 0;

		X1 = (INT) ScreenBounds.MinX;
		X2 = (INT) ScreenBounds.MaxX;
		Y1 = (INT) ScreenBounds.MinY;
		Y2 = (INT) ScreenBounds.MaxY;

		// NJS: Try to get rid of this check:
		if( Y1>=Y2 )
		{
			X1=Y1=0;
			X2=Y2=1;
			return 0; // NJS: Occlusion fix? 
		}

		return 1;
	#endif
	} else
	// Handle the actor based on its type.
	if((Actor->DrawType==DT_Sprite) 
	 ||(Actor->DrawType==DT_SpriteAnimOnce)
	 ||(Frame->Viewport->Actor->ShowFlags & SHOW_ActorIcons) )
	{

		// Make sure we have something to draw.
		FLOAT     DrawScale = Actor->DrawScale;
		UTexture* Texture   = Actor->Texture;

		if( Frame->Viewport->Actor->ShowFlags & SHOW_ActorIcons )
		{
			DrawScale = 1.f;
			if( !Texture )
				Texture = GetDefault<AActor>()->Texture;
		}
		if( !Texture )
			return 0;

		// Setup projection plane.
		Z = ((Actor->Location - Frame->Coords.Origin) | Frame->Coords.ZAxis) - /*SPRITE_PROJECTION_FORWARD*/0;
		if( Z<-2*0/*SPRITE_PROJECTION_FORWARD*/ && !Frame->Viewport->IsOrtho() )
		{} //return 0; 

		// See if this is occluded.
		if( !GRender->Project( Frame, Actor->Location, ScreenX, ScreenY, &Persp ))
			return 0;

		// X extent.
		FLOAT XSize = Persp * DrawScale * Texture->USize;//!!expensive
		X1          = appRound(appCeil(ScreenX-XSize/2));
		X2          = appRound(appCeil(ScreenX+XSize/2));
		if( X1 > X2 ) Exchange( X1, X2 );

		if( X1 < 0 )
		{
			X1 = 0;
			if( X2 < 0 ) X2 = 0;
		}
		if( X2 > Frame->X )
		{
			X2 = Frame->X;
			if( X1 > Frame->X ) X1 = Frame->X;
		}
		if( X2<=0 || X1>=Frame->X-1 )
			return 0;

		// Y extent.
		FLOAT YSize=Persp * DrawScale * Texture->VSize;
		Y1         =appRound(appCeil(ScreenY-YSize/2));
		Y2         =appRound(appCeil(ScreenY+YSize/2));
		if( Y1 > Y2 ) Exchange( Y1, Y2 );

		if( Y1 < 0 )
		{
			Y1 = 0;
			if( Y2 < 0 ) Y2 = 0;
		}
		if( Y2 > Frame->Y )
		{
			Y2 = Frame->Y;
			if( Y1 > Frame->Y )	Y1 = Frame->Y;
		}
		if( Y2<=0 || Y1>=Frame->Y || Y1>=Y2 )
			return 0;

		return 1;
	}
	else if( Actor->DrawType==DT_Mesh )
	{
	// JEP...
	#if 1
		// Verify mesh.
		if( !Actor->Mesh )
			return 0;

		FScreenBounds ScreenBounds;
		FBox Bounds = Actor->Mesh->GetRenderBoundingBox( Actor, 0 );
		if( !GRender->BoundVisible( Frame, &Bounds, NULL, ScreenBounds ) )
			return 0;

		Z = ScreenBounds.MinZ;

		if (Z < 1.0)
			Z = 1.0;

		X1 = appRound(ScreenBounds.MinX);
		X2 = appRound(ScreenBounds.MaxX);
		Y1 = appRound(ScreenBounds.MinY);
		Y2 = appRound(ScreenBounds.MaxY);
		if( Y1>=Y2 )
			return 0;

		return 1;
	#else
	// ... JEP
		// Verify mesh.
		if( !Actor->Mesh )
			return 0;

		// Setup projection plane.
		FVector TestVect = Actor->Location - Frame->Viewport->Actor->Location;

		FLOAT SpriteProj = 0.f;
		if ( Actor->bIsRenderActor )
			SpriteProj = ((ARenderActor*) Actor)->SpriteProjForward;
		if ( Actor->bIsRenderActor && ((ARenderActor*) Actor)->bUseViewportForZ && (TestVect.SizeSquared() < 300.f) )
			Z = ((Frame->Viewport->Actor->Location - Frame->Coords.Origin) | Frame->Coords.ZAxis) - SpriteProj;
		else
			Z = ((Actor->Location - Frame->Coords.Origin) | Frame->Coords.ZAxis) - SpriteProj;
//		if( Z<-2*SPRITE_PROJECTION_FORWARD && !Frame->Viewport->IsOrtho() )
//			{} // CDH
			//return 0;

		FScreenBounds ScreenBounds;
		FBox Bounds = Actor->Mesh->GetRenderBoundingBox( Actor, 0 );
		if ( (!GRender->BoundVisible( Frame, &Bounds, NULL, ScreenBounds )) && (!Actor->bAlwaysVisible) )
			return 0;

		X1 = (INT) ScreenBounds.MinX;
		X2 = (INT) ScreenBounds.MaxX;
		Y1 = (INT) ScreenBounds.MinY;
		Y2 = (INT) ScreenBounds.MaxY;
		if( Y1>=Y2 )
			return 0;

		return 1;
	#endif
	}
	else return 0;
}

/*------------------------------------------------------------------------------
	FDynamicChunk implementation.
------------------------------------------------------------------------------*/

FDynamicChunk::FDynamicChunk( INT iNode, FDynamicSprite* InSprite, FRasterPoly* InRaster )
:	FDynamicItem	( iNode )
,	Raster			( InRaster )
,	Sprite			( InSprite )
{
	// Add at start of list.
	FilterNext = GRender->Dynamic( iNode, 0 );
	GRender->Dynamic( iNode, 0 ) = this;

	STAT(GStat.NumChunks++);
}

void __fastcall FDynamicChunk::Filter( UViewport* Viewport, FSceneNode* Frame, INT iNode, INT Outside )
{
#ifdef FILTER_OPTIMIZATION
	if (Sprite->SpanBuffer)
		return;
#endif

	STAT(clock(GStat.FilterTime));		// JEP

	FBspNode& Node = Frame->Level->Model->Nodes(iNode);

	// Setup.
	FRasterPoly *FrontRaster, *BackRaster;

	// Find point-to-plane distances for all four vertices (side-of-plane classifications).
	INT Front=0, Back=0;
	FLOAT Dist[4];
	for( INT i=0; i<4; i++ )
	{
		Dist[i] = Node.Plane.PlaneDot( Sprite->ProxyVerts[i].Point );
		Front  += Dist[i] > +0.01;
		Back   += Dist[i] < -0.01;
	}

	#if 1
	// JEP ...
	if( !Front && !Back )		// Check on plane case
	{
		if (Dist[0] > 0)		// Use the same logic as the BSP renderer 
			Front = 1;
		else
			Back = 1;
	}
	// ... JEP
	#endif

	if(Front && Back )
	{	
		// Find intersection points.
		FTransform	Intersect[4];
		FTransform* I  = &Intersect	         [0];
		FTransform* V1 = &Sprite->ProxyVerts [3]; 
		FTransform* V2 = &Sprite->ProxyVerts [0];
		FLOAT*      D1 = &Dist			     [3];
		FLOAT*      D2 = &Dist			     [0];
		INT			NumInt = 0;

		for( INT i=0; i<4; i++ )
		{
			if( (*D1)*(*D2) < 0.0 )
			{	
				// At intersection point.
				FLOAT Alpha = *D1 / (*D1 - *D2);
				I->ScreenX  = V1->ScreenX + Alpha * (V2->ScreenX - V1->ScreenX);
				I->ScreenY  = V1->ScreenY + Alpha * (V2->ScreenY - V1->ScreenY);

				I++;
				NumInt++;
			}
			V1 = V2++;
			D1 = D2++;
		}
		if( NumInt < 2 )
			goto NoSplit;

		// Allocate front and back rasters.
		INT	Size	= sizeof (FRasterPoly) + (Raster->EndY - Raster->StartY) * sizeof( FRasterSpan );
		FrontRaster	= (FRasterPoly *)New<BYTE>(GDynMem,Size);
		BackRaster	= (FRasterPoly *)New<BYTE>(GDynMem,Size);

		// Make sure that first intersection point is on top.
		if( Intersect[0].ScreenY > Intersect[1].ScreenY )
			Exchange( Intersect[0], Intersect[1] );
		INT Y0 = Max( appFloor(Intersect[0].ScreenY), Raster->StartY );
		INT Y1 = Min( appFloor(Intersect[1].ScreenY), Raster->EndY   );
		if( Y0>Y1 )
			goto NoSplit;

		// Find TopRaster.
		FRasterPoly* TopRaster = NULL;
		if( Y0 > Raster->StartY )
		{
			if( Dist[0] >= 0 ) TopRaster = FrontRaster;
			else               TopRaster = BackRaster;
		}

		// Find BottomRaster.
		FRasterPoly* BottomRaster = NULL;
		if( Y1 < Raster->EndY )
		{
			if( Dist[2] >= 0 ) BottomRaster = FrontRaster;
			else               BottomRaster = BackRaster;
		}

		// Find LeftRaster and RightRaster.
		FRasterPoly *LeftRaster, *RightRaster;
		if( Intersect[1].ScreenX >= Intersect[0].ScreenX )
		{
			if (Dist[1] >= 0.0) {LeftRaster = BackRaster;  RightRaster = FrontRaster;}
			else	   			{LeftRaster = FrontRaster; RightRaster = BackRaster; };
		}
		else // Intersect[1].ScreenX < Intersect[0].ScreenX
		{
			if (Dist[0] >= 0.0) {LeftRaster = FrontRaster; RightRaster = BackRaster; }
			else                {LeftRaster = BackRaster;  RightRaster = FrontRaster;};
		}

		// Set left and right raster defaults (may be overwritten by TopRaster or BottomRaster).
		checkSlow(Y0>=0);
		checkSlow(Y1<=Frame->Y);
		LeftRaster->StartY = Y0; RightRaster->StartY = Y0;
		LeftRaster->EndY   = Y1; RightRaster->EndY   = Y1;

		// Copy TopRaster section.
		if( TopRaster )
		{
			TopRaster->StartY = Raster->StartY;

			FRasterSpan* SourceLine	= &Raster->Lines    [0];
			FRasterSpan* Line		= &TopRaster->Lines [0];

			for( i=TopRaster->StartY; i<Y0; i++ )
				*Line++ = *SourceLine++;
		}

		// Copy BottomRaster section.
		if( BottomRaster )
		{
			BottomRaster->EndY = Raster->EndY;

			FRasterSpan* SourceLine	= &Raster->Lines       [Y1 - Raster->StartY];
			FRasterSpan* Line       = &BottomRaster->Lines [Y1 - BottomRaster->StartY];

			for( i=Y1; i<BottomRaster->EndY; i++ )
				*Line++ = *SourceLine++;
		}

		// Split middle raster section.
		if( Y1 != Y0 )
		{
			FLOAT	FloatYAdjust	= (FLOAT)Y0 + 1.0 - Intersect[0].ScreenY;
			FLOAT	FloatFixDX 		= 65536.0 * (Intersect[1].ScreenX - Intersect[0].ScreenX) / (Intersect[1].ScreenY - Intersect[0].ScreenY);
			INT		FixDX			= (INT) FloatFixDX;
			INT		FixX			= (INT) (65536.0 * Intersect[0].ScreenX + FloatFixDX * FloatYAdjust);

			if( Raster->StartY > Y0 ) 
			{
				FixX   += (Raster->StartY-Y0) * FixDX;
				Y0		= Raster->StartY;
			}
			if( Raster->EndY < Y1 )
			{
				Y1      = Raster->EndY;
			}
			
			FRasterSpan	*SourceLine = &Raster->Lines      [Y0 - Raster->StartY];
			FRasterSpan	*LeftLine   = &LeftRaster->Lines  [Y0 - LeftRaster->StartY];
			FRasterSpan	*RightLine  = &RightRaster->Lines [Y0 - RightRaster->StartY];

			while( Y0++ < Y1 )
			{
				*LeftLine  = *SourceLine;
				*RightLine = *SourceLine;

				INT X = Unfix(FixX);
				if (X < LeftLine->X[1])    LeftLine->X[1] = X;
				if (X > RightLine->X[0]) RightLine->X[0] = X;

				FixX       += FixDX;
				SourceLine ++;
				LeftLine   ++;
				RightLine  ++;
			}
		}

		// Discard any rasters that are completely empty.
		if( BackRaster->EndY <= BackRaster->StartY )
			BackRaster = NULL;
		if( FrontRaster->EndY <= FrontRaster->StartY )
			FrontRaster = NULL;
	}
	else
	{
		// Don't have to split the rasterization.
		NoSplit:
		FrontRaster = BackRaster = Raster;
	}

	// Filter it down.
	INT CSG = Node.IsCsg();
	if( Front && FrontRaster )
	{
		if( Node.iFront != INDEX_NONE )
			new(GDynMem)FDynamicChunk( Node.iFront, Sprite, FrontRaster );
		else if( Outside || CSG )
			new(GDynMem)FDynamicFinalChunk( iNode, Sprite, FrontRaster, 0 );
	}
	if( Back && BackRaster )
	{
		if( Node.iBack != INDEX_NONE  )
			new(GDynMem)FDynamicChunk( Node.iBack, Sprite, BackRaster );
		else if( Outside && !CSG )
			new(GDynMem)FDynamicFinalChunk( iNode, Sprite, BackRaster, 1 );
	}
	
	STAT(unclock(GStat.FilterTime));		// JEP
}

/*------------------------------------------------------------------------------
	FDynamicFinalChunk implementation.
------------------------------------------------------------------------------*/

FDynamicFinalChunk::FDynamicFinalChunk( INT iNode, FDynamicSprite* InSprite, FRasterPoly* InRaster, INT IsBack )
:	FDynamicItem( iNode )
,	Raster( InRaster )
,	Sprite( InSprite )
{
	// Set Z.
	Z = InSprite->Z;

	// Add into list z-sorted.
	for( FDynamicItem** Item=&GRender->Dynamic( iNode, IsBack ); *Item && (*Item)->Z<Z; Item=&(*Item)->FilterNext );
	FilterNext = *Item;
	*Item      = this;

	STAT(GStat.NumFinalChunks++);
}

void FDynamicFinalChunk::PreRender( UViewport* Viewport, FSceneNode* Frame, FSpanBuffer* SpanBuffer, INT iNode, FVolActorLink* Volumetrics )
{
	UBOOL Drawn=0;
	
	//STAT(clock(GStat.OcclusionTime));		// JEP

	if( !Sprite->SpanBuffer )
	{
		// Creating a new span buffer for this sprite.
		Sprite->SpanBuffer = New<FSpanBuffer>(GDynMem);
		Sprite->SpanBuffer->AllocIndex( Raster->StartY, Raster->EndY, &GDynMem );

		if(Sprite->SpanBuffer->CopyFromRaster( *SpanBuffer, Raster->StartY, Raster->EndY, (FRasterSpan*)Raster->Lines ) )
		{
			// Span buffer is non-empty, so keep it and put it on the to-draw list.
			STAT(GStat.ChunksDrawn++);
			Drawn                = 1;
			Sprite->RenderNext	 = Frame->Sprite;
			Frame->Sprite        = Sprite;

			GStat.MeshCount++;
		}
		else
		{
			// Span buffer is empty, so ditch it.
			Sprite->SpanBuffer->Release();
			Sprite->SpanBuffer = NULL;
		}
	}
	else
	{
	#ifndef FILTER_OPTIMIZATION
		// Merging with the sprite's existing span buffer.
		FMemMark Mark(GMem);
		FSpanBuffer* Span = New<FSpanBuffer>(GMem);
		Span->AllocIndex(Raster->StartY,Raster->EndY,&GMem);
		if(Span->CopyFromRaster( *SpanBuffer, Raster->StartY, Raster->EndY, (FRasterSpan*)Raster->Lines ) )
		{
			// Temporary span buffer is non-empty, so merge it into sprite's.
			Drawn = 1;
			Sprite->SpanBuffer->MergeWith(*Span);
			STAT(GStat.ChunksDrawn++);
		}

		// Release the temporary memory.
		Mark.Pop();
	#endif
	}

	// Add volumetrics to list.
	if( Drawn )
	{
		for( Volumetrics; Volumetrics; Volumetrics=Volumetrics->Next )
		{
			if( Volumetrics->Volumetric )
			{
				for( FActorLink* Link=Sprite->Volumetrics; Link; Link=Link->Next )
					if( Link->Actor==Volumetrics->Actor )
						break;
				if( !Link )
					Sprite->Volumetrics = new(GDynMem)FActorLink(Volumetrics->Actor,Sprite->Volumetrics);
			}
		}
	}

	//STAT(unclock(GStat.OcclusionTime));		// JEP
}

/*-----------------------------------------------------------------------------
	FDynamicLight implementation.
-----------------------------------------------------------------------------*/

FDynamicLight::FDynamicLight( INT iNode, AActor* InActor, UBOOL InIsVol, UBOOL InHitLeaf )
:	FDynamicItem( iNode )
,	Actor( InActor )
,	IsVol( InIsVol )
,	HitLeaf( InHitLeaf )
{
	// Add at start of list.
	FilterNext = GRender->Dynamic( iNode, 0 );
	GRender->Dynamic( iNode, 0 ) = this;

	STAT(GStat.NumMovingLights++);
}

void __fastcall FDynamicLight::Filter( UViewport* Viewport, FSceneNode* Frame, INT iNode, INT Outside )
{
	STAT(clock(GStat.FilterTime));	// JEP

	// Filter down.
	FBspNode& Node = Viewport->Actor->GetLevel()->Model->Nodes(iNode);
	FLOAT Dist   = Node.Plane.PlaneDot( Actor->Location );
	FLOAT Radius = Actor->WorldLightRadius();
	if( Dist > -Radius )
	{
		// Filter down front.
		UBOOL ThisHitLeaf=HitLeaf;
		if( !HitLeaf )
		{
			INT iLeaf=Node.iLeaf[1];
			// JEP: Added: GRender->NumDynLightLeaves < URender::MAX_DYN_LIGHT_LEAVES
			if( iLeaf!=INDEX_NONE && GRender->NumDynLightLeaves < URender::MAX_DYN_LIGHT_LEAVES)
			{
				if( !GRender->LeafLights[iLeaf] )
					GRender->DynLightLeaves[GRender->NumDynLightLeaves++] = iLeaf;
				GRender->LeafLights[iLeaf] = new( GMem )FVolActorLink( Frame->Coords, Actor, GRender->LeafLights[iLeaf], IsVol && Dist>-Actor->WorldVolumetricRadius() );
				ThisHitLeaf=1;
			}
		}
		if( Node.iFront!=INDEX_NONE )
			new(GDynMem)FDynamicLight( Node.iFront, Actor, IsVol && Dist>-Actor->WorldVolumetricRadius(), ThisHitLeaf );

		// Handle planars.
		if( Dist < Radius )
		{
			for( INT iPlane=iNode; iPlane!=INDEX_NONE; iPlane = Viewport->Actor->GetLevel()->Model->Nodes(iPlane).iPlane )
			{
				FBspNode&       Node  = Viewport->Actor->GetLevel()->Model->Nodes(iPlane);
				FBspSurf&       Surf  = Viewport->Actor->GetLevel()->Model->Surfs(Node.iSurf);
				FLightMapIndex* Index = Viewport->Actor->GetLevel()->Model->GetLightMapIndex(Node.iSurf);

				if
				(	(Index)
				&&	(GRender->NumDynLightSurfs < URender::MAX_DYN_LIGHT_SURFS)
				&&	(Actor->bSpecialLit ? (Surf.PolyFlags&PF_SpecialLit) : !(Surf.PolyFlags&PF_SpecialLit)) )
				{
					// Don't apply a light twice.
					for( FActorLink* Link = GRender->SurfLights[Node.iSurf]; Link; Link=Link->Next )
						if( Link->Actor == Actor )
							break;
					if( !Link )
					{
						if( !GRender->SurfLights[Node.iSurf] )
							GRender->DynLightSurfs[GRender->NumDynLightSurfs++] = Node.iSurf;
						
						GRender->SurfLights[Node.iSurf] = new(GMem)FActorLink( Actor, GRender->SurfLights[Node.iSurf] );
					}
				}
			}
		}
	}
	if( Dist < Radius )
	{
		UBOOL ThisHitLeaf=HitLeaf;
		if( !HitLeaf )
		{
			INT iLeaf=Node.iLeaf[0];
			// JEP: Added: GRender->NumDynLightLeaves < URender::MAX_DYN_LIGHT_LEAVES
			if( iLeaf!=INDEX_NONE && GRender->NumDynLightLeaves < URender::MAX_DYN_LIGHT_LEAVES)
			{
				if( !GRender->LeafLights[iLeaf] )
					GRender->DynLightLeaves[GRender->NumDynLightLeaves++] = iLeaf;
				GRender->LeafLights[iLeaf] = new( GMem )FVolActorLink( Frame->Coords, Actor, GRender->LeafLights[iLeaf], IsVol && Dist<Actor->WorldVolumetricRadius() );
				ThisHitLeaf=1;
			}
		}
		if( Node.iBack!=INDEX_NONE )
			new(GDynMem)FDynamicLight( Node.iBack, Actor, IsVol && Dist<Actor->WorldVolumetricRadius(), ThisHitLeaf );
	}
	
	STAT(unclock(GStat.FilterTime));	// JEP
}

/*-----------------------------------------------------------------------------
	Actor drawing.
-----------------------------------------------------------------------------*/

//
// Draw an actor defined by a FDynamicSprite.
//
void __fastcall URender::DrawActorSprite( FSceneNode* Frame, FDynamicSprite* Sprite )
{
	PUSH_HIT(Frame,HActor(Sprite->Actor));
	DWORD PolyFlags  =0,
		  PolyFlagsEx=0;
	Sprite->Actor->STY2PolyFlags(Frame,PolyFlags,PolyFlagsEx);

	//GetPolyFlags(Frame,Sprite->Actor);

	UBOOL AlreadyHandled=FALSE;
	if(Sprite->Actor->IsA(ABeamSystem::StaticClass())&&((!GIsEditor)||((((ABeamSystem *)Sprite->Actor)->SimulateInEditor))))
	{
		Frame->Viewport->RenDev->dnDrawBeam(*(ABeamSystem *)Sprite->Actor,Frame);
		AlreadyHandled=!GIsEditor;	
	}
	else if(!GIsEditor&&Sprite->Actor->IsA(ASoftParticleSystem::StaticClass())&&!((ASoftParticleSystem *)Sprite->Actor)->ParticleRecursing)
	{
		((ASoftParticleSystem *)Sprite->Actor)->DrawParticles((void *)Frame);
		AlreadyHandled=!GIsEditor;
	}
	//else if(!GIsEditor && Sprite->Actor->IsA(ABreakableGlass::StaticClass()))
	else if(Sprite->Actor->IsA(ABreakableGlass::StaticClass()))// && !Frame->Viewport->IsOrtho())
	{
		((ABreakableGlass*)Sprite->Actor)->DrawGlass((void*)Frame);
		AlreadyHandled=TRUE;
	}

	if(AlreadyHandled) ;
	// Draw the actor.
	else if
	(	(Sprite->Actor->DrawType==DT_Sprite || Sprite->Actor->DrawType==DT_SpriteAnimOnce || (Frame->Viewport->Actor->ShowFlags & SHOW_ActorIcons)) 
	&&	(Sprite->Actor->Texture) )
	{
		// Sprite.
		FPlane    Color     = (GIsEditor && Sprite->Actor->bSelected) ? FPlane(.5f,.9f,.5f,0) : FPlane(1,1,1,0);
		UTexture* Texture   = Sprite->Actor->Texture;
		FLOAT     DrawScale = Sprite->Actor->DrawScale;
		UTexture* SavedNext = NULL;
		UTexture* SavedCur  = NULL;
		if( Sprite->Actor->ScaleGlow!=1.f )
		{
			Color *= Sprite->Actor->ScaleGlow;
			if( Color.X>1.f ) Color.X=1.f;
			if( Color.Y>1.f ) Color.Y=1.f;
			if( Color.Z>1.f ) Color.Z=1.f;
		}
		if( Sprite->Actor->DrawType==DT_SpriteAnimOnce )
		{
			INT Count=1;
			for( UTexture* Test=Texture->AnimNext; Test && Test!=Texture; Test=Test->AnimNext )
				Count++;
			INT Num = Clamp( appFloor(Sprite->Actor->LifeFraction()*Count), 0, Count-1 );
			while( Num-- > 0 )
				Texture = Texture->AnimNext;
			SavedNext         = Texture->AnimNext; //sort of a hack!!
			SavedCur          = Texture->AnimCur;
			Texture->AnimNext = NULL;
			Texture->AnimCur  = NULL;
		}
		if( Frame->Viewport->Actor->ShowFlags & SHOW_ActorIcons )
		{
			DrawScale = 1.f;
			if( !Texture )
				Texture = GetDefault<AActor>()->Texture;
		}
		FLOAT XScale = Sprite->Persp * DrawScale * Texture->USize;
		FLOAT YScale = Sprite->Persp * DrawScale * Texture->VSize;
		if( Texture ) Frame->Viewport->Canvas->DrawIcon
		(
			Texture->Get( Frame->Viewport->CurrentTime ),
			Sprite->ScreenX - XScale/2,
			Sprite->ScreenY - YScale/2,
			XScale,
			YScale,
			Sprite->SpanBuffer,
			Sprite->Z,
			Color,
			FPlane(0,0,0,0),
			PolyFlags | PF_TwoSided | Texture->PolyFlags,
			0,
			Sprite->Actor->Bilinear,
			Sprite->Actor->Alpha,
			Sprite->Actor->BillboardRotation
		);

		if( Sprite->Actor->DrawType==DT_SpriteAnimOnce )
		{
			Texture->AnimNext = SavedNext;
			Texture->AnimCur  = SavedCur;
		}
	}
	else if(
		Sprite->Actor->DrawType==DT_Mesh
	&&	Sprite->Actor->Mesh )
	{
		// Mesh.
		if( Frame->Viewport->Actor->RendMap==REN_Polys 
		 || Frame->Viewport->Actor->RendMap==REN_PolyCuts 
		 || Frame->Viewport->Actor->RendMap==REN_Zones 
		 || Frame->Viewport->Actor->RendMap==REN_Wire )
			PolyFlags |= PF_FlatShaded;

		clock(GStat.MeshTime);
		DrawMesh
		(
			Frame,
			Sprite->Actor,
			Sprite->Actor,
			Sprite->SpanBuffer,
			Sprite->Actor->Region.Zone,
			Frame->Coords,
			Sprite->LeafLights,
			Sprite->Volumetrics,
			PolyFlags,
			PolyFlagsEx
		);

		unclock(GStat.MeshTime);

		// Draw shadow.
		if (Sprite->Actor->IsA(APawn::StaticClass()))
		{
			if ( ((APawn*)Sprite->Actor)->Shadow )
				((APawn*)Sprite->Actor)->Shadow->eventUpdate(NULL);
		}
	}

	// Done.
	POP_HIT(Frame);
}

/*-----------------------------------------------------------------------------
	Wireframe view drawing.
-----------------------------------------------------------------------------*/

//
// Just draw an actor, no span occlusion.
//

void __fastcall URender::DrawActor( FSceneNode* Frame, AActor* Actor)
{
	FDynamicSprite Sprite(Actor);
	
	if( Sprite.Setup( Frame ) )
		DrawActorSprite( Frame, &Sprite );
}

/*------------------------------------------------------------------------------
	The End.
------------------------------------------------------------------------------*/
