/*=============================================================================
	UnEdCsg.cpp: High-level CSG tracking functions for editor
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

#include "EditorPrivate.h"
#include <math.h>

//
// Globals:
//!!wastes 128K, fixed size
//
BYTE GFlags1 [MAXWORD+1]; // For fast polygon selection
BYTE GFlags2 [MAXWORD+1];

/*-----------------------------------------------------------------------------
	Level brush tracking.
-----------------------------------------------------------------------------*/

//
// Prepare a moving brush.
//
void UEditorEngine::csgPrepMovingBrush( ABrush* Actor )
{
	check(Actor);
	check(Actor->Brush);
	check(Actor->Brush->RootOutside);
	debugf( NAME_Log, TEXT("Preparing brush %s"), Actor->GetName() );

	// Allocate tables
	Actor->Brush->EmptyModel( 1, 0 );

	// Build bounding box.
	Actor->Brush->BuildBound();

	// Build BSP for the brush.
	bspBuild( Actor->Brush, BSP_Good, 15, 1, 0 );
	bspRefresh( Actor->Brush, 1 );
	bspBuildBounds( Actor->Brush );
}

//
// Duplicate the specified brush and make it into a CSG-able level brush.
// Returns new brush, or NULL if the original was empty.
//
void UEditorEngine::csgCopyBrush
(
	ABrush*		Dest,
	ABrush*		Src,
	DWORD		PolyFlags, 
	DWORD		ResFlags,
	UBOOL		IsMovingBrush
)
{
	check(Src);
	check(Src->Brush);

	// Handle empty brush.
	if( !Src->Brush->Polys->Element.Num() )
	{
		Dest->Brush = NULL;
		return;
	}

	// Duplicate the brush and its polys.
	Dest->PolyFlags				= PolyFlags;
	Dest->Brush					= new( Src->Brush->GetOuter(), NAME_None, ResFlags )UModel( NULL, Src->Brush->RootOutside );
	Dest->Brush->Polys			= new( Src->Brush->GetOuter(), NAME_None, ResFlags )UPolys;
	check(Dest->Brush->Polys->Element.GetOwner()==Dest->Brush->Polys);
	Dest->Brush->Polys->Element = Src->Brush->Polys->Element;
	check(Dest->Brush->Polys->Element.GetOwner()==Dest->Brush->Polys);

	// Update poly textures.
	for( INT i=0; i<Dest->Brush->Polys->Element.Num(); i++ )
		Dest->Brush->Polys->Element(i).iBrushPoly = INDEX_NONE;

	// Copy positioning, and build bounding box.
	Dest->CopyPosRotScaleFrom( Src );

	// If it's a moving brush, prep it.
	if( IsMovingBrush )
		csgPrepMovingBrush( Dest );
}

//
// Add a brush to the list of CSG brushes in the level, using a CSG operation, and return 
// a newly-created copy of it.
//
ABrush* UEditorEngine::csgAddOperation
(
	ABrush*		Actor,
	ULevel*		Level,
	DWORD		PolyFlags,
	ECsgOper	CsgOper
)
{
	check(Actor);
	check(Actor->Brush);
	check(Actor->Brush->Polys);

	// Can't do this if brush has no polys.
	if( !Actor->Brush->Polys->Element.Num() )
		return NULL;

	// Spawn a new actor for the brush.
	ABrush* Result  = Level->SpawnBrush();
	Result->SetFlags( RF_NotForClient | RF_NotForServer );

	// Duplicate the brush.
	csgCopyBrush
	(
		Result,
		Actor,
		PolyFlags,
		RF_NotForClient | RF_NotForServer | RF_Transactional,
		0
	);
	check(Result->Brush);

	// Set add-info.
	Result->CsgOper = CsgOper;

	return Result;
}

const TCHAR* UEditorEngine::csgGetName( ECsgOper CSG )
{
	return *(FindObjectChecked<UEnum>( ANY_PACKAGE, TEXT("ECsgOper") ) )->Names(CSG);
}

/*-----------------------------------------------------------------------------
	CSG Rebuilding.
-----------------------------------------------------------------------------*/

//
// Rebuild the level's Bsp from the level's CSG brushes
//
// Note: Needs to be expanded to defragment Bsp polygons as needed (by rebuilding
// the Bsp), so that it doesn't slow down to a crawl on complex levels.
//

//
// Repartition the bsp.
//
void UEditorEngine::bspRepartition( UModel* Model, INT iNode, INT Simple )
{
	bspBuildFPolys( Level->Model, 1, iNode );
	bspMergeCoplanars( Level->Model, 0, 0 );
	bspBuild( Level->Model, BSP_Good, 12, Simple, iNode );
	bspRefresh( Level->Model, 1 );
}

//
// Build list of leaves.
//
static void EnlistLeaves( UModel* Model, TArray<INT>& iFronts, TArray<INT>& iBacks, INT iNode )
{
	FBspNode& Node=Model->Nodes(iNode);

	if( Node.iFront==INDEX_NONE ) iFronts.AddItem(iNode);
	else EnlistLeaves( Model, iFronts, iBacks, Node.iFront );

	if( Node.iBack==INDEX_NONE ) iBacks.AddItem(iNode);
	else EnlistLeaves( Model, iFronts, iBacks, Node.iBack );
}

//
// Rebuild the level's Bsp from the level's CSG brushes.
//
void UEditorEngine::csgRebuild( ULevel* Level, UBOOL bVisibleOnly )
{
	GWarn->BeginSlowTask( TEXT("Rebuilding geometry"), 1, 0 );
	FastRebuild = 1;

	FinishAllSnaps(Level);

	// Empty the model out.
	Level->Model->EmptyModel( 1, 1 );

	// Count brushes.
	INT BrushTotal=0, BrushCount=0;
	for( FStaticBrushIterator TempIt(Level); TempIt; ++TempIt )
		if( !bVisibleOnly || ( bVisibleOnly && !TempIt->bHiddenEd ) )
			if( *TempIt != Level->Brush() )
				BrushTotal++;

	// Compose all structural brushes and portals.
	for( FStaticBrushIterator It(Level); It; ++It )
	{
		if( !bVisibleOnly || ( bVisibleOnly && !It->bHiddenEd ) )
			if( *It!=Level->Brush() )
			{
				if
				(  !(It->PolyFlags&PF_Semisolid)
				||	(It->CsgOper!=CSG_Add)
				||	(It->PolyFlags&PF_Portal) )
				{
					// Treat portals as solids for cutting.
					if( It->PolyFlags & PF_Portal )
						It->PolyFlags = (It->PolyFlags & ~PF_Semisolid) | PF_NotSolid;
					BrushCount++;
					GWarn->StatusUpdatef( BrushCount, BrushTotal, TEXT("Applying structural brush %i of %i"), BrushCount, BrushTotal );
					bspBrushCSG( *It, Level->Model, It->PolyFlags, (ECsgOper)It->CsgOper, 0 );
				}
			}
	}

	// Repartition the structural BSP.
	bspRepartition( Level->Model, 0, 0 );
	TestVisibility( Level, Level->Model, 0, 0 );

	// Remember leaves.
	TArray<INT> iFronts, iBacks;
	if( Level->Model->Nodes.Num() )
		EnlistLeaves( Level->Model, iFronts, iBacks, 0 );

	// Compose all detail brushes.
	for( It=FStaticBrushIterator(Level); It; ++It )
	{
		if( !bVisibleOnly || ( bVisibleOnly && !It->bHiddenEd ) )
			if
			(	*It!=Level->Brush()
			&&	(It->PolyFlags&PF_Semisolid)
			&& !(It->PolyFlags&PF_Portal)
			&&	It->CsgOper==CSG_Add )
			{
				BrushCount++;
				GWarn->StatusUpdatef( BrushCount, BrushTotal, TEXT("Applying detail brush %i of %i"), BrushCount, BrushTotal );
				bspBrushCSG( *It, Level->Model, It->PolyFlags, (ECsgOper)It->CsgOper, 0 );
			}
	}

	// Optimize the sub-bsp's.
	INT iNode;
	for( TArray<INT>::TIterator ItF(iFronts); ItF; ++ItF )
		if( (iNode=Level->Model->Nodes(*ItF).iFront)!=INDEX_NONE )
			bspRepartition( Level->Model, iNode, 2 );
	for( TArray<INT>::TIterator ItB(iBacks); ItB; ++ItB )
		if( (iNode=Level->Model->Nodes(*ItB).iBack)!=INDEX_NONE )
			bspRepartition( Level->Model, iNode, 2 );

	// Build bounding volumes.
	bspOptGeom( Level->Model );
	bspBuildBounds( Level->Model );

	// Done.
	FastRebuild = 0;
	GWarn->EndSlowTask();
}

