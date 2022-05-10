//===========================================================================
//	ABreakableGlass.cpp
//	John Pollard
//===========================================================================
#include "EnginePrivate.h"

IMPLEMENT_CLASS(ABreakableGlass);

#define MAX_WORK_VERTS				(64)			// For rendering and cutting up
#define	MAX_TOTAL_GLASS_PARTICLES	(2048)			// Total glass particles we allow the GGlassParticles to expand to

#define MAX_PARTICLE_VERTS			(8)				// The final count on a particles cannot exceed this number

#define INITIAL_GLASS_PARTICLE_SIZE	(128)
#define PARTICLE_EXTEND_AMOUNT		(128)

#define PARTICLE_LIFE_FADE			(0.5f)

struct GlassParticle
{
	FVector		Verts[MAX_PARTICLE_VERTS];
	INT			NumVerts;

	FLOAT		Dist;			// Dist from breakpoint (for sorting)

	FLOAT		CountDown;		// Seconds this particle will live after physics have started

	// Physics related stuff
	UBOOL		DoPhysics;		// == true if physics should be performed (the particle is broken off from the main glass)
	FVector		Origin;			// Origin is in local space
	FVector		Location;		// Location is in local space
	FRotator	Rotation;		// Local space
	FVector		Velocity;		// World space (it's transformed to local space before being applied)

	FCoords		FrozenToWorld;	// What the parent glass transform was when the glass broke off

	FRotator	OverRot;

	UBOOL		InWorld;
};

struct GlassUserData
{
	UBOOL		Shattered;		// == true if glass has been considered shattered (pieces start to fall)

	FCoords		LocalToWorld;
	FCoords		WorldToLocal;
	FCoords		LocalToCamera;

	FBox		RenderBox;

	INT			NumAllocatedParticles;

	FLOAT		RespawnTime;
	INT			NumOriginalParticles;
	INT			RandomRotateDir;

#ifdef SPECIAL_SUBDIVIDE
	FVector		UnBrokenVerts[4][4];
	UBOOL		UnBrokenVertsValid;
#endif
};

// The all mighty globals section (used by ALL actors)
static GlassParticle				GGlassParticles[MAX_TOTAL_GLASS_PARTICLES];
static INT							GNumGlassParticles = 0;
static INT							GFreedGlassParticles[MAX_TOTAL_GLASS_PARTICLES];
static INT							GNumFreedGlassParticles = 0;
static FTransTexture				WorkPolyVerts[MAX_WORK_VERTS];

static TArray<ABreakableGlass*>		GGlassActors;

#define GLASS_PARTICLES(p) ((GlassParticle**)p->GlassParticles)
#define GLASS_USERDATA(p) ((GlassUserData*)p->UserData)

// Local static functions
static void FindParticleOrigins(ABreakableGlass *Glass);
static void PackParticlePointers(ABreakableGlass *Glass);
static void SortTestParticles(ABreakableGlass *Glass, FVector &BreakLocation);
static void BreakGlassFinal(ABreakableGlass *Glass, FVector *pVerts, INT NumVerts, FVector &BreakLocation);
static void BreakGlassXY(ABreakableGlass *Glass, FVector *pVerts, INT NumVerts, FLOAT X, FLOAT Y, FVector &BreakLocation);
static void ProjectWorldToGlass(ABreakableGlass *Glass, FVector *pVerts, INT NumVerts, FVector &Location, FLOAT &BreakX, FLOAT &BreakY);
static void CalcGenericRenderBox(ABreakableGlass *Glass);
static void GlassInternalTick(ABreakableGlass *Glass, FLOAT DeltaTime);
#ifdef RANDOM_BREAKS
static void BreakGlassRandom(ABreakableGlass *Glass, FVector *pVerts, INT NumVerts);
#endif
static void DrawTri(FSceneNode *Frame, FTransTexture **TriPts, FTextureInfo *TexInfo, DWORD PolyFlags);
static void DrawPolygon(ABreakableGlass *Glass, FSceneNode *Frame, FVector *pVerts, INT NumVerts, FVector &Color, FCoords &ModelToCamera, FTextureInfo *TexInfo, FLOAT ShiftU, FLOAT ShiftV, FLOAT ScaleU, FLOAT ScaleV);
static void DrawGlassParticle(ABreakableGlass *Glass, FSceneNode *Frame, GlassParticle *Particle, FVector &Color, FTextureInfo *TexInfo);
static void DoParticlePhysics(ABreakableGlass *Glass, GlassParticle *Particle, FLOAT DeltaTime);
static void StartParticlePhysics(ABreakableGlass *Glass, INT NumParticles, UBOOL DirForce = false, FVector *Dir = NULL, FVector *BreakLoc = NULL);
static void FreeGlassParticles(ABreakableGlass *Glass);
static void ResetGlass(ABreakableGlass *Glass);

static UBOOL g_GlassEnviroMap;

//===========================================================================
//	GlassIsValid
//===========================================================================
static UBOOL GlassIsValid(ABreakableGlass *Glass)
{
	if (!Glass->GlassParticles)
		return false;
	if (!Glass->UserData)
		return false;
	
	return true;
}

//===========================================================================
//	GlassIsDone
//===========================================================================
static UBOOL GlassIsDone(ABreakableGlass *Glass)
{
	if (Glass->GlassBreakCount > 0 && Glass->NumGlassParticles == 0)
		return true;	

	return false;
}

//===========================================================================
//	GlassPlaySound
//===========================================================================
static void GlassPlaySound(ABreakableGlass *Glass, USound *Sound, UBOOL RandomPitch = false, FLOAT Pitch1 = 1.0f, FLOAT Pitch2 = 1.0f)
{
	if (Sound)
	{
		if (RandomPitch)
		{
			FLOAT	Pitch = Pitch1 + ((appRand()&255)*(1.0f/255.0f))*(Pitch2-Pitch1);
			Pitch = Clamp(Pitch, Pitch1, Pitch2);
			Glass->PlayActorSound(Sound, SLOT_Misc, Glass->TransientSoundVolume, 0, Glass->TransientSoundRadius, Pitch, 0);
		}
		else
			Glass->PlayActorSound(Sound, SLOT_Misc, Glass->TransientSoundVolume, 0, Glass->TransientSoundRadius, 1.0f, 0);
	}
}

//===========================================================================
//	InitializeNewParticle
//===========================================================================
static void InitializeNewParticle(ABreakableGlass *Glass, GlassParticle *Particle)
{
	Particle->DoPhysics = false;
	Particle->Location = FVector(0.0f, 0.0f, 0.0f);
	Particle->Rotation = FRotator(0,0,0);
	Particle->Velocity = FVector(0.0f, 0.0f, 0.0f);
	Particle->CountDown = (Glass->ParticleLife > 0.0f) ? Glass->ParticleLife : 99999.0f;
	Particle->InWorld = false;
			
	check(Glass->NumGlassParticles < GLASS_USERDATA(Glass)->NumAllocatedParticles);

	GLASS_PARTICLES(Glass)[Glass->NumGlassParticles++] = Particle;
}

/*
static void BuildGlassQuad(ABreakableGlass *Glass, FVector *Quad)
{
	for (INT i=0; i<4; i++)
		Quad[i].X = 0.0f;

	FLOAT HalfX = Glass->GlassSizeX*0.5f;
	FLOAT HalfY = Glass->GlassSizeY*0.5f;

	Quad[0].Y = -HalfX;
	Quad[0].Z = -HalfY;
	Quad[1].Y =  HalfX;
	Quad[1].Z = -HalfY;
	Quad[2].Y =  HalfX;
	Quad[2].Z =  HalfY;
	Quad[3].Y = -HalfX;
	Quad[3].Z =  HalfY;
}
*/

//===========================================================================
//	BuildGlassQuad2
//===========================================================================
static void BuildGlassQuad2(ABreakableGlass *Glass, FVector *Quad, FLOAT X, FLOAT Y, FLOAT W, FLOAT H)
{
	for (INT i=0; i<4; i++)
		Quad[i].X = 0.0f;

	Quad[0].Y = X;
	Quad[0].Z = Y;
	Quad[1].Y = X+W;
	Quad[1].Z = Y;
	Quad[2].Y = X+W;
	Quad[2].Z = Y+H;
	Quad[3].Y = X;
	Quad[3].Z = Y+H;
}

//===========================================================================
//	BuildGlassQuad
//===========================================================================
static void BuildGlassQuad(ABreakableGlass *Glass, FVector *Quad)
{
	FLOAT HalfX = Glass->GlassSizeX*0.5f;
	FLOAT HalfY = Glass->GlassSizeY*0.5f;

	BuildGlassQuad2(Glass, Quad, -HalfX, -HalfY, Glass->GlassSizeX, Glass->GlassSizeY);
}

//===========================================================================
//	JGlassPrimitive
//===========================================================================
class JGlassPrimitive : public UPrimitive
{
public:
	DECLARE_CLASS( JGlassPrimitive, UPrimitive, 0 );
	
    ABreakableGlass   *GlassInstance;

    JGlassPrimitive() {};
	
    virtual UBOOL PointCheck
	(
        FCheckResult	&Result,
        AActor			*Owner,
        FVector			Location,
        FVector			Extent,
        DWORD			ExtraNodeFlags
	);

