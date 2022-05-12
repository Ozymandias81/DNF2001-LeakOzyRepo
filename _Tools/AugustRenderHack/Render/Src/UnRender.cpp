/*=============================================================================
	UnRender.cpp: Main Unreal rendering functions and pipe
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

#include "..\..\Engine\Src\EnginePrivate.h"
#pragma hdrstop

/*-----------------------------------------------------------------------------
	Globals.
-----------------------------------------------------------------------------*/

#if STATS
FRenderStats GStat;
#endif

/*-----------------------------------------------------------------------------
	Object implementations.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(URender);

/*-----------------------------------------------------------------------------
	Profile variables:
-----------------------------------------------------------------------------*/
Profile	Profile_Frame;
Profile		Profile_Game  (&Profile_Frame,_T("Game"));
Profile		Profile_Client(&Profile_Frame,_T("Client"));
Profile	    Profile_Blit  (&Profile_Frame,_T("Blit"));

// JEP... (Projector/Shadow code)

// For marking nodes (and coplanars) as traversed this frame
static TArray<INT>		NodeFrameStamp;
static TArray<INT>		CoplanarNodeFrameStamp;

#define MAX_SHADOW_RENDER_TARGETS		(16)

#define MAX_WORK_SHADOW_ACTORS			(256)
#define MAX_VISIBLE_SHADOW_ACTORS		(16)
#define MAX_SHADOW_LIGHTS_PER_ACTOR		(3)
#define	MAX_SHADOW_LIGHTS				(128)

#define MAX_FINAL_SHADOW_ACTORS			(MAX_SHADOW_RENDER_TARGETS)

#define	MAX_PROJECTORS					(32)

// This structure holds the rendertargets we created at initialization, and which ones are free to use
struct RenderTargetInfo
{
	UBOOL				Active;
	void				*RenderTarget;
};

// This holds info about the projectors currently in the scene (built per frame, only by shadow casters currently)
struct ProjectorInfo
{
	FSceneNode			*Frame;
	INT					ProjectorIndex;
	FLOAT				wNear;
	FLOAT				wFar;
};

// Info about a light (used with the workshadowactor)
struct ShadowActorLight
{
	AActor				*Light;
	FSceneNode			*ShadowFrustum;
};

// This is the structure used to build up a list of actors, with lights.  
//	The final list will eventually be a FinalShadowActor
struct WorkShadowActor
{
	AActor				*Actor;
	FLOAT				Dist;			// Dist from viewer
	ShadowActorLight	Lights[MAX_SHADOW_LIGHTS_PER_ACTOR];
	INT					NumLights;
	INT					CurWorkingLight;
};

// This struct will hold the final actor/light pairs that will be used to generate the shadow projectors
struct FinalShadowActor
{
	AActor				*Actor;
	AActor				*Light;
	FSceneNode			*ShadowFrustum;

	INT					RenderCountdown;
	INT					RenderTargetIndex;
};

static UBOOL			ShadowRenderTargetsCreated = false;
static RenderTargetInfo	ShadowRenderTargets[MAX_SHADOW_RENDER_TARGETS];
static INT				NumShadowRenderTargets = 0;

// List of projectors to apply to the scene
static ProjectorInfo	Projectors[MAX_PROJECTORS];
static INT				NumProjectors = 0;

// This is used per actor, to build the list of lights (that will get sorted, and stuffed into the WorkShadowActor)
static AActor			*ShadowLights[MAX_SHADOW_LIGHTS];
static INT				NumShadowLights = 0;

// This is a temporary list used to build the final list
static WorkShadowActor	WorkShadowActors[MAX_WORK_SHADOW_ACTORS];
static INT				NumWorkShadowActors = 0;

// This is the list that ultimately gets rendered into projectors
static FinalShadowActor	FinalShadowActors[MAX_FINAL_SHADOW_ACTORS];
static INT				NumFinalShadowActors = 0;

// These are for remembering which actors were casting shadows last frame, so we can carry info from frame to frame (like rendercountdown, etc)
static FinalShadowActor	CachedFinalShadowActors[MAX_FINAL_SHADOW_ACTORS];
static INT				NumCachedFinalShadowActors = 0;

static UBOOL			EnableShadows = false;
static UBOOL			ForceShadows = false;
static UBOOL			ForceMeshShadows = false;
static INT				GMaxShadowLightsPerActor = 2;
static INT				GMaxFinalShadowActors = 16;

#define PSIDE_INVALID	(0)
#define PSIDE_FRONT		(1<<0)
#define PSIDE_BACK		(1<<1)
#define PSIDE_BOTH		(PSIDE_FRONT|PSIDE_BACK)

//=======================================================================================
//	BuildSideIndexesFromPlane
//	Precompute which sides of a box a plane is looking at (the indexes will index into contiguous set of Min/Max X,Y,Z's)
//=======================================================================================
__forceinline void BuildSideIndexesFromPlane(FPlane &Plane, INT *Indexes)
{
	for (INT i=0 ; i<3 ; i++)
	{
		if (((FVector&)Plane).Component(i) < 0)
		{
			Indexes[i] = i;
			Indexes[i+3] = i+3;
		}
		else
		{
			Indexes[i] = i+3;
			Indexes[i+3] = i;
		}
	}
}

//=======================================================================================
//	RejectAcceptFromSideIndexes
//	Using the pre-computed indexes, builds the Reject/Accept points of a box for a plane
//=======================================================================================
__forceinline void RejectAcceptFromSideIndexes(FBox &Box, INT *Indexes, FVector &Reject, FVector &Accept)
{
	//FLOAT	*Min = ((float*)&Box.Min);
	FLOAT	*Min = &Box.Min.X;

	Reject.X = Min[Indexes[0]];
	Reject.Y = Min[Indexes[1]];
	Reject.Z = Min[Indexes[2]];
	
	Accept.X = Min[Indexes[3]];
	Accept.Y = Min[Indexes[4]];
	Accept.Z = Min[Indexes[5]];
}

//=======================================================================================
//	BoxSideFast
//=======================================================================================
__forceinline INT BoxSideFast(const FPlane &Plane, FVector &Reject, FVector &Accept, FLOAT Epsilon)
{
	if (Plane.PlaneDot(Reject) < Epsilon)
		return PSIDE_BACK;

	if (Plane.PlaneDot(Accept) >= Epsilon)
		return PSIDE_FRONT;

	return PSIDE_BOTH;
}

//=======================================================================================
//	BoxSide
//	Determines if a box is totally inside, outside, or crossing a plane.
//	Does this by figureing out which 3 sides the plane is looking at, and builds a new set of Min/Max values
//=======================================================================================
__forceinline INT BoxSide(FPlane &Plane, FBox &Box, FLOAT Epsilon)
{
	INT				i;
	FVector			Reject(0,0,0), Accept(0,0,0);

	for (i=0 ; i<3 ; i++)
	{
		// Find Reject/Accept points (based on orientation of plane)
		if (((FVector&)Plane).Component(i) < 0)
		{
			Reject.Component(i) = Box.Min.Component(i);
			Accept.Component(i) = Box.Max.Component(i);
		}
		else
		{
			Reject.Component(i) = Box.Max.Component(i);
			Accept.Component(i) = Box.Min.Component(i);
		}
	}

	if (Plane.PlaneDot(Reject) < Epsilon)
		return PSIDE_BACK;

	if (Plane.PlaneDot(Accept) >= Epsilon)
		return PSIDE_FRONT;

	return PSIDE_BOTH;
}

//=========================================================================================
//	FindFreeRenderTarget
//=========================================================================================
static INT FindFreeRenderTarget()
{
	for (INT i = 0; i< NumShadowRenderTargets; i++)
	{
		if (!ShadowRenderTargets[i].Active)
		{
			ShadowRenderTargets[i].Active = true;
			return i;
		}
	}

	return -1;
}

//=========================================================================================
//	ResetRenderTargets
//=========================================================================================
static void ResetRenderTargets()
{
	for (INT i = 0; i< NumShadowRenderTargets; i++)
		ShadowRenderTargets[i].Active = false;
}

//=========================================================================================
//	CreateShadowRenderTargets
//=========================================================================================
static void CreateShadowRenderTargets(UViewport* Viewport, INT NumRenderTargets)
{
	if (ShadowRenderTargetsCreated)
		return;

	NumShadowRenderTargets = 0;

	debugf(TEXT("Created %i shadowcaster render targets"), NumShadowRenderTargets);

	ShadowRenderTargetsCreated = true;
	ResetRenderTargets();
}

//=========================================================================================
//	DestroyShadowRenderTargets
//=========================================================================================
static void DestroyShadowRenderTargets(UViewport* Viewport)
{
	if (!ShadowRenderTargetsCreated)
		return;

	NumShadowRenderTargets = 0;
	ShadowRenderTargetsCreated = false;
}

//=========================================================================================
//	GetNearFarFadeScaleFromLight
//=========================================================================================
static void GetNearFarFadeScaleFromLight(AActor *Light, FLOAT &wNear, FLOAT &wFar, FLOAT &FadeScale)
{
	// Override the values from the light if avail
	if (Light->IsA(ALight::StaticClass()))
	{
		ALight *LightActor = (ALight*)Light;

		wNear = LightActor->ProjectorNear;
		wFar = LightActor->ProjectorFar;
		FadeScale = LightActor->ProjectorFadeScale;
	}
	else
	{
		wNear		= 100.0f;
		wFar		= 200.0f;
		FadeScale	= 0.6f;
	}
}

//=========================================================================================
// Build a shadow caster frame.
//=========================================================================================
static FSceneNode *CreateShadowCasterFrame(FSceneNode *Parent, UViewport* Viewport, INT W, INT H, AActor *Light, AActor *Actor)
{
	// Get source and target locations
	FVector Source = Light->Location + FVector(0, 0, 0);
	FVector Target = Actor->Location + FVector(0, 0, 0);

	// Save old FOV from parent (we are gonna muck with it)
	float OldFovAngle = Parent->Viewport->Actor->FovAngle;

	// Set base info.
	FSceneNode* ShadowFrame	= new(GSceneMem)FSceneNode;
	ShadowFrame->Viewport	= Viewport;
	ShadowFrame->X			= W;
	ShadowFrame->Y			= H;
	ShadowFrame->XB			= 1;
	ShadowFrame->YB			= 1;
	ShadowFrame->Level		= Viewport->Actor->GetLevel();
	ShadowFrame->Parent		= Parent;
	ShadowFrame->Sibling	= NULL;
	ShadowFrame->Child		= NULL;
	ShadowFrame->iSurf		= INDEX_NONE;
	ShadowFrame->Recursion	= 0;
	ShadowFrame->Mirror		= 1.f;
	ShadowFrame->Recursion	= 0;
	ShadowFrame->NearClip	= FPlane(0.f,0.f,0.f,0.f);
	ShadowFrame->Draw[0]	= NULL;
	ShadowFrame->Draw[1]	= NULL;
	ShadowFrame->Draw[2]	= NULL;
	ShadowFrame->Sprite		= NULL;
	ShadowFrame->Span		= NULL;

	// Build a lookat vector
	FVector		Vector = Target-Source;
	
	Vector.Normalize();

	FRotator	Rotation = Vector.Rotation();

#if 1
	// Compute optimized FOV that will perfectly encapsulate the actor's mesh
	FLOAT wNear, wFar, FadeScale;
	GetNearFarFadeScaleFromLight(Light, wNear, wFar, FadeScale);
	
	FCoords LightCoords = (GMath.ViewCoords / Rotation) / Source;
	FBox LightSpaceBox = Actor->Mesh->GetRenderBoundingBox(Actor, 0 ).TransformBy(LightCoords);

	FLOAT HalfWidth = (LightSpaceBox.Max.X - LightSpaceBox.Min.X)*0.6f;
	FLOAT Depth = LightSpaceBox.Min.Z;

	wNear *= 0.50f;			// This is a kludge since we know that the render box is usually larger than it should be (need to do a better fix for this)
	//FLOAT wNear = 50.0f;

	if (Depth < wNear)
	{
		Source -= Vector*(wNear - Depth);
		Depth = wNear;
	}

	Parent->Viewport->Actor->FovAngle = appAtan(HalfWidth/Depth)/PI*360.0f;	// Same as aTan/PI*180*2
	
	// Don't let the FOV get too large or too small (because small objects will be have really sharp edges, and we don't want that)
	Parent->Viewport->Actor->FovAngle = Clamp<FLOAT>(Parent->Viewport->Actor->FovAngle, 25.0f, 70.0f);
#else
	// Just guess at what the FOV should be (faster)

	// Get the dist between target/source
	float Dist = (Target-Source).Size();

	if (Dist < 100)
		Parent->Viewport->Actor->FovAngle = 70.0f;
	else if (Dist < 200)
		Parent->Viewport->Actor->FovAngle = 50.0f;
	else if (Dist < 300)
		Parent->Viewport->Actor->FovAngle = 40.0f;
	else
		Parent->Viewport->Actor->FovAngle = 20.0f;

	// Don't let the light get too close, or the frustum will clip shadows incorrectly
	if (Dist < 100)
	{
		FVector Vect = Source-Target;

		Vect /= max(1.0f,Dist);

		Source += Vect*(100-Dist);
	}
#endif

	// Compute coords.
	ShadowFrame->ComputeRenderCoords( Source, Rotation );

	// Reset parent FOV
	Parent->Viewport->Actor->FovAngle = OldFovAngle;

	return ShadowFrame;
}

//=========================================================================================
//	CompareShadowActors
//=========================================================================================
static QSORT_RETURN CDECL CompareShadowActors( const WorkShadowActor *A, const WorkShadowActor *B)
{
	if (A->Dist > B->Dist)
		return 1;
	else if (A->Dist < B->Dist)
		return -1;

	return 0;
}

//=========================================================================================
//	CompareShadowLights
//=========================================================================================
static QSORT_RETURN CDECL CompareShadowLights( const AActor **A, const AActor **B)
{
	if ((*A)->LightingTag < (*B)->LightingTag)
		return 1;
	else if ((*A)->LightingTag > (*B)->LightingTag)
		return -1;

	return 0;
}

//=========================================================================================
//	FindShadowActorLights
//=========================================================================================
static void FindShadowActorLights(FSceneNode *Frame, WorkShadowActor *SActor, FPlane **Planes, INT NumPlanes)
{
	AActor *Actor = SActor->Actor;

	NumShadowLights = 0;

	if (!Actor->bUnlit
	&& Actor->Region.iLeaf!=INDEX_NONE
	&& Frame->Level->Model->Leaves.Num()
	&& Frame->Viewport->Actor->RendMap==REN_DynLight 
	&& !Frame->Viewport->GetOuterUClient()->NoLighting)
	{
		FLeaf &Leaf = Frame->Level->Model->Leaves(Actor->Region.iLeaf);

		if (Leaf.iPermeating != INDEX_NONE)
		{
			for(INT i=Leaf.iPermeating; Frame->Level->Model->Lights(i); i++ )
			{
				if (NumShadowLights >= MAX_SHADOW_LIGHTS)
					break;

				AActor *Light = Frame->Level->Model->Lights(i);

				if (ForceShadows)
				{
					if (!Light->AffectMeshes) 
						continue;
				}
				else
				{
					if (!Light->bActorShadows)
						continue;
				}

				FLOAT DistSquared = FDistSquared(Actor->Location,Light->Location);
				FLOAT Radius      = Light->WorldLightRadius();

				//if (DistSquared < 100*100)
				//	continue;

				if(Light->bSpecialLit != Actor->bSpecialLit || DistSquared > Square(Radius))
					continue;
				
				FCheckResult Hit(0);
				if (!Frame->Level->Model->LineCheck(Hit, NULL, Light->Location, Actor->Location, FVector(0,0,0), 0 ))
					continue;

				// Generate sort tag
				Light->LightingTag = appRound((1.0-SqrtApprox(DistSquared)/Radius) * Light->LightBrightness * 1024);
				//Light->LightingTag = Radius - SqrtApprox(DistSquared);

				ShadowLights[NumShadowLights++] = Light;
			}
		}

		// Sort the lights by dist
		appQsort(&ShadowLights[0], NumShadowLights, sizeof(ShadowLights[0]), (QSORT_COMPARE)CompareShadowLights);
	}
	
	// Reset number of lights on WorkShadowActor
	SActor->NumLights = 0;
	SActor->CurWorkingLight = 0;

	// Clamp to maximum number of lights on an actor (since they are sorted, this will take the closest ones)
	if (NumShadowLights > MAX_SHADOW_LIGHTS_PER_ACTOR)
		NumShadowLights = MAX_SHADOW_LIGHTS_PER_ACTOR;

	if (NumShadowLights > GMaxShadowLightsPerActor)
		NumShadowLights = GMaxShadowLightsPerActor;

	for (INT j = 0; j < NumShadowLights; j++)
	{
		AActor	*Light = ShadowLights[j];

		// Only add light if the lights shadow frustum is visible
	
		// Create shadow frustum
		#define SHADOW_FRUSTUM_WIDTH		(126)

		FSceneNode *ShadowFrustum = CreateShadowCasterFrame(Frame, Frame->Viewport, SHADOW_FRUSTUM_WIDTH, SHADOW_FRUSTUM_WIDTH, ShadowLights[j], Actor);

		// Setup wNear/wFar/FadeScale
		FLOAT	wNear, wFar, FadeScale;
		GetNearFarFadeScaleFromLight(Light, wNear, wFar, FadeScale);
		
		// Setup box in light space
		FBox		Box;
		FLOAT		Ratio = (wFar*ShadowFrustum->RProj.Z);
		FLOAT		HalfExtent = SHADOW_FRUSTUM_WIDTH*Ratio*0.5f;

		Box.Min.X =-HalfExtent;
		Box.Max.X = HalfExtent;

		Box.Min.Y =-HalfExtent;
		Box.Max.Y = HalfExtent;

		Box.Min.Z = wNear;
		Box.Max.Z = wFar;
		
		// First, do sphere to frustum test (this may be sufficient)
		FVector		Center = (Box.Min+Box.Max)*0.5f;
		FLOAT		RadiusSq = FDistSquared(Center,Box.Min);

		// Transform sphere into world space (where the camera frustum is)
		Center = Center.TransformPointBy(ShadowFrustum->Uncoords);

		for(INT i=0; i<NumPlanes; i++ )
		{
			FLOAT Dot = Planes[i]->PlaneDot(Center);
			if (Dot<0.0f && Square(Dot)>RadiusSq)
				break;
		}

		if (i != NumPlanes)
			continue;			// Don't add this light

	#if 1
		// Test box against frustum (transform frustum into box to get the equivalent of an OBB test, rather than an AABB)
		for(i=0; i<NumPlanes; i++ )
		{
			if (BoxSide(Planes[i]->TransformPlaneByOrtho(ShadowFrustum->Coords), Box, 0.001f) == PSIDE_BACK)
				break;
		}

		if (i != NumPlanes)
			continue;			// Don't add this light
	#endif

		// Store the light, and frustum for later use (when we build the final shadow list)
		SActor->Lights[SActor->NumLights].Light = Light;
		SActor->Lights[SActor->NumLights++].ShadowFrustum = ShadowFrustum;
	}
}

//=========================================================================================
//	BuildShadowCasterList
//=========================================================================================
void BuildShadowCasterList(FSceneNode *Frame, TArray<AActor*> &Relevent)
{
	AActor			*MainActor = Frame->Viewport->Actor;
	INT				ActorCount;
	FPlane			*Planes[5];

	// Add default planes
	for (INT p=0; p<4; p++)
		Planes[p] = &Frame->ViewPlanes[p];

	// Add front plane
	FPlane	FrontPlane;

	FrontPlane.X = 0.0f;
	FrontPlane.Y = 0.0f;
	FrontPlane.Z = 1.0f;
	FrontPlane.W = 20.0f;
	
	FrontPlane = FrontPlane.TransformPlaneByOrtho(Frame->Uncoords);

	Planes[4] = &FrontPlane;


	// Reset the list
	NumWorkShadowActors = 0;

	//
	//	Build main working actor set of all MAX_WORK_SHADOW_ACTORS closest actors, and get the most important ones
	//

	// Add main player by default
	if (MainActor->Mesh)
	{
		WorkShadowActors[NumWorkShadowActors].Actor = MainActor;
		WorkShadowActors[NumWorkShadowActors].Dist = 0.0f;
		NumWorkShadowActors++;
	}

#if 0
	ActorCount = Frame->Viewport->Actor->XLevel->Actors.Num();
#else
	ActorCount = Relevent.Num();
#endif

	for (INT iActor=0;iActor<ActorCount;iActor++)
	{
		if (NumWorkShadowActors >= MAX_WORK_SHADOW_ACTORS)
			break;

	#if 0
		AActor  *Actor = Frame->Viewport->Actor->XLevel->Actors(iActor);
	#else
		AActor	*Actor = Relevent(iActor);
			
		if(!Actor) 
			break;
	#endif
			
		Actor->ProjectorFlags = 0xffffffff;

		if (Actor == MainActor)
			continue;			// Already in list

		if (!Actor) 
			continue;

		if (Actor->DrawType!=DT_Mesh)
			continue;

		if (!Actor->Mesh)
			continue;

		if (!Actor->bShadowCast && !ForceShadows)
			continue;
		
		FLOAT Dist = (MainActor->Location - Actor->Location).Size();

		if (Dist > 2000)
			continue;

	#if 0
		// See if the mesh is visible (will be wrong, but faster)
		FBox			Bounds;
		FScreenBounds	ScreenBounds;

		Bounds = Actor->Mesh->GetRenderBoundingBox(Actor, 0 );

		if (!GRender->BoundVisible(Frame, &Bounds, NULL, ScreenBounds))
			continue;
	#endif

		WorkShadowActors[NumWorkShadowActors].Actor = Actor;
		WorkShadowActors[NumWorkShadowActors].Dist = Dist;

		NumWorkShadowActors++;
	}
	
	// Sort actors by distance
	appQsort(&WorkShadowActors[0], NumWorkShadowActors, sizeof(WorkShadowActors[0]), (QSORT_COMPARE)CompareShadowActors);

	// Reset all the rendertargets so they will all be avail
	ResetRenderTargets();

	// Build the light list on the actors
	INT NumVisibleShadowActors = 0;
	
	for (INT i=0; i<NumWorkShadowActors;i++)
	{
		if (NumVisibleShadowActors >= MAX_VISIBLE_SHADOW_ACTORS)
			break;			// Stop when enough actors have lights

		FindShadowActorLights(Frame, &WorkShadowActors[i], Planes, 5);

		if (WorkShadowActors[i].NumLights)
			NumVisibleShadowActors++;		// The actor got some lights, increase the visible actors
	}

	// Set the number of actors to last one encountered
	INT	NumWorkShadowActorsToUse = i;
	
	// Build final list to use as actor shadows
	NumFinalShadowActors = 0;

	while(1)
	{
		UBOOL AddedActor = false;

		for (INT i = 0; i < NumWorkShadowActorsToUse; i++)
		{
			FinalShadowActor	*FSActor = &FinalShadowActors[NumFinalShadowActors];
			WorkShadowActor		*SActor = &WorkShadowActors[i];

			if (NumFinalShadowActors >= MAX_FINAL_SHADOW_ACTORS)
				break;

			if (NumFinalShadowActors >= GMaxFinalShadowActors)
				break;

			if (SActor->CurWorkingLight >= SActor->NumLights)
				continue;

			FSActor->Actor = SActor->Actor;
			FSActor->Light = SActor->Lights[SActor->CurWorkingLight].Light;
			FSActor->ShadowFrustum = SActor->Lights[SActor->CurWorkingLight].ShadowFrustum;
			
			// See if this actor/light combo was used last frame
			for (INT j = 0; j < NumCachedFinalShadowActors; j++)
			{
				if (CachedFinalShadowActors[j].Actor == FSActor->Actor && 
					CachedFinalShadowActors[j].Light == FSActor->Light)
					break;
			}
			
			if (j == NumCachedFinalShadowActors)
			{
				// Not found
				FSActor->RenderCountdown = 0;
				FSActor->RenderTargetIndex = -1;		// So we'll know to set it up later
			}
			else
			{
				// Copy and mark RenderTargetIndex as used
				FSActor->RenderTargetIndex = CachedFinalShadowActors[j].RenderTargetIndex;
				ShadowRenderTargets[FSActor->RenderTargetIndex].Active = true;

				FSActor->RenderCountdown = CachedFinalShadowActors[j].RenderCountdown -1;

				if (FSActor->RenderCountdown < 0)
					FSActor->RenderCountdown = NumFinalShadowActors;//min(8, WorkShadowActors[i].Dist / 100);
			}

			NumFinalShadowActors++;

			SActor->CurWorkingLight++;

			AddedActor = true;
		}

		if (!AddedActor)
			break;
	}

	// Remember actors so we can see if we re-use them next frame
	for (i = 0; i < NumFinalShadowActors; i++)
	{
		FinalShadowActor	*FSActor = &FinalShadowActors[i];

		if (FSActor->RenderTargetIndex == -1)
			FSActor->RenderTargetIndex = FindFreeRenderTarget();

		CachedFinalShadowActors[i] = FinalShadowActors[i];
	}

	GStat.NumFinalShadowActors = NumFinalShadowActors;

	NumCachedFinalShadowActors = NumFinalShadowActors;
}

//=========================================================================================
//	BuildShadowCasters
//=========================================================================================
static void BuildShadowCasters(FSceneNode *Frame, TArray<AActor*> &Relevent)
{
	INT				i, ProjectorIndex = 0;

	// Build list of actors that will cast shadows
	BuildShadowCasterList(Frame, Relevent);
		
	NumProjectors = 0;

	// Render and setup the frames for all the final shadow actors
	for (i=0; i< NumFinalShadowActors; i++)
	{
		FinalShadowActor	*FSActor = &FinalShadowActors[i];

		if (NumProjectors >= MAX_PROJECTORS)
			break;

		if (FSActor->RenderTargetIndex == -1)
			continue;

		AActor	*Actor = FSActor->Actor;
		AActor	*Light = FSActor->Light;

		UBOOL	Render = true;

		if (FSActor->RenderCountdown != 0)
			Render = false;

		// Create the shadow frustum frame
		FSceneNode *ShadowFrame = FSActor->ShadowFrustum;

		void *RenderTarget = ShadowRenderTargets[FSActor->RenderTargetIndex].RenderTarget;

		if (!RenderTarget)
			continue;

		if (Render)
		{
			// Render actor from lights POV
			GRender->DrawMeshFast(ShadowFrame, Actor, Actor->Region.Zone, ShadowFrame->Coords, 0);
			
			GStat.NumRenderedFinalShadowActors++;
		}

		// Setup wNear/wFar/FadeScale
		FLOAT	wNear, wFar, FadeScale;
		GetNearFarFadeScaleFromLight(Light, wNear, wFar, FadeScale);

		// Add this projector to the list to be occluded later
		Projectors[NumProjectors].Frame = ShadowFrame;
		Projectors[NumProjectors].ProjectorIndex = NumProjectors;
		Projectors[NumProjectors].wNear = wNear;
		Projectors[NumProjectors].wFar = wFar;
		NumProjectors++;

		//GRender->OccludeProjector(ShadowFrame, NumProjectors);
	}

	// Restore the rendering devices current frame	
	Frame->Viewport->RenDev->SetSceneNode( Frame );
}