/*---------------------------------------------------------------------------------------
	Flag setting and searching
---------------------------------------------------------------------------------------*/

//
// Sets and clears all Bsp node flags.  Affects all nodes, even ones that don't
// really exist.
//
void UEditorEngine::polySetAndClearPolyFlags(UModel *Model, DWORD SetBits, DWORD ClearBits,int SelectedOnly, int UpdateMaster)
{
	for( INT i=0; i<Model->Surfs.Num(); i++ )
	{
		FBspSurf& Poly = Model->Surfs(i);
		if( !SelectedOnly || (Poly.PolyFlags & PF_Selected) )
		{
			DWORD NewFlags = (Poly.PolyFlags & ~ClearBits) | SetBits;
			if( NewFlags != Poly.PolyFlags )
			{
				Model->ModifySurf( i, UpdateMaster );
				Poly.PolyFlags = NewFlags;
				if( UpdateMaster )
					polyUpdateMaster( Model, i, 0, 0 );
			}
		}
	}
} 

// NJS Set the tags of selected surfaces:
void UEditorEngine::polySetSurfaceTags( UModel* Model, FName NewTag, INT SelectedOnly, INT UpdateMaster )
{
	for( INT i=0; i<Model->Surfs.Num(); i++ )
	{
		FBspSurf& Poly = Model->Surfs(i);
		if( !SelectedOnly || (Poly.PolyFlags & PF_Selected) )
		{
			//DWORD NewFlags = (Poly.PolyFlags & ~ClearBits) | SetBits;
			//if( NewFlags != Poly.PolyFlags )
			//{
				Model->ModifySurf( i, UpdateMaster );
				Poly.SurfaceTag=NewTag;
				if( UpdateMaster )
					polyUpdateMaster( Model, i, 0, 0 );
			//}
		}
	}
}

/*-----------------------------------------------------------------------------
	Polygon searching
-----------------------------------------------------------------------------*/

//
// Find the Brush EdPoly corresponding to a given Bsp surface.
//
int UEditorEngine::polyFindMaster(UModel *Model, INT iSurf, FPoly &Poly)
{
	FBspSurf &Surf = Model->Surfs(iSurf);
	if( !Surf.Actor )
	{
		return 0;
	}
	else
	{
		Poly = Surf.Actor->Brush->Polys->Element(Surf.iBrushPoly);
		return 1;
	}
}

//
// Update a the master brush EdPoly corresponding to a newly-changed
// poly to reflect its new properties.
//
// Doesn't do any transaction tracking.  Assumes you've called transSelectedBspSurfs.
//
void UEditorEngine::polyUpdateMaster
(
	UModel*	Model,
	INT  	iSurf,
	INT		UpdateTexCoords,
	INT		UpdateBase
)
{
	FBspSurf &Surf = Model->Surfs(iSurf);
	if( !Surf.Actor )
		return;

	FModelCoords Uncoords;
	if( UpdateTexCoords || UpdateBase )
		Surf.Actor->BuildCoords( NULL, &Uncoords );

	for( INT iEdPoly = Surf.iBrushPoly; iEdPoly < Surf.Actor->Brush->Polys->Element.Num(); iEdPoly++ )
	{
		FPoly& MasterEdPoly = Surf.Actor->Brush->Polys->Element(iEdPoly);
		if( iEdPoly==Surf.iBrushPoly || MasterEdPoly.iLink==Surf.iBrushPoly )
		{
			Surf.Actor->Brush->Polys->Element.ModifyItem( iEdPoly );

			MasterEdPoly.Texture   = Surf.Texture;
			MasterEdPoly.PanU      = Surf.PanU;
			MasterEdPoly.PanV      = Surf.PanV;
			MasterEdPoly.PolyFlags = Surf.PolyFlags & ~(PF_NoEdit);
			
			// DNF Extensions:
			MasterEdPoly.SurfaceTag= Surf.SurfaceTag;
			MasterEdPoly.PolyFlags2= Surf.PolyFlags2;
	
			if( UpdateTexCoords || UpdateBase )
			{
				if( UpdateTexCoords )
				{
					MasterEdPoly.TextureU = Model->Vectors(Surf.vTextureU).TransformVectorBy(Uncoords.VectorXform);
					MasterEdPoly.TextureV = Model->Vectors(Surf.vTextureV).TransformVectorBy(Uncoords.VectorXform);
				}
				/*
				if( UpdateBase )
				{
					MasterEdPoly.Base
					=	(Model->Points(Surf.pBase) - Surf.Actor->Location)
					.	TransformVectorBy(Uncoords.PointXform)
					+	Surf.Actor->PrePivot;
				}
				*/
				if( UpdateBase )
				{
					//MasterEdPoly.Base = Model->Points(Surf.pBase).TransformPointBy(Uncoords.PointXform);
				}
			}
		}
	}
}

//
// Find all Bsp polys with flags such that SetBits are clear or ClearBits are set.
//
void UEditorEngine::polyFindByFlags(UModel *Model, DWORD SetBits, DWORD ClearBits, POLY_CALLBACK Callback)
{
	FBspSurf *Poly = &Model->Surfs(0);
	//
	for (INT i=0; i<Model->Surfs.Num(); i++)
		{
		if (((Poly->PolyFlags&SetBits)!=0) || ((Poly->PolyFlags&~ClearBits)!=0))
			{
			Callback (Model,i);
			};
		Poly++;
		};
};

//
// Find all BspSurfs corresponding to a particular editor brush object
// and polygon index. Call with BrushPoly set to INDEX_NONE to find all Bsp 
// polys corresponding to the Brush.
//
void UEditorEngine::polyFindByBrush( UModel* Model, ABrush* Actor, INT iBrushPoly, POLY_CALLBACK Callback )
{
	for (INT i=0; i<Model->Surfs.Num(); i++)
		{
		FBspSurf &Poly = Model->Surfs(i);
		if (
			(Poly.Actor == Actor) && 
			((iBrushPoly == INDEX_NONE) || (Poly.iBrushPoly == iBrushPoly))
			)
			{
			Callback (Model,i);
			};
		};
};

// Populates a list with all polys that are linked to the specified poly.  The
// resulting list includes the original poly.
void UEditorEngine::polyGetLinkedPolys
(
	ABrush* InBrush,
	FPoly* InPoly,
	TArray<FPoly>* InPolyList
)
{
	InPolyList->Empty();

	if( InPoly->iLink == INDEX_NONE )
	{
		// If this poly has no links, just stick the one poly in the final list.
		new(*InPolyList)FPoly( *InPoly );
	}
	else
	{
		// Find all polys that match the source polys link value.
		for( INT poly = 0 ; poly < InBrush->Brush->Polys->Element.Num() ; poly++ )
			if( InBrush->Brush->Polys->Element(poly).iLink == InPoly->iLink )
				new(*InPolyList)FPoly( InBrush->Brush->Polys->Element(poly) );
	}
}

// Takes a list of polygons and creates a new list of polys which have no overlapping edges.  It splits
// edges as necessary to achieve this.
void UEditorEngine::polySplitOverlappingEdges( TArray<FPoly>* InPolyList, TArray<FPoly>* InResult )
{
	InResult->Empty();

	for( INT poly = 0 ; poly < InPolyList->Num() ; poly++ )
	{
		FPoly* SrcPoly = &(*InPolyList)(poly);
		FPoly NewPoly = *SrcPoly;

		for( INT edge = 0 ; edge < SrcPoly->NumVertices ; edge++ )
		{
			FEdge SrcEdge = FEdge( SrcPoly->Vertex[edge], SrcPoly->Vertex[ edge+1 < SrcPoly->NumVertices ? edge+1 : 0 ] );
			FPlane SrcEdgePlane( SrcEdge.Vertex[0], SrcEdge.Vertex[1], SrcEdge.Vertex[0] + (SrcPoly->Normal * 16) );

			for( INT poly2 = 0 ; poly2 < InPolyList->Num() ; poly2++ )
			{
				FPoly* CmpPoly = &(*InPolyList)(poly2);

				// We can't compare to ourselves.
				if( CmpPoly == SrcPoly )
					continue;

				for( INT edge2 = 0 ; edge2 < CmpPoly->NumVertices ; edge2++ )
				{
					FEdge CmpEdge = FEdge( CmpPoly->Vertex[edge2], CmpPoly->Vertex[ edge2+1 < CmpPoly->NumVertices ? edge2+1 : 0 ] );

					// If both vertices on this edge lie on the same plane as the original edge, create
					// a sphere around the original 2 vertices.  If either of this edges vertices are inside of
					// that sphere, we need to split the original edge by adding a vertex to it's poly.
					if( ::fabs( FPointPlaneDist( CmpEdge.Vertex[0], SrcEdge.Vertex[0], SrcEdgePlane ) ) < THRESH_POINT_ON_PLANE
							&& ::fabs( FPointPlaneDist( CmpEdge.Vertex[1], SrcEdge.Vertex[0], SrcEdgePlane ) ) < THRESH_POINT_ON_PLANE )
					{
						//
						// Check THIS edge against the SOURCE edge
						//

						FVector Dir = SrcEdge.Vertex[1] - SrcEdge.Vertex[0];
						Dir.Normalize();
						FLOAT Dist = FDist( SrcEdge.Vertex[1], SrcEdge.Vertex[0] );
						FVector Origin = SrcEdge.Vertex[0] + (Dir * (Dist / 2.0f));
						FLOAT Radius = Dist / 2.0f;

						for( INT vtx = 0 ; vtx < 2 ; vtx++ )
							if( FDist( Origin, CmpEdge.Vertex[vtx] ) && FDist( Origin, CmpEdge.Vertex[vtx] ) < Radius )
								NewPoly.InsertVertex( edge2+1, CmpEdge.Vertex[vtx] );
					}
				}
			}
		}

		new(*InResult)FPoly( NewPoly );
	}
}