	virtual UBOOL LineCheck
	(
		FCheckResult	&Result,
		AActor			*Owner,
		FVector			End,
		FVector			Start,
		FVector			Extent,
		DWORD		ExtraNodeFlags,
		UBOOL		bMeshAccurate=0
	);

    virtual FBox GetRenderBoundingBox(const AActor* Owner, UBOOL Exact);

    virtual FBox GetCollisionBoundingBox( const AActor* Owner ) const;
};

IMPLEMENT_CLASS(JGlassPrimitive);

#define GLASS_PRIMITIVE(p) ((JGlassPrimitive*)p->GlassPrimitive)

//===========================================================================
//	PointCheckAgainstConvexVol
//===========================================================================
static UBOOL PointCheckAgainstConvexVol(FPlane *Planes, INT NumPlanes, FVector Loc, FVector &Extent)
{
	for (INT i=0; i<NumPlanes; i++)
	{
		FLOAT PushOut = FBoxPushOut(Planes[i], Extent*1.1f);

		FLOAT Dist = Planes[i].PlaneDot(Loc) - PushOut;

		if (Dist >= 0.0f)
			return false;
	}

	return true;
}

//===========================================================================
//	JGlassPrimitive::PointCheck
//===========================================================================
UBOOL JGlassPrimitive::PointCheck
(
	FCheckResult	&Result,
	AActor			*Owner,
	FVector			Location,
	FVector			Extent,
	DWORD			ExtraNodeFlags
)
{
    ABreakableGlass		*Glass = this->GlassInstance;

	if (!Glass)
		return true;

	if (!Glass->bBlockPlayers)
		return true;

	if (!GlassIsValid(Glass))
		return true;

	if (GlassIsDone(Glass))
		return true;

	if (Extent == FVector(0,0,0) )
		return true;		// Points can't be "inside" glass

	// Slower box check
	
	FCoords ModelToWorld = Glass->ToWorld();

	FLOAT		HalfX = Glass->GlassSizeX*0.5f;
	FLOAT		HalfY = Glass->GlassSizeY*0.5f;

	FPlane		Planes[6];
	FVector		Normal(1,0,0);

	Planes[0] = FPlane(Normal, 0.0f);
	Planes[1] = FPlane(-Normal, 0.0f);

	Normal = FVector(0,1,0);

	Planes[2] = FPlane(Normal, HalfX);
	Planes[3] = FPlane(-Normal, HalfX);

	Normal = FVector(0,0,1);

	Planes[4] = FPlane(Normal, HalfY);
	Planes[5] = FPlane(-Normal, HalfY);

	// Put planes into worldspace
	for (INT i=0; i< 6; i++)
		Planes[i] = Planes[i].TransformPlaneByOrtho(ModelToWorld);

	if (PointCheckAgainstConvexVol(Planes, 6, Location, Extent))
		return false;

	return true;
}

static INT		HitPlaneIndex = -1;
static FLOAT	HitTime = 0.0f;

//===========================================================================
//	LineCheck_r
//===========================================================================
static UBOOL LineCheck_r(FPlane *Planes, INT PlaneIndex, INT NumPlanes, FVector Start, FVector End, FVector &Extent)
{
	if (PlaneIndex == -1)
		return false;

	if (PlaneIndex >= NumPlanes)
		return true;

	FLOAT PushOut = FBoxPushOut(Planes[PlaneIndex], Extent*1.1f);

	FLOAT Dist1 = Planes[PlaneIndex].PlaneDot(Start) - PushOut;
	FLOAT Dist2 = Planes[PlaneIndex].PlaneDot(End) - PushOut;

	if (Dist1 >= 0.0f && Dist2 >= 0.0f)
		return false;			// both front, this part of the line segment did not collide
	
	if (Dist1 <= 0.0f && Dist2 <= 0.0f)	
		return LineCheck_r(Planes, PlaneIndex+1, NumPlanes, Start, End, Extent);	// both back, recurse to back

	// Split by plane
	FVector		Split;
	
	FLOAT Time = Clamp(-Dist1 / (Dist2-Dist1), 0.0f, 1.0f);

	Split = Start + (End-Start)*Time;

	INT Side = (Dist1 < 0) ? 1 : 0;

	if (Side && LineCheck_r(Planes, PlaneIndex+1,NumPlanes, Start, Split, Extent))
	{
		return (HitPlaneIndex != -1);
	}
	else if (!Side && LineCheck_r(Planes, PlaneIndex+1, NumPlanes, Split, End, Extent))
	{
		if (HitPlaneIndex == -1)
		{
			HitPlaneIndex = PlaneIndex;
			HitTime = Time;
		}

		return true;
	}

	return (HitPlaneIndex != -1);
}

//===========================================================================
//	PointInParticleCheck
//	Loc is expected to be in local glass space
//===========================================================================
static UBOOL PointInParticleCheck(GlassParticle *Particle, FVector &Loc)
{
	FVector	Normal(-1,0,0);
	FVector *PrevVert = &Particle->Verts[Particle->NumVerts-1];

	for (INT i=0; i< Particle->NumVerts; i++)
	{
		FVector *Vert = &Particle->Verts[i];

		FVector EdgeVect(*PrevVert - *Vert);
		EdgeVect.Normalize();
		FVector EdgeNormal = EdgeVect^Normal;
		FPlane	EdgePlane(*Vert, EdgeNormal);

		if (EdgePlane.PlaneDot(Loc) > 0.0f)
			return false;	// Outside

		PrevVert = Vert;
	}

	return true;			// Inside
}

//===========================================================================
//	JGlassPrimitive::LineCheck
//===========================================================================
UBOOL JGlassPrimitive::LineCheck
(
	FCheckResult	&Result,
	AActor			*Owner,
	FVector			End,
	FVector			Start,
	FVector			Extent,
	DWORD			ExtraNodeFlags,
	UBOOL			bMeshAccurate
)
{
    ABreakableGlass		*Glass = this->GlassInstance;

	if (!Glass)
		return true;

	if (!Glass->bBlockPlayers)
		return true;

	if (!GlassIsValid(Glass))
		return true;

	if (GlassIsDone(Glass))
		return true;

	FCoords ModelToWorld = GMath.UnitCoords * Glass->Location * Glass->Rotation;
	FCoords WorldToModel = ModelToWorld.Transpose();

	FLOAT		HalfX = Glass->GlassSizeX*0.5f;
	FLOAT		HalfY = Glass->GlassSizeY*0.5f;

	if (Extent == FVector(0,0,0) )
	{
		// Faster trace special cases no extent box
		FVector		Normal(-1,0,0);
		FVector		LStart =	Start.TransformPointBy(WorldToModel);
		FVector		LEnd =		End.TransformPointBy(WorldToModel);

		FLOAT		Dist1 = LStart|Normal;
		FLOAT		Dist2 = LEnd|Normal;

		if (Dist1 >= 0.0f && Dist2 >= 0.0f)
			return true;
		if (Dist1 < 0.0f && Dist2 < 0.0f)
			return true;

		FLOAT Time = -Dist1 / (Dist2-Dist1);
	
		Result.Time      = Clamp(Time-0.001,0.0,1.0);
		Result.Location  = Start + ((End-Start) * Result.Time);

		FVector	ModelLocation = Result.Location.TransformPointBy(WorldToModel);
	
		if (ModelLocation.Y > HalfX+1.0f)
			return true;
		if (ModelLocation.Y < -HalfX-1.0f)
			return true;
		if (ModelLocation.Z > HalfY+1.0f)
			return true;
		if (ModelLocation.Z < -HalfY-1.0f)
			return true;

		// Go in and do a polygon accurate check (so you can't shoot the glass when you hit a hole already made)
		if (Glass->GlassBreakCount)
		{
			//return true;		// test
			for (INT i=0; i< Glass->NumGlassParticles; i++)
			{
				if (!GLASS_PARTICLES(Glass)[i])
					continue;
				if (GLASS_PARTICLES(Glass)[i]->DoPhysics)
					continue;

				if (PointInParticleCheck(GLASS_PARTICLES(Glass)[i], ModelLocation))
					break;
			}

			if (i == Glass->NumGlassParticles)
				return true;
		}
	}
	else
	{
		if (GLASS_USERDATA(Glass)->Shattered)
			return true;

		// Slower box check
		FPlane		Planes[6];
		FVector		Normal(1,0,0);

		Planes[0] = FPlane(Normal, 0.0f);
		Planes[1] = FPlane(-Normal, 0.0f);

		Normal = FVector(0,1,0);

		Planes[2] = FPlane(Normal, HalfX);
		Planes[3] = FPlane(-Normal, HalfX);

		Normal = FVector(0,0,1);

		Planes[4] = FPlane(Normal, HalfY);
		Planes[5] = FPlane(-Normal, HalfY);

		// Put planes into worldspace
		for (INT i=0; i< 6; i++)
			Planes[i] = Planes[i].TransformPlaneByOrtho(ModelToWorld);

		HitPlaneIndex = -1;
		if (!LineCheck_r(Planes, 0, 6, Start, End, Extent))
			return true;
		
		if (HitPlaneIndex == -1)
			return true;

		Result.Time      = Clamp(HitTime-0.001,0.0,1.0);
		Result.Location  = Start + ((End-Start) * Result.Time);

		Result.Normal = ((FVector&)Planes[HitPlaneIndex]);
	}

	Result.Actor     = Owner;
	Result.Primitive = NULL;
	Result.MeshBoneName = NAME_None;
	Result.MeshTri = -1;
	Result.MeshBarys = FVector(0.33,0.33,0.34);
	Result.MeshTexture = NULL;		

	return false;

	//return UPrimitive::LineCheck(Result, Owner, End, Start, Extent, ExtraNodeFlags, bMeshAccurate);
}