//=========================================================================================
//	SetupActorForProjectors
//	NOTEZ - This functions assumes that the projector list has been built
//=========================================================================================
void __fastcall URender::SetupActorForProjectors(FSceneNode *Frame, AActor *Actor)
{
	if (Frame->Recursion != 0)
		return;

	if (!(Actor->bShadowReceive || ForceMeshShadows) || !Actor->Mesh)
	{
		Actor->ProjectorFlags = 0;
		return;
	}
	
	FBox RenderBox = Actor->Mesh->GetRenderBoundingBox(Actor, 0 );

	for (INT p = 0; p < NumProjectors; p++)
	{
		DWORD Mask = (1<<p);

		if (!(Actor->ProjectorFlags & Mask))
			continue;		// Don't bother if this projector has already been removed

		for (INT i = 0; i < 4; i++)
		{
			if (BoxSide(Projectors[p].Frame->ViewPlanes[i], RenderBox, 0.001f) == PSIDE_BACK)
				break;		
		}

		if (i != 4)
			Actor->ProjectorFlags &= ~Mask;	// Box is totally outside the projector frustum, remove it from the actor
	}
}
// ...JEP

/*-----------------------------------------------------------------------------
	Globals.
-----------------------------------------------------------------------------*/

// URender statics.
DWORD 								URender::Stamp;
FMemStack							URender::VectorMem;
URender::FStampedPoint*				URender::PointCache;
URender::FDynamicsCache*			URender::DynamicsCache;
INT									URender::NumDynLightSurfs;
INT									URender::NumDynLightLeaves;
INT									URender::MaxSurfLights;
INT									URender::MaxLeafLights;
FActorLink**						URender::SurfLights=NULL;
FVolActorLink**						URender::LeafLights=NULL;
INT									URender::DynLightSurfs[MAX_DYN_LIGHT_SURFS];
INT									URender::DynLightLeaves[MAX_DYN_LIGHT_LEAVES];

// Optimization globals.
INT         GFrameStamp=0;
FSceneNode* GFrame;
FBspNode*   GNodes;
FBspSurf*   GSurfs;
FVert*      GVerts;
TArray<FVector>* GPoints;
//INT			GLODActorLights;

/*-----------------------------------------------------------------------------
	URender init & exit.
-----------------------------------------------------------------------------*/

//
// Constructor.
//
URender::URender()
{
	// Validate stuff.
	if(sizeof(*this)!=GetClass()->GetPropertiesSize())
		appErrorf( TEXT("Render size mismatch: C=%i U=%i"), sizeof(*this), GetClass()->GetPropertiesSize() );
	check((INT) FBspNode::MAX_NODE_VERTICES<=(INT) FPoly::MAX_VERTICES);
	check(sizeof(FVector)==12);
	check(sizeof(FRotator)==12);
	check(sizeof(FCoords)==48);
}

//
// Static class initializer.
//
void URender::StaticConstructor()
{
}

//
// Initialize the rendering engine and allocate all temporary buffers.
// Calls appError if failure.
//
void URender::Init( UEngine* InEngine )
{
	// Init subsystems.
	GDynMem.Init( 65536 );
	GSceneMem.Init( 32768 );

	Engine = InEngine;

	// Set global render pointer.
	GRender = this;

	// Init.
	NumDynLightSurfs  = 0;
	NumDynLightLeaves = 0;
	GlobalMeshLOD     = 1.f;
	GlobalShapeLOD    = 1.f;
	GlobalShapeLODAdjust    = 1.f;
	ShapeLODMode      = 1;
	ShapeLODFix       = 1.f;

	// Allocate rendering stuff.
	PointCache		= new(TEXT("FStampedPoint" ))FStampedPoint[MAX_POINTS];
	DynamicsCache   = new(TEXT("FDynamicsCache"))FDynamicsCache[MAX_NODES];
	appMemzero( DynamicsCache, MAX_NODES * sizeof(FDynamicsCache) );

	GCache.Flush();

	// Caches.
	for( INT i=0; i<MAX_POINTS;  i++ )
		PointCache [i].Stamp = Stamp;
	VectorMem.Init( 16384 );

	// Init stats.
	STAT(appMemzero(&GStat,sizeof(GStat));)
	//GLODActorLights = 0;

	// Light manager.
	GLightManager.Init();

	debugf( NAME_Init, TEXT("Render core initialized.") );
}

//
// Shut down the rendering engine
//
void URender::Destroy()
{
	// JEP...
	NodeFrameStamp.Empty();
	CoplanarNodeFrameStamp.Empty();
	// ...JEP

	GDynMem.Exit();
	GSceneMem.Exit();

	delete PointCache;
	delete DynamicsCache;
	if( SurfLights ) appFree(SurfLights);
	if( LeafLights ) appFree(LeafLights);

	SurfLights = NULL;
	MaxSurfLights = 0;

	LeafLights = NULL;
	MaxLeafLights = 0;

	//GLightManager.Exit(); does nothing anyways
	VectorMem.Exit();

	debugf( NAME_Exit, TEXT("Rendering shut down") );

	Super::Destroy();
}

//
// Precache.
//
void URender::Precache( UViewport* Viewport )
{
	for( TObjectIterator<UModel> ItM; ItM; ++ItM )
	{
		for( INT i=0; i<ItM->Surfs.Num(); i++ )
		{
			FBspSurf& ItS= ItM->Surfs(i);
			UTexture* It = ItS.Texture;
			if( It )
			{
				//oldver: Since some Unreal 1 textures were imported without masking,
				// we must fix them up here.
				//DWORD Flags = ItM->Surfs(i).PolyFlags&(PF_Masked|PF_NoSmooth);
				//if( Flags )
				//{
				//	ItM->Surfs(i).Texture->PolyFlags |= Flags;
				//}
				if( !It->bParametric )
				{
					FTextureInfo T;
					It->Lock( T, Viewport->LastUpdateTime, -1, Viewport->RenDev );
					Viewport->RenDev->PrecacheTexture( T, It->PolyFlags|ItS.PolyFlags );
					It->Unlock( T );
				}
			}
		}
	}
	
	for( TObjectIterator<UTexture> It; It; ++It )
	{
		if( !It->bParametric )
		{
			FTextureInfo T;
			It->Lock( T, Viewport->LastUpdateTime, -1, Viewport->RenDev );
			Viewport->RenDev->PrecacheTexture( T, It->PolyFlags );
			It->Unlock( T );
		}
	}
}

/*-----------------------------------------------------------------------------
	URender Stats display.
-----------------------------------------------------------------------------*/

static QSORT_RETURN CDECL CompareFunctions( const UFunction** A, const UFunction** B )
{
	__int64 DeltaCycles=((*B)->ProfileCycles-(*B)->ProfileChildrenCycles) - ((*A)->ProfileCycles-(*A)->ProfileChildrenCycles);
	if(DeltaCycles<0) return -1;
	if(DeltaCycles>0) return 1;
	return 0;
}

// JEP ...
#define MAX_COLLISION_FRAMES		(10)
#define MAX_COLLISION_MS_FRAMES		(10)

static float	NumCollisions[MAX_COLLISION_FRAMES];
static INT		NumCollisionFrames = 0;
static float	NumCollisionMS[MAX_COLLISION_MS_FRAMES];
static INT		NumCollisionMSFrames = 0;

static INT		PeekCollisionCount;
static INT		PeekCollisionCycles;
static INT		PeekSetMeshCycles;

static float __forceinline GetAvgValue(float *Table, INT *Marker, float NewEntry, INT MaxEntries)
{
	float AvgValue = 0.0f;

	Table[*Marker] = NewEntry;
	*Marker = ((*Marker)+1)%MaxEntries;

	for (INT i = 0; i < MaxEntries; i++)
		AvgValue += Table[i];

	AvgValue /= MaxEntries;

	return AvgValue;
}

// ... JEP

void Profile::Show( URender* RenDev, FSceneNode* Frame, int Depth )
{		
	if(Depth==0)
	{
		RenDev->ShowStat(Frame, _T("  Cur  |  Avg  |  Min  |  Max  |   MS  | Calls | Description       "));
		RenDev->ShowStat(Frame, _T("-------------------------------------------------------------------"));
	}

	// Show myself:
	//ShowStat(Frame, _T("  %3.1f"),1000*FrameTime);

	double Percent=0.0;
	if(!Parent) Percent=100.0;
	else if(Parent->TotalCycles)
	{
		Percent=((double)TotalCycles/(double)Parent->TotalCycles)*100.0;
	}


	if(!RunningAveragePercent) RunningAveragePercent=Percent;
	else 
	{
		RunningAveragePercent+=Percent;
		RunningAveragePercent/=2;
	}

	     if(Percent<MinPercent)	MinPercent=Percent;
	else if(Percent>MaxPercent)	MaxPercent=Percent;

	double Milliseconds=TotalCycles*GSecondsPerCycle*1000.0;
	RenDev->ShowStat(Frame,_T(" %3.1f%%  %3.1f%%   %3.1f%%   %3.1f%% %3.1fms  %5i  %s "), Percent,RunningAveragePercent,MinPercent,MaxPercent,Milliseconds,TimesCalled,Description);

	// Display each of my children, recursively.

	Depth++;
	// Collapse any of my children recursively:
	for(Profile *Iterator=FirstChild;Iterator;Iterator=Iterator->NextSibling)
		if(Iterator->Expanded)
			Iterator->Show(RenDev,Frame,Depth);

	TotalCycles=0;

}

void URender::DrawStats( FSceneNode* Frame )
{
	EndTime          = appSeconds();
	DOUBLE FrameTime  = EndTime - LastEndTime;
	DOUBLE RenderTime = EndTime - StartTime;
	TCHAR TempStr[8192];

	Frame->Viewport->Canvas->Color = FColor(255,255,255);


	if( FpsStats )
	{
		Frame->Viewport->Canvas->CurX=0;
		Frame->Viewport->Canvas->CurY=Frame->Y-10;
		Frame->Viewport->Canvas->WrappedPrintf
		(
			Frame->Viewport->Canvas->SmallFont,
			1,
			TEXT("Frame=%05.1f MSEC Render=%05.1f MSEC Nodes=%03i Polys=%03i"),
			1000.f * FrameTime,
			1000.f * RenderTime,
			NodesDraw,
			PolysDraw
		);
	}
#if STATS
	Frame->Viewport->Canvas->CurX=0;
	Frame->Viewport->Canvas->CurY=16;

	if( ProfileStats )
	{
		Profile_Frame.Show(this, Frame);
		//ShowStat(Frame, _T("  Cur  |  Avg  |  Min  |  Max  |   MS  | Calls | Description       "));
		//ShowStat(Frame, _T("-------------------------------------------------------------------"));
		//ShowStat(Frame, _T("  %3.1f"),1000*FrameTime);

		//ShowStat(Frame, Profile_Frame.GetStatString());
	}

	if( GlobalStats )
	{

		ShowStat( Frame, TEXT("GLOBAL:") );
		ShowStat
		(
			Frame,
			TEXT("  FRAME=%04.1f: GAME=%04.1f CLI=%04.1f BLIT=%04.1f "),
			1000*FrameTime,
			GSecondsPerCycle*1000 * Engine->GameCycles,
			GSecondsPerCycle*1000 * (Engine->ClientCycles-Frame->Viewport->GetOuterUClient()->DrawCycles),
			GSecondsPerCycle*1000 * Frame->Viewport->GetOuterUClient()->DrawCycles,
			1000*Abs(FrameTime - GSecondsPerCycle*Engine->TickCycles)
		);
		ShowStat
		(
			Frame,
			TEXT("  NewObjects=%i ReplacedObjects=%i TOBJS=%i Preloads=%i LazyLoads=%i"),
			GNumNewObjects,
			GNumReplacedObjects,
			UObject::GObjObjects.Num(),
			GNumPreloads,
			GNumLazyLoads
		);
		Frame->Viewport->Actor->GetLevel()->GetStats( TempStr );
		ShowStat( Frame, TEXT("  %s"), TempStr );
		ShowStat
		(
			Frame,
			TEXT("  RENDER=%04.1f MESH=%04.1f POLYV=%04.1f ILLUM=%04.1f OCC=%04.1f FILT=%04.1f EX=%04.1f DECAL=%04.1f DECALCLIP=%04.1f DECAL#=%d BREJ=%04.1f"),
			1000 * RenderTime,
			GSecondsPerCycle*1000 * GStat.MeshTime,
			GSecondsPerCycle*1000 * GStat.PolyVTime,
			GSecondsPerCycle*1000 * GStat.IllumTime,
			GSecondsPerCycle*1000 * GStat.OcclusionTime,
			GSecondsPerCycle*1000 * GStat.FilterTime,
			GSecondsPerCycle*1000 * GStat.ExtraTime,
			GSecondsPerCycle*1000 * GStat.DecalTime,
			GSecondsPerCycle*1000 * GStat.DecalClipTime,
			GStat.DecalCount,
			GSecondsPerCycle*1000 * GStat.BoxIsVisibleCycles		// JEP
		);
		
		// JEP ...

		if (GStat.SetMeshCycles > PeekSetMeshCycles)
			PeekSetMeshCycles = GStat.SetMeshCycles;

		ShowStat
		(
			Frame,
			TEXT("  MOUNTPHYS=%04.1f SETMESH=%04.1f PEEKSETMESH=%04.1f GETFRAME=%04.1f GETMOUNT=%04.1f MOUNNTRENDER=%04.1f"),
			GSecondsPerCycle*1000 * GStat.MountPhysCycles,
			GSecondsPerCycle*1000 * GStat.SetMeshCycles,
			GSecondsPerCycle*1000 * PeekSetMeshCycles,
			GSecondsPerCycle*1000 * GStat.GetFrameCycles,
			GSecondsPerCycle*1000 * GStat.GetMountCoordsCycles,
			GSecondsPerCycle*1000 * GStat.MeshMountRenderCycles
		);

		ShowStat
		(
			Frame,
			TEXT("  MGETFRAME=%04.1f MOUTCODES=%04.1f MSETUPTRIS=%04.1f MLIGHT=%04.1f MPART=%04.1f MQUEUE=%04.1f"),
			GSecondsPerCycle*1000 * GStat.MeshGetFrameCycles,
			GSecondsPerCycle*1000 * GStat.MeshOutCodesCycles,
			GSecondsPerCycle*1000 * GStat.MeshSetupTrisCycles,
			GSecondsPerCycle*1000 * GStat.MeshLightingCycles,
			GSecondsPerCycle*1000 * GStat.MeshParticleCycles,
			GSecondsPerCycle*1000 * GStat.MeshQueuePolygonCycles
		);
		// ... JEP

		ShowStat( Frame, TEXT(" ") );
	}
	else
	{
		PeekSetMeshCycles = 0;
	}

	static UBOOL OldNetStats=0;
	if( NetStats )
	{
		UNetConnection* Conn;
		if( ( Frame->Level->NetDriver && (Conn=Frame->Level->NetDriver->ServerConnection)!=NULL ) ||
			( Frame->Level->DemoRecDriver && (Conn=Frame->Level->DemoRecDriver->ServerConnection)!=NULL )
		)
		{
			INT ChCount=0;
			for( INT i=0; i<UNetConnection::MAX_CHANNELS; i++ )
				ChCount += (Conn->Channels[i]!=NULL);
			ShowStat( Frame, TEXT("NET (IN/OUT):") );
			ShowStat( Frame, TEXT("  % 4i          Ping"),          (INT)(1000.f*Conn->BestLag));
			ShowStat( Frame, TEXT("  % 4i          Channels"),      (INT)ChCount );
			ShowStat( Frame, TEXT("  % 4i    % 4i  Unordered/Sec"), (INT)Conn->InOrder, (INT)Conn->OutOrder );
			ShowStat( Frame, TEXT(" % 4i%%   % 4i%%  Packet Loss"), (INT)Conn->InLoss, (INT)Conn->OutLoss );
			ShowStat( Frame, TEXT("% 6i  % 6i  Packets/Sec"),       (INT)Conn->InPackets, (INT)Conn->OutPackets );
			ShowStat( Frame, TEXT("% 6i  % 6i  Bunches/Sec"),       (INT)Conn->InBunches, (INT)Conn->OutBunches );
			ShowStat( Frame, TEXT("% 6i%s % 6i%s Bytes/Sec"),       (INT)Conn->InRate,  Conn->InRate *0.95f>Conn->CurrentNetSpeed ? "*" : " ", (INT)Conn->OutRate, Conn->OutRate*0.95f>Conn->CurrentNetSpeed ? "*" : " " );
			ShowStat( Frame, TEXT("% 6i  % 6i  %sSpeed"),           (INT)Conn->CurrentNetSpeed, (INT)Conn->CurrentNetSpeed, (Frame->Level->NetDriver && Frame->Level->NetDriver->ServerConnection->URL.HasOption(TEXT("LAN"))) ? TEXT("Lan") : TEXT("Net") );
			ShowStat( Frame, TEXT(" ") );
			static DOUBLE SavedTime=0.f;
			if( SavedTime!=Conn->StatUpdateTime )
			{
				SavedTime = Conn->StatUpdateTime;
				if( !OldNetStats )
				{
					debugf( TEXT("Ping  Ch Loss IRate ORate IBnch OBnch  IPkt  OPkt ILoss OLoss") );
					debugf( TEXT("---- --- ---- ----- ----- ----- ----- ----- ----- ----- -----") );
				}
				debugf
				(
					TEXT("% 4i % 3i % 3i%% % 5i % 5i % 5i % 5i % 5i % 5i % 5i % 5i"),
					(INT)(1000.f*Conn->BestLag),
					(INT)ChCount,
					(INT)Conn->InLoss,
					(INT)Conn->InRate,
					(INT)Conn->OutRate,
					(INT)Conn->InBunches,
					(INT)Conn->OutBunches,
					(INT)Conn->InPackets,
					(INT)Conn->OutPackets,
					(INT)Conn->InLoss,
					(INT)Conn->OutLoss
				);
			}
		}
	}
	OldNetStats = NetStats;
	if( ActorChanStats )
	{
		UNetConnection* Conn;
		if( ( Frame->Level->NetDriver && (Conn=Frame->Level->NetDriver->ServerConnection)!=NULL ) ||
			( Frame->Level->DemoRecDriver && (Conn=Frame->Level->DemoRecDriver->ServerConnection)!=NULL )
		)
		{
			INT ChCount=0;
			for( INT i=0; i<UNetConnection::MAX_CHANNELS; i++ )
				ChCount += (Conn->Channels[i]!=NULL);
			ShowStat( Frame, TEXT("Net Channels (%i Current)"), ChCount );
			ShowStat( Frame, TEXT("Index Class                 Topic                               Owner") );
			ShowStat( Frame, TEXT("----- -----                 -----                               -----") );
			for ( i=0; i<UNetConnection::MAX_CHANNELS; i++ )
			{
				UChannel* CurChannel = Conn->Channels[i];
				if ( CurChannel )
				{
					if ( CurChannel->IsA( UActorChannel::StaticClass() ) )
					{
						if ( ((UActorChannel*) CurChannel)->Actor->Owner != NULL)
							ShowStat( Frame, TEXT("%5i %-22s %-35s %-s"), i, CurChannel->GetClass()->GetName(), ((UActorChannel*) CurChannel)->Actor->GetName(), ((UActorChannel*) CurChannel)->Actor->Owner->GetName() );
						else
							ShowStat( Frame, TEXT("%5i %-22s %-35s %-s"), i, CurChannel->GetClass()->GetName(), ((UActorChannel*) CurChannel)->Actor->GetName(), TEXT("None") );
					}
					else if ( CurChannel->IsA( UFileChannel::StaticClass() ) )
						ShowStat( Frame, TEXT("%5i %-22s %-35s"), i, CurChannel->GetClass()->GetName(), ((UFileChannel*) CurChannel)->Filename );
					else
						ShowStat( Frame, TEXT("%5i %-22s"), i, CurChannel->GetClass()->GetName() );
				}
			}
		}
	}
	if( HardwareStats )
	{
		ShowStat( Frame, TEXT("HARDWARE:") );
		Frame->Viewport->RenDev->GetStats( TempStr );
		ShowStat( Frame, TempStr );
		//ShowStat( Frame, TEXT("  %s"), TempStr );
		ShowStat( Frame, TEXT(" ") );
		Frame->Viewport->RenDev->DrawStats( Frame );
	}
	if( MeshStats )
	{
		extern INT mesh_InstanceCount;

		ShowStat( Frame, TEXT("MESH: %04.1f"), GSecondsPerCycle*1000 * GStat.MeshTime );
		ShowStat
		(
			Frame,
			TEXT("  GetFrame=%04.1f Process=%04.1f LightSet=%04.1f Light=%04.1f"),
			GSecondsPerCycle*1000 * GStat.MeshGetFrameTime,
			GSecondsPerCycle*1000 * GStat.MeshProcessTime,
			GSecondsPerCycle*1000 * GStat.MeshLightSetupTime,
			GSecondsPerCycle*1000 * GStat.MeshLightTime
		);
		ShowStat
		(
			Frame,
			TEXT("  Sub=%04.1f Clip=%04.1f Tmap=%04.1f"),
			GSecondsPerCycle*1000 * GStat.MeshSubTime,
			GSecondsPerCycle*1000 * GStat.MeshClipTime,
			GSecondsPerCycle*1000 * GStat.MeshTmapTime
		);
		
		ShowStat
		(
			Frame,
			TEXT("  MeshCount=%i MeshPolyCount=%i MeshSubCount=%i MeshLights=%i MeshVtrics=%i VertLights=%i MeshInstCount=%i"),
			GStat.MeshCount,
			GStat.MeshPolyCount,
			GStat.MeshSubCount,
			GStat.MeshLightCount,
			GStat.MeshVtricCount,
			GStat.MeshVertLightCount,
			mesh_InstanceCount
		);
		ShowStat( Frame, TEXT(" ") );
		/*
		// actor mesh lighting stats (LOD actor lighting)
		ShowStat
		(
			Frame,
			TEXT("  LODActorLights=%i"),
			GLODActorLights
		);
		ShowStat( Frame, TEXT(" ") );
		*/
	}

	if( MemoryStats )
	{
		const double Megabytes=1024*1024;
		// Get windows memory status
		MEMORYSTATUS stat;
		GlobalMemoryStatus (&stat);
		ShowStat(Frame,TEXT("%ld%% of memory currently in use, Physical memory:%.2lfM / %.2lfM, Page file:%.2lfM / %.2lfM, Virtual memory:%.2lfM / %.2lfM"),
							stat.dwMemoryLoad,
							(stat.dwTotalPhys-stat.dwAvailPhys)/Megabytes, stat.dwTotalPhys/Megabytes,		 
							(stat.dwTotalPageFile-stat.dwAvailPageFile)/Megabytes, stat.dwTotalPageFile/Megabytes,
							(stat.dwTotalVirtual-stat.dwAvailVirtual)/Megabytes,stat.dwTotalVirtual/Megabytes);
		HANDLE ProcessHeaps[512];
		DWORD NumberHeaps=GetProcessHeaps(ARRAY_COUNT(ProcessHeaps),ProcessHeaps);

		DWORD Data=0;
		DWORD Overhead=0;

		for(DWORD i=0;i<NumberHeaps;i++)
		{
			PROCESS_HEAP_ENTRY he;
			ZeroMemory(&he,sizeof(he));

			while(HeapWalk(ProcessHeaps[i],&he))
			{
				Data+=he.cbData;
				Overhead+=he.cbOverhead;
			}

			if(GetLastError()!=ERROR_NO_MORE_ITEMS)
				ShowStat(Frame,TEXT("*** Heap %i has serious problems (failed a HeapWalk) ***"),i);

		}

		ShowStat(Frame,TEXT("Local heaps:%u, Total:%.2lfM = (Data:%.2lfM + Overhead:%.2lfM) "),NumberHeaps,(Data+Overhead)/Megabytes,Data/Megabytes,Overhead/Megabytes);
		ShowStat(Frame,GMalloc->GetAllocsStats());
	}

	if(ActorStats)
	{
		int Pawns=0, Brushes=0, Items=0, Lights=0, Triggers=0, Other=0, Empty=0, RenderActor=0;

		INT NumActors=Frame->Level->Actors.Num();
		for( INT iActor=0; iActor<NumActors; iActor++ )
		{
			AActor *current=Frame->Level->Actors(iActor);
			if(!current) Empty++;
			else
			{
					 if(current->IsA(APawn::StaticClass()))		  Pawns++;
				else if(current->IsA(AItem::StaticClass()))		  Items++;
				else if(current->IsA(ALight::StaticClass()))	  Lights++;
				else if(current->IsA(ATrigger::StaticClass()))    Triggers++;
				else if(current->IsA(ABrush::StaticClass()))      Brushes++;
				else Other++; // Unknown actor type

				if(current->IsA(ARenderActor::StaticClass()))	  RenderActor++;
			}
		}
		//Frame->Level->Actors()
		ShowStat
		( 
			Frame, 
			TEXT("Actor: Total=%i (RenderActor=%i) (Alist:%i/Blist:%i) Ticked=%i (Pawns=%i Brushes=%i Items=%i Lights=%i Triggers=%i Other=%i Empty=%i)"),
			NumActors,
			RenderActor,
			NumActors-GStat.BListedActors,
			GStat.BListedActors,
			Frame->Viewport->Actor->GetLevel()->TickedActors,
			Pawns,
			Brushes,
			Items, 
			Lights,
			Triggers,
			Other,
			Empty
		);
	}

	static bool didFunctions=false;

	if( FunctionStats )
	{
		ShowStat(Frame,TEXT("                                                    Function   total ms     calls    ms/call  ") );
		ShowStat(Frame,TEXT("------------------------------------------------------------  ----------  -------- -----------") );
		TArray<UFunction*> List;
		for( TObjectIterator<UFunction> ItF; ItF; ++ItF )
		{
			if(!didFunctions)
			{
				ItF->ProfileCalls=0;
				ItF->ProfileCycles=0;
				ItF->ProfileChildrenCycles=0;
			}
			if( ItF->ProfileCalls!=0 )
				List.AddItem( *ItF );
		}
		appQsort( &List(0), List.Num(), sizeof(List(0)), (QSORT_COMPARE)CompareFunctions );

		int max=List.Num();
		if(max>50) max=50;
		for( INT i=0; i<max; i++ )
		{
			double ms=1000.0*GSecondsPerCycle*(DOUBLE)(List(i)->ProfileCycles-List(i)->ProfileChildrenCycles);
			ShowStat
			(
				Frame,
				TEXT("%60s  %10.1f  %8u  %.2f"),
				List(i)->GetPathName(),
				ms,
				List(i)->ProfileCalls,
				ms/(DOUBLE)List(i)->ProfileCalls
			);
		}
		didFunctions=true;
	} else 
		didFunctions=false;

	
	if( ZoneStats )
	{
		ShowStat
		(
			Frame,
			TEXT("Zones: Visible=%i/%i Reject=%i"),
			GStat.VisibleZones,
			GStat.NumZones,
			GStat.MaskRejectZones
		);
		ShowStat( Frame, TEXT(" ") );
	}
	if( LightStats )
	{
	}
	if( OcclusionStats )
	{
		ShowStat
		(
			Frame,
			TEXT("Occlusion=%04.1f:"),
			GSecondsPerCycle*1000 * GStat.OcclusionTime
		);
		ShowStat
		(
			Frame,
			TEXT("   Clip=%04.1f Raster=%04.1f Span=%04.1f Visit=%i/%i Points=%i"),
			GSecondsPerCycle*1000 * GStat.ClipTime,
			GSecondsPerCycle*1000 * GStat.RasterTime,
			GSecondsPerCycle*1000 * GStat.SpanTime,
			GStat.NodesDone,
			GStat.NodesTotal,
			GStat.NumPoints
		);
		ShowStat
		(
			Frame,
			TEXT("   Transform=%i Clip=%i Raster=%i RasterAccept=%i DrawNodes=%i"),
			GStat.NumTransform,
			GStat.NumClip,
			GStat.NumRasterPolys+GStat.NumRasterBoxReject,
			GStat.NumRasterPolys,
			NodesDraw
		);
		ShowStat
		(
			Frame,
			TEXT("   BoxTime=%04.1f BoxChecks=%i BoxBacks=%i BoxIn=%i BoxOutPyr=%i BoxSpanOcc=%i"),
			GSecondsPerCycle*1000 * GStat.BoxTime,
			GStat.BoxChecks,
			GStat.BoxBacks,
			GStat.BoxIn,
			GStat.BoxOutOfPyramid,
			GStat.BoxSpanOccluded
		);
		ShowStat( Frame, TEXT(" ") );
	}
	if( GameStats )
	{
		ShowStat( Frame, TEXT("GAME:") );
		Frame->Viewport->Actor->GetLevel()->GetStats( TempStr );
		ShowStat( Frame, TEXT("   %s"), TempStr );
		ShowStat( Frame, TEXT(" ") );
	}
	if( SoftStats )
	{
	}
	if( CacheStats )
	{
		ShowStat( Frame, TEXT("CACHE:") );
		GCache.Status( TempStr );
		ShowStat( Frame, TEXT("   %s"), TempStr );
		ShowStat( Frame, TEXT(" ") );
	}
	// JEP ...
	if (CollisionStats)
	{
		float AvgCollisionsPerFrame=0.0f, AvgCollisionMSPerFrame=0.0f;

		AvgCollisionsPerFrame = GetAvgValue(NumCollisions, &NumCollisionFrames, GStat.CollisionCount, MAX_COLLISION_FRAMES);
		AvgCollisionMSPerFrame = GetAvgValue(NumCollisionMS, &NumCollisionMSFrames, GSecondsPerCycle*1000 * GStat.CollisionCycles, MAX_COLLISION_MS_FRAMES);
		
		if (GStat.CollisionCount > PeekCollisionCount)
			PeekCollisionCount = GStat.CollisionCount;

		if (GStat.CollisionCycles > PeekCollisionCycles)
			PeekCollisionCycles = GStat.CollisionCycles;

		ShowStat( Frame, TEXT("COLLISION:") );
		ShowStat
		(
			Frame,
			TEXT("  CC=%i PeekCC=%i AvgCC=%f CMS=%04.1f PeekCMS=%04.1f AvgCMS==%04.1f"),
			GStat.CollisionCount,
			PeekCollisionCount,
			AvgCollisionsPerFrame,
			GSecondsPerCycle*1000 * GStat.CollisionCycles,
			GSecondsPerCycle*1000 * PeekCollisionCycles,
			AvgCollisionMSPerFrame
		);
	}
	else
	{
		PeekCollisionCount = 0;
		PeekCollisionCycles = 0;
	}

	if (ProjectorStats)
	{
		ShowStat( Frame, TEXT("Projector:") );
		ShowStat
		(
			Frame,
			TEXT("   SHADACT=%i RSHADACT=%i PROJSURFS=%i OCCLPROJMS=%04.1f RNDSHDMS=%04.1f"),
			GStat.NumFinalShadowActors, 
			GStat.NumRenderedFinalShadowActors, 
			GStat.NumProjectorSurfs,
			GSecondsPerCycle*1000 * GStat.OccludeProjectorCycles,
			GSecondsPerCycle*1000 * GStat.ShadowRenderCycles
		);
	}
	// ... JEP

#endif // STATS
	
	// JEP: Moved here from PreRender 
	//	(safer to clear after you are done with the stats, rather than to try and guess when to clear them beforehand)
	STAT(appMemzero(&GStat,sizeof(GStat)));			
}