// Takes a list of polygons and returns a list of the outside edges (edges which are not shared
// by other polys in the list).
void UEditorEngine::polyGetOuterEdgeList
(
	TArray<FPoly>* InPolyList,
	TArray<FEdge>* InEdgeList
)
{
	TArray<FPoly> NewPolyList;
	polySplitOverlappingEdges( InPolyList, &NewPolyList );

	TArray<FEdge> TempEdges;

	// Create a master list of edges.
	for( INT poly = 0 ; poly < NewPolyList.Num() ; poly++ )
	{
		FPoly* Poly = &NewPolyList(poly);
		for( INT vtx = 0 ; vtx < Poly->NumVertices ; vtx++ )
			new( TempEdges )FEdge( Poly->Vertex[vtx], Poly->Vertex[ vtx+1 < Poly->NumVertices ? vtx+1 : 0] );
	}

	// Add all the unique edges into the final edge list.
	TArray<FEdge> FinalEdges;

	FEdge blah;
	for( INT tedge = 0 ; tedge < TempEdges.Num() ; tedge++ )
	{
		FEdge* TestEdge = &TempEdges(tedge);

		INT EdgeCount = 0;
		for( INT edge = 0 ; edge < TempEdges.Num() ; edge++ )
		{
			blah = TempEdges(edge);
			if( TempEdges(edge) == *TestEdge )
				EdgeCount++;
		}

		if( EdgeCount == 1 )
			new( FinalEdges )FEdge( *TestEdge );
	}

	// Reorder all the edges so that they line up, end to end.
	InEdgeList->Empty();
	if( !FinalEdges.Num() ) return;

	new( *InEdgeList )FEdge( FinalEdges(0) );
	FVector Comp = FinalEdges(0).Vertex[1];
	FinalEdges.Remove(0);

	FEdge DebuG;
	for( INT x = 0 ; x < FinalEdges.Num() ; x++ )
	{
		DebuG = FinalEdges(x);

		// If the edge is backwards, flip it
		if( FinalEdges(x).Vertex[1] == Comp )
			Exchange( FinalEdges(x).Vertex[0], FinalEdges(x).Vertex[1] );

		if( FinalEdges(x).Vertex[0] == Comp )
		{
			new( *InEdgeList )FEdge( FinalEdges(x) );
			Comp = FinalEdges(x).Vertex[1];
			FinalEdges.Remove(x);
			x = -1;
		}
	}
}

/*-----------------------------------------------------------------------------
   All transactional polygon selection functions
-----------------------------------------------------------------------------*/

void UEditorEngine::polyResetSelection(UModel *Model)
{
	for (INT i=0; i<Model->Surfs.Num(); i++)
		{
		FBspSurf *Poly = &Model->Surfs(i);
		Poly->PolyFlags |= ~(PF_Selected | PF_Memorized);
		Poly++;
		};
};

void UEditorEngine::polySelectAll(UModel *Model)
{
	polySetAndClearPolyFlags(Model,PF_Selected,0,0,0);
};

void UEditorEngine::polySelectMatchingGroups( UModel* Model )
{
	appMemzero( GFlags1, sizeof(GFlags1) );
	for( INT i=0; i<Model->Surfs.Num(); i++ )
	{
		FBspSurf *Surf = &Model->Surfs(i);
		if( Surf->PolyFlags&PF_Selected )
		{
			FPoly Poly; polyFindMaster(Model,i,Poly);
			GFlags1[Poly.Actor->Group.GetIndex()]=1;
		}
	}
	for( i=0; i<Model->Surfs.Num(); i++ )
	{
		FBspSurf *Surf = &Model->Surfs(i);
		FPoly Poly; polyFindMaster(Model,i,Poly);
		if
		(	(GFlags1[Poly.Actor->Group.GetIndex()]) 
		&&	(!(Surf->PolyFlags & PF_Selected)) )
			{
			Model->ModifySurf( i, 0 );
			Surf->PolyFlags |= PF_Selected;
			};
	}
}

void UEditorEngine::polySelectMatchingItems(UModel *Model)
{
	appMemzero(GFlags1,sizeof(GFlags1));
	appMemzero(GFlags2,sizeof(GFlags2));

	for( INT i=0; i<Model->Surfs.Num(); i++ )
	{
		FBspSurf *Surf = &Model->Surfs(i);
		if( Surf->Actor )
		{
			if( Surf->PolyFlags & PF_Selected )
				GFlags2[Surf->Actor->Brush->GetIndex()]=1;
		}
		if( Surf->PolyFlags&PF_Selected )
		{
			FPoly Poly; polyFindMaster(Model,i,Poly);
			GFlags1[Poly.ItemName.GetIndex()]=1;
		}
	}
	for( i=0; i<Model->Surfs.Num(); i++ )
	{
		FBspSurf *Surf = &Model->Surfs(i);
		if( Surf->Actor )
		{
			FPoly Poly; polyFindMaster(Model,i,Poly);
			if ((GFlags1[Poly.ItemName.GetIndex()]) &&
				( GFlags2[Surf->Actor->Brush->GetIndex()]) &&
				(!(Surf->PolyFlags & PF_Selected)))
			{
				Model->ModifySurf( i, 0 );
				Surf->PolyFlags |= PF_Selected;
			}
		}
	}
}

enum EAdjacentsType
{
	ADJACENT_ALL,		// All adjacent polys
	ADJACENT_COPLANARS,	// Adjacent coplanars only
	ADJACENT_WALLS,		// Adjacent walls
	ADJACENT_FLOORS,	// Adjacent floors or ceilings
	ADJACENT_SLANTS,	// Adjacent slants
};

//
// Select all adjacent polygons (only coplanars if Coplanars==1) and
// return number of polygons newly selected.
//
int TagAdjacentsType(UModel *Model, EAdjacentsType AdjacentType)
{
	FVert	*VertPool;
	FVector		*Base,*Normal;
	BYTE		b;
	INT		    i;
	int			Selected,Found;
	//
	Selected = 0;
	appMemzero( GFlags1, sizeof(GFlags1) );
	//
	// Find all points corresponding to selected vertices:
	//
	for (i=0; i<Model->Nodes.Num(); i++)
		{
		FBspNode &Node = Model->Nodes(i);
		FBspSurf &Poly = Model->Surfs(Node.iSurf);
		if (Poly.PolyFlags & PF_Selected)
			{
			VertPool = &Model->Verts(Node.iVertPool);
			//
			for (b=0; b<Node.NumVertices; b++) GFlags1[(VertPool++)->pVertex] = 1;
			};
		};
	//
	// Select all unselected nodes for which two or more vertices are selected:
	//
	for (i=0; i<Model->Nodes.Num(); i++)
		{
		FBspNode &Node = Model->Nodes(i);
		FBspSurf &Poly = Model->Surfs(Node.iSurf);
		if (!(Poly.PolyFlags & PF_Selected))
			{
			Found    = 0;
			VertPool = &Model->Verts(Node.iVertPool);
			//
			Base   = &Model->Points (Poly.pBase);
			Normal = &Model->Vectors(Poly.vNormal);
			//
			for (b=0; b<Node.NumVertices; b++) Found += GFlags1[(VertPool++)->pVertex];
			//
			if (AdjacentType == ADJACENT_COPLANARS)
				{
				if (!GFlags2[Node.iSurf]) Found=0;
				}
			else if (AdjacentType == ADJACENT_FLOORS)
				{
				if (Abs(Normal->Z) <= 0.85) Found = 0;
				}
			else if (AdjacentType == ADJACENT_WALLS)
				{
				if (Abs(Normal->Z) >= 0.10) Found = 0;
				}
			else if (AdjacentType == ADJACENT_SLANTS)
				{
				if (Abs(Normal->Z) > 0.85) Found = 0;
				if (Abs(Normal->Z) < 0.10) Found = 0;
				};
			if (Found > 0)
			{
				Model->ModifySurf( Node.iSurf, 0 );
				Poly.PolyFlags |= PF_Selected;
				Selected++;
			}
		}
	}
	return Selected;
};

