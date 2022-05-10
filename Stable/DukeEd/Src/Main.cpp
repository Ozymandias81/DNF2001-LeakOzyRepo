/*=============================================================================
	Main.cpp: DukeEd Windows startup.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

    Revision history:
		* Created by Tim Sweeney.

    Work-in-progress todo's:

=============================================================================*/

enum eLASTDIR 
{
	eLASTDIR_DNF,
	eLASTDIR_DTX,
	eLASTDIR_PCX,
	eLASTDIR_DFX,
	eLASTDIR_WAV,
	eLASTDIR_BRUSH,
	eLASTDIR_2DS,
	eLASTDIR_DMX,
	eLASTDIR_MAX,
};

enum eBROWSER 
{
	eBROWSER_MESH,
	eBROWSER_MUSIC,
	eBROWSER_SOUND,
	eBROWSER_ACTOR,
	eBROWSER_GROUP,
	eBROWSER_TEXTURE,
	eBROWSER_MAX,
};

// Includes
#pragma warning( disable : 4201 )
#pragma warning( disable : 4505 )  //  "Unreferenced local function removed"  
//#pragma comment( lib, "vfw32.lib" )
#define STRICT
#define _WIN32_IE 0x0200
#include <windows.h>
#include <commctrl.h>
#include <commdlg.h>
#include <shlobj.h>
#include "Engine.h"
#include "UnRender.h"
#include "Window.h"
#include "..\..\Editor\Src\EditorPrivate.h"
#include "Res\resource.h"
#include "DnMeshPrivate.h"
#include <string.h>
#define EDITOR_MAINLOOP_CANNIBAL
static DWORD IpcHandler(DWORD inSenderProcess, DWORD inMessage, DWORD inParamV, ANSICHAR* inParamS, void* inUserData);
#include "UnEngineWin.h"
#include "MRUList.h"

// Startup sound
#include <mmsystem.h>

// Mail support
#include "mail.h"

// Bugslayer
#ifndef _DEBUG
#undef _T
#include "Bugslayer\BugslayerUtil.h"
#pragma comment(lib,"bugslayerutil.lib")
#endif

// Instance reference. (Global for crash handler.)
HINSTANCE				GhInst;
// Crash handler execption pointers.
EXCEPTION_POINTERS*		GExPtrs;
// Used to prevent having to allocate memory from the possibly corrupted heap.
static char BugTextBuffer[32767]; 

/*-----------------------------------------------------------------------------
	Option proxies.
-----------------------------------------------------------------------------*/

// These enumerations should match the order of the proxies in the TArray.
enum
{
	PROXY_OPTIONSBRUSHSCALE				= 0,
	PROXY_OPTIONS2DSHAPEREXTRUDE		= 1,
	PROXY_OPTIONS2DSHAPEREXTRUDETOPOINT	= 2,
	PROXY_OPTIONS2DSHAPEREXTRUDETOBEVEL	= 3,
	PROXY_OPTIONS2DSHAPERSHEET			= 4,
	PROXY_OPTIONS2DSHAPERREVOLVE		= 5,
	PROXY_OPTIONS2DSHAPERBEZIERDETAIL	= 6,
	PROXY_OPTIONSSURFBEVEL				= 7,
	PROXY_OPTIONSTEXALIGN				= 8,
	PROXY_OPTIONSTEXALIGNPLANAR			= 9,
};
struct
{
	TCHAR* FullName;
	TCHAR* Name;
} GProxyNames[] =
{
	TEXT("Editor.OptionsBrushScale"), TEXT("OptionsBrushScale"),
	TEXT("Editor.Options2DShaperExtrude"), TEXT("Options2DShaperExtrude"),
	TEXT("Editor.Options2DShaperExtrudeToPoint"), TEXT("Options2DShaperExtrudeToPoint"),
	TEXT("Editor.Options2DShaperExtrudeToBevel"), TEXT("Options2DShaperExtrudeToBevel"),
	TEXT("Editor.Options2DShaperSheet"), TEXT("Options2DShaperSheet"),
	TEXT("Editor.Options2DShaperRevolve"), TEXT("Options2DShaperRevolve"),
	TEXT("Editor.Options2DShaperBezierDetail"), TEXT("Options2DShaperBezierDetail"),
	TEXT("Editor.OptionsSurfBevel"), TEXT("OptionsSurfBevel"),
	TEXT("Editor.OptionsTexAlign"), TEXT("OptionsTexAlign"),
	TEXT("Editor.OptionsTexAlignPlanar"), TEXT("OptionsTexAlignPlanar"),
	NULL, NULL
};
TArray<UOptionsProxy*> GProxies;

extern void FlushAllViewports();

#include "DlgProgress.h"
#include "DlgMapError.h"
#include "DlgRename.h"
#include "DlgDepth.h"
#include "DlgSearchActors.h"
#include "Browser.h"
#include "BrowserMaster.h"
WBrowserMaster* GBrowserMaster = NULL;
#include "CodeFrame.h"
#include "DlgTexProp.h"
#include "DlgGeneric.h"
#include "DlgBrushBuilder.h"
#include "DlgAddSpecial.h"
#include "DlgScaleLights.h"
#include "DlgTexReplace.h"
#include "SurfacePropSheet.h"
#include "TerrainEditSheet.h"
#include "BuildPropSheet.h"
#include "DlgBrushImport.h"
#include "DlgViewportConfig.h"
#include "DlgMapImport.h"


/*-----------------------------------------------------------------------------
	Cannibal IPC
-----------------------------------------------------------------------------*/

void DukeEdIpcHook(void)
{
	// Handle any incoming model config editor IPC messages
	IPC_GetMessages(IpcHandler, MACEDIT_IPC_PROTOCOL_OUT, NULL);
}

DWORD IpcHandler(DWORD inSenderProcess, DWORD inMessage, DWORD inParamV, ANSICHAR* inParamS, void* inUserData)
{
	UDukeMesh* Mesh = NULL;
	UDukeMeshInstance* MeshInst = NULL;
	UViewport* Viewport = FindObject<UViewport>(GEditor->Client, TEXT("MeshViewer"));
	if (Viewport)
	{
		Mesh = Cast<UDukeMesh>(Viewport->MiscRes);
		if (Mesh)
			MeshInst = Cast<UDukeMeshInstance>(Mesh->GetInstance(NULL));
	}

	switch(inMessage)
	{
	case MACEDIT_IPC_OMSG_SETCONFIG:
		debugf(TEXT("Cannibal: IPC SetConfig %s"), appFromAnsi(inParamS));
		if (!Mesh)
		{
			debugf(TEXT("Cannibal: IPC SetConfig: No mesh!"));
			return(1);
		}
		Mesh->ConfigName = FString(appFromAnsi(inParamS));
		GEditor->NotifyExec(NULL, TEXT("USECURRENT CLASS=Mesh"));
		return(1);
		break;
	case MACEDIT_IPC_OMSG_GETCURTEXREF:
		debugf(TEXT("Cannibal: IPC GetCurTexRef"));
		GEditor->NotifyExec(NULL, TEXT("USECURRENT CLASS=Texture"));
		inParamS[0] = 0;
		if (GEditor->CurrentTexture)
		{
			strcpy(inParamS, appToAnsi(GEditor->CurrentTexture->GetPathName()));
			debugf(TEXT("Cannibal: IPC GetCurTexRef: Result %s"), GEditor->CurrentTexture->GetPathName());
		}
		return(1);
		break;
	case MACEDIT_IPC_OMSG_ACTORUPDATE:
		debugf(TEXT("Cannibal: IPC ActorUpdate %s"), appFromAnsi(inParamS));
		if (MeshInst && MeshInst->Mac)
		{
			OCpjConfig* cfg = OCpjConfig::New(NULL);
			if (cfg->LoadFile(inParamS))
			{
				MeshInst->Mac->LoadConfig(cfg);

				// map the configuration's textures
				for (DWORD i=0;i<MeshInst->Mac->mSurfaces.GetCount();i++)
				{
					OCpjSurface* surf = MeshInst->Mac->mSurfaces[i];
					for (DWORD j=0;j<surf->m_Textures.GetCount();j++)
					{
						CCpjSrfTex* tex = &surf->m_Textures[j];
						tex->imagePtr = NULL;
						if (tex->refName[0])
						{
							tex->imagePtr = FindObject<UTexture>(ANY_PACKAGE, appFromAnsi(tex->refName), 0);
							if (!tex->imagePtr)
							{
								//tex->imagePtr = LoadObject<UTexture>(NULL, appFromAnsi(tex->refName), NULL, LOAD_None, NULL);
								// This is beyond nasty, but LoadObject, due to crappy linker requirements, needs the class to be an exact match... graar :(
								for (TObjectIterator<UClass> It; It; ++It)
								{
									if (It->IsChildOf(UTexture::StaticClass()))
										if (tex->imagePtr = (UTexture*)UObject::StaticLoadObject(*It, NULL, appFromAnsi(tex->refName), NULL, LOAD_None, NULL))
											break;
								}
							}
						}
					}
				}
			}
			cfg->Destroy();
		}
		if (Viewport)
			GEditor->Draw(Viewport, 1);
		GEditor->NotifyExec(NULL, TEXT("USECURRENT CLASS=Mesh")); // will update vb dialog info
		return(1);
		break;
	case MACEDIT_IPC_OMSG_TEXREFUPDATE:
		debugf(TEXT("Cannibal: IPC TexRefUpdate %s"));
		if (MeshInst && MeshInst->Mac)
		{
			// map the configuration's textures
			for (DWORD i=0;i<MeshInst->Mac->mSurfaces.GetCount();i++)
			{
				OCpjSurface* surf = MeshInst->Mac->mSurfaces[i];
				for (DWORD j=0;j<surf->m_Textures.GetCount();j++)
				{
					CCpjSrfTex* tex = &surf->m_Textures[j];
					tex->imagePtr = NULL;
					if (tex->refName[0])
					{
						tex->imagePtr = FindObject<UTexture>(ANY_PACKAGE, appFromAnsi(tex->refName), 0);
						if (!tex->imagePtr)
						{
							//tex->imagePtr = LoadObject<UTexture>(NULL, appFromAnsi(tex->refName), NULL, LOAD_None, NULL);
							// This is beyond nasty, but LoadObject, due to crappy linker requirements, needs the class to be an exact match... graar :(
							for (TObjectIterator<UClass> It; It; ++It)
							{
								if (It->IsChildOf(UTexture::StaticClass()))
									if (tex->imagePtr = (UTexture*)UObject::StaticLoadObject(*It, NULL, appFromAnsi(tex->refName), NULL, LOAD_None, NULL))
										break;
							}
						}
					}
				}
			}
		}
		if (Viewport)
			GEditor->Draw(Viewport, 1);
		GEditor->NotifyExec(NULL, TEXT("USECURRENT CLASS=Mesh")); // will update vb dialog info
		return(1);
		break;
	}
	return(0);
}


/*-----------------------------------------------------------------------------
	FPolyBreaker.
-----------------------------------------------------------------------------*/

//
// Breaks a list of vertices into a set of convex FPolys.  The only requirement
// is the vertices are wound in edge order ... so that each vertex connects to the next.
// It can't be a random pool of vertices.  The winding direction doesn't matter.
//
class /*ENGINE_API*/ FPolyBreaker
{
public:
	FPolyBreaker()
	{
		PolyVerts = NULL;
	}
	~FPolyBreaker()
	{}

	TArray<FVector>* PolyVerts;
	FVector PolyNormal;

	TArray<FPoly> FinalPolys;	// The resulting polygons.

	void Process( TArray<FVector>* InPolyVerts, FVector InPolyNormal )
	{
		PolyVerts = InPolyVerts;
		PolyNormal = InPolyNormal;

		MakeConvexPoly( PolyVerts );
		Optimize();
		
		FPlane testplane( FinalPolys(0).Vertex[0], FinalPolys(0).Vertex[1], FinalPolys(0).Vertex[2] );
		if( InPolyNormal != testplane )
		{
			// Sometimes the polys/verts come out the other side wound the wrong way, which results in brushes
			// that are inside-out.  Fix it.
			for( INT x = 0 ; x < FinalPolys.Num() ; x++ )
				FinalPolys(x).Reverse();

			TArray<FVector> NewVerts;
			for( x = PolyVerts->Num()-1 ; x > -1 ; x-- )
				new(NewVerts)FVector((*PolyVerts)(x));
			*PolyVerts = NewVerts;
		}
	}
	UBOOL IsPolyConvex( FPoly* InPoly )
	{
		TArray<FVector> Verts;
		for( INT x = 0 ; x < InPoly->NumVertices ; x++ )
			new(Verts)FVector( (*InPoly).Vertex[x] );

		return IsPolyConvex( &Verts );
	}
	UBOOL IsPolyConvex( TArray<FVector>* InVerts )
	{
		for( INT x = 0 ; x < InVerts->Num() ; x++ )
		{
			FVector Edge = (*InVerts)(x) - (*InVerts)( x < InVerts->Num()-1 ? x+1 : 0 );
			Edge.Normalize();

			FPlane CuttingPlane( (*InVerts)(x), (*InVerts)(x) + (PolyNormal * 16), (*InVerts)(x) + (Edge * 16 ) );
			TArray<FVector> FrontPoly, BackPoly;

			INT result = SplitWithPlane( InVerts, InVerts->Num(), (*InVerts)(x), CuttingPlane, &FrontPoly, &BackPoly );

			if( result == SP_Split )
			{
				return 0;
			}
		}

		return 1;
	}
	void MakeConvexPoly( TArray<FVector>* InVerts )
	{
		for( INT x = 0 ; x < InVerts->Num() ; x++ )
		{
			FVector Edge = (*InVerts)(x) - (*InVerts)( x < InVerts->Num()-1 ? x+1 : 0 );
			Edge.Normalize();

			FPlane CuttingPlane( (*InVerts)(x), (*InVerts)(x) + (PolyNormal * 16), (*InVerts)(x) + (Edge * 16 ) );
			TArray<FVector> FrontPoly, BackPoly;

			INT result = SplitWithPlane( InVerts, InVerts->Num(), (*InVerts)(x), CuttingPlane, &FrontPoly, &BackPoly );

			if( result == SP_Split )
			{
				MakeConvexPoly( &FrontPoly );
				MakeConvexPoly( &BackPoly );
				return;
			}
		}

		FPoly NewPoly;
		NewPoly.Init();
		for( x = 0 ; x < InVerts->Num() ; x++ )
		{
			if( NewPoly.NumVertices == FPoly::MAX_VERTICES )
			{
				new(FinalPolys)FPoly( NewPoly );

				NewPoly.Init();
				NewPoly.Vertex[ NewPoly.NumVertices ] = (*InVerts)(0);
				NewPoly.NumVertices++;
				NewPoly.Vertex[ NewPoly.NumVertices ] = (*InVerts)(x-1);
				NewPoly.NumVertices++;
			}

			NewPoly.Vertex[ NewPoly.NumVertices ] = (*InVerts)(x);
			NewPoly.NumVertices++;
		}

		if( NewPoly.NumVertices > 2 )
			new(FinalPolys)FPoly( NewPoly );
	}
	INT TryToMerge( FPoly *Poly1, FPoly *Poly2 )
	{
		// Vertex count reasonable?
		if( Poly1->NumVertices+Poly2->NumVertices > FPoly::MAX_VERTICES )
			return 0;

		// Find one overlapping point.
		INT Start1=0, Start2=0;
		for( Start1=0; Start1<Poly1->NumVertices; Start1++ )
			for( Start2=0; Start2<Poly2->NumVertices; Start2++ )
				if( FPointsAreSame(Poly1->Vertex[Start1], Poly2->Vertex[Start2]) )
					goto FoundOverlap;
		return 0;
		FoundOverlap:

		// Wrap around trying to merge.
		INT End1  = Start1;
		INT End2  = Start2;
		INT Test1 = Start1+1; if (Test1>=Poly1->NumVertices) Test1 = 0;
		INT Test2 = Start2-1; if (Test2<0)                   Test2 = Poly2->NumVertices-1;
		if( FPointsAreSame(Poly1->Vertex[Test1],Poly2->Vertex[Test2]) )
		{
			End1   = Test1;
			Start2 = Test2;
		}
		else
		{
			Test1 = Start1-1; if (Test1<0)                   Test1=Poly1->NumVertices-1;
			Test2 = Start2+1; if (Test2>=Poly2->NumVertices) Test2=0;
			if( FPointsAreSame(Poly1->Vertex[Test1],Poly2->Vertex[Test2]) )
			{
				Start1 = Test1;
				End2   = Test2;
			}
			else return 0;
		}

		// Build a new edpoly containing both polygons merged.
		FPoly NewPoly = *Poly1;
		NewPoly.NumVertices = 0;
		INT Vertex = End1;
		for( INT i=0; i<Poly1->NumVertices; i++ )
		{
			NewPoly.Vertex[NewPoly.NumVertices++] = Poly1->Vertex[Vertex];
			if( ++Vertex >= Poly1->NumVertices )
				Vertex=0;
		}
		Vertex = End2;
		for( i=0; i<(Poly2->NumVertices-2); i++ )
		{
			if( ++Vertex >= Poly2->NumVertices )
				Vertex=0;
			NewPoly.Vertex[NewPoly.NumVertices++] = Poly2->Vertex[Vertex];
		}

		// Remove colinear vertices and check convexity.
		if( NewPoly.RemoveColinears() )
		{
			if( NewPoly.NumVertices <= FBspNode::MAX_NODE_VERTICES )
			{
				*Poly1 = NewPoly;
				Poly2->NumVertices	= 0;
				return 1;
			}
			else return 0;
		}
		else return 0;
	}
	// Looks at the resulting polygons and tries to put polys with matching edges
	// together.  This reduces the total number of polys in the final shape.
	void Optimize()
	{
		debugf(TEXT("======== FPolyBreaker::Optimize"));
		while( OptimizeList( &FinalPolys ) )
		{
			debugf(TEXT("======== OptimizeList"));
		}
	}
	// Returns 1 if any polys were merged
	UBOOL OptimizeList( TArray<FPoly>* PolyList )
	{
		TArray<FPoly> OptimizedPolys, TempPolys;
		UBOOL bDidMergePolys = 0;

		TempPolys = FinalPolys;

		for( INT x = 0 ; x < TempPolys.Num() && !bDidMergePolys ; x++ )
		{
			for( INT y = 0 ; y < PolyList->Num()  && !bDidMergePolys ; y++ )
			{
				if( TempPolys(x) != (*PolyList)(y) )
				{
					FPoly Poly1 = TempPolys(x);
					debugf(TEXT("--------"));
					debugf(TEXT("======== TryToMerge"));
					bDidMergePolys = TryToMerge( &Poly1, &(*PolyList)(y) );
					new(OptimizedPolys)FPoly(Poly1);
				}
			}
		}

		debugf(TEXT("======== bDidMergePolys : %d"), bDidMergePolys);
		if( bDidMergePolys )
			FinalPolys = OptimizedPolys;
		return bDidMergePolys;
	}
	// This is basically the same function as FPoly::SplitWithPlane, but modified
	// to work with this classes data structures.
	INT SplitWithPlane
	(
		TArray<FVector>			*Vertex,
		INT						NumVertices,
		const FVector			&PlaneBase,
		const FVector			&PlaneNormal,
		TArray<FVector>			*FrontPoly,
		TArray<FVector>			*BackPoly
	) const
	{
		FVector 	Intersection;
		FLOAT   	Dist=0,MaxDist=0,MinDist=0;
		FLOAT		PrevDist,Thresh = THRESH_SPLIT_POLY_PRECISELY;
		enum 	  	{V_FRONT,V_BACK,V_EITHER} Status,PrevStatus=V_EITHER;
		INT     	i,j;

		// Find number of vertices.
		check(NumVertices>=3);

		*FrontPoly = *Vertex;
		*BackPoly = *Vertex;

		// See if the polygon is split by SplitPoly, or it's on either side, or the
		// polys are coplanar.  Go through all of the polygon points and
		// calculate the minimum and maximum signed distance (in the direction
		// of the normal) from each point to the plane of SplitPoly.
		for( i=0; i<NumVertices; i++ )
		{
			Dist = FPointPlaneDist( (*Vertex)(i), PlaneBase, PlaneNormal );

			if( i==0 || Dist>MaxDist ) MaxDist=Dist;
			if( i==0 || Dist<MinDist ) MinDist=Dist;

			if      (Dist > +Thresh) PrevStatus = V_FRONT;
			else if (Dist < -Thresh) PrevStatus = V_BACK;
		}
		if( MaxDist<Thresh && MinDist>-Thresh )
		{
			return SP_Coplanar;
		}
		else if( MaxDist < Thresh )
		{
			return SP_Back;
		}
		else if( MinDist > -Thresh )
		{
			return SP_Front;
		}
		else
		{
			// Split.
			if( FrontPoly==NULL )
				return SP_Split; // Caller only wanted status.

			FrontPoly->Empty();
			BackPoly->Empty();

			j = NumVertices-1; // Previous vertex; have PrevStatus already.

			for( i=0; i<NumVertices; i++ )
			{
				PrevDist	= Dist;
      			Dist		= FPointPlaneDist( (*Vertex)(i), PlaneBase, PlaneNormal );

				if      (Dist > +Thresh)  	Status = V_FRONT;
				else if (Dist < -Thresh)  	Status = V_BACK;
				else						Status = PrevStatus;

				if( Status != PrevStatus )
				{
					// Crossing.  Either Front-to-Back or Back-To-Front.
					// Intersection point is naturally on both front and back polys.
					if( (Dist >= -Thresh) && (Dist < +Thresh) )
					{
						// This point lies on plane.
						if( PrevStatus == V_FRONT )
						{
							new(*FrontPoly)FVector( (*Vertex)(i) );
							new(*BackPoly)FVector( (*Vertex)(i) );
						}
						else
						{
							new(*BackPoly)FVector( (*Vertex)(i) );
							new(*FrontPoly)FVector( (*Vertex)(i) );
						}
					}
					else if( (PrevDist >= -Thresh) && (PrevDist < +Thresh) )
					{
						// Previous point lies on plane.
						if (Status == V_FRONT)
						{
							new(*FrontPoly)FVector( (*Vertex)(j) );
							new(*FrontPoly)FVector( (*Vertex)(i) );
						}
						else
						{
							new(*BackPoly)FVector( (*Vertex)(j) );
							new(*BackPoly)FVector( (*Vertex)(i) );
						}
					}
					else
					{
						// Intersection point is in between.
						Intersection = FLinePlaneIntersection((*Vertex)(j),(*Vertex)(i),PlaneBase,PlaneNormal);

						if( PrevStatus == V_FRONT )
						{
							new(*FrontPoly)FVector( Intersection );
							new(*BackPoly)FVector( Intersection );
							new(*BackPoly)FVector( (*Vertex)(i) );
						}
						else
						{
							new(*BackPoly)FVector( Intersection );
							new(*FrontPoly)FVector( Intersection );
							new(*FrontPoly)FVector( (*Vertex)(i) );
						}
					}
				}
				else
				{
        			if (Status==V_FRONT) new(*FrontPoly)FVector( (*Vertex)(i) );
        			else                 new(*BackPoly)FVector( (*Vertex)(i) );
				}
				j          = i;
				PrevStatus = Status;
			}

			// Handle possibility of sliver polys due to precision errors.
			if( FrontPoly->Num()<3 )
				return SP_Back;
			else if( BackPoly->Num()<3 )
				return SP_Front;
			else return SP_Split;
		}
	}
};