//===========================================================================
//	JGlassPrimitive::GetRenderBoundingBox
//===========================================================================
FBox JGlassPrimitive::GetRenderBoundingBox
(
	const AActor	*Owner,
	UBOOL			Exact
)
{	
    ABreakableGlass		*Glass = this->GlassInstance;

	if (!Glass)
		return UPrimitive::GetRenderBoundingBox( Owner, Exact );

	if (GIsEditor)
		CalcGenericRenderBox(Glass);		// Sort of a hack since the editor doesn't call script tick (which in turn calls InternalTick)

	return GLASS_USERDATA(Glass)->RenderBox;
}

//===========================================================================
//	JGlassPrimitive::GetCollisionBoundingBox
//===========================================================================
FBox JGlassPrimitive::GetCollisionBoundingBox(const AActor *Owner ) const
{	
    //ABreakableGlass		*Glass = this->GlassInstance;

	//if (!Glass)
		return UPrimitive::GetCollisionBoundingBox( Owner );
	
	//return GLASS_USERDATA(Glass)->RenderBox;
}

//===========================================================================
//	AllocGlassParticlePointers
//===========================================================================
static void AllocGlassParticlePointers(ABreakableGlass *Glass, INT AmountToExtent)
{
	check(Glass->UserData);

	if (!AmountToExtent)
		return;

	INT NewAmount = GLASS_USERDATA(Glass)->NumAllocatedParticles+AmountToExtent;

	// Allocate the particles
	Glass->GlassParticles = (INT)appRealloc((void*)Glass->GlassParticles, sizeof(GlassParticle*)*NewAmount, TEXT("GlassParticles"));

	if (!Glass->GlassParticles)
		return;

	for (INT i=GLASS_USERDATA(Glass)->NumAllocatedParticles; i< NewAmount; i++)
		GLASS_PARTICLES(Glass)[i] = NULL;

	GLASS_USERDATA(Glass)->NumAllocatedParticles = NewAmount;
}

//===========================================================================
// ABreakableGlass::ABreakableGlass
//===========================================================================
ABreakableGlass::ABreakableGlass() 
{
	NumGlassParticles = 0;
	CurGlassParticle = 0;
	GlassBreakCount = 0;
	GlassTime = 0.0f;

	GlassPrimitive = NULL;
	
	// Allocate user data
	UserData = (INT)appMalloc(sizeof(GlassUserData), TEXT("GlassUserData"));
	appMemzero(GLASS_USERDATA(this), sizeof(GlassUserData));

	GLASS_USERDATA(this)->Shattered = false;
	GLASS_USERDATA(this)->RespawnTime = this->GlassRespawnTime;

	AllocGlassParticlePointers(this, INITIAL_GLASS_PARTICLE_SIZE);

	// Add this actor to the global list
	GGlassActors.AddItem(this);
}

//===========================================================================
// ABreakableGlass::Destroy
//===========================================================================
void ABreakableGlass::Destroy() 
{
	// Make sure we remove all the particle allocations this Glass actor made so others have a chance to use them
	ResetGlass(this);

	// Clean stuff up
	if (GlassParticles)
	{
		appFree(GLASS_PARTICLES(this));
		GlassParticles = NULL;
	}

	if (UserData)
	{
		appFree(GLASS_USERDATA(this));
		UserData = NULL;
	}
		
	if (GlassPrimitive)
	{
		GLASS_PRIMITIVE(this)->RemoveFromRoot();
		GLASS_PRIMITIVE(this)->ConditionalDestroy();
		delete GLASS_PRIMITIVE(this);
		GlassPrimitive = NULL;
	}

	GGlassActors.RemoveItem(this);

	Super::Destroy();
}

//===========================================================================
//	AllocGlassParticle	Keith was here looking at your code. Find my secret changes!!!!
//===========================================================================
static GlassParticle *AllocGlassParticle(void)
{
	INT				Index;

	// If there are no free particles, go find the oldest ABreakableGlass actor,
	//	and free all that actors glassparticles 
	if (!GNumFreedGlassParticles && GNumGlassParticles >= MAX_TOTAL_GLASS_PARTICLES)
	{
		FLOAT	BestTime = -1.0f;
		INT		BestActor = -1;

		for (INT i=0; i< GGlassActors.Num(); i++)
		{
			if (!GGlassActors(i)->GlassBreakCount)
				continue;

			if (!GGlassActors(i)->NumGlassParticles)
				continue;

			if (GGlassActors(i)->GlassTime > BestTime)
			{
				BestTime = GGlassActors(i)->GlassTime;
				BestActor = i;
			}
		}

		if (BestActor != -1)
			FreeGlassParticles(GGlassActors(BestActor));
	}
																					
	if (GNumFreedGlassParticles > 0)				// First, look in the freed list
	{
		Index = GFreedGlassParticles[--GNumFreedGlassParticles];
	}
	else
	{
		if (GNumGlassParticles >= MAX_TOTAL_GLASS_PARTICLES)
			return NULL;		// Too many glass particles floating around

		Index = GNumGlassParticles++;
	}

	return &GGlassParticles[Index];
}

//===========================================================================
//	AllocGlassParticleFromPolygon
//===========================================================================
static GlassParticle *AllocGlassParticleFromPolygon(const FVector *pVerts, INT NumVerts)
{
	GlassParticle	*Particle = AllocGlassParticle();

	if (!Particle)
		return NULL;

	if (NumVerts > MAX_PARTICLE_VERTS)
		NumVerts = MAX_PARTICLE_VERTS;

	for (INT i=0; i< NumVerts; i++)
		Particle->Verts[i] = pVerts[i];

	Particle->NumVerts = NumVerts;

	return Particle;
}

//===========================================================================
//	FreeGlassParticle
//===========================================================================
static void FreeGlassParticle(GlassParticle **ppParticle)
{
	check(ppParticle);
	check(*ppParticle);
	check(GNumFreedGlassParticles < MAX_TOTAL_GLASS_PARTICLES);		// Because we don't allow them to allocate more than this, this should be true

	INT Index = (*ppParticle) - &GGlassParticles[0];

	if (Index < 0 || Index > GNumGlassParticles)
		appErrorf(TEXT("FreeGlassParticle: Invalid Index: %i"), Index);

	GFreedGlassParticles[GNumFreedGlassParticles++] = Index;

	*ppParticle = NULL;
}

//#define GLASS_PARANOID

//===========================================================================
//	CutPolygon
//===========================================================================
static UBOOL CutPolygon(FVector		*pVerts, 
						INT			NumVerts, 
						INT			Edge1, 
						FLOAT		Edge1Dist, 
						INT			Edge2, 
						FLOAT		Edge2Dist, 
						FVector		*pFront,
						INT			*pFrontNumVerts,
						FVector		*pBack,
						INT			*pBackNumVerts,
						INT			MaxWorkVerts)
{
	INT		i;
	UBOOL	Front = true;

#ifdef GLASS_PARANOID
	check(Edge1 != Edge2);
	check(Edge1 >= 0 && Edge1 < NumVerts);
	check(Edge2 >= 0 && Edge2 < NumVerts);
#endif

	// Set the number of verts to 0
	*pFrontNumVerts = 0;
	*pBackNumVerts = 0;

	for (i=0; i< NumVerts; i++)
	{
	#ifdef GLASS_PARANOID
		check((*pFrontNumVerts) < MaxWorkVerts);
		check((*pBackNumVerts) < MaxWorkVerts);
	#endif

		if (Front)		// Add to front
			pFront[(*pFrontNumVerts)++] = pVerts[i];
		else			// Add to back
			pBack[(*pBackNumVerts)++] = pVerts[i];
		
		if (i == Edge1 || i == Edge2)
		{
		#ifdef GLASS_PARANOID
			check((*pFrontNumVerts) < MaxWorkVerts);
			check((*pBackNumVerts) < MaxWorkVerts);
		#endif

			FVector		&Vert1 = pVerts[i];
			FVector		&Vert2 = pVerts[(i+1)%NumVerts];

			FLOAT Dist = (i == Edge1) ? Edge1Dist : Edge2Dist;

			FVector	Split = Vert1 + ((Vert2 - Vert1)*Dist);
			
			// Add split point to both sides
			pFront[(*pFrontNumVerts)++] = Split;
			pBack[(*pBackNumVerts)++] = Split;

			Front ^= 1;
		}
	}

	return true;
}

//===========================================================================
//	PolygonPerimeterFastSquared
//	This is not the true area, but rather the perimeter
//	The true area would be the half the sum of the cross-products of all the tris first 2 edges
//===========================================================================
static FLOAT PolygonPerimeterFastSquared(FVector *pVerts, INT NumVerts, INT *LongestEdge)
{
	FLOAT	Area = 0.0f;
	FLOAT	LongestVal = -1.0f;

	*LongestEdge = 0;

	for (INT i = 0; i < NumVerts; i++)
	{
		FVector		&V1 = pVerts[i];
		FVector		&V2 = pVerts[(i+1)%NumVerts];

		FLOAT Val = (V1-V2).SizeSquared();

		if (Val > LongestVal)
		{
			LongestVal = Val;
			*LongestEdge = i;
		}

		Area += Val;
	}

	return Area;
}