//
// Show one statistic and update the pointer.
//
void URender::ShowStat( FSceneNode* Frame, const TCHAR* Fmt, ... )
{
	TCHAR TempStr[16384];
	GET_VARARGS( TempStr, ARRAY_COUNT(TempStr), Fmt );

	Frame->Viewport->Canvas->WrappedPrintf( Frame->Viewport->Canvas->SmallFont, 0, TEXT(" %s\n"), TempStr );
}

/*-----------------------------------------------------------------------------
	URender PreRender & PostRender.
-----------------------------------------------------------------------------*/

//
// Set up for rendering a frame.
//
static FMemMark Mark;
void URender::PreRender( FSceneNode* Frame )
{
	// Init stats.
	//STAT(appMemzero(&GStat,sizeof(GStat)));			// JEP: Moved to just after DrawStats
	Profile_Frame.Stop();
	Profile_Frame.Start();

	LastEndTime = EndTime;
	StartTime   = appSeconds();

	// Init counts.
	NodesDraw		= 0;
	PolysDraw		= 0;

	// Bump the iteration count.
	Mark = FMemMark(GMem);

	// Set math to low precision.
	appEnableFastMath(1);

	// Tick stuff.
	GRandoms.Tick( Frame->Viewport->Actor->GetLevel()->GetLevelInfo()->TimeSeconds );
}

#if defined(LEGEND) //LEGEND
static void ComputeActorMeshLighting( FSceneNode* Frame )
{
	// default properties stored in ZoneInfo.uc
	INT MinActorLights = 6;
	INT MaxActorLights = 6;
	INT MinLODPolys = 1000;
	INT MaxLODPolys = 5000;

	// extract min/max lighting properties from the current zone (clamp to required limits)
	AZoneInfo* ZoneInfo = Frame->Viewport->Actor->Region.Zone;
	check( ZoneInfo != NULL );
	check( ZoneInfo->MinLightCount > 0 );
	check( ZoneInfo->MaxLightCount > 0 );
	MinActorLights = Max( (INT)ZoneInfo->MinLightCount, 1 );
	MaxActorLights = Min( (INT)ZoneInfo->MaxLightCount, 16 );
	if( MinActorLights > MaxActorLights )
	{
		MinActorLights = MaxActorLights;
	}
	MinLODPolys = ZoneInfo->MinLightingPolyCount;
	MaxLODPolys = ZoneInfo->MaxLightingPolyCount;

	// interpolate between the min/max actor lights and min/max polys (clamped to min/max actor lights)
	if( GStat.MeshPolyCount > MaxLODPolys )
		GLODActorLights = MinActorLights;
	else if( GStat.MeshPolyCount < MinLODPolys )
		GLODActorLights = MaxActorLights;
	else
		GLODActorLights = ( MaxActorLights - MinActorLights ) 
			* ( (FLOAT)( MaxLODPolys - GStat.MeshPolyCount ) / ( MaxLODPolys - MinLODPolys ) ) 
			+ MinActorLights;
}
#endif

//
// Clean up after rendering a frame.
//
EXECVAR_HELP(UBOOL, video_capture, false, "turns on video capturing");

void URender::PostRender( FSceneNode* Frame )
{
#if defined(LEGEND) //LEGEND
	ComputeActorMeshLighting( Frame );
#endif

	// Restore default precision.
	appEnableFastMath(0);

	// Draw whatever stats were requested.
	if( Frame->Viewport->Actor->RendMap==REN_Polys || 
		Frame->Viewport->Actor->RendMap==REN_PolyCuts || 
		Frame->Viewport->Actor->RendMap==REN_DynLight || 
		Frame->Viewport->Actor->RendMap==REN_PlainTex )
		DrawStats( Frame );

	if(video_capture)
		Frame->Viewport->Exec(_T("QUICKSHOT"),*GLog);
}

/*-----------------------------------------------------------------------------
	URender command line.
-----------------------------------------------------------------------------*/

//
// Execute a command line.
//
UBOOL URender::Exec( const TCHAR* Cmd, FOutputDevice& Ar )
{
	const TCHAR* Str = Cmd;
	if( ParseCommand(&Str,TEXT("STAT")) )
	{
			 if( ParseCommand(&Str,TEXT("Net"         )) ) NetStats       ^= 1;
		else if( ParseCommand(&Str,TEXT("ActorChannel")) ) ActorChanStats ^= 1;
		else if( ParseCommand(&Str,TEXT("Fps"         )) ) FpsStats       ^= 1;
		else if( ParseCommand(&Str,TEXT("Global"      )) ) GlobalStats    ^= 1;
		else if( ParseCommand(&Str,TEXT("Mesh"        )) ) MeshStats      ^= 1;
		else if( ParseCommand(&Str,TEXT("Actor"       )) ) ActorStats     ^= 1;
		else if( ParseCommand(&Str,TEXT("Function"    )) ) FunctionStats  ^= 1;
		else if( ParseCommand(&Str,TEXT("Filter"      )) ) FilterStats    ^= 1;
		else if( ParseCommand(&Str,TEXT("Reject"      )) ) RejectStats    ^= 1;
		else if( ParseCommand(&Str,TEXT("Span"        )) ) SpanStats      ^= 1;
		else if( ParseCommand(&Str,TEXT("Zone"        )) ) ZoneStats      ^= 1;
		else if( ParseCommand(&Str,TEXT("Light"       )) ) LightStats     ^= 1;
		else if( ParseCommand(&Str,TEXT("Occlusion"   )) ) OcclusionStats ^= 1;
		else if( ParseCommand(&Str,TEXT("Game"        )) ) GameStats      ^= 1;
		else if( ParseCommand(&Str,TEXT("Soft"        )) ) SoftStats      ^= 1;
		else if( ParseCommand(&Str,TEXT("Cache"       )) ) CacheStats     ^= 1;
		else if( ParseCommand(&Str,TEXT("PolyV"       )) ) PolyVStats     ^= 1;
		else if( ParseCommand(&Str,TEXT("PolyC"       )) ) PolyCStats     ^= 1;
		else if( ParseCommand(&Str,TEXT("Illum"       )) ) IllumStats     ^= 1;
		else if( ParseCommand(&Str,TEXT("Hardware"    )) ) HardwareStats  ^= 1;
		else if( ParseCommand(&Str,TEXT("Memory"	  )) ) MemoryStats    ^= 1;
		else if( ParseCommand(&Str,TEXT("Collision"	  )) ) CollisionStats ^= 1;
		else if( ParseCommand(&Str,TEXT("Projector"	  )) ) ProjectorStats ^= 1;
		else											   ProfileStats   ^=1;
		return 1;
	}
	else if( ParseCommand(&Str,TEXT("REND")) )
	{
		if      (ParseCommand(&Str,TEXT("LEAK")))	  LeakCheck		 ^= 1;
		else if (ParseCommand(&Str,TEXT("T")))		  Toggle		 ^= 1;
		else return 0;
		Ar.Log( TEXT("Rendering option recognized") );
		return 1;
	}
	else if( ParseCommand(&Str,TEXT("TLOD")) )
	{
		if( !appStrcmp(Str, TEXT("")) )
		{
			Ar.Logf( TEXT("%f"), (FLOAT)GlobalMeshLOD );
			return 1;
		}
		if( appAtof(Str)>0 )
			GlobalMeshLOD = appAtof(Str);
		Ar.Logf( TEXT("Global mesh texture LOD distance %f"), (FLOAT)GlobalMeshLOD );
		return 1;
	}
	else if( ParseCommand(&Str,TEXT("MLOD")) )
	{
		if( !appStrcmp(Str, TEXT("")) )
		{
			Ar.Logf( TEXT("%f"), (FLOAT)GlobalShapeLOD );
			return 1;
		}
		if( appAtof(Str)>0 )
			GlobalShapeLOD = appAtof(Str);
		Ar.Logf( TEXT("Global mesh shape LOD distance %f"), (FLOAT)GlobalShapeLOD );
		return 1;
	}
	else if( ParseCommand(&Str,TEXT("MLMODE")) )
	{
		if( !appStrcmp(Str, TEXT("")) )
		{
			Ar.Logf( TEXT("%i"), (INT)ShapeLODMode );
			return 1;
		}
		if( appAtoi(Str)>=0 )
			ShapeLODMode = appAtoi(Str);
		Ar.Logf( TEXT("Shape LOD draw mode %i"), (INT)ShapeLODMode );
		return 1;
	}
	else if( ParseCommand(&Str,TEXT("MLFIX")) )
	{
		if( !appStrcmp(Str, TEXT("")) )
		{
			Ar.Logf( TEXT("%f"), (FLOAT)ShapeLODFix );
			return 1;
		}
		if( appAtof(Str)>=0 )
			ShapeLODFix = appAtof(Str);
		Ar.Logf( TEXT("Shape LOD scaling fixed at %f"), (FLOAT)ShapeLODFix );
		return 1;
	}
	else if( ParseCommand(&Str,TEXT("FORCESHADOWS")) )
	{
		ForceShadows ^= 1;
		return 1;
	}
	else if( ParseCommand(&Str,TEXT("FORCEMESHSHADOWS")) )
	{
		ForceMeshShadows ^= 1;
		return 1;
	}
	else return 0; // Not executed
}

/*--------------------------------------------------------------------------
	Pipe.
--------------------------------------------------------------------------*/

//
// Basic transform, outcode, project.
//
static void Pipe( FTransform& Result, const FSceneNode* Frame, const FVector& InVector )
{
	static FLOAT Half=0.5f;
	static FLOAT ClipXM, ClipXP, ClipYM, ClipYP;
	static const BYTE OutXMinTab [2] = { 0, FVF_OutXMin };
	static const BYTE OutXMaxTab [2] = { 0, FVF_OutXMax };
	static const BYTE OutYMinTab [2] = { 0, FVF_OutYMin };
	static const BYTE OutYMaxTab [2] = { 0, FVF_OutYMax };
#if ASM
	__asm
	{
		; Load pointers.
		mov	    esi, [Frame]
		mov     ecx, [Result]
		mov     eax, [InVector]
		lea     edx, [esi]FSceneNode.Coords

		; Transform the point.
		mov		esi, [Frame]
		mov     eax, [InVector]
		lea     edx, [esi]FSceneNode.Coords
		mov     ecx, [Result]

		fld     dword ptr [eax+0]
		fld     dword ptr [eax+4]
		fld     dword ptr [eax+8]
		fxch    st(2)

		fsub    dword ptr [edx + 0]
		fxch    st(1)
		fsub	dword ptr [edx + 4]
		fxch    st(2)
		fsub	dword ptr [edx + 8]
		fxch    st(1)

		fld     st(0)
        fmul    dword ptr [edx+12]
        fld     st(1)
        fmul    dword ptr [edx+24]
		fxch    st(2)
		fmul    dword ptr [edx+36]
		fxch    st(4)

		fld     st(0)
		fmul    dword ptr [edx+16]     
		fld     st(1)
        fmul    dword ptr [edx+28]    
		fxch    st(2)
		fmul    dword ptr [edx+40]
		fxch    st(1)

        faddp   st(3),st(0)
        faddp   st(5),st(0)
        faddp   st(2),st(0)
		fxch    st(2)

		fld     st(0)
		fmul    dword ptr [edx+20]     
		fld     st(1)
        fmul    dword ptr [edx+32]      
		fxch    st(2)
		fmul    dword ptr [edx+44]
		fxch    st(1)

		faddp   st(4),st(0)
		faddp   st(4),st(0)
		faddp   st(1),st(0)
		fxch    st(1)                   ; X Y Z

		fstp    dword ptr [ecx+0]       ; X
        fstp    dword ptr [ecx+4]       ; Y                     
        fstp    dword ptr [ecx+8]       ; Z

		; Compute clipping numbers.
		fld  [ecx]FVector.Z				; Z
		fld  [ecx]FVector.Z				; Z Z
		fxch							; Z Z
		fmul [esi]FSceneNode.PrjXM		; Z*ProjZM Z
		fxch							; Z Z*ProjXM
		fmul [esi]FSceneNode.PrjYM		; Z*ProjYM Z*ProjXM
		fld  [ecx]FVector.Z				; Z Z*ProjYM Z*ProjXM
		fld  [ecx]FVector.Z				; Z Z Z*ProjYM Z*ProjXM
		fxch                            ; Z Z Z*ProjYM Z*ProjXM
		fmul [esi]FSceneNode.PrjXP      ; Z*ProjXP Z Z*ProjYM Z*ProjXM
		fxch                            ; Z Z*ProjXP Z*ProjYM Z*ProjXM
		fmul [esi]FSceneNode.PrjYP      ; Z*ProjYP Z*ProjXP Z*ProjYM Z*ProjXM
		fxch st(3)                      ; Z*ProjXM Z*ProjXP Z*ProjYM Z*ProjYP
		fadd [ecx]FVector.X             ; X+Z*ProjXM Z*ProjXP Z*ProjYM Z*ProjYP
		fxch st(2)                      ; Z*ProjYM Z*ProjXP X+Z*ProjXM Z*ProjYP
		fadd [ecx]FVector.Y             ; Y+Z*ProjYM Z*ProjXP X+Z*ProjXM Z*ProjYP
		fxch st(1)                      ; Z*ProjXP Y+Z*ProjYM X+Z*ProjXM Z*ProjYP
		fsub [ecx]FVector.X             ; X-Z*ProjXP Y+Z*ProjYM X+Z*ProjXM Z*ProjYP
		fxch st(3)                      ; Z*ProjYP Z+Y*ProjYM Z+X*ProjXM Z+X*ProjXP
		fsub [ecx]FVector.Y             ; Y-Z*ProjYP Z+Y*ProjYM Z+X*ProjXM Z+X*ProjXP
		fxch st(2)                      ; Z+X*ProjXM Z+Y*ProjYM Z+Y*ProjYP Z+X*ProjXP
		fstp ClipXM                     ; Z+Y*ProjYM Z+Y*ProjYP Z+X*ProjXP
		fstp ClipYM                     ; Z+Y*ProjYP Z+X*ProjXP
		fstp ClipYP                     ; Z+X*ProjXP
		fstp ClipXP                     ; (empty)

		; Start speculative 1/Z divide.
		fld  [esi]FSceneNode.Proj.Z     ; ProjZ
		fdiv [ecx]FVector.Z             ; ProjZ/Z

		; Compute flags.
		mov  ebx,ClipXM					; ebx = XM clipping number as integer
		mov  edx,ClipYM					; edx = YM clipping number as integer
		shr  ebx,31						; ebx = XM: 0 iff clip>=0.0, 1 iff clip<0.0
		mov  edi,ClipXP					; edi = XP
		shr  edx,31                     ; edx = YM: 0 or 1
		mov  esi,ClipYP					; esi = YP: 0 or 1
		shr  edi,31						; edi = XP: 0 or 1
		mov  al,OutXMinTab[ebx]			; al = 0 or FVF_OutXMin
		shr  esi,31						; esi = YP: 0 or 1
		mov  bl,OutYMinTab[edx]			; bl = FVF_OutYMin
		or   bl,al						; bl = FVF_OutXMin, FVF_OutYMin
		mov  ah,OutXMaxTab[edi]			; ah = FVF_OutXMax
		or   bl,ah						; bl = FVF_OutXMin, FVF_OutYMin, OutYMax
		mov  al,OutYMaxTab[esi]			; bh = FVF_OutYMax
		or   al,bl                      ; al = FVF_OutYMin and FVF_OutYMax
		mov  [ecx]FOutVector.Flags, al	; Store flags

		; Projection.
		fstp [ecx]FTransform.RZ
		jne SkipProjection
		mov esi, [Frame]
		fld [ecx]FVector.X
		fld [ecx]FVector.Y
		fxch
		fmul [ecx]FTransform.RZ
		fxch
		fmul [ecx]FTransform.RZ
		fxch
		fadd [esi]FSceneNode.FX15
		fxch
		fadd [esi]FSceneNode.FY15
		fxch
		fstp [ecx]FTransform.ScreenX
		fst  [ecx]FTransform.ScreenY
		fsub [Half]
		fistp DWORD PTR [ecx]Result.IntY

		; Finished.
		SkipProjection:
	}
#else
	Result.Point = InVector.TransformPointBy( Frame->Coords );
	#if ASMLINUX
		// Load member variables into local variables.
		asm volatile ("
			#
			# Compute clipping numbers.
			#
			flds %0;				# Z
			flds %0;				# Z Z
			fxch;					# Z Z
			fmuls %1;				# Z*ProjXM Z
			fxch;					# Z Z*ProjXM
			fmuls %2;				# Z*ProjYM Z*ProjXM
			flds %0;				# Z Z*ProjYM Z*ProjXM
			flds %0;				# Z Z Z*ProjYM Z*ProjXM
			fxch;					# Z Z Z*ProjYM Z*ProjXM
			fmuls %3;				# Z*ProjXP Z Z*ProjYM Z*ProjXM
			fxch;					# Z Z*ProjXP Z*ProjYM Z*ProjXM
			fmuls %4;				# Z*ProjYP Z*ProjXP Z*ProjYM Z*ProjXM
			fxch %%st(3);			# Z*ProjXM Z*ProjXP Z*ProjYM Z*ProjYP
			fadds %5;				# Z*ProjXM+X Z*ProjXP Z*ProjYM Z*ProjYP
			fxch %%st(2);			# Z*ProjYM Z*ProjXP Z*ProjXM+X Z*ProjYP
			fadds %6;				# Z*ProjYM+Y Z*ProjXP Z*ProjXM+X Z*ProjYP
			fxch %%st(1);			# Z*ProjXP Z*ProjYM+Y Z*ProjXM+X Z*ProjYP
			fsubs %5;				# Z*ProjXP-X Z*ProjYM+Y Z*ProjXM+X Z*ProjYP
			fxch %%st(3);			# Z*ProjYP Z*ProjYM+Y Z*ProjXM+X Z*ProjXP-X
			fsubs %6;				# Z*ProjYP-Y Z*ProjYM+Y Z*ProjXM+X Z*ProjXP-X
			fxch %%st(2);			# Z*ProjXM+X Z*ProjYM+Y Z*ProjYP-Y Z*ProjXP-X
		"
		:
		: "g" (Result.Point.Z),
		  "g" (Frame->PrjXM),
		  "g" (Frame->PrjYM),
		  "g" (Frame->PrjXP),
		  "g" (Frame->PrjYP),
		  "g" (Result.Point.X),
		  "g" (Result.Point.Y)
		);
		asm volatile ("
								# Z*ProjXM+X Z*ProjYM+Y Z*ProjYP-Y Z*ProjXP-X
			fstps %0;			# Z*ProjYM+Y Z*ProjYP-Y Z*ProjXP-X
			fstps %1;			# Z*ProjYP-Y Z*ProjXP-X
			fstps %2;			# Z*ProjXP-X
			fstps %3;			# (empty)
		"
		: "=g" (ClipXM),
		  "=g" (ClipYM),
		  "=g" (ClipYP),
		  "=g" (ClipXP)
		);
	#else
	ClipXM = Frame->PrjXM * Result.Point.Z + Result.Point.X;
	ClipXP = Frame->PrjXP * Result.Point.Z - Result.Point.X;
	ClipYM = Frame->PrjYM * Result.Point.Z + Result.Point.Y;
	ClipYP = Frame->PrjYP * Result.Point.Z - Result.Point.Y;
	#endif
	Result.Flags  =
	(	OutXMinTab [ClipXM < 0.0]
	+	OutXMaxTab [ClipXP < 0.0]
	+	OutYMinTab [ClipYM < 0.0]
	+	OutYMaxTab [ClipYP < 0.0]);
	if( !Result.Flags )
	{
		#if LINUXASM
		asm volatile ("
			#
			# Projection
			#
			flds %4;
			flds %5;
			fxch;
			fmuls %3;
			fxch;
			fmuls %3;
			fxch;
			fadds %6;
			fxch;
			fadds %7;
			fxch;
			fstps %1;
			fsts %2;
			fsubs %8;
			fistps %0;
		"
		: "=g" (Result.IntY)
		  "=g" (Result.ScreenX),
		  "=g" (Result.ScreenY)
		: "g" (Transform.RZ),
		  "g" (Result.Point.X),
		  "g" (Result.Point.Y),
		  "g" (Frame->FX15),
		  "g" (Frame->FY15),
		  "g" (Half)
			);
		#else
		Result.RZ      = Frame->Proj.Z / Result.Point.Z;
		Result.ScreenX = Result.Point.X * Result.RZ + Frame->FX15;
		Result.ScreenY = Result.Point.Y * Result.RZ + Frame->FY15;
		Result.IntY    = appFloor( Result.ScreenY );
		#endif
	}
#endif
}