#include "TwoDeeShapeEditor.h"
#include "Extern.h"
#include "BrowserSound.h"
#include "BrowserMusic.h"
#include "BrowserGroup.h"
#include "BrowserTexture.h"
#include "BrowserMesh.h"
#include "..\..\core\inc\unmsg.h"

//extern HWND GhwndBSPages[eBS_MAX];

// Just to keep track of the last viewport to get the focus.  The main editor
// app uses this to draw a white outline around the current viewport.
MRUList* GMRUList;
HWND GCurrentViewportFrame = NULL;
INT GScrollBarWidth = GetSystemMetrics(SM_CXVSCROLL);
HWND GhwndEditorFrame = NULL;

enum EViewportStyle
{
	VSTYLE_Floating		= 0,
	VSTYLE_Fixed		= 1,
};

class WViewportFrame;
typedef struct {
	INT RendMap;
	FLOAT PctLeft, PctTop, PctRight, PctBottom;	// Percentages of the parent window client size (VSTYLE_Fixed)
	FLOAT Left, Top, Right, Bottom;				// Literal window positions (VSTYLE_Floatin)
	WViewportFrame* m_pViewportFrame;
} VIEWPORTCONFIG;

// This is a list of all the viewport configs that are currently in effect.
TArray<VIEWPORTCONFIG> GViewports;

// Prefebbed viewport configs.  These should be in the same order as the buttons in DlgViewportConfig.
VIEWPORTCONFIG GTemplateViewportConfigs[4][4] =
{
	// 0
	REN_OrthXY,		0,		0,		.65f,		.50f,		0, 0, 0, 0,		NULL,
	REN_OrthXZ,		.65f,	0,		.35f,		.50f,		0, 0, 0, 0,		NULL,
	REN_DynLight,	0,		.50f,	.65f,		.50f,		0, 0, 0, 0,		NULL,
	REN_OrthYZ,		.65f,	.50f,	.35f,		.50f,		0, 0, 0, 0,		NULL,

	// 1
	REN_OrthXY,		0,		0,		.40f,		.40f,		0, 0, 0, 0,		NULL,
	REN_OrthXZ,		.40f,	0,		.30f,		.40f,		0, 0, 0, 0,		NULL,
	REN_OrthYZ,		.70f,	0,		.30f,		.40f,		0, 0, 0, 0,		NULL,
	REN_DynLight,	0,		.40f,	1.0f,		.60f,		0, 0, 0, 0,		NULL,

	// 2
	REN_DynLight,	0,		0,		.70f,		1.0f,		0, 0, 0, 0,		NULL,
	REN_OrthXY,		.70f,	0,		.30f,		.40f,		0, 0, 0, 0,		NULL,
	REN_OrthXZ,		.70f,	.40f,	.30f,		.30f,		0, 0, 0, 0,		NULL,
	REN_OrthYZ,		.70f,	.70f,	.30f,		.30f,		0, 0, 0, 0,		NULL,

	// 3
	REN_OrthXY,		0,		0,		1.0f,		.40f,		0, 0, 0, 0,		NULL,
	REN_DynLight,	0,		.40f,	1.0f,		.60f,		0, 0, 0, 0,		NULL,
	-1,	0, 0, 0, 0, 0, 0, 0, 0, NULL,
	-1,	0, 0, 0, 0, 0, 0, 0, 0, NULL,
};

INT GViewportStyle, GViewportConfig;

#include "ViewportFrame.h"

FString GLastDir[eLASTDIR_MAX];
FString GMapExt;
HMENU GMainMenu = NULL;

extern "C" {HINSTANCE hInstance;}
extern "C" {TCHAR GPackage[64]=TEXT("DukeEd");}

extern FString GLastText;
extern FString GMapExt;

void UpdateMenu();

class WMdiClient;
class WMdiFrame;
class WEditorFrame;
class WMdiDockingFrame;
class WLevelFrame;

// Memory allocator.
#include "FMallocWindows.h"
FMallocWindows Malloc;

// Log file.
#include "FOutputDeviceFile.h"
FOutputDeviceFile Log;

// Error handler.
#include "FOutputDeviceWindowsError.h"
FOutputDeviceWindowsError Error;

// Feedback.
#include "FFeedbackContextWindows.h"
FFeedbackContextWindows Warn;

// File manager.
#include "FFileManagerWindows.h"
FFileManagerWindows FileManager;

// Config.
#include "FConfigCacheIni.h"

WCodeFrame* GCodeFrame = NULL;
#include "BrowserActor.h"

WEditorFrame* GEditorFrame = NULL;
WLevelFrame* GLevelFrame = NULL;
W2DShapeEditor* G2DShapeEditor = NULL;
WSurfacePropSheet* GSurfPropSheet = NULL;
WTerrainEditSheet* GTerrainEditSheet = NULL;
WBuildPropSheet* GBuildSheet = NULL;
WBrowserSound* GBrowserSound = NULL;
WBrowserMusic* GBrowserMusic = NULL;
WBrowserGroup* GBrowserGroup = NULL;
WBrowserActor* GBrowserActor = NULL;
WBrowserTexture* GBrowserTexture = NULL;
WBrowserMesh* GBrowserMesh = NULL;
WDlgAddSpecial* GDlgAddSpecial = NULL;
WDlgScaleLights* GDlgScaleLights = NULL;
WDlgProgress* GDlgProgress = NULL;
WDlgMapErrors* GDlgMapErrors = NULL;
WDlgSearchActors* GDlgSearchActors = NULL;
WDlgTexReplace* GDlgTexReplace = NULL;

#include "ButtonBar.h"
#include "BottomBar.h"
#include "TopBar.h"
WButtonBar* GButtonBar;
WBottomBar* GBottomBar;
WTopBar* GTopBar;

void FileOpen( HWND hWnd );

void RefreshEditor()
{
	GBrowserMaster->RefreshAll();
	GBuildSheet->PropSheet->RefreshPages();
}

/*-----------------------------------------------------------------------------
	Document manager crappy abstraction.
-----------------------------------------------------------------------------*/

struct FDocumentManager
{
	virtual void OpenLevelView()=0;
} *GDocumentManager=NULL;

/*-----------------------------------------------------------------------------
	WMdiClient.
-----------------------------------------------------------------------------*/

// An MDI client window.
class WMdiClient : public WControl
{
	DECLARE_WINDOWSUBCLASS(WMdiClient,WControl,DukeEd)
	WMdiClient( WWindow* InOwner )
	: WControl( InOwner, 0, SuperProc )
	{}
	void OpenWindow( CLIENTCREATESTRUCT* ccs )
	{
		//must make nccreate work!! GetWindowClassName(),
		//!! WS_VSCROLL | WS_HSCROLL
        HWND hWndCreated = TCHAR_CALL_OS(CreateWindowEx(0,TEXT("MDICLIENT"),NULL,WS_CHILD|WS_CLIPCHILDREN | WS_CLIPSIBLINGS,0,0,0,0,OwnerWindow->hWnd,(HMENU)0xCAC,hInstance,ccs),CreateWindowExA(0,"MDICLIENT",NULL,WS_CHILD|WS_CLIPCHILDREN|WS_CLIPSIBLINGS,0,0,0,0,OwnerWindow->hWnd,(HMENU)0xCAC,hInstance,ccs));
		check(hWndCreated);
		check(!hWnd);
		_Windows.AddItem( this );
		hWnd = hWndCreated;
		Show( 1 );
	}
};
WNDPROC WMdiClient::SuperProc;

/*-----------------------------------------------------------------------------
	WDockingFrame.
-----------------------------------------------------------------------------*/

// One of four docking frame windows on a MDI frame.
class WDockingFrame : public WWindow
{
	DECLARE_WINDOWCLASS(WDockingFrame,WWindow,DukeEd)

	// Variables.
	INT DockDepth;
	WWindow* Child;

	// Functions.
	WDockingFrame( FName InPersistentName, WMdiFrame* InFrame, INT InDockDepth )
	:	WWindow			( InPersistentName, (WWindow*)InFrame )
	,   DockDepth       ( InDockDepth )
	,	Child			( NULL )
	{}
	void OpenWindow()
	{
		PerformCreateWindowEx
		(
			0,
			NULL,
			WS_CHILD | WS_CLIPCHILDREN | WS_CLIPSIBLINGS,
			0, 0, 0, 0,
			OwnerWindow->hWnd,
			NULL,
			hInstance
		);
		Show(1);
	}
	void Dock( WWindow* InChild )
	{
		Child = InChild;
	}
	void OnSize( DWORD Flags, INT InX, INT InY )
	{
		if( Child )
			Child->MoveWindow( GetClientRect(), TRUE );
	}
	void OnPaint()
	{
		PAINTSTRUCT PS;
		HDC hDC = BeginPaint( *this, &PS );
		HBRUSH brushBack = CreateSolidBrush( RGB(128,128,128) );

		FRect Rect = GetClientRect();
		FillRect( hDC, Rect, brushBack );
		MyDrawEdge( hDC, Rect, 1 );

		EndPaint( *this, &PS );

		DeleteObject( brushBack );
	}
};

/*-----------------------------------------------------------------------------
	WMdiFrame.
-----------------------------------------------------------------------------*/

// An MDI frame window.
class WMdiFrame : public WWindow
{
	DECLARE_WINDOWCLASS(WMdiFrame,WWindow,DukeEd)

	// Variables.
	WMdiClient MdiClient;
	WDockingFrame LeftFrame, BottomFrame, TopFrame;

	// Functions.
	WMdiFrame( FName InPersistentName )
	:	WWindow		( InPersistentName )
	,	MdiClient	( this )
	,	BottomFrame	( TEXT("MdiFrameBottom"), this, 32 )
	,	LeftFrame	( TEXT("MdiFrameLeft"), this, 68 + GScrollBarWidth )
	,	TopFrame	( TEXT("MdiFrameTop"), this, 32 )
	{}
	INT CallDefaultProc( UINT Message, UINT wParam, LONG lParam )
	{
		return DefFrameProcX( hWnd, MdiClient.hWnd, Message, wParam, lParam );
	}
	void OnCreate()
	{
		WWindow::OnCreate();

		// Create docking frames.
		BottomFrame.OpenWindow();
		LeftFrame.OpenWindow();
		TopFrame.OpenWindow();
	}
	virtual void RepositionClient()
	{
		// Reposition docking frames.
		FRect Client = GetClientRect();
		BottomFrame.MoveWindow( FRect(LeftFrame.DockDepth, Client.Max.Y-BottomFrame.DockDepth, Client.Max.X, Client.Max.Y), 1 );
		LeftFrame  .MoveWindow( FRect(0, TopFrame.DockDepth, LeftFrame.DockDepth, Client.Max.Y), 1 );
		TopFrame.MoveWindow( FRect(0, 0, Client.Max.X, TopFrame.DockDepth), 1 );

		// Reposition MDI client window.
		MdiClient.MoveWindow( FRect(LeftFrame.DockDepth, TopFrame.DockDepth, Client.Max.X, Client.Max.Y-BottomFrame.DockDepth), 1 );
	}
	void OnSize( DWORD Flags, INT NewX, INT NewY )
	{
		RepositionClient();
		throw TEXT("NoRoute");
	}
	void OpenWindow()
	{
		TCHAR Title[256];
		appSprintf( Title, LocalizeGeneral(TEXT("FrameWindow"),TEXT("DukeEd")), LocalizeGeneral(TEXT("Product"),TEXT("Core")) );
		PerformCreateWindowEx
		(
			WS_EX_APPWINDOW,
			Title,
			WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_SIZEBOX | WS_MAXIMIZEBOX | WS_MINIMIZEBOX,
			CW_USEDEFAULT,
			CW_USEDEFAULT,
			640,
			480,
			NULL,
			NULL,
			hInstance
		);
		ShowWindow( *this, SW_SHOWMAXIMIZED );
	}
	void OnSetFocus()
	{
		SetFocus( MdiClient );
	}
};

/*-----------------------------------------------------------------------------
	WBackgroundHolder.
-----------------------------------------------------------------------------*/

// Test.
class WBackgroundHolder : public WWindow
{
	DECLARE_WINDOWCLASS(WBackgroundHolder,WWindow,Window)

	// Structors.
	WBackgroundHolder( FName InPersistentName, WWindow* InOwnerWindow )
	:	WWindow( InPersistentName, InOwnerWindow )
	{}

	// WWindow interface.
	void OpenWindow()
	{
		MdiChild = 0;
		PerformCreateWindowEx
		(
			WS_EX_TOOLWINDOW | WS_EX_WINDOWEDGE,
			NULL,
			WS_CHILD | WS_POPUP | WS_CLIPCHILDREN | WS_CLIPSIBLINGS,
			0,
			0,
			512,
			256,
			OwnerWindow ? OwnerWindow->hWnd : NULL,
			NULL,
			hInstance
		);
	}
};

/*-----------------------------------------------------------------------------
	WLevelFrame.
-----------------------------------------------------------------------------*/

enum eBIMODE 
{
	eBIMODE_CENTER	= 0,
	eBIMODE_TILE	= 1,
	eBIMODE_STRETCH	= 2
};

class WLevelFrame : public WWindow
{
	DECLARE_WINDOWCLASS(WLevelFrame,WWindow,Window)

	// Variables.
	ULevel* Level;
	HBITMAP hImage;
	FString BIFilename;
	INT BIMode;	// eBIMODE_

	// Structors.
	WLevelFrame( ULevel* InLevel, FName InPersistentName, WWindow* InOwnerWindow )
	:	WWindow( InPersistentName, InOwnerWindow )
	,	Level( InLevel )
	{
		SetMapFilename( TEXT("") );
		hImage = NULL;
		BIMode = eBIMODE_CENTER;
		BIFilename = TEXT("");

		for( INT x = 0 ; x < GViewports.Num() ; x++)
			GViewports(x).m_pViewportFrame = NULL;
		GViewports.Empty();
	}
	void SetMapFilename( TCHAR* _MapFilename )
	{
		appStrcpy( MapFilename, _MapFilename );
		if( ::IsWindow( hWnd ) )
			SetText( MapFilename );
	}
	TCHAR* GetMapFilename()
	{
		return MapFilename;
	}