//===========================================================================
//	CutPolygonIntoPieces_r
//===========================================================================
static void CutPolygonIntoPieces_r(ABreakableGlass *Glass, FVector *pVerts, INT NumVerts, INT Recursion)
{
	INT				Edge1, Edge2, FrontNumVerts, BackNumVerts, LongestEdge;
	FVector			*Front, *Back;
	FLOAT			Edge1Dist, Edge2Dist, Area;

	if (NumVerts < 2)
		return;			// Bad polygon, shouldn't happen, but just in case

	if (Glass->NumGlassParticles >= GLASS_USERDATA(Glass)->NumAllocatedParticles)
	{
		AllocGlassParticlePointers(Glass, PARTICLE_EXTEND_AMOUNT);

		if (!Glass->GlassParticles)
			return;
	}

	Area = PolygonPerimeterFastSquared(pVerts, NumVerts, &LongestEdge);

	if (Recursion > 6 || Area < Glass->ParticleSize*Glass->ParticleSize)
	{
		GlassParticle *Particle = AllocGlassParticleFromPolygon(pVerts, NumVerts);

		if (Particle)
			InitializeNewParticle(Glass, Particle);

		return;
	}

	if (NumVerts >= MAX_WORK_VERTS)
		return;

	FMemMark Mark(GMem);

	Front = New<FVector>(GMem, NumVerts+1);

	if (!Front)
		goto Done;

	Back = New<FVector>(GMem, NumVerts+1);

	if (!Back)
		goto Done;

#if 1
	Edge1 = LongestEdge;
	Edge2 = (((appRand()&255) < 20) ? Edge1 + 1 : Edge1 + 2) % NumVerts;
#else
	Edge1 = 0;
	Edge2 = NumVerts-2;
#endif

#if 1
	Edge1Dist = (FLOAT)(appRand() & 255) * (1.0f/512.0f) + 0.25f;
	Edge2Dist = (FLOAT)(appRand() & 255) * (1.0f/512.0f) + 0.25f;

	Edge1Dist = Clamp(Edge1Dist, 0.35f, 0.65f);
	Edge2Dist = Clamp(Edge2Dist, 0.35f, 0.65f);
#else
	Edge1Dist = 0.5f;
	Edge2Dist = 0.5f;
#endif

	if (!CutPolygon(pVerts, NumVerts, Edge1, Edge1Dist, Edge2, Edge2Dist, Front, &FrontNumVerts, Back, &BackNumVerts, NumVerts+1))
		goto Done;

	if (FrontNumVerts >= 3)
		CutPolygonIntoPieces_r(Glass, Front, FrontNumVerts, Recursion+1);
	if (BackNumVerts >= 3)
		CutPolygonIntoPieces_r(Glass, Back, BackNumVerts, Recursion+1);

	Done:;

	Mark.Pop();
}

//=========================================================================================
//	CompareParticles
//=========================================================================================
static QSORT_RETURN CDECL CompareParticles(const GlassParticle **A, const GlassParticle **B)
{
	if ((*A)->DoPhysics && !(*B)->DoPhysics)
		return -1;
	else if (!(*A)->DoPhysics && (*B)->DoPhysics)
		return 1;

	if ((*A)->Dist > (*B)->Dist)
		return 1;
	else if ((*A)->Dist < (*B)->Dist)
		return -1;

	return 0;
}

//===========================================================================
//	FindParticleOrigins
//===========================================================================
static void FindParticleOrigins(ABreakableGlass *Glass)
{
	for (INT i = 0; i< Glass->NumGlassParticles; i++)
	{
		if (!GLASS_PARTICLES(Glass)[i])
			continue;

		// Find particle center
		GLASS_PARTICLES(Glass)[i]->Origin = FVector(0.0f, 0.0f, 0.0f);

		for (INT v=0; v< GLASS_PARTICLES(Glass)[i]->NumVerts; v++)
			GLASS_PARTICLES(Glass)[i]->Origin += GLASS_PARTICLES(Glass)[i]->Verts[v];
		
		GLASS_PARTICLES(Glass)[i]->Origin /= GLASS_PARTICLES(Glass)[i]->NumVerts;
	}
}

//===========================================================================
//	PackParticlePointers
//===========================================================================
static void PackParticlePointers(ABreakableGlass *Glass)
{
	INT		NumNewParticles = 0;

	Glass->CurGlassParticle = 0;

	// Prune NULL particle pointers
	for (INT i = 0; i< Glass->NumGlassParticles; i++)
	{
		if (!GLASS_PARTICLES(Glass)[i])
			continue;

		if (GLASS_PARTICLES(Glass)[i]->DoPhysics)
			Glass->CurGlassParticle++;

		GLASS_PARTICLES(Glass)[NumNewParticles++] = GLASS_PARTICLES(Glass)[i];
	}

	Glass->NumGlassParticles = NumNewParticles;
}

//===========================================================================
//	SortTestParticles
//===========================================================================
static void SortTestParticles(ABreakableGlass *Glass, FVector &BreakLocation)
{
	PackParticlePointers(Glass);

	for (INT i = 0; i< Glass->NumGlassParticles; i++)
	{
		// Dist is the distance of the particles center from the BreakPoint
		GLASS_PARTICLES(Glass)[i]->Dist = (BreakLocation - GLASS_PARTICLES(Glass)[i]->Origin).SizeSquared();
	}

	// Sort them
	appQsort(&GLASS_PARTICLES(Glass)[0], Glass->NumGlassParticles, sizeof(GLASS_PARTICLES(Glass)[0]), (QSORT_COMPARE)CompareParticles);

	// Find the first particle with no physics, and set our CurGlassParticle to that one
	Glass->CurGlassParticle = 0;
	
	for (i = 0; i< Glass->NumGlassParticles; i++)
	{
		if (!GLASS_PARTICLES(Glass)[i]->DoPhysics)
			break;

		Glass->CurGlassParticle++;
	}
}

//===========================================================================
//	BreakGlassFinal
//===========================================================================
static void BreakGlassFinal(ABreakableGlass *Glass, FVector *pVerts, INT NumVerts, FVector &BreakLocation)
{
	if (!Glass->GlassBreakCount)
	{
		// First time break (need to tesselate)
		// Fan out from the cut point, and make 4 new tris
	#if 1
		for (INT i=0; i< NumVerts; i++)
		{
			FVector		Tri[3];
		
			Tri[0] = BreakLocation;
			Tri[1] = pVerts[i];
			Tri[2] = pVerts[(i+1)%NumVerts];
		
			CutPolygonIntoPieces_r(Glass, Tri, 3, 0);
		}
	#else
		CutPolygonIntoPieces_r(Glass, pVerts, NumVerts, 0);
	#endif
		
		FindParticleOrigins(Glass);

		Glass->GlassTime = 0.0f;

		GLASS_USERDATA(Glass)->NumOriginalParticles = Glass->NumGlassParticles;

		if (Glass->bRandomTextureRotation)
			GLASS_USERDATA(Glass)->RandomRotateDir = appRand()%4;
		else
			GLASS_USERDATA(Glass)->RandomRotateDir = 0;
	}
	
	Glass->GlassBreakCount++;

	// Sort polygons around this break location (so they will fall from this location)
	SortTestParticles(Glass, BreakLocation);
	
	if (!GLASS_USERDATA(Glass)->Shattered)
		GlassPlaySound(Glass, Glass->GlassSound1, true, 0.5f, 1.5f);
}

//===========================================================================
//	BreakGlassXY
//===========================================================================
static void BreakGlassXY(ABreakableGlass *Glass, FVector *pVerts, INT NumVerts, FLOAT X, FLOAT Y, FVector &BreakLocation)
{
	FVector Temp1 = pVerts[0] + (pVerts[1] - pVerts[0])*X;
	FVector Temp2 = pVerts[3] + (pVerts[2] - pVerts[3])*X;

	BreakLocation = Temp1 + (Temp2 - Temp1)*Y;

	BreakGlassFinal(Glass, pVerts, NumVerts, BreakLocation);
}

//===========================================================================
//	ProjectWorldToGlass
//===========================================================================
static void ProjectWorldToGlass(ABreakableGlass *Glass, FVector *pVerts, INT NumVerts, FVector &Location, FLOAT &BreakX, FLOAT &BreakY)
{
	check(NumVerts == 4);		// We only know how to deal with a sheet of glass with 4 verts right now

	FCoords ModelToWorld = Glass->ToWorld();
	FCoords WorldToModel = ModelToWorld.Transpose();

	Location = Location.TransformPointBy(WorldToModel);

	// Project the breakpoint onto the glass
	FVector VecX = (pVerts[1] - pVerts[0]);
	FVector VecY = (pVerts[3] - pVerts[0]);
	
	VecX.Normalize();
	VecY.Normalize();
	
	Location -= pVerts[0];

	BreakX = Clamp((Location|VecX)/Glass->GlassSizeX, 0.1f, 0.9f);
	BreakY = Clamp((Location|VecY)/Glass->GlassSizeY, 0.1f, 0.9f);
	
	FVector Temp1 = pVerts[0] + (pVerts[1] - pVerts[0])*BreakX;
	FVector Temp2 = pVerts[3] + (pVerts[2] - pVerts[3])*BreakX;

	Location = Temp1 + (Temp2 - Temp1)*BreakY;
}