//
// Clipping helper.
//
static FLOAT Dot[FBspNode::MAX_FINAL_VERTICES];

/*-----------------------------------------------------------------------------
	3DNow! code.
-----------------------------------------------------------------------------*/
#if ASM3DNOW

#pragma warning( disable : 4799 )
#pragma pack( 8 )

#define MAKE_FP(Val) *((FLOAT *)&(Val))
#define MAKE_DWORD(Val) *((DWORD *)&(Val))

static inline void TransformAndComputeOutcodeAndProject
(
	FTransform*			OutPoint,
	const FVector&		InPoint,
	const FSceneNode*	Frame
)
{
	// Unions containing QWORDS are used here so the compiler will align them properly.
	static union
	{
		DWORD d[2];
		double q;
	} Negator={0x80000000,0x80000000},PlusMask={FVF_OutXMax,FVF_OutYMax},MinusMask={FVF_OutXMin,FVF_OutYMin};
	__asm
	{
		mov		ebx,InPoint
		mov		ecx,Frame
		mov		edx,OutPoint

		// Approx 27 clocks.
		movq	mm0,[ebx]FVector.X					// mm0=Y|X, mm2=Yo|Xo
		movq	mm2,[ecx]FSceneNode.Coords.Origin.X
		movd	mm1,[ebx]FVector.Z					// mm1=0|Z, mm3=0|Zo
		movd	mm3,[ecx]FSceneNode.Coords.Origin.Z
		pfsub	(m0,m2)								// mm0=Y'|X', mm4=Yz|Xz
		movq	mm4,[ecx]FSceneNode.Coords.ZAxis.X
		pfsub	(m1,m3)								// mm1=0 |Z', mm5=0 |Zz
		movd	mm5,[ecx]FSceneNode.Coords.ZAxis.Z
		pfmul	(m4,m0)								// mm4=YzY'|XzX', mm6=Yx|Xx
		movq	mm6,[ecx]FSceneNode.Coords.XAxis.X
		pfmul	(m5,m1)								// mm5=0   |ZzZ', mm7=0 |Zx
		movd	mm7,[ecx]FSceneNode.Coords.XAxis.Z		
		pfmul	(m6,m0)								// mm6=YxY'|XxX', mm2=Yy|Xy
		movq	mm2,[ecx]FSceneNode.Coords.YAxis.X
		pfmul	(m7,m1)								// mm7=0   |ZxZ', mm3=0 |Zy
		movd	mm3,[ecx]FSceneNode.Coords.YAxis.Z
		pfmul	(m2,m0)								// mm2=YyY'|XyX', mm4=ZzZ'|YzY'+XzX'
		pfacc	(m4,m5)
		pfmul	(m3,m1)								// mm3=0   |ZyZ', mm6=ZxZ'|YxY'+XxX'
		pfacc	(m6,m7)
		pfacc	(m4,m4)								// mm4=Z"|Z", mm0=Ym|Xm
		movq	mm0,[ecx]FSceneNode.PrjXM		
		pfacc	(m2,m3)								// mm2=ZyZ'|YyY'+XyX', mm1=Yp|Xp
		movq	mm1,[ecx]FSceneNode.PrjXP
		pfmul	(m0,m4)								// mm0=YmZ"|XmZ", mm5=0x80000000|0x80000000
		movq	mm5,Negator
		pfmul	(m1,m4)								// mm1=YpZ"|XpZ", mm7=+Mask
		movq	mm7,PlusMask
		pxor	mm0,mm5								// mm0=-YmZ"|-XmZ", mm3=-Mask
		movq	mm3,MinusMask
		pfacc	(m6,m2)								// mm6=Y"|X", save Z"
		movd	[edx]FOutVector.Point.Z,mm4
		pfrcp	(m4,m4)								// mm4=1/Z"|1/Z", mm5=0|Zp
		movd	mm5,[ecx]FSceneNode.Proj.Z
		pfcmpge	(m1,m6)								// mm1=+ClipVal, mm2=FY15 | FX15
		movq	mm2,[ecx]FSceneNode.FX15
		pfcmpgt	(m0,m6)								// mm0=+ClipVal, save Y"|X"
		movq	[edx]FOutVector.Point.X,mm6
		punpckldq mm5,mm5							// mm5=Zp|Zp, mm1=Y+c|X+c
		pandn	mm1,mm7
		pfmul	(m5,m4)								// mm5=Zp1/Z"|Zp1/Z", mm0=Y-c|X-c
		pand	mm0,mm3								
		por		mm0,mm1								// mm0=Yc|Xc, mm1=Yc|Xc
		movq	mm1,mm0
		pfmul	(m6,m5)								// mm6=Zp1/Z"Y"|Zp1/Z"X", mm0=0|Yc
		psrlq	mm0,32								
		movd	[edx]FTransform.RZ,mm5				// Save 1/Z", mm0=Clip Flag
		por		mm0,mm1								
		pfadd	(m6,m2)								// mm6=ScreenY|ScreenX, save flags
		movd	[edx]FOutVector.Flags,mm0			
		pf2id	(m3,m6)								// mm3=IntY|IntX, Save ScreenY|ScreenX
		movq	[edx]FTransform.ScreenX,mm6			
		psrlq	mm3,32								// mm3=0|IntY, Save IntY
		movd	[edx]FTransform.IntY,mm3			
	}
}

//
// K6 3D assembler version of:
//			for( INT i=0; i<NumPts; i++ )
//				Dot[i] = Frame->PrjXM * Pts[i]->Point.Z + Pts[i]->Point.X;
//
static inline void SetXMinDotVals( FSceneNode* Frame, INT NumPts, FTransform** Pts )
{
	__asm
	{
		// Get ready for loop
		mov		eax,offset Dot
		mov		ebx,Frame
		mov		ecx,NumPts
		mov		edx,Pts
		movd	mm0,[ebx]FSceneNode.PrjXM
		cmp		ecx,0
		jz		Done
TopLoop:
		// Do: Dot[i] = Frame->PrjXM * Pts[i]->Point.Z + Pts[i]->Point.X;
		mov		edi,[edx]	// Get ptr to Pt
		movd	mm1,[edi]FOutVector.Point.Z
		movd	mm2,[edi]FOutVector.Point.X
		pfmul	(m1,m0)
		pfadd	(m2,m1)
		movd	[eax],mm2

		// Loop
		add		edx,4
		add		eax,4
		loop	TopLoop	
Done:	
	}
}

//
// K6 3D assembler version of:
//			for( INT i=0; i<NumPts; i++ )
//				Dot[i] = Frame->PrjXP * Pts[i]->Point.Z - Pts[i]->Point.X;
//
static inline void SetXMaxDotVals( FSceneNode* Frame, INT NumPts, FTransform** Pts )
{
	__asm
	{
		// Get ready for loop
		mov		eax,offset Dot
		mov		ebx,Frame
		mov		ecx,NumPts
		mov		edx,Pts
		movd	mm0,[ebx]FSceneNode.PrjXP
		cmp		ecx,0
		jz		Done
TopLoop:
		// Do: Dot[i] = Frame->PrjXP * Pts[i]->Point.Z - Pts[i]->Point.X;
		mov		edi,[edx]	// Get ptr to Pt
		movd	mm1,[edi]FOutVector.Point.Z
		movd	mm2,[edi]FOutVector.Point.X
		pfmul	(m1,m0)
		pfsubr	(m2,m1)
		movd	[eax],mm2

		// Loop
		add		edx,4
		add		eax,4
		loop	TopLoop	
Done:	
	}
}

//
// K6 3D assembler version of:
//			for( INT i=0; i<NumPts; i++ )
//				Dot[i] = Frame->PrjYM * Pts[i]->Point.Z + Pts[i]->Point.Y;
//
static inline void SetYMinDotVals( FSceneNode* Frame, INT NumPts, FTransform** Pts )
{
	__asm
	{
		// Get ready for loop
		mov		eax,offset Dot
		mov		ebx,Frame
		mov		ecx,NumPts
		mov		edx,Pts
		movd	mm0,[ebx]FSceneNode.PrjYM
		cmp		ecx,0
		jz		Done
TopLoop:
		// Do: Dot[i] = Frame->PrjYM * Pts[i]->Point.Z + Pts[i]->Point.Y;
		mov		edi,[edx]	// Get ptr to Pt
		movd	mm1,[edi]FOutVector.Point.Z
		movd	mm2,[edi]FOutVector.Point.Y
		pfmul	(m1,m0)
		pfadd	(m2,m1)
		movd	[eax],mm2

		// Loop
		add		edx,4
		add		eax,4
		loop	TopLoop	
Done:	
	}
}

//
// K6 3D assembler version of:
//			for( INT i=0; i<NumPts; i++ )
//				Dot[i] = Frame->PrjYP * Pts[i]->Point.Z - Pts[i]->Point.Y;
//
static inline void SetYMaxDotVals( FSceneNode* Frame, INT NumPts, FTransform** Pts )
{
	__asm
	{
		// Get ready for loop
		mov		eax,offset Dot
		mov		ebx,Frame
		mov		ecx,NumPts
		mov		edx,Pts
		movd	mm0,[ebx]FSceneNode.PrjYP
		cmp		ecx,0
		jz		Done
TopLoop:
		// Do: Dot[i] = Frame->PrjYP * Pts[i]->Point.Z - Pts[i]->Point.Y;
		mov		edi,[edx]	// Get ptr to Pt
		movd	mm1,[edi]FOutVector.Point.Z
		movd	mm2,[edi]FOutVector.Point.Y
		pfmul	(m1,m0)
		pfsubr	(m2,m1)
		movd	[eax],mm2

		// Loop
		add		edx,4
		add		eax,4
		loop	TopLoop	
Done:	
	}
}

//
// Routine to calculate intersection of two points against a clipping plane
// and then project the resultant point.
//
static inline void IntersectAndProject
(
	FSceneNode*	Frame,
	FTransform*	OutPoint,
	FTransform*	InPoint1,
	FTransform*	InPoint2,
	DWORD		Dot1,
	DWORD		Dot2)
{
	__asm
	{
		// Get pointers
		mov		eax,InPoint1
		mov		ebx,InPoint2

		// Do intersect and project
		movd	mm0,Dot1						// mm0=0|Dot1, mm1=0|Dot2
		movd	mm1,Dot2
		movd	mm2,[eax]FOutVector.Point.Z		// mm2=0|Z1, mm3=0|Z2
		movd	mm3,[ebx]FOutVector.Point.Z
		pfsubr	(m1,m0)							// mm1=0|Dot1-Dot2, mm4=Y1|X1
		movq	mm4,[eax]FOutVector.Point.X
		mov		ecx,Frame						// added - ecx=ptr to Frame, mm0=Dot1|Dot1
		punpckldq mm0,mm0							
		pfsub	(m3,m2)							// mm3=0|Z2-Z1, mm5=Y2|X2
		movq	mm5,[ebx]FOutVector.Point.X
		pfrcp	(m1,m1)							// mm1=1/(Dot1-Dot2), mm6=0|ProjZ
		movd	mm6,[ecx]FSceneNode.Proj.Z
		pfsub	(m5,m4)							// mm5=Y2-Y1|X2-X1, mm7=FY15|FX15
		movq	mm7,[ecx]FSceneNode.FX15
		pfmul	(m3,m0)							// mm3=0|(Z2-Z1)*Dot1, mm6=ProjZ|ProjZ
		punpckldq mm6,mm6
		pfmul	(m0,m1)							// mm0=Dot1/(Dot1-Dot2), mm3=0|Zs
		pfmul	(m3,m1)
		mov		edx,OutPoint					// added - Try and eat a bit of scheduler latency
		pfmul	(m5,m0)							// mm5=Ys|Xs, mm2=0|Z'
		pfadd	(m2,m3)
		pfadd	(m4,m5)							// mm4=Y'|X', save Z'
		movd	[edx]FOutVector.Point.Z,mm2		
		pfrcp	(m1,m2)							// mm1=1/Z'|1/Z', save Y'|X'
		movq	[edx]FOutVector.Point.X,mm4
		pfmul	(m6,m1)							// mm6=ProjZ/Z'|ProjZ/Z', save mm6
		movd	[edx]FTransform.RZ,mm6
		// We have some scheduler stalls. Need some stuff to stick in here.
		pfmul	(m6,m4)							// mm6=Y'ProjZ1/Z'|X'ProjZ1/Z', mm7=ScrY|ScrX
		pfadd	(m7,m6)
		movq	[edx]FTransform.ScreenX,mm7		// save ScrY|ScrX, mm0=Int(ScrY)|Int(ScrX)
		pf2id	(m0,m7)
		psrlq	mm0,32							// mm0=0|Int(ScrY), save Int(ScrY)
		movd	[edx]FTransform.IntY,mm0
	}
}

static inline INT AMD3DClip( FTransform** Dest, FTransform** Src, INT SrcNum )
{
	INT DestNum=0;
	for( INT i=0,j=SrcNum-1; i<SrcNum; j=i++ )
	{
		if( *(INT*)(Dot+j) >= 0 )
		{
			Dest[DestNum++] = Src[j];
		}
		if( (*(INT*)(Dot+j) ^ *(INT*)(Dot+i)) < 0 )
		{
			FTransform* T = Dest[DestNum++] = New<FTransform>( GDynMem );
			IntersectAndProject( GFrame, T, Src[j], Src[i], MAKE_DWORD(Dot[j]), MAKE_DWORD(Dot[i]) );
		}
	}
	return DestNum;
}

//
// Transform and clip a polygon.
//
#pragma warning (disable:4730)
inline INT URender::AMD3DClipBspSurf( INT iNode, FTransform**& Result )
{
	static FTransform* LocalPts[FBspNode::MAX_FINAL_VERTICES];

	// Transform.
	STAT(GStat.NumTransform++);
	FBspNode* Node		= &GNodes[iNode];
	INT       NumPts    = Node->NumVertices;
	FVert*	  VertPool	= &GVerts[Node->iVertPool];
	BYTE      Outcode   = FVF_OutReject;
	BYTE      AllCodes  = 0;

	DoFemms();

	for( INT i=0; i<NumPts; i++ )
	{
		INT pPoint = VertPool[i].pVertex;
		FStampedPoint& S = PointCache[pPoint];
		if( S.Stamp != Stamp )
		{
			S.Stamp = Stamp;
			S.Point = new(VectorMem)FTransform;
			TransformAndComputeOutcodeAndProject(S.Point,(*GPoints)(pPoint),GFrame);
			STAT(GStat.NumPoints++);
		}
		LocalPts[i] = S.Point;
		BYTE Flags  = S.Point->Flags; 
		Outcode    &= Flags;
		AllCodes   |= Flags;
	}

	if( Outcode )
	{
		DoFemms();
		return 0;
	}

	// Clip.
	STAT(GStat.NumClip++);
	FTransform** Pts = LocalPts;
	if( AllCodes )
	{
		if( AllCodes & FVF_OutXMin )
		{
			static FTransform* LocalPts[FBspNode::MAX_FINAL_VERTICES];
			SetXMinDotVals(GFrame,NumPts,Pts);
			NumPts = AMD3DClip( LocalPts, Pts, NumPts );
			if( !NumPts )
			{
				DoFemms();
				return 0;
			}
			Pts = LocalPts;
		}
		if( AllCodes & FVF_OutXMax )
		{
			static FTransform* LocalPts[FBspNode::MAX_FINAL_VERTICES];
			SetXMaxDotVals(GFrame,NumPts,Pts);
			NumPts = AMD3DClip( LocalPts, Pts, NumPts );
			if( !NumPts )
			{
				DoFemms();
				return 0;
			}
			Pts = LocalPts;
		}
		if( AllCodes & FVF_OutYMin )
		{
			static FTransform* LocalPts[FBspNode::MAX_FINAL_VERTICES];
			SetYMinDotVals(GFrame,NumPts,Pts);
			NumPts = AMD3DClip( LocalPts, Pts, NumPts );
			if( !NumPts )
			{
				DoFemms();
				return 0;
			}
			Pts = LocalPts;
		}
		if( AllCodes & FVF_OutYMax )
		{
			static FTransform* LocalPts[FBspNode::MAX_FINAL_VERTICES];
			SetYMaxDotVals(GFrame,NumPts,Pts);
			NumPts = AMD3DClip( LocalPts, Pts, NumPts );
			if( !NumPts )
			{
				DoFemms();
				return 0;
			}
			Pts = LocalPts;
		}
	}
	if( MAKE_DWORD(GFrame->NearClip.W) != 0 )
	{
		UBOOL Clipped=0;
		// Can't K63Dize this since it doesn't seem to be used so we can't test it.
		DoFemms();
		for( INT i=0; i<NumPts; i++ )
		{
			Dot[i] = GFrame->NearClip.PlaneDot(Pts[i]->Point);
			Clipped |= (Dot[i]<0.f);
		}
		DoFemms();

		if( Clipped )
		{
			static FTransform* LocalPts[FBspNode::MAX_FINAL_VERTICES];
			NumPts = AMD3DClip( LocalPts, Pts, NumPts );
			if( !NumPts )
			{
				DoFemms();
				return 0;
			}
			Pts = LocalPts;
		}
	}
	Result = Pts;

	DoFemms();

	return NumPts;
}
#pragma warning( disable : 4799 )
#pragma pack( )

#endif
/*-----------------------------------------------------------------------------
	Normal code.
-----------------------------------------------------------------------------*/

static inline INT __fastcall Clip( FTransform** Dest, FTransform** Src, INT SrcNum )
{
	INT DestNum=0;
	for( INT i=0,j=SrcNum-1; i<SrcNum; j=i++ )
	{
		if( *(INT*)(Dot+j) >= 0 )
		{
			Dest[DestNum++] = Src[j];
		}
		if( (*(INT*)(Dot+j) ^ *(INT*)(Dot+i)) < 0 )
		{
			FTransform* T = Dest[DestNum++] = New<FTransform>( GDynMem );
			FLOAT Alpha   = Dot[j] / (Dot[j]-Dot[i]);
			T->Point.X    = Src[j]->Point.X + (Src[i]->Point.X-Src[j]->Point.X) * Alpha;
			T->Point.Y    = Src[j]->Point.Y + (Src[i]->Point.Y-Src[j]->Point.Y) * Alpha;
			T->Point.Z    = Src[j]->Point.Z + (Src[i]->Point.Z-Src[j]->Point.Z) * Alpha;
			T->Project( GFrame );
		}
	}
	return DestNum;
}
/*

static inline INT Clip( FTransTexture** Dest, FTransTexture** Src, INT SrcNum )
{
	INT DestNum=0;
	for( INT i=0,j=SrcNum-1; i<SrcNum; j=i++ )
	{
		if( *(INT*)(Dot+j) >= 0 )
		{
			Dest[DestNum++] = Src[j];
		}
		if( (*(INT*)(Dot+j) ^ *(INT*)(Dot+i)) < 0 )
		{
			FTransTexture* T = Dest[DestNum++] = New<FTransTexture>( GDynMem );
			FLOAT Alpha   = Dot[j] / (Dot[j]-Dot[i]);
			T->Point.X    = Src[j]->Point.X + (Src[i]->Point.X-Src[j]->Point.X) * Alpha;
			T->Point.Y    = Src[j]->Point.Y + (Src[i]->Point.Y-Src[j]->Point.Y) * Alpha;
			T->Point.Z    = Src[j]->Point.Z + (Src[i]->Point.Z-Src[j]->Point.Z) * Alpha;
			T->Project( GFrame );
		}
	}
	return DestNum;
}
*/

//
// Transform and clip a polygon.
//
INT __fastcall URender::ClipBspSurf( INT iNode, FTransform**& Result )
{
#if ASM3DNOW
	if( GIs3DNow )
		return AMD3DClipBspSurf( iNode, Result );
#endif		

	static FTransform* LocalPts[FBspNode::MAX_FINAL_VERTICES];

	// Transform.
	//STAT(GStat.NumTransform++);
	FBspNode* Node		= &GNodes[iNode];
	INT       NumPts    = Node->NumVertices;
	FVert*	  VertPool	= &GVerts[Node->iVertPool];
	BYTE      Outcode   = FVF_OutReject;
	BYTE      AllCodes  = 0;
	for( INT i=0; i<NumPts; i++ )
	{
		INT pPoint = VertPool[i].pVertex;
		FStampedPoint& S = PointCache[pPoint];

		if( S.Stamp != Stamp )
		{
			S.Stamp = Stamp;
			S.Point = new(VectorMem)FTransform;
			Pipe( *S.Point, GFrame, (*GPoints)(pPoint) );
			//STAT(GStat.NumPoints++);
		}
		LocalPts[i] = S.Point;
		BYTE Flags  = S.Point->Flags; 
		Outcode    &= Flags;
		AllCodes   |= Flags;
	}
	if( Outcode )
		return 0;

	// Clip.
	//STAT(GStat.NumClip++);
	FTransform** Pts = LocalPts;
	if( AllCodes )
	{
		if( AllCodes & FVF_OutXMin )
		{
			static FTransform* LocalPts[FBspNode::MAX_FINAL_VERTICES];
			for( INT i=0; i<NumPts; i++ )
				Dot[i] = GFrame->PrjXM * Pts[i]->Point.Z + Pts[i]->Point.X;
			NumPts = Clip( LocalPts, Pts, NumPts );
			if( !NumPts )
				return 0;
			Pts = LocalPts;
		}
		if( AllCodes & FVF_OutXMax )
		{
			static FTransform* LocalPts[FBspNode::MAX_FINAL_VERTICES];
			for( INT i=0; i<NumPts; i++ )
				Dot[i] = GFrame->PrjXP * Pts[i]->Point.Z - Pts[i]->Point.X;
			NumPts = Clip( LocalPts, Pts, NumPts );
			if( !NumPts )
				return 0;
			Pts = LocalPts;
		}
		if( AllCodes & FVF_OutYMin )
		{
			static FTransform* LocalPts[FBspNode::MAX_FINAL_VERTICES];
			for( INT i=0; i<NumPts; i++ )
				Dot[i] = GFrame->PrjYM * Pts[i]->Point.Z + Pts[i]->Point.Y;
			NumPts = Clip( LocalPts, Pts, NumPts );
			if( !NumPts )
				return 0;
			Pts = LocalPts;
		}
		if( AllCodes & FVF_OutYMax )
		{
			static FTransform* LocalPts[FBspNode::MAX_FINAL_VERTICES];
			for( INT i=0; i<NumPts; i++ )
				Dot[i] = GFrame->PrjYP * Pts[i]->Point.Z - Pts[i]->Point.Y;
			NumPts = Clip( LocalPts, Pts, NumPts );
			if( !NumPts )
				return 0;
			Pts = LocalPts;
		}
	}
	if( GFrame->NearClip.W != 0.f )
	{
		UBOOL Clipped=0;
		for( INT i=0; i<NumPts; i++ )
		{
			Dot[i] = GFrame->NearClip.PlaneDot(Pts[i]->Point);
			Clipped |= (Dot[i]<0.f);
		}
		if( Clipped )
		{
			static FTransform* LocalPts[FBspNode::MAX_FINAL_VERTICES];
			NumPts = Clip( LocalPts, Pts, NumPts );
			if( !NumPts )
				return 0;
			Pts = LocalPts;
		}
	}
	Result = Pts;
	return NumPts;
}

/*-----------------------------------------------------------------------------
	Scene frames.
-----------------------------------------------------------------------------*/

//
// Build a master scene frame.
//
FSceneNode* URender::CreateMasterFrame( UViewport* Viewport, FVector Location, FRotator Rotation, FScreenBounds* Bounds )
{

	// Push memory.
	if( ++SceneCount==1 )
	{
		MemMark   = FMemMark(GMem);
		DynMark   = FMemMark(GDynMem);
		SceneMark = FMemMark(GSceneMem);
	}

	// Set base info.
	FSceneNode* Frame	= new(GSceneMem)FSceneNode;
	Frame->Viewport		= Viewport;
	Frame->X			= Viewport->SizeX;
	Frame->Y			= Viewport->SizeY;
	Frame->XB			= 0;
	Frame->YB			= 0;
	Frame->Level		= Viewport->Actor->GetLevel();
	Frame->Parent		= NULL;
	Frame->Sibling		= NULL;
	Frame->Child		= NULL;
	Frame->iSurf		= INDEX_NONE;
	Frame->Recursion	= 0;
	Frame->Mirror		= 1.f;
	Frame->Recursion	= 0;
	Frame->NearClip		= FPlane(0.f,0.f,0.f,0.f);
	Frame->Draw[0]		= NULL;
	Frame->Draw[1]		= NULL;
	Frame->Draw[2]		= NULL;
	Frame->Sprite		= NULL;
	Frame->Span			= new(GSceneMem)FSpanBuffer;
	Frame->Span->AllocIndexForScreen( Viewport->SizeX, Viewport->SizeY, &GSceneMem );

	// Compute coords.
	Frame->ComputeRenderCoords( Location, Rotation );

	// Compute zone.
	Frame->ZoneNumber   = Viewport->Actor->GetLevel()->Model->PointRegion( Viewport->Actor->GetLevel()->GetLevelInfo(), Frame->Coords.Origin ).ZoneNumber;

	return Frame;
}

//
// Finish rendering all scene nodes.
//
void URender::FinishMasterFrame()
{
	if( --SceneCount==0 )
	{
		MemMark  .Pop();
		DynMark  .Pop();
		SceneMark.Pop();
	}
	check(SceneCount>=0);
}

