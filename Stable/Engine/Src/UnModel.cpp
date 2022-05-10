/*=============================================================================
	UnModel.cpp: Unreal model functions
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

#include "EnginePrivate.h"

/*-----------------------------------------------------------------------------
	Struct serializers.
-----------------------------------------------------------------------------*/

ENGINE_API FArchive& operator<<( FArchive& Ar, FBspSurf& Surf )
{
	INT ExtVersion=0;
	// DNF... use extended surface automatically when saving
	if (Ar.IsSaving())
	{
		ExtVersion = 1;
		Surf.PolyFlags |= PF_ExtendedSurface;
		//ExtVersion=0;
		//Surf.PolyFlags&=~PF_ExtendedSurface;
	}
	// ...DNF
	
	Ar << Surf.Texture;

	Ar << Surf.PolyFlags << AR_INDEX(Surf.pBase) << AR_INDEX(Surf.vNormal);
	Ar << AR_INDEX(Surf.vTextureU) << AR_INDEX(Surf.vTextureV);
	Ar << AR_INDEX(Surf.iLightMap) << AR_INDEX(Surf.iBrushPoly);
	Ar << Surf.PanU << Surf.PanV;
	Ar << Surf.Actor;
	if( Ar.IsLoading() )
		Surf.PolyFlags &= ~PF_Transient;
#ifndef NODECALS
	if( !Ar.IsLoading() && !Ar.IsSaving() )
		Ar << Surf.Decals;
#endif

	// DNF...
	
	// Set extended surface defaults incase we're not loading them
	if (Ar.IsLoading()) 
	{
		ExtVersion = 0;
		Surf.SurfaceTag = NAME_None;
		Surf.PolyFlags2 = 0;
	}

	// If we're using extensions, load/save version
	if ((Ar.Ver() >= 68) && (Surf.PolyFlags & PF_ExtendedSurface))
	{
		Surf.PolyFlags&=~PF_ExtendedSurface;
		Ar << ExtVersion;
	}
	
	// Load/save based on version
	if (ExtVersion > 0)
	{
		Ar << Surf.SurfaceTag;
		Ar << Surf.PolyFlags2;
	}

	// ...DNF

	return Ar;
}

ENGINE_API FArchive& operator<<( FArchive& Ar, FPoly& Poly )
{

    INT ExtVersion=0;
	// DNF... use extended surface automatically when saving
	if (Ar.IsSaving())
	{
		ExtVersion = 1;
		Poly.PolyFlags |= PF_ExtendedPoly;
	}
	// ...DNF

	Ar << AR_INDEX(Poly.NumVertices);
	Ar << Poly.Base << Poly.Normal << Poly.TextureU << Poly.TextureV;
	for( INT i=0; i<Poly.NumVertices; i++ )
		Ar << Poly.Vertex[i];
	Ar << Poly.PolyFlags;
	Ar << Poly.Actor << Poly.Texture << Poly.ItemName;
	Ar << AR_INDEX(Poly.iLink) << AR_INDEX(Poly.iBrushPoly) << Poly.PanU << Poly.PanV;
	if( Ar.IsLoading() )
		Poly.PolyFlags &= ~PF_Transient;

	// DNF...
	
	// Set extended surface defaults incase we're not loading them
	if (Ar.IsLoading())
	{
        ExtVersion=0;
		
		Poly.SurfaceTag = NAME_None;
		Poly.PolyFlags2 = 0;
	}

	// If we're using extensions, load/save version
	if ((Ar.Ver() >= 68) && (Poly.PolyFlags & PF_ExtendedPoly))
	{
		Ar << ExtVersion;
		Poly.PolyFlags&=~PF_ExtendedPoly;
	}
	
	// Load/save based on version
	if (ExtVersion > 0)
	{
		Ar << Poly.SurfaceTag;
		Ar << Poly.PolyFlags2;
	}

	// ...DNF

	return Ar;
}

ENGINE_API FArchive& operator<<( FArchive& Ar, FBspNode& N )
{
	Ar << N.Plane << N.ZoneMask << N.NodeFlags << AR_INDEX(N.iVertPool) << AR_INDEX(N.iSurf);
	Ar << AR_INDEX(N.iChild[0]) << AR_INDEX(N.iChild[1]) << AR_INDEX(N.iChild[2]);
	Ar << AR_INDEX(N.iCollisionBound) << AR_INDEX(N.iRenderBound);

	Ar << N.iZone[0] << N.iZone[1];
	Ar << N.NumVertices;
	Ar << N.iLeaf[0] << N.iLeaf[1];
	if( Ar.IsLoading() )
		N.NodeFlags &= ~(NF_IsNew|NF_IsFront|NF_IsBack);
	return Ar;
}

/*---------------------------------------------------------------------------------------
	Old database implementations.
---------------------------------------------------------------------------------------*/

class ENGINE_API UBspNodes : public UObject
{
	DECLARE_CLASS(UBspNodes,UObject,CLASS_RuntimeStatic)
	TTransArray<FBspNode> Element;
	INT _NumZones;
	FZoneProperties	_Zones[FBspNode::MAX_ZONES];
	UBspNodes()
	: Element( this )
	{
		_NumZones = 0;
		for( INT i=0; i<FBspNode::MAX_ZONES; i++ )
		{
			_Zones[i].ZoneActor    = NULL;
			_Zones[i].Connectivity = ((QWORD)1)<<i;
			_Zones[i].Visibility   = ~(QWORD)0;
		}	
	}
	void Serialize( FArchive& Ar )
	{
		Super::Serialize(Ar);
		if( Ar.IsLoading() )
		{
			INT DbNum=Element.Num(), DbMax=DbNum;
			Ar << DbNum << DbMax;
			Element.Empty( DbNum );
			Element.AddZeroed( DbNum );
			for( INT i=0; i<Element.Num(); i++ )
				Ar << Element(i);
			Ar << AR_INDEX(_NumZones);
			for( i=0; i<_NumZones; i++ )
				Ar << _Zones[i];
		}
	}
};
IMPLEMENT_CLASS(UBspNodes);

class ENGINE_API UBspSurfs : public UObject
{
	DECLARE_CLASS(UBspSurfs,UObject,CLASS_RuntimeStatic)
	TArray<FBspSurf> Element;
	void Serialize( FArchive& Ar )
	{
		Super::Serialize( Ar );
		if( Ar.IsLoading() )
		{
			INT DbNum=0, DbMax=0;
			Ar << DbNum << DbMax;
			Element.Empty( DbNum );
			Element.AddZeroed( DbNum );
			for( INT i=0; i<Element.Num(); i++ )
				Ar << Element(i);
		}
	}
};
IMPLEMENT_CLASS(UBspSurfs);

class ENGINE_API UVectors : public UObject
{
	DECLARE_CLASS(UVectors,UObject,CLASS_RuntimeStatic)
	TArray<FVector> Element;
	void Serialize( FArchive& Ar )
	{
		Super::Serialize( Ar );
		if( Ar.IsLoading() )
		{
			INT DbNum=Element.Num(), DbMax=DbNum;
			Ar << DbNum << DbMax;
			Element.Empty( DbNum );
			Element.Add( DbNum );
			for( INT i=0; i<Element.Num(); i++ )
				Ar << Element(i);
		}
	}
};
IMPLEMENT_CLASS(UVectors);

class ENGINE_API UVerts : public UObject
{
	DECLARE_CLASS(UVerts,UObject,CLASS_RuntimeStatic)
	TArray<FVert> Element;
	INT NumSharedSides;
	void Serialize( FArchive& Ar )
	{
		Super::Serialize( Ar );
		if( Ar.IsLoading() )
		{
			Element.CountBytes( Ar );
			INT DbNum=Element.Num(), DbMax=DbNum;
			Ar << DbNum << DbMax;
			Element.Empty( DbNum );
			Element.Add( DbNum );
			for( INT i=0; i<Element.Num(); i++ )
				Ar << Element(i);
		}
		Ar << AR_INDEX(NumSharedSides);
	}
};
IMPLEMENT_CLASS(UVerts);

/*---------------------------------------------------------------------------------------
	UModel object implementation.
---------------------------------------------------------------------------------------*/

void UModel::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );

#if 0	// JEP (Test code.  We no longer use this hack.  Models are now imported in the linker)
	if (Ar.IsSaving())
	{
		Ar << Filename << FilePos;

		Ar << Surfs;
		
		Ar << NumSharedSides;
		Ar << NumZones;

		for( INT i=0; i<NumZones; i++ )
			Ar << Zones[i];

		Ar << Polys;

		if( Polys && !Ar.IsTrans() )
			Ar.Preload( Polys );

		Ar << Lights;
		Ar << RootOutside;
		Ar << Linked;
		return;
	}

	if (Ar.IsLoading() && GSaveLoadHack)
	{
		FArchive	*pAr2 = NULL;

		Ar << Filename << FilePos;

		Ar << Surfs;
		
		Ar << NumSharedSides;
		Ar << NumZones;

		for( INT i=0; i<NumZones; i++ )
			Ar << Zones[i];

		
		Ar << Polys;

		if( Polys && !Ar.IsTrans() )
			Ar.Preload( Polys );
		
		//Polys = new( GetOuter(), NAME_None, RF_Transactional )UPolys;

		Ar << Lights;
		Ar << RootOutside;
		Ar << Linked;

		// Load stuff that doesn't change from the original package
		//pAr2 = GFileManager->CreateFileReader(*Filename);
		UObject::GObjBeginLoadCount++;
		pAr2 = GetPackageLinker(CreatePackage(NULL, *Filename), NULL, LOAD_Throw, NULL, NULL);
		UObject::GObjBeginLoadCount--;

		if (pAr2)
		{
			// Seek to the pos
			pAr2->Seek(FilePos(0));
			
			*pAr2 << Vectors;
			*pAr2 << Points;
			*pAr2 << Nodes;
			
			// Seek to the pos
			pAr2->Seek(FilePos(1));

			*pAr2 << Verts;

			// Seek to the pos
			pAr2->Seek(FilePos(2));

			*pAr2 << LightMap << LightBits << Bounds << LeafHulls << Leaves;

			//delete pAr2;
		}

		return;
	}

	if (Ar.IsLoading())
	{
		//Filename = this->GetLinker()->Filename;
		Filename = GetOuter()->GetName();

		const ANSICHAR *Str = appToAnsi(*Filename);
		// Remember current pos so we can manually seek here for loading saved games
		FilePos.AddItem(this->GetLinker()->Loader->Tell());
	}

	Ar << Vectors;
	Ar << Points;
	Ar << Nodes;
	Ar << Surfs;
	if (Ar.IsLoading())
		FilePos.AddItem(this->GetLinker()->Loader->Tell());
	Ar << Verts;
	Ar << NumSharedSides;
	Ar << NumZones;

	for( INT i=0; i<NumZones; i++ )
		Ar << Zones[i];

	Ar << Polys;

	if( Polys && !Ar.IsTrans() )
		Ar.Preload( Polys );

	if (Ar.IsLoading())
		FilePos.AddItem(this->GetLinker()->Loader->Tell());

	Ar << LightMap;
	Ar << LightBits ;
	Ar << Bounds ;
	Ar << LeafHulls ;
	Ar << Leaves ;
	Ar << Lights;
	Ar << RootOutside << Linked;
#else
		//oldver
	UBspSurfs* _Surfs   = NULL;
	UVectors*  _Vectors = NULL;
	UVectors*  _Points  = NULL;
	UVerts*    _Verts   = NULL;
	UBspNodes* _Nodes   = NULL;
	if( Ar.Ver()<=61 )
	{
		Ar << _Vectors << _Points << _Nodes << _Surfs << _Verts;
	}
	else
	{
		Ar << Vectors << Points << Nodes << Surfs << Verts << NumSharedSides << NumZones;
		for( INT i=0; i<NumZones; i++ )
			Ar << Zones[i];
	}
	
	Ar << Polys;
	
	if( _Vectors )
	{
		Ar.Preload( _Vectors );
		ExchangeArray( _Vectors->Element, Vectors );
	}
	if( _Points )
	{
		Ar.Preload( _Points );
		ExchangeArray( _Points->Element, Points );
	}
	if( _Surfs )
	{
		Ar.Preload( _Surfs );
		ExchangeArray( _Surfs->Element, Surfs );
	}
	if( _Verts )
	{
		Ar.Preload( _Verts );
		ExchangeArray( _Verts->Element, Verts );
		NumSharedSides = _Verts->NumSharedSides;
	}
	if( _Nodes )
	{
		Ar.Preload( _Nodes );
		ExchangeArray( _Nodes->Element, Nodes );
		NumZones = _Nodes->_NumZones;
		for( INT i=0; i<NumZones; i++ )
			Zones[i] = _Nodes->_Zones[i];
	}
	if( Polys && !Ar.IsTrans() )
	{
		Ar.Preload( Polys );
	}

	Ar << LightMap << LightBits << Bounds << LeafHulls << Leaves << Lights;
	if( Ar.Ver()<=61 )//oldver
	{
		UObject* Tmp=NULL;
		Ar << Tmp << Tmp;
	}
	Ar << RootOutside << Linked;
#endif
}
void UModel::PostLoad()
{
	for( INT i=0; i<Nodes.Num(); i++ )
		Surfs(Nodes(i).iSurf).Nodes.AddItem(i);
	Super::PostLoad();
}
void UModel::ModifySurf( INT Index, INT UpdateMaster )
{
	Surfs.ModifyItem( Index );
	FBspSurf& Surf = Surfs(Index);
	if( UpdateMaster && Surf.Actor )
		Surf.Actor->Brush->Polys->Element.ModifyItem( Surf.iBrushPoly );
}
void UModel::ModifyAllSurfs( INT UpdateMaster )
{
	for( INT i=0; i<Surfs.Num(); i++ )
		ModifySurf( i, UpdateMaster );
}
void UModel::ModifySelectedSurfs( INT UpdateMaster )
{
	for( INT i=0; i<Surfs.Num(); i++ )
		if( Surfs(i).PolyFlags & PF_Selected )
			ModifySurf( i, UpdateMaster );
}
IMPLEMENT_CLASS(UModel);

/*---------------------------------------------------------------------------------------
	UModel implementation.
---------------------------------------------------------------------------------------*/

//
// Lock a model.
//
void UModel::Modify( UBOOL DoTransArrays )
{
	// Modify all child objects.
	//warning: Don't modify self because model contains a dynamic array.
	if( Polys   ) Polys->Modify();

}

//
// Empty the contents of a model.
//
void UModel::EmptyModel( INT EmptySurfInfo, INT EmptyPolys )
{
	// Init arrays.
	Nodes		.Empty();
	Bounds		.Empty();
	LeafHulls	.Empty();
	Leaves		.Empty();
	Lights		.Empty();
	LightMap	.Empty();
	LightBits	.Empty();
	Verts		.Empty();
	if( EmptySurfInfo )
	{
		Vectors.Empty();
		Points.Empty();
		for( INT i=0; i<Surfs.Num(); i++ )
			Surfs(i).Decals.Empty();
		Surfs.Empty();
	}
	if( EmptyPolys )
	{
		Polys = new( GetOuter(), NAME_None, RF_Transactional )UPolys;
	}

	// Init variables.
	NumZones		= 0;
	NumSharedSides	= 4;
	NumZones = 0;
	for( INT i=0; i<FBspNode::MAX_ZONES; i++ )
	{
		Zones[i].ZoneActor    = NULL;
		Zones[i].Connectivity = ((QWORD)1)<<i;
		Zones[i].Visibility   = ~(QWORD)0;
	}	
}


//
// Create a new model and allocate all objects needed for it.
//
UModel::UModel( ABrush* Owner, UBOOL InRootOutside )
:	RootOutside	( InRootOutside )
,	Surfs		( this )
,	Vectors		( this )
,	Points		( this )
,	Verts		( this )
,	Nodes		( this )
{
	SetFlags( RF_Transactional );
	EmptyModel( 1, 1 );
	if( Owner )
	{
		Owner->Brush = this;
		Owner->InitPosRotScale();
	}
}

//
// Build the model's bounds (min and max).
//
void UModel::BuildBound()
{
	if( Polys && Polys->Element.Num() )
	{
		TArray<FVector> Points;
		for( INT i=0; i<Polys->Element.Num(); i++ )
			for( INT j=0; j<Polys->Element(i).NumVertices; j++ )
				Points.AddItem(Polys->Element(i).Vertex[j]);
		BoundingBox    = FBox( &Points(0), Points.Num() );
		BoundingSphere = FSphere( &Points(0), Points.Num() );
	}
	else BoundingBox = FBox(0);
}

//
// Transform this model by its coordinate system.
//
void UModel::Transform( ABrush* Owner )
{
	check(Owner);

	Polys->Element.ModifyAllItems();

	FModelCoords Coords;
	FLOAT Orientation = Owner->BuildCoords( &Coords, NULL );
	for( INT i=0; i<Polys->Element.Num(); i++ )
		Polys->Element( i ).Transform( Coords, Owner->PrePivot, Owner->Location, Orientation );

}

//
// Returns whether a BSP leaf is potentially visible from another leaf.
//
UBOOL UModel::PotentiallyVisible( INT iLeaf1, INT iLeaf2 )
{
	// This is the amazing superfast patent-pending 1 cpu cycle potential visibility 
	// algorithm programmed by the great Tim Sweeney!
	return 1;
}

/*---------------------------------------------------------------------------------------
	UModel basic implementation.
---------------------------------------------------------------------------------------*/

//
// Shrink all stuff to its minimum size.
//
void UModel::ShrinkModel()
{

	Vectors		.Shrink();
	Points		.Shrink();
	Verts		.Shrink();
	Nodes		.Shrink();
	Surfs		.Shrink();
	if( Polys     ) Polys    ->Element.Shrink();
	Bounds		.Shrink();
	LeafHulls	.Shrink();

}

/*---------------------------------------------------------------------------------------
	The End.
---------------------------------------------------------------------------------------*/