void TagCoplanars(UModel *Model)
{
	FBspSurf	*SelectedPoly,*Poly;
	FVector		*SelectedBase,*SelectedNormal,*Base,*Normal;
	//
	appMemzero(GFlags2,sizeof(GFlags2));
	//
	for (INT i=0; i<Model->Surfs.Num(); i++)
		{
		SelectedPoly = &Model->Surfs(i);
		if (SelectedPoly->PolyFlags & PF_Selected)
			{
			SelectedBase   = &Model->Points (SelectedPoly->pBase);
			SelectedNormal = &Model->Vectors(SelectedPoly->vNormal);
			//
			for (INT j=0; j<Model->Surfs.Num(); j++)
				{
				Poly = &Model->Surfs(j);
				Base   = &Model->Points (Poly->pBase);
				Normal = &Model->Vectors(Poly->vNormal);
				//
				if (FCoplanar(*Base,*Normal,*SelectedBase,*SelectedNormal) && (!(Poly->PolyFlags & PF_Selected)))
					{
					GFlags2[j]=1;
					};
				};
			};
		};
};

void UEditorEngine::polySelectAdjacents(UModel *Model)
{
	do {} while (TagAdjacentsType (Model,ADJACENT_ALL) > 0);
};

void UEditorEngine::polySelectCoplanars(UModel *Model)
{
	TagCoplanars(Model);
	do {} while (TagAdjacentsType(Model,ADJACENT_COPLANARS) > 0);
};

void UEditorEngine::polySelectMatchingBrush(UModel *Model)
{
	TArray<ABrush*> Brushes;

	// Generate a list of unique brushes.
	for( INT i = 0 ; i < Model->Surfs.Num() ; i++ )
	{
		FBspSurf* Surf = &Model->Surfs(i);
		if( Surf->PolyFlags & PF_Selected )
		{
			ABrush* ParentBrush = Cast<ABrush>(Surf->Actor);

			// See if we've already got this brush ...
			for( int brush = 0 ; brush < Brushes.Num() ; brush++ )
				if( ParentBrush == Brushes(brush) )
					break;

			// ... if not, add it to the list.
			if( brush == Brushes.Num() )
				Brushes( Brushes.Add() ) = ParentBrush;
		}
	}

	// Generate a list of unique brushes.
	for( i = 0 ; i < Model->Surfs.Num() ; i++ )
	{
		FBspSurf* Surf = &Model->Surfs(i);

		// Select all the polys on each brush in the unique list.
		for( int brush = 0 ; brush < Brushes.Num() ; brush++ )
			if( Cast<ABrush>(Surf->Actor) == Brushes(brush) )
				for( int poly = 0 ; poly < Brushes(brush)->Brush->Polys->Element.Num() ; poly++ )
					if( Surf->iBrushPoly == poly )
					{
						Model->ModifySurf( i, 0 );
						Surf->PolyFlags |= PF_Selected;
					}
	}
};

void UEditorEngine::polySelectMatchingTexture(UModel *Model)
{
	INT		i,Blank=0;
	appMemzero( GFlags1, sizeof(GFlags1) );
	//
	for (i=0; i<Model->Surfs.Num(); i++)
		{
		FBspSurf *Poly = &Model->Surfs(i);
		if (Poly->Texture && (Poly->PolyFlags&PF_Selected)) GFlags1[Poly->Texture->GetIndex()]=1;
		else if (!Poly->Texture) Blank=1;
		Poly++;
		};
	for (i=0; i<Model->Surfs.Num(); i++)
		{
		FBspSurf *Poly = &Model->Surfs(i);
		if (Poly->Texture && (GFlags1[Poly->Texture->GetIndex()]) && (!(Poly->PolyFlags&PF_Selected)))
			{
			Model->ModifySurf( i, 0 );
			Poly->PolyFlags |= PF_Selected;
			}
		else if (Blank & !Poly->Texture) Poly->PolyFlags |= PF_Selected;
		Poly++;
		};
};

void UEditorEngine::polySelectAdjacentWalls(UModel *Model)
{
	do {} while (TagAdjacentsType  (Model,ADJACENT_WALLS) > 0);
};

void UEditorEngine::polySelectAdjacentFloors(UModel *Model)
{
	do {} while (TagAdjacentsType (Model,ADJACENT_FLOORS) > 0);
};

void UEditorEngine::polySelectAdjacentSlants(UModel *Model)
{
	do {} while (TagAdjacentsType  (Model,ADJACENT_SLANTS) > 0);
};

void UEditorEngine::polySelectReverse(UModel *Model)
{
	for (INT i=0; i<Model->Surfs.Num(); i++)
		{
		FBspSurf *Poly = &Model->Surfs(i);
		Model->ModifySurf( i, 0 );
		Poly->PolyFlags ^= PF_Selected;
		//
		Poly++;
		};
};

void UEditorEngine::polyMemorizeSet(UModel *Model)
{
	for (INT i=0; i<Model->Surfs.Num(); i++)
		{
		FBspSurf *Poly = &Model->Surfs(i);
		if (Poly->PolyFlags & PF_Selected) 
			{
			if (!(Poly->PolyFlags & PF_Memorized))
				{
				Model->ModifySurf( i, 0 );
				Poly->PolyFlags |= (PF_Memorized);
				};
			}
		else
			{
			if (Poly->PolyFlags & PF_Memorized)
				{
				Model->ModifySurf( i, 0 );
				Poly->PolyFlags &= (~PF_Memorized);
				};
			};
		Poly++;
		};
};

void UEditorEngine::polyRememberSet(UModel *Model)
{
	for (INT i=0; i<Model->Surfs.Num(); i++)
		{
		FBspSurf *Poly = &Model->Surfs(i);
		if (Poly->PolyFlags & PF_Memorized) 
			{
			if (!(Poly->PolyFlags & PF_Selected))
				{
				Model->ModifySurf( i, 0 );
				Poly->PolyFlags |= (PF_Selected);
				};
			}
		else
			{
			if (Poly->PolyFlags & PF_Selected)
				{
				Model->ModifySurf( i, 0 );
				Poly->PolyFlags &= (~PF_Selected);
				};
			};
		Poly++;
		};
};

void UEditorEngine::polyXorSet(UModel *Model)
{
	int			Flag1,Flag2;
	//
	for (INT i=0; i<Model->Surfs.Num(); i++)
		{
		FBspSurf *Poly = &Model->Surfs(i);
		Flag1 = (Poly->PolyFlags & PF_Selected ) != 0;
		Flag2 = (Poly->PolyFlags & PF_Memorized) != 0;
		//
		if (Flag1 ^ Flag2)
			{
			if (!(Poly->PolyFlags & PF_Selected))
				{
				Model->ModifySurf( i, 0 );
				Poly->PolyFlags |= PF_Selected;
				};
			}
		else
			{
			if (Poly->PolyFlags & PF_Selected)
				{
				Model->ModifySurf( i, 0 );
				Poly->PolyFlags &= (~PF_Selected);
				};
			};
		Poly++;
		};
};

void UEditorEngine::polyUnionSet(UModel *Model)
{
	for (INT i=0; i<Model->Surfs.Num(); i++)
		{
		FBspSurf *Poly = &Model->Surfs(i);
		if (!(Poly->PolyFlags & PF_Memorized))
			{
			if (Poly->PolyFlags | PF_Selected)
				{
				Model->ModifySurf( i, 0 );
				Poly->PolyFlags &= (~PF_Selected);
				};
			};
		Poly++;
		};
};

void UEditorEngine::polyIntersectSet(UModel *Model)
{
	for (INT i=0; i<Model->Surfs.Num(); i++)
		{
		FBspSurf *Poly = &Model->Surfs(i);
		if ((Poly->PolyFlags & PF_Memorized) && !(Poly->PolyFlags & PF_Selected))
			{
			Poly->PolyFlags |= PF_Selected;
			};
		Poly++;
		};
};

