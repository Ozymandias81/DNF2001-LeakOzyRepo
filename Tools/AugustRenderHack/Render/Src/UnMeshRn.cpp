/*=============================================================================
	UnMeshRn.cpp: Unreal mesh rendering.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney		
=============================================================================*/

#include "EnginePrivate.h"

/*------------------------------------------------------------------------------
	Globals.
------------------------------------------------------------------------------*/
UBOOL               HasSpecialCoords;
FCoords             SpecialCoords;
static FLOAT        UScale, VScale;
static UTexture*    Textures[16];
static FTextureInfo TextureInfo[16];
static FTextureInfo EnvironmentInfo;
static FPlane      GUnlitColor;

EXECVAR(UBOOL, DisableMeshes, false);

/*------------------------------------------------------------------------------
	Environment mapping.
------------------------------------------------------------------------------*/
 
static __forceinline void EnviroMap( FSceneNode* Frame, FTransTexture& P )
{
	FVector T = P.Point.UnsafeNormal().MirrorByVector( P.Normal ).TransformVectorBy( Frame->Uncoords );
	P.U = (T.X+1.f) * 0.5f * UScale;
	P.V = (T.Y+1.f) * 0.5f * VScale;
}

/*--------------------------------------------------------------------------
	Clippers.
--------------------------------------------------------------------------*/

static FLOAT Dot[32];
static inline INT Clip( FSceneNode* Frame, FTransTexture** Dest, FTransTexture** Src, INT SrcNum )
{
	INT DestNum=0;
	for( INT i=0,j=SrcNum-1; i<SrcNum; j=i++ )
	{
		if( Dot[j]>=0.f )
		{
			Dest[DestNum++] = Src[j];
		}
		if( Dot[j]*Dot[i]<0.f )
		{
			FTransTexture* T = Dest[DestNum] = New<FTransTexture>(GMem);
			*T = FTransTexture( *Src[j] + (*Src[i]-*Src[j]) * (Dot[j]/(Dot[j]-Dot[i])) );
			T->Project( Frame );
			DestNum++;
		}
	}
	return DestNum; 
}

/*------------------------------------------------------------------------------
	Subsurface rendering.
------------------------------------------------------------------------------*/

// Triangle subdivision table.
/*
static const int CutTable[8][4][3] =
{
	{{0,1,2},{9,9,9},{9,9,9},{9,9,9}},
	{{0,3,2},{2,3,1},{9,9,9},{9,9,9}},
	{{0,1,4},{4,2,0},{9,9,9},{9,9,9}},
	{{0,3,2},{2,3,4},{4,3,1},{9,9,9}},
	{{0,1,5},{5,1,2},{9,9,9},{9,9,9}},
	{{0,3,5},{5,3,1},{1,2,5},{9,9,9}},
	{{0,1,4},{4,2,5},{5,0,4},{9,9,9}},
	{{0,3,5},{3,1,4},{5,4,2},{3,4,5}}
};
*/
static FVector RenderSubsurface_MinExtent=FVector(FLT_MAX,FLT_MAX,FLT_MAX);
static FVector RenderSubsurface_MaxExtent=FVector(FLT_MIN,FLT_MIN,FLT_MIN);

static void __fastcall RenderSubsurface
(
	bool            Batch,
	FSceneNode*		Frame,
	FTextureInfo&	Texture,
	UTexture       *Tex,
	FSpanBuffer*	Span,
	FTransTexture**	Pts,
	DWORD			PolyFlags,
	DWORD			PolyFlagsEx,
	INT				SubCount,
	UBOOL			ModifyExtent=0
)
{
#define EXT_RETURN \
	{ \
		if (PolyFlags & PF_Unlit) \
		{ \
			for (INT i=0;i<3;i++) \
				Pts[i]->Light = BackupPts[i]; \
		} \
		return; \
	}

	check(Frame&&(Frame->Viewport)&&(Frame->Viewport->RenDev));

	if(!Frame->Viewport->RenDev->QueuePolygonDoes())
	{
		// If outcoded, skip it.
		if( Pts[0]->Flags & Pts[1]->Flags & Pts[2]->Flags )
			return;
		// Backface reject it.
		if( (PolyFlags & PF_TwoSided) && FTriple(Pts[0]->Point,Pts[1]->Point,Pts[2]->Point) <= 0.0 )
		{
			if( !(PolyFlags & PF_TwoSided) )
				return;
			Exchange( Pts[2], Pts[0] );
		}
	}
	/* NJS: Reject small polys: */
#if 0
	for( INT i=0; i<2; i++ )
	{
		if((fabs(Pts[i]->ScreenY-Pts[i+1]->ScreenY)>0.0001f)
		 &&(fabs(Pts[i]->ScreenX-Pts[i+1]->ScreenX)>0.0001f))
			break;
	}

	if(i==2) return;
#endif

	FPlane BackupPts[3];

	// Handle effects.
	if( PolyFlags & (PF_Environment | PF_Unlit) )
	{
		// Environment mapping.
		if( PolyFlags & PF_Environment )
			for( INT i=0; i<3; i++ )
				EnviroMap( Frame, *Pts[i] );

		// Handle unlit.
		if( PolyFlags & PF_Unlit )
			for( INT j=0; j<3; j++ )
			{
				BackupPts[j] = Pts[j]->Light;
				Pts[j]->Light = GUnlitColor;
			}
	}

	// Clip it.
	INT NumPts=3;
	if(!Frame->Viewport->RenDev->QueuePolygonDoes())
	{

		BYTE AllCodes = Pts[0]->Flags | Pts[1]->Flags | Pts[2]->Flags;

		if( AllCodes )
		{
			if( AllCodes & FVF_OutXMin )
			{
				static FTransTexture* LocalPts[8];
				for( INT i=0; i<NumPts; i++ )
					Dot[i] = Frame->PrjXM * Pts[i]->Point.Z + Pts[i]->Point.X;
				NumPts = Clip( Frame, LocalPts, Pts, NumPts );
				if( NumPts==0 ) EXT_RETURN
				Pts = LocalPts;
			}
			if( AllCodes & FVF_OutXMax )
			{
				static FTransTexture* LocalPts[8];
				for( INT i=0; i<NumPts; i++ )
					Dot[i] = Frame->PrjXP * Pts[i]->Point.Z - Pts[i]->Point.X;
				NumPts = Clip( Frame, LocalPts, Pts, NumPts );
				if( NumPts==0 ) EXT_RETURN
				Pts = LocalPts;
			}
			if( AllCodes & FVF_OutYMin )
			{
				static FTransTexture* LocalPts[8];
				for( INT i=0; i<NumPts; i++ )
					Dot[i] = Frame->PrjYM * Pts[i]->Point.Z + Pts[i]->Point.Y;
				NumPts = Clip( Frame, LocalPts, Pts, NumPts );
				if( NumPts==0 ) EXT_RETURN
				Pts = LocalPts;
			}
			if( AllCodes & FVF_OutYMax )
			{
				static FTransTexture* LocalPts[8];
				for( INT i=0; i<NumPts; i++ )
					Dot[i] = Frame->PrjYP * Pts[i]->Point.Z - Pts[i]->Point.Y;
				NumPts = Clip( Frame, LocalPts, Pts, NumPts );
				if( NumPts==0 ) EXT_RETURN
				Pts = LocalPts;
			}
		}
		
		if( Frame->NearClip.W != 0.f )
		{
			UBOOL Clipped=0;
			for( INT i=0; i<NumPts; i++ )
			{
				Dot[i] = Frame->NearClip.PlaneDot(Pts[i]->Point);
				Clipped |= (Dot[i]<0.f);
			}
			if( Clipped )
			{
				static FTransTexture* LocalPts[8];
				NumPts = Clip( Frame, LocalPts, Pts, NumPts );
				if( NumPts==0 ) EXT_RETURN
				Pts = LocalPts;
			}
		}
		
		if(ModifyExtent&&!(PolyFlags&PF_Invisible))
		{
			for( INT i=0; i<NumPts; i++ )
			{
				ClipFloatFromZero(Pts[i]->ScreenX, Frame->FX);
					 if(RenderSubsurface_MinExtent.X>Pts[i]->ScreenX) RenderSubsurface_MinExtent.X=Pts[i]->ScreenX;
				else if(RenderSubsurface_MaxExtent.X<Pts[i]->ScreenX) RenderSubsurface_MaxExtent.X=Pts[i]->ScreenX;

				ClipFloatFromZero(Pts[i]->ScreenY, Frame->FY);
					 if(RenderSubsurface_MinExtent.Y>Pts[i]->ScreenY) RenderSubsurface_MinExtent.Y=Pts[i]->ScreenY;
				else if(RenderSubsurface_MaxExtent.Y<Pts[i]->ScreenY) RenderSubsurface_MaxExtent.Y=Pts[i]->ScreenY;
			}

		} else
		{
			for( INT i=0; i<NumPts; i++ )
			{
				ClipFloatFromZero(Pts[i]->ScreenX, Frame->FX);
				ClipFloatFromZero(Pts[i]->ScreenY, Frame->FY);
			}
		}
	}
	if(Batch)
		// Render it.
		Frame->Viewport->RenDev->QueuePolygon(&Texture, Pts, NumPts, PolyFlags, PolyFlagsEx|(Texture.Texture?Texture.Texture->PolyFlagsEx:0), Span );
	else
		Frame->Viewport->RenDev->DrawGouraudPolygon(Frame,Texture,Pts,NumPts,PolyFlags,Span);

	EXT_RETURN

#undef EXT_RETURN

}