//
// Build a new child scene frame.
//
FSceneNode* URender::CreateChildFrame
(
	FSceneNode*		Parent,
	FSpanBuffer*	Span,
	ULevel*			Level,
	INT				iSurf,
	INT				iZone,
	FLOAT			Mirror,
	const FPlane&	NearClip,
	const FCoords&	Coords,
	FScreenBounds*	Bounds
)
{
	// See if the scene frame already exists.
	for( FSceneNode* Frame=Parent->Child; Frame; Frame=Frame->Sibling )
	{
		if
		(	Frame->Level==Level
		&&	Frame->iSurf==iSurf
		&&	Frame->Parent==Parent
		&&	Frame->NearClip==NearClip
		&&	Frame->ZoneNumber==iZone )
		{
			// Merge with existing scene frame.
			Frame->Span->MergeWith( *Span );
			if( Bounds )
			{
				Frame->PrjXM = Max( Frame->PrjXM, (Bounds->MinX - Frame->FX2)*(-Frame->RProj.Z) );
				Frame->PrjXP = Max( Frame->PrjXP, (Bounds->MaxX - Frame->FX2)*(+Frame->RProj.Z) );
				Frame->PrjYM = Max( Frame->PrjYM, (Bounds->MinY - Frame->FY2)*(-Frame->RProj.Z) );
				Frame->PrjYP = Max( Frame->PrjYP, (Bounds->MaxY - Frame->FY2)*(+Frame->RProj.Z) );
			}
			break;
		}
	}
	if( Frame == NULL )
	{
		// Make a new scene frame.
		Frame				= new(GSceneMem)FSceneNode(*Parent);
		Frame->Span        	= new(GSceneMem)FSpanBuffer;
		Frame->Viewport     = Parent->Viewport;
		Frame->Level		= Level;
		Frame->iSurf		= iSurf;
		Frame->ZoneNumber	= iZone;
		Frame->Recursion	= Parent->Recursion+1;
		Frame->Mirror		= Mirror;
		Frame->NearClip		= NearClip;
		Frame->Coords		= Coords;
		Frame->Uncoords		= Coords.Transpose(); //!!inverse() - assumes orthogonal.
		Frame->Draw[0]		= NULL;
		Frame->Draw[1]		= NULL;
		Frame->Draw[2]		= NULL;
		Frame->Sprite		= NULL;

		// Insert into linked list of scene frames.
		Frame->Parent		= Parent;
		Frame->Child		= NULL;
		Frame->Sibling		= Parent->Child;
		Parent->Child		= Frame;

		// Compute rendering information.
		//!!clip to parent
		Frame->ComputeRenderSize();
		if( Bounds )
		{
			Frame->PrjXM = (Bounds->MinX - Frame->FX2)*(-Frame->RProj.Z);
			Frame->PrjXP = (Bounds->MaxX - Frame->FX2)*(+Frame->RProj.Z);
			Frame->PrjYM = (Bounds->MinY - Frame->FY2)*(-Frame->RProj.Z);
			Frame->PrjYP = (Bounds->MaxY - Frame->FY2)*(+Frame->RProj.Z);
		}

		// Make span buffer.
		Frame->Span->AllocIndex( 0, 0, &GSceneMem );
		Frame->Span->MergeWith( *Span );
	}
	return Frame;
}

/*-----------------------------------------------------------------------------
	World polygon rasterizer.
-----------------------------------------------------------------------------*/

FRasterSpan HackRaster[2880];//max y res!!
static INT RasterStartY, RasterEndY, RasterStartX, RasterEndX;
UBOOL __forceinline SetupRaster( FTransform** Pts, INT NumPts, FSpanBuffer* Span, INT EndY )
{
	// Compute integer coords.
	RasterStartY = RasterEndY = Pts[0]->IntY;
	RasterStartX = RasterEndX = appFloor( Pts[0]->ScreenX );
	for( INT i=1; i<NumPts; i++ )
	{
		INT Y = Pts[i]->IntY;
		if( Y < RasterStartY )
			RasterStartY = Y;
		else if( Y > RasterEndY )
			RasterEndY = Y;

		INT X = appFloor( Pts[i]->ScreenX );
		if( X < RasterStartX )
			RasterStartX = X;
		else if( X > RasterEndX )
			RasterEndX = X;
	}

	if( RasterStartY<0 || RasterEndY>EndY )
	{
		RasterStartY=Clamp( RasterStartY, 0, EndY );
		RasterEndY  =Clamp( RasterEndY,   0, EndY );
		for( INT i=0; i<NumPts; i++ )
		{
			Pts[i]->ScreenY=Pts[i]->IntY=Clamp( Pts[i]->IntY,0,EndY);
		}
	}

	// Check bounds for visibility.
	if( Span && !Span->BoxIsVisible( RasterStartX, RasterStartY, RasterEndX, RasterEndY ) )
		return 0;

	// Rasterize the edges.
	FTransform **Last=Pts+NumPts, *P[2], *Top, *Bot;
	for( P[0]=Pts[NumPts-1],P[1]=Pts[0]; Pts<Last; P[0]=*Pts,Pts++,P[1]=*Pts )
	{
		if( P[1]->IntY != P[0]->IntY )
		{
			INT Index		= P[1]->IntY > P[0]->IntY;
			Bot          = P[Index];
			Top          = P[1-Index];
			INT*   Set		= HackRaster->X + Top->IntY*2 + Index;
			DOUBLE YAdj		= Top->IntY - Top->ScreenY;
			DOUBLE FDX   = 65536.0f * (Bot->ScreenX - Top->ScreenX) / (Bot->ScreenY - Top->ScreenY);
			DWORD  X     = appFloor( 65536.0f * Top->ScreenX + YAdj * FDX );
			DWORD  DX		= appFloor( FDX );
			INT    Count	= Bot->IntY - Top->IntY;
			for( ; Count >= 4 ; Count -= 4 )
			{
				Set[0]  = Unfix(X+=DX);
				Set[2]  = Unfix(X+=DX);
				Set[4]  = Unfix(X+=DX);
				Set[6]  = Unfix(X+=DX);
				Set    += 2*4;
			}
			for( ; Count > 0; Count-- )
			{
				*Set=Unfix(X+=DX);
				Set+=2;
			}
		}
	}
	return 1;
}

/*-----------------------------------------------------------------------------
	Visible nodes.
-----------------------------------------------------------------------------*/
void URender::GetVisibleSurfs( UViewport* Viewport, TArray<INT>& iSurfs )
{
	// Try six views.
	for( INT i=0; i<6; i++ )
	{
		// Set up rendering.
		FMemMark VectorMark(VectorMem);
		Viewport->Actor->ViewRotation
		=	i==0 ? FRotator(0x4000,0     ,0)
		:	i==1 ? FRotator(0xC000,0     ,0)
		:	i==2 ? FRotator(0     ,0     ,0)
		:	i==3 ? FRotator(0     ,0x8000,0)
		:	i==4 ? FRotator(0     ,0xC000,0)
		:          FRotator(0     ,0x4000,0);
		FSceneNode* Frame = CreateMasterFrame( Viewport, Viewport->Actor->Location, Viewport->Actor->ViewRotation, NULL );

		// Add all visible nodes.
		UBOOL SavedFogZone = Viewport->RenDev->VolumetricLighting;
		Viewport->RenDev->VolumetricLighting = 0;
		OccludeBsp( Frame );

		for( INT i=0; i<3; i++ )
			for( FBspDrawList* Draw=Frame->Draw[i]; Draw; Draw=Draw->Next )
				iSurfs.AddUniqueItem( Draw->iSurf );

		Viewport->RenDev->VolumetricLighting = SavedFogZone;
		FinishMasterFrame();
		VectorMark.Pop();
	}
}

/*-----------------------------------------------------------------------------
	Bsp occlusion functions.
-----------------------------------------------------------------------------*/

//
// Checks whether the node's bouding box is totally occluded.  Returns 0 if
// total occlusion, 1 if all or partial visibility.
//
UBOOL __fastcall URender::BoundVisible
(
	FSceneNode*		Frame,
	FBox*			Bound,
	FSpanBuffer*	SpanBuffer,
	FScreenBounds&	Result
)
{
	FCoords		BoxDot[2];
	FTransform	Pts[8], *Pt;
	FVector 	ViewportLoc;
	FLOAT       BoxMinZ, BoxMaxZ;
	INT         BoxX, BoxY;
	INT 		BoxMinX, BoxMaxX, BoxMinY, BoxMaxY;
	INT			OutCode;

	STAT(clock(GStat.BoxIsVisibleCycles));			// JEP

	// Handle rejection in orthogonal views.
	if( Frame->Viewport->IsOrtho() )
	{
		Project( Frame, Bound->Min, Result.MinX, Result.MinY, NULL );
		Project( Frame, Bound->Max, Result.MaxX, Result.MaxY, NULL );
		if( Result.MinX > Result.MaxX ) Exchange( Result.MinX, Result.MaxX );
		if( Result.MinY > Result.MaxY ) Exchange( Result.MinY, Result.MaxY );
		STAT(unclock(GStat.BoxIsVisibleCycles));			// JEP
		return Result.MaxX>0.0f && Result.MaxY>0.0f && Result.MinX<Frame->FX && Result.MinY<Frame->FY;
	}

	// Compute hull position code.
	INT HullCode = 0;
	FVector NewMin = Bound->Min - Frame->Coords.Origin;
	FVector NewMax = Bound->Max - Frame->Coords.Origin;
	if     ( NewMin.X > 0.0f ) HullCode  = 1;
	else if( NewMax.X < 0.0f ) HullCode  = 2;
	if     ( NewMin.Y > 0.0f ) HullCode += 3;
	else if( NewMax.Y < 0.0f ) HullCode += 6;
	if     ( NewMin.Z > 0.0f ) HullCode += 9;
	else if( NewMax.Z < 0.0f ) HullCode += 17;

	static const BYTE HullVerts[27][8] = 
	{
	/*  0 */ {255},
	/*  1 */ {0,4,6,2,255},
	/*  2 */ {1,3,7,5,255},
	/*  3 */ {0,1,5,4,255},
	/*  4 */ {0,1,5,4,6,2,255},
	/*  5 */ {0,1,3,7,5,4,255},
	/*  6 */ {2,6,7,3,255},
	/*  7 */ {0,4,6,7,3,2,255},
	/*  8 */ {1,3,2,6,7,5,255},
	/*  9 */ {0,2,3,1,255},
	/* 10 */ {0,4,6,2,3,1,255},
	/* 11 */ {0,2,3,7,5,1,255},
	/* 12 */ {0,2,3,1,5,4,255},
	/* 13 */ {1,5,4,6,2,3,255},
	/* 14 */ {0,2,3,7,5,4,255},
	/* 15 */ {0,2,6,7,3,1,255},
	/* 16 */ {0,4,6,7,3,1,255},
	/* 17 */ {0,2,6,7,5,1,255},
	/* 18 */ {5,7,6,4,255},
	/* 19 */ {0,4,5,7,6,2,255},
	/* 20 */ {1,3,7,6,4,5,255},
	/* 21 */ {0,1,5,7,6,4,255},
	/* 22 */ {0,1,5,7,6,2,255},
	/* 23 */ {0,1,3,7,6,4,255},
	/* 24 */ {2,6,4,5,7,3,255},
	/* 25 */ {0,4,5,7,3,2,255},
	/* 27 */ {1,3,2,6,4,5,255},
	};
	/*{for( INT i=0; i<27; i++ )
	{
		INT Verts[8];
		INT Found[9];
		for( INT j=0; j<8; j++ )
			Verts[j]=Found[j]=0;
		INT x=i;
		if( x>=18 )
		{
			Verts[7]++;
			Verts[6]++;
			Verts[4]++;
			Verts[5]++;
			x -= 18;
		}
		if( x>=9 )
		{
			Verts[2]++;
			Verts[3]++;
			Verts[1]++;
			Verts[0]++;
			x -= 9;
		}
		if( x>=6 )
		{
			Verts[2]++;
			Verts[3]++;
			Verts[7]++;
			Verts[6]++;
			x -= 6;
		}
		if( x>=3 )
		{
			Verts[0]++;
			Verts[1]++;
			Verts[5]++;
			Verts[4]++;
			x -= 3;
		}
		if( x>=2 )
		{
			Verts[1]++;
			Verts[3]++;
			Verts[7]++;
			Verts[5]++;
			x -= 2;
		}
		if( x>=1 )
		{
			Verts[0]++;
			Verts[2]++;
			Verts[6]++;
			Verts[4]++;
			x -= 1;
		}
		check(x==0);
		for( INT u=0; u<8 && HullVerts[i][u]!=255; u++ )
		{
			check(HullVerts[i][u]>=0);
			check(HullVerts[i][u]<=7);
			if( !Verts[HullVerts[i][u]] )
				appErrorf("b %i [%i]",i,HullVerts[i][u]);
			Verts[HullVerts[i][u]]=0;
		}
		for( INT q=0; q<8; q++ )
			if( Verts[q]!=0 && Verts[q]!=3 )
				appErrorf("a %i [%i]",i,q);
	}}*/

	// Trivial in-bound accept.
	if( HullCode==0 )
	{
		Result.MinX = 0;
		Result.MinY = 0;
		Result.MaxX = Frame->FX;
		Result.MaxY = Frame->FY;
		Result.MinZ = 0;
		STAT(unclock(GStat.BoxIsVisibleCycles));			// JEP
		return 1;
	}

	/* Bounding sphere reject: Not worth it (slower).
	if( Toggle )
	{
		FVector Center   = 0.5f*(Bound->Min + Bound->Max);
		FLOAT   RadiusSq = FDistSquared(Center,Bound->Min);
		for( INT i=0; i<4; i++ )
		{
			FLOAT Dot = Frame->ViewPlanes[i].PlaneDot(Center);
			if( Dot<0.0f && Square(Dot)>RadiusSq )
			{
				unclock(GStat.BoxTime);
				return 0;
			}
		}
	}*/

	// Test bounding-box side-of-viewport rejection.  Since box is axis-aligned,
	// this can be optimized: Box can only be rejected if all 8 dot products of the
	// 8 box sides are less than zero. This is the case iff each dot product
	// component is less than zero.
	BoxDot[0].ZAxis = NewMin * Frame->Coords.ZAxis;
	BoxDot[1].ZAxis = NewMax * Frame->Coords.ZAxis;
	if
	(	BoxDot[0].ZAxis.X<0.0f && BoxDot[0].ZAxis.Y<0.0f && BoxDot[0].ZAxis.Z<0.0f
	&&	BoxDot[1].ZAxis.X<0.0f && BoxDot[1].ZAxis.Y<0.0f && BoxDot[1].ZAxis.Z<0.0f )
	{
		STAT(unclock(GStat.BoxIsVisibleCycles));			// JEP
		return 0;
	}

	// Transform bounding box min and max coords into screenspace.
	BoxDot[0].XAxis = NewMin * Frame->Coords.XAxis;
	BoxDot[1].XAxis = NewMax * Frame->Coords.XAxis;
	BoxDot[0].YAxis = NewMin * Frame->Coords.YAxis;
	BoxDot[1].YAxis = NewMax * Frame->Coords.YAxis;

	// View-pyramid reject with an outcode test.
	INT ThisCode, AllCodes;
	BoxMinZ = Pts[0].Point.Z;
	BoxMaxZ = Pts[0].Point.Z;
	OutCode  = 1|2|4|8;
	AllCodes = 0;
	#define CMD(i,j,k,First,P)\
		ThisCode = 0;\
		\
		P.Point.Z = BoxDot[i].ZAxis.X + BoxDot[j].ZAxis.Y + BoxDot[k].ZAxis.Z;\
		if( First || P.Point.Z < BoxMinZ ) BoxMinZ = P.Point.Z;\
		if( First || P.Point.Z > BoxMaxZ ) BoxMaxZ = P.Point.Z;\
		\
		P.Point.X = BoxDot[i].XAxis.X + BoxDot[j].XAxis.Y + BoxDot[k].XAxis.Z;\
		if( Frame->PrjXM * P.Point.Z + P.Point.X < 0 ) ThisCode |= 1;\
		if( Frame->PrjXP * P.Point.Z - P.Point.X < 0 ) ThisCode |= 2;\
		\
		P.Point.Y = BoxDot[i].YAxis.X + BoxDot[j].YAxis.Y + BoxDot[k].YAxis.Z;\
		if( Frame->PrjYM * P.Point.Z + P.Point.Y < 0 ) ThisCode |= 4;\
		if( Frame->PrjYP * P.Point.Z - P.Point.Y < 0 ) ThisCode |= 8;\
		\
		OutCode  &= ThisCode;\
		AllCodes |= ThisCode;
	CMD(0,0,0,1,Pts[0]); CMD(1,0,0,0,Pts[1]); CMD(0,1,0,0,Pts[2]); CMD(1,1,0,0,Pts[3]);
	CMD(0,0,1,0,Pts[4]); CMD(1,0,1,0,Pts[5]); CMD(0,1,1,0,Pts[6]); CMD(1,1,1,0,Pts[7]);
	#undef CMD
	if( OutCode )
	{
		// Invisible - pyramid reject.
		STAT(unclock(GStat.BoxIsVisibleCycles));			// JEP
		return 0;
	}

	// Calculate projections of 8 points and take X,Y min/max bounded to Span X,Y window.
	Pt       = &Pts[0];
	FLOAT RZ = Frame->Proj.Z / Pt->Point.Z;
	BoxMinX  = BoxMaxX = appFloor( Frame->FX2 + Pt->Point.X * RZ );
	BoxMinY  = BoxMaxY = appFloor( Frame->FY2 + Pt->Point.Y * RZ );
	if( AllCodes & 1 ) BoxMinX = 0;
	if( AllCodes & 2 ) BoxMaxX = Frame->X;
	if( AllCodes & 4 ) BoxMinY = 0;
	if( AllCodes & 8 ) BoxMaxY = Frame->Y;
	for( INT i=1; i<8; i++,Pt++ )
	{
		FLOAT RZ = Frame->Proj.Z / Pt->Point.Z;
		BoxX     = appFloor( Frame->FX2 + Pt->Point.X * RZ );
		BoxY     = appFloor( Frame->FY2 + Pt->Point.Y * RZ );
		if      ( BoxX < BoxMinX ) BoxMinX = BoxX;
		else if ( BoxX > BoxMaxX ) BoxMaxX = BoxX;
		if      ( BoxY < BoxMinY ) BoxMinY = BoxY;
		else if ( BoxY > BoxMaxY ) BoxMaxY = BoxY;
	}
	Result.MinX  = ::Max(BoxMinX,0);
	Result.MinY  = ::Max(BoxMinY,0);
	Result.MaxX  = ::Min(BoxMaxX,Frame->X);
	Result.MaxY  = ::Min(BoxMaxY,Frame->Y);
	Result.MinZ  = ::Max( BoxMinZ, 0.f );
	
	STAT(unclock(GStat.BoxIsVisibleCycles));			// JEP
	
	return ( !SpanBuffer || SpanBuffer->BoxIsVisible( BoxMinX, BoxMinY, BoxMaxX, BoxMaxY ) );
}

enum ENodePass
{
	PASS_Front=0,
	PASS_Plane=1,
};

struct FNodeStack
{
	INT				iNode;
	INT				iFarNode;
	INT				FarOutside;
	INT				Outside;
	ENodePass		Pass;
	FNodeStack*		Next;
};

static UBOOL VolumetricOccludes( const FVolActorLink* Link, FVector* VolCross, INT NumVolCross )
{
	for( INT i=0; i<NumVolCross; i++ )
		if( (Link->Location | VolCross[i]) > Link->Actor->WorldVolumetricRadius() )
			return 0;
	return 1;
}

void URender::LeafVolumetricLighting( FSceneNode* Frame, UModel* Model, INT iLeaf )
{
	// Static volumetrics.
	FLeaf& Leaf = Model->Leaves(iLeaf);
	if( Leaf.iVolumetric != INDEX_NONE )
	{
		AActor* Actor;
		for( INT i=Leaf.iVolumetric; (Actor=Model->Lights(i))!=NULL; i++ )
		{
			if( Actor->LightingTag!=(INT)Stamp )
			{
				Actor->LightingTag = Stamp;
				if( FDistSquared( Frame->Coords.Origin, Actor->Location ) > Square(Actor->WorldVolumetricRadius()) )
					for( int i=0; i<4; i++ )
						if( Frame->ViewPlanes[i].PlaneDot(Actor->Location) < -Actor->WorldVolumetricRadius() )
							goto Skip;
				FirstVolumetric = new(GDynMem)FVolActorLink( Frame->Coords, Actor, FirstVolumetric, 1 );
				Skip:;
			}
		}
	}

	// Dynamic volumetrics.
	for( FVolActorLink* Link=LeafLights[iLeaf]; Link; Link=Link->Next )
	{
		if( Link->Volumetric && Link->Actor->LightingTag!=(INT)Stamp )
		{
			Link->Actor->LightingTag = Stamp;
			FirstVolumetric = new(GDynMem)FVolActorLink( *Link, FirstVolumetric );
		}
	}
}

// JEP...
#define USE_FRONT_PROJECTOR_PLANE

#ifdef USE_FRONT_PROJECTOR_PLANE
	#define NUM_PROJECTOR_PLANES		(6)
#else
	#define NUM_PROJECTOR_PLANES		(5)
#endif

//=======================================================================================
//	OccludeProjector
//=======================================================================================
void __fastcall URender::OccludeProjector(FSceneNode* Frame, INT ProjectorIndex)
{
	UModel*				Model;
	FBspNode*			Node;
	INT          		iNode = 0,iOriginalNode = 0;
	FNodeStack*			Stack;
	INT					Outside;
	INT					Pass;
	FBspSurf*			Poly = NULL;
	DWORD				PolyFlags = 0;
	FVector				Origin;
	FPlane				*Planes[NUM_PROJECTOR_PLANES], BackPlane;
	DWORD				ClipFlags = ((1<<NUM_PROJECTOR_PLANES)-1);		// NUM_PROJECTOR_PLANES clip planes
	INT					SideIndexes[NUM_PROJECTOR_PLANES][6];
	DWORD				ProjectorFlag = 1<<ProjectorIndex;

	// If unrenderable.
	Model = Frame->Level->Model;
	if( !Model->Nodes.Num() )
		return;

	// Init
	Origin				= Frame->Coords.Origin;
	GNodes				= &Model->Nodes(0);
	GSurfs				= &Model->Surfs(0);
	GVerts				= &Model->Verts(0);
	GPoints				= &Model->Points;

	Stack				= New<FNodeStack>(GMem);
	Stack->Next			= NULL;
	iNode				= 0;
	Outside				= Model->RootOutside;
	Pass				= PASS_Front;

	// Add all the default frustum planes
	for( INT i=0; i<4; i++ )
		Planes[i] = &Frame->ViewPlanes[i];

	// Create the back plane, and add it to the list of planes to clip the bsp by
	//	(btw, this plane is created in camera space, and backwards transformed into world space)
	BackPlane.X = 0.0f;
	BackPlane.Y = 0.0f;
	BackPlane.Z = -1.0f;
	BackPlane.W = -Projectors[ProjectorIndex].wFar;
	BackPlane = BackPlane.TransformPlaneByOrtho(Frame->Uncoords);

	Planes[4] = &BackPlane;

#ifdef USE_FRONT_PROJECTOR_PLANE
	// Add front plane
	FPlane	FrontPlane;

	FrontPlane.X = 0.0f;
	FrontPlane.Y = 0.0f;
	FrontPlane.Z = 1.0f;
	FrontPlane.W = Projectors[ProjectorIndex].wNear;
	
	FrontPlane = FrontPlane.TransformPlaneByOrtho(Frame->Uncoords);

	Planes[5] = &FrontPlane;
#endif

	for (i = 0; i<NUM_PROJECTOR_PLANES; i++)
		BuildSideIndexesFromPlane(*Planes[i], SideIndexes[i]);

	for (;;)
	{
		Node = &GNodes[iNode];

		// Pass 1: Process node for the first time and optionally recurse with front node.
		if( Pass==PASS_Front )
		{
			if (NodeFrameStamp(iNode) != GFrameStamp)
				goto PopStack;				// Totally rejected

			if (Node->iRenderBound != INDEX_NONE && ClipFlags
				&&	(!Frame->Level->BrushTracker || !Frame->Level->BrushTracker->SurfIsDynamic(Node->iSurf)))
			{
				FVector		Reject, Accept;

				for( INT i=0; i<NUM_PROJECTOR_PLANES; i++ )
				{
					DWORD Mask = (1<<i);

					if (!(ClipFlags & Mask))
						continue;			// Don't need to check against this plane anymore

					//INT Side = BoxSide(Planes[i], &Model->Bounds(Node->iRenderBound), 0.001f);
					RejectAcceptFromSideIndexes(Model->Bounds(Node->iRenderBound), SideIndexes[i], Reject, Accept);
					INT Side = BoxSideFast(*Planes[i], Reject, Accept, 0.001f);

					if (Side == PSIDE_BACK)
						goto PopStack;				// Totally rejected
					if (Side == PSIDE_FRONT)
						ClipFlags &= ~Mask;			// Totally accepted (don't need to test against this plane anymore)
				}
			}
			
			// Set up stack to recurse into front.
			INT IsFront       = Node->Plane.PlaneDot(Origin) > 0.0f;
			Stack->iFarNode   = Node->iChild[1-IsFront];
			Stack->FarOutside = Node->ChildOutside(1-IsFront,Outside);

			if( Node->iChild[IsFront] != INDEX_NONE )
			{
				Stack->iNode		= iNode;
				Stack->Outside		= Outside;
				Stack->Pass  		= PASS_Plane;

				FNodeStack* Next	= Stack;
				Stack				= New<FNodeStack>(GMem);
				Stack->Next			= Next;

				iNode				= Node->iChild[IsFront];
				Outside				= Node->ChildOutside(IsFront,Outside);
				Pass				= PASS_Front;

				continue;
			}

			Pass = PASS_Plane;
		}
		#if 1
		// Pass 2: Process polys within this node and optionally recurse with back.
		if( Pass == PASS_Plane )
		{
			// Setup.
			iOriginalNode	= iNode;
			FLOAT Dot		= Node->Plane.PlaneDot(Origin);
			INT IsFront		= Dot>0.0f;

			// View frustrum rejection of the plane and back subtree.
			FLOAT Sign = IsFront ? 1.0f : -1.0f;
			if
			(	(Sign * (Node->Plane | Frame->ViewSides[0]) > 0.0f)
			&&	(Sign * (Node->Plane | Frame->ViewSides[1]) > 0.0f)
			&&	(Sign * (Node->Plane | Frame->ViewSides[2]) > 0.0f)
			&&	(Sign * (Node->Plane | Frame->ViewSides[3]) > 0.0f) )
				goto PopStack;

			// Process node and all of its coplanars.
			for( ;; )
			{
				// Note: Can't zone mask reject coplanars due to moving brush rules.
				Poly		= &GSurfs[Node->iSurf];
				PolyFlags	= Poly->PolyFlags;
				
				if (CoplanarNodeFrameStamp(iNode) != GFrameStamp)
					goto NextCoplanar;

				// Backface and portal reject.
				if( !IsFront && Dot<-1.0f && !(PolyFlags & PF_TwoSided))
					goto NextCoplanar;
				if((PolyFlags & PF_Portal))
					goto NextCoplanar;
				
				// The surface is visible from this projector
				/*
				if (Poly->ProjectorFrame != GFrameStamp)
				{
					Poly->ProjectorFlags = 0;
					Poly->ProjectorFrame = GFrameStamp;
				}
				if (Node->ProjectorFrame != GFrameStamp)
				{
					Node->ProjectorFlags = 0;
					Node->ProjectorFrame = GFrameStamp;
				}
				*/

				//if (!(Poly->ProjectorFlags & ProjectorFlag) && ClipFlags)
				if (!(Node->ProjectorFlags & ProjectorFlag) && ClipFlags)
				{
					for( INT i=0; i<NUM_PROJECTOR_PLANES; i++ )
					{
						DWORD Mask = (1<<i);

						if (!(ClipFlags & Mask))
							continue;			// Don't need to check against this plane anymore

						INT		NumPts		= Node->NumVertices;
						FVert*	VertPool	= &GVerts[Node->iVertPool];
						
						for (INT v =0; v<NumPts; v++)
						{
							INT pPoint = VertPool[v].pVertex;

							if (Planes[i]->PlaneDot((*GPoints)(pPoint)) > 0)
								break;
						}
						
						if (v == NumPts)
							break;		// Totally behind plane
					}
					
					if (i != NUM_PROJECTOR_PLANES)
						goto NextCoplanar;				// Totally rejected

					GStat.NumProjectorSurfs++;
				}
				
				Poly->ProjectorFlags |= ProjectorFlag;
				Node->ProjectorFlags |= ProjectorFlag;

				NextCoplanar:
				iNode = Node->iPlane;
				if( iNode==INDEX_NONE )
					break;
				Node	= &GNodes[iNode];
				Dot		= Node->Plane.PlaneDot(Origin);
				IsFront	= Dot > 0.0f;
			}

			iNode      = iOriginalNode;
			Node       = &GNodes[iNode];
			Dot		   = Node->Plane.PlaneDot( Origin );
			IsFront	   = Dot > 0.0f;

			// Set up recursion for back.
			if( Stack->iFarNode != INDEX_NONE )
			{
				iNode				= Stack->iFarNode;
				Outside				= Stack->FarOutside;
				Pass				= PASS_Front;
				continue;
			}
		}
		#endif
		// Return from recursion, noting that the node we're returning to is guaranteed visible if the
		// child we're processing now is visible.
		PopStack:
		Stack = Stack->Next;
		if( !Stack )
			break;

		iNode		= Stack->iNode;
		Outside		= Stack->Outside;
		Pass		= Stack->Pass;
	}
}
// ...JEP