	void OnDestroy()
	{
		ChangeViewportStyle();

		for( INT group = 0 ; group < GButtonBar->Groups.Num() ; group++ )
			GConfig->SetInt( TEXT("Groups"), *GButtonBar->Groups(group).GroupName, GButtonBar->Groups(group).iState, TEXT("DukeEd.ini") );

		// Save data out to config file, and clean up...
		GConfig->SetInt( TEXT("Viewports"), TEXT("Style"), GViewportStyle, TEXT("DukeEd.ini") );
		GConfig->SetInt( TEXT("Viewports"), TEXT("Config"), GViewportConfig, TEXT("DukeEd.ini") );

		for( INT x = 0 ; x < GViewports.Num() ; x++)
		{
			TCHAR l_chName[20];
			appSprintf( l_chName, TEXT("U2Viewport%d"), x);

			if( GViewports(x).m_pViewportFrame 
					&& ::IsWindow( GViewports(x).m_pViewportFrame->hWnd ) 
					&& !::IsIconic( GViewports(x).m_pViewportFrame->hWnd )
					&& !::IsZoomed( GViewports(x).m_pViewportFrame->hWnd ))
			{
				FRect R = GViewports(x).m_pViewportFrame->GetWindowRect();
			
				GConfig->SetInt( l_chName, TEXT("Active"), 1, TEXT("DukeEd.ini") );
				GConfig->SetInt( l_chName, TEXT("RendMap"), GViewports(x).m_pViewportFrame->m_pViewport->Actor->RendMap, TEXT("DukeEd.ini") );

				GConfig->SetFloat( l_chName, TEXT("PctLeft"), GViewports(x).PctLeft, TEXT("DukeEd.ini") );
				GConfig->SetFloat( l_chName, TEXT("PctTop"), GViewports(x).PctTop, TEXT("DukeEd.ini") );
				GConfig->SetFloat( l_chName, TEXT("PctRight"), GViewports(x).PctRight, TEXT("DukeEd.ini") );
				GConfig->SetFloat( l_chName, TEXT("PctBottom"), GViewports(x).PctBottom, TEXT("DukeEd.ini") );

				GConfig->SetFloat( l_chName, TEXT("Left"), GViewports(x).Left, TEXT("DukeEd.ini") );
				GConfig->SetFloat( l_chName, TEXT("Top"), GViewports(x).Top, TEXT("DukeEd.ini") );
				GConfig->SetFloat( l_chName, TEXT("Right"), GViewports(x).Right, TEXT("DukeEd.ini") );
				GConfig->SetFloat( l_chName, TEXT("Bottom"), GViewports(x).Bottom, TEXT("DukeEd.ini") );

				FString Device = GViewports(x).m_pViewportFrame->m_pViewport->RenDev->GetClass()->GetFullName();
				Device = Device.Right( Device.Len() - Device.InStr( TEXT(" "), 0 ) - 1 );
				GConfig->SetString( l_chName, TEXT("Device"), *Device, TEXT("DukeEd.ini") );
			}
			else {

				GConfig->SetInt( l_chName, TEXT("Active"), 0, TEXT("DukeEd.ini") );
			}

			SafeDelete(GViewports(x).m_pViewportFrame);
		}

		// "Last Directory"
		GConfig->SetString( TEXT("Directories"), TEXT("PCX"), *GLastDir[eLASTDIR_PCX], TEXT("DukeEd.ini") );
		GConfig->SetString( TEXT("Directories"), TEXT("WAV"), *GLastDir[eLASTDIR_WAV], TEXT("DukeEd.ini") );
		GConfig->SetString( TEXT("Directories"), TEXT("BRUSH"), *GLastDir[eLASTDIR_BRUSH], TEXT("DukeEd.ini") );
		GConfig->SetString( TEXT("Directories"), TEXT("2DS"), *GLastDir[eLASTDIR_2DS], TEXT("DukeEd.ini") );

		// Background image
		GConfig->SetInt( TEXT("Background Image"), TEXT("Active"), (hImage != NULL), TEXT("DukeEd.ini") );
		GConfig->SetInt( TEXT("Background Image"), TEXT("Mode"), BIMode, TEXT("DukeEd.ini") );
		GConfig->SetString( TEXT("Background Image"), TEXT("Filename"), *BIFilename, TEXT("DukeEd.ini") );

		if (hImage)
			::DeleteObject( hImage );
	}
	// Looks for an empty viewport slot, allocates a viewport and returns a pointer to it.
	WViewportFrame* NewViewportFrame( FName* pName, UBOOL bNoSize )
	{
		// Clean up dead windows first.
		for( INT x = 0 ; x < GViewports.Num() ; x++)
			if( GViewports(x).m_pViewportFrame && !::IsWindow( GViewports(x).m_pViewportFrame->hWnd ) )
				GViewports.Remove(x);

		if( GViewports.Num() > dED_MAX_VIEWPORTS )
		{
			appMsgf( TEXT("You are at the limit for open viewports.") );
			return NULL;
		}

		// Make up a unique name for this viewport.
		TCHAR l_chName[20];
		for( x = 0 ; x < dED_MAX_VIEWPORTS ; x++)
		{
			appSprintf( l_chName, TEXT("U2Viewport%d"), x);

			// See if this name is already taken
			BOOL bIsUnused = 1;
			for( INT y = 0 ; y < GViewports.Num() ; y++)
				if( !appStricmp(GViewports(y).m_pViewportFrame->m_pViewport->GetName(),l_chName) )
				{
					bIsUnused = 0;
					break;
				}

			if( bIsUnused )
				break;
		}

		*pName = l_chName;

		// Create the viewport.
		new(GViewports)VIEWPORTCONFIG();
		INT Index = GViewports.Num() - 1;
		GViewports(Index).PctLeft = 0;
		GViewports(Index).PctTop = 0;
		GViewports(Index).PctRight = bNoSize ? 0 : 50;
		GViewports(Index).PctBottom = bNoSize ? 0 : 50;
		GViewports(Index).Left = 0;
		GViewports(Index).Top = 0;
		GViewports(Index).Right = bNoSize ? 0 : 320;
		GViewports(Index).Bottom = bNoSize ? 0 : 200;
		GViewports(Index).m_pViewportFrame = new WViewportFrame( *pName, this );
		GViewports(Index).m_pViewportFrame->m_iIdx = Index;

		GCurrentViewport = (DWORD)(GViewports(Index).m_pViewportFrame);

		return GViewports(Index).m_pViewportFrame;
	}
	// Causes all viewports to redraw themselves.  This is necessary so we can reliably switch
	// which window has the white focus outline.
	void RedrawAllViewports()
	{
		for( INT x = 0 ; x < GViewports.Num() ; x++)
			if(GViewports(x).m_pViewportFrame)
				InvalidateRect( GViewports(x).m_pViewportFrame->hWnd, NULL, 1 );
	}
	// Changes the visual style of all open viewports to whatever the current style is.  This is also good
	// for forcing all viewports to recompute their positional data.
	void ChangeViewportStyle()
	{
		for( INT x = 0 ; x < GViewports.Num() ; x++)
		{
			if( GViewports(x).m_pViewportFrame && ::IsWindow( GViewports(x).m_pViewportFrame->hWnd ) )
			{
				switch( GViewportStyle )
				{
					case VSTYLE_Floating:
						SetWindowLongA( GViewports(x).m_pViewportFrame->hWnd, GWL_STYLE, WS_OVERLAPPEDWINDOW | WS_CHILD | WS_VISIBLE | WS_CLIPCHILDREN | WS_CLIPSIBLINGS );
						break;
					case VSTYLE_Fixed:
						SetWindowLongA( GViewports(x).m_pViewportFrame->hWnd, GWL_STYLE, WS_CHILD | WS_VISIBLE | WS_CLIPCHILDREN | WS_CLIPSIBLINGS );
						break;
				}

				GViewports(x).m_pViewportFrame->ComputePositionData();
				SetWindowPos( GViewports(x).m_pViewportFrame->hWnd, HWND_TOP, 0, 0, 0, 0, SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE );

				GViewports(x).m_pViewportFrame->AdjustToolbarButtons();
			}
		}
	}
	// Resizes all existing viewports to fit properly on the screen.
	void FitViewportsToWindow()
	{
		RECT R;
		::GetClientRect( GLevelFrame->hWnd, &R );

		for( INT x = 0 ; x < GViewports.Num() ; x++)
		{
			VIEWPORTCONFIG* pVC = &(GViewports(GViewports(x).m_pViewportFrame->m_iIdx));
			if( GViewportStyle == VSTYLE_Floating )
				::MoveWindow(GViewports(x).m_pViewportFrame->hWnd,
					pVC->Left, pVC->Top, pVC->Right, pVC->Bottom, 1);
			else
				::MoveWindow(GViewports(x).m_pViewportFrame->hWnd,
					pVC->PctLeft * R.right, pVC->PctTop * R.bottom,
					pVC->PctRight * R.right, pVC->PctBottom * R.bottom, 1);
		}
	}
	void CreateNewViewports( INT _Style, INT _Config )
	{
		GViewportStyle = _Style;
		GViewportConfig = _Config;

		// Get rid of any existing viewports.
		for( INT x = 0 ; x < GViewports.Num() ; x++)
		{
			SafeDelete(GViewports(x).m_pViewportFrame);
		}
		GViewports.Empty();

		// Create new viewports
		switch( GViewportConfig )
		{
			case 0:		// classic
			{
				GLevelFrame->OpenFrameViewport( REN_OrthXY,0,0,10,10,SHOW_Menu | SHOW_Frame | SHOW_Actors | SHOW_Brush | SHOW_StandardView | SHOW_ChildWindow | SHOW_MovingBrushes | SHOW_HardwareBrushes );
				GLevelFrame->OpenFrameViewport( REN_OrthXZ,0,0,10,10,SHOW_Menu | SHOW_Frame | SHOW_Actors | SHOW_Brush | SHOW_StandardView | SHOW_ChildWindow | SHOW_MovingBrushes | SHOW_HardwareBrushes );
				GLevelFrame->OpenFrameViewport( REN_DynLight,0,0,10,10,SHOW_Menu | SHOW_Frame | SHOW_Actors | SHOW_Brush | SHOW_StandardView | SHOW_ChildWindow | SHOW_MovingBrushes | SHOW_HardwareBrushes );
				GLevelFrame->OpenFrameViewport( REN_OrthYZ,0,0,10,10,SHOW_Menu | SHOW_Frame | SHOW_Actors | SHOW_Brush | SHOW_StandardView | SHOW_ChildWindow | SHOW_MovingBrushes | SHOW_HardwareBrushes );
			}
			break;

			case 1:		// big one on buttom, small ones along top
			{
				GLevelFrame->OpenFrameViewport( REN_OrthXY,0,0,10,10,SHOW_Menu | SHOW_Frame | SHOW_Actors | SHOW_Brush | SHOW_StandardView | SHOW_ChildWindow | SHOW_MovingBrushes | SHOW_HardwareBrushes );
				GLevelFrame->OpenFrameViewport( REN_OrthXZ,0,0,10,10,SHOW_Menu | SHOW_Frame | SHOW_Actors | SHOW_Brush | SHOW_StandardView | SHOW_ChildWindow | SHOW_MovingBrushes | SHOW_HardwareBrushes );
				GLevelFrame->OpenFrameViewport( REN_OrthYZ,0,0,10,10,SHOW_Menu | SHOW_Frame | SHOW_Actors | SHOW_Brush | SHOW_StandardView | SHOW_ChildWindow | SHOW_MovingBrushes | SHOW_HardwareBrushes );
				GLevelFrame->OpenFrameViewport( REN_DynLight,0,0,10,10,SHOW_Menu | SHOW_Frame | SHOW_Actors | SHOW_Brush | SHOW_StandardView | SHOW_ChildWindow | SHOW_MovingBrushes | SHOW_HardwareBrushes );
			}
			break;

			case 2:		// big one on left side, small along right
			{
				GLevelFrame->OpenFrameViewport( REN_DynLight,0,0,10,10,SHOW_Menu | SHOW_Frame | SHOW_Actors | SHOW_Brush | SHOW_StandardView | SHOW_ChildWindow | SHOW_MovingBrushes | SHOW_HardwareBrushes );
				GLevelFrame->OpenFrameViewport( REN_OrthXY,  0,0,10,10,SHOW_Menu | SHOW_Frame | SHOW_Actors | SHOW_Brush | SHOW_StandardView | SHOW_ChildWindow | SHOW_MovingBrushes | SHOW_HardwareBrushes );
				GLevelFrame->OpenFrameViewport( REN_OrthXZ,  0,0,10,10,SHOW_Menu | SHOW_Frame | SHOW_Actors | SHOW_Brush | SHOW_StandardView | SHOW_ChildWindow | SHOW_MovingBrushes | SHOW_HardwareBrushes );
				GLevelFrame->OpenFrameViewport( REN_OrthYZ,  0,0,10,10,SHOW_Menu | SHOW_Frame | SHOW_Actors | SHOW_Brush | SHOW_StandardView | SHOW_ChildWindow | SHOW_MovingBrushes | SHOW_HardwareBrushes );
			}
			break;

			case 3:		// 2 large windows, split horizontally
			{
				GLevelFrame->OpenFrameViewport( REN_OrthXY,  0,0,10,10,SHOW_Menu | SHOW_Frame | SHOW_Actors | SHOW_Brush | SHOW_StandardView | SHOW_ChildWindow | SHOW_MovingBrushes | SHOW_HardwareBrushes );
				GLevelFrame->OpenFrameViewport( REN_DynLight,0,0,10,10,SHOW_Menu | SHOW_Frame | SHOW_Actors | SHOW_Brush | SHOW_StandardView | SHOW_ChildWindow | SHOW_MovingBrushes | SHOW_HardwareBrushes );
			}
			break;
		}

		// Load initial data from templates
		for( x = 0 ; x < GViewports.Num() ; x++ )
			if( GTemplateViewportConfigs[0][x].PctLeft != -1 )
			{
				GViewports(x).PctLeft = GTemplateViewportConfigs[GViewportConfig][x].PctLeft;
				GViewports(x).PctTop = GTemplateViewportConfigs[GViewportConfig][x].PctTop;
				GViewports(x).PctRight = GTemplateViewportConfigs[GViewportConfig][x].PctRight;
				GViewports(x).PctBottom = GTemplateViewportConfigs[GViewportConfig][x].PctBottom;
			}

		// Set the viewports to their proper sizes.
		INT SaveViewportStyle = VSTYLE_Fixed;
		Exchange( GViewportStyle, SaveViewportStyle );
		FitViewportsToWindow();
		Exchange( SaveViewportStyle, GViewportStyle );
		ChangeViewportStyle();
	}
	// WWindow interface.
	void OnKillFocus( HWND hWndNew )
	{
		GEditor->Client->MakeCurrent( NULL );
	}
	void Serialize( FArchive& Ar )
	{
		WWindow::Serialize( Ar );
		Ar << Level;
	}
	void OpenWindow( UBOOL bMdi, UBOOL bMax )
	{
		MdiChild = bMdi;
		PerformCreateWindowEx
		(
			MdiChild
			?	(WS_EX_MDICHILD)
			:	(0),
			TEXT("Level"),
			(bMax ? WS_MAXIMIZE : 0 ) |
			(MdiChild
			?	(WS_CHILD | WS_CLIPSIBLINGS | WS_CLIPCHILDREN | WS_SYSMENU | WS_CAPTION | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX)
			:	(WS_CHILD | WS_CLIPCHILDREN | WS_CLIPSIBLINGS)),
			CW_USEDEFAULT,
			CW_USEDEFAULT,
			512,
			384,
			MdiChild ? OwnerWindow->OwnerWindow->hWnd : OwnerWindow->hWnd,
			NULL,
			hInstance
		);
		if( !MdiChild )
		{
			SetWindowLongX( hWnd, GWL_STYLE, WS_POPUP | WS_CLIPCHILDREN | WS_CLIPSIBLINGS );
			OwnerWindow->Show(1);
		}

		// Open the proper configuration of viewports.
		if(!GConfig->GetInt( TEXT("Viewports"), TEXT("Style"), GViewportStyle, TEXT("DukeEd.ini") ))		GViewportStyle = VSTYLE_Fixed;
		if(!GConfig->GetInt( TEXT("Viewports"), TEXT("Config"), GViewportConfig, TEXT("DukeEd.ini") ))	GViewportConfig = 0;

		for( INT x = 0 ; x < dED_MAX_VIEWPORTS ; x++)
		{
			TCHAR l_chName[20];
			appSprintf( l_chName, TEXT("U2Viewport%d"), x);
			INT Active, RendMap;

			if(!GConfig->GetInt( l_chName, TEXT("Active"), Active, TEXT("DukeEd.ini") ))		Active = 0;

			if( Active )
			{
				if(!GConfig->GetInt( l_chName, TEXT("RendMap"), RendMap, TEXT("DukeEd.ini") ))	RendMap = REN_OrthXY;

				OpenFrameViewport( RendMap, 0, 0, 10, 10, SHOW_Menu | SHOW_Frame | SHOW_Actors | SHOW_Brush | SHOW_StandardView | SHOW_ChildWindow | SHOW_MovingBrushes | SHOW_HardwareBrushes );
				VIEWPORTCONFIG* pVC = &(GViewports.Last());

				if(!GConfig->GetFloat( l_chName, TEXT("PctLeft"), pVC->PctLeft, TEXT("DukeEd.ini") ))	pVC->PctLeft = 0;
				if(!GConfig->GetFloat( l_chName, TEXT("PctTop"), pVC->PctTop, TEXT("DukeEd.ini") ))	pVC->PctTop = 0;
				if(!GConfig->GetFloat( l_chName, TEXT("PctRight"), pVC->PctRight, TEXT("DukeEd.ini") ))	pVC->PctRight = .5f;
				if(!GConfig->GetFloat( l_chName, TEXT("PctBottom"), pVC->PctBottom, TEXT("DukeEd.ini") ))	pVC->PctBottom = .5f;

				if(!GConfig->GetFloat( l_chName, TEXT("Left"), pVC->Left, TEXT("DukeEd.ini") ))	pVC->Left = 0;
				if(!GConfig->GetFloat( l_chName, TEXT("Top"), pVC->Top, TEXT("DukeEd.ini") ))	pVC->Top = 0;
				if(!GConfig->GetFloat( l_chName, TEXT("Right"), pVC->Right, TEXT("DukeEd.ini") ))	pVC->Right = 320;
				if(!GConfig->GetFloat( l_chName, TEXT("Bottom"), pVC->Bottom, TEXT("DukeEd.ini") ))	pVC->Bottom = 200;

				FString Device;
				INT SizeX, SizeY;
				SizeX = pVC->m_pViewportFrame->m_pViewport->SizeX;
				SizeY = pVC->m_pViewportFrame->m_pViewport->SizeY;

				GConfig->GetString( l_chName, TEXT("Device"), Device, TEXT("DukeEd.ini") );
				if( !Device.Len() )		Device = TEXT("SoftDrv.SoftwareRenderDevice");

				pVC->m_pViewportFrame->m_pViewport->TryRenderDevice( *Device, SizeX, SizeY, INDEX_NONE, 0 );
				if( !pVC->m_pViewportFrame->m_pViewport->RenDev )
					pVC->m_pViewportFrame->m_pViewport->TryRenderDevice( TEXT("SoftDrv.SoftwareRenderDevice"), SizeX, SizeY, INDEX_NONE, 0 );
			}
		}

		FitViewportsToWindow();

		// Background image
		UBOOL bActive;
		if(!GConfig->GetInt( TEXT("Background Image"), TEXT("Active"), bActive, TEXT("DukeEd.ini") ))	bActive = 0;

		if( bActive )
		{
			if(!GConfig->GetInt( TEXT("Background Image"), TEXT("Mode"), BIMode, TEXT("DukeEd.ini") ))	BIMode = eBIMODE_CENTER;
			if(!GConfig->GetString( TEXT("Background Image"), TEXT("Filename"), BIFilename, TEXT("DukeEd.ini") ))	BIFilename.Empty();
			LoadBackgroundImage(BIFilename);
		}
	}
	void LoadBackgroundImage( FString Filename )
	{
		if( hImage ) 
			DeleteObject( hImage );

		hImage = (HBITMAP)LoadImageA( hInstance, appToAnsi( *Filename ), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE );

		if( hImage )
			BIFilename = Filename;
		else
			appMsgf ( TEXT("Error loading bitmap for background image.") );
	}
	void OnSize( DWORD Flags, INT NewX, INT NewY )
	{
		WWindow::OnSize( Flags, NewX, NewY );

		FitViewportsToWindow();
	}
	INT OnSetCursor()
	{
		WWindow::OnSetCursor();
		SetCursor(LoadCursorIdX(NULL,IDC_ARROW));
		return 0;
	}
	void OnPaint()
	{
		PAINTSTRUCT PS;
		HDC hDC = BeginPaint( *this, &PS );
		FillRect( hDC, GetClientRect(), (HBRUSH)(COLOR_WINDOW+1) );
		DrawImage( hDC );
		EndPaint( *this, &PS );

		// Put the name of the map into the titlebar.
		SetText( GetMapFilename() );
	}
	void DrawImage( HDC _hdc )
	{
		if( !hImage ) return;

		HDC hdcMem;
		HBITMAP hbmOld;
		BITMAP bitmap;

		// Prepare the bitmap.
		//
		GetObjectA( hImage, sizeof(BITMAP), (LPSTR)&bitmap );
		hdcMem = CreateCompatibleDC(_hdc);
		hbmOld = (HBITMAP)SelectObject(hdcMem, hImage);

		// Display it.
		//
		RECT l_rc;
		::GetClientRect( hWnd, &l_rc );
		switch( BIMode )
		{
			case eBIMODE_CENTER:
			{
				BitBlt(_hdc,
				   (l_rc.right - bitmap.bmWidth) / 2, (l_rc.bottom - bitmap.bmHeight) / 2,
				   bitmap.bmWidth, bitmap.bmHeight,
				   hdcMem,
				   0, 0,
				   SRCCOPY);
			}
			break;

			case eBIMODE_TILE:
			{
				INT XSteps = (INT)(l_rc.right / bitmap.bmWidth) + 1;
				INT YSteps = (INT)(l_rc.bottom / bitmap.bmHeight) + 1;

				for( INT x = 0 ; x < XSteps ; x++ )
					for( INT y = 0 ; y < YSteps ; y++ )
						BitBlt(_hdc,
						   (x * bitmap.bmWidth), (y * bitmap.bmHeight),
						   bitmap.bmWidth, bitmap.bmHeight,
						   hdcMem,
						   0, 0,
						   SRCCOPY);
			}
			break;

			case eBIMODE_STRETCH:
			{
				StretchBlt(
					_hdc,
				   0, 0,
				   l_rc.right, l_rc.bottom,
				   hdcMem,
				   0, 0,
				   bitmap.bmWidth, bitmap.bmHeight,
				   SRCCOPY);
			}
			break;
		}

		// Clean up.
		//
		SelectObject(hdcMem, hbmOld);
		DeleteDC(hdcMem);
	}

	// Opens a new viewport window.  It creates a viewportframe of the specified size, then creates
	// a viewport that fits inside of it.
	virtual void OpenFrameViewport( INT RendMap, INT X, INT Y, INT W, INT H, DWORD ShowFlags )
	{
		FName Name = TEXT("");

		// Open a viewport frame.
		WViewportFrame* pViewportFrame = NewViewportFrame( &Name, 1 );

		if( pViewportFrame ) 
		{
			pViewportFrame->OpenWindow();

			// Create the viewport inside of the frame.
			UViewport* Viewport = GEditor->Client->NewViewport( Name );
			Level->SpawnViewActor( Viewport );
			Viewport->Actor->ShowFlags = ShowFlags;
			Viewport->Actor->RendMap   = RendMap;
			Viewport->Input->Init( Viewport );
			pViewportFrame->SetViewport( Viewport );
			::MoveWindow( (HWND)pViewportFrame->hWnd, X, Y, W, H, 1 );
			::BringWindowToTop( pViewportFrame->hWnd );
			pViewportFrame->ComputePositionData();
		}
	}
private:

	TCHAR MapFilename[256];
};



/*-----------------------------------------------------------------------------
	WNewObject.
-----------------------------------------------------------------------------*/

// New object window.
class WNewObject : public WDialog
{
	DECLARE_WINDOWCLASS(WNewObject,WDialog,DukeEd)

	// Variables.
	WButton OkButton;
	WButton CancelButton;
	WListBox TypeList;
	WObjectProperties Props;
	UObject* Context;
	UObject* Result;
 
	// Constructor.
	WNewObject( UObject* InContext, WWindow* InOwnerWindow )
	:	WDialog		( TEXT("NewObject"), IDDIALOG_NewObject, InOwnerWindow )
	,	OkButton    ( this, IDOK,     FDelegate(this,(TDelegate)OnOk) )
	,	CancelButton( this, IDCANCEL, FDelegate(this,(TDelegate)EndDialogFalse) )
	,	TypeList	( this, IDC_TypeList )
	,	Props		( NAME_None, CPF_Edit, TEXT(""), this, 0 )
	,	Context     ( InContext )
	,	Result		( NULL )
	{
		Props.ShowTreeLines = 0;
		TypeList.DoubleClickDelegate=FDelegate(this,(TDelegate)OnOk);
	}

	// WDialog interface.
	void OnInitDialog()
	{
		WDialog::OnInitDialog();
		for( TObjectIterator<UClass> It; It; ++It )
		{
			if( It->IsChildOf(UFactory::StaticClass()) )
			{
				UFactory* Default = (UFactory*)It->GetDefaultObject();
				if( Default->bCreateNew )
					TypeList.SetItemData( TypeList.AddString( *Default->Description ), *It );
			}
		}
		Props.OpenChildWindow( IDC_PropHolder );
		TypeList.SetCurrent( 0, 1 );
		TypeList.SelectionChangeDelegate = FDelegate(this,(TDelegate)OnSelChange);
		OnSelChange();
	}
	void OnDestroy()
	{
		WDialog::OnDestroy();
	}
	virtual UObject* DoModal()
	{
		WDialog::DoModal( hInstance );
		return Result;
	}

	// Notifications.
	void OnSelChange()
	{
		INT Index = TypeList.GetCurrent();
		if( Index>=0 )
		{
			UClass*   Class   = (UClass*)TypeList.GetItemData(Index);
			UObject*  Factory = ConstructObject<UFactory>( Class );
			Props.Root.SetObjects( &Factory, 1 );
			EnableWindow( OkButton, 1 );
		}
		else
		{
			Props.Root.SetObjects( NULL, 0 );
			EnableWindow( OkButton, 0 );
		}
	}
	void OnOk()
	{
		if( Props.Root._Objects.Num() )
		{
			UFactory* Factory = CastChecked<UFactory>(Props.Root._Objects(0));
			Result = Factory->FactoryCreateNew( Factory->SupportedClass, NULL, NAME_None, 0, Context, GWarn );
			if( Result )
				EndDialogTrue();
		}
	}

	// WWindow interface.
	void Serialize( FArchive& Ar )
	{
		WDialog::Serialize( Ar );
		Ar << Context;
		for( INT i=0; i<TypeList.GetCount(); i++ )
		{
			UObject* Obj = (UClass*)TypeList.GetItemData(i);
			Ar << Obj;
		}
	}
};

void FileSaveAs( HWND hWnd )
{
	// Make sure we have a level loaded...
	if( !GLevelFrame ) { return; }

	OPENFILENAMEA ofn;
	char File[8192], *pFilename;
	TCHAR l_chCmd[255];

	pFilename = TCHAR_TO_ANSI( GLevelFrame->GetMapFilename() );
	strcpy( File, pFilename );

	ZeroMemory(&ofn, sizeof(OPENFILENAMEA));
	ofn.lStructSize = sizeof(OPENFILENAMEA);
	ofn.hwndOwner = hWnd;
	ofn.lpstrFile = File;
	ofn.nMaxFile = sizeof(char) * 8192;
	char Filter[255];
	::sprintf( Filter,
		"Map Files (*.%s)%c*.%s%cAll Files%c*.*%c%c",
		appToAnsi( *GMapExt ),
		'\0',
		appToAnsi( *GMapExt ),
		'\0',
		'\0',
		'\0',
		'\0' );
	ofn.lpstrFilter = Filter;
	ofn.lpstrInitialDir = appToAnsi( *(GLastDir[eLASTDIR_DNF]) );
	ofn.lpstrDefExt = appToAnsi( *GMapExt );
	ofn.Flags = OFN_HIDEREADONLY | OFN_NOCHANGEDIR | OFN_OVERWRITEPROMPT;

	// Display the Open dialog box. 
	if( GetSaveFileNameA(&ofn) )
	{
		// Convert the ANSI filename to UNICODE, and tell the editor to open it.
		GEditor->Exec( TEXT("BRUSHCLIP DELETE") );
		GEditor->Exec( TEXT("POLYGON DELETE") );
		appSprintf( l_chCmd, TEXT("MAP SAVE FILE=\"%s\""), ANSI_TO_TCHAR(File));
		GEditor->Exec( l_chCmd );

		// Save the filename.
		GLevelFrame->SetMapFilename( ANSI_TO_TCHAR(File) );
		GMRUList->AddItem( GLevelFrame->GetMapFilename() );
		GMRUList->AddToMenu( hWnd, GMainMenu, 1 );

		FString S = ANSI_TO_TCHAR(File);
		GLastDir[eLASTDIR_DNF] = S.Left( S.InStr( TEXT("\\"), 1 ) );
	}

	GFileManager->SetDefaultDirectory(appBaseDir());
}

void FileSave( HWND hWnd )
{
	if( GLevelFrame ) {

		if( ::appStrlen( GLevelFrame->GetMapFilename() ) )
		{
			GEditor->Exec( TEXT("BRUSHCLIP DELETE") );
			GEditor->Exec( TEXT("POLYGON DELETE") );
			GEditor->Exec( *(FString::Printf(TEXT("MAP SAVE FILE=\"%s\""), GLevelFrame->GetMapFilename())) );

			GMRUList->AddItem( GLevelFrame->GetMapFilename() );
			GMRUList->AddToMenu( hWnd, GMainMenu, 1 );
		}
		else
			FileSaveAs( hWnd );
	}
}

void FileSaveChanges( HWND hWnd )
{
	// If a level has been loaded and there is something in the undo buffer, ask the user
	// if they want to save.
	if( GLevelFrame 
			&& GEditor->Trans->CanUndo() )
	{
		TCHAR l_chMsg[256];

		appSprintf( l_chMsg, TEXT("Save changes to %s?"), GLevelFrame->GetMapFilename() );

		if( ::MessageBox( hWnd, l_chMsg, TEXT("DukeEd"), MB_YESNO) == IDYES )
			FileSave( hWnd );
	}
}

enum 
{
	GI_NUM_SELECTED			= 1,
	GI_CLASSNAME_SELECTED	= 2,
	GI_NUM_SURF_SELECTED	= 4,
	GI_CLASS_SELECTED		= 8
};

typedef struct
{
	INT iValue;
	FString String;
	UClass*	pClass;
} FGetInfoRet;

FGetInfoRet GetInfo( ULevel* Level, INT Item )
{
	FGetInfoRet Ret;

	Ret.iValue = 0;
	Ret.String = TEXT("");

	// ACTORS
	if( Item & GI_NUM_SELECTED
			|| Item & GI_CLASSNAME_SELECTED 
			|| Item & GI_CLASS_SELECTED )
	{
		INT NumActors = 0;
		BOOL bAnyClass = FALSE;
		UClass*	AllClass = NULL;

		for( INT i=0; i<Level->Actors.Num(); i++ )
		{
			if( Level->Actors(i) && Level->Actors(i)->bSelected )
			{
				if( bAnyClass && Level->Actors(i)->GetClass() != AllClass ) 
					AllClass = NULL;
				else 
					AllClass = Level->Actors(i)->GetClass();

				bAnyClass = TRUE;
				NumActors++;
			}
		}

		if( Item & GI_NUM_SELECTED )
		{
			Ret.iValue = NumActors;
		}
		if( Item & GI_CLASSNAME_SELECTED )
		{
			if( bAnyClass && AllClass )
				Ret.String = AllClass->GetName();
			else 
				Ret.String = TEXT("Actor");
		}
		if( Item & GI_CLASS_SELECTED )
		{
			if( bAnyClass && AllClass )
				Ret.pClass = AllClass;
			else 
				Ret.pClass = NULL;
		}
	}

	// SURFACES
	if( Item & GI_NUM_SURF_SELECTED)
	{
		INT NumSurfs = 0;

		for( INT i=0; i<Level->Model->Surfs.Num(); i++ )
		{
			FBspSurf *Poly = &Level->Model->Surfs(i);

			if( Poly->PolyFlags & PF_Selected )
			{
				NumSurfs++;
			}
		}

		if( Item & GI_NUM_SURF_SELECTED )
		{
			Ret.iValue = NumSurfs;
		}
	}

	return Ret;
}

void ShowCodeFrame( WWindow* Parent )
{
	if( GCodeFrame
			&& ::IsWindow( GCodeFrame->hWnd ) )
	{
		GCodeFrame->Show(1);
		::BringWindowToTop( GCodeFrame->hWnd );
	}
}

void RefreshOptionProxies()
{
	// Options Proxies
	GProxies.Empty();
	for( INT x = 0 ; GProxyNames[x].Name ; x++ )
	{
		UObject::StaticLoadObject( UClass::StaticClass(), NULL, GProxyNames[x].FullName, NULL, LOAD_NoWarn, NULL );
		UClass* Class = FindObjectChecked<UClass>( ANY_PACKAGE, GProxyNames[x].Name );	check(Class);
		UOptionsProxy* Proxy = ConstructObject<UOptionsProxy>( Class );					check(Proxy);
		GProxies.AddItem( Proxy );
	}
}


/*-----------------------------------------------------------------------------
	WEditorFrame.
-----------------------------------------------------------------------------*/

// NJS: Temporary:
void FlushAllViewports()
{
	for( INT x = 0 ; x < GViewports.Num() ; x++)
	{
		if(GViewports(x).m_pViewportFrame)
			if(GViewports(x).m_pViewportFrame->m_pViewport)
				if(GViewports(x).m_pViewportFrame->m_pViewport->RenDev)
					GViewports(x).m_pViewportFrame->m_pViewport->RenDev->Flush(0); 
	}
}

// Editor frame window.
class WEditorFrame : public WMdiFrame, public FNotifyHook, public FDocumentManager
{
	DECLARE_WINDOWCLASS(WEditorFrame,WMdiFrame,DukeEd)

	// Variables.
	WBackgroundHolder BackgroundHolder;
	WConfigProperties* Preferences;

	// Popup menus.
	HMENU TexturePopupMenu;
	HMENU SurfPopupMenu;
	HMENU ActorPopupMenu;
	HMENU BackdropPopupMenu;

	// Constructors.
	WEditorFrame()
	: WMdiFrame( TEXT("EditorFrame") )
	, BackgroundHolder( NAME_None, &MdiClient )
	, Preferences( NULL )
	{
	}

	// WWindow interface.
	void OnCreate()
	{
		WMdiFrame::OnCreate();
		SetText( *FString::Printf( LocalizeGeneral(TEXT("FrameWindow"),TEXT("DukeEd")), LocalizeGeneral(TEXT("Product"),TEXT("Core"))) );

		// Create MDI client.
		CLIENTCREATESTRUCT ccs;
        ccs.hWindowMenu = NULL; 
        ccs.idFirstChild = 60000;
		MdiClient.OpenWindow( &ccs );

		// Background.
		BackgroundHolder.OpenWindow();

		NE_EdInit( hWnd, hWnd );

		// Set up progress dialog.
		SafeDelete(GDlgProgress);
		GDlgProgress = new WDlgProgress( NULL, this );		
		GDlgProgress->DoModeless();

		SafeDelete(GDlgMapErrors);
		GDlgMapErrors = new WDlgMapErrors( NULL, this );
		GDlgMapErrors->DoModeless();

		Warn.hWndProgressBar = (DWORD)::GetDlgItem( GDlgProgress->hWnd, IDPG_PROGRESS);
		Warn.hWndProgressText = (DWORD)::GetDlgItem( GDlgProgress->hWnd, IDSC_MSG);
		Warn.hWndProgressDlg = (DWORD)GDlgProgress->hWnd;
		Warn.hWndMapErrorsDlg = (DWORD)GDlgMapErrors->hWnd;

		SafeDelete(GDlgSearchActors);
		GDlgSearchActors = new WDlgSearchActors( NULL, this );
		GDlgSearchActors->DoModeless();
		GDlgSearchActors->Show(0);

		SafeDelete(GDlgScaleLights);
		GDlgScaleLights = new WDlgScaleLights( NULL, this );
		GDlgScaleLights->DoModeless();
		GDlgScaleLights->Show(0);

		SafeDelete(GDlgTexReplace);
		GDlgTexReplace = new WDlgTexReplace( NULL, this );
		GDlgTexReplace->DoModeless();
		GDlgTexReplace->Show(0);

		// Create the popup menus.
		TexturePopupMenu  = LoadMenuIdX(hInstance, IDMENU_BrowserTexture_Context);
		SurfPopupMenu     = LoadMenuIdX(hInstance, IDMENU_SurfPopup);
		ActorPopupMenu    = LoadMenuIdX(hInstance, IDMENU_ActorPopup);
		BackdropPopupMenu = LoadMenuIdX(hInstance, IDMENU_BackdropPopup);

		RefreshOptionProxies();

		GEditorFrame = this;
	}
	virtual void OnTimer()
	{
		check(GEditor);
		if( GEditor->AutoSave )
			GEditor->Exec( TEXT("MAYBEAUTOSAVE") );
	}
	void RepositionClient()
	{
		WMdiFrame::RepositionClient();
		BackgroundHolder.MoveWindow( MdiClient.GetClientRect(), 1 );
	}
	virtual UBOOL ShouldClose()
	{
		if ( IDYES == MessageBoxEx( hWnd, _T("Are you sure you want to quit?"), _T("Confirm Quit"), MB_YESNO | MB_ICONQUESTION | MB_DEFBUTTON2 | MB_SYSTEMMODAL, MAKELANGID( LANG_ENGLISH, LANG_NEUTRAL ) ) )
			return TRUE;
		else
			return FALSE;
	}
	void OnClose()
	{
		::DestroyWindow( GLevelFrame->hWnd );
		SafeDelete(GLevelFrame);

		KillTimer( hWnd, 900 );

		GMRUList->WriteINI();

		SafeDelete(GSurfPropSheet);
		SafeDelete(GTerrainEditSheet);
		SafeDelete(GBuildSheet);
		SafeDelete(G2DShapeEditor);
		SafeDelete(GBrowserSound);
		SafeDelete(GBrowserMusic);
		SafeDelete(GBrowserGroup);
		SafeDelete(GBrowserMaster);
		SafeDelete(GBrowserActor);
		SafeDelete(GBrowserTexture);
		SafeDelete(GBrowserMesh);
		SafeDelete(GDlgAddSpecial);
		SafeDelete(GDlgScaleLights);
		SafeDelete(GDlgMapErrors);
		SafeDelete(GDlgProgress);
		SafeDelete(GDlgSearchActors);
		SafeDelete(GDlgTexReplace);

		::DestroyMenu( TexturePopupMenu );
		::DestroyMenu( SurfPopupMenu );
		::DestroyMenu( ActorPopupMenu );
		::DestroyMenu( BackdropPopupMenu );

		appRequestExit( 0 );
		WMdiFrame::OnClose();
	}
	void AddTriggerLightMacros( HMENU l_menu )
	{
		MENUITEMINFOA mif;
		char l_ch[255];

		mif.cbSize = sizeof(MENUITEMINFO);
		mif.fMask = MIIM_TYPE | MIIM_STATE;
		mif.fType = MFT_STRING;

		FGetInfoRet gir = GetInfo( GEditor->Level, GI_NUM_SURF_SELECTED );
		INT SelSurfs = gir.iValue;

		gir = GetInfo( GEditor->Level, GI_NUM_SELECTED | GI_CLASS_SELECTED );
		INT SelLights = 0;
		if ( (SelSurfs > 0) && (gir.iValue > 0) && (gir.pClass == ATriggerLight::StaticClass()) )
		{
			SelLights = gir.iValue;
			mif.fState = MFS_ENABLED;
		}
		else
			mif.fState = MFS_DISABLED;

		sprintf( l_ch, "Build TriggerLight (%i Surfs, %i TriggerLights Selected)", SelSurfs, SelLights );
		mif.dwTypeData = l_ch;
		SetMenuItemInfoA( l_menu, ID_SurfPopupBuildTriggerLight, FALSE, &mif );
	}
	void OnCommand( INT Command )
	{
		TCHAR l_chCmd[255];

		switch( Command )
		{
			case WM_REDRAWALLVIEWPORTS:
				{
					GEditor->RedrawLevel( GEditor->Level );
					GButtonBar->UpdateButtons();
					GBottomBar->UpdateButtons();
					GTopBar->UpdateButtons();
					GLevelFrame->RedrawAllViewports();
				}
				break;

			case WM_SETCURRENTVIEWPORT:
				{
					if( GCurrentViewport != (DWORD)LastlParam && LastlParam )
					{
						GCurrentViewport = (DWORD)LastlParam;
						for( INT x = 0 ; x < GViewports.Num() ; x++ )
						{
							if( GCurrentViewport == (DWORD)GViewports(x).m_pViewportFrame->m_pViewport )
							{
								GCurrentViewportFrame = GViewports(x).m_pViewportFrame->hWnd;
								break;
							}
						}
					}
					GLevelFrame->RedrawAllViewports();
				}
				break;

			case ID_FileNew:
			{
				FileSaveChanges( hWnd );
				//WNewObject Dialog( NULL, this );
				//UObject* Result = Dialog.DoModal();
				//if( Cast<ULevel>(Result) )
				//{
					GEditor->Exec(TEXT("MAP NEW"));
					GLevelFrame->SetMapFilename( TEXT("") );
					OpenLevelView();
					GButtonBar->RefreshBuilders();
					RefreshOptionProxies();
					if( GBrowserGroup )
						GBrowserGroup->RefreshGroupList();
				//}
			}
			break;

			case ID_FILE_IMPORT:
			{
				OPENFILENAMEA ofn;
				ANSICHAR File[8192] = "\0";

				ZeroMemory(&ofn, sizeof(OPENFILENAMEA));
				ofn.lStructSize = sizeof(OPENFILENAMEA);
				ofn.hwndOwner = hWnd;
				ofn.lpstrFile = File;
				ofn.nMaxFile = sizeof(char) * 8192;
				ofn.lpstrFilter = "Unreal Engine Text (*.t3d)\0*.t3d\0All Files\0*.*\0\0";
				ofn.lpstrInitialDir = appToAnsi( *(GLastDir[eLASTDIR_DNF]) );
				ofn.lpstrDefExt = "t3d";
				ofn.lpstrTitle = "Import Map";
				ofn.Flags = OFN_HIDEREADONLY | OFN_NOCHANGEDIR;

				// Display the Open dialog box.
				GEditor->LockMeshView = 1;
				if( GetOpenFileNameA(&ofn) )
				{
					WDlgMapImport l_dlg( this );
					if( l_dlg.DoModal( appFromAnsi( File ) ) )
					{
						GWarn->BeginSlowTask( TEXT("Importing Map"), 1, 0 );
						TCHAR l_chCmd[256];
						if( l_dlg.bImportIntoExistingCheck )
							appSprintf( l_chCmd, TEXT("MAP IMPORTADD FILE=\"%s\""), appFromAnsi( File ) );
						else
						{
							GLevelFrame->SetMapFilename( TEXT("") );
							OpenLevelView();
							appSprintf( l_chCmd, TEXT("MAP IMPORT FILE=\"%s\""), appFromAnsi( File ) );
						}
						GEditor->Exec( l_chCmd );
						GWarn->EndSlowTask();
						GEditor->RedrawLevel( GEditor->Level );

						FString S = appFromAnsi( File );
						GLastDir[eLASTDIR_DNF] = S.Left( S.InStr( TEXT("\\"), 1 ) );

						RefreshEditor();
						if( !l_dlg.bImportIntoExistingCheck )
						{
							GButtonBar->RefreshBuilders();
							RefreshOptionProxies();
						}
					}
				}
				GEditor->LockMeshView = 0;

				GFileManager->SetDefaultDirectory(appBaseDir());
			}
			break;

			case ID_FILE_EXPORT:
			{
				OPENFILENAMEA ofn;
				char File[8192] = "\0";

				ZeroMemory(&ofn, sizeof(OPENFILENAMEA));
				ofn.lStructSize = sizeof(OPENFILENAMEA);
				ofn.hwndOwner = hWnd;
				ofn.lpstrFile = File;
				ofn.nMaxFile = sizeof(char) * 8192;
				ofn.lpstrFilter = "Unreal Engine Text (*.t3d)\0*.t3d\0All Files\0*.*\0\0";
				ofn.lpstrInitialDir = appToAnsi( *(GLastDir[eLASTDIR_DNF]) );
				ofn.lpstrDefExt = "t3d";
				ofn.lpstrTitle = "Export Map";
				ofn.Flags = OFN_HIDEREADONLY | OFN_NOCHANGEDIR | OFN_OVERWRITEPROMPT;

				if( GetSaveFileNameA(&ofn) )
				{
					GEditor->Exec( TEXT("BRUSHCLIP DELETE") );
					GEditor->Exec( TEXT("POLYGON DELETE") );
					GEditor->Exec( *(FString::Printf(TEXT("MAP EXPORT FILE=\"%s\""), appFromAnsi( File ))));

					FString S = appFromAnsi( File );
					GLastDir[eLASTDIR_DNF] = S.Left( S.InStr( TEXT("\\"), 1 ) );
				}

				GFileManager->SetDefaultDirectory(appBaseDir());
			}
			break;

			case IDMN_ALIGN_WALL:
				GEditor->Exec( TEXT("POLY TEXALIGN WALL") );
				break;
			//case IDMN_ALIGN_ADJACENT:
			//	GEditor->Exec( TEXT("POLY TEXALIGN WALLCOLUMN") );
			//	break;

			case IDMN_TOOL_CHECK_ERRORS:
			{
				GEditor->Exec(TEXT("MAP CHECK"));
			}
			break;

			case IDMN_MRU1:
			case IDMN_MRU2:
			case IDMN_MRU3:
			case IDMN_MRU4:
			case IDMN_MRU5:
			case IDMN_MRU6:
			case IDMN_MRU7:
			case IDMN_MRU8:
			{
				GLevelFrame->SetMapFilename( (TCHAR*)(*(GMRUList->Items[Command - IDMN_MRU1] ) ) );
				GEditor->Exec( *(FString::Printf(TEXT("MAP LOAD FILE=\"%s\""), *GMRUList->Items[Command - IDMN_MRU1] )) );
				RefreshEditor();
				GButtonBar->RefreshBuilders();
				RefreshOptionProxies();
			}
			break;

			case IDMN_LOAD_BACK_IMAGE:
			{
				OPENFILENAMEA ofn;
				char File[8192] = "\0";

				ZeroMemory(&ofn, sizeof(OPENFILENAMEA));
				ofn.lStructSize = sizeof(OPENFILENAMEA);
				ofn.hwndOwner = hWnd;
				ofn.lpstrFile = File;
				ofn.nMaxFile = sizeof(char) * 8192;
				ofn.lpstrFilter = "Bitmaps (*.bmp)\0*.bmp\0All Files\0*.*\0\0";
				ofn.lpstrInitialDir = "..\\maps";
				ofn.lpstrTitle = "Open Image";
				ofn.lpstrInitialDir = appToAnsi( *(GLastDir[eLASTDIR_DTX]) );
				ofn.lpstrDefExt = "bmp";
				ofn.Flags = OFN_NOCHANGEDIR;

				// Display the Open dialog box. 
				//
				if( GetOpenFileNameA(&ofn) )
				{
					GLevelFrame->LoadBackgroundImage(appFromAnsi( File ));

					FString S = appFromAnsi( File );
					GLastDir[eLASTDIR_DTX] = S.Left( S.InStr( TEXT("\\"), 1 ) );
				}

				InvalidateRect( GLevelFrame->hWnd, NULL, FALSE );
			}
			break;

			case IDMN_CLEAR_BACK_IMAGE:
			{
				::DeleteObject( GLevelFrame->hImage );
				GLevelFrame->hImage = NULL;
				GLevelFrame->BIFilename = TEXT("");
				InvalidateRect( GLevelFrame->hWnd, NULL, FALSE );
			}
			break;

			case IDMN_BI_CENTER:
			{
				GLevelFrame->BIMode = eBIMODE_CENTER;
				InvalidateRect( GLevelFrame->hWnd, NULL, FALSE );
			}
			break;

			case IDMN_BI_TILE:
			{
				GLevelFrame->BIMode = eBIMODE_TILE;
				InvalidateRect( GLevelFrame->hWnd, NULL, FALSE );
			}
			break;

			case IDMN_BI_STRETCH:
			{
				GLevelFrame->BIMode = eBIMODE_STRETCH;
				InvalidateRect( GLevelFrame->hWnd, NULL, FALSE );
			}
			break;

			case ID_FileOpen:
			{
				FileOpen( hWnd );
			}
			break;

			case ID_FileClose:
			{
				FileSaveChanges( hWnd );

				if( GLevelFrame )
				{
					GLevelFrame->_CloseWindow();
					SafeDelete(GLevelFrame);
				}
			}
			break;

			case ID_FileSave:
			{
				FileSave( hWnd );
			}
			break;

			case ID_FileSaveAs:
			{
				FileSaveAs( hWnd );
			}
			break;

			case ID_BrowserMaster:
			{
				GBrowserMaster->Show(1);
			}
			break;

			case ID_BrowserTexture:
			{
				GBrowserMaster->ShowBrowser(eBROWSER_TEXTURE);
			}
			break;

			case ID_BrowserMesh:
			{
				GBrowserMaster->ShowBrowser(eBROWSER_MESH);
			}
			break;

			case ID_BrowserActor:
			{
				GBrowserMaster->ShowBrowser(eBROWSER_ACTOR);
			}
			break;

			case ID_BrowserSound:
			{
				GBrowserMaster->ShowBrowser(eBROWSER_SOUND);
			}
			break;

			case ID_BrowserMusic:
			{
				GBrowserMaster->ShowBrowser(eBROWSER_MUSIC);
			}
			break;

			case ID_BrowserGroup:
			{
				GBrowserMaster->ShowBrowser(eBROWSER_GROUP);
			}
			break;

			case ID_BrowserPrefabs:
			{
				appMsgf(TEXT("Not implemented yet."));
			}
			break;

			case IDMN_CODE_FRAME:
			{
				GBrowserMaster->ShowBrowser(eBROWSER_ACTOR);
				ShowCodeFrame( this );
			}
			break;

			case ID_FileExit:
			{
				if ( ShouldClose() )
					OnClose();
			}
			break;

			case ID_EditUndo:
			{
				GEditor->Exec( TEXT("TRANSACTION UNDO") );
			}
			break;

			case ID_EditRedo:
			{
				GEditor->Exec( TEXT("TRANSACTION REDO") );
			}
			break;

			case ID_EditDuplicate:
			{
				GEditor->Exec( TEXT("DUPLICATE") );
			}
			break;

			case IDMN_EDIT_SEARCH:
			{
				GDlgSearchActors->Show(1);
			}
			break;

			case IDMN_EDIT_SCALE_LIGHTS:
			{
				GDlgScaleLights->Show(1);
			}
			break;

			case IDMN_EDIT_TEX_REPLACE:
			{
				GDlgTexReplace->Show(1);
			}
			break;

			case ID_EditDelete:
			{
				GEditor->Exec( TEXT("DELETE") );
			}
			break;

			case ID_EditCut:
			{
				GEditor->Exec( TEXT("EDIT CUT") );
			}
			break;

			case ID_EditCopy:
			{
				GEditor->Exec( TEXT("EDIT COPY") );
			}
			break;

			case ID_EditPaste:
			{
				GEditor->Exec( TEXT("EDIT PASTE") );
			}
			break;

			case ID_EditSelectNone:
			{
				GEditor->Exec( TEXT("SELECT NONE") );
			}
			break;

			case ID_EditSelectAllActors:
			{
				GEditor->Exec( TEXT("ACTOR SELECT ALL") );
			}
			break;

			case ID_EditSelectAllSurfs:
			{
				GEditor->Exec( TEXT("POLY SELECT ALL") );
			}
			break;

			case ID_ViewActorProp:
			{
				if( !GEditor->ActorProperties )
				{
					GEditor->ActorProperties = new WObjectProperties( TEXT("ActorProperties"), CPF_Edit, TEXT(""), NULL, 1 );
					GEditor->ActorProperties->OpenWindow( hWnd );
					GEditor->ActorProperties->SetNotifyHook( GEditor );
				}
				GEditor->UpdatePropertiesWindows();
				GEditor->ActorProperties->Show(1);
			}
			break;

			case ID_ViewSurfaceProp:
			{
				GSurfPropSheet->Show( TRUE );
			}
			break;

			case ID_ViewTerrainEditSheet:
			{
				GTerrainEditSheet->Show( TRUE );
			}
			break;

			case ID_ViewLevelProp:
			{
				if( !GEditor->LevelProperties )
				{
					GEditor->LevelProperties = new WObjectProperties( TEXT("LevelProperties"), CPF_Edit, TEXT("Level Properties"), NULL, 1 );
					GEditor->LevelProperties->OpenWindow( hWnd );
					GEditor->LevelProperties->SetNotifyHook( GEditor );
				}
				GEditor->LevelProperties->Root.SetObjects( (UObject**)&GEditor->Level->Actors(0), 1 );
				GEditor->LevelProperties->Show(1);
			}
			break;

			case ID_BrushClip:
			{
				GEditor->Exec( TEXT("BRUSHCLIP") );
				GEditor->RedrawLevel( GEditor->Level );
			}
			break;

			case ID_BrushClipSplit:
			{
				GEditor->Exec( TEXT("BRUSHCLIP SPLIT") );
				GEditor->RedrawLevel( GEditor->Level );
			}
			break;

			case ID_BrushClipFlip:
			{
				GEditor->Exec( TEXT("BRUSHCLIP FLIP") );
				GEditor->RedrawLevel( GEditor->Level );
			}
			break;

			case ID_BrushClipDelete:
			{
				GEditor->Exec( TEXT("BRUSHCLIP DELETE") );
				GEditor->RedrawLevel( GEditor->Level );
			}
			break;

			case ID_BrushScale:
			{
				UOptionsBrushScale* Proxy = Cast<UOptionsBrushScale>(GProxies(PROXY_OPTIONSBRUSHSCALE));
				WDlgGeneric dlg( NULL, this, Proxy );
				if( dlg.DoModal() )
				{
					GEditor->Exec( *FString::Printf(TEXT("BRUSH SCALE X=%f, Y=%f, Z=%f"), Proxy->X, Proxy->Y, Proxy->Z ) );
					GEditor->RedrawLevel( GEditor->Level );
				}
			}
			break;

			case ID_BrushAdd:
			{
				GEditor->Exec( TEXT("BRUSH ADD") );
				GEditor->RedrawLevel( GEditor->Level );
			}
			break;

			case ID_BrushSubtract:
			{
				GEditor->Exec( TEXT("BRUSH SUBTRACT") );
				GEditor->RedrawLevel( GEditor->Level );
			}
			break;

			case ID_BrushIntersect:
			{
				GEditor->Exec( TEXT("BRUSH FROM INTERSECTION") );
				GEditor->RedrawLevel( GEditor->Level );
			}
			break;

			case ID_BrushDeintersect:
			{
				GEditor->Exec( TEXT("BRUSH FROM DEINTERSECTION") );
				GEditor->RedrawLevel( GEditor->Level );
			}
			break;

			case ID_BrushAddMover:
			{
				GEditor->Exec( TEXT("BRUSH ADDMOVER") );
				GEditor->RedrawLevel( GEditor->Level );
			}
			break;

			case ID_BrushAddSpecial:
			{
				if( !GDlgAddSpecial )
				{
					GDlgAddSpecial = new WDlgAddSpecial( NULL, GEditorFrame );
					GDlgAddSpecial->DoModeless();
				}
				else
					GDlgAddSpecial->Show(1);
			}
			break;

			case ID_BrushOpen:
			{
				OPENFILENAMEA ofn;
				char File[8192] = "\0";

				ZeroMemory(&ofn, sizeof(OPENFILENAMEA));
				ofn.lStructSize = sizeof(OPENFILENAMEA);
				ofn.hwndOwner = hWnd;
				ofn.lpstrFile = File;
				ofn.nMaxFile = sizeof(char) * 8192;
				ofn.lpstrFilter = "Brushes (*.u3d)\0*.u3d\0All Files\0*.*\0\0";
				ofn.lpstrInitialDir = "..\\maps";
				ofn.lpstrDefExt = "u3d";
				ofn.lpstrTitle = "Open Brush";
				ofn.Flags = OFN_HIDEREADONLY | OFN_NOCHANGEDIR;

				// Display the Open dialog box. 
				if( GetOpenFileNameA(&ofn) )
				{
					GEditor->Exec( *(FString::Printf(TEXT("BRUSH LOAD FILE=\"%s\""), appFromAnsi( File ))));
					GEditor->RedrawLevel( GEditor->Level );
				}

				GFileManager->SetDefaultDirectory(appBaseDir());
				GButtonBar->RefreshBuilders();
				RefreshOptionProxies();
			}
			break;

			case ID_BrushSaveAs:
			{
				OPENFILENAMEA ofn;
				char File[8192] = "\0";

				ZeroMemory(&ofn, sizeof(OPENFILENAMEA));
				ofn.lStructSize = sizeof(OPENFILENAMEA);
				ofn.hwndOwner = hWnd;
				ofn.lpstrFile = File;
				ofn.nMaxFile = sizeof(char) * 8192;
				ofn.lpstrFilter = "Brushes (*.u3d)\0*.u3d\0All Files\0*.*\0\0";
				ofn.lpstrInitialDir = "..\\maps";
				ofn.lpstrDefExt = "u3d";
				ofn.lpstrTitle = "Save Brush";
				ofn.Flags = OFN_HIDEREADONLY | OFN_NOCHANGEDIR | OFN_OVERWRITEPROMPT;

				if( GetSaveFileNameA(&ofn) )
					GEditor->Exec( *(FString::Printf(TEXT("BRUSH SAVE FILE=\"%s\""), appFromAnsi( File ))));

				GFileManager->SetDefaultDirectory(appBaseDir());
			}
			break;

			case ID_BRUSH_IMPORT:
			{
				OPENFILENAMEA ofn;
				char File[8192] = "\0";

				ZeroMemory(&ofn, sizeof(OPENFILENAMEA));
				ofn.lStructSize = sizeof(OPENFILENAMEA);
				ofn.hwndOwner = hWnd;
				ofn.lpstrFile = File;
				ofn.nMaxFile = sizeof(char) * 8192;
				ofn.lpstrFilter = "Import Types (*.t3d, *.dxf, *.asc, *.ase)\0*.t3d;*.dxf;*.asc;*.ase;\0All Files\0*.*\0\0";
				ofn.lpstrInitialDir = appToAnsi( *(GLastDir[eLASTDIR_BRUSH]) );
				ofn.lpstrDefExt = "t3d";
				ofn.lpstrTitle = "Import Brush";
				ofn.Flags = OFN_HIDEREADONLY | OFN_NOCHANGEDIR;

				// Display the Open dialog box. 
				if( GetOpenFileNameA(&ofn) )
				{
					WDlgBrushImport l_dlg( NULL, this );
					l_dlg.DoModal( appFromAnsi( File ) );
					GEditor->RedrawLevel( GEditor->Level );

					FString S = appFromAnsi( File );
					GLastDir[eLASTDIR_BRUSH] = S.Left( S.InStr( TEXT("\\"), 1 ) );
				}

				GFileManager->SetDefaultDirectory(appBaseDir());
				GButtonBar->RefreshBuilders();
				RefreshOptionProxies();
			}
			break;

			case ID_BRUSH_EXPORT:
			{
				OPENFILENAMEA ofn;
				char File[8192] = "\0";

				ZeroMemory(&ofn, sizeof(OPENFILENAMEA));
				ofn.lStructSize = sizeof(OPENFILENAMEA);
				ofn.hwndOwner = hWnd;
				ofn.lpstrFile = File;
				ofn.nMaxFile = sizeof(char) * 8192;
				ofn.lpstrFilter = "Unreal Engine Text (*.t3d)\0*.t3d\0All Files\0*.*\0\0";
				ofn.lpstrInitialDir = appToAnsi( *(GLastDir[eLASTDIR_BRUSH]) );
				ofn.lpstrDefExt = "t3d";
				ofn.lpstrTitle = "Export Brush";
				ofn.Flags = OFN_HIDEREADONLY | OFN_NOCHANGEDIR | OFN_OVERWRITEPROMPT;

				if( GetSaveFileNameA(&ofn) )
				{
					GEditor->Exec( *(FString::Printf(TEXT("BRUSH EXPORT FILE=\"%s\""), appFromAnsi( File ))));

					FString S = appFromAnsi( File );
					GLastDir[eLASTDIR_BRUSH] = S.Left( S.InStr( TEXT("\\"), 1 ) );
				}

				GFileManager->SetDefaultDirectory(appBaseDir());
				GButtonBar->RefreshBuilders();
				RefreshOptionProxies();
			}
			break;

			case ID_BuildPlay:
			{

				//GBrowserMaster->HideAllBrowsers();

				GEditor->Exec(TEXT("HOOK PLAYMAP"));
			}
			break;

			case ID_BuildGeometry:
			{
				((WPageOptions*)GBuildSheet->PropSheet->Pages(0))->BuildGeometry();
				GBuildSheet->PropSheet->RefreshPages();
			}
			break;

			case ID_BuildLighting:
			{
				((WPageOptions*)GBuildSheet->PropSheet->Pages(0))->BuildLighting();
				GBuildSheet->PropSheet->RefreshPages();
			}
			break;

			case ID_BuildPaths:
			{
				((WPageOptions*)GBuildSheet->PropSheet->Pages(0))->BuildPaths();
				GBuildSheet->PropSheet->RefreshPages();
			}
			break;

			case ID_BuildAll:
			{
				((WPageOptions*)GBuildSheet->PropSheet->Pages(0))->OnBuildClick();
				GBuildSheet->PropSheet->RefreshPages();
			}
			break;

			case ID_BuildOptions:
			{
				GBuildSheet->Show( TRUE );
			}
			break;

			case ID_ToolsLog:
			{
				if( GLogWindow )
				{
					GLogWindow->Show(1);
					SetFocus( *GLogWindow );
					GLogWindow->Display.ScrollCaret();
				}
			}
			break;

			case ID_Tools2DEditor:
			{
				SafeDelete(G2DShapeEditor);

				G2DShapeEditor = new W2DShapeEditor( TEXT("2D Shape Editor"), this );
				G2DShapeEditor->OpenWindow();
			}
			break;

			case ID_ViewNewFree:
			{
				if( GViewportStyle == VSTYLE_Floating )
					GLevelFrame->OpenFrameViewport( REN_OrthXY, 0, 0, 320, 200, SHOW_Menu | SHOW_Frame | SHOW_Actors | SHOW_Brush | SHOW_StandardView | SHOW_ChildWindow | SHOW_MovingBrushes | SHOW_HardwareBrushes );
			}
			break;

			case IDMN_VIEWPORT_CLOSEALL:
			{
				for( INT x = 0 ; x < GViewports.Num() ; x++)
					SafeDelete(GViewports(x).m_pViewportFrame);

				GViewports.Empty();
			}
			break;

			case IDMN_VIEWPORT_FLOATING:
			{
				GViewportStyle = VSTYLE_Floating;
				UpdateMenu();
				GLevelFrame->ChangeViewportStyle();
			}
			break;

			case IDMN_VIEWPORT_FIXED:
			{
				GViewportStyle = VSTYLE_Fixed;
				UpdateMenu();
				GLevelFrame->ChangeViewportStyle();
			}
			break;

			case IDMN_VIEWPORT_CONFIG:
			{
				WDlgViewportConfig l_dlg( NULL, this );
				if( l_dlg.DoModal( GViewportConfig ) )
					GLevelFrame->CreateNewViewports( GViewportStyle, l_dlg.ViewportConfig );
				GEditor->RedrawLevel( GEditor->Level );
			}
			break;

			case ID_ToolsPrefs:
			{
				if( !Preferences )
				{
					Preferences = new WConfigProperties( TEXT("Preferences"), LocalizeGeneral(TEXT("AdvancedOptionsTitle"),TEXT("Window")) );
					Preferences->OpenWindow( *this );
					Preferences->SetNotifyHook( this );
					Preferences->ForceRefresh();
				}
				Preferences->Show(1);
			}
			break;

			case WM_EDC_SAVEMAP:
			{
				FileSave( hWnd );
			}
			break;

			case WM_EDC_SAVEMAPAS:
			{
				FileSaveAs( hWnd );
			}
			break;
 
			case WM_BROWSER_DOCK:
			{
				INT Browsr = LastlParam;
				switch( Browsr )
				{
					case eBROWSER_ACTOR:
						SafeDelete(GBrowserActor);
						GBrowserActor = new WBrowserActor( TEXT("Actor Browser"), GBrowserMaster, GEditorFrame->hWnd );
						check(GBrowserActor);
						GBrowserActor->OpenWindow( 1 );
						GBrowserMaster->ShowBrowser(eBROWSER_ACTOR);
						break;

					case eBROWSER_GROUP:
						SafeDelete(GBrowserGroup); 
						GBrowserGroup = new WBrowserGroup( TEXT("Group Browser"), GBrowserMaster, GEditorFrame->hWnd );
						check(GBrowserGroup);
						GBrowserGroup->OpenWindow( 1 );
						GBrowserMaster->ShowBrowser(eBROWSER_GROUP);
						break;

					case eBROWSER_MUSIC:
						SafeDelete(GBrowserMusic);
						GBrowserMusic = new WBrowserMusic( TEXT("Music Browser"), GBrowserMaster, GEditorFrame->hWnd );
						check(GBrowserMusic);
						GBrowserMusic->OpenWindow( 1 );
						GBrowserMaster->ShowBrowser(eBROWSER_MUSIC);
						break;

					case eBROWSER_SOUND:
						SafeDelete(GBrowserSound);
						GBrowserSound = new WBrowserSound( TEXT("Sound Browser"), GBrowserMaster, GEditorFrame->hWnd );
						check(GBrowserSound);
						GBrowserSound->OpenWindow( 1 );
						GBrowserMaster->ShowBrowser(eBROWSER_SOUND);
						break;

					case eBROWSER_TEXTURE:
						SafeDelete(GBrowserTexture);
						GBrowserTexture = new WBrowserTexture( TEXT("Texture Browser"), GBrowserMaster, GEditorFrame->hWnd );
						check(GBrowserTexture);
						GBrowserTexture->OpenWindow( 1 );
						GBrowserMaster->ShowBrowser(eBROWSER_TEXTURE);
						break;

					case eBROWSER_MESH:
						SafeDelete(GBrowserMesh);
						GBrowserMesh = new WBrowserMesh( TEXT("Mesh Browser"), GBrowserMaster, GEditorFrame->hWnd );
						check(GBrowserMesh);	// NJS: Sanity.	
						GBrowserMesh->OpenWindow( 1 );
						GBrowserMaster->ShowBrowser(eBROWSER_MESH);
						break;
				}
			}
			break;

			case WM_BROWSER_UNDOCK:
			{
				INT Browsr = LastlParam;
				switch( Browsr )
				{
					case eBROWSER_ACTOR:
						SafeDelete(GBrowserActor);
						GBrowserActor = new WBrowserActor( TEXT("Actor Browser"), GEditorFrame, GEditorFrame->hWnd );
						check(GBrowserActor);
						GBrowserActor->OpenWindow( 0 );
						GBrowserMaster->ShowBrowser(eBROWSER_ACTOR);
						break;

					case eBROWSER_GROUP:
						SafeDelete(GBrowserGroup);
						GBrowserGroup = new WBrowserGroup( TEXT("Group Browser"), GEditorFrame, GEditorFrame->hWnd );
						check(GBrowserGroup);
						GBrowserGroup->OpenWindow( 0 );
						GBrowserMaster->ShowBrowser(eBROWSER_GROUP);
						break;

					case eBROWSER_MUSIC:
						SafeDelete(GBrowserMusic);
						GBrowserMusic = new WBrowserMusic( TEXT("Music Browser"), GEditorFrame, GEditorFrame->hWnd );
						check(GBrowserMusic);
						GBrowserMusic->OpenWindow( 0 );
						GBrowserMaster->ShowBrowser(eBROWSER_MUSIC);
						break;

					case eBROWSER_SOUND:
						SafeDelete(GBrowserSound);
						GBrowserSound = new WBrowserSound( TEXT("Sound Browser"), GEditorFrame, GEditorFrame->hWnd );
						check(GBrowserSound);
						GBrowserSound->OpenWindow( 0 );
						GBrowserMaster->ShowBrowser(eBROWSER_SOUND);
						break;

					case eBROWSER_TEXTURE:
						SafeDelete(GBrowserTexture);
						GBrowserTexture = new WBrowserTexture( TEXT("Texture Browser"), GEditorFrame, GEditorFrame->hWnd );
						check(GBrowserTexture);
						GBrowserTexture->OpenWindow( 0 );
						GBrowserMaster->ShowBrowser(eBROWSER_TEXTURE);
						break;

					case eBROWSER_MESH:
						SafeDelete(GBrowserMesh);
						GBrowserMesh = new WBrowserMesh( TEXT("Mesh Browser"), GEditorFrame, GEditorFrame->hWnd );
						if(!GBrowserMesh) appErrorf(TEXT("Failed to new GBrowserMesh"));
						//check(GBrowserMesh);
						GBrowserMesh->OpenWindow( 0 );
						GBrowserMaster->ShowBrowser(eBROWSER_MESH);
						break;
				}

				GBrowserMaster->RefreshBrowserTabs( -1 );
			}
			break;

			case WM_EDC_CAMMODECHANGE:
			{
				if( GButtonBar )
				{
					GButtonBar->UpdateButtons();
					GBottomBar->UpdateButtons();
					GTopBar->UpdateButtons();
				}
			}
			break;

			case WM_EDC_LOADMAP:
			{
				FileOpen( hWnd );
			}
			break;

			case WM_EDC_PLAYMAP:
			{
				GEditor->Exec( TEXT("HOOK PLAYMAP") );
			}
			break;

			case WM_EDC_BROWSE:
			{
				*GetPropResult = FStringOutputDevice();
				GEditor->Get( TEXT("OBJ"), TEXT("BROWSECLASS"), *GetPropResult );

				if( !appStrcmp( **GetPropResult, TEXT("Texture") ) )
					GBrowserMaster->ShowBrowser(eBROWSER_TEXTURE);

				if( !appStrcmp( **GetPropResult, TEXT("Palette") ) )
					GBrowserMaster->ShowBrowser(eBROWSER_TEXTURE);

				if( !appStrcmp( **GetPropResult, TEXT("Sound") ) )
					GBrowserMaster->ShowBrowser(eBROWSER_SOUND);

				if( !appStrcmp( **GetPropResult, TEXT("Music") ) )
					GBrowserMaster->ShowBrowser(eBROWSER_MUSIC);

				if( !appStrcmp( **GetPropResult, TEXT("Class") ) )
					GBrowserMaster->ShowBrowser(eBROWSER_ACTOR);

				if( !appStrcmp( **GetPropResult, TEXT("Mesh") ) )
					GBrowserMaster->ShowBrowser(eBROWSER_MESH);
					
			}
			break;

			case WM_EDC_USECURRENT:
			{
				*GetPropResult = FStringOutputDevice();
				GEditor->Get( TEXT("OBJ"), TEXT("BROWSECLASS"), *GetPropResult );

				FString Cur;

				if( !appStrcmp( **GetPropResult, TEXT("Palette") ) )
					if( GEditor->CurrentTexture )
						Cur = GEditor->CurrentTexture->Palette->GetPathName();

				if( !appStrcmp( **GetPropResult, TEXT("Texture") ) )
					if( GEditor->CurrentTexture )
						Cur = GEditor->CurrentTexture->GetPathName();

				if( !appStrcmp( **GetPropResult, TEXT("Sound") ) )
					if( GBrowserSound )
						Cur = *GBrowserSound->GetCurrentPathName();

				if( !appStrcmp( **GetPropResult, TEXT("Music") ) )
					if( GBrowserMusic )
						Cur = *GBrowserMusic->GetCurrentPathName();

				if( !appStrcmp( **GetPropResult, TEXT("Class") ) )
					if( GEditor->CurrentClass )
						Cur = GEditor->CurrentClass->GetPathName();

				if( !appStrcmp( **GetPropResult, TEXT("Mesh") ) )
					if( GBrowserMesh )
						Cur = GBrowserMesh->GetCurrentMeshName();

				if( Cur.Len() )
					GEditor->Set( TEXT("OBJ"), TEXT("NOTECURRENT"), *(FString::Printf(TEXT("CLASS=%s OBJECT=%s"), **GetPropResult, *Cur)));
			}
			break;

			case WM_EDC_CURTEXCHANGE:
			{
				if( GBrowserMaster->CurrentBrowser == eBROWSER_TEXTURE )
				{
					GBrowserTexture->SetCaption();
					GBrowserTexture->pViewport->Repaint(1);
				}
			}
			break;

			case WM_EDC_SELPOLYCHANGE:
			case WM_EDC_SELCHANGE:
			{
				GSurfPropSheet->PropSheet->RefreshPages();
			}
			break;

			case WM_EDC_RTCLICKTEXTURE:
			{
				POINT pt;
				::GetCursorPos( &pt );
				TrackPopupMenu( GetSubMenu( TexturePopupMenu, 0 ),
					TPM_LEFTALIGN | TPM_TOPALIGN | TPM_RIGHTBUTTON,
					pt.x, pt.y, 0,
					GBrowserTexture->hWnd, NULL);
			}
			break;

			case WM_EDC_RTCLICKPOLY:
			{
				POINT l_point;

				::GetCursorPos( &l_point );
//				HMENU l_menu = GetSubMenu( LoadMenuIdX(hInstance, IDMENU_SurfPopup), 0 );
				HMENU l_menu = GetSubMenu( SurfPopupMenu, 0 );

				// Customize the menu options we need to.
				MENUITEMINFOA mif;
				char l_ch[255];

				mif.cbSize = sizeof(MENUITEMINFO);
				mif.fMask = MIIM_TYPE;
				mif.fType = MFT_STRING;

				FGetInfoRet gir = GetInfo( GEditor->Level, GI_NUM_SURF_SELECTED );

				sprintf( l_ch, "Surface &Properties (%i Selected)\tF5", gir.iValue );
				mif.dwTypeData = l_ch;
				SetMenuItemInfoA( l_menu, ID_SurfProperties, FALSE, &mif );

				// Add special options for macrotizing trigger light creation.
				AddTriggerLightMacros( l_menu );

				if( GEditor->CurrentClass )
				{
					debugf(_T("GEditor->CurrentClass set (%i)"),__LINE__);

					sprintf( l_ch, "&Add %s Here", TCHAR_TO_ANSI( GEditor->CurrentClass->GetName() ) );
					mif.dwTypeData = l_ch;
					SetMenuItemInfoA( l_menu, ID_SurfPopupAddClass, FALSE, &mif );
				}
				else 
				{
					debugf(_T("GEditor->CurrentClass not set (%i)"),__LINE__);

					DeleteMenu( l_menu, ID_SurfPopupAddClass, MF_BYCOMMAND );
				}

				if( GEditor->CurrentTexture )
				{
					sprintf( l_ch, "&Apply Texture : %s", TCHAR_TO_ANSI( GEditor->CurrentTexture->GetName() ) );
					mif.dwTypeData = l_ch;
					SetMenuItemInfoA( l_menu, ID_SurfPopupApplyTexture, FALSE, &mif );
				}

				TrackPopupMenu( l_menu,
					TPM_LEFTALIGN | TPM_TOPALIGN | TPM_RIGHTBUTTON,
					l_point.x, l_point.y, 0,
					hWnd, NULL);
			}
			break;

			case WM_EDC_RTCLICKACTOR:
			{
				POINT l_point;

				::GetCursorPos( &l_point );
				HMENU l_menu = GetSubMenu( LoadMenuIdX(hInstance, IDMENU_ActorPopup), 0 );
//				HMENU l_menu = GetSubMenu( ActorPopupMenu, 0 );

				// Customize the menu options we need to.
				MENUITEMINFOA mif;
				char l_ch[255];

				mif.cbSize = sizeof(MENUITEMINFO);
				mif.fMask = MIIM_TYPE;
				mif.fType = MFT_STRING;

				FGetInfoRet gir = GetInfo( GEditor->Level, GI_NUM_SELECTED | GI_CLASSNAME_SELECTED | GI_CLASS_SELECTED );

				sprintf( l_ch, "%s &Properties (%i Selected)", TCHAR_TO_ANSI( *gir.String ), gir.iValue );
				mif.dwTypeData = l_ch;
				SetMenuItemInfoA( l_menu, IDMENU_ActorPopupProperties, FALSE, &mif );

				sprintf( l_ch, "&Select All %s", TCHAR_TO_ANSI( *gir.String ) );
				mif.dwTypeData = l_ch;
				SetMenuItemInfoA( l_menu, IDMENU_ActorPopupSelectAllClass, FALSE, &mif );

				EnableMenuItem( l_menu, IDMENU_ActorPopupEditScript, (gir.pClass == NULL) );
				EnableMenuItem( l_menu, IDMENU_ActorPopupMakeCurrent, (gir.pClass == NULL) );

				TrackPopupMenu( l_menu,
					TPM_LEFTALIGN | TPM_TOPALIGN | TPM_RIGHTBUTTON,
					l_point.x, l_point.y, 0,
					hWnd, NULL);
			}
			break;

			case WM_EDC_RTCLICKWINDOW:
			case WM_EDC_RTCLICKWINDOWCANADD:
			{
				debugf(_T("***** RtClickWindowCanADD"));

				POINT l_point;

				::GetCursorPos( &l_point );
				HMENU l_menu = GetSubMenu( LoadMenuIdX(hInstance, IDMENU_BackdropPopup), 0 );
//				HMENU l_menu = GetSubMenu( BackdropPopupMenu, 0 );

				// Customize the menu options we need to.
				MENUITEMINFOA mif;
				char l_ch[255];

				mif.cbSize = sizeof(MENUITEMINFO);
				mif.fMask = MIIM_TYPE;
				mif.fType = MFT_STRING;

				if( GEditor->CurrentClass )
				{
					debugf(_T("GEditor->CurrentClass set"));
					sprintf( l_ch, "&Add %s here", TCHAR_TO_ANSI( GEditor->CurrentClass->GetName() ) );
					mif.dwTypeData = l_ch;
					SetMenuItemInfoA( l_menu, ID_BackdropPopupAddClassHere, FALSE, &mif );
				}
				else 
				{
					debugf(_T("GEditor->CurrentClass not set"));
					DeleteMenu( l_menu, ID_BackdropPopupAddClassHere, MF_BYCOMMAND );
				}

				// Put special options at the top of the menu depending on the mode the editor is in.
				mif.fMask = MIIM_TYPE | MIIM_ID;
				switch( GEditor->Mode )
				{
					case EM_Polygon:
						mif.fType = MFT_SEPARATOR;
						InsertMenuItemA( l_menu, 0, TRUE, &mif );

						mif.fType = MFT_STRING;
						mif.dwTypeData = "CREATE BRUSH";
						mif.wID = IDMENU_ModeSpecific_CreateBrush;
						InsertMenuItemA( l_menu, 0, TRUE, &mif );
						break;
				}

				TrackPopupMenu( l_menu,
					TPM_LEFTALIGN | TPM_TOPALIGN | TPM_RIGHTBUTTON,
					l_point.x, l_point.y, 0,
					hWnd, NULL);
			}
			break;

			case WM_EDC_MAPCHANGE:
			{
			}
			break;

			case WM_EDC_VIEWPORTUPDATEWINDOWFRAME:
			{
				GLevelFrame->RedrawAllViewports();
			}
			break;

			case WM_EDC_VIEWPORTSDISABLEREALTIME:
			{
				// Loop through all viewports and disable any realtime viewports before running the game.
				for( INT x = 0 ; x < GViewports.Num() ; x++)
				{
					if(GViewports(x).m_pViewportFrame)
						if(GViewports(x).m_pViewportFrame->m_pViewport)
							if(GViewports(x).m_pViewportFrame->m_pViewport->Actor)
								GViewports(x).m_pViewportFrame->m_pViewport->Actor->ShowFlags &= ~SHOW_PlayerCtrl;
				}
				GLevelFrame->RedrawAllViewports();
			}
			break;

			case WM_EDC_FLUSHALLVIEWPORTS:
			{
				FlushAllViewports();
			}
			break;

			case WM_EDC_SURFPROPS:
			{
				GSurfPropSheet->Show( TRUE );
			}
			break;

			case WM_EDC_MASTERBROWSER:
			{
				GBrowserMaster->Show(!GBrowserMaster->m_bShow);
			}
			break;

			case WM_EDC_CONFIRMDELETE:
			{
//				if ( IDYES == MessageBox( (HWND)GEditor->Client->Viewports(0)->GetWindow(), TEXT("Are you sure you want to delete?"), TEXT("Confirm Delete"), MB_YESNO | MB_ICONWARNING | MB_DEFBUTTON2 ) )
//					GEditor->Exec( TEXT("ACTOR DELETE") );	
			}
			break;

			//
			// BACKDROP POPUP
			//

			// Root
			case ID_BackdropPopupAddClassHere:
			{
				GEditor->Exec( *(FString::Printf( TEXT("ACTOR ADD CLASS=%s"), GEditor->CurrentClass->GetName() ) ) );
				GEditor->Exec( TEXT("POLY SELECT NONE") );
			}
			break;

			case ID_BackdropPopupAddLightHere:
			{
				GEditor->Exec( TEXT("ACTOR ADD CLASS=LIGHT") );
				GEditor->Exec( TEXT("POLY SELECT NONE") );
			}
			break;

			case ID_BackdropPopupLevelProperties:
			{
				if( !GEditor->LevelProperties )
				{
					GEditor->LevelProperties = new WObjectProperties( TEXT("LevelProperties"), CPF_Edit, TEXT("Level Properties"), NULL, 1 );
					GEditor->LevelProperties->OpenWindow( hWnd );
					GEditor->LevelProperties->SetNotifyHook( GEditor );
				}
				GEditor->LevelProperties->Root.SetObjects( (UObject**)&GEditor->Level->Actors(0), 1 );
				GEditor->LevelProperties->Show(1);
			}
			break;

			// Grid
			case ID_BackdropPopupGrid1:
			{
				GEditor->Exec( TEXT("MAP GRID X=1 Y=1 Z=1") );
			}
			break;

			case ID_BackdropPopupGrid2:
			{
				GEditor->Exec( TEXT("MAP GRID X=2 Y=2 Z=2") );
			}
			break;

			case ID_BackdropPopupGrid4:
			{
				GEditor->Exec( TEXT("MAP GRID X=4 Y=4 Z=4") );
			}
			break;

			case ID_BackdropPopupGrid8:
			{
				GEditor->Exec( TEXT("MAP GRID X=8 Y=8 Z=8") );
			}
			break;

			case ID_BackdropPopupGrid16:
			{
				GEditor->Exec( TEXT("MAP GRID X=16 Y=16 Z=16") );
			}
			break;

			case ID_BackdropPopupGrid32:
			{
				GEditor->Exec( TEXT("MAP GRID X=32 Y=32 Z=32") );
			}
			break;

			case ID_BackdropPopupGrid64:
			{
				GEditor->Exec( TEXT("MAP GRID X=64 Y=64 Z=64") );
			}
			break;

			case ID_BackdropPopupGrid128:
			{
				GEditor->Exec( TEXT("MAP GRID X=128 Y=128 Z=128") );
			}
			break;

			case ID_BackdropPopupGrid256:
			{
				GEditor->Exec( TEXT("MAP GRID X=256 Y=256 Z=256") );
			}
			break;

			// Pivot
			case ID_BackdropPopupPivotSnapped:
			{
				GEditor->Exec( TEXT("PIVOT SNAPPED") );
			}
			break;

			case ID_BackdropPopupPivot:
			{
				GEditor->Exec( TEXT("PIVOT HERE") );
			}
			break;

			//
			// SURFACE POPUP MENU
			//

			// Root
			case ID_SurfProperties:
			{
				GSurfPropSheet->Show( TRUE );
			}
			break;

			case ID_SurfPopupBuildTriggerLight:
			{
				GLog->Logf( TEXT("----- Macrotizing Trigger Light Creation -----") );

				// Find a unique name to give this trigger light.
				INT MaxEdTrigLightNum = 0;
				FString TrigLightTag = FString::Printf( TEXT("EdTrigLight") );

				// Check actors for a free number.
				for( INT i=0; i<GEditor->Level->Actors.Num(); i++ )
				{
					AActor* pActor = GEditor->Level->Actors(i);

					if ( pActor )
					{
						FString ActorTag = *(pActor->Tag);
						TCHAR* str = appStrstr( *ActorTag, *TrigLightTag );
						if ( str && (ActorTag.Len() > TrigLightTag.Len()) )
						{
							// This actor has been made into a trigger light.
							FString StrLightNum = ActorTag.Right( ActorTag.Len() - TrigLightTag.Len() );
							TCHAR* End;
							INT LightNum = appStrtoi( *StrLightNum, &End, 10 );
							GLog->Logf( TEXT("Found trigger light of number %i."), LightNum );
							if ( LightNum >= MaxEdTrigLightNum )
								MaxEdTrigLightNum = LightNum+1;
						}
					}
				}

				// Check surfaces for a free number.
				for ( i=0; i<GEditor->Level->Model->Surfs.Num(); i++ )
				{
					FBspSurf* Surf = &GEditor->Level->Model->Surfs(i);
					if ( Surf )
					{
						FString SurfTag = *(Surf->SurfaceTag);
						TCHAR* str = appStrstr( *SurfTag, *TrigLightTag );
						if ( str && (SurfTag.Len() > TrigLightTag.Len()) )
						{
							// This surf has been made into a trigger light.
							FString StrLightNum = SurfTag.Right( SurfTag.Len() - TrigLightTag.Len() );
							TCHAR* End;
							INT LightNum = appStrtoi( *StrLightNum, &End, 10 );
							GLog->Logf( TEXT("Found surface light tag of number %i."), LightNum );
							if ( LightNum >= MaxEdTrigLightNum )
								MaxEdTrigLightNum = LightNum+1;
						}
					}
				}

				FString FinalTag = FString::Printf( TEXT("%s%i"), *TrigLightTag, MaxEdTrigLightNum );
				GLog->Logf( TEXT("Assigning tag %s for macroed TriggerLight setup."), *FinalTag );

				// Assign the correct values to selected TriggerLight actors.
				for( i=0; i<GEditor->Level->Actors.Num(); i++ )
				{
					AActor* pActor = GEditor->Level->Actors(i);

					if ( pActor && pActor->bSelected && pActor->IsA(ATriggerLight::StaticClass()) )
					{
						GLog->Logf( TEXT("Working on TriggerLight %s"), pActor->GetName() );
						ATriggerLight* pLight = Cast<ATriggerLight>(pActor);
						pLight->Tag = FName( *FinalTag );
						pLight->bInitiallyOn = TRUE;
						pLight->InitialState = FName( TEXT("TriggerToggle") );
					}
				}

				// Asssign the correct tag to selected surfaces.
				for ( i=0; i<GEditor->Level->Model->Surfs.Num(); i++ )
				{
					FBspSurf* Surf = &GEditor->Level->Model->Surfs(i);
					if ( Surf && (Surf->PolyFlags & PF_Selected) )
					{
						GLog->Logf( TEXT("Working on a selected surface.") );
						Surf->SurfaceTag = FName( *FinalTag );
					}
				}

				GLog->Logf( TEXT("------------------ Finished ------------------") );
			}
			break;

			case ID_SurfPopupBevel:
			{
				UOptionsSurfBevel* Proxy = Cast<UOptionsSurfBevel>(GProxies(PROXY_OPTIONSSURFBEVEL));
				WDlgGeneric dlg( NULL, this, Proxy );
				if( dlg.DoModal() )
					GEditor->Exec( *FString::Printf(TEXT("POLY BEVEL DEPTH=%d BEVEL=%d"), Proxy->Depth, Proxy->Bevel ) );
			}
			break;

			case ID_SurfPopupExtrude16:
				GEditor->Exec( TEXT("POLY EXTRUDE DEPTH=16") );
				break;
			case ID_SurfPopupExtrude32:
				GEditor->Exec( TEXT("POLY EXTRUDE DEPTH=32") );
				break;
			case ID_SurfPopupExtrude64:
				GEditor->Exec( TEXT("POLY EXTRUDE DEPTH=64") );
				break;
			case ID_SurfPopupExtrude128:
				GEditor->Exec( TEXT("POLY EXTRUDE DEPTH=128") );
				break;
			case ID_SurfPopupExtrude256:
				GEditor->Exec( TEXT("POLY EXTRUDE DEPTH=256") );
				break;
			case ID_SurfPopupExtrudeCustom:
			{
				WDlgDepth dlg( NULL, this );
				if( dlg.DoModal() )
				{
					GEditor->Exec( *FString::Printf(TEXT("POLY EXTRUDE DEPTH=%d"), dlg.Depth ) );
				}
			}
			break;

			case ID_SurfPopupAddClass:
			{
				if( GEditor->CurrentClass )
				{
					GEditor->Exec( *(FString::Printf(TEXT("ACTOR ADD CLASS=%s"), GEditor->CurrentClass->GetName())));
					GEditor->Exec( TEXT("POLY SELECT NONE") );
				}
			}
			break;

			case ID_SurfPopupAddLight:
			{
				GEditor->Exec( TEXT("ACTOR ADD CLASS=LIGHT") );
				GEditor->Exec( TEXT("POLY SELECT NONE") );
			}
			break;

			case ID_SurfPopupApplyTexture:
			{
				GEditor->Exec( TEXT("POLY SETTEXTURE") );
			}
			break;

			// Align Selected
			case ID_SurfPopupAlignPlanarAuto:
			{
				GSurfPropSheet->AlignmentPage->Align( TEXALIGN_PlanarAuto );
			}
			break;

			case ID_SurfPopupAlignPlanarWall:
			{
				GSurfPropSheet->AlignmentPage->Align( TEXALIGN_PlanarWall );
			}
			break;

			case ID_SurfPopupAlignPlanarFloor:
			{
				GSurfPropSheet->AlignmentPage->Align( TEXALIGN_PlanarFloor );
			}
			break;

			case ID_SurfPopupAlignWallDir:
			{
				GSurfPropSheet->AlignmentPage->Align( TEXALIGN_WallDir );
			}
			break;

			case ID_SurfPopupAlignCylinder:
			{
				GSurfPropSheet->AlignmentPage->Align( TEXALIGN_Cylinder );
			}
			break;

			case ID_SurfPopupAlignFace:
			{
				GSurfPropSheet->AlignmentPage->Align( TEXALIGN_Face );
			}
			break;

			case ID_SurfPopupUnalign:
			{
				GSurfPropSheet->AlignmentPage->Align( TEXALIGN_Default );
			}
			break;

			// Select Surfaces
			case ID_SurfPopupSelectMatchingGroups:
			{
				GEditor->Exec( TEXT("POLY SELECT MATCHING GROUPS") );
			}
			break;

			case ID_SurfPopupSelectMatchingItems:
			{
				GEditor->Exec( TEXT("POLY SELECT MATCHING ITEMS") );
			}
			break;

			case ID_SurfPopupSelectMatchingBrush:
			{
				GEditor->Exec( TEXT("POLY SELECT MATCHING BRUSH") );
			}
			break;

			case ID_SurfPopupSelectMatchingTexture:
			{
				GEditor->Exec( TEXT("POLY SELECT MATCHING TEXTURE") );
			}
			break;

			case ID_SurfPopupSelectAllAdjacents:
			{
				GEditor->Exec( TEXT("POLY SELECT ADJACENT ALL") );
			}
			break;

			case ID_SurfPopupSelectAdjacentCoplanars:
			{
				GEditor->Exec( TEXT("POLY SELECT ADJACENT COPLANARS") );
			}
			break;

			case ID_SurfPopupSelectAdjacentWalls:
			{
				GEditor->Exec( TEXT("POLY SELECT ADJACENT WALLS") );
			}
			break;

			case ID_SurfPopupSelectAdjacentFloors:
			{
				GEditor->Exec( TEXT("POLY SELECT ADJACENT FLOORS") );
			}
			break;

			case ID_SurfPopupSelectAdjacentSlants:
			{
				GEditor->Exec( TEXT("POLY SELECT ADJACENT SLANTS") );
			}
			break;

			case ID_SurfPopupSelectReverse:
			{
				GEditor->Exec( TEXT("POLY SELECT REVERSE") );
			}
			break;

			case ID_SurfPopupMemorize:
			{
				GEditor->Exec( TEXT("POLY SELECT MEMORY SET") );
			}
			break;

			case ID_SurfPopupRecall:
			{
				GEditor->Exec( TEXT("POLY SELECT MEMORY RECALL") );
			}
			break;

			case ID_SurfPopupOr:
			{
				GEditor->Exec( TEXT("POLY SELECT MEMORY INTERSECTION") );
			}
			break;

			case ID_SurfPopupAnd:
			{
				GEditor->Exec( TEXT("POLY SELECT MEMORY UNION") );
			}
			break;

			case ID_SurfPopupXor:
			{
				GEditor->Exec( TEXT("POLY SELECT MEMORY XOR") );
			}
			break;


			//
			// ACTOR POPUP MENU
			//

			// Root
			case IDMENU_ModeSpecific_CreateBrush:
			{
				TArray<FVector> PolyMarkers;

				for( INT i = 0 ; i < GEditor->Level->Actors.Num() ; i++ )
				{
					AActor* pActor = GEditor->Level->Actors(i);
					if( pActor && pActor->IsA(APolyMarker::StaticClass()) )
						new(PolyMarkers)FVector(pActor->Location);
				}

				if( PolyMarkers.Num() < 3 )
					appMsgf(TEXT("You must place at least 3 markers to create a brush."));
				else
				{
					WDlgDepth dlg( NULL, this );
					if( dlg.DoModal() )
					{
						FPolyBreaker breaker;
						FPlane plane( PolyMarkers(0), PolyMarkers(1), PolyMarkers(2) );
						FVector PlaneNormal = plane, WkVertex1, WkVertex2;
						breaker.Process( &PolyMarkers, PlaneNormal );

						FVector Origin;
						for( INT vtx = 0 ; vtx < PolyMarkers.Num() ; vtx++ )
							Origin += PolyMarkers(vtx);
						Origin /= PolyMarkers.Num();

						FString Cmd;

						Cmd += TEXT("BRUSH SET\n\n");

						for( INT poly = 0 ; poly < breaker.FinalPolys.Num() ; poly++ )
						{
							Cmd += TEXT("Begin Polygon Flags=0\n");
							for( INT vtx = 0 ; vtx < breaker.FinalPolys(poly).NumVertices ; vtx++ )
							{
								WkVertex1 = (breaker.FinalPolys(poly).Vertex[vtx] + (PlaneNormal * (dlg.Depth / 2.0f))) - Origin;
								Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
									WkVertex1.X, WkVertex1.Y, WkVertex1.Z ) );
							}
							Cmd += TEXT("End Polygon\n");

							Cmd += TEXT("Begin Polygon Flags=0\n");
							for( vtx = breaker.FinalPolys(poly).NumVertices-1 ; vtx > -1 ; vtx-- )
							{
								WkVertex1 = (breaker.FinalPolys(poly).Vertex[vtx] - (PlaneNormal * (dlg.Depth / 2.0f))) - Origin;
								Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
									WkVertex1.X, WkVertex1.Y, WkVertex1.Z ) );
							}
							Cmd += TEXT("End Polygon\n");
						}

						// Sides ...
						//
						for( vtx = 0 ; vtx < PolyMarkers.Num() ; vtx++ )
						{
							Cmd += TEXT("Begin Polygon Flags=0\n");

							FVector* pvtxPrev = &PolyMarkers( (vtx ? vtx - 1 : PolyMarkers.Num() - 1 ) );
							FVector* pvtx = &PolyMarkers(vtx);

							WkVertex1 = (*pvtx + (PlaneNormal * (dlg.Depth / 2.0f) )) - Origin;
							WkVertex2 = (*pvtxPrev + (PlaneNormal * (dlg.Depth / 2.0f) )) - Origin;
							Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
								WkVertex1.X, WkVertex1.Y, WkVertex1.Z ) );
							Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
								WkVertex2.X, WkVertex2.Y, WkVertex2.Z ) );

							WkVertex1 = (*pvtx - (PlaneNormal * (dlg.Depth / 2.0f) )) - Origin;
							WkVertex2 = (*pvtxPrev - (PlaneNormal * (dlg.Depth / 2.0f) )) - Origin;
							Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
								WkVertex2.X, WkVertex2.Y, WkVertex2.Z ) );
							Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
								WkVertex1.X, WkVertex1.Y, WkVertex1.Z ) );

							Cmd += TEXT("End Polygon\n");
						}

						GEditor->edactApplyTransformToBrush( GEditor->Level->Brush() );
						GEditor->Exec( *Cmd );
						GEditor->Level->Brush()->Location = Origin;
					}

					// Delete all poly markers.
					GEditor->Exec(TEXT("POLYGON DELETE"));
				}
			}
			break;

			case IDMENU_ActorPopupProperties:
			{
				GEditor->Exec( TEXT("HOOK ACTORPROPERTIES") );
			}
			break;

			case IDMENU_ActorPopupSelectAllClass:
			{
				FGetInfoRet gir = GetInfo( GEditor->Level, GI_NUM_SELECTED | GI_CLASSNAME_SELECTED );

				if( gir.iValue )
				{
					appSprintf( l_chCmd, TEXT("ACTOR SELECT OFCLASS CLASS=%s"), *gir.String );
					GEditor->Exec( l_chCmd );
				}
			}
			break;

			case IDMENU_ActorPopupSelectAll:
			{
				GEditor->Exec( TEXT("ACTOR SELECT ALL") );
			}
			break;

			case IDMENU_ActorPopupSelectNone:
			{
				GEditor->Exec( TEXT("SELECT NONE") );
			}
			break;

			case IDMENU_ActorPopupDuplicate:
			{
				GEditor->Exec( TEXT("ACTOR DUPLICATE") );
			}
			break;

			case IDMENU_ActorPopupDelete:
			{
				GEditor->Exec( TEXT("ACTOR DELETE") );
			}
			break;

			case IDMENU_ActorPopupEditScript:
			{
				GBrowserMaster->ShowBrowser(eBROWSER_ACTOR);
				FGetInfoRet gir = GetInfo( GEditor->Level, GI_CLASS_SELECTED );
				GCodeFrame->AddClass( gir.pClass );
			}
			break;

			case IDMENU_ActorPopupMakeCurrent:
			{
				FGetInfoRet gir = GetInfo( GEditor->Level, GI_CLASSNAME_SELECTED );
				GEditor->Exec( *(FString::Printf(TEXT("SETCURRENTCLASS CLASS=%s"), *gir.String)) );
			}
			break;

			case IDMENU_ActorPopupMerge:
			{
				GEditor->Exec(TEXT("BRUSH MERGEPOLYS"));
			}
			break;

			case IDMENU_ActorPopupSeparate:
			{
				GEditor->Exec(TEXT("BRUSH SEPARATEPOLYS"));
			}
			break;

			// Select Brushes
			case IDMENU_ActorPopupSelectBrushesAdd:
			{
				GEditor->Exec( TEXT("MAP SELECT ADDS") );
			}
			break;

			case IDMENU_ActorPopupSelectBrushesSubtract:
			{
				GEditor->Exec( TEXT("MAP SELECT SUBTRACTS") );
			}
			break;

			case IDMENU_ActorPopupSubtractBrushesSemisolid:
			{
				GEditor->Exec( TEXT("MAP SELECT SEMISOLIDS") );
			}
			break;

			case IDMENU_ActorPopupSelectBrushesNonsolid:
			{
				GEditor->Exec( TEXT("MAP SELECT NONSOLIDS") );
			}
			break;

			// Movers
			case IDMN_ActorPopupShowPolys:
			{
				for( INT i=0; i<GEditor->Level->Actors.Num(); i++ )
				{
					ABrush* Brush = Cast<ABrush>(GEditor->Level->Actors(i));
					if( Brush && Brush->IsMovingBrush() && Brush->bSelected )
					{
						Brush->Brush->EmptyModel( 1, 0 );
						Brush->Brush->BuildBound();
						GEditor->bspBuild( Brush->Brush, BSP_Good, 15, 1, 0 );
						GEditor->bspRefresh( Brush->Brush, 1 );
						GEditor->bspValidateBrush( Brush->Brush, 1, 1 );
						GEditor->bspBuildBounds( Brush->Brush );

						GEditor->bspBrushCSG( Brush, GEditor->Level->Model, 0, CSG_Add, 1 );
					}
				}
				GEditor->RedrawLevel( GEditor->Level );
			}
			break;

			case IDMENU_ActorPopupKey0:
			{
				GEditor->Exec( TEXT("ACTOR KEYFRAME NUM=0") );
			}
			break;

			case IDMENU_ActorPopupKey1:
			{
				GEditor->Exec( TEXT("ACTOR KEYFRAME NUM=1") );
			}
			break;

			case IDMENU_ActorPopupKey2:
			{
				GEditor->Exec( TEXT("ACTOR KEYFRAME NUM=2") );
			}
			break;

			case IDMENU_ActorPopupKey3:
			{
				GEditor->Exec( TEXT("ACTOR KEYFRAME NUM=3") );
			}
			break;

			case IDMENU_ActorPopupKey4:
			{
				GEditor->Exec( TEXT("ACTOR KEYFRAME NUM=4") );
			}
			break;

			case IDMENU_ActorPopupKey5:
			{
				GEditor->Exec( TEXT("ACTOR KEYFRAME NUM=5") );
			}
			break;

			case IDMENU_ActorPopupKey6:
			{
				GEditor->Exec( TEXT("ACTOR KEYFRAME NUM=6") );
			}
			break;

			case IDMENU_ActorPopupKey7:
			{
				GEditor->Exec( TEXT("ACTOR KEYFRAME NUM=7") );
			}
			break;

			// Reset
			case IDMENU_ActorPopupResetOrigin:
			{
				GEditor->Exec( TEXT("ACTOR RESET LOCATION") );
			}
			break;

			case IDMENU_ActorPopupResetPivot:
			{
				GEditor->Exec( TEXT("ACTOR RESET PIVOT") );
			}
			break;

			case IDMENU_ActorPopupResetRotation:
			{
				GEditor->Exec( TEXT("ACTOR RESET ROTATION") );
			}
			break;

			case IDMENU_ActorPopupResetScaling:
			{
				GEditor->Exec( TEXT("ACTOR RESET SCALE") );
			}
			break;

			case IDMENU_ActorPopupResetAll:
			{
				GEditor->Exec( TEXT("ACTOR RESET ALL") );
			}
			break;

			// Transform
			case IDMENU_ActorPopupMirrorX:
			{
				GEditor->Exec( TEXT("ACTOR MIRROR X=-1") );
			}
			break;

			case IDMENU_ActorPopupMirrorY:
			{
				GEditor->Exec( TEXT("ACTOR MIRROR Y=-1") );
			}
			break;

			case IDMENU_ActorPopupMirrorZ:
			{
				GEditor->Exec( TEXT("ACTOR MIRROR Z=-1") );
			}
			break;

			case IDMENU_ActorPopupPerm:
			{
				GEditor->Exec( TEXT("ACTOR APPLYTRANSFORM") );
			}
			break;

			// Order
			case IDMENU_ActorPopupToFirst:
			{
				GEditor->Exec( TEXT("MAP SENDTO FIRST") );
			}
			break;

			case IDMENU_ActorPopupToLast:
			{
				GEditor->Exec( TEXT("MAP SENDTO LAST") );
			}
			break;

			case IDMENU_ActorPopupSwapOrder:
			{
				GEditor->Exec( TEXT("MAP SENDTO SWAP") );
			}
			break;

			// Copy Polygons
			case IDMENU_ActorPopupToBrush:
			{
				GEditor->Exec( TEXT("MAP BRUSH GET") );
			}
			break;

			case IDMENU_ActorPopupFromBrush:
			{
				GEditor->Exec( TEXT("MAP BRUSH PUT") );
			}
			break;

			// Solidity
			case IDMENU_ActorPopupMakeSolid:
			{
				GEditor->Exec( *(FString::Printf( TEXT("MAP SETBRUSH CLEARFLAGS=%d SETFLAGS=%d"), PF_Semisolid + PF_NotSolid, 0 ) ) );
			}
			break;

			case IDMENU_ActorPopupMakeSemisolid:
			{
				GEditor->Exec( *(FString::Printf( TEXT("MAP SETBRUSH CLEARFLAGS=%d SETFLAGS=%d"), PF_Semisolid + PF_NotSolid, PF_Semisolid ) ) );
			}
			break;

			case IDMENU_ActorPopupMakeNonSolid:
			{
				GEditor->Exec( *(FString::Printf( TEXT("MAP SETBRUSH CLEARFLAGS=%d SETFLAGS=%d"), PF_Semisolid + PF_NotSolid, PF_NotSolid ) ) );
			}
			break;

			// CSG
			case IDMENU_ActorPopupMakeAdd:
			{
				GEditor->Exec( *(FString::Printf(TEXT("MAP SETBRUSH CSGOPER=%d"), CSG_Add) ) );
			}
			break;

			case IDMENU_ActorPopupMakeSubtract:
			{
				GEditor->Exec( *(FString::Printf(TEXT("MAP SETBRUSH CSGOPER=%d"), CSG_Subtract) ) );
			}
			break;
		
			// CONVERT
			case IDMENU_ConvertToHardwareBrush:
			{
				GEditor->Exec( TEXT("STATICMESH FROM ACTOR") );
			}
			break;
			case IDMENU_ConvertToBrush:
			{
				GEditor->Exec( TEXT("STATICMESH TOBRUSH") );
			}
			break;

			default:
				WMdiFrame::OnCommand(Command);
			}
	}
	void NotifyDestroy( void* Other )
	{
		if( Other==Preferences )
			Preferences=NULL;
	}

	// FDocumentManager interface.
	virtual void OpenLevelView()
	{
		// This is making it so you can only open one level window - it will reuse it for each
		// map you load ... which is not really MDI.  But the editor has problems with 2+ level windows open.  
		// Fix if you can...
		if( !GLevelFrame )
		{
			GLevelFrame = new WLevelFrame( GEditor->Level, TEXT("LevelFrame"), &BackgroundHolder );
			GLevelFrame->OpenWindow( 1, 1 );
		}
	}
};


void UpdateMenu()
{
	CheckMenuItem( GMainMenu, IDMN_VIEWPORT_FLOATING, MF_BYCOMMAND | (GViewportStyle == VSTYLE_Floating ? MF_CHECKED : MF_UNCHECKED) );
	CheckMenuItem( GMainMenu, IDMN_VIEWPORT_FIXED, MF_BYCOMMAND | (GViewportStyle == VSTYLE_Fixed ? MF_CHECKED : MF_UNCHECKED) );

	EnableMenuItem( GMainMenu, ID_ViewNewFree, MF_BYCOMMAND | (GViewportStyle == VSTYLE_Floating ? MF_ENABLED : MF_GRAYED) );
}

void FileOpen( HWND hWnd )
{
	FileSaveChanges( hWnd );

	OPENFILENAMEA ofn;
	char File[255] = "\0";

	ZeroMemory(&ofn, sizeof(OPENFILENAMEA));
	ofn.lStructSize = sizeof(OPENFILENAMEA);
	ofn.hwndOwner = hWnd;
	ofn.lpstrFile = File;
	ofn.nMaxFile = sizeof(File);
	char Filter[255];
	::sprintf( Filter,
		"Map Files (*.%s)%c*.%s%cAll Files%c*.*%c%c",
		appToAnsi( *GMapExt ),
		'\0',
		appToAnsi( *GMapExt ),
		'\0',
		'\0',
		'\0',
		'\0' );
	ofn.lpstrFilter = Filter;
	ofn.lpstrInitialDir = appToAnsi( *(GLastDir[eLASTDIR_DNF]) );
	ofn.lpstrDefExt = appToAnsi( *GMapExt );
	ofn.Flags = OFN_HIDEREADONLY | OFN_NOCHANGEDIR;

	// NJS: Ensure the file actually exists:
	ofn.Flags |= OFN_FILEMUSTEXIST | OFN_PATHMUSTEXIST; 

	// Display the Open dialog box. 
	if( GetOpenFileNameA(&ofn) )
	{
		// Make sure there's a level frame open.
		GEditorFrame->OpenLevelView();
			
		// Convert the ANSI filename to UNICODE, and tell the editor to open it.
		GLevelFrame->SetMapFilename( (TCHAR*)appFromAnsi(File) );
		GEditor->Exec( *(FString::Printf(TEXT("MAP LOAD FILE=\"%s\""), GLevelFrame->GetMapFilename() ) ) );

		FString S = GLevelFrame->GetMapFilename();
		GMRUList->AddItem( GLevelFrame->GetMapFilename() );
		GMRUList->AddToMenu( hWnd, GMainMenu, 1 );

		GLastDir[eLASTDIR_DNF] = S.Left( S.InStr( TEXT("\\"), 1 ) );

		GMRUList->AddItem( GLevelFrame->GetMapFilename() );
		GMRUList->AddToMenu( hWnd, GMainMenu, 1 );
	}

	// Make sure that the browsers reflect any new data the map brought with it.
	RefreshEditor();
	GButtonBar->RefreshBuilders();
	RefreshOptionProxies();

	GFileManager->SetDefaultDirectory(appBaseDir());
}

//-----------------------------------------------------------------------------
// Name: CrashHandler()
// Desc: Crash handler function.
//-----------------------------------------------------------------------------
#ifndef _DEBUG
__forceinline char* GetCrashInfo()
{
	strcpy(BugTextBuffer,"--- Fault Reason ---\n");

	strcat(BugTextBuffer,GetFaultReason(GExPtrs));
	strcat(BugTextBuffer,"\n\n");

	strcat(BugTextBuffer,"--- Register Dump ---\n");
	strcat(BugTextBuffer,GetRegisterString(GExPtrs));
	strcat(BugTextBuffer,"\n\n");

	strcat(BugTextBuffer,"--- Stack Trace ---\n");

	// Stack trace.
	char* StackLevel=GetFirstStackTraceString(GSTSO_MODULE|GSTSO_SYMBOL|GSTSO_SRCLINE,GExPtrs);
	while(StackLevel)
	{
		strcat(BugTextBuffer,StackLevel);
		strcat(BugTextBuffer,"\n");

		// In-place unicode conversion, to avoid exacerbating stack bugs.
		static TCHAR UnicodeString[2048];
		TCHAR* UnicodeStringIndex=UnicodeString;

		while(*UnicodeStringIndex++=*StackLevel++)
			;

		StackLevel=GetNextStackTraceString(GSTSO_MODULE|GSTSO_SYMBOL|GSTSO_SRCLINE,GExPtrs);
	}             

	strcat(BugTextBuffer,"\n--- Memory Status ---\n");

	MEMORYSTATUS stat;

	GlobalMemoryStatus (&stat);

	static char MemoryStatusText[4096];
	sprintf(MemoryStatusText,	"%ld%% of memory currently in use\n"
								"Physical memory total:%ldK\n"
								"Physical memory free :%ldK\n"
								"Page file total:%ldK\n"
								"Page file free :%ldK\n"
								"Virtual memory total:%ldK\n"
								"Virtual memory free :%ldK\n",
						stat.dwMemoryLoad,
						stat.dwTotalPhys/1024,		stat.dwAvailPhys/1024, 
						stat.dwTotalPageFile/1024,	stat.dwAvailPageFile/1024,
						stat.dwTotalVirtual/1024,	stat.dwAvailVirtual/1024);

	strcat(BugTextBuffer,MemoryStatusText);
	//strcat(BugTextBuffer,"\n--- User Comments ---\n");

	strcat(BugTextBuffer,"\n *** Would you like to email this information to the coders? ***\n");

	return BugTextBuffer;
}