/*------------------------------------------------------------------------------
	High level mesh rendering.
------------------------------------------------------------------------------*/

//
// Structure used by DrawMesh for sorting triangles.
//
INT __forceinline Compare( const FTransform* A, const FTransform* B )
{
	return appRound(B->Point.Z - A->Point.Z);
}

struct FMeshTriSortDuke
{
	SMacTri* Tri;
	INT Key;
};
INT __forceinline Compare( const FMeshTriSortDuke& A, const FMeshTriSortDuke& B )
{
	if(((A.Tri->surfaceFlags)&SRFTF_TEXBLEND)&&(!((B.Tri->surfaceFlags)&SRFTF_TEXBLEND))) return -1;
	if(((B.Tri->surfaceFlags)&SRFTF_TEXBLEND)&&(!((A.Tri->surfaceFlags)&SRFTF_TEXBLEND))) return 1;

	return (B.Key - A.Key);
}

EXECVAR_HELP(UBOOL, mesh_showbones, 0, "Display bone bounding boxes");
EXECVAR_HELP(FLOAT, mesh_wpndrawscale, 0.2, "Weapon draw scale");
EXECVAR_HELP(UBOOL, mesh_nospecular, 0, "Disable pseudo-specular glazing flag on mesh polys");
EXECVAR_HELP(UBOOL, mesh_notransparent, 0, "Disable transparent flag on mesh polys");
EXECVAR_HELP(UBOOL, mesh_nomodulated, 0, "Disable modulated flag on mesh polys");
EXECVAR_HELP(UBOOL, mesh_nomasking, 0, "Disable masking flag on mesh polys");
EXECVAR(FLOAT, mesh_specdist, 0.1f);
EXECVAR(FLOAT, mesh_wpnspecdist, 0.01f);
EXECVAR(FLOAT, mesh_lodforcelevel, 0);
EXECVAR_HELP(UBOOL, mesh_lodactive, 0, "Enables or disables mesh LOD");
EXECFUNC(GetSpecular)
{
	GDnExec->Printf(TEXT("%i"),!mesh_nospecular);
}
EXECFUNC(GetLodActive)
{
	GDnExec->Printf(TEXT("%i"),mesh_lodactive);
}

EXECFUNC(Lod)
{
	mesh_lodactive ^= 1;
	GDnExec->Printf(TEXT("Mesh level of detail reduction %s"),mesh_lodactive?TEXT("ON"):TEXT("OFF"));
}

#pragma warning(disable: 4505) // unreferenced local function

/*
	Color conversion convenience functions.
	Components in both RGB and HSV are in the [0,1] range.

	Cut&pasted directly from VecMain.h, and made static
	since the inlining of the VEC_RGBToHSV and VEC_HSVToRGB
	functions is causing havoc with the global
	optimizer in the draw function for some reason. - CDH
*/
static VVec3 __fastcall VEC_RGBToHSV_2(const VVec3& inRGB)
{
	float r = inRGB.x, g = inRGB.y, b = inRGB.z, v, x, f;
	int i;
	x = M_MIN3(r, g, b);
	v = M_MAX3(r, g, b);
	if (v == x)
		return(VVec3(0, 0, v));
	f = (r == x) ? g - b : ((g == x) ? b - r : r - g);
	i = (r == x) ? 3 : ((g == x) ? 5 : 1);
	return(VVec3((i-f/(v-x))/6.f, (v-x)/v, v));
}

static VVec3 __fastcall VEC_HSVToRGB_2(const VVec3& inHSV)
{
	float h = inHSV.x*6.f, s = inHSV.y, v = inHSV.z, m, n, f;
	int i;
	if (s == 0.f)
		return(VVec3(v,v,v));
	i = (int)h;
	f = h - i;
	if (!(i & 1))
		f = 1 - f;
	m = v * (1 - s);
	n = v * (1 - s*f);
	switch(i)
	{
		case 0: case 6: return(VVec3(v,n,m));
		case 1:			return(VVec3(n,v,m));
		case 2:			return(VVec3(m,v,n));
		case 3:			return(VVec3(m,n,v));
		case 4:			return(VVec3(n,m,v));
		case 5:			return(VVec3(v,m,n));
		default:		return(VVec3(0,0,0));
	};
}