#if 1 //LEGEND
void UEditorEngine::polySelectZone( UModel* Model )
{
	// identify the list of currently selected zones
	TArray<INT> iZoneList;
	for( INT i = 0; i < Model->Nodes.Num(); i++ )
	{
		FBspNode* Node = &Model->Nodes(i);
		FBspSurf* Poly = &Model->Surfs( Node->iSurf );
		if( Poly->PolyFlags & PF_Selected )
		{
			if( Node->iZone[1] != 0 )
				iZoneList.AddUniqueItem( Node->iZone[1] ); //front zone
			if( Node->iZone[0] != 0 )
				iZoneList.AddUniqueItem( Node->iZone[0] ); //back zone
		}
	}

	// select all polys that are match one of the zones identified above
	for( i = 0; i < Model->Nodes.Num(); i++ )
	{
		FBspNode* Node = &Model->Nodes(i);
		for( INT j = 0; j < iZoneList.Num(); j++ ) 
		{
			if( Node->iZone[1] == iZoneList(j) || Node->iZone[0] == iZoneList(j) )
			{
				FBspSurf* Poly = &Model->Surfs( Node->iSurf );
				Poly->PolyFlags |= PF_Selected;
			}
		}
	}
}
#endif

/*---------------------------------------------------------------------------------------
   Brush selection functions
---------------------------------------------------------------------------------------*/

//
// Generic selection routines
//

typedef int (*BRUSH_SEL_FUNC)( ABrush* Brush, int Tag );

void MapSelect( ULevel* Level, BRUSH_SEL_FUNC Func, int Tag )
{
	for( FStaticBrushIterator It(Level); It; ++It )
	{
		ABrush* Actor = *It;
		if( Func( Actor, Tag ) )
		{
			// Select it.
			if( !Actor->bSelected )
			{
				Actor->Modify();
				Actor->bSelected = 1;
			}
		}
		else
		{
			// Deselect it.
			if( Actor->bSelected )
			{
				Actor->Modify();
				Actor->bSelected = 0;
			}
		}
	}
}

//
// Select none
//
static int BrushSelectNoneFunc( ABrush* Actor, int Tag )
{
	return 0;
}

//
// Select by CSG operation
//
int BrushSelectOperationFunc( ABrush* Actor, int Tag )
{
	return ((ECsgOper)Actor->CsgOper == Tag) && !(Actor->PolyFlags & (PF_NotSolid | PF_Semisolid));
}
void UEditorEngine::mapSelectOperation(ULevel *Level,ECsgOper CsgOper)
{
	MapSelect( Level, BrushSelectOperationFunc, CsgOper );
}

int BrushSelectFlagsFunc( ABrush* Actor, int Tag )
{
	return Actor->PolyFlags & Tag;
}
void UEditorEngine::mapSelectFlags(ULevel *Level,DWORD Flags)
{
	MapSelect( Level, BrushSelectFlagsFunc, (int)Flags );
};

//
// Select first.
//
void UEditorEngine::mapSelectFirst( ULevel *Level )
{
	MapSelect( Level, BrushSelectNoneFunc, 0 );
	for( FStaticBrushIterator It(Level); It; ++It )
	{
		if( *It != Level->Brush() )
		{
			It->Modify();
			It->bSelected = 1;
			break;
		}
	}
}

//
// Select last.
//
void UEditorEngine::mapSelectLast( ULevel *Level )
{
	MapSelect( Level, BrushSelectNoneFunc, 0 );
	
	ABrush* Found=NULL;
	for( FStaticBrushIterator It(Level); It; ++It )
		Found = *It;

	if( Found )
	{
		Found->Modify();
		Found->bSelected = 1;
	}
}

/*---------------------------------------------------------------------------------------
   Other map brush functions
---------------------------------------------------------------------------------------*/

//
// Put the first selected brush into the current Brush.
//
void UEditorEngine::mapBrushGet( ULevel* Level )
{
	for( INT i=0; i<Level->Actors.Num(); i++ )
	{
		ABrush* Actor = Cast<ABrush>(Level->Actors(i));
		if( Actor && Actor!=Level->Brush() && Actor->bSelected )
		{
			Level->Brush()->Modify();
			Level->Brush()->Brush->Polys->Element = Actor->Brush->Polys->Element;
			Level->Brush()->CopyPosRotScaleFrom( Actor );
			break;
		}
	}
}

//
// Replace all selected brushes with the current Brush.
//
void UEditorEngine::mapBrushPut( ULevel* Level )
{
	for( INT i=0; i<Level->Actors.Num(); i++ )
	{
		ABrush* Actor = Cast<ABrush>(Level->Actors(i));
		if( Actor && Actor!=Level->Brush() && Actor->bSelected )
		{
			Actor->Modify();
			Actor->Brush->Polys->Element = Level->Brush()->Brush->Polys->Element;
			Actor->CopyPosRotScaleFrom( Level->Brush() );
		}
	}
}

//
// Generic private routine for send to front / send to back
//
void SendTo( ULevel* Level, int bSendToFirst )
{
	FMemMark Mark(GMem);

	// Partition.
	TArray<AActor*> Lists[2];
	for( INT i=2; i<Level->Actors.Num(); i++ )
		if( Level->Actors(i) )
			Lists[Level->Actors(i)->bSelected ^ bSendToFirst ^ 1].AddItem( Level->Actors(i) );

	// Refill.
	check(Level->Actors.Num()>=2);
	Level->Actors.Remove(2,Level->Actors.Num()-2);
	for( i=0; i<2; i++ )
		for( INT j=0; j<Lists[i].Num(); j++ )
			Level->Actors.AddItem( Lists[i](j) );

	Mark.Pop();
}

//
// Send all selected brushes in a level to the front of the hierarchy
//
void UEditorEngine::mapSendToFirst( ULevel* Level )
{
	SendTo( Level, 0 );
}

//
// Send all selected brushes in a level to the back of the hierarchy
//
void UEditorEngine::mapSendToLast( ULevel* Level )
{
	SendTo( Level, 1 );
}

//
// Swaps the first 2 selected actors in the actor list
//
void UEditorEngine::mapSendToSwap( ULevel* Level )
{
	FStringOutputDevice GetPropResult = FStringOutputDevice();
	GEditor->Get( TEXT("ACTOR"), TEXT("NUMSELECTED"), GetPropResult );
	INT NumSelected = appAtoi(*GetPropResult);
	if (NumSelected < 2)
		return;

	INT Count = 0;
	AActor** Actors[2];
	for( INT i=2; i<Level->Actors.Num() && Count < 2; i++ )
		if( Level->Actors(i) && Level->Actors(i)->bSelected )
		{
			Actors[Count] = &(Level->Actors(i));
			Count++;
		}

	Exchange( *Actors[0], *Actors[1] );
}

void UEditorEngine::mapSetBrush
(
	ULevel*				Level,
	EMapSetBrushFlags	PropertiesMask,
	_WORD				BrushColor,
	FName				GroupName,
	DWORD				SetPolyFlags,
	DWORD				ClearPolyFlags,
	DWORD				CSGOper,
	INT					DrawType
)
{
	for( FStaticBrushIterator It(Level); It; ++It )
	{
		if( *It!=Level->Brush() && It->bSelected )
		{
			if( PropertiesMask & MSB_PolyFlags )
			{
				It->Modify();
				It->PolyFlags = (It->PolyFlags & ~ClearPolyFlags) | SetPolyFlags;
			}
			if( PropertiesMask & MSB_CSGOper )
			{
				It->Modify();
				It->CsgOper = CSGOper;
			}
			if( PropertiesMask & MSB_DrawType )
			{
				It->Modify();
				It->DrawType = DrawType;
			}
		}
	}
}

/*---------------------------------------------------------------------------------------
   Poly texturing operations
---------------------------------------------------------------------------------------*/

//
// Pan textures on selected polys.  Doesn't do transaction tracking.
//
void UEditorEngine::polyTexPan(UModel *Model,int PanU,int PanV,int Absolute)
{
	for (INT i=0; i<Model->Surfs.Num(); i++)
		{
		FBspSurf *Poly = &Model->Surfs(i);
		if (Poly->PolyFlags & PF_Selected)
			{
			if (Absolute)
				{
				Poly->PanU = PanU;
				Poly->PanV = PanV;
				}
			else // Relative
				{
				Poly->PanU += PanU;
				Poly->PanV += PanV;
				};
			polyUpdateMaster (Model,i,0,0);
			};
		Poly++;
		};
};