void __fastcall URender::OccludeBsp( FSceneNode* Frame )
{
	UModel*				Model;
	FSpanBuffer			ZoneSpanBuffer[FBspNode::MAX_ZONES];
	FSpanBuffer*		SpanBuffer;
	FBspDrawList*		TempDrawList;
	FBspDrawList**		AllPolyDrawLists;
	FBspDrawList*		Merge;
	FBspNode*			Node;
	FBspSurf*			Poly;
	FNodeStack*			Stack;
	FTransform 			**Pts;
	FVector				Origin;
	DWORD				PolyFlags, PolyFlagsEx;
	DWORD				PolyFlagMask, ExtraPolyFlags;
	QWORD				ActiveZoneMask;
	INT          		iNode,iOriginalNode,iThingZone;
	BYTE				iViewZone;
	BYTE				iZone;
	BYTE				ViewZoneMask;
	INT           		Visible;
	INT					Mergeable;
	INT					Outside;
	INT					Pass;
	INT					NumPts;
	INT					IsVolumetric;
	INT					DrawBin;
	INT                 NumActiveZones;
	BYTE                ActiveZones[64];
	INT					iSkyZone = 0;
	ASkyZoneInfo*		pSkyZoneInfo;
	// NJS: This funtion is too performance critical for these checks in release mode.
	//check(Frame->Level->Model->Nodes.Num()<=MAX_NODES);
	//check(Frame->Level->Model->Points.Num()<=MAX_POINTS);

	// If unrenderable.
	Model = Frame->Level->Model;
	if( !Model->Nodes.Num() )
		return;

	// If we're in the editor, locate the skyzoneinfo.
	pSkyZoneInfo = NULL;
	if( GIsEditor )
	{
		// Use the first skyzone we come across.
		for( TObjectIterator<ASkyZoneInfo> It; It; ++It )
		{
			pSkyZoneInfo = *It;
			check(pSkyZoneInfo);
			break;
		}
	}

	// Init temporary caches.
	Stamp++;

	// Init.
	UViewport* Viewport = Frame->Viewport;
	URenderDevice* RenDev = Viewport->RenDev;
	TempDrawList		= new(GMem)FBspDrawList;
	AllPolyDrawLists    = new(GMem,MEM_Zeroed,Model->Surfs.Num())FBspDrawList*;
	Origin				= Frame->Coords.Origin;
	iViewZone			= Frame->ZoneNumber;
	ViewZoneMask		= iViewZone ? ~0 : 0;
	NumActiveZones      = 1;
	ActiveZones[0]      = iViewZone;
	ActiveZoneMask		= ((QWORD)1) << iViewZone;
	IsVolumetric        = RenDev->VolumetricLighting && RenDev->SupportsFogMaps && Viewport->Actor->Region.Zone->bFogZone;
	PolyFlagMask        = (Viewport->Actor->ShowFlags & SHOW_PlayerCtrl) ? ~0 : ~PF_Invisible;
	ExtraPolyFlags		= Viewport->ExtraPolyFlags;
	FirstVolumetric		= NULL;
	GFrame              = Frame;
	GNodes				= &Model->Nodes(0);
	GSurfs				= &Model->Surfs(0);
	GVerts				= &Model->Verts(0);
	GPoints				= &Model->Points;
	FLOAT TimeSeconds   = Frame->Level->GetLevelInfo()->TimeSeconds;
	Model->Zones[iViewZone].LastRenderTime = TimeSeconds;

	// If inside a warp zone, skip out and give this span buffer to the other side.
	AWarpZoneInfo* Warp = (AWarpZoneInfo*)Model->Zones[iViewZone].ZoneActor;
	if( Warp && Warp->IsA(AWarpZoneInfo::StaticClass()) && Warp->OtherSideActor && Warp->OtherSideLevel )
	{
		CreateChildFrame
		(
			Frame,
			Frame->Span,
			Frame->Level,
			INDEX_NONE,
			Warp->OtherSideActor->iWarpZone,
			Frame->Mirror,
			Frame->NearClip,
			Frame->Coords * Warp->WarpCoords * Warp->OtherSideActor->WarpCoords.Transpose(),
			NULL
		);
		return;
	}

	// Init zone span buffers.
	for( INT i=0; i<FBspNode::MAX_ZONES; i++ )
		ZoneSpanBuffer[i].AllocIndex(0,0,&GDynMem);
	ZoneSpanBuffer[iViewZone] = *Frame->Span;

	// Init unrolled recursion stack.
	Stack				= New<FNodeStack>(GMem);
	Stack->Next			= NULL;
	iNode				= 0;
	Outside				= Model->RootOutside;
	Pass				= PASS_Front;

	// Process everything in the world.
	for( ;; )
	{
		Node = &GNodes[iNode];

		// Pass 1: Process node for the first time and optionally recurse with front node.
		if( Pass==PASS_Front )
		{
			// Zone mask rejection.
			if( iViewZone && !(Node->ZoneMask & ActiveZoneMask))
			{
				// Use pure zone rejection.
				//STAT(GStat.MaskRejectZones++);
				goto PopStack;
			}

				// Bound rejection.
				if
				(	Node->iRenderBound != INDEX_NONE
				&&	(!Frame->Level->BrushTracker || !Frame->Level->BrushTracker->SurfIsDynamic(Node->iSurf))
				&&	((Node->NodeFlags&NF_BoxOccluded) || !((iNode^GFrameStamp)&15)) )
				{
					// Use bounding box rejection.
					Node->NodeFlags &= ~NF_BoxOccluded;
					FScreenBounds Results;
					if( !BoundVisible(Frame,&Model->Bounds(Node->iRenderBound),iViewZone?NULL:&ZoneSpanBuffer[0],Results) )
					{
						Node->NodeFlags |= NF_BoxOccluded;
						goto PopStack;
					}
					if( iViewZone )
					{
						for( INT i=0; i<NumActiveZones; i++ )
						{
							BYTE iZone = ActiveZones[i];
							if
							(	(Node->ZoneMask & ((QWORD)1<<iZone))
							&&	(ZoneSpanBuffer[iZone].BoxIsVisible(Results.MinX,Results.MinY,Results.MaxX,Results.MaxY)) )
								break;
						}
						if( i==NumActiveZones )
						{
							Node->NodeFlags |= NF_BoxOccluded;
							goto PopStack;
						}
					}
				}
			// Filter dynamics.
			for( FDynamicItem* Item = Dynamic(iNode,0); Item; Item=Item->FilterNext )
				Item->Filter( Viewport, Frame, iNode, Outside );

			if (Frame->Recursion == 0 && EnableShadows)
				NodeFrameStamp(iNode) = GFrameStamp;

			// Set up stack to recurse into front.
			INT IsFront       = Node->Plane.PlaneDot(Origin) > 0.0f;
			Stack->iFarNode   = Node->iChild[1-IsFront];
			Stack->FarOutside = Node->ChildOutside(1-IsFront,Outside);
			if( Node->iChild[IsFront] != INDEX_NONE )
			{
				Stack->iNode		= iNode;
				Stack->Outside		= Outside;
				Stack->Pass  		= PASS_Plane;

				FNodeStack* Next	= Stack;
				Stack				= New<FNodeStack>(GMem);
				Stack->Next			= Next;

				iNode				= Node->iChild[IsFront];
				Outside				= Node->ChildOutside(IsFront,Outside);
				Pass				= PASS_Front;

				continue;
			}
			Pass = PASS_Plane;
		}

		// Pass 2: Process polys within this node and optionally recurse with back.
		if( Pass == PASS_Plane )
		{
			// Zone mask rejection.
			if( iViewZone && !(Node->ZoneMask & ActiveZoneMask) )
				goto PopStack;

			// Setup.
			iOriginalNode	= iNode;
			FLOAT Dot		= Node->Plane.PlaneDot(Origin);
			INT IsFront		= Dot>0.0f;
			iThingZone      = Node->iZone[IsFront] & ViewZoneMask;

			// Render dynamic stuff in front of the plane.
			if( IsVolumetric && Node->iLeaf[IsFront]!=INDEX_NONE )
				LeafVolumetricLighting( Frame, Model, Node->iLeaf[IsFront] );
			if( ZoneSpanBuffer[iThingZone].ValidLines && (Node->ChildOutside(IsFront,Outside)||Toggle) )
				for( FDynamicItem* Item = Dynamic(iNode,1-IsFront); Item; Item=Item->FilterNext )
					Item->PreRender( Viewport, Frame, &ZoneSpanBuffer[iThingZone], iNode, FirstVolumetric );

			// View frustrum rejection of the plane and back subtree.
			FLOAT Sign = IsFront ? 1.0f : -1.0f;
			if
			(	(Sign * (Node->Plane | Frame->ViewSides[0]) > 0.0f)
			&&	(Sign * (Node->Plane | Frame->ViewSides[1]) > 0.0f)
			&&	(Sign * (Node->Plane | Frame->ViewSides[2]) > 0.0f)
			&&	(Sign * (Node->Plane | Frame->ViewSides[3]) > 0.0f) )
				goto PopStack;

			// Process node and all of its coplanars.
			for( ;; )
			{
				// Note: Can't zone mask reject coplanars due to moving brush rules.
				Poly		= &GSurfs[Node->iSurf];
				PolyFlags	= Poly->PolyFlags | ExtraPolyFlags;
				PolyFlagsEx	= Poly->PolyFlags2;
				// Backface and portal reject.
				if( !IsFront && Dot<-1.0f && !(PolyFlags & (PF_TwoSided|PF_Portal)) )
					goto NextCoplanar;
				if( (PolyFlags & PF_Portal) && iViewZone==0 )
					goto NextCoplanar;


				// Get zones.
				iZone         = Node->iZone[IsFront  ] & ViewZoneMask;
				SpanBuffer    = &ZoneSpanBuffer[iZone];

				// Span reject.
				if( SpanBuffer->ValidLines <= 0 )
					goto NextCoplanar;

				// Clip it.
				//STAT(GStat.NodesDone++);
				NumPts = ClipBspSurf( iNode, Pts );
				if( !NumPts )
					goto NextCoplanar;

				//begin code to force rendering of "sliver" polygons
				/*ForceRender=0;
				Area=0.f;
				{for( INT j=1,i=2; i<NumPts; j=i++ )
				{
					FLOAT DX0 = Pts[i]->ScreenX-Pts[0]->ScreenX;
					FLOAT DY0 = Pts[i]->ScreenY-Pts[0]->ScreenY;

					FLOAT DX1 = Pts[j]->ScreenX-Pts[0]->ScreenX;
					FLOAT DY1 = Pts[j]->ScreenY-Pts[0]->ScreenY;

					Area += (DX0*DY1-DX1*DY0);
				}}
				if( Area<5.f && SoftStats )
					ForceRender=1;
				{for( INT i=0,j=NumPts-1,k=NumPts-2; i<NumPts; k=j, j=i, i++ )
				{
					FLOAT DX0 = Pts[i]->ScreenX - Pts[j]->ScreenX;
					FLOAT DY0 = Pts[i]->ScreenY - Pts[j]->ScreenY;
					FLOAT N0  = appSqrt(DX0*DX0+DY0*DY0+0.001);

					FLOAT DX1 = Pts[j]->ScreenX - Pts[k]->ScreenX;
					FLOAT DY1 = Pts[j]->ScreenY - Pts[k]->ScreenY;
					FLOAT N1  = appSqrt(DX1*DX1+DY1*DY1+0.001);

					FLOAT Cross = (DX0*DY1-DX1*DY0)/(N0*N1);
					if( Cross<-0.9 && SoftStats )
						ForceRender=1;
				}}*/
				//end code to force rendering of "sliver" polygons

				// Fix facing.
				if( (!IsFront && (PolyFlags & (PF_TwoSided | PF_Portal))) ^ (Frame->Mirror==-1.f) )
					for( INT i=0; i<NumPts/2; i++ )
						Exchange( Pts[i], Pts[NumPts-i-1] );

				// Setup.
				if( !SetupRaster( Pts, NumPts, (Node->NodeFlags & NF_PolyOccluded) ? SpanBuffer : NULL, Frame->Y ) )
				{
					//STAT(unclock(GStat.RasterTime));
					goto NextCoplanar;
				}

				// Assimilate the texture's flags.
				if( Poly->Texture )
				{
					PolyFlags	|= Poly->Texture->PolyFlags;
					PolyFlagsEx |= Poly->Texture->PolyFlagsEx;
				}
				PolyFlags &= PolyFlagMask;

				// See if we should merge.
				Mergeable = !((PolyFlags & (PF_NoOcclude|PF_NoMerge|PF_Portal))||(PolyFlagsEx&PFX_NoOcclude));
				
				Merge = NULL;
				if( Mergeable )
				{
					AZoneInfo* ZoneActor = Frame->Level->GetZoneActor(Node->iZone[IsFront]);
					for( Merge=AllPolyDrawLists[Node->iSurf]; Merge; Merge=Merge->SurfNext )
						if( Merge->Zone==ZoneActor )
							break;
				}

				// Allocate fragment span buffer.
				TempDrawList->Span.AllocIndex( RasterStartY, RasterEndY, (Merge || !RenDev->SpanBased) ? &GMem : &GDynMem );

				// Perform the span buffer clipping and updating.
				STAT(clock(GStat.SpanTime));
				if
				(	!((PolyFlags & PF_NoOcclude) || (PolyFlagsEx&PFX_NoOcclude))
				||	(PolyFlags&(PF_Portal|PF_Invisible))==(PF_Portal|PF_Invisible) 
				||	(PolyFlags&(PF_Mirrored)) )
					Visible = TempDrawList->Span.CopyFromRasterUpdate( *SpanBuffer, RasterStartY, RasterEndY, HackRaster+RasterStartY );
				else		
					Visible = TempDrawList->Span.CopyFromRaster( *SpanBuffer, RasterStartY, RasterEndY, HackRaster+RasterStartY );
				STAT(unclock(GStat.SpanTime));

				if ( GIsEditor && pSkyZoneInfo )
					iSkyZone = pSkyZoneInfo->Region.ZoneNumber;
				else
					iSkyZone = iZone;

				// JEP...
				if (EnableShadows && Visible)
				{
					// Reset projector flags on this surface
					Poly->ProjectorFlags = 0;
					
					if (Frame->Recursion == 0)
						CoplanarNodeFrameStamp(iNode) = GFrameStamp;
				}
				// ...JEP

				// Process the spans.
				DrawBin = 1 + (((PolyFlags & PF_NoOcclude)||(PolyFlagsEx&PFX_NoOcclude))!=0);
				if( !Visible )
				{
					// Rejected, span buffer wasn't affected.
					Node->NodeFlags |= NF_PolyOccluded;
					TempDrawList->Span.Release();
				}
				else if
				(	(PolyFlags & PF_FakeBackdrop)
				&&  !(PolyFlags & PF_Environment)
				&&	((Frame->Level->GetZoneActor(iSkyZone)->SkyZone) || (GIsEditor && pSkyZoneInfo))
				&&	(Frame->Recursion<MAX_FRAME_RECURSION-1)
				&&	(Viewport->Actor->ShowFlags & SHOW_PlayerCtrl) )
				{
					// Handle sky portal.
					AZoneInfo* SkyZone = GIsEditor ? (AZoneInfo*)pSkyZoneInfo : (AZoneInfo*)Frame->Level->GetZoneActor(iSkyZone)->SkyZone;
					FCoords Coords = Frame->Coords;
					Coords *= Frame->Coords.Origin;
					Coords /= SkyZone->Rotation;
					Coords /= SkyZone->Location;

					FScreenBounds Bounds;
					Bounds.MinY = RasterStartY;
					Bounds.MaxY = RasterEndY;
					Bounds.MinX = RasterStartX;
					Bounds.MaxX = RasterEndX;

					CreateChildFrame
					(
						Frame,
						&TempDrawList->Span,
						Frame->Level,
						0,
						SkyZone->Region.ZoneNumber,
						Frame->Mirror,
						Frame->NearClip,
						Coords,
						Toggle ? NULL : &Bounds
					);
				}
				else if
				(	(PolyFlags & PF_FakeBackdrop)
				&&  (PolyFlags & PF_Environment)
				&&  (Viewport->GetPortalView( Poly->SurfaceTag ))
				&&	(Frame->Recursion<MAX_FRAME_RECURSION-1)
				&&	(Viewport->Actor->ShowFlags & SHOW_PlayerCtrl) )
				{
					// Handle neat special portal thing.
					AActor* PortalView = Viewport->GetPortalView( Poly->SurfaceTag );
					if (PortalView == NULL)
						return;
					FCoords Coords = Frame->Coords;
					Coords *= Frame->Coords.Origin;
					Coords /= PortalView->Rotation;
					Coords /= PortalView->CamRotAdjust;
					Coords /= PortalView->Location;

					FScreenBounds Bounds;
					Bounds.MinY=RasterStartY;
					Bounds.MaxY=RasterEndY;
					Bounds.MinX=RasterStartX;
					Bounds.MaxX=RasterEndX;

					CreateChildFrame
					(
						Frame,
						&TempDrawList->Span,
						Frame->Level,
						0,
						PortalView->Region.ZoneNumber,
						Frame->Mirror,
						Frame->NearClip,
						Coords,
						Toggle ? NULL : &Bounds
					);
				}
				else if
				(	(PolyFlags & PF_Mirrored)
				&&	(Frame->Recursion<MAX_FRAME_RECURSION-1)
				&&	(Viewport->Actor->ShowFlags & SHOW_PlayerCtrl) )
				{
					// Handle mirrored surface.
					if( (PolyFlags & PF_Translucent) && !RenDev->ShinySurfaces )
					{
						PolyFlags &= ~PF_Translucent;
						PolyFlags |= PF_Occlude;
						DrawBin = 1;
						goto DrawIt;
					}

					FScreenBounds Bounds;
					Bounds.MinY = RasterStartY;
					Bounds.MaxY = RasterEndY;
					Bounds.MinX = RasterStartX;
					Bounds.MaxX = RasterEndX;

					CreateChildFrame
					(
						Frame,
						&TempDrawList->Span,
						Frame->Level,
						0,
						iSkyZone,
						-Frame->Mirror,
						Node->Plane.TransformPlaneByOrtho( Frame->Coords ).Flip(),
						Frame->Coords.MirrorByPlane(Node->Plane),
						Toggle ? NULL : &Bounds
					);
					DrawBin = 0;
					if( !(PolyFlags & PF_NoOcclude) )
					{
						if( RenDev->SpanBased )
							goto NextCoplanar;
						PolyFlags |= PF_Invisible;
					}
					PolyFlags |= PF_Occlude;
					goto DrawIt;
				}
				else if( (PolyFlags & PF_Portal) && (Viewport->Actor->RendMap!=REN_Zones || (PolyFlags&PF_NoOcclude) ) )
				{
					UBOOL RenderPortal = !(PolyFlags & PF_Invisible);
					BYTE iOppositeZone = Node->iZone[1-IsFront] & ViewZoneMask;
					if( iOppositeZone!=0 && (PolyFlags&PF_NoOcclude) )
					{
						AWarpZoneInfo* Warp = (AWarpZoneInfo*)Model->Zones[iOppositeZone].ZoneActor;
						if( !Warp || !Warp->IsA(AWarpZoneInfo::StaticClass()) || Frame->Recursion>=MAX_FRAME_RECURSION-1 )
						{
							// Normal zone.
							NormalZone:
							QWORD OldMask = ActiveZoneMask;
							ActiveZoneMask |= ((QWORD)1)<<iOppositeZone;
							if( ActiveZoneMask != OldMask )
								ActiveZones[NumActiveZones++] = iOppositeZone;
							if( RenderPortal )
								ZoneSpanBuffer[iOppositeZone].MergeWith( FSpanBuffer( TempDrawList->Span, GDynMem) );
							else
								ZoneSpanBuffer[iOppositeZone].MergeWith( TempDrawList->Span );
							Model->Zones[iOppositeZone].LastRenderTime = TimeSeconds;
						}
						else
						{
							// Warp zone.
							if( Warp->OtherSideLevel==NULL || Warp->OtherSideActor==NULL )
							{
								Warp->eventGenerate();
								if( Warp->OtherSideLevel==NULL || Warp->OtherSideActor==NULL )
									goto NormalZone;
							}

							// Handle warp zone.
							CreateChildFrame
							(
								Frame,
								&TempDrawList->Span,
								(ULevel*)Warp->OtherSideLevel,
								Node->iSurf,
								Warp->OtherSideActor->iWarpZone,
								Frame->Mirror,
								(IsFront ? Node->Plane.Flip() : Node->Plane).TransformPlaneByOrtho(Frame->Coords),
								Frame->Coords * Warp->WarpCoords * Warp->OtherSideActor->WarpCoords.Transpose(),
								NULL
							);
							DrawBin = 0;
							if( (PolyFlags & PF_Invisible) && RenDev->SpanBased )
								goto NextCoplanar;
							PolyFlags |= PF_Occlude;
							goto DrawIt;
						}
					}
					if( RenderPortal )
					{
						// Actually display zone portals.
						Merge = 0;
						goto DrawIt;
					}
				}
				else if( !(PolyFlags & PF_Invisible) )
				{
					// Draw it.
					DrawIt:

					// Handle volumetrics.
					static FVector VolCross[32];
					INT NumVolCross=0;
					if( FirstVolumetric )
					{
						for( FTransform** P1=Pts,**P2=Pts+NumPts-1; P1<Pts+NumPts; P2=P1++ )
						{
							if( (*P2)->IntY!=INDEX_NONE )
							{
								VolCross[NumVolCross] = (*P1)->Point ^ (*P2)->Point;
								VolCross[NumVolCross] *= DivSqrtApprox(VolCross[NumVolCross].SizeSquared());
								NumVolCross++;
							}
						}
					}

					// Save drawing info.
					if( !Merge )
					{
						// Create new draw-list entry.
						TempDrawList->iNode		 = iNode;
						TempDrawList->iZone		 = Node->iZone[IsFront];
						TempDrawList->Zone       = Frame->Level->GetZoneActor(TempDrawList->iZone);
						TempDrawList->iSurf		 = Node->iSurf;
						TempDrawList->PolyFlags	 = PolyFlags;
						TempDrawList->PolyFlagsEx= PolyFlagsEx;
						TempDrawList->Next       = Frame->Draw[DrawBin];

						// Add to linked list.
						TempDrawList->SurfNext  = AllPolyDrawLists[Node->iSurf];
						AllPolyDrawLists[Node->iSurf] = TempDrawList;

						// Save applicable volumetric lights.
						TempDrawList->Volumetrics = NULL;
						for( FVolActorLink* Link=FirstVolumetric; Link; Link=Link->Next )
							if( VolumetricOccludes( Link, VolCross, NumVolCross ) )
								TempDrawList->Volumetrics = new(GDynMem)FActorLink( Link->Actor, TempDrawList->Volumetrics );

						// Save stuff out for hardware rendering.
						if( !RenDev->SpanBased )
						{
							FSavedPoly* Saved   = (FSavedPoly*)New<BYTE>(GDynMem,sizeof(FSavedPoly)+NumPts*sizeof(FTransform*));
							Saved->Next         = NULL;
							Saved->iNode        = iNode;
							TempDrawList->Polys = Saved;
							Saved->NumPts       = NumPts;
							for( INT i=0; i<NumPts; i++ )
								Saved->Pts[i] = Pts[i];

							TempDrawList->Span.Release();

							Node->ProjectorFlags = 0;			// JEP
						}

						// Sort key.
						TempDrawList->Key = TempDrawList->Zone->GetIndex() << (32-6);
						if( Poly->Texture )
						{
							TempDrawList->Key += Poly->Texture->GetIndex();
							if( Poly->Texture->Palette )	
								TempDrawList->Key += Poly->Texture->Palette->GetIndex() << 12;
						}

						Frame->Draw[DrawBin] = TempDrawList;
						TempDrawList = New<FBspDrawList>(GDynMem);
						PolysDraw++;
					}
					else
					{
						// Add to existing draw-list entry.
						if( !RenDev->SpanBased )
						{
							// Save stuff out for hardware rendering.
							FSavedPoly* Saved   = (FSavedPoly*)New<BYTE>(GDynMem,sizeof(FSavedPoly)+NumPts*sizeof(FTransform*));
							Saved->Next         = Merge->Polys;
							Saved->iNode        = iNode;
							Merge->Polys        = Saved;
							Saved->NumPts       = NumPts;
							for( INT i=0; i<NumPts; i++ )
								Saved->Pts[i] = Pts[i];
						
							Node->ProjectorFlags = 0;			// JEP
						}
						else
						{
							STAT(clock(GStat.SpanTime));
							Merge->Span.MergeWith( TempDrawList->Span );
							STAT(unclock(GStat.SpanTime));
						}
						TempDrawList->Span.Release();

						// Merge in the new volumetrics.
						for( FVolActorLink* Link=FirstVolumetric; Link; Link=Link->Next )
						{
							for( FActorLink* Other=Merge->Volumetrics; Other; Other=Other->Next )
								if( Other->Actor == Link->Actor )
									break;
							if( Other==NULL && VolumetricOccludes( Link, VolCross, NumVolCross ) )
								Merge->Volumetrics = new(GDynMem)FActorLink( Link->Actor, Merge->Volumetrics );
						}
					}
					Node->NodeFlags &= ~NF_PolyOccluded;
					NodesDraw++;

					// See if filled up.
					if( SpanBuffer->ValidLines <= 0 )
					{
						for( INT i=0,j=0; i<NumActiveZones; j+=ActiveZones[i++]!=iZone )
							ActiveZones[j] = ActiveZones[i];
						NumActiveZones=j;
						ActiveZoneMask &= ~(((QWORD)1)<<iZone);
						if( NumActiveZones==0 )
							return;
							//goto DoneRendering;
					}
				}

				NextCoplanar:
				iNode = Node->iPlane;
				if( iNode==INDEX_NONE )
					break;
				Node	= &GNodes[iNode];
				Dot		= Node->Plane.PlaneDot(Origin);
				IsFront	= Dot > 0.0f;
			}
			iNode      = iOriginalNode;
			Node       = &GNodes[iNode];
			Dot		   = Node->Plane.PlaneDot( Origin );
			IsFront	   = Dot > 0.0f;
			iThingZone = Node->iZone[1-IsFront] & ViewZoneMask;

			// Render dynamic stuff behind the plane.
			if( IsVolumetric && Node->iLeaf[1-IsFront]!=INDEX_NONE )
				LeafVolumetricLighting( Frame, Model, Node->iLeaf[1-IsFront] );
			if( ZoneSpanBuffer[iThingZone].ValidLines && (Node->ChildOutside(1-IsFront,Outside)||Toggle) )
				for( FDynamicItem* Item = Dynamic(iNode,IsFront); Item; Item=Item->FilterNext )
					Item->PreRender( Viewport, Frame, &ZoneSpanBuffer[iThingZone], iNode, FirstVolumetric );

			// Set up recursion for back.
			if( Stack->iFarNode != INDEX_NONE )
			{
				iNode				= Stack->iFarNode;
				Outside				= Stack->FarOutside;
				Pass				= PASS_Front;
				continue;
			}
		}

		// Return from recursion, noting that the node we're returning to is guaranteed visible if the
		// child we're processing now is visible.
		PopStack:
		Stack = Stack->Next;
		if( !Stack )
			break;

		iNode		= Stack->iNode;
		Outside		= Stack->Outside;
		Pass		= Stack->Pass;
	}
}