// CDH: This function used to be below as part of DrawMesh but MSVC++'s ridiculous optimizer kept fubaring because that function is too large.
//      It is used to calculate vertex lighting when in HeatVision.  The name "StupidOptimizer" is intentional, as it is the most meaningful
//		description of this function possible, since the function would not exist if the optimizer weren't so insipid.
static void __fastcall StupidOptimizer(FSceneNode* Frame, UMeshInstance* MeshInst, ARenderActor* Owner, FTransTexture* Samples, INT NumVerts, const FCoords& Coords)
{
	FVector Center;
	UDukeMeshInstance* DukeMesh = Cast<UDukeMeshInstance>(MeshInst);
	CMacBone* ChestBone = NULL;
	if (DukeMesh)
		ChestBone = DukeMesh->Mac->FindBone( "Abdomen" );
	if (ChestBone)
	{
		VCoords3 c(ChestBone->GetCoords(true));
		FCoords fc(FVector(0,0,0), *((FVector*)&c.r.vX), *((FVector*)&c.r.vY), *((FVector*)&c.r.vZ));
		fc = fc.ToUnr();
		FCoords MeshCoords = DukeMesh->GetBasisCoords(GMath.UnitCoords);
		FCoords BoneCoords = GMath.UnitCoords;
		BoneCoords.XAxis = fc.XAxis.TransformVectorBy(MeshCoords); BoneCoords.XAxis.Normalize();
		BoneCoords.YAxis = fc.YAxis.TransformVectorBy(MeshCoords); BoneCoords.YAxis.Normalize();
		BoneCoords.ZAxis = fc.ZAxis.TransformVectorBy(MeshCoords); BoneCoords.ZAxis.Normalize();
		BoneCoords.Origin = *((FVector*)&c.t); BoneCoords.Origin = BoneCoords.Origin.ToUnr();
		BoneCoords.Origin = (BoneCoords.Origin - DukeMesh->Mac->mDukeOrigin).TransformPointBy(MeshCoords);
		FCoords OutCoords = BoneCoords.Transpose();
		Center = FVector(0,0,0).TransformPointBy(OutCoords);
	} else 
	{
		FBox Bound = MeshInst->GetRenderBoundingBox(Owner, false);
		Center = (Bound.Min + Bound.Max) * 0.5f;
	}
	Center = Center.TransformPointBy(Coords);
	FCoords InvFrameCoords = Frame->Coords.Transpose();

	FLOAT Radius2 = (FLOAT)Owner->HeatRadius;
	FLOAT Falloff2 = Radius2 + Radius2*(1.f-((FLOAT)Owner->HeatFalloff/256.f));
	for (INT i=0;i<NumVerts;i++)
	{
		FTransSample* Vert = &Samples[i];
		FLOAT VHeat = 1.f;
		FLOAT Dist2 = (Vert->Point - Center).Size();
		if (Dist2 > Radius2)
		{
			if (Dist2 > Falloff2)
				VHeat = 0.f;
			else
				VHeat = 1.f - ((Dist2 - Radius2) / (Falloff2 - Radius2));
		}

		FVector N = Vert->Normal.TransformVectorBy(InvFrameCoords);
		VVec3 v(Vert->Light.X, Vert->Light.Y, Vert->Light.Z);
		v = VEC_RGBToHSV_2((VVec3)v);
		//v.x = (FLOAT)fmod(0.15f - ((M_Fabs(N.Z) * 0.15f) + (1.f-VHeat)*((FLOAT)Owner->HeatFalloff/255.f)) + 1.f, 1.f);
		//v.x = VHeat;
		FLOAT temp1 = (M_Fabs(N.Z) * 0.15f);
		FLOAT temp2 = (1.f-VHeat)*(184.f/255.f);
		FLOAT temp3 = temp1 + temp2;
		v.x = (FLOAT)fmod(0.85f + temp3, 1.f);

		v.x = Min(v.x, 1.f);
		v.y = 1.f;
		v.z = 1.f;// - v.x;
		v = VEC_HSVToRGB_2(v);
		Vert->Light = FVector(v.x, v.y, v.z);
	}
}

// Draw a mesh map.
void __fastcall URender::DrawMesh
(
	FSceneNode*		Frame,
	AActor*			Owner,
	AActor*			LightSink,
	FSpanBuffer*	SpanBuffer,
	AZoneInfo*		Zone,
	const FCoords&	Coords,
	FVolActorLink*	LeafLights,
	FActorLink*		Volumetrics,
	DWORD			ExtraFlags, 
	DWORD			PolyFlagsEx
)
{
	if(DisableMeshes) 
		return;

	if(!Owner->Mesh||!Owner->Mesh->IsA(UDukeMesh::StaticClass()))
	{
		debugf(_T("Attempted to render an obsolete or unsupported mesh format: %s"),Owner->GetName());
		return;
	}

	ExtraFlags |= PF_Flat; // Currently disabled curved surfaces, too much performance drain

	UDukeMesh* Mesh = (UDukeMesh*)Owner->Mesh;
	UDukeMeshInstance* MeshInst = Cast<UDukeMeshInstance>(Mesh->GetInstance(Owner));
	if (!MeshInst || !MeshInst->Mac || !MeshInst->Mac->mGeometry || !MeshInst->Mac->mSurfaces.GetCount() || !MeshInst->Mac->mSurfaces[0])
		return;

	// JEP: In editor, force bones to be dirty
	if (GIsEditor)
		MeshInst->Mac->bBonesDirty = true;

	bool DriverQueues=Frame->Viewport->RenDev->QueuePolygonDoes();
	// NJS: Init mesh extent computation:

	// Recurse into weapon rendering:
#if 1
	if (Owner->IsA(APawn::StaticClass()))
	{
		STAT(clock(GStat.MeshMountRenderCycles));		// JEP

		AWeapon* Wpn = ((APawn*)Owner)->Weapon;
		if (Wpn && Wpn->ThirdPersonMesh)
		{
			// Third person weapon.
			FCoords WpnCoords(FVector(0,0,0));
			if (MeshInst->GetMountCoords(FName(_T("Weapon")), MOUNT_MeshSurface, WpnCoords, Wpn))
			{
				FVector OldPos = Wpn->Location;
				FRotator OldRot = Wpn->Rotation;
				FLOAT OldHeight = Wpn->CollisionHeight;
				UTexture* OldSkin = Wpn->Skin;
				Wpn->Skin = NULL;
				Wpn->Location = FVector(0,0,0).TransformPointBy(WpnCoords);
				Wpn->Weapon3rdLocation = Wpn->Location;
				Wpn->Rotation = WpnCoords.Transpose().OrthoRotation();
				Wpn->Weapon3rdRotation = Wpn->Rotation;
				Wpn->CollisionHeight = 0.f;
				Exchange( Wpn->ThirdPersonMesh, Wpn->Mesh );
				Exchange( Wpn->ThirdPersonScale, Wpn->DrawScale );
				DrawMesh(Frame, Wpn, LightSink, SpanBuffer, Zone, Coords, LeafLights, Volumetrics, ExtraFlags, PolyFlagsEx );
				Exchange( Wpn->ThirdPersonMesh, Wpn->Mesh );
				Exchange( Wpn->ThirdPersonScale, Wpn->DrawScale );
				Wpn->Skin = OldSkin;
				Wpn->Location = OldPos;
				Wpn->Rotation = OldRot;
				Wpn->CollisionHeight = OldHeight;
			}
		}
		
		STAT(unclock(GStat.MeshMountRenderCycles));		// JEP
	}
#endif

	UBOOL ComputeMeshExtent=Owner->ComputeMeshExtent;
	if(ComputeMeshExtent)
	{
		RenderSubsurface_MinExtent=FVector(FLT_MAX,FLT_MAX,FLT_MAX);
		RenderSubsurface_MaxExtent=FVector(FLT_MIN,FLT_MIN,FLT_MIN);
		Owner->MeshLastScreenExtentMin=FVector(0,0,0);
		Owner->MeshLastScreenExtentMax=FVector(0,0,0);

	}

	UBOOL NotWeaponHeuristic=(Owner->Owner!=Frame->Viewport->Actor);
	if( !Engine->Client->CurvedSurfaces )
		ExtraFlags |= PF_Flat;

	UBOOL bWire = Frame->Viewport->IsOrtho() || Frame->Viewport->Actor->RendMap==REN_Wire || mesh_showbones;
	UBOOL bHeatVision  = Frame->Viewport->Actor->CameraStyle == PCS_HeatVision;
	UBOOL bNightVision = Frame->Viewport->Actor->CameraStyle == PCS_NightVision;

	ARenderActor* RenderOwner = NULL;
	UBOOL lodActive;
	if ( !Owner->bIsRenderActor )
		lodActive = false;
	else 
	{
		RenderOwner = Cast<ARenderActor>( Owner );
		lodActive = ((mesh_lodactive && !bWire && (RenderOwner->LodMode < LOD_Disabled)&&!(Owner->MeshDecalLink )));
	}
	
	// FIXME: temporarily disable LOD if mesh decals are active on the model, due to the way the decals are currently handled
	// Same with heat vision
	//if (Owner->MeshDecalLink/* || bHeatVision*/)
	//	lodActive = 0;

	FLOAT LodLevel;

	// NJS: New LOD system
	// If lodActive is true, the object must be a RenderActor.  This code assumes that.
	if (lodActive)
	{
		FScreenBounds ScreenBounds;
		FBox Bounds = Owner->Mesh->GetRenderBoundingBox( Owner, 0 );
		
		// Is the mesh even visible?
		if (!GRender->BoundVisible(Frame, &Bounds, NULL, ScreenBounds))
			return;

		//FLOAT ModelArea=fabs((ScreenBounds.MaxX-ScreenBounds.MinX)*(ScreenBounds.MaxY-ScreenBounds.MinY))/**65.f*Owner->LodScale+Owner->LodOffset*/;
		//FLOAT ScreenArea=Frame->FX*Frame->FY;
		//FLOAT TargetScreenArea=ScreenArea/(640*480);
		//if(ScreenArea<=0) ScreenArea=0.001f;

		GlobalShapeLODAdjust=1.f; // NJS: Debugging


		FLOAT ModelHeight=RenderOwner->LodOffset+(fabs(ScreenBounds.MaxY-ScreenBounds.MinY)*6*RenderOwner->LodScale);
		FLOAT ScreenHeight=Frame->FY;
		// NEW STUFF: FIX:
		//if(ScreenHeight) LodLevel=ModelHeight/ScreenHeight;
		//else			 LodLevel=0.f; 
		if(!ScreenHeight) ScreenHeight=0.001f;
		LodLevel=ModelHeight/ScreenHeight; /*(appSqrt(ModelArea*(ModelArea/10))/appSqrt(ScreenArea));*/

		if(LodLevel>GlobalShapeLODAdjust)
		{
			LodLevel=GlobalShapeLODAdjust;
		} else if(LodLevel<0.001f)
		{
			if(RenderOwner->LodMode<LOD_StopMinimum)
				return; // full falloff, and too far away to see anything, so abort

			LodLevel=0.001f;
		}
		if(mesh_lodforcelevel>0.f)
			LodLevel=mesh_lodforcelevel;
		
		// LOD the actor lights:
		Owner->CurrentDesiredActorLights=((Owner->MaxDesiredActorLights+1)*LodLevel);
		if(Owner->CurrentDesiredActorLights<Owner->MinDesiredActorLights)	   Owner->CurrentDesiredActorLights=Owner->MinDesiredActorLights;
		else if(Owner->CurrentDesiredActorLights>Owner->MaxDesiredActorLights) Owner->CurrentDesiredActorLights=Owner->MaxDesiredActorLights;
	} else
	{		
		LodLevel=1.f;													// Assign 'full' lod level.
		Owner->CurrentDesiredActorLights=Owner->MaxDesiredActorLights;  // Don't LOD the actor lights.
	}

	FMemMark Mark(GMem);

	static SMacTri TempTris[4096];
	INT MaxVerts   =MeshInst->Mac->mGeometry->m_Verts.GetCount();

	// Get transformed verts.
	FTransTexture* Samples=NULL;
	BYTE* SeqHiddenTris = NULL;
	
	Samples = New<FTransTexture>(GMem, MaxVerts);
	
	// Start of main hotspot: EvaluateTris is a costly little bastardo:
	INT NumListTris = MeshInst->Mac->EvaluateTris(LodLevel, TempTris);
	STAT(clock(GStat.MeshGetFrameCycles));			// JEP
	INT NumVerts = MeshInst->GetFrame( &Samples->Point, NULL, sizeof(Samples[0]), bWire ? GMath.UnitCoords : Coords, LodLevel );
	STAT(unclock(GStat.MeshGetFrameCycles));			// JEP

	if ( Owner->bIsRenderActor && ((ARenderActor*) Owner)->bOwnerGetFrameOnly && (Owner->Owner == Frame->Viewport->Actor) )
		return;

	OCpjSequence* Seq = NULL;
	if ((Owner->AnimSequence!=NAME_None) && (Seq = MeshInst->Mac->FindSequence(appToAnsi(*Owner->AnimSequence))))
	{
		DWORD EventCount=Seq->m_Events.GetCount();
		for (DWORD i=0;i<EventCount;i++)
		{
			if (Seq->m_Events[i].eventType == SEQEV_TRIFLAGS)
			{
				SeqHiddenTris = (BYTE*)Seq->m_Events[i].paramString.Str();
				break;
			}
		}
	}

	INT NumTextures=MeshInst->Mac->mSurfaces[0]->m_Textures.GetCount();

	STAT(clock(GStat.MeshOutCodesCycles));			// JEP

	// NJS: Computing outcodes is hotspot #1:
	// Compute outcodes.
	BYTE Outcode = FVF_OutReject;

	if(DriverQueues) 
	{
		for( INT i=0; i<NumVerts; i++ )
		{
			Samples[i].Light.X = -1;
			
			// NJS: Ensure that this is faster:
			Samples[i].Normal.X=
			Samples[i].Normal.Y=
			Samples[i].Normal.Z=
			Samples[i].Normal.W=0;
			Samples[i].Flags=0;
		}
		Outcode=0;

	} else
	{
		for( INT i=0; i<NumVerts; i++ )
		{
			Samples[i].Light.X = -1;
			
			// NJS: Ensure that this is faster:
			Samples[i].Normal.X=
			Samples[i].Normal.Y=
			Samples[i].Normal.Z=
			Samples[i].Normal.W=0;
			Samples[i].ComputeOutcode( Frame );
			Outcode &= Samples[i].Flags;
		}

	}
	
	STAT(unclock(GStat.MeshOutCodesCycles));			// JEP

	// Handle wireframe without bones:
	// Render a wireframe view or textured view.
	if( bWire && !mesh_showbones)
	{
		Frame->Viewport->RenDev->PreRender(Frame);
		// Render each wireframe triangle.
		FPlane Color = Owner->bSelected ? FPlane(.2f,.8f,.1f,0.f) : FPlane(.6f,.4f,.1f,0.f);
		for( INT i=0; i<NumListTris; i++ )
		{
			SMacTri* Tri = &TempTris[i];
			FVector* P1 = &Samples[Tri->vertIndex[2]].Point;
			if (Tri->surfaceFlags & SRFTF_INACTIVE)
				continue;
			for( INT j=0; j<3; j++ )
			{
				FVector* P2 = &Samples[Tri->vertIndex[j]].Point;
				if ((Tri->surfaceFlags & SRFTF_TWOSIDED) || P1->X>=P2->X)
					Frame->Viewport->RenDev->Queue3DLine( Frame, Color, LINE_DepthCued, *P1, *P2 );
				P1 = P2;
			}
		}
		Frame->Viewport->RenDev->Queued3DLinesFlush(Frame);

		Mark.Pop();
		return;
	}
	// Handle wireframe with bones:
	else if ( bWire && mesh_showbones )
	{
		Frame->Viewport->RenDev->PreRender(Frame);

		// Render bone bounding boxes.
		if (!MeshInst->Mac->mSkeleton || !MeshInst->Mac->mGeometry)
		{
			Mark.Pop();
			return;
		}
		FPlane Color = Owner->bSelected ? FPlane(.2f,.8f,.1f,0.f) : FPlane(.6f,.4f,.1f,0.f);
		if ((!MeshInst->Mac->mTraceInfo) || (MeshInst->Mac->mTraceInfo->mTraceGeometry!=MeshInst->Mac->mGeometry) || (MeshInst->Mac->mTraceInfo->mTraceSkeleton!=MeshInst->Mac->mSkeleton))
			MeshInst->Mac->mTraceInfo = CMacTraceInfo::StaticFindInfo(MeshInst->Mac, MeshInst->Mac->mGeometry, MeshInst->Mac->mSkeleton);
		CMacTraceInfo* info = MeshInst->Mac->mTraceInfo;
		if (!info)
		{
			Mark.Pop();
			return;
		}
		FCoords MeshCoords = MeshInst->GetBasisCoords( bWire ? GMath.UnitCoords : Coords);
		for (DWORD i=0;i<info->mBoneBounds.GetCount();i++)
		{
			VBox3 box = info->mBoneBounds[i];
			box.c <<= MeshInst->Mac->mActorBones[i].GetCoords(true);
			//LOG_Logf("Box %d: pos (%f,%f,%f) dim (%f,%f,%f)", i, box.c.t.x, box.c.t.y, box.c.t.z, box.c.s.x, box.c.s.y, box.c.s.z);
			VVec3 boxPoints[8];
			FVector v[8];
			boxPoints[0] = VVec3(0,0,0) << box.c;
			boxPoints[1] = VVec3(0,1,0) << box.c;
			boxPoints[2] = VVec3(1,1,0) << box.c;
			boxPoints[3] = VVec3(1,0,0) << box.c;
			boxPoints[4] = VVec3(0,0,1) << box.c;
			boxPoints[5] = VVec3(0,1,1) << box.c;
			boxPoints[6] = VVec3(1,1,1) << box.c;
			boxPoints[7] = VVec3(1,0,1) << box.c;
			//FVector* v = (FVector*)&boxPoints[0];
			for (DWORD j=0;j<8;j++)
			{
				//LOG_Logf("v[%d] = %f,%f,%f", j, v[j].X, v[j].Y, v[j].Z);
				v[j] = FVector(boxPoints[j].x, boxPoints[j].y, boxPoints[j].z);
				v[j] = (v[j].ToUnr() - MeshInst->Mac->mDukeOrigin).TransformPointBy(MeshCoords);
			}
			Frame->Viewport->RenDev->Queue3DLine(Frame, Color, LINE_DepthCued, v[0], v[1]);
			Frame->Viewport->RenDev->Queue3DLine(Frame, Color, LINE_DepthCued, v[1], v[2]);
			Frame->Viewport->RenDev->Queue3DLine(Frame, Color, LINE_DepthCued, v[2], v[3]);
			Frame->Viewport->RenDev->Queue3DLine(Frame, Color, LINE_DepthCued, v[3], v[0]);
			Frame->Viewport->RenDev->Queue3DLine(Frame, Color, LINE_DepthCued, v[4], v[5]);
			Frame->Viewport->RenDev->Queue3DLine(Frame, Color, LINE_DepthCued, v[5], v[6]);
			Frame->Viewport->RenDev->Queue3DLine(Frame, Color, LINE_DepthCued, v[6], v[7]);
			Frame->Viewport->RenDev->Queue3DLine(Frame, Color, LINE_DepthCued, v[7], v[4]);
			Frame->Viewport->RenDev->Queue3DLine(Frame, Color, LINE_DepthCued, v[0], v[4]);
			Frame->Viewport->RenDev->Queue3DLine(Frame, Color, LINE_DepthCued, v[1], v[5]);
			Frame->Viewport->RenDev->Queue3DLine(Frame, Color, LINE_DepthCued, v[2], v[6]);
			Frame->Viewport->RenDev->Queue3DLine(Frame, Color, LINE_DepthCued, v[3], v[7]);
		}
		Frame->Viewport->RenDev->Queued3DLinesFlush(Frame);


		Mark.Pop();
		return;
	}

	// Coloring.
	FLOAT Unlit  = Clamp( Owner->ScaleGlow/* *0.5f */ + Owner->AmbientGlow/256.f, 0.f, 1.f );
	GUnlitColor  = FVector( Unlit, Unlit, Unlit );
	if( GIsEditor && (ExtraFlags & PF_Selected) )
		GUnlitColor = GUnlitColor*0.4f + FVector(0.0f,0.6f,0.0f);

	// Mesh based particle effects.
	if( Owner->bParticles )
	{
		if( !Owner->Texture )
		{
			Mark.Pop();
			return;
		}
	
		STAT(clock(GStat.MeshParticleCycles));		// JEP

		UTexture* Tex = Owner->Texture->Get( Frame->Viewport->CurrentTime );
		FTransform** SortedPts = New<FTransform*>(GMem,NumVerts);
		INT Count=0;
		FPlane Color = GUnlitColor;
		if( Owner->ScaleGlow!=1.f )
		{
			Color *= Owner->ScaleGlow;
			if( Color.X>1.f ) Color.X=1.f;
			if( Color.Y>1.f ) Color.Y=1.f;
			if( Color.Z>1.f ) Color.Z=1.f;
		}

		for( INT i=0; i<NumVerts; i++ )
		{
			if( !Samples[i].Flags && Samples[i].Point.Z>1.f )
			{
				Samples[i].Project( Frame );
				SortedPts[Count++] = &Samples[i];
			}
		}

		for( i=0; i<Count; i++ )
		{
			if( !SortedPts[i]->Flags )
			{
				UTexture* SavedNext = NULL;
				UTexture* SavedCur = NULL;
				if ( Tex )
				{
					FLOAT XSize = SortedPts[i]->RZ * Tex->USize * Owner->DrawScale;
					FLOAT YSize = SortedPts[i]->RZ * Tex->VSize * Owner->DrawScale;

					Frame->Viewport->Canvas->DrawIcon
					(
						Tex,
						SortedPts[i]->ScreenX - XSize/2,
						SortedPts[i]->ScreenY - XSize/2,
						XSize,
						YSize,
						SpanBuffer,
						Samples[i].Point.Z,
						Color,
						FPlane(0,0,0,0),
						ExtraFlags | PF_TwoSided | Tex->PolyFlags,
						0,
						true
					);
				}
				Tex->AnimNext = SavedNext;
				Tex->AnimCur  = SavedCur;
			}
		}
		Mark.Pop();
		
		STAT(unclock(GStat.MeshParticleCycles));		// JEP
		
		return;
	}
	
	STAT(clock(GStat.MeshSetupTrisCycles));			// JEP

	// Set up triangles.
	UBOOL IsSoftware = Frame->Viewport->RenDev->SpanBased;
	INT VisibleTriangles = 0;
	FMeshTriSortDuke* TriPool=NULL;
	if( Outcode == 0 )
	{
		// Process triangles.
		TriPool = New<FMeshTriSortDuke>(GMem,NumListTris);

		// Set up list for triangle sorting, adding all possibly visible triangles.
		FMeshTriSortDuke* TriTop = &TriPool[0];
		for( INT i=0; i<NumListTris; i++ )
		{
			SMacTri* Tri = &TempTris[i];
			//DWORD SurfIndex    = Tri->surfaceIndex;
			if(Tri->surfaceIndex) continue; // FIXME: skip decal triangles for now, need to find way to use them with new discrete LOD levels

			DWORD SurfTriFlags = Tri->surfaceFlags;

			FTransTexture& V1  = Samples[Tri->vertIndex[0]];
			FTransTexture& V2  = Samples[Tri->vertIndex[1]];
			FTransTexture& V3  = Samples[Tri->vertIndex[2]];

			// Compute triangle normal, only for primary surface
			//if (!Tri->surfaceIndex) //
			//{ //
				FVector TriNormal = (V1.Point-V2.Point) ^ (V3.Point-V1.Point);
				TriNormal *= DivSqrtApprox(TriNormal.SizeSquared()+0.001f);

				if (!(SurfTriFlags & SRFTF_VNIGNORE))
				{
					V1.Normal += TriNormal;
					V2.Normal += TriNormal;
					V3.Normal += TriNormal;
				}
			//} //

			if (SurfTriFlags & SRFTF_INACTIVE)							continue;
			if (SeqHiddenTris && (SeqHiddenTris[Tri->triIndex]-'0'))	continue;
			DWORD PolyFlags = ExtraFlags;

			if (SurfTriFlags & SRFTF_TWOSIDED) PolyFlags |= PF_TwoSided;

			// See if potentially visible.
			if( !(V1.Flags & V2.Flags & V3.Flags) )
			{
				if

				((PolyFlags & (PF_TwoSided|PF_Flat|PF_Invisible))!=(PF_Flat)
				||  Frame->Mirror*(V1.Point|TriNormal)<0.f )
				{
					// This is visible.
					TriTop->Tri = Tri;

					// Set the sort key.
					if (!IsSoftware)
					{
						TriTop->Key = (DWORD)Tri->texture;

					}
					else
					{
						FVector HackVector = FVector(0.f,-8.f,0.f);

						TriTop->Key
						=	NotWeaponHeuristic
						?	appRound( V1.Point.Z + V2.Point.Z + V3.Point.Z )
						:	appRound( FDistSquared(V1.Point,HackVector)*FDistSquared(V2.Point,HackVector)*FDistSquared(V3.Point,HackVector) );
					}

					// Add to list.
					VisibleTriangles++;
					TriTop++;
				}
			}
		}
	}

	STAT(unclock(GStat.MeshSetupTrisCycles));			// JEP

	// Render triangles.
	if( VisibleTriangles<=0 )
	{
		Mark.Pop();
		return;
	}

	GStat.MeshPolyCount += VisibleTriangles;

	// Sort by depth for software, or texture for hardware
	//if( Frame->Viewport->RenDev->SpanBased )
	try	{ Sort( TriPool, VisibleTriangles ); } catch(...) { debugf(_T("***** SORT FAILURE *****")); }
	// Lock the textures.
	UTexture* EnvironmentMap = NULL;
	check(NumTextures<=ARRAY_COUNT(TextureInfo));
	for( INT i=0; i<NumTextures; i++ )
	{
		Textures[i] = MeshInst->GetTexture( i );
		if( Textures[i] )
		{
			Textures[i] = Textures[i]->Get( Frame->Viewport->CurrentTime );
			INT ThisLOD = -1;//Mesh->TextureLOD.Num() ? Clamp<INT>( appCeilLogTwo(1+appFloor(256.f/(Detail*Mesh->TextureLOD(i)*Textures[i]->USize))), 0, 3 ) : 0;
			Textures[i]->Lock( TextureInfo[i], Frame->Viewport->CurrentTime, ThisLOD, Frame->Viewport->RenDev );
			EnvironmentMap = Textures[i];
		}
	}
	if( Owner->Texture )
		EnvironmentMap = Owner->Texture;
	else if( Owner->Region.Zone && Owner->Region.Zone->EnvironmentMap )
		EnvironmentMap = Owner->Region.Zone->EnvironmentMap;
	else if( Owner->Level->EnvironmentMap )
		EnvironmentMap = Owner->Level->EnvironmentMap;

	if ( bHeatVision )
	{
		UTexture* HeatMap = FindObject<UTexture>(ANY_PACKAGE, TEXT("t_detail.fabric.gendetfabric4RC"), 0);
		if (!HeatMap)
			HeatMap = LoadObject<UTexture>(NULL, TEXT("t_detail.fabric.gendetfabric4RC"), NULL, LOAD_None, NULL); // FIXME: inappropriate hardcoded texture name
		if (HeatMap && Owner->bIsRenderActor && ((ARenderActor*) Owner)->bHeated)
			EnvironmentMap = HeatMap;
	}
	
	if( EnvironmentMap==NULL )
	{
		Mark.Pop();
		return; //!!temporary work around for screwup
	}
	check(EnvironmentMap);
	EnvironmentMap->Lock( EnvironmentInfo, Frame->Viewport->CurrentTime, -1, Frame->Viewport->RenDev );

	STAT(clock(GStat.MeshLightingCycles));		// JEP

	// Build list of all incident lights on the mesh.
	ExtraFlags |= GLightManager.SetupForActor( Frame, Owner, LeafLights, Volumetrics );

	// *** Perform all vertex lighting ***
	for( i=0; i<VisibleTriangles; i++ )
	{
		SMacTri* Tri = TriPool[i].Tri;

		for( INT j=0; j<3; j++ )
		{
			FTransSample& Vert = Samples[Tri->vertIndex[j]];
			if( Vert.Light.X == -1 )
			{
				// Compute vertex normal.
				Vert.Normal = FPlane( Vert.Point, Vert.Normal * DivSqrtApprox(Vert.Normal.SizeSquared()+0.001f) );

				// Compute effect of each lightsource on this vertex.
				GLightManager.LightAndFog( Vert, ExtraFlags ); // Computes Vert.Light and Vert.Fog

				// Project it.
				if( !Vert.Flags )
					Vert.Project( Frame );
			}
		}
	}

	if (bHeatVision)
	{
		if (Owner->bIsRenderActor && ((ARenderActor*) Owner)->bHeated)
			StupidOptimizer(Frame, MeshInst, (ARenderActor*) Owner, Samples, NumVerts, Coords);
		else
		{	
			for (INT i=0;i<NumVerts;i++)
			{
				FTransSample& Vert = Samples[i];
				Vert.Light.X = 0.f;
				Vert.Light.Y = 0.f;
			}
		}
	} else if (bNightVision) 
	{
		for (INT i=0;i<NumVerts;i++)
		{
			FTransSample& Vert = Samples[i];
			Vert.Light.X = 0.f;
			Vert.Light.Y = 0.5f;
			Vert.Light.Z = 0.125f;
		}
	}

	STAT(unclock(GStat.MeshLightingCycles));		// JEP

	// Draw the triangles.
	//Frame->Viewport->RenDev->PreRender(Frame);
	Frame->Viewport->RenDev->QueuePolygonBegin(Frame);

	STAT(clock(GStat.MeshQueuePolygonCycles));		// JEP

	UBOOL* VertsExpanded = New<UBOOL>(GMem,MaxVerts);
	appMemzero(VertsExpanded, NumVerts*sizeof(UBOOL));

	DWORD SurfTriFlagsMask = 0xffffffff;
	if(mesh_notransparent) SurfTriFlagsMask &= ~SRFTF_TRANSPARENT;
	if(mesh_nomodulated)   SurfTriFlagsMask &= ~SRFTF_MODULATED;
	if(mesh_nomasking)		SurfTriFlagsMask &= ~SRFTF_MASKING;

	for (INT iPass=0; iPass<3; iPass++)
	{
		if ((iPass==2) && mesh_nospecular)
			continue;

		for( INT i=0; i<VisibleTriangles; i++ )
		{
			// Set up the triangle.
			SMacTri* Tri = TriPool[i].Tri;

			DWORD SurfTriFlags = Tri->surfaceFlags & SurfTriFlagsMask;

			DWORD ExFlags=PolyFlagsEx;
			if (SurfTriFlags & SRFTF_TEXBLEND) ExFlags|=PFX_AlphaMap;

			// Reject based on current pass
			UBOOL isTransparent = SurfTriFlags & (SRFTF_TRANSPARENT|SRFTF_MODULATED);
			if ( ((iPass==0) && (isTransparent))
			 ||  ((iPass==1) && (!isTransparent))
			 ||  ((iPass==2) && (Tri->glazeFunc == SRFGLAZE_NONE)) )
				continue;

			// Reject based on valid texture
			CCpjSrfTex* SurfTex = Tri->texture;
			if (iPass==2)
				SurfTex = Tri->glazeTexture;

			DWORD TexIndex = 0xffffffff;

			if (SurfTex)
				TexIndex = SurfTex - &MeshInst->Mac->mSurfaces[Tri->surfaceIndex]->m_Textures[0];

			if (TexIndex >= (DWORD)NumTextures)
				continue;

			//if(1) //(!(SurfTriFlags & SRFTF_HIDDEN) )
			{
				// Get texture.
				DWORD PolyFlags = ExtraFlags;
				if (SurfTriFlags & SRFTF_TWOSIDED)
					PolyFlags |= PF_TwoSided;
				if (iPass < 2)
				{
					if(SurfTriFlags & SRFTF_TRANSPARENT)  PolyFlags |= PF_Translucent;
					if(SurfTriFlags & SRFTF_UNLIT)		  PolyFlags |= PF_Unlit;
					if(SurfTriFlags & SRFTF_MASKING)      PolyFlags |= PF_Masked;
					if(SurfTriFlags & SRFTF_MODULATED)    PolyFlags |= PF_Modulated;
					if(SurfTriFlags & SRFTF_ENVMAP)		  PolyFlags |= PF_Environment;
				} else
				{
					PolyFlags |= PF_Translucent | PF_Flat;
				}

				FTextureInfo* Info = Info = (Textures[TexIndex] && !(PolyFlags & PF_Environment)) ? &TextureInfo[TexIndex] : &EnvironmentInfo;
				if (bHeatVision || bNightVision)
				{
					PolyFlags &= ~PF_Unlit;
					if (bHeatVision && Owner->bIsRenderActor && ((ARenderActor*) Owner)->bHeated)
						Info = &EnvironmentInfo;
				}
			
				
				UScale = Info->UScale * Info->USize /** (1.f/256.f)*/;
				VScale = Info->VScale * Info->VSize /** (1.f/256.f)*/;

				// Set up texture coords.
				FTransTexture* Pts[6];
				
				if (iPass < 2)
				{	
					// opaque and transparent pass
					Pts[0] = &Samples[Tri->vertIndex[0]];
					Pts[0]->U = Tri->texUV[0]->x * UScale;
					Pts[0]->V = Tri->texUV[0]->y * VScale;
					
					Pts[1] = &Samples[Tri->vertIndex[1]];
					Pts[1]->U = Tri->texUV[1]->x * UScale;
					Pts[1]->V = Tri->texUV[1]->y * VScale;

					Pts[2] = &Samples[Tri->vertIndex[2]];
					Pts[2]->U = Tri->texUV[2]->x * UScale;
					Pts[2]->V = Tri->texUV[2]->y * VScale;

				} else
				{
					FVector OriginalLightPos=FVector(0,0,0).TransformPointBy(Coords);
					// specular pass
					for( INT j=0; j<3; j++ )
					{
						FVector LightPosOrg(0,0,0), LightPosT;
						FVector LightPos = OriginalLightPos/*LightPosOrg.TransformPointBy(Coords)*/;
						FVector NormAxisX(1,0,0), NormAxisY(0,1,0);
						Pts[j] = &Samples[Tri->vertIndex[j]];

						FVector NormAxisZ = Pts[j]->Normal;
						
						if (Abs(NormAxisY | NormAxisZ) > 0.9997f)
							NormAxisY = FVector(0.7070f, 0.7070f, 0);

						NormAxisX = NormAxisY ^ NormAxisZ;
						NormAxisX.Normalize();
						NormAxisY = NormAxisZ ^ NormAxisX;
						NormAxisY.Normalize();
						LightPos -= Pts[j]->Point;
						LightPos.Normalize();
						LightPosT.X = LightPos | NormAxisX;
						LightPosT.Y = LightPos | NormAxisY;
						LightPosT.Z = LightPos | NormAxisZ;
						LightPosT.Normalize();
						FVector LightVector = LightPos - Pts[j]->Point;
						FLOAT LightSquared = LightVector.SizeSquared();
						FLOAT LightSize = SqrtApprox(LightSquared);
						FLOAT G = Square(1.f + (LightVector | Pts[j]->Normal) / LightSize) - 1.5f;
						FLOAT SpecMag = 1.f - G;
						FLOAT SpecU = SpecMag * LightPosT.X;
						FLOAT SpecV = SpecMag * LightPosT.Y;
						if(SpecU>1.f)  SpecU= 1.f;
						if(SpecU<-1.f) SpecU=-1.f;
						if(SpecV>1.f)  SpecV= 1.f;
						if(SpecV<-1.f) SpecV=-1.f;
						Pts[j]->U = (0.5f + (0.5f*SpecU)) * 128.f;
						Pts[j]->V = (0.5f + (0.5f*SpecV)) * 128.f;
						if (!VertsExpanded[Tri->vertIndex[j]])
						{
							FLOAT expandSize = mesh_specdist; // more = forcefield effect
							if (Owner == Frame->Viewport->Actor->Weapon)
								expandSize = mesh_wpnspecdist;
							Pts[j]->Point += Pts[j]->Normal*expandSize;
							Pts[j]->ComputeOutcode(Frame);
							Pts[j]->Project(Frame);
							VertsExpanded[Tri->vertIndex[j]] = 1;
						}
					}
				}

				if( Frame->Mirror == -1 )
					Exchange( Pts[2], Pts[0] );

				RenderSubsurface( true, Frame, *Info, Info->Texture, SpanBuffer, Pts, PolyFlags, ExFlags, 0, ComputeMeshExtent );
			}
		} // VisibleTriangles
	} // Pass

	STAT(unclock(GStat.MeshQueuePolygonCycles));		// JEP

	// JEP: Setup the actors projectors
	SetupActorForProjectors(Frame, Owner);				// JEP

	// Dump normal mesh polys:
	Frame->Viewport->RenDev->QueuePolygonEnd(Owner->ProjectorFlags);

	STAT(clock(GStat.MeshLightingCycles));				// JEP
	GLightManager.FinishActor();
	STAT(unclock(GStat.MeshLightingCycles));			// JEP

	for( i=0; i<NumTextures; i++ )
		if( Textures[i] )
			Textures[i]->Unlock( TextureInfo[i] );
	EnvironmentMap->Unlock( EnvironmentInfo );		

	// Mesh decals
	// NJS: Decals temporarilly disabled until texture locking handling can be improved.
	if (Owner->MeshDecalLink && !bHeatVision)
	{
		appMemzero(VertsExpanded, NumVerts*sizeof(UBOOL));
		CCpjGeoTri* GeoTris = &MeshInst->Mac->mGeometry->m_Tris[0];
		CCpjGeoVert* GeoVerts = &MeshInst->Mac->mGeometry->m_Verts[0];

		for(AMeshDecal* Decal = Owner->MeshDecalLink; Decal; Decal = Decal->MeshDecalLink)
		{
			if(!Decal->Texture) continue;

			for(INT i=0;i<Decal->Tris.Num();i++)
			{
				FMeshDecalTri* DecalTri = &Decal->Tris(i);
				DWORD PolyFlags = ExtraFlags | PF_Modulated | PF_MeshUVClamp;
				FTextureInfo Info;
				UTexture* Tex = Decal->Texture->Get(Frame->Viewport->CurrentTime);
				Tex->Lock(Info, Frame->Viewport->CurrentTime, -1, Frame->Viewport->RenDev);
				FLOAT UScale = Info.UScale * Info.USize;
				FLOAT VScale = Info.VScale * Info.VSize;
				FTransTexture* Pts[6];
				for(INT j=0;j<3;j++)
				{
					INT Index = GeoTris[DecalTri->TriIndex].edgeRing[j]->tailVertex - GeoVerts;
					Pts[j] = &Samples[Index];
					if (Pts[j]->Light.X == -1)
						break;

					Pts[j]->U = DecalTri->TexU[j] * UScale;
					Pts[j]->V = DecalTri->TexV[j] * VScale;

					if(!VertsExpanded[Index])
					{
						FLOAT expandSize = mesh_specdist; // more = forcefield effect
						if (Owner == Frame->Viewport->Actor->Weapon)
							expandSize = mesh_wpnspecdist;
						Pts[j]->Point += Pts[j]->Normal*expandSize;
						Pts[j]->ComputeOutcode(Frame);
						Pts[j]->Project(Frame);
						VertsExpanded[Index] = 1;
					} 
				}
				if(j==3)
				{
					if (Frame->Mirror==-1) Exchange(Pts[2], Pts[0]);
					RenderSubsurface(false, Frame, Info, Info.Texture, SpanBuffer, Pts, PolyFlags, 0, ComputeMeshExtent);					
				}

				Tex->Unlock(Info);
			}
		}
	}
	
	if(ComputeMeshExtent)
	{
		Owner->MeshLastScreenExtentMin=RenderSubsurface_MinExtent; //FVector(20,20,20); //RenderSubsurface_MinExtent;
		Owner->MeshLastScreenExtentMax=RenderSubsurface_MaxExtent; //FVector(200,200,100); //RenderSubsurface_MaxExtent;
	}


	Mark.Pop();
}

// Draw a mesh map.
void __fastcall URender::DrawMeshFast
(
	FSceneNode*		Frame,
	AActor*			Owner,
	AZoneInfo*		Zone,
	const FCoords&	Coords,
	DWORD			ExtraFlags,
	DWORD			PolyFlagsEx
)
{
	if (DisableMeshes) 
		return;

	if(!Owner->Mesh||!Owner->Mesh->IsA(UDukeMesh::StaticClass()))
	{
		debugf(_T("Attempted to render unsupported mesh format: %s"),Owner->GetName());
		return;
	}

	ExtraFlags |= PF_Flat; // Currently disabled curved surfaces, too much performance drain

	UDukeMesh			*Mesh = (UDukeMesh*)Owner->Mesh;
	UDukeMeshInstance	*MeshInst = Cast<UDukeMeshInstance>(Mesh->GetInstance(Owner));

	if (!MeshInst || !MeshInst->Mac || !MeshInst->Mac->mGeometry || !MeshInst->Mac->mSurfaces.GetCount() || !MeshInst->Mac->mSurfaces[0])
		return;

	// JEP: In editor, force bones to be dirty
	if (GIsEditor)
		MeshInst->Mac->bBonesDirty = true;

	bool DriverQueues=Frame->Viewport->RenDev->QueuePolygonDoes();

	FLOAT LodLevel=1.0f;		// Assign 'full' lod level.

	FMemMark Mark(GMem);

	static SMacTri	TempTris[4096];
	INT				MaxVerts = MeshInst->Mac->mGeometry->m_Verts.GetCount();

	// Get transformed verts.
	FTransTexture	*Samples=NULL;
	BYTE			*SeqHiddenTris = NULL;
	
	Samples = New<FTransTexture>(GMem, MaxVerts);
	
	// Start of main hotspot: EvaluateTris is a costly little bastardo:
	INT NumListTris = MeshInst->Mac->EvaluateTris(LodLevel, TempTris);
	STAT(clock(GStat.MeshGetFrameCycles));			// JEP
	INT NumVerts = MeshInst->GetFrame( &Samples->Point, NULL, sizeof(Samples[0]), Coords, LodLevel );
	STAT(unclock(GStat.MeshGetFrameCycles));			// JEP

	OCpjSequence	*Seq = NULL;

	if ((Owner->AnimSequence!=NAME_None) && (Seq = MeshInst->Mac->FindSequence(appToAnsi(*Owner->AnimSequence))))
	{
		DWORD EventCount=Seq->m_Events.GetCount();
		for (DWORD i=0;i<EventCount;i++)
		{
			if (Seq->m_Events[i].eventType == SEQEV_TRIFLAGS)
			{
				SeqHiddenTris = (BYTE*)Seq->m_Events[i].paramString.Str();
				break;
			}
		}
	}

	STAT(clock(GStat.MeshOutCodesCycles));			// JEP

	// NJS: Computing outcodes is hotspot #1:
	// Compute outcodes.
	BYTE Outcode = FVF_OutReject;

	if(DriverQueues) 
	{
		for( INT i=0; i<NumVerts; i++ )
		{
			Samples[i].Light.X = -1;
			
			// NJS: Ensure that this is faster:
			Samples[i].Normal.X=
			Samples[i].Normal.Y=
			Samples[i].Normal.Z=
			Samples[i].Normal.W=0;
			Samples[i].Flags=0;
		}
		Outcode=0;

	} else
	{
		for( INT i=0; i<NumVerts; i++ )
		{
			Samples[i].Light.X = -1;
			
			// NJS: Ensure that this is faster:
			Samples[i].Normal.X=
			Samples[i].Normal.Y=
			Samples[i].Normal.Z=
			Samples[i].Normal.W=0;
			Samples[i].ComputeOutcode( Frame );
			Outcode &= Samples[i].Flags;
		}

	}
	
	STAT(unclock(GStat.MeshOutCodesCycles));			// JEP

	STAT(clock(GStat.MeshSetupTrisCycles));			// JEP

	// Set up triangles.
	INT					VisibleTriangles = 0;
	FMeshTriSortDuke	*TriPool=NULL;

	if( Outcode == 0 )
	{
		// Process triangles.
		TriPool = New<FMeshTriSortDuke>(GMem,NumListTris);

		// Set up list for triangle sorting, adding all possibly visible triangles.
		FMeshTriSortDuke* TriTop = &TriPool[0];
		for( INT i=0; i<NumListTris; i++ )
		{
			SMacTri* Tri = &TempTris[i];

			if(Tri->surfaceIndex) 
				continue; // FIXME: skip decal triangles for now, need to find way to use them with new discrete LOD levels

			DWORD SurfTriFlags = Tri->surfaceFlags;

			FTransTexture& V1  = Samples[Tri->vertIndex[0]];
			FTransTexture& V2  = Samples[Tri->vertIndex[1]];
			FTransTexture& V3  = Samples[Tri->vertIndex[2]];

			if (SurfTriFlags & SRFTF_INACTIVE)							
				continue;
			if (SeqHiddenTris && (SeqHiddenTris[Tri->triIndex]-'0'))	
				continue;

			DWORD PolyFlags = ExtraFlags;

			if (SurfTriFlags & SRFTF_TWOSIDED) 
				PolyFlags |= PF_TwoSided;

			FVector TriNormal = (V1.Point-V2.Point) ^ (V3.Point-V1.Point);

			// See if potentially visible.
			if( !(V1.Flags & V2.Flags & V3.Flags) )
			{
				if ((PolyFlags & (PF_TwoSided|PF_Flat|PF_Invisible))!=(PF_Flat)
						||  Frame->Mirror*(V1.Point|TriNormal)<0.f )
				{
					// This is visible.
					TriTop->Tri = Tri;

					// Add to list.
					VisibleTriangles++;
					TriTop++;

					if (V1.Light.X == -1)
					{
						V1.Project(Frame);
						V1.Light.X = 0.0f;
					}
					if (V2.Light.X == -1)
					{
						V2.Project(Frame);
						V2.Light.X = 0.0f;
					}
					if (V3.Light.X == -1)
					{
						V3.Project(Frame);
						V3.Light.X = 0.0f;
					}
				}
			}
		}
	}

	STAT(unclock(GStat.MeshSetupTrisCycles));			// JEP

	// Render triangles.
	if( VisibleTriangles<=0 )
	{
		Mark.Pop();
		return;
	}

	GStat.MeshPolyCount += VisibleTriangles;

	// Draw the triangles.
	Frame->Viewport->RenDev->QueuePolygonBegin(Frame);

	STAT(clock(GStat.MeshQueuePolygonCycles));		// JEP

	for( INT i=0; i<VisibleTriangles; i++ )
	{
		// Set up the triangle.
		SMacTri		*Tri = TriPool[i].Tri;

		FTransTexture	*Pts[6];
				
		// opaque and transparent pass
		Pts[0] = &Samples[Tri->vertIndex[0]];
		Pts[1] = &Samples[Tri->vertIndex[1]];
		Pts[2] = &Samples[Tri->vertIndex[2]];

		if( Frame->Mirror == -1 )
			Exchange( Pts[2], Pts[0] );

		Frame->Viewport->RenDev->QueuePolygon(NULL, Pts, 3, 0, 0, NULL);
	} // VisibleTriangles

	STAT(unclock(GStat.MeshQueuePolygonCycles));		// JEP

	// Dump normal mesh polys:
	check(Frame&&Frame->Viewport&&Frame->Viewport->RenDev);
	Frame->Viewport->RenDev->QueuePolygonEnd();

	Mark.Pop();
}