#ifdef RANDOM_BREAKS
//===========================================================================
//	BreakGlassRandom
//===========================================================================
static void BreakGlassRandom(ABreakableGlass *Glass, FVector *pVerts, INT NumVerts)
{
	check(NumVerts == 4);		// We only know how to deal with a sheet of glass with 4 verts right now

	// Find a random break point
	FLOAT BreakX = Clamp((FLOAT)(appRand() & 255) * (1.0f/255.0f), 0.1f, 0.9f);
	FLOAT BreakY = Clamp((FLOAT)(appRand() & 255) * (1.0f/255.0f), 0.1f, 0.9f);

	FVector BreakLocation;

	BreakGlassXY(Glass, pVerts, NumVerts, BreakX, BreakY, BreakLocation);
}
#endif

//===========================================================================
//	DrawTri
//===========================================================================
static void DrawTri(FSceneNode *Frame, FTransTexture **TriPts, FTextureInfo *TexInfo, DWORD PolyFlags)
{
	if (TexInfo)
		Frame->Viewport->RenDev->QueuePolygon(TexInfo, TriPts, 3, PolyFlags, 0, NULL);
	else
	{
		// Draw it twice (HACK) since this function does not allow polyflags (we can't tell the driver to make it double sided)
		Frame->Viewport->RenDev->QueuePolygonFast(TriPts, 3);
		Exchange(TriPts[2], TriPts[0]);
		Frame->Viewport->RenDev->QueuePolygonFast(TriPts, 3);
	}
}

static FLOAT g_UScale = 1.0f, g_VScale = 1.0f;

static __forceinline void EnviroMap( FSceneNode* Frame, FTransTexture& P )
{
	//FVector T = P.Point.SafeNormal().MirrorByVector( P.Normal ).TransformVectorBy( Frame->Uncoords );
	FVector T = P.Point.SafeNormal().MirrorByVector( P.Normal );
	//FLOAT	Dot = 2.0f*(P.Point|P.Normal);
	//FVector	T = (Dot * P.Normal - P.Point).SafeNormal();

	P.U = (T.X+1.f) * 0.5f * g_UScale;
	P.V = (T.Y+1.f) * 0.5f * g_VScale;
}

//===========================================================================
//	DrawPolygon
//===========================================================================
static void DrawPolygon(ABreakableGlass *Glass, FSceneNode *Frame, FVector *pVerts, INT NumVerts, FVector &Color, FCoords &ModelToCamera, FTextureInfo *TexInfo, FLOAT ShiftU, FLOAT ShiftV, FLOAT ScaleU, FLOAT ScaleV)
{
	if (NumVerts >= MAX_WORK_VERTS)
		return;		// Oh well...

	FLOAT	HalfX = 0.0f, HalfY = 0.0f, ScaleX = 0.0f, ScaleY = 0.0f;

	DWORD PolyFlags = 0;
		
	if (TexInfo)
	{
		ScaleU *= TexInfo->USize;
		ScaleV *= TexInfo->VSize;
		
		if (TexInfo->Texture)
			PolyFlags |= TexInfo->Texture->PolyFlags;
	}

	if (Glass->bGlassTranslucent)
		PolyFlags |= PF_Translucent;
	if (Glass->bGlassModulated)
		PolyFlags |= PF_Modulated;
	if (Glass->bGlassMasked)
		PolyFlags |= PF_Masked;
	if (Glass->bTwoSided)
		PolyFlags |= PF_TwoSided;

	if ((PolyFlags & (PF_Translucent|PF_Modulated)) == (PF_Translucent|PF_Modulated))
		PolyFlags &= ~PF_Modulated;

	FVector Normal = FVector(-1,0,0).TransformVectorBy(ModelToCamera);

	// Transform the verts into camera space, and project them
	for (INT i=0; i<NumVerts; i++)
	{
		WorkPolyVerts[i].Light = Color;

		WorkPolyVerts[i].Point = pVerts[i].TransformPointBy(ModelToCamera);
		WorkPolyVerts[i].Project(Frame);			// Project into screen space
		
		if (!TexInfo)
			continue;		// No need to generate tex coords

		WorkPolyVerts[i].Normal = Normal;

		// Generate texture coords
		if (g_GlassEnviroMap)
		{
			g_UScale = TexInfo->UScale * TexInfo->USize;
			g_VScale = TexInfo->VScale * TexInfo->VSize;
			
			EnviroMap(Frame, WorkPolyVerts[i]);
		}
		else
		{		
			switch (GLASS_USERDATA(Glass)->RandomRotateDir)
			{
				case 0:
					WorkPolyVerts[i].U = (pVerts[i].Y + ShiftU)*ScaleU;
					WorkPolyVerts[i].V =-(pVerts[i].Z + ShiftV)*ScaleV;		// Invert Z because +Z is up in world space, but down in texture space
					break;
				case 1:
					WorkPolyVerts[i].U = (pVerts[i].Z + ShiftU)*ScaleU;
					WorkPolyVerts[i].V = (pVerts[i].Y + ShiftV)*ScaleV;
					break;
				case 2:
					WorkPolyVerts[i].U =-(pVerts[i].Y + ShiftU)*ScaleU;
					WorkPolyVerts[i].V = (pVerts[i].Z + ShiftV)*ScaleV;
					break;
				case 3:
					WorkPolyVerts[i].U =-(pVerts[i].Z + ShiftU)*ScaleU;
					WorkPolyVerts[i].V =-(pVerts[i].Y + ShiftV)*ScaleV;
					break;
			}
		}
	}

	// Render the polygon as tris
	for (i=0; i<NumVerts-2; i++)
	{
		FTransTexture		*TriPts[3];

		TriPts[0] = &WorkPolyVerts[0];
		TriPts[1] = &WorkPolyVerts[i+1];
		TriPts[2] = &WorkPolyVerts[i+2];
		
		DrawTri(Frame, TriPts, TexInfo, PolyFlags);
	}
}

//===========================================================================
//	DrawPolygonWire
//===========================================================================
static void DrawPolygonWire(ABreakableGlass *Glass, FSceneNode *Frame, FVector *pVerts, INT NumVerts, FVector &Color, FCoords &ModelToWorld)
{
	if (NumVerts >= MAX_WORK_VERTS)
		return;		// Oh well...

	FVector		WorkVerts[MAX_WORK_VERTS];

	// Transform the verts into camera space, and project them
	for (INT i=0; i<NumVerts; i++)
		WorkVerts[i] = pVerts[i].TransformPointBy(ModelToWorld);

	// Render the polygon as lines
	for (i=0; i<NumVerts; i++)
	{
		FVector		*P1 = &WorkVerts[i];
		FVector		*P2 = &WorkVerts[(i+1)%NumVerts];

		Frame->Viewport->RenDev->Queue3DLine(Frame, Color, LINE_DepthCued, *P1, *P2);
	}
}

//===========================================================================
//	ParticleToWorld
//	Brings the particle into world space (ignores the particles relative location and rotation)
//===========================================================================
static __forceinline FCoords ParticleToWorld(ABreakableGlass *Glass, GlassParticle *Particle)
{
	if (Particle->DoPhysics)
		return Particle->FrozenToWorld;

	return GLASS_USERDATA(Glass)->LocalToWorld;
}

//===========================================================================
//	ParticleToLocal
//===========================================================================
static __forceinline FCoords ParticleToLocal(ABreakableGlass *Glass, GlassParticle *Particle)
{
	if (Particle->DoPhysics)
		return Particle->FrozenToWorld.Transpose();

	return GLASS_USERDATA(Glass)->WorldToLocal;
}

#define PARTICLE_TO_LOCAL_FOR_RENDER(p) (p->Origin+p->Location) * p->Rotation * (-p->Origin)

//===========================================================================
//	ParticleToCameraForRender
//===========================================================================
static __forceinline FCoords ParticleToCameraForRender(FSceneNode *Frame, ABreakableGlass *Glass, GlassParticle *Particle)
{
	if (Particle->DoPhysics)
	{
		FCoords LocalToCamera = Frame->Coords << ParticleToWorld(Glass, Particle);

		return LocalToCamera*PARTICLE_TO_LOCAL_FOR_RENDER(Particle);
	}

	return GLASS_USERDATA(Glass)->LocalToCamera*PARTICLE_TO_LOCAL_FOR_RENDER(Particle);
}

//===========================================================================
//	ParticleToWorldForRender
//===========================================================================
static __forceinline FCoords ParticleToWorldForRender(FSceneNode *Frame, ABreakableGlass *Glass, GlassParticle *Particle)
{
	if (Particle->DoPhysics)
		return ParticleToWorld(Glass, Particle)*PARTICLE_TO_LOCAL_FOR_RENDER(Particle);

	return GLASS_USERDATA(Glass)->LocalToWorld*PARTICLE_TO_LOCAL_FOR_RENDER(Particle);
}