//
// Scale textures on selected polys. Doesn't do transaction tracking.
//
void UEditorEngine::polyTexScale( UModel* Model, FLOAT UU, FLOAT UV, FLOAT VU, FLOAT VV, INT Absolute )
{
	for( INT i=0; i<Model->Surfs.Num(); i++ )
	{
		FBspSurf *Poly = &Model->Surfs(i);
		if (Poly->PolyFlags & PF_Selected)
		{
			FVector OriginalU = Model->Vectors(Poly->vTextureU);
			FVector OriginalV = Model->Vectors(Poly->vTextureV);

			if( Absolute )
			{
				OriginalU *= 1.0/OriginalU.Size();
				OriginalV *= 1.0/OriginalV.Size();
			}

			// Calc new vectors.
			FVector NewU = OriginalU * UU + OriginalV * UV;
			FVector NewV = OriginalU * VU + OriginalV * VV;

			// Update Bsp poly.
			Poly->vTextureU = bspAddVector (Model,&NewU,0); // Add U vector
			Poly->vTextureV = bspAddVector (Model,&NewV,0); // Add V vector

			// Update generating brush poly.
			polyUpdateMaster( Model, i, 1, 0 );
			Poly->iLightMap = INDEX_NONE;
		}
		Poly++;
	}
}

// ============================================
//
// TEXTURE ALIGNMENT
//
// ============================================

INT GetMajorAxis( FVector InNormal )
{
	// Figure out the major axis information.
	INT Axis = TAXIS_X;
	if( ::fabs(InNormal.Y) > 0.6f ) Axis = TAXIS_Y;
	else if( ::fabs(InNormal.Z) > 0.6f ) Axis = TAXIS_Z;

	return Axis;
}

INT GetAxisMod( FVector InNormal, INT InAxis )
{
	INT Mod = 1;
	if( InNormal[InAxis] < 0 )	Mod = -1;

	return Mod;
}

void AlignWallDir( UModel* InModel, FBspSurf* InSurf, FVector InNormal )
{
	FVector U, V;

	U.X = +InNormal.Y;
	U.Y = -InNormal.X;
	U.Z = 0.0;
	U *= 1.0f / U.Size();
	V = (U ^ InNormal);
	V *= 1.0f / V.Size();

	if( V.Z > 0.0 )
	{
		V *= -1.0;
		U *= -1.0;
	}

	InSurf->vTextureU = GEditor->bspAddVector( InModel, &U, 0 );
	InSurf->vTextureV = GEditor->bspAddVector( InModel, &V, 0 );

	InSurf->PanU = 0;
	InSurf->PanV = 0;
	InSurf->iLightMap = INDEX_NONE;
}

void AlignFace( UModel* InModel, FBspSurf* InSurf, FVector InNormal, FPoly* InEdPoly, FBox* InBBox )
{

	int U=0, V=1;
	if( ::fabs(InEdPoly->Normal.X) > 0.5f )			{	U=1;	V=2;	}
	else if( ::fabs(InEdPoly->Normal.Y) > 0.5f )	{	U=2;	V=0;	}
	FVector Verts[3];

	for( INT x = 0 ; x < 3 ; x++ )
	{
		FVector Wk = InEdPoly->Vertex[x];
		Verts[x] = FVector(0,0,0);
		Verts[x][U] = Wk[U];
		Verts[x][V] = Wk[V];
		InEdPoly->UV[x] = FVector(0,0,0);
		InEdPoly->UV[x].X = (Verts[x][U] / InEdPoly->Texture->UClamp) * InEdPoly->Texture->UClamp;
		InEdPoly->UV[x].Y = (Verts[x][V] / InEdPoly->Texture->VClamp) * InEdPoly->Texture->VClamp;
	}


	//
	// NEW
	// NEW
	// NEW
	//
/*
	FBox PolyBBox = InEdPoly->GetBoundingBox( InSurf->Actor->Location );
	FVector Axis1, Axis2;
	FPlane Plane( InEdPoly->Vertex[0], InEdPoly->Vertex[1], InEdPoly->Vertex[2] );
	Plane.FindBestAxisVectors( Axis1, Axis2 );

	Verts[0] = PolyBBox.Min;
	Verts[1] = PolyBBox.Min + ( Axis1 * InEdPoly->Texture->UClamp );
	Verts[2] = PolyBBox.Min + ( Axis2 * InEdPoly->Texture->VClamp );
*/
	//
	// NEW
	// NEW
	// NEW
	//



	FVector Base;
	FTexCoordsToVectors(
		Verts[0], FVector(0,0,0),//InEdPoly->UV[0],
		Verts[1], FVector(0,InEdPoly->Texture->UClamp,0),//InEdPoly->UV[1],
		Verts[2], FVector(InEdPoly->Texture->UClamp,InEdPoly->Texture->VClamp,0),//InEdPoly->UV[2],
		&Base, &InEdPoly->TextureU, &InEdPoly->TextureV);

	InEdPoly->TextureV *= -1;

	//InSurf->pBase = GEditor->bspAddPoint( InModel, &InEdPoly->Base, 1);
	InSurf->vTextureU = GEditor->bspAddVector( InModel, &InEdPoly->TextureU, 0);
	InSurf->vTextureV = GEditor->bspAddVector( InModel, &InEdPoly->TextureV, 0);
	InSurf->iLightMap = INDEX_NONE;
}

void AlignDefault( UModel* InModel, FBspSurf* InSurf, FVector InNormal, FPoly* InEdPoly )
{
	FModelCoords Coords, Uncoords;

	FLOAT Orientation = InSurf->Actor->BuildCoords( &Coords, &Uncoords );

	InEdPoly->TextureU = FVector(0,0,0);
	InEdPoly->TextureV = FVector(0,0,0);
	InEdPoly->PanU = 0;
	InEdPoly->PanV = 0;
	InEdPoly->Finalize( 0 );
	InEdPoly->Transform( Coords, FVector(0,0,0), FVector(0,0,0), Orientation );

	InSurf->vTextureU = GEditor->bspAddVector( InModel, &InEdPoly->TextureU, 0);
	InSurf->vTextureV = GEditor->bspAddVector( InModel, &InEdPoly->TextureV, 0);
	InSurf->PanU = InEdPoly->PanU;
	InSurf->PanV = InEdPoly->PanV;
	InSurf->iLightMap = INDEX_NONE;
}

void AlignPlanar( UModel* InModel, FBspSurf* InSurf, FVector InNormal, FPoly* InEdPoly, INT ForceAxis = -1 )
{
	FVector Normal = InModel->Vectors( InSurf->vNormal );
	INT Axis = GetMajorAxis( Normal );

	if( ForceAxis != TAXIS_AUTO )
		if( ForceAxis == TAXIS_WALLS )
		{
			if( Axis == TAXIS_Z )
				Axis = TAXIS_Y;
		}
		else
		{
			Axis = ForceAxis;
		}

	// Determine the texturing vectors.
	FVector UAxis, VAxis;
	if( Axis == TAXIS_X )
	{
		UAxis = FVector(0,1,0);
		VAxis = FVector(0,0,-1);
	}
	else if( Axis == TAXIS_Y )
	{
		UAxis = FVector(1,0,0);
		VAxis = FVector(0,0,-1);
	}
	else
	{
		UAxis = FVector(1,0,0);
		VAxis = FVector(0,-1,0);
	}

	FVector Base = InModel->Points( InSurf->pBase );
	FVector UVClamp = InEdPoly->GetTextureSize();

	if( Axis == TAXIS_X )
	{
		InSurf->PanU = UVClamp.X + Base.Y;
		InSurf->PanV = UVClamp.Y - Base.Z;
	}
	else if( Axis == TAXIS_Y )
	{
		InSurf->PanU = UVClamp.X + Base.X;
		InSurf->PanV = UVClamp.Y - Base.Z;
	}
	else
	{
		InSurf->PanU = UVClamp.X + Base.X;
		InSurf->PanV = UVClamp.Y - Base.Y;
	}

	InSurf->PanU %= (INT)UVClamp.X;
	InSurf->PanV %= (INT)UVClamp.Y;

	InSurf->vTextureU = GEditor->bspAddVector( InModel, &UAxis, 0);
	InSurf->vTextureV = GEditor->bspAddVector( InModel, &VAxis, 0);
	InSurf->iLightMap = INDEX_NONE;
}