LONG __stdcall CrashHandler( EXCEPTION_POINTERS *pExPtrs )
{
	GExPtrs=pExPtrs;
	if(IDYES==MessageBoxA(NULL,GetCrashInfo(),"Crash!",MB_YESNO))
	{		
		static char subject[1024];
		static char userName[128];

		SetCursor(LoadCursor(NULL,IDC_WAIT));

		DWORD NameSize=sizeof(userName);
		GetUserNameA(userName,&NameSize);
		sprintf(subject,"[*** DUKEED CRASH ***] %s",userName);
		//SendMailMessage("smtp.3drealms.com",NULL,"<nicks@3drealms.com>",    subject, BugTextBuffer);
		//SendMailMessage("smtp.3drealms.com",NULL,"<brandonr@3drealms.com>", subject, BugTextBuffer);
		//SendMailMessage("smtp.3drealms.com",NULL,"<jessc@3drealms.com>",	subject, BugTextBuffer);
		//SendMailMessage("smtp.3drealms.com",NULL,"<scotta@3drealms.com>",	subject, BugTextBuffer);
		//SendMailMessage("smtp.3drealms.com",NULL,"<andyh@3drealms.com>",	subject, BugTextBuffer);

		static char *mailingList[] =
		{
			"<nicks@3drealms.com>",
			"<brandonr@3drealms.com>",
			"<jessc@3drealms.com>",
			"<scotta@3drealms.com>",
			"<andyh@3drealms.com>",
			"<johnp@3drealms.com>",
			NULL
		};

		SendMultiMailMessage("smtp.3drealms.com",NULL,mailingList,subject,BugTextBuffer);
	}

	exit(EXIT_FAILURE);
	return 1;
}
#endif

// NJS: Urrm, I didn't put this here, I swear.
BOOL isExcusedFromAnnoyingSound()
{
	TCHAR UserName[256];
	DWORD UserNameSize=sizeof(UserName);
	GetUserName(UserName,&UserNameSize);
	if(!appStricmp(UserName,TEXT("SHAFFNER"))) return TRUE;
	if(!appStricmp(UserName,TEXT("SCOTTA")))   return TRUE;
	if(!appStricmp(UserName,TEXT("JESS")))     return TRUE;
	if(!appStricmp(UserName,TEXT("CRABLE")))   return TRUE;
	return FALSE;
}

/*-----------------------------------------------------------------------------
	WinMain.
-----------------------------------------------------------------------------*/
//
// Main window entry point.
//
INT WINAPI WinMain( HINSTANCE hInInstance, HINSTANCE hPrevInstance, char* InCmdLine, INT nCmdShow )
{
	// NJS: Prevent the user from accidentally starting more than one copy of the editor: (can cause nasty system crashes)
    HANDLE hInstanceMutex = ::CreateMutex(NULL,TRUE, TEXT("DukeEDMutex"));
    if(GetLastError() == ERROR_ALREADY_EXISTS)
    {
        if(hInstanceMutex) CloseHandle(hInstanceMutex);
        return EXIT_FAILURE;
    }

	// Initialize a few needed windows subsystems:
	InitCommonControls();
	LoadLibrary(_T("RICHED32.DLL"));

	// Remember instance.
	GIsStarted = 1;
	hInstance = hInInstance;
	GhInst = hInInstance;

	GetPropResult = NULL;

	// Set the crash handler.
#ifndef _DEBUG
	SetCrashHandlerFilter( CrashHandler );
#endif

	// Set package name.
	appStrcpy( GPackage, appPackage() );

	// Set mode.
	GIsClient = GIsServer = GIsEditor = GLazyLoad = 1;
	GIsScriptable = 0;

	// Start main loop.

	// Create a fully qualified pathname for the log file.  If we don't do this, pieces of the log file
	// tends to get written into various directories as the editor starts up.
	TCHAR chLogFilename[256] = TEXT("\0");
	appSprintf( chLogFilename, TEXT("%s%s"), appBaseDir(), TEXT("Editor.log"));
	appStrcpy( Log.Filename, chLogFilename );
	appInit( TEXT("DukeForever"), GetCommandLine(), &Malloc, &Log, &Error, &Warn, &FileManager, FConfigCacheIni::Factory, 1 );
	if (!GetPropResult)
		GetPropResult = new FStringOutputDevice;

	// Init windowing.
	InitWindowing();
	IMPLEMENT_WINDOWCLASS(WMdiFrame,CS_DBLCLKS);
	IMPLEMENT_WINDOWCLASS(WEditorFrame,CS_DBLCLKS);
	IMPLEMENT_WINDOWCLASS(WBackgroundHolder,CS_DBLCLKS);
	IMPLEMENT_WINDOWCLASS(WLevelFrame,CS_DBLCLKS);
	IMPLEMENT_WINDOWCLASS(WDockingFrame,CS_DBLCLKS | CS_VREDRAW | CS_HREDRAW);
	IMPLEMENT_WINDOWCLASS(WCodeFrame,CS_DBLCLKS | CS_VREDRAW | CS_HREDRAW);
	IMPLEMENT_WINDOWCLASS(W2DShapeEditor,CS_DBLCLKS | CS_VREDRAW | CS_HREDRAW);
	IMPLEMENT_WINDOWCLASS(WViewportFrame,CS_DBLCLKS);
	IMPLEMENT_WINDOWCLASS(WBrowser,CS_DBLCLKS | CS_VREDRAW | CS_HREDRAW);
	IMPLEMENT_WINDOWCLASS(WBrowserSound,CS_DBLCLKS | CS_VREDRAW | CS_HREDRAW);
	IMPLEMENT_WINDOWCLASS(WBrowserMusic,CS_DBLCLKS | CS_VREDRAW | CS_HREDRAW);
	IMPLEMENT_WINDOWCLASS(WBrowserGroup,CS_DBLCLKS | CS_VREDRAW | CS_HREDRAW);
	IMPLEMENT_WINDOWCLASS(WBrowserMaster,CS_DBLCLKS  | CS_VREDRAW | CS_HREDRAW);
	IMPLEMENT_WINDOWCLASS(WBrowserTexture,CS_DBLCLKS | CS_VREDRAW | CS_HREDRAW);
	IMPLEMENT_WINDOWCLASS(WBrowserMesh,CS_DBLCLKS | CS_VREDRAW | CS_HREDRAW);
	IMPLEMENT_WINDOWCLASS(WBrowserActor,CS_DBLCLKS | CS_VREDRAW | CS_HREDRAW);
	IMPLEMENT_WINDOWSUBCLASS(WMdiClient,TEXT("MDICLIENT"));
	IMPLEMENT_WINDOWCLASS(WButtonBar,CS_DBLCLKS | CS_VREDRAW | CS_HREDRAW);
	IMPLEMENT_WINDOWCLASS(WButtonGroup,CS_DBLCLKS | CS_VREDRAW | CS_HREDRAW);
	IMPLEMENT_WINDOWCLASS(WBottomBar,CS_DBLCLKS | CS_VREDRAW | CS_HREDRAW);
	IMPLEMENT_WINDOWCLASS(WVFToolBar,CS_DBLCLKS);
	IMPLEMENT_WINDOWCLASS(WTopBar,CS_DBLCLKS | CS_VREDRAW | CS_HREDRAW);
	IMPLEMENT_WINDOWCLASS(WBuildPropSheet,CS_DBLCLKS);
	IMPLEMENT_WINDOWCLASS(WPageOptions,CS_DBLCLKS);
	IMPLEMENT_WINDOWCLASS(WPageLevelStats,CS_DBLCLKS);
	IMPLEMENT_WINDOWCLASS(WSurfacePropSheet,CS_DBLCLKS);
	IMPLEMENT_WINDOWCLASS(WTerrainEditSheet,CS_DBLCLKS);
	IMPLEMENT_WINDOWCLASS(WSurfacePropPage,CS_DBLCLKS);
	IMPLEMENT_WINDOWCLASS(WPageFlags,CS_DBLCLKS);
	IMPLEMENT_WINDOWCLASS(WPagePanRotScale,CS_DBLCLKS);
	IMPLEMENT_WINDOWCLASS(WPageAlignment,CS_DBLCLKS);
	IMPLEMENT_WINDOWCLASS(WPageStats,CS_DBLCLKS);
	IMPLEMENT_WINDOWCLASS(WPageSoftSelection,CS_DBLCLKS);

	// Windows.
	WEditorFrame Frame;
	GDocumentManager = &Frame;
	Frame.OpenWindow();
	InvalidateRect( Frame, NULL, 1 );
	UpdateWindow( Frame );
	UBOOL ShowLog = ParseParam(appCmdLine(),TEXT("log"));
	if( !ShowLog && !ParseParam(appCmdLine(),TEXT("server")) )
#ifndef _DEBUG
		InitSplash(TEXT("Logo.bmp"),IDDIALOG_Splash);
#endif
	// Play a welcome sound.
	if(!isExcusedFromAnnoyingSound())
		PlaySound( _T("EditorRes\\DEStartup.wav"), NULL, SND_ASYNC | SND_FILENAME | SND_NODEFAULT | SND_NOWAIT );

	// Init.
	GLogWindow = new WLog( Log.Filename, Log.LogAr, TEXT("EditorLog"), &Frame );
	GLogWindow->OpenWindow( ShowLog, 0 );
	GLogWindow->MoveWindow( 100, 100, 450, 450, 0 );

	// Init engine.
	GEditor = CastChecked<UEditorEngine>(InitEngine(IDDIALOG_Splash));
	GhwndEditorFrame = GEditorFrame->hWnd;

	// Set up autosave timer.  We ping the engine once a minute and it determines when and 
	// how to do the autosave.
	SetTimer( GEditorFrame->hWnd, 900, 60000, NULL);

	// Initialize "last dir" array
	GLastDir[eLASTDIR_DNF] = TEXT("..\\maps");
	GLastDir[eLASTDIR_DTX] = TEXT("..\\textures");
	GLastDir[eLASTDIR_DFX] = TEXT("..\\sounds");
	GLastDir[eLASTDIR_DMX] = TEXT("..\\meshes");

	if( !GConfig->GetString( TEXT("Directories"), TEXT("PCX"),   GLastDir[eLASTDIR_PCX],	TEXT("DukeEd.ini") ) )	GLastDir[eLASTDIR_PCX] = TEXT("..\\textures");
	if( !GConfig->GetString( TEXT("Directories"), TEXT("WAV"),	 GLastDir[eLASTDIR_WAV],	TEXT("DukeEd.ini") ) )	GLastDir[eLASTDIR_WAV] = TEXT("..\\sounds");
	if( !GConfig->GetString( TEXT("Directories"), TEXT("BRUSH"), GLastDir[eLASTDIR_BRUSH],	TEXT("DukeEd.ini") ) )	GLastDir[eLASTDIR_BRUSH] = TEXT("..\\maps");
	if( !GConfig->GetString( TEXT("Directories"), TEXT("2DS"),   GLastDir[eLASTDIR_2DS],	TEXT("DukeEd.ini") ) )	GLastDir[eLASTDIR_2DS] = TEXT("..\\maps");

	if( !GConfig->GetString( TEXT("URL"), TEXT("MapExt"), GMapExt, TEXT("DukeForever.ini") ) )		GMapExt = TEXT("dnf");
	GEditor->Exec( *(FString::Printf(TEXT("MODE MAPEXT=%s"), *GMapExt ) ) );

	// Init input.
	UInput::StaticInitInput();

	// Toolbar.
	GButtonBar = new WButtonBar( TEXT("EditorToolbar"), &Frame.LeftFrame );
	GButtonBar->OpenWindow();
	Frame.LeftFrame.Dock( GButtonBar );
	Frame.LeftFrame.OnSize( SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE, 0, 0 );

	GBottomBar = new WBottomBar( TEXT("BottomBar"), &Frame.BottomFrame );
	GBottomBar->OpenWindow();
	Frame.BottomFrame.Dock( GBottomBar );
	Frame.BottomFrame.OnSize( SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE, 0, 0 );

	GTopBar = new WTopBar( TEXT("TopBar"), &Frame.TopFrame );
	GTopBar->OpenWindow();
	Frame.TopFrame.Dock( GTopBar );
	Frame.TopFrame.OnSize( SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE, 0, 0 );

	GBrowserMaster = new WBrowserMaster( TEXT("Master Browser"), GEditorFrame );
	check(GBrowserMaster);
	GBrowserMaster->OpenWindow( 0 );
	GBrowserMaster->Browsers[eBROWSER_MESH]    =(WBrowser**)(&GBrowserMesh);
	GBrowserMaster->Browsers[eBROWSER_MUSIC]   =(WBrowser**)(&GBrowserMusic);
	GBrowserMaster->Browsers[eBROWSER_SOUND]   =(WBrowser**)(&GBrowserSound);
	GBrowserMaster->Browsers[eBROWSER_ACTOR]   =(WBrowser**)(&GBrowserActor);
	GBrowserMaster->Browsers[eBROWSER_GROUP]   =(WBrowser**)(&GBrowserGroup);
	GBrowserMaster->Browsers[eBROWSER_TEXTURE] =(WBrowser**)(&GBrowserTexture);
	::InvalidateRect( GBrowserMaster->hWnd, NULL, 1 );
	
	GBuildSheet = new WBuildPropSheet( TEXT("Build Options"), GEditorFrame );
	GBuildSheet->OpenWindow();
	GBuildSheet->Show( FALSE );

	GSurfPropSheet = new WSurfacePropSheet( TEXT("Surface Properties"), GEditorFrame );
	GSurfPropSheet->OpenWindow();
	GSurfPropSheet->Show( FALSE );

	GTerrainEditSheet = new WTerrainEditSheet( TEXT("Terrain Editing"), GEditorFrame );
	GTerrainEditSheet->OpenWindow();
	GTerrainEditSheet->Show( FALSE );

	// Open a blank level on startup.
	Frame.OpenLevelView();

	// Reopen whichever windows we need to.
	UBOOL bDocked, bActive;

	// Attempt to create the mesh browser here:
	if(!GConfig->GetInt( TEXT("Mesh Browser"), TEXT("Docked"), bDocked, TEXT("DukeEd.ini") ))	bDocked = FALSE;
	SendMessageX( GEditorFrame->hWnd, WM_COMMAND, bDocked ? WM_BROWSER_DOCK : WM_BROWSER_UNDOCK, eBROWSER_MESH );
	if( !bDocked ) 
	{
		if(!GBrowserMesh) appErrorf(TEXT("GBrowserMesh==NULL"));
		if(!GConfig->GetInt( *GBrowserMesh->PersistentName, TEXT("Active"), bActive, TEXT("DukeEd.ini") ))	bActive = FALSE;
		GBrowserMesh->Show( bActive );
	}
	
	if(!GConfig->GetInt( TEXT("Music Browser"), TEXT("Docked"), bDocked, TEXT("DukeEd.ini") ))	bDocked = FALSE;
	SendMessageX( GEditorFrame->hWnd, WM_COMMAND, bDocked ? WM_BROWSER_DOCK : WM_BROWSER_UNDOCK, eBROWSER_MUSIC );
	if( !bDocked ) 
	{
		check(GBrowserMusic); 
		if(!GConfig->GetInt( *GBrowserMusic->PersistentName, TEXT("Active"), bActive, TEXT("DukeEd.ini") ))	bActive = FALSE;
		GBrowserMusic->Show( bActive );
	}

	if(!GConfig->GetInt( TEXT("Sound Browser"), TEXT("Docked"), bDocked, TEXT("DukeEd.ini") ))	bDocked = FALSE;
	SendMessageX( GEditorFrame->hWnd, WM_COMMAND, bDocked ? WM_BROWSER_DOCK : WM_BROWSER_UNDOCK, eBROWSER_SOUND );
	if( !bDocked ) 
	{
		check(GBrowserSound);
		if(!GConfig->GetInt( *GBrowserSound->PersistentName, TEXT("Active"), bActive, TEXT("DukeEd.ini") ))	bActive = FALSE;
		GBrowserSound->Show( bActive );
	}

	if(!GConfig->GetInt( TEXT("Actor Browser"), TEXT("Docked"), bDocked, TEXT("DukeEd.ini") ))	bDocked = FALSE;
	SendMessageX( GEditorFrame->hWnd, WM_COMMAND, bDocked ? WM_BROWSER_DOCK : WM_BROWSER_UNDOCK, eBROWSER_ACTOR );
	if( !bDocked ) 
	{
		if(!GConfig->GetInt( *GBrowserActor->PersistentName, TEXT("Active"), bActive, TEXT("DukeEd.ini") ))	bActive = FALSE;
		GBrowserActor->Show( bActive );
	}

	if(!GConfig->GetInt( TEXT("Group Browser"), TEXT("Docked"), bDocked, TEXT("DukeEd.ini") ))	bDocked = FALSE;
	SendMessageX( GEditorFrame->hWnd, WM_COMMAND, bDocked ? WM_BROWSER_DOCK : WM_BROWSER_UNDOCK, eBROWSER_GROUP );
	if( !bDocked ) 
	{
		if(!GConfig->GetInt( *GBrowserGroup->PersistentName, TEXT("Active"), bActive, TEXT("DukeEd.ini") ))	bActive = FALSE;
		GBrowserGroup->Show( bActive );
	}

	if(!GConfig->GetInt( TEXT("Texture Browser"), TEXT("Docked"), bDocked, TEXT("DukeEd.ini") ))	bDocked = FALSE;
	SendMessageX( GEditorFrame->hWnd, WM_COMMAND, bDocked ? WM_BROWSER_DOCK : WM_BROWSER_UNDOCK, eBROWSER_TEXTURE );
	if( !bDocked ) 
	{
		if(!GConfig->GetInt( *GBrowserTexture->PersistentName, TEXT("Active"), bActive, TEXT("DukeEd.ini") ))	bActive = FALSE;
		GBrowserTexture->Show( bActive );
	}
	
	if(!GConfig->GetInt( TEXT("CodeFrame"), TEXT("Active"), bActive, TEXT("DukeEd.ini") ))	bActive = FALSE;
	if( bActive )	ShowCodeFrame( GEditorFrame );

	GCodeFrame = new WCodeFrame( TEXT("CodeFrame"), GEditorFrame );
	GCodeFrame->OpenWindow( 0, 0 );

	GMainMenu = LoadMenuIdX( hInstance, IDMENU_MainMenu );
	SetMenu( GEditorFrame->hWnd, GMainMenu );

	GMRUList = new MRUList( TEXT("MRU") );
	GMRUList->ReadINI();
	GMRUList->AddToMenu( GEditorFrame->hWnd, GMainMenu, 1 );

#ifndef _DEBUG
	ExitSplash();
#endif
	/* setup hook for IPC message passing */
	IpcHookInit(DukeEdIpcHook);

	if( !GIsRequestingExit )
		MainLoop( GEditor, TRUE);

	// Play a welcome sound.
	if(!isExcusedFromAnnoyingSound())
		PlaySound( _T("EditorRes\\DEShutdown.wav"), NULL, SND_ASYNC | SND_FILENAME | SND_NODEFAULT | SND_NOWAIT );

	GDocumentManager=NULL;
	GFileManager->Delete(TEXT("Running.ini"),0,0);

	SafeDelete( GLogWindow );
	appPreExit();
	check(GMRUList);		SafeDelete(GMRUList);
	check(GCodeFrame);		SafeDelete(GCodeFrame);
	check(GetPropResult);	SafeDelete(GetPropResult);
	check(GButtonBar);		SafeDelete(GButtonBar);
	check(GBottomBar);		SafeDelete(GBottomBar);
	check(GTopBar);			SafeDelete(GTopBar);

	// Shut down.
	appExit();
	GIsStarted = 0;

	return 0;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