/*-----------------------------------------------------------------------------
	Span buffer Bsp rendering.
-----------------------------------------------------------------------------*/

//
// BSP draw list pointer for sorting.
//
struct FBspDrawListPtr
{
	FBspDrawList *Ptr;
	friend INT Compare( const FBspDrawListPtr& A, const FBspDrawListPtr& B )
	{
		return A.Ptr->Key - B.Ptr->Key;
	}
};

//
// Temporary optics.
//
struct FCoronaLight
{
	AActor* _Actor;
	INT     iActor;
	FLOAT   Bright;
};
#define MAX_CORONA_LIGHTS 64
static void __fastcall GAddCorona( FSceneNode* Frame, FCoronaLight* CoronaLights, INT& iFree, AActor* Light, FLOAT Delta )
{
	FCheckResult Hit;

	//if(Light->IsA(AFlareLight::StaticClass()))
	//{
	//	((AFlareLight *)Light)->ActorsBlock=true;
	//	((AFlareLight *)Light)->MeshAccurate=true;
	//}

	if
	(	Light->bCorona
	&& !Light->bDeleteMe)
	{
		if(Light->IsA(AFlareLight::StaticClass())&&((AFlareLight *)Light)->ActorsBlock)
		{
			if(!Frame->Level->SingleLineCheck( Hit, NULL, Light->Location, Frame->Coords.Origin, TRACE_AllColliding, FVector(0,0,0),0,((AFlareLight *)Light)->MeshAccurate ))
				return;
		} else
		{
			if(!Frame->Level->SingleLineCheck( Hit, NULL, Light->Location, Frame->Coords.Origin, TRACE_VisBlocking, FVector(0,0,0) ))
				return;
		}
		// Check my light cache.
		for( INT i=0; i<MAX_CORONA_LIGHTS; i++ )
			if( CoronaLights[i]._Actor == Light )
				break;

		if( i<MAX_CORONA_LIGHTS )
		{
			CoronaLights[i].Bright = Min(1.f,CoronaLights[i].Bright+2.f*Delta);
		}
		else
		{
			while( iFree<MAX_CORONA_LIGHTS && CoronaLights[iFree]._Actor )
				iFree++;
			if( iFree<MAX_CORONA_LIGHTS )
			{
				CoronaLights[iFree]._Actor = Light;
				CoronaLights[iFree].iActor = Light->GetLevel()->GetActorIndex(Light);
				CoronaLights[iFree].Bright = Min(1.f,2.f*Delta);
			}
		}
	}
}

//
// Draw the entire world.
//
void __fastcall URender::OccludeFrame( FSceneNode* Frame, TArray<AActor*> &Relevent )
{
	UViewport* Viewport = Frame->Viewport;
	ULevel*    Level    = Frame->Level;
	UModel*	   Model    = Level->Model;
	check(Model->Nodes.Num()>0);

	// Init rendering info.
	if( SurfLights==NULL || Level->Model->Surfs.Num()>MaxSurfLights )
	{
		MaxSurfLights = Level->Model->Surfs.Num();
		SurfLights    = (FActorLink**)appRealloc( SurfLights, MaxSurfLights * sizeof(FActorLink*), TEXT("SurfLights") );
		appMemzero( SurfLights, MaxSurfLights * sizeof(FActorLink*) );
	}
	if( Level->Model->Leaves.Num() && (LeafLights==NULL || Level->Model->Leaves.Num()>MaxLeafLights) )
	{
		MaxLeafLights = Level->Model->Leaves.Num();
		LeafLights    = (FVolActorLink**)appRealloc( LeafLights, MaxLeafLights * sizeof(FActorLink*), TEXT("LeafLights") );
		appMemzero( LeafLights, MaxLeafLights * sizeof(FVolActorLink*) );
	}
	NumDynLightSurfs  = 0;
	NumDynLightLeaves = 0;
	NumPostDynamics   = 0;
	PostDynamics      = new(GDynMem,Level->Model->Nodes.Num())URender::FDynamicsCache*;

	// Perform occlusion checking.
#if 0
	//SetupDynamics( Frame, (Viewport->Actor->bBehindView || Frame->Parent!=NULL) ? NULL : Viewport->Actor->ViewTarget ?  Viewport->Actor->ViewTarget : Viewport->Actor, Relevent  );
#else
	//void __forceinline SetupDynamics( FSceneNode* Frame, AActor* Exclude, TArray<AActor*> &Relevent  )
	AActor *Exclude=(Viewport->Actor->bBehindView || Frame->Parent!=NULL) ? NULL : Viewport->Actor->ViewTarget ?  Viewport->Actor->ViewTarget : Viewport->Actor;
	if
	(!(	!(Frame->Level->Model->Nodes.Num())
	||	!(Frame->Viewport->Actor->ShowFlags & SHOW_Actors) ))
	{
		STAT(clock(GStat.FilterTime));
		UBOOL HighDetailActors=Frame->Viewport->RenDev->HighDetailActors;
		UBOOL bHeatVision = Frame->Viewport->Actor->CameraStyle == PCS_HeatVision; // CDH

		// Traverse entire actor list.
		for( INT iActor=0; iActor<Relevent.Num(); iActor++ )
		{
			AActor* Actor=Relevent(iActor);
			if(!Actor) break;

			ARenderActor* RenderActor = NULL;
			if ( Actor->bIsRenderActor )
				RenderActor=(ARenderActor*)Actor;

			// Add this actor to dynamics if it's renderable.
			//AActor* Actor = Frame->Level->Actors(iActor);
			//if(!Actor) continue;

			if ( RenderActor )
			{
				if
				(	RenderActor
				&&	(!RenderActor->bHighDetail || HighDetailActors) 
				&&  (!RenderActor->bDontReflect || Frame->Recursion==0)
				&&	(Frame->Recursion!=0 || Frame->Viewport->Actor->bBehindView || RenderActor!=Frame->Viewport->Actor->ViewTarget) )
				{
					if
					(	(RenderActor != Exclude)
					&&	(GIsEditor ? !RenderActor->bHiddenEd : (!RenderActor->bHidden || (bHeatVision ? RenderActor->bHeatNoHide : 0)) ) // CDH: even if hidden, may be visible in heatvision

					// Call PlayerPawn Render Control Interface (RCI) to assess visible actors
					&&	( ( GIsEditor && !( Frame->Viewport->Actor->ShowFlags & SHOW_PlayerCtrl ) )
						|| ( Frame->Viewport->Actor->IsA( APlayerPawn::StaticClass() ) 
							&& Frame->Viewport->Actor->IsActorVisible( RenderActor ) ) )
					// Clip actors that aren't "visible" 
					&&	( (RenderActor->VisibilityRadius == 0.f || (RenderActor->Location - Frame->Coords.Origin).SizeSquared2D() < RenderActor->VisibilityRadius*RenderActor->VisibilityRadius)
						&&(RenderActor->VisibilityHeight == 0.f || Abs    ((RenderActor->Location - Frame->Coords.Origin).Z              ) < RenderActor->VisibilityHeight) )

					&&  (!RenderActor->bOwnerSeeSpecial || !RenderActor->IsOwnedBy(Frame->Viewport->Actor) || (RenderActor->IsOwnedBy(Frame->Viewport->Actor) && (Frame->Viewport->Actor->bBehindView || (Frame->Recursion!=0))))
					&&	(!RenderActor->bOnlyOwnerSee || (RenderActor->IsOwnedBy(Frame->Viewport->Actor) && !Frame->Viewport->Actor->bBehindView))
					&&	(!RenderActor->IsOwnedBy(Frame->Viewport->Actor) || !RenderActor->bOwnerNoSee || (RenderActor->IsOwnedBy(Frame->Viewport->Actor) && Frame->Viewport->Actor->bBehindView)) )
					{				
						// Add the sprite proxy.
						if( !RenderActor->IsMovingBrush() )
						{
							new(GDynMem)FDynamicSprite( Frame, 0, RenderActor );
						}
						else if( Frame->Level->BrushTracker )
						{
							//bounding box reject!!
							Frame->Level->BrushTracker->Update( RenderActor );
						}
					}

					if
					(	(RenderActor->LightType)
					&&	(!(RenderActor->bStatic || RenderActor->bNoDelete) || RenderActor->bDynamicLight)
					&&	(RenderActor->LightBrightness)
					&&	(RenderActor->LightRadius) )
					{
						// Add the dynamic light.
						FLOAT MaxRadius = Max( RenderActor->WorldLightRadius(), RenderActor->WorldVolumetricRadius() );
						for( int i=0; i<4; i++ )
							if( Frame->ViewPlanes[i].PlaneDot(RenderActor->Location) < -MaxRadius )
								break;
						if( i==4 )
						{
							UBOOL IsVolumetric = RenderActor->Region.Zone->bFogZone && RenderActor->VolumeRadius && RenderActor->VolumeBrightness;
							for( i=0; IsVolumetric && i<4; i++ )
								if( Frame->ViewPlanes[i].PlaneDot(RenderActor->Location) < -RenderActor->WorldVolumetricRadius() )
									IsVolumetric = 0;
							new(GDynMem)FDynamicLight( 0, RenderActor, IsVolumetric, 0 );
							STAT(GStat.DynLightActors++);
						}
					}
				}
			}
			else
			{
				if
				(	Actor
				&&  (!Actor->bDontReflect || Frame->Recursion==0)
				&&	(Frame->Recursion!=0 || Frame->Viewport->Actor->bBehindView || Actor!=Frame->Viewport->Actor->ViewTarget) )
				{
					if
					(	(Actor != Exclude)
					&&	(GIsEditor ? !Actor->bHiddenEd : !Actor->bHidden)

					// Call PlayerPawn Render Control Interface (RCI) to assess visible actors
					&&	( ( GIsEditor && !( Frame->Viewport->Actor->ShowFlags & SHOW_PlayerCtrl ) )
						|| ( Frame->Viewport->Actor->IsA( APlayerPawn::StaticClass() ) 
							&& Frame->Viewport->Actor->IsActorVisible( Actor ) ) ) )
					{				
						// Add the sprite proxy.
						if( !Actor->IsMovingBrush() )
						{
							new(GDynMem)FDynamicSprite( Frame, 0, Actor );
						}
						else if( Frame->Level->BrushTracker )
						{
							//bounding box reject!!
							Frame->Level->BrushTracker->Update( Actor );
						}
					}

					if
					(	(Actor->LightType)
					&&	(!(Actor->bStatic || Actor->bNoDelete) || Actor->bDynamicLight)
					&&	(Actor->LightBrightness)
					&&	(Actor->LightRadius) )
					{
						// Add the dynamic light.
						FLOAT MaxRadius = Max( Actor->WorldLightRadius(), Actor->WorldVolumetricRadius() );
						for( int i=0; i<4; i++ )
							if( Frame->ViewPlanes[i].PlaneDot(Actor->Location) < -MaxRadius )
								break;
						if( i==4 )
						{
							UBOOL IsVolumetric = Actor->Region.Zone->bFogZone && Actor->VolumeRadius && Actor->VolumeBrightness;
							for( i=0; IsVolumetric && i<4; i++ )
								if( Frame->ViewPlanes[i].PlaneDot(Actor->Location) < -Actor->WorldVolumetricRadius() )
									IsVolumetric = 0;
							new(GDynMem)FDynamicLight( 0, Actor, IsVolumetric, 0 );
							STAT(GStat.DynLightActors++);
						}
					}
				}
			}
		}
		STAT(unclock(GStat.FilterTime));
	}
#endif

	OccludeBsp( Frame );

	// Remember surface lights.
	for( INT i=0; i<3; i++ )
		for( FBspDrawList* Draw=Frame->Draw[i]; Draw; Draw=Draw->Next )
			Draw->SurfLights = SurfLights[Draw->iSurf];

	// Remember visible actor leaf lights.
	if( Level->Model->Leaves.Num() )
		for( FDynamicSprite* Sprite = Frame->Sprite; Sprite; Sprite=Sprite->RenderNext )
			if( Sprite->Actor->Region.iLeaf!=INDEX_NONE )
				Sprite->LeafLights = LeafLights[ Sprite->Actor->Region.iLeaf ];

	// Cleanup rendering info.
	for( i=0; i<NumPostDynamics; i++ )
	{
		PostDynamics[i]->Dynamics[0] = NULL;
		PostDynamics[i]->Dynamics[1] = NULL;
	}


	for( i=0; i<NumDynLightSurfs; i++ )
	{
		SurfLights[ DynLightSurfs[i] ] = NULL;
	}
	
	for( i=0; i<NumDynLightLeaves; i++ )
	{
		LeafLights[ DynLightLeaves[i] ] = NULL;
	}

	// Occlude child frames.
	for( FSceneNode* F=Frame->Child; F; F=F->Sibling )
		OccludeFrame( F, Relevent );
}


void __fastcall URender::DrawFrame( FSceneNode* Frame )
{
	UViewport* Viewport = Frame->Viewport;
	UModel*	   Model    = Frame->Level->Model;
	check(Model->Nodes.Num()>0);

	// First, draw children.
	for( FSceneNode* F=Frame->Child; F; F=F->Sibling )
		DrawFrame( F );

	// Clear the Z-buffer if portal surfaces are visible.
	if( Frame->Draw[0] )
		Viewport->RenDev->ClearZ( Frame );

	// Count surfaces to draw.
	INT Num[3]={0,0,0};
	for( INT Pass=0; Pass<3; Pass++ )
		for( FBspDrawList* Draw = Frame->Draw[Pass]; Draw; Draw = Draw->Next )
			Num[Pass]++;

	// Group surfaces into solid (draw-order invariant) and transparent.
	FBspDrawListPtr* FirstDraw [3];
	FirstDraw[0] = new(GMem,Num[0])FBspDrawListPtr;
	FirstDraw[1] = new(GMem,Num[1])FBspDrawListPtr;
	FirstDraw[2] = new(GMem,Num[2])FBspDrawListPtr;
	FBspDrawListPtr* LastDraw  [3] = {FirstDraw[0],FirstDraw[1],FirstDraw[2]};
	for( Pass=0; Pass<3; Pass++ )
		for( FBspDrawList* Draw = Frame->Draw[Pass]; Draw; Draw = Draw->Next )
			(LastDraw[Pass]++)->Ptr = Draw;
	for( INT i=0; i<Num[0]/2; i++ )
		Exchange( FirstDraw[0][i], FirstDraw[0][Num[0]-i-1] );

	// Sort solid surfaces by texture and then by palette for cache coherence.
	Sort( FirstDraw[1], Num[1] );

	// Render everything.
	FLOAT T = Frame->Level->GetLevelInfo()->GameTimeSeconds;

	for( Pass=0; Pass<3; Pass++ )
	{
		// Draw everything in the world.
		for( FBspDrawListPtr* DrawPtr = FirstDraw[Pass]; DrawPtr<LastDraw[Pass]; DrawPtr++ )
		{
			// Setup for this surface.
			FBspDrawList*	Draw = DrawPtr->Ptr;
			FBspSurf*		Surf = &Model->Surfs( Draw->iSurf );
			

			// Compute texture LOD.
			UTexture* Texture = Surf->Texture ? Surf->Texture->Get(Viewport->CurrentTime) : Viewport->Actor->Level->DefaultTexture;
			/*INT TextureLOD=0;
			if( !Viewport->RenDev->SpanBased )
			{
				FLOAT Scale = appSqrt(Max(Model->Vectors(Surf->vTextureU).SizeSquared(),Model->Vectors(Surf->vTextureV).SizeSquared()));
				FLOAT MinZ = 65536.0f;
				for( FSavedPoly* PolyIt=Draw->Polys; PolyIt; PolyIt=PolyIt->Next )
					for( INT i=0; i<PolyIt->NumPts; i++ )
						MinZ = Min(MinZ,PolyIt->Pts[i]->Point.Z);
				TextureLOD = Clamp<INT>( appCeilLogTwo(1.3 * LodBias * Scale * MinZ / Frame->FX), Texture->DefaultLOD(), MAX_TEXTURE_LOD-1 );
			}*/
			INT TextureLOD=-1;

			// Setup panning.
			FLOAT PanU = Surf->PanU;
			if( Surf->PolyFlags & PF_AutoUPan )
			{
				PanU += ((INT)(T * 35.f * Draw->Zone->TexUPanSpeed * 256.0f)&0x3ffff)/256.f;
			}
			FLOAT PanV = Surf->PanV;
			if( Surf->PolyFlags & PF_AutoVPan )
			{
				PanV += ((INT)(T * 35.f * Draw->Zone->TexVPanSpeed * 256.0f)&0x3ffff)/256.f;
			}
			if( Surf->PolyFlags & PF_SmallWavy )
			{
				PanU += 8.f * appSin(T) + 4.f * appCos(2.3f*T);
				PanV += 8.f * appCos(T) + 4.f * appSin(2.3f*T);
			}

			// Make SurfaceInfo.
			FSurfaceInfo Surface;
			Surface.Level			= Frame->Level;
			Surface.PolyFlags		= Draw->PolyFlags;
			Surface.LightMap		= NULL;
			Surface.MacroTexture	= NULL;
			Surface.DetailTexture	= NULL;
			Surface.FogMap			= NULL;	

			// Make TextureMap.
			FTextureInfo TextureMap;
			Texture->Lock( TextureMap, Viewport->CurrentTime, TextureLOD, Viewport->RenDev );
			TextureMap.Pan  = FVector( -PanU, -PanV, 0 );
			Surface.Texture = &TextureMap;

			// Make DetailTexture.
			FTextureInfo DetailTexture;
			if( Texture->DetailTexture && !(Surface.PolyFlags & PF_Portal) && TextureLOD<2 && UTexture::__Client && UTexture::__Client->TextureLODSet[LODSET_World]==0 )
			{
				Texture->DetailTexture->Lock( DetailTexture, Viewport->CurrentTime, -1, Viewport->RenDev );
				Surface.DetailTexture = &DetailTexture;
			}

			// Make MacroTexture.
			FTextureInfo MacroTexture;
			if( Texture->MacroTexture )
			{
				Texture->MacroTexture->Lock( MacroTexture, Viewport->CurrentTime, -1, Viewport->RenDev );
				Surface.MacroTexture = &MacroTexture;
			}

			// Make SurfaceFacet.
			FSurfaceFacet Facet;
			Facet.Polys = Draw->Polys;
			Facet.Span = &Draw->Span;
			Facet.MapCoords = FCoords
			(
				Model->Points (Surf->pBase),
				Model->Vectors(Surf->vTextureU),
				Model->Vectors(Surf->vTextureV),
				Model->Vectors(Surf->vNormal)
			);

			// Setup lighting for this surface.
			if
			(	Surf->iLightMap!=INDEX_NONE
			&&	Viewport->Actor->RendMap==REN_DynLight
			&&	Model->LightMap.Num() 
			&&	!Viewport->GetOuterUClient()->NoLighting )
				GLightManager.SetupForSurf
				(
					Frame,
					Facet.MapCoords,
					Draw,
					Surface.LightMap,
					Surface.FogMap,
					Pass==0
				);
			
			// Update facet.
			Facet.MapCoords *= Frame->Coords;

			// Handle flatshading.
			if
			(	Viewport->Actor->RendMap==REN_Polys
			||	Viewport->Actor->RendMap==REN_PolyCuts
			||	Viewport->Actor->RendMap==REN_Zones )
			{
				UModel*		Model		= Viewport->Actor->GetLevel()->Model;
				FBspNode*	Node 		= &Model->Nodes( Draw->iNode );
				FBspSurf*	Surf 		= &Model->Surfs( Node->iSurf );
				UTexture*	Texture		= Surf->Texture ? Surf->Texture->Get(Viewport->CurrentTime) : Viewport->Actor->Level->DefaultTexture;
				FVector Color;
				if( Viewport->Actor->RendMap==REN_Polys )
				{
					INT Index = Texture->GetIndex();
					Color = FVector( (Index*67)&255, (Index*1371)&255, (Index*1991)&255 )/256.0f;
				}
				else if( Viewport->Actor->RendMap!=REN_Zones || Model->NumZones==0 )
				{
					INT Index = Viewport->Actor->RendMap==REN_Polys ? Node->iSurf : Draw->iNode;
					Color = Texture->MipZero.Plane() * (0.5f + (Index&7)/16.0f);
				}
				else
				{
					// Render Zones:
					if( Draw->iZone == 0 )
						Color = Texture->MipZero.Plane();
					else
						Color = FVector( (Draw->iZone*67)&255, (Draw->iZone*1371)&255, (Draw->iZone*1991)&255 )/256.0f;
					Color *= (0.5f + (Draw->iNode&7)/16.0f);
				}
				Surface.FlatColor = FColor(Color);
				Surface.PolyFlags |= PF_FlatShaded;
			}

			// Draw the surface.
			PUSH_HIT(Frame,HBspSurf(Draw->iSurf));
			//Surface.PolyFlags&=~(PF_NoOcclude|PF_Masked); // NJS: Test
			//Surface.PolyFlags|=PF_Occlude;
			Viewport->RenDev->DriverValidate();	// Attempt to validate the driver.
			Viewport->RenDev->DrawComplexSurface(Frame,Surface,Facet);
			
			POP_HIT(Frame);

			//STAT(clock(GStat.DecalTime));
			// NJS: Maintain and Render Decals:
			if( !Viewport->RenDev->SpanBased && Viewport->GetOuterUClient()->Decals )	
			{
				UBOOL LockedTexture=0;
				UTexture* DecalTexture=NULL;		// NJS: Setting this to NULL initially prevents a stack overflow.
				FTextureInfo DecalTextureInfo;

				// Draw any decals
				for( INT i=0; i < Surf->Decals.Num(); i++ )
				{
					FDecal* DecalIt = &Surf->Decals(i);
					
					// NJS: Evaluate Decal Behavior:
					if(DecalIt->Behavior!=DB_Normal)
					{
						switch(DecalIt->Behavior)
						{
							case DB_Permanant:	break;	// Do nothing, leave it alone.							
							case DB_DestroyAfterArgumentSeconds:
								if(DecalIt->SpawnTime+DecalIt->BehaviorArgument<Viewport->Actor->Level->TimeSeconds) 
								{ 
									Surf->Decals.Remove(i); i--; 
									continue;
								}
								break;

							case DB_DestroyNotVisibleForArgumentSeconds:
								if(DecalIt->LastRenderedTime+DecalIt->BehaviorArgument<Viewport->Actor->Level->TimeSeconds) 
								{ 
									Surf->Decals.Remove(i); i--; 
									continue;
								}
								break;							
						}
					}

					if( !LockedTexture )
					{
						DecalTexture=DecalIt->Texture;
					
						if(!DecalTexture) Viewport->Actor->Level->DefaultTexture;
						DecalTexture->Lock( DecalTextureInfo, Viewport->CurrentTime, -1, Viewport->RenDev );
					} 

					//Viewport->RenDev->QueuePolygonBegin(Frame);

					for( FSavedPoly* PolyIt=Facet.Polys; PolyIt; PolyIt = PolyIt->Next )
					{
						INT Found;
						if(DecalIt->Nodes.Num() > 0 && !DecalIt->Nodes.FindItem(PolyIt->iNode, Found))
							continue;
						INT	DecalNumPoints = 0;
						FTransTexture**	DecalPoints = NULL;
						//STAT(clock(GStat.DecalClipTime));
						ClipDecal( Frame, DecalIt, Model, Surf, PolyIt, DecalPoints, DecalNumPoints );
						//STAT(unclock(GStat.DecalClipTime));
						if(DecalNumPoints != 0)
						{
							// NJS: Add to decal:
							DecalIt->LastRenderedTime=Viewport->Actor->Level->TimeSeconds;
							Viewport->RenDev->DrawGouraudPolygon( Frame, DecalTextureInfo, DecalPoints, DecalNumPoints, DecalIt->PolyFlags|PF_Unlit, &Draw->Span);
							//Viewport->RenDev->DrawGouraudPolygon( Frame, DecalTextureInfo, DecalPoints, DecalNumPoints, DecalIt->PolyFlags|PF_Unlit|PF_Masked /*GetPolyFlags( Frame, DecalIt->Actor)*//* NJS: USE NORMAL RENDER STYLE *//*PF_Modulated*/, &Draw->Span );
							
							//Viewport->RenDev->QueuePolygonBegin(Frame);
							//Viewport->RenDev->QueuePolygon( &DecalTextureInfo, DecalPoints, DecalNumPoints, DecalIt->PolyFlags|PF_Unlit|PF_Occlude/*GetPolyFlags( Frame, DecalIt->Actor)*//* NJS: USE NORMAL RENDER STYLE *//*PF_Modulated*/, DecalIt->PolyFlagsEx, &Draw->Span );
							//Viewport->RenDev->QueuePolygonEnd();
							//STAT(GStat.DecalCount++);
						}
					}
					//Viewport->RenDev->QueuePolygonEnd();

					if( i<Surf->Decals.Num()-1 && (DecalIt->Texture/*Actor->Texture*/==Surf->Decals(i+1).Texture/*Actor->Texture*/) )
						LockedTexture = 1;	
					else
					{
						DecalTexture->Unlock( DecalTextureInfo );
						LockedTexture = 0;
					}
				}
			}

			// Finish up.
			Texture->Unlock(TextureMap);
			if( Surface.DetailTexture )				 Texture->DetailTexture->Unlock(DetailTexture);
			if( Surface.MacroTexture )				 Texture->MacroTexture->Unlock(MacroTexture);
			if( Surface.LightMap || Surface.FogMap ) GLightManager.FinishSurf();
		}

		// Sort transparent sprites in front of masked and transparent geometry;
		// sort all others in back of masked/transparent geometry.
		for( FDynamicSprite* Sprite = Frame->Sprite; Sprite; Sprite=Sprite->RenderNext )
		{
			UBOOL bTranslucent = Sprite->Actor && Sprite->Actor->Style==STY_Translucent;
			if
			(	(Pass==2 && bTranslucent)
			||	(Viewport->RenDev->SpanBased ? Pass==2 : (Pass==1 && !bTranslucent) ) )
				DrawActorSprite( Frame, Sprite );
		}
	}


	// Optics.
	if
	(	Viewport->Actor->Region.iLeaf!=INDEX_NONE
	&&	Viewport->Actor->Region.Zone 
	&&	Viewport->RenDev->Coronas 
	&&	Frame->Recursion==0 )
	{
		// Do coronas.
		FCacheItem*   Item         = NULL;
		QWORD         CacheID      = MakeCacheID( CID_CoronaCache, (UObject*)0 );
		FCoronaLight* CoronaLights = (FCoronaLight*)GCache.Get( CacheID, Item );

		if( !CoronaLights )
		{
			CoronaLights = (FCoronaLight*)GCache.Create( CacheID, Item, MAX_CORONA_LIGHTS * sizeof(FCoronaLight) );
			for( int i=0; i<MAX_CORONA_LIGHTS; i++ )
				CoronaLights[i]._Actor = NULL;
		}

		// Corona and lens flare lighting.
		static DOUBLE LastTime = appSeconds();
		FLOAT Delta            = 10.f * (appSeconds() - LastTime);
		LastTime               = appSeconds();
		for( INT i=0; i<MAX_CORONA_LIGHTS; i++ )
			if( CoronaLights[i]._Actor && (CoronaLights[i].Bright-=Delta)<0 )
				CoronaLights[i]._Actor = NULL;
		INT iFree=0;
		INT iPermeating = Viewport->Actor->GetLevel()->Model->Leaves(Viewport->Actor->Region.iLeaf).iPermeating;
		if( iPermeating!=INDEX_NONE )
		{
			AActor** LightPtr = &Viewport->Actor->GetLevel()->Model->Lights(iPermeating);
			while( *LightPtr )
				GAddCorona( Frame, CoronaLights, iFree, *LightPtr++, Delta );
		}
		for( FVolActorLink* Link=LeafLights[Viewport->Actor->Region.iLeaf]; Link; Link=Link->Next )
			GAddCorona( Frame, CoronaLights, iFree, Link->Actor, Delta );


		for( i=0; i<MAX_CORONA_LIGHTS; i++ )
		{
			AActor* Light = CoronaLights[i]._Actor;



			// NJS: FIXME: this actor validation logic is fucked.
			if(Light
			 //&&CoronaLights[i].iActor<=Viewport->Actor->GetLevel()->Actors.Num()
			 //&&Viewport->Actor->GetLevel()->Actors(CoronaLights[i].iActor)==Light
			 )
			{
				check(Light->IsValid());
				FVector Loc = Light->Location.TransformPointBy(Frame->Coords);
				if(Loc.Z>0)
				{
					BYTE    H     = Light->LightHue;
					FVector Hue   = (H<86) ? FVector((85-H)/85.f,(H-0)/85.f,0) : (H<171) ? FVector(0,(170-H)/85.f,(H-85)/85.f) : FVector((H-170)/85.f,0,(255-H)/84.f);
					FLOAT	Alpha = Light->LightSaturation / 255.f;
					FVector Color = (Hue + Alpha * (FVector(1,1,1) - Hue));
					FLOAT   RZ    = Frame->Proj.Z / Loc.Z;
					FLOAT   X     = Loc.X * RZ + Frame->FX2;
					FLOAT   Y     = Loc.Y * RZ + Frame->FY2;
					FLOAT   Scale = 512.f * Light->DrawScale * Frame->X/640;
					
					// Process lens flares:
					if(Light->IsA(AFlareLight::StaticClass()))
					{
						AFlareLight *FlareLight=(AFlareLight *)Light;

						// Compute whether or not I'm in the view cone:
						bool InCone=true;
						FVector DirectionToViewer=Viewport->Actor->Location-Light->Location;
						DirectionToViewer.Normalize();
						float DotProduct=Light->Rotation.Vector() dot DirectionToViewer;
						if(DotProduct<(1.f-(FlareLight->LightCone/255.f))) InCone=false;

						for( int j=0; j<ARRAY_COUNT(FlareLight->LensFlares); j++ )
						{
							FLensFlare &LensFlare=FlareLight->LensFlares[j];
							if(LensFlare.FlareTexture==NULL) break;

							FLOAT A  = LensFlare.Offset; //
							FLOAT OffsetX=(Viewport->Canvas->X/2-X)*A;
							FLOAT OffsetY=(Viewport->Canvas->Y/2-Y)*A;
							FLOAT XX = X + OffsetX;
							FLOAT YY = Y + OffsetY;

							// abort render if primary light source isn't "inside the camera lens"
							if( !j)
								if( XX < 0
								 || YY < 0
								 || XX > Viewport->Canvas->ClipX 
								 || YY > Viewport->Canvas->ClipY ) 
									break;

							// Handle spotlight like occlusion:
							if(LensFlare.UseCone&&!InCone)
								continue;

							// Compute my 2D distance from the center of the screen.
							float Distance2D=0.f;
							if(OffsetX||OffsetY)
								Distance2D=appSqrt(OffsetX*OffsetX+OffsetY*OffsetY);

							// Compute my base rotation:
							float Rot=0.f;
							if(LensFlare.RotationFactor&&(OffsetX||OffsetY))
								Rot=LensFlare.RotationFactor*Distance2D;


							Rot+=((LensFlare.RotationVelocity*appSeconds())/(2*PI));
							// Compute base scale:
							float RadiusScale;
							if(Distance2D<=FlareLight->InnerRadius) // Between origin and inner radius.
							{
								RadiusScale=Lerp(LensFlare.OriginScale,LensFlare.InnerRadiusScale,(Distance2D/FlareLight->InnerRadius));
							} else if(Distance2D<=FlareLight->OuterRadius) // Between Inner radius and outer radius
							{
							    RadiusScale=Lerp(LensFlare.InnerRadiusScale,LensFlare.OuterRadiusScale,((Distance2D-FlareLight->InnerRadius)/(FlareLight->OuterRadius-FlareLight->InnerRadius)));
							} else // Outside the outer radius
							{
								RadiusScale=LensFlare.OuterRadiusScale;
							}

							float Sc = Scale * 0.2f* LensFlare.Scale *RadiusScale;
							Scale+=(Loc.Z*-LensFlare.DistanceScaleFactor);	// Process distance scaling

							// Render the flares:
							float AngleMultiplier=(2*PI)/(LensFlare.AdditionalCopies+1);
														
							for(int i=0;i<=LensFlare.AdditionalCopies;i++)
								if(LensFlare.FlareTexture)
									Viewport->Canvas->DrawIcon( LensFlare.FlareTexture, XX-Sc/2, YY-Sc/2, Sc, Sc, NULL, 1.f, CoronaLights[i].Bright * RZ * Color, FPlane(0,0,0,0), PF_TwoSided | PF_Translucent, 0, true/*bilinear*/, 1.0/*alpha*/, Rot+(AngleMultiplier*i) );
						}
					} else
					{
						if(Light->Skin)
							Viewport->Canvas->DrawIcon( Light->Skin, X-Scale/2, Y-Scale/2, Scale, Scale, NULL, 1.f, CoronaLights[i].Bright * RZ * Color, FPlane(0,0,0,0), PF_TwoSided | PF_Translucent, 0, true );
					}
				}
			}
		}
		Item->Unlock();
	}

	// Sky cleanup.
	if( Cast<ASkyZoneInfo>(Frame->Level->Model->Zones[Frame->ZoneNumber].ZoneActor) )
		Viewport->RenDev->ClearZ( Frame );

	// Finish up.
	STAT(GStat.GMem += GMem.GetByteCount());
	STAT(GStat.GDynMem += GDynMem.GetByteCount());
	STAT(GStat.NodesTotal += Frame->Level->Model->Nodes.Num());
}

//
// Clip decals
//
INT __fastcall URender::ClipDecal( FSceneNode* Frame, FDecal *Decal, UModel* Model, FBspSurf* Surf, FSavedPoly* Poly, FTransTexture**& DecalPoints, INT& NumPts )
{
	static FVector			Pts[FBspNode::MAX_FINAL_VERTICES];
	static FVector			PolyPts[FBspNode::MAX_FINAL_VERTICES];
	static FTransTexture*	LocalDecalPointsArr[FBspNode::MAX_FINAL_VERTICES];
	static FTransTexture	LocalDecalPoints[FBspNode::MAX_FINAL_VERTICES];
	static FLOAT			Dots[FBspNode::MAX_FINAL_VERTICES];
	FVector &SurfNormal = Model->Vectors(Surf->vNormal);
	FVector &SurfBase = Model->Points(Surf->pBase);
	NumPts = 4;
	FVector Adj = SurfNormal;
	Adj.Normalize();
	for( INT i=0;i<NumPts;i++ )
		Pts[i] = Decal->TransformedVerts[i] + SurfBase + Adj;
	for( i=0;i<Poly->NumPts;i++)
		PolyPts[i] = Poly->Pts[i]->Point.TransformPointBy( Frame->Uncoords );
	INT Prev = Poly->NumPts - 1;
	for(i=0;i<Poly->NumPts;i++)
	{
		// setup clipping plane for this polygon edge
		FPlane ClipPlane = FPlane( PolyPts[i], (PolyPts[Prev] - PolyPts[i]) ^ (Frame->Coords.Origin - PolyPts[i]) ); 
	
		for(INT j=0;j<NumPts;j++)
			Dots[j] = Frame->Mirror * ClipPlane.PlaneDot( Pts[j] );
		for(j=0;j<NumPts;j++)
		{
			// changed from (j+1)%NumPts
			INT n = j+1;
			if( n == NumPts )
				n=0;
			if(		(Dots[j] > 0 && Dots[n] < 0) 
				||	(Dots[j] < 0 && Dots[n] > 0))
			{
				FVector NewPoint = FLinePlaneIntersection( Pts[j], Pts[n], ClipPlane );
				if(j < NumPts-1)
				{	
					// move Dots[] and Pts[] arrays along
					appMemmove( &Dots[j+2], &Dots[j+1], sizeof(FLOAT) * (NumPts - j - 1));
					appMemmove( &Pts[j+2], &Pts[j+1], sizeof(FVector) * (NumPts - j - 1));
				}
				Pts[j+1] = NewPoint;
				Dots[j+1] = 0; 
				NumPts++;
				j++;
				checkSlow(NumPts < FBspNode::MAX_FINAL_VERTICES);
			}
		}
		for(j=0;j<NumPts;j++)
		{
			if( Dots[j] < 0 )
			{
				appMemmove( &Dots[j], &Dots[j+1], sizeof(FLOAT) * (NumPts - j - 1));
				appMemmove( &Pts[j], &Pts[j+1], sizeof(FVector) * (NumPts - j - 1) );
				j--;
				NumPts--;
			}
		}
		if( NumPts == 0 )
			return 0;
		Prev = i;
	}
	FLOAT Unlit  = Clamp( Decal->ScaleGlow*0.5f + Decal->AmbientGlow/256.f, 0.f, 1.f );
	DecalPoints = LocalDecalPointsArr;
	for(i=0;i<NumPts;i++)
	{
		DecalPoints[i] = &LocalDecalPoints[i];
		Pipe( *DecalPoints[i], Frame, Pts[i] );
		if(DecalPoints[i]->Flags)
		{
			DecalPoints[i]->Project( Frame );//!!
			DecalPoints[i]->ScreenX = Clamp<FLOAT>(DecalPoints[i]->ScreenX, 0, Frame->X - 1);
			DecalPoints[i]->ScreenY = Clamp<FLOAT>(DecalPoints[i]->ScreenY, 0, Frame->Y - 1);
		}
		DecalPoints[i]->U = ((Pts[i] - SurfBase - Decal->TransformedVerts[0]) | (Decal->TransformedVerts[1] - Decal->TransformedVerts[0]) / (Decal->TransformedVerts[1] - Decal->TransformedVerts[0]).Size()) / Decal->DrawScale;
		DecalPoints[i]->V = ((Pts[i] - SurfBase - Decal->TransformedVerts[0]) | (Decal->TransformedVerts[3] - Decal->TransformedVerts[0]) / (Decal->TransformedVerts[3] - Decal->TransformedVerts[0]).Size()) / Decal->DrawScale;
		DecalPoints[i]->Light = FVector( Unlit, Unlit, Unlit );
		DecalPoints[i]->Fog   = FPlane(0,0,0,0);
	}
	return NumPts;
}

//
// Draw the entire world.
//
EXECVAR_HELP(UBOOL, BList,true,"Enable/Disable BList");
void __fastcall URender::DrawWorld( FSceneNode* Frame )
{
	FMemMark SceneMark(GSceneMem);
	FMemMark MemMark(GMem);
	FMemMark DynMark(GDynMem);
	FMemMark VectorMark( VectorMem );
	GFrameStamp++;

	// Render mode.
//	if( !Frame->Viewport->Actor->bAdmin && Frame->Viewport->Actor->Level->bNoCheating && !GIsEditor )
//	{
//		Frame->Viewport->Actor->RendMap = REN_DynLight;
//		Frame->Viewport->GetOuterUClient()->NoLighting = 0;
//	}

	// NJS: Build a NULL terminated TArray of actors:
	INT actorCount=Frame->Viewport->Actor->XLevel->Actors.Num();
	INT relevantActorCount=0;
//	UBOOL HighDetailActors=Frame->Viewport->RenDev->HighDetailActors;
//	AActor *Exclude=(Frame->Viewport->Actor->bBehindView || Frame->Parent!=NULL) ? NULL : Frame->Viewport->Actor->ViewTarget ?  Frame->Viewport->Actor->ViewTarget : Frame->Viewport->Actor;
	UBOOL bHeatVision=Frame->Viewport->Actor->CameraStyle==PCS_HeatVision;   // CDH

	TArray<AActor*> RelevantActors(actorCount+1);
	for(INT iActor=0;iActor<actorCount;iActor++)
	{
		AActor  *current=Frame->Viewport->Actor->XLevel->Actors(iActor);
		if(!current) continue;
	
		//Frame->Viewport->Actor->Level->DefaultVisibilityRadius=10.0f;
		if(BList)
		{
			if ( current->bIsRenderActor )
			{
				ARenderActor* RenderCurrent = (ARenderActor*) current;

//				if(!(!RenderCurrent->bHighDetail || HighDetailActors)) continue; // Handle high detail bastardos 
				//if(!((Frame->Recursion!=0 || RenderCurrent!=Frame->Viewport->Actor->ViewTarget) )) continue;

				if(!(
					(	/*(RenderCurrent != Exclude)
					&&*/	(GIsEditor ? !RenderCurrent->bHiddenEd : (!RenderCurrent->bHidden || (bHeatVision ? RenderCurrent->bHeatNoHide : 0)) ) // CDH: even if hidden, may be visible in heatvision
					&&	(!RenderCurrent->bOnlyOwnerSee || (RenderCurrent->IsOwnedBy(Frame->Viewport->Actor) && !Frame->Viewport->Actor->bBehindView)) )
				))
				{
					if(!(
					(	(RenderCurrent->LightType)
					&&	(!(RenderCurrent->bStatic || RenderCurrent->bNoDelete) || RenderCurrent->bDynamicLight)
					&&	(RenderCurrent->LightBrightness)
					&&	(RenderCurrent->LightRadius) )
					))
						continue;
				}
			

				if(!RenderCurrent->bIgnoreBList&&BList&&!GIsEditor)
				{
					UBOOL ignoreNextStep=false;

					if(RenderCurrent->VisibilityRadius)
					{
						ignoreNextStep=true;
						if((Frame->Viewport->Actor->Location-RenderCurrent->Location).SizeSquared2D()>(RenderCurrent->VisibilityRadius*RenderCurrent->VisibilityRadius))
							continue;
					}

					if(RenderCurrent->VisibilityHeight)
					{
						ignoreNextStep=true;
						if(Abs(RenderCurrent->Location.Z-Frame->Viewport->Actor->Location.Z)>RenderCurrent->VisibilityHeight)
							continue;
					}

					if(!ignoreNextStep && (Frame->Viewport->Actor->Level->DefaultVisibilityRadius||Frame->Viewport->Actor->Region.Zone->DefaultVisibilityRadius))
					{
						FLOAT DistanceSquared=(RenderCurrent->Location-Frame->Viewport->Actor->Location).SizeSquared();

						if(Frame->Viewport->Actor->Region.Zone->DefaultVisibilityRadius)
						{
							FLOAT b=Frame->Viewport->Actor->Region.Zone->DefaultVisibilityRadius;
							ignoreNextStep=true;
							if(DistanceSquared>b*b)
								continue;
						}
						if(!ignoreNextStep&&Frame->Viewport->Actor->Level->DefaultVisibilityRadius)
						{
							FLOAT b=Frame->Viewport->Actor->Level->DefaultVisibilityRadius;
							// ignoreNextStep=true; // NJS: Not needed here
							if(DistanceSquared>b*b)
								continue;
						}
					}
				}
			}
			else
			{
				if(!(GIsEditor ? !current->bHiddenEd : !current->bHidden ))
				{
					if(!(
					(	(current->LightType)
					&&	(!(current->bStatic || current->bNoDelete) || current->bDynamicLight)
					&&	(current->LightBrightness)
					&&	(current->LightRadius) )
					))
						continue;
				}
			

				if(!current->bIgnoreBList&&BList&&!GIsEditor)
				{
					UBOOL ignoreNextStep=false;

					if(!ignoreNextStep && (Frame->Viewport->Actor->Level->DefaultVisibilityRadius||Frame->Viewport->Actor->Region.Zone->DefaultVisibilityRadius))
					{
						FLOAT DistanceSquared=(current->Location-Frame->Viewport->Actor->Location).SizeSquared();

						if(Frame->Viewport->Actor->Region.Zone->DefaultVisibilityRadius)
						{
							FLOAT b=Frame->Viewport->Actor->Region.Zone->DefaultVisibilityRadius;
							ignoreNextStep=true;
							if(DistanceSquared>b*b)
								continue;
						}
						if(!ignoreNextStep&&Frame->Viewport->Actor->Level->DefaultVisibilityRadius)
						{
							FLOAT b=Frame->Viewport->Actor->Level->DefaultVisibilityRadius;
							// ignoreNextStep=true; // NJS: Not needed here
							if(DistanceSquared>b*b)
								continue;
						}
					}
				}
			}
		}

		RelevantActors(relevantActorCount)=current;
		relevantActorCount++;
	}
	RelevantActors(relevantActorCount)=NULL;
	GStat.BListedActors=actorCount-relevantActorCount;	

	// JEP... (Handle projectors/shadows)
	NumProjectors = 0;

	EnableShadows = Frame->Viewport->GetOuterUClient()->ShadowDetail > 0;

	if (Frame->Viewport->GetOuterUClient()->ShadowDetail == 1)
	{
		GMaxShadowLightsPerActor = 1;
		GMaxFinalShadowActors = 8;
	}
	else if (Frame->Viewport->GetOuterUClient()->ShadowDetail == 2)
	{
		GMaxShadowLightsPerActor = 1;
		GMaxFinalShadowActors = 12;
	}
	else
	{
		GMaxShadowLightsPerActor = 2;
		GMaxFinalShadowActors = 16;
	}

	if (EnableShadows)
	{
		if (Frame->Level->Model)
		{
			INT NumNodes = Frame->Level->Model->Nodes.Num();

			if (NumNodes > NodeFrameStamp.Num())
				NodeFrameStamp.AddZeroed(NumNodes-NodeFrameStamp.Num());
			if (NumNodes > CoplanarNodeFrameStamp.Num())
				CoplanarNodeFrameStamp.AddZeroed(NumNodes-CoplanarNodeFrameStamp.Num());
		}

	#if 1
		if (ShadowRenderTargetsCreated && GMaxFinalShadowActors != NumShadowRenderTargets)
			DestroyShadowRenderTargets(Frame->Viewport);

		// Create shadow caster Render targets
		if (!ShadowRenderTargetsCreated)
			CreateShadowRenderTargets(Frame->Viewport, GMaxFinalShadowActors);
	#else
		if (!ShadowRenderTargetsCreated)
			CreateShadowRenderTargets(Frame->Viewport, MAX_SHADOW_RENDER_TARGETS);
	#endif
		
		STAT(clock(GStat.ShadowRenderCycles));
		if (NumShadowRenderTargets > 0)
			BuildShadowCasters(Frame, RelevantActors);
		STAT(unclock(GStat.ShadowRenderCycles));
	}
	else
	{
		if (ShadowRenderTargetsCreated)
			DestroyShadowRenderTargets(Frame->Viewport);
	}
	// ...JEP

	// ... NJS
	// Give the audio subsystem a chance to process the listener's surrounding geometry.
	if( Engine->Audio && !GIsEditor )
		Engine->Audio->RenderAudioGeometry( Frame );

	// adjust LOD if rendering too slowly
#if 0
	if ( Frame->Viewport->Actor->GetLevel()->GetLevelInfo()->bDropDetail )
	{
		if ( Frame->Viewport->Actor->GetLevel()->GetLevelInfo()->bAggressiveLOD )
			GlobalShapeLODAdjust = Clamp(GlobalShapeLODAdjust+0.1f,1.f,1.6f);
		else if ( GlobalShapeLODAdjust > 1.3f )
			GlobalShapeLODAdjust -= 0.1f;
		else
			GlobalShapeLODAdjust = Clamp(GlobalShapeLODAdjust+0.1f,1.f,1.6f);
	}
	else if ( GlobalShapeLODAdjust > 1.f )
		GlobalShapeLODAdjust = Clamp(GlobalShapeLODAdjust-0.1f,1.f,1.6f);
#else
	if ( Frame->Viewport->Actor->GetLevel()->GetLevelInfo()->bDropDetail )
	{
		GlobalShapeLODAdjust=0.9f;
		//GlobalShapeLODAdjust-=0.05f;
		//if(GlobalShapeLODAdjust<0.90f) GlobalShapeLODAdjust=0.90f;
	} else
	{
		GlobalShapeLODAdjust=1.f;
		//GlobalShapeLODAdjust+=0.05f;
		//if(GlobalShapeLODAdjust>=1.f) GlobalShapeLODAdjust=1.f;
	}
#endif


	// Occlude and render all scene frames.
STAT(clock(GStat.OcclusionTime));		// JEP
	OccludeFrame( Frame, RelevantActors );
STAT(unclock(GStat.OcclusionTime));		// JEP
	
	// JEP...
	if (EnableShadows)
	{
		STAT(clock(GStat.OccludeProjectorCycles));
		for (INT k = 0; k< NumProjectors; k++)
			GRender->OccludeProjector(Projectors[k].Frame, Projectors[k].ProjectorIndex);
		STAT(unclock(GStat.OccludeProjectorCycles));
	}
	// ...JEP

	DrawFrame( Frame );
	
	// Have HUD draw the player's weapon on top (and any other overlays which should happen before screen flashes). 
	AActor* Actor
	= Frame->Viewport->Actor->bBehindView ? NULL 
	: Frame->Viewport->Actor->ViewTarget ? Frame->Viewport->Actor->ViewTarget
	: Frame->Viewport->Actor;
	if
	(	!GIsEditor
	&&	Actor
	&&	(Frame->Viewport->Actor->ShowFlags & SHOW_Actors) )
	{
		GUglyHackFlags|=1;
		Frame->Viewport->RenDev->SetTextureClampMode( 1 );
		Actor->eventRenderOverlays(Frame->Viewport->Canvas);
		Frame->Viewport->RenDev->SetTextureClampMode( 0 );
		GUglyHackFlags&=~1;
	}

	MemMark.Pop();
	DynMark.Pop();
	SceneMark.Pop();
	VectorMark.Pop();
}

/*-----------------------------------------------------------------------------
	Global subsystem instantiation.
-----------------------------------------------------------------------------*/
ENGINE_API URender*	GRender = NULL;

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/