void AlignCylinder( UModel* InModel, FBspSurf* InSurf, FVector InNormal, FPoly* InEdPoly, FVector* InOrigin, FBox* InBBox )
{
	/*
	//FPoly Temp = *InEdPoly;

	FBox PolyBBox = InEdPoly->GetBoundingBox( InSurf->Actor->Location - InSurf->Actor->PrePivot );
	FPoly Temp;
	Temp.NumVertices = 2;
	Temp.Vertex[0] = FVector( PolyBBox.Min.X, PolyBBox.Min.Y, 0 );
	Temp.Vertex[1] = FVector( PolyBBox.Max.X, PolyBBox.Max.Y, 0 );;

	FVector MinMaxU = FVector(999,-999,0);
	for( INT x = 0 ; x < 3 ; x++ )
	{
		//
		// U
		//

		//FVector FocalPoint = Temp.Vertex[x] + InSurf->Actor->Location - InSurf->Actor->PrePivot;

		FVector Dir;
		Dir = FVector( InOrigin->X, InOrigin->Y, 0 ) - Temp.Vertex[x];
		Dir.Normalize();

		FRotator Test = Dir.Rotation();
		if( Test.Yaw < 0 )
			Test.Yaw += 65536;

		FLOAT U = Test.Yaw;// / 65536.0f;

		if( MinMaxU.X > U ) MinMaxU.X = U;
		if( MinMaxU.Y < U ) MinMaxU.Y = U;

		//
		// V
		//

		FLOAT TotalHeight;
		TotalHeight = InBBox->Max.Z - InBBox->Min.Z;
		FLOAT Vtx = Temp.Vertex[x].Z;
		Vtx -= InBBox->Max.Z;

		//UV[x].Y = Vtx / TotalHeight;
	}

	FVector Base, TextureU, TextureV;
	FVector UVClamp = InEdPoly->GetTextureSize();

	//FTexCoordsToVectors(
	//	Temp.Vertex[0], UV[0] * UVClamp,
	//	Temp.Vertex[1], UV[1] * UVClamp,
	//	Temp.Vertex[2], UV[2] * UVClamp,
	//	&Base, &TextureU, &TextureV);

	FLOAT warren = 1.0f / (MinMaxU.Y - MinMaxU.X);
	TextureU = FVector(1,0,0) * warren;
	TextureV = FVector(0,0,-1);

	//InSurf->PanU = UVClamp.X * UV[0].X;
	//InSurf->PanU %= (INT)UVClamp.X;

	InSurf->vTextureU = GEditor->bspAddVector( InModel, &TextureU, 0 );
	InSurf->vTextureV = GEditor->bspAddVector( InModel, &TextureV, 0 );
	InSurf->iLightMap = INDEX_NONE;
	*/

	///*
	FPoly Temp = *InEdPoly;

	FVector UV[3];	// X = U, Y = V
	for( INT x = 0, x2 = 2 ; x < 3 ; x++, x2-- )
	{
		UV[x].Z = 0;

		//
		// U
		//

		FVector FocalPoint = Temp.Vertex[x] + InSurf->Actor->Location - InSurf->Actor->PrePivot;

		FVector Dir;
		Dir = FVector( InOrigin->X, InOrigin->Y, 0 ) - FVector( FocalPoint.X, FocalPoint.Y, 0 );
		Dir.Normalize();

		FRotator Test = Dir.Rotation();
		if( Test.Yaw < 0 )
			Test.Yaw += 65536;

		UV[x].X = Test.Yaw / 65536.0f;

		//
		// V
		//

		FLOAT TotalHeight;
		TotalHeight = InBBox->Max.Z - InBBox->Min.Z;
		FLOAT Vtx = Temp.Vertex[x].Z;
		Vtx -= InBBox->Max.Z;

		UV[x].Y = Vtx / TotalHeight;
	}

	FVector Base, TextureU, TextureV;
	FVector UVClamp = InEdPoly->GetTextureSize();

	FTexCoordsToVectors(
		Temp.Vertex[0], UV[0] * UVClamp,
		Temp.Vertex[1], UV[1] * UVClamp,
		Temp.Vertex[2], UV[2] * UVClamp,
		&Base, &TextureU, &TextureV);

	TextureV *= -1;

	InSurf->PanU = UVClamp.X * UV[0].X;
	InSurf->PanU %= (INT)UVClamp.X;

	InSurf->vTextureU = GEditor->bspAddVector( InModel, &TextureU, 0 );
	InSurf->vTextureV = GEditor->bspAddVector( InModel, &TextureV, 0 );
	InSurf->iLightMap = INDEX_NONE;
	//*/
}

class FBspSurfIdx
{
public:
	FBspSurfIdx()
	{}
	FBspSurfIdx( FBspSurf* InSurf, INT InIdx )
	{
		Surf = InSurf;
		Idx = InIdx;
	}
	~FBspSurfIdx()
	{}

	FBspSurf* Surf;
	INT Idx;
};

//
// Align textures on selected polys.  Doesn't do any transaction tracking.
//
void UEditorEngine::polyTexAlign( UModel *Model, ETexAlign TexAlignType, DWORD Texels, DWORD Options )
{
	//
	// Reset any globals we need to.
	//

	//
	// Build an initial list of BSP surfaces to be aligned.
	//
	
	FModelCoords Coords, Uncoords;
	FPoly EdPoly;
	TArray<FBspSurfIdx> InitialSurfList;
	FBox PolyBBox;

	PolyBBox.Init();

	for( INT i = 0 ; i < Model->Surfs.Num() ; i++ )
	{
		FBspSurf* Surf = &Model->Surfs(i);
		polyFindMaster( Model, i, EdPoly );
		FVector Normal = Model->Vectors( Surf->vNormal );

		if( Surf->PolyFlags & PF_Selected )
		{
			new(InitialSurfList)FBspSurfIdx( Surf, i );

			switch( TexAlignType )
			{
				case TEXALIGN_Face:
				case TEXALIGN_Cylinder:
				{
					for( INT x = 0 ; x < EdPoly.NumVertices ; x++ )
						PolyBBox += (EdPoly.Vertex[x] + Surf->Actor->Location);
				}
				break;
			}
		}
	}

	//
	// Create a final list of BSP surfaces ... 
	//
	// - allows for rejection of surfaces
	// - allows for specific ordering of faces
	//

	TArray<FBspSurfIdx> FinalSurfList;
	FVector Normal;

	for( i = 0 ; i < InitialSurfList.Num() ; i++ )
	{
		FBspSurfIdx* Surf = &InitialSurfList(i);
		Normal = Model->Vectors( Surf->Surf->vNormal );
		polyFindMaster( Model, Surf->Idx, EdPoly );

		UBOOL bOK = 1;
		switch( TexAlignType )
		{
			case TEXALIGN_WallDir:
				if( Abs(Normal.Z) > 0.95 )
					bOK = 0;
				break;
		}

		if( bOK )
			new(FinalSurfList)FBspSurfIdx( Surf->Surf, Surf->Idx );
	}

	// 
	// Preprocessing for certain types.
	//

	FVector Origin = FVector(0,0,0);	// The world origin of all selected faces.
	FBox CylinderBBox;
	CylinderBBox.Init();

	switch( TexAlignType )
	{
		case TEXALIGN_Cylinder:
		{
			for( i = 0 ; i < FinalSurfList.Num() ; i++ )
			{
				FBspSurfIdx* Surf = &FinalSurfList(i);
				polyFindMaster( Model, Surf->Idx, EdPoly );

				for( INT x = 0 ; x < EdPoly.NumVertices ; x++ )
				{
					FVector Vtx = EdPoly.Vertex[x] + Surf->Surf->Actor->Location - Surf->Surf->Actor->PrePivot;
					Vtx.Z = 0;
					CylinderBBox += Vtx;
				}
			}
		}
		break;
	}

	FLOAT Dist = (CylinderBBox.Max - CylinderBBox.Min).Size() / 2.0f;
	FVector Dir = CylinderBBox.Max - CylinderBBox.Min;
	Dir.Normalize();
	Origin = CylinderBBox.Min + ( Dir * Dist );

	//
	// Align the final surfaces.
	//

	for( i = 0 ; i < FinalSurfList.Num() ; i++ )
	{
		FBspSurfIdx* Surf = &FinalSurfList(i);
		polyFindMaster( Model, Surf->Idx, EdPoly );
		Normal = Model->Vectors( Surf->Surf->vNormal );
		
		switch( TexAlignType )
		{
			case TEXALIGN_Default:
				AlignDefault( Model, Surf->Surf, Normal, &EdPoly );
				break;

			case TEXALIGN_WallDir:
				AlignWallDir( Model, Surf->Surf, Normal );
				break;

			case TEXALIGN_Cylinder:
				AlignCylinder( Model, Surf->Surf, Normal, &EdPoly, &Origin, &PolyBBox );
				break;

			case TEXALIGN_Planar:
			{
				UOptionsTexAlignPlanar* Proxy = (UOptionsTexAlignPlanar*)Options;
				AlignPlanar( Model, Surf->Surf, Normal, &EdPoly, Proxy->TAxis );
			}
			break;

			case TEXALIGN_PlanarAuto:
			{
				AlignPlanar( Model, Surf->Surf, Normal, &EdPoly, TAXIS_AUTO );
			}
			break;

			case TEXALIGN_PlanarWall:
			{
				AlignPlanar( Model, Surf->Surf, Normal, &EdPoly, TAXIS_WALLS );
			}
			break;

			case TEXALIGN_PlanarFloor:
			{
				AlignPlanar( Model, Surf->Surf, Normal, &EdPoly, TAXIS_Z );
			}
			break;

			case TEXALIGN_Face:
			{
				debugf( TEXT("EdPoly.NumVertices=%i"), EdPoly.NumVertices );
				if ( EdPoly.NumVertices == 4 ) 
				{
					// Scan through all 
					// Shouldn't change base point, just base U,V.
					FBspSurf* Poly = Surf->Surf;
					FLOAT Orientation = Poly->Actor->BuildCoords(&Coords,&Uncoords);

					EdPoly.Base      = EdPoly.Vertex[0];
					EdPoly.TextureU  = EdPoly.Vertex[3]-EdPoly.Vertex[0];//FVector(0,0,0);
					float TextureULength=EdPoly.TextureU.Size();
					EdPoly.TextureU.Normalize();

					EdPoly.TextureU/=(TextureULength/(float)EdPoly.Texture->USize);													
						
					EdPoly.TextureV  = EdPoly.Vertex[0]-EdPoly.Vertex[1];//FVector(0,0,0);
					float TextureVLength=EdPoly.TextureV.Size();

					EdPoly.TextureV.Normalize();
					EdPoly.TextureV/=(TextureVLength/(float)EdPoly.Texture->VSize);

					EdPoly.PanU      = 0;
					EdPoly.PanV      = 0;
					EdPoly.Finalize( 0 );
					EdPoly.Transform( Coords, FVector(0,0,0), FVector(0,0,0), Orientation );

					Poly->vTextureU 	= bspAddVector (Model,&EdPoly.TextureU,0);
					Poly->vTextureV 	= bspAddVector (Model,&EdPoly.TextureV,0);
					Poly->PanU			= EdPoly.PanU;
					Poly->PanV			= EdPoly.PanV;
					Poly->iLightMap     = INDEX_NONE;
				}
			}
		//		AlignFace( Model, Surf->Surf, Normal, &EdPoly, &PolyBBox );
			break;
		}

		polyUpdateMaster( Model, Surf->Idx, 1, 1 );
	}

	//GEditor->bspCleanup( Model );
	//GEditor->bspRefresh( Model, 1 );		
}