//===========================================================================
//	DrawGlassParticle
//===========================================================================
static void DrawGlassParticle(ABreakableGlass *Glass, FSceneNode *Frame, GlassParticle *Particle, FVector &Color, FTextureInfo *TexInfo, FLOAT ShiftU, FLOAT ShiftV, FLOAT ScaleU, FLOAT ScaleV)
{
	FCoords Coords = ParticleToCameraForRender(Frame, Glass, Particle);
	
	if (Particle->CountDown < PARTICLE_LIFE_FADE && Glass->bGlassTranslucent)
	{
		FVector Color2 = Color*Clamp(Particle->CountDown/PARTICLE_LIFE_FADE, 0.0f, 1.0f);
		DrawPolygon(Glass, Frame, Particle->Verts, Particle->NumVerts, Color2, Coords, TexInfo, ShiftU, ShiftV, ScaleU, ScaleV);
	}
	else
		DrawPolygon(Glass, Frame, Particle->Verts, Particle->NumVerts, Color, Coords, TexInfo, ShiftU, ShiftV, ScaleU, ScaleV);
}

//===========================================================================
//	DrawGlassParticleWire
//===========================================================================
static void DrawGlassParticleWire(ABreakableGlass *Glass, FSceneNode *Frame, GlassParticle *Particle, FVector &Color)
{
	FCoords Coords = ParticleToWorldForRender(Frame, Glass, Particle);

	DrawPolygonWire(Glass, Frame, Particle->Verts, Particle->NumVerts, Color, Coords);
}

//===========================================================================
//	NormRot1
//===========================================================================
static __forceinline INT NormRot1(INT Rot)
{
	Rot = Rot & 0xFFFF; if( Rot > 32767 ) Rot -= 0x10000;

	return Rot;
}

//===========================================================================
//	RandRot
//===========================================================================
static __forceinline void RandRot(FRotator &Rot, INT Range)
{
#if 1
	INT Rot1 = ((appRand() & 255) < 128) ? Range : -Range;
	INT Rot2 = ((appRand() & 255) < 128) ? Range : -Range;
	INT Rot3 = ((appRand() & 255) < 128) ? Range : -Range;
#else
	INT Rot1 = (appRand() % (Range<<1)) - Range;
	INT Rot2 = (appRand() % (Range<<1)) - Range;
	INT Rot3 = (appRand() % (Range<<1)) - Range;
#endif

	Rot = FRotator(Rot1, Rot2, Rot3);
}

//===========================================================================
//	NormRot2
//===========================================================================
static __forceinline FRotator &NormRot2(FRotator &Rot)
{
	Rot.Pitch = NormRot1(Rot.Pitch);
	Rot.Yaw = NormRot1(Rot.Yaw);
	Rot.Roll = NormRot1(Rot.Roll);

	return Rot;
}

void __forceinline SlerpRot(const FRotator &A, const FRotator &B, float Alpha, FRotator &C)
{
	FCoords CoordsA(GMath.UnitCoords / A);
	FCoords CoordsB(GMath.UnitCoords / B);
	FQuat QuatA(CoordsA);
	FQuat QuatB(CoordsB);

	FQuat QuatR; QuatR.Slerp(QuatA, QuatB, 1.f-Alpha, Alpha, false);
	FCoords CoordsR(QuatR);
	C = CoordsR.OrthoRotation();
}

/*
static void MyCheapBroadcastMessage(AActor* inActor, TCHAR* inFmt, ... )
{ 
	static TCHAR buf[256];
	GET_VARARGS( buf, ARRAY_COUNT(buf), inFmt );
	inActor->Level->eventBroadcastMessage(FString(buf),0,NAME_None);
}
*/

//===========================================================================
//	DoParticlePhysics
//===========================================================================
static void DoParticlePhysics(ABreakableGlass *Glass, GlassParticle *Particle, FLOAT DeltaTime)
{
	if (!Particle->DoPhysics)
		return;

	FLOAT TimeDeltaSeconds = DeltaTime;
	
	FCoords &LocalToWorld = ParticleToWorld(Glass, Particle);
	FCoords &WorldToLocal = ParticleToLocal(Glass, Particle);

	// Gravity
	Particle->Velocity.Z -= TimeDeltaSeconds*300.0f;

	FVector Start = Particle->Location;
	FVector	End = Start + Particle->Velocity.TransformVectorBy(WorldToLocal)*TimeDeltaSeconds;
	
	FVector	Bias(0.0f, 0.0f, -2.5f);

	Start += Particle->Origin;
	End += Particle->Origin;

	Start = Start.TransformPointBy(LocalToWorld)+Bias;
	End = End.TransformPointBy(LocalToWorld)+Bias;

	FCheckResult Hit;

	UBOOL		OnGround = false;

#if 1
	// If start point is in solid, don't even bother checking ray
	FPointRegion TestRegion = Glass->GetLevel()->Model->PointRegion(Glass->Level, Start);

	//if (TestRegion.Zone == Glass->Level)
	if (TestRegion.iLeaf == INDEX_NONE)
	{
		Particle->InWorld = true;
	}
	else
#endif
	{
		if (Glass->GetLevel()->Model->LineCheck(Hit, NULL, End, Start, FVector(0.0f, 0.0f, 0.0f), 0, false)==0)
		{
			End = Hit.Location;
				
			Particle->Velocity -= Hit.Normal*(Particle->Velocity|Hit.Normal)*Glass->BounceScale;

			OnGround = true;
		}
	}

	Particle->Location = (End-Bias).TransformPointBy(WorldToLocal) - Particle->Origin;

	// Handle rotation
	if (OnGround)
	{
		FVector UpVector = FVector(0,0,1).TransformVectorBy(WorldToLocal);
		FRotator UpRotation = UpVector.Rotation();

		NormRot2(UpRotation);
		NormRot2(Particle->Rotation);

		// Rotate so that we will eventually be level with the ground
		if (Particle->Rotation != UpRotation)
		{
			FLOAT		Alpha = Clamp(TimeDeltaSeconds*12.0f, 0.0f, 1.0f);

			// JEP: NOTEZ:
			//	Both of these versions are actually totally wrong.  We need to find the 2 axis
			//	angles needed to rotate on to align with the ground, and to roll on.
			//	These 2 angles can be computed for the entire glass.
			//	For now, this works.  Maybe I (or someone else) can fix later.
		#if 1
			FRotator	Rot = NormRot2(UpRotation-Particle->Rotation)*Alpha;
		#else
			FRotator	Rot;
			SlerpRot(Particle->Rotation, UpRotation, Alpha, Rot);
			Rot = NormRot2(Rot-Particle->Rotation);
		#endif

			Particle->Rotation += Rot;

			Particle->OverRot = Rot;
		}
	}
	else	// If not on ground, apply over rotation
	{
		if ((Particle->OverRot.Pitch+Particle->OverRot.Yaw+Particle->OverRot.Roll) < 100)
			RandRot(Particle->OverRot, 1000);

		Particle->Rotation += Particle->OverRot*11.0f*TimeDeltaSeconds*Glass->RotateScale;
	}

	NormRot2(Particle->Rotation);
}

//===========================================================================
//	StartParticlePhysics
//===========================================================================
static void StartParticlePhysics(ABreakableGlass *Glass, INT NumParticles, UBOOL DirForce, FVector *Dir, FVector *BreakLoc)
{
	while (NumParticles-- > 0 && Glass->CurGlassParticle < Glass->NumGlassParticles)
	{
		GlassParticle	*Particle = GLASS_PARTICLES(Glass)[Glass->CurGlassParticle++];

		if (!Particle)
			continue;

		// Before we turn physics on, remember what our ToWorld xform was (so we won't follow the glass actor when it moves)
		Particle->FrozenToWorld = Glass->ToWorld();

		Particle->DoPhysics = true;
		FLOAT JitterX = ((FLOAT)(appRand() & 255) * (1.0f/255.0f)-0.5f)*50.0f;
		FLOAT JitterY = ((FLOAT)(appRand() & 255) * (1.0f/255.0f)-0.5f)*50.0f;
		Particle->Velocity = FVector(JitterX,JitterY,10.0f);
		Particle->Location = FVector(0.0f,0.0f,0.0f);

		RandRot(Particle->OverRot, 1000);

		if (DirForce && Dir && BreakLoc)
		{
			FVector NewDir = *Dir;

			NewDir *= (1.2f-Clamp((Particle->Origin - *BreakLoc).Size()*(1.0f/90.0f), 0.0f, 1.0f))*2;

			Particle->Velocity += NewDir;
		}
	} 
}

//===========================================================================
//	FreeGlassParticles
//===========================================================================
static void FreeGlassParticles(ABreakableGlass *Glass)
{
	for (INT i=0; i<Glass->NumGlassParticles; i++)
	{
		if (!GLASS_PARTICLES(Glass)[i])
			continue;

		FreeGlassParticle(&GLASS_PARTICLES(Glass)[i]);
	}

	Glass->NumGlassParticles = 0;
	Glass->CurGlassParticle = 0;
}

//===========================================================================
//	SetGlassCollision
//===========================================================================
static void SetGlassCollision(ABreakableGlass *Glass, UBOOL On)
{
	if (On)
		Glass->SetCollision(true, true, true);
	else
		Glass->SetCollision(true, false, false);
}

//===========================================================================
//	ResetGlass
//===========================================================================
static void ResetGlass(ABreakableGlass *Glass)
{
	Glass->GlassTime = 0.0f;
	Glass->GlassBreakCount = 0;

	FreeGlassParticles(Glass);

	GLASS_USERDATA(Glass)->Shattered = false;
	GLASS_USERDATA(Glass)->RespawnTime = Glass->GlassRespawnTime;

	SetGlassCollision(Glass, true);
}

//===========================================================================
//	NotifyOtherActorsOfBreak
//===========================================================================
static void NotifyOtherActorsOfBreak(ABreakableGlass *Glass)
{
	FMemMark Mark(GMem);
	FCheckResult* Link=Glass->GetLevel()->Hash->ActorRadiusCheck( GMem, Glass->Location, Glass->CollisionRadius, 0 );

	for ( ; Link; Link = Link->GetNext())
	{
		if (!Link->Actor)
			continue;

		if (Link->Actor->bHidden)
			continue;

		if (Link->Actor->IsA(ABreakableGlass::StaticClass()))
			continue;

		if (Link->Actor->Physics == PHYS_None)
			Link->Actor->setPhysics(PHYS_Falling);		// If the actor was resting, wake it up
	}

	Mark.Pop();
}

//===========================================================================
//	ShatterGlass
//===========================================================================
static void ShatterGlass(ABreakableGlass *Glass)
{
	if (GLASS_USERDATA(Glass)->Shattered)
		return;			// Already shattered

	INT Val = appRand()%3;

	if (Val == 0)
		GlassPlaySound(Glass, Glass->GlassSound2);
	else if (Val == 2)
		GlassPlaySound(Glass, Glass->GlassSound3);
	else 
		GlassPlaySound(Glass, Glass->GlassSound4);

	GLASS_USERDATA(Glass)->Shattered = true;

	NotifyOtherActorsOfBreak(Glass);

	// Do the script event
	Glass->eventGlassShattered();
}

//===========================================================================
//	CalcGenericRenderBox
//===========================================================================
static void CalcGenericRenderBox(ABreakableGlass *Glass)
{
	// Assign renderbox
	FLOAT HalfX = Glass->GlassSizeX*0.5f;
	FLOAT HalfY = Glass->GlassSizeY*0.5f;

	FVector	Min(0,0,0), Max(0,0,0);

	Min.X = -1.0f;
	Min.Y = -HalfX-1.0f;
	Min.Z = -HalfY-1.0f;
	
	Max.X =  1.0f;
	Max.Y =  HalfX+1.0f;
	Max.Z =  HalfY+1.0f;

	//GLASS_USERDATA(Glass)->RenderBox = FBox(Min, Max).TransformBy(GLASS_USERDATA(Glass)->LocalToWorld);
	GLASS_USERDATA(Glass)->RenderBox = FBox(Min, Max).TransformBy(Glass->ToWorld());
}

//===========================================================================
//	GlassInternalTick
//===========================================================================
static void GlassInternalTick(ABreakableGlass *Glass, FLOAT DeltaTime)
{
	if (!GlassIsValid(Glass))
		return;

	if (Glass->bGlassRespawn && GLASS_USERDATA(Glass)->Shattered)
	{
		GLASS_USERDATA(Glass)->RespawnTime -= DeltaTime;

		if (GLASS_USERDATA(Glass)->RespawnTime <= 0.0f)
		{
			Glass->eventGlassRespawned();
			ResetGlass(Glass);
		}
	}

	if (GlassIsDone(Glass))
		return;

	PackParticlePointers(Glass);		// Remove NULL'd out pointers

	// Cache out our ToWorld fcoords (we do this once per frame)
	GLASS_USERDATA(Glass)->LocalToWorld = Glass->ToWorld();
	GLASS_USERDATA(Glass)->WorldToLocal = GLASS_USERDATA(Glass)->LocalToWorld.Transpose();

	if (!Glass->GlassBreakCount)
	{
		CalcGenericRenderBox(Glass);
		return;
	}

	// Increase glasstime (how long glass has been broken or partially broken)
	Glass->GlassTime += DeltaTime;

	FBox	RenderBox(0);

	INT NumParticlesToStay = GLASS_USERDATA(Glass)->NumOriginalParticles*Glass->ParticlesToStayPercent;

	// Do Physics on each particle
	for (INT i=0; i< Glass->NumGlassParticles; i++)
	{
		GlassParticle *Particle = GLASS_PARTICLES(Glass)[i];

		if (!Particle)
			continue;
			
		// Calc renderbox
		if (!Particle->InWorld)
			RenderBox += (Particle->Origin + Particle->Location).TransformPointBy(ParticleToWorld(Glass, Particle));

		if (!Particle->DoPhysics)
			continue;
		
		// Do physics
		DoParticlePhysics(Glass, Particle, DeltaTime);

		// Destroy the particle over time
		if (Glass->ParticleLife > 0.0f && Glass->NumGlassParticles > NumParticlesToStay)
		{
			Particle->CountDown -= DeltaTime;

			if (Particle->CountDown <= 0.0f)
			{
				FreeGlassParticle(&GLASS_PARTICLES(Glass)[i]);
				GLASS_PARTICLES(Glass)[i] = NULL;
			}
		}
	}

	// Assign renderbox
	GLASS_USERDATA(Glass)->RenderBox = RenderBox;

	// Turn particle physics on, one by one after certain percentage has been broken
	if (!GLASS_USERDATA(Glass)->Shattered)
	{
		//if (Glass->CurGlassParticle > Glass->NumGlassParticles*Glass->TotalBreakPercent1 && Glass->CurGlassParticle < Glass->NumGlassParticles && Glass->GlassTime > 0.5f)
		if (Glass->CurGlassParticle > Glass->NumGlassParticles*Glass->TotalBreakPercent1 && Glass->GlassTime > 0.5f)
			ShatterGlass(Glass);
	}

	if (GLASS_USERDATA(Glass)->Shattered)
	{
		FLOAT	ParticlesPS = (Glass->CurGlassParticle < Glass->NumGlassParticles*0.1f) ? Glass->FallPerSecond1 : Glass->FallPerSecond2;
		INT		NumParticlesToFall = max(1,DeltaTime*ParticlesPS);

		StartParticlePhysics(Glass, NumParticlesToFall);
	}

	// Turn collision off when enough particles have been destroyed
	if (Glass->CurGlassParticle > Glass->NumGlassParticles*Glass->TotalBreakPercent2)
		SetGlassCollision(Glass, false);
}

static FTextureInfo TextureInfo[3];