/*---------------------------------------------------------------------------------------
   Map geometry link topic handler
---------------------------------------------------------------------------------------*/

AUTOREGISTER_TOPIC(TEXT("Map"),MapTopicHandler);
void MapTopicHandler::Get( ULevel* Level, const TCHAR* Item, FOutputDevice& Ar )
{
	int NumBrushes  = 0;
	int NumAdd	    = 0;
	int NumSubtract	= 0;
	int NumSpecial  = 0;
	int NumPolys    = 0;

	for( FStaticBrushIterator It(Level); It; ++It )
	{
		NumBrushes++;
		UModel* Brush        = It->Brush;
		UPolys* BrushEdPolys = Brush->Polys;

		if      (It->CsgOper == CSG_Add)		NumAdd++;
		else if (It->CsgOper == CSG_Subtract)	NumSubtract++;
		else									NumSpecial++;

		NumPolys += BrushEdPolys->Element.Num();
	}

	if     ( appStricmp(Item,TEXT("Brushes"       ))==0 ) Ar.Logf(TEXT("%i"),NumBrushes-1);
	else if( appStricmp(Item,TEXT("Add"           ))==0 ) Ar.Logf(TEXT("%i"),NumAdd);
	else if( appStricmp(Item,TEXT("Subtract"      ))==0 ) Ar.Logf(TEXT("%i"),NumSubtract);
	else if( appStricmp(Item,TEXT("Special"       ))==0 ) Ar.Logf(TEXT("%i"),NumSpecial);
	else if( appStricmp(Item,TEXT("AvgPolys"      ))==0 ) Ar.Logf(TEXT("%i"),NumPolys/Max(1,NumBrushes-1));
	else if( appStricmp(Item,TEXT("TotalPolys"    ))==0 ) Ar.Logf(TEXT("%i"),NumPolys);
	else if( appStricmp(Item,TEXT("Points"		  ))==0 ) Ar.Logf(TEXT("%i"),Level->Model->Points.Num());
	else if( appStricmp(Item,TEXT("Vectors"		  ))==0 ) Ar.Logf(TEXT("%i"),Level->Model->Vectors.Num());
	else if( appStricmp(Item,TEXT("Sides"		  ))==0 ) Ar.Logf(TEXT("%i"),Level->Model->NumSharedSides);
	else if( appStricmp(Item,TEXT("Zones"		  ))==0 ) Ar.Logf(TEXT("%i"),Level->Model->NumZones-1);
	else if( appStricmp(Item,TEXT("Bounds"		  ))==0 ) Ar.Logf(TEXT("%i"),Level->Model->Bounds.Num());
	else if( appStricmp(Item,TEXT("DuplicateBrush"))==0 )
	{
		// Duplicate brush.
		for( INT i=0; i<Level->Actors.Num(); i++ )
			if
			(	Level->Actors(i)
			&&	Cast<ABrush>(Level->Actors(i))
			&&	Level->Actors(i)->bSelected )
			{
				ABrush* Actor    = (ABrush*)Level->Actors(i);
				Actor->Location  = Level->Brush()->Location;
				//Actor->Rotation  = Level->Brush()->Rotation;
				Actor->PrePivot  = Level->Brush()->PrePivot;
				GEditor->csgCopyBrush( Actor, Level->Brush(), 0, 0, 1 );
				break;
			}
		debugf( NAME_Log, TEXT("Duplicated brush") );
	}
}
void MapTopicHandler::Set( ULevel* Level, const TCHAR* Item, const TCHAR* Data )
{}

/*---------------------------------------------------------------------------------------
   Polys link topic handler
---------------------------------------------------------------------------------------*/

AUTOREGISTER_TOPIC(TEXT("Polys"),PolysTopicHandler);
void PolysTopicHandler::Get( ULevel* Level, const TCHAR* Item, FOutputDevice& Ar )
{
	DWORD		OnFlags,OffFlags;
	FName		SurfaceTag=NAME_None;

	INT n=0, StaticLights=0, Meshels=0, MeshU=0, MeshV=0;
	FString TextureName;
	OffFlags = (DWORD)~0;
	OnFlags  = (DWORD)~0;
	TextureName = TEXT("");
	for( INT i=0; i<Level->Model->Surfs.Num(); i++ )
	{
		FBspSurf *Poly = &Level->Model->Surfs(i);
		if( Poly->PolyFlags&PF_Selected )
		{
			if( Poly->Texture )
			{
				FString Name = Poly->Texture->GetFullName();
				Name = Name.Right( Name.Len() - Name.InStr(TEXT(" "), 0) );
				if( (TextureName == TEXT("") || TextureName == Name) && TextureName != TEXT("Multiple Textures") )
					TextureName = Name;
				else
					TextureName = TEXT("Multiple Textures");
			}

			if(!n) SurfaceTag=Poly->SurfaceTag;
			else
			{
				if(SurfaceTag!=Poly->SurfaceTag) SurfaceTag=NAME_None;
			}

			OnFlags  &=  Poly->PolyFlags;
			OffFlags &= ~Poly->PolyFlags;
			n++;
			if( Poly->iLightMap != INDEX_NONE )
			{
				FLightMapIndex& Index = Level->Model->LightMap(Poly->iLightMap);
				Meshels			+= Index.UClamp * Index.VClamp;
				MeshU            = Index.UClamp;
				MeshV            = Index.VClamp;
				if( Index.iLightActors != INDEX_NONE )
					for( INT j=0; Level->Model->Lights(j+Index.iLightActors); j++ )
						StaticLights++;
			}
		}
	}
	if      (!appStricmp(Item,TEXT("NumSelected")))				Ar.Logf(TEXT("%i"),n);
	else if (!appStricmp(Item,TEXT("StaticLights")))			Ar.Logf(TEXT("%i"),StaticLights);
	else if (!appStricmp(Item,TEXT("Meshels")))					Ar.Logf(TEXT("%i"),Meshels);
	else if (!appStricmp(Item,TEXT("SelectedSetFlags")))		Ar.Logf(TEXT("%u"),OnFlags  & ~PF_NoEdit);
	else if (!appStricmp(Item,TEXT("SelectedClearFlags")))		Ar.Logf(TEXT("%u"),OffFlags & ~PF_NoEdit);
	else if (!appStricmp(Item,TEXT("MeshSize")) && n==1)		Ar.Logf(TEXT("%ix%i"),MeshU,MeshV);
	else if (!appStricmp(Item,TEXT("TextureName")))				Ar.Logf(TEXT("%s"),*TextureName);
	else if (!appStricmp(Item,TEXT("SurfaceTag")))				Ar.Logf(TEXT("%s"),*SurfaceTag);
}
void PolysTopicHandler::Set( ULevel* Level, const TCHAR* Item, const TCHAR* Data )
{
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