//===========================================================================
//	DrawGlass
//===========================================================================
void ABreakableGlass::DrawGlass(void *VoidFrame)
{
	if (!GlassIsValid(this))
		return;

	if (GlassIsDone(this))
		return;

	if (!GlassTexture1 || !GlassTexture2 || !GlassTexture3)
		return;

	FSceneNode *Frame = (FSceneNode*)VoidFrame;

	// Build a Quad centered around the origin that has the dimensions defined by GlassSizeX and GlassSizeY
#ifdef SPECIAL_SUBDIVIDE
	if (!GLASS_USERDATA(this)->UnBrokenVertsValid)
	{
		FLOAT HalfX = this->GlassSizeX*0.5f;
		FLOAT HalfY = this->GlassSizeY*0.5f;
		BuildGlassQuad2(this, &GLASS_USERDATA(this)->UnBrokenVerts[0][0], -HalfX, -HalfY, this->GlassSizeX, this->GlassSizeY);
		BuildGlassQuad2(this, &GLASS_USERDATA(this)->UnBrokenVerts[1][0], 0, -HalfY, HalfX, HalfY);
		BuildGlassQuad2(this, &GLASS_USERDATA(this)->UnBrokenVerts[2][0], -HalfX, 0, HalfX, HalfY);
		BuildGlassQuad2(this, &GLASS_USERDATA(this)->UnBrokenVerts[3][0], 0, 0, HalfX, HalfY);
		GLASS_USERDATA(this)->UnBrokenVertsValid = true;
	}
#else
	FVector	Quad[4];

	// Build our Quad
	BuildGlassQuad(this, Quad);
#endif

	// Build some FCoords we will need
	FCoords ModelToWorld = this->ToWorld();
	FCoords WorldToModel = ModelToWorld.Transpose();
	FCoords ModelToCamera = Frame->Coords << ModelToWorld;

	GLASS_USERDATA(this)->LocalToCamera = ModelToCamera;

	UBOOL		bWire = Frame->Viewport->IsOrtho() || Frame->Viewport->Actor->RendMap==REN_Wire;
	FVector		Color = (this->bSelected && GIsEditor) ? FVector(0.5f,1.0f,0.5f) : FVector(1.0f,1.0f,1.0f);

#if 0
	// Handle lighting
	FTransSample	Vert;
	GLightManager.SetupForActor( Frame, this, NULL, NULL);
	Vert.Point = this->Location;
	Vert.Normal = FVector(0,0,1);
	Vert.Normal = Vert.Normal.TransformPointBy(ModelToWorld);
	GLightManager.LightAndFog(Vert, 0);
	GLightManager.FinishActor();

	Color *= (FVector)Vert.Light;
#endif

	if (this->GlassBreakCount)
		g_GlassEnviroMap = false;
	else
		g_GlassEnviroMap = this->bGlassEnviroMap;

	if (bWire)
	{
		// Special case wireframe mode
		Frame->Viewport->RenDev->PreRender(Frame);
		
		// Draw the particles
		if (this->GlassBreakCount)
		{
			// Render sheet as a bunch of broken up polygons
			for (INT i=0; i< this->NumGlassParticles; i++)
			{
				if (!GLASS_PARTICLES(this)[i])
					continue;

				// Render the particle
				DrawGlassParticleWire(this, Frame, GLASS_PARTICLES(this)[i], Color);
			}
		}
		else
		{
		#ifdef SPECIAL_SUBDIVIDE
			for (INT i=0; i<4; i++)
				DrawPolygonWire(this, Frame, &GLASS_USERDATA(this)->UnBrokenVerts[i][0], 4, Color, ModelToWorld);
		#else
			DrawPolygonWire(this, Frame, Quad, 4, Color, ModelToWorld);
		#endif
		}

		Frame->Viewport->RenDev->Queued3DLinesFlush(Frame);
	}
	else
	{
		// Lock textures, and driver
		GlassTexture1->Lock(TextureInfo[0], Frame->Viewport->CurrentTime, -1, Frame->Viewport->RenDev);
		GlassTexture2->Lock(TextureInfo[1], Frame->Viewport->CurrentTime, -1, Frame->Viewport->RenDev);
		GlassTexture3->Lock(TextureInfo[2], Frame->Viewport->CurrentTime, -1, Frame->Viewport->RenDev);

		Frame->Viewport->RenDev->QueuePolygonBegin(Frame);

		FLOAT ShiftU, ShiftV, ScaleU, ScaleV;

		if (GLASS_USERDATA(this)->RandomRotateDir == 1 || GLASS_USERDATA(this)->RandomRotateDir == 3)
		{
			ShiftU = this->GlassSizeY*0.5f+this->UShift;
			ShiftV = this->GlassSizeX*0.5f+this->VShift;

			ScaleU = (1.0f/this->GlassSizeY)*(1.0f/this->UScale);
			ScaleV = (1.0f/this->GlassSizeX)*(1.0f/this->VScale);
		}
		else
		{
			ShiftU = this->GlassSizeX*0.5f+this->UShift;
			ShiftV = this->GlassSizeY*0.5f+this->VShift;

			ScaleU = (1.0f/this->GlassSizeX)*(1.0f/this->UScale);
			ScaleV = (1.0f/this->GlassSizeY)*(1.0f/this->VScale);
		}

		// Draw the particles
		if (this->GlassBreakCount)
		{
			// Render sheet as a bunch of broken up polygons
			for (INT i=0; i< this->NumGlassParticles; i++)
			{
				if (!GLASS_PARTICLES(this)[i])
					continue;

				// Render the particle
				if (!GLASS_USERDATA(this)->Shattered)
					DrawGlassParticle(this, Frame, GLASS_PARTICLES(this)[i], Color, &TextureInfo[1], ShiftU, ShiftV, ScaleU, ScaleV);
				else 
					DrawGlassParticle(this, Frame, GLASS_PARTICLES(this)[i], Color, &TextureInfo[2], ShiftU, ShiftV, ScaleU, ScaleV);
			}
		}
		else
		{
			// Draw entire sheet at one polygon
		#ifdef SPECIAL_SUBDIVIDE
			for (INT i=0; i<4; i++)
				DrawPolygon(this, Frame, &GLASS_USERDATA(this)->UnBrokenVerts[i][0], 4, Color, ModelToCamera, &TextureInfo[0], ShiftU, ShiftV, ScaleU, ScaleV);
		#else
			DrawPolygon(this, Frame, Quad, 4, Color, ModelToCamera, &TextureInfo[0], ShiftU, ShiftV, ScaleU, ScaleV);
		#endif
		}
	
		// Unlock textures and driver
		Frame->Viewport->RenDev->QueuePolygonEnd();
		
		GlassTexture1->Unlock(TextureInfo[0]);
		GlassTexture2->Unlock(TextureInfo[1]);
		GlassTexture3->Unlock(TextureInfo[2]);
	}
}

//===========================================================================
//	CreatePrimitive
//===========================================================================
UPrimitive *CreatePrimitive(ABreakableGlass *Glass)
{
    JGlassPrimitive		*Prim;

    if (!Glass->GlassPrimitive )
    {
        UClass *Cls = JGlassPrimitive::StaticClass();
        Prim = (JGlassPrimitive*)UObject::StaticConstructObject(	Cls, 
														UObject::GetTransientPackage(),
														NAME_None,
														RF_Transient,
														Cls->GetDefaultObject());
        Glass->GlassPrimitive = (INT)Prim;
        Prim->GlassInstance = Glass;

		Prim->AddToRoot();		// Don't delete me Unreal!!!
    }
    else
    {
        Prim = (JGlassPrimitive*)Glass->GlassPrimitive;
    }

    FVector Extent(30, 30, 30);

	Prim->BoundingBox = FBox(Extent,Extent);	
    
    return Prim;
}

//====================================================================
//	ABoneRope::GetPrimitive - Returns a primitive for system collision
//====================================================================
UPrimitive *ABreakableGlass::GetPrimitive() const
{
#if 1
	if (!GlassPrimitive)
		CreatePrimitive((ABreakableGlass*)this);

	if (GlassPrimitive)
		return GLASS_PRIMITIVE(this);
#endif

	return GetLevel()->Engine->Cylinder;

}

//
//	Script functions
//

//===========================================================================
// ABreakableGlass::execBreakGlass
//===========================================================================
void ABreakableGlass::execBreakGlass( FFrame& Stack, RESULT_DECL )
{
	P_GET_VECTOR(Location);
	P_GET_UBOOL_OPTX(DirForce, false);
	P_GET_FLOAT_OPTX(DirForceScale, 1.0f);
	P_FINISH;

	if (!GlassIsValid(this))
		return;

	if (GlassIsDone(this))
		return;

	FVector	Verts[4];

	BuildGlassQuad(this, Verts);

	// Put the worldspace location on the glass (it will get projected onto the surface, then clamped to the boundry)
	FVector ProjLocation = Location;
	FLOAT	BreakX, BreakY;

	ProjectWorldToGlass(this, Verts, 4, ProjLocation, BreakX, BreakY);

	BreakGlassFinal(this, Verts, 4, ProjLocation);

	if (DirForce)
	{
		// BreakLocation is in glass space, bring it into world 
		FVector WorldProjLocation = ProjLocation.TransformPointBy(this->ToWorld());

		FVector		Dir = (WorldProjLocation - Location);

		if (Dir.SizeSquared() > 0.0001)
		{
			Dir.Normalize();
			Dir *= DirForceScale;
		}
		else
			Dir = FVector(0,0,0);

		StartParticlePhysics(this, this->NumGlassParticles*0.75f, DirForce, &Dir, &ProjLocation);
		ShatterGlass(this);
	}
	else
	{
		// Break out this->InitialBreakCount pieces of glass on the break
		StartParticlePhysics(this, this->InitialBreakCount);
		this->eventGlassCracked();
	}
}

//===========================================================================
// ABreakableGlass::execBreakGlassDir
//===========================================================================
void ABreakableGlass::execBreakGlassDir( FFrame& Stack, RESULT_DECL )
{
	P_GET_VECTOR(Location);
	P_GET_VECTOR(Dir);
	P_GET_FLOAT(DirForceScale);
	P_FINISH;

	FVector	Verts[4];

	BuildGlassQuad(this, Verts);

	// Put the worldspace location on the glass (it will get projected onto the surface, then clamped to the boundry)
	FVector ProjLocation = Location;
	FLOAT	BreakX, BreakY;

	ProjectWorldToGlass(this, Verts, 4, ProjLocation, BreakX, BreakY);

	BreakGlassFinal(this, Verts, 4, ProjLocation);

	if (Dir.SizeSquared() > 0.0001)
	{
		Dir.Normalize();
		Dir *= DirForceScale;
	}
	else
		Dir = FVector(0,0,0);

	StartParticlePhysics(this, this->NumGlassParticles*0.75f, true, &Dir, &ProjLocation);
	ShatterGlass(this);
}

//===========================================================================
// ABreakableGlass::execBreakGlassXY
//===========================================================================
void ABreakableGlass::execBreakGlassXY( FFrame& Stack, RESULT_DECL )
{
	P_GET_FLOAT(x);
	P_GET_FLOAT(y);
	P_FINISH;
	
	if (!GlassIsValid(this))
		return;

	if (GlassIsDone(this))
		return;

	FVector	Verts[4], BL;

	BuildGlassQuad(this, Verts);

	BreakGlassXY(this, Verts, 4, x, y, BL);

	// Break out this->InitialBreakCount pieces of glass on the break
	StartParticlePhysics(this, this->InitialBreakCount);
}

//===========================================================================
// ABreakableGlass::execInternalTick
//===========================================================================
void ABreakableGlass::execInternalTick( FFrame& Stack, RESULT_DECL )
{
	P_GET_FLOAT(DeltaTime);
	P_FINISH;
	
	if (!GlassIsValid(this))
		return;

	GlassInternalTick(this, DeltaTime);
}

//===========================================================================
// ABreakableGlass::execGetParticleBox
//===========================================================================
void ABreakableGlass::execGetParticleBox( FFrame& Stack, RESULT_DECL )
{
	P_GET_VECTOR_REF(Min);
	P_GET_VECTOR_REF(Max);
	P_FINISH;

	FBox Bounds = GLASS_USERDATA(this)->RenderBox;//GetPrimitive()->GetRenderBoundingBox(this, 0);

	*Min = Bounds.Min;
	*Max = Bounds.Max;
}