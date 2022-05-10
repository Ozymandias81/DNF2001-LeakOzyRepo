#ifndef __MESHBASE_H__
#define __MESHBASE_H__
//****************************************************************************
//**
//**    MESHBASE.H
//**    Header - Abstract Mesh Objects and Interfaces
//**
//**	There will be quadrillions of picochanges all over the code, changing
//**	references to the specific unreal structures to use these interfaces
//**	instead.  I don't have the time or inclination to put comments next to
//**	all of them, but just assume that if you see any such changes that I
//**	did them. - CDH
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
#define MESHSEQEV_FOURCC(a,b,c,d) ((a)+((b)<<8)+((c)<<16)+((d)<<24))

// sequence event types
enum EMeshSeqEvent
{
	MESHSEQEV_None			= 0,
	MESHSEQEV_Marker		= MESHSEQEV_FOURCC('M','R','K','R'), // string is a marker, not an actual event
	MESHSEQEV_Trigger		= MESHSEQEV_FOURCC('T','R','I','G'), // fire a trigger notification string
	MESHSEQEV_MacCmd		= MESHSEQEV_FOURCC('A','C','M','D'), // send a model actor command
};

// sequence handle
typedef void* HMeshSequence;

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================

/*
	FMeshChannel
	Mesh animation channel structure within MeshInstance
*/
#if _MSC_VER
#pragma pack(push,4)
#endif

class AMeshEffect;

struct ENGINE_API FMeshChannel
{
	BITFIELD bAnimFinished:1 GCC_PACK(4);
	BITFIELD bAnimLoop:1;
	BITFIELD bAnimNotify:1;
	BITFIELD bAnimBlendAdditive:1;
	FName AnimSequence GCC_PACK(4);
	FLOAT AnimFrame;
	FLOAT AnimRate;
	FLOAT AnimBlend;
	FLOAT TweenRate;
	FLOAT AnimLast;
	FLOAT AnimMinRate;
	FLOAT OldAnimRate;
	FPlane SimAnim;
	AMeshEffect* MeshEffect;
};

struct ENGINE_API FMeshDecalTri
{
	DWORD TriIndex; // triangle index
	FLOAT TexU[3]; // texture U coordinates
	FLOAT TexV[3]; // texture V coordinates
};

#if _MSC_VER
#pragma pack(pop)
#endif

class UMesh;
class UMeshInstance;

/*
	UMesh

	The standard mesh interface has been changed from a mesh representation
	ala Unreal's meshes, into a small interface dedicated only to creating
	a mesh instance to attach to an actor.

	The existing UMesh is being changed to UUnrealMesh, and the base UMesh
	class will be an abstract base for UUnrealMesh and the UDukeMesh branches
*/
class ENGINE_API UMesh : public UPrimitive
{
	DECLARE_CLASS(UMesh,UPrimitive,0)

	UMeshInstance* DefaultInstance;

	// UObject
	UMesh();
	void Destroy();

	// Get a mesh instance for this mesh attached to the given actor.
	// If the actor's mesh is the same as this mesh, any current instance should be valid.
	// If the actor's mesh is not the same, or its instance isn't valid, create a new one.
	// InActor may be NULL to retrieve a default unattached instance usable for some operations.
	virtual UMeshInstance* GetInstance(AActor* InActor);

	virtual UClass* GetInstanceClass() { return(NULL); }
};

/*
	UMeshInstance

	A mesh instance is attached to an actor when its mesh is initially set or is changed.
	This mesh instance can maintain its own state specific to the bound actor, and acts as
	an aggregate of the actor for anything related to its mesh representation.
*/
class ENGINE_API UMeshInstance : public UPrimitive
{
	DECLARE_CLASS(UMeshInstance,UPrimitive,CLASS_Transient)

	FMeshChannel MeshChannels[16];

	// UPrimitive
	UBOOL PointCheck(FCheckResult& Result, AActor* Owner, FVector Location, FVector Extent, DWORD ExtraNodeFlags)
	{
		UMesh* Mesh = GetMesh();
		if (!Mesh)
			return(1);
		return(Mesh->PointCheck(Result, Owner, Location, Extent, ExtraNodeFlags));
	}
	UBOOL LineCheck(FCheckResult& Result, AActor* Owner, FVector End, FVector Start, FVector Extent, DWORD ExtraNodeFlags, UBOOL bMeshAccurate=0)
	{
		UMesh* Mesh = GetMesh();
		if (!Mesh)
			return(1);
		return(Mesh->LineCheck(Result, Owner, End, Start, Extent, ExtraNodeFlags, bMeshAccurate));
	}
	FBox GetRenderBoundingBox(const AActor* Owner, UBOOL Exact)
	{
		UMesh* Mesh = GetMesh();
		if (!Mesh)
			return(FBox());
		return(Mesh->GetRenderBoundingBox(Owner, Exact));
	}
	FBox GetCollisionBoundingBox(const AActor* Owner) const
	{
		UMesh* Mesh = ((UMeshInstance*)this)->GetMesh();
		if (!Mesh)
			return(FBox());
		return(Mesh->GetCollisionBoundingBox(Owner));
	}

	// UMeshInstance
	virtual UMesh* GetMesh() { return(NULL); }
	virtual void SetMesh(UMesh* InMesh) {}

	virtual AActor* GetActor() { return(NULL); }
	virtual void SetActor(AActor* InActor) {}

	virtual INT GetNumSequences() { return(0); }
	virtual HMeshSequence GetSequence(INT SeqIndex) { return(NULL); }
	virtual HMeshSequence FindSequence(FName SeqName) { return(NULL); } // find sequence for a given name
	
	virtual FName GetSeqName(HMeshSequence Seq) { return(NAME_None); } // name of sequence
	virtual void SetSeqGroupName(FName SequenceName, FName GroupName) { } // group name, potentially NAME_None
	virtual FName GetSeqGroupName(FName SequenceName) { return(NAME_None); } // group name, potentially NAME_None
	virtual INT GetSeqNumFrames(HMeshSequence Seq) { return(0); } // number of frames in sequence
	virtual FLOAT GetSeqRate(HMeshSequence Seq) { return(10.f); } // play rate in FPS
	virtual INT GetSeqNumEvents(HMeshSequence Seq) { return(0); } // number of events in sequence
	virtual EMeshSeqEvent GetSeqEventType(HMeshSequence Seq, INT Index) { return(MESHSEQEV_None); } // sequence event type
	virtual FLOAT GetSeqEventTime(HMeshSequence Seq, INT Index) { return(0.f); } // time to occur, 0.0-1.0
	virtual const TCHAR* GetSeqEventString(HMeshSequence Seq, INT Index) { return(TEXT("")); } // parameter string, potentially null

	virtual UBOOL PlaySequence(HMeshSequence Seq, BYTE Channel, UBOOL bLoop, FLOAT Rate, FLOAT MinRate, FLOAT TweenTime) { return(0); } // play a sequence on a channel
	virtual void DriveSequences(FLOAT DeltaSeconds) {} // drive all sequences by a given delta time

	virtual UTexture* GetTexture(INT Count) { return(NULL); } // get the texture for a given index slot
	virtual void GetStringValue(FOutputDevice& Ar, const TCHAR* Key, INT Index) {} // get an arbitrary property value for a string key name
	virtual void SendStringCommand(const TCHAR* Cmd) {} // send a string command to the mesh instance to perform arbitrary actions
	virtual FCoords GetBasisCoords(FCoords Coords) { return(FCoords(FVector(0,0,0))); } // get the basis coords for world<->actor space transforms
	virtual INT GetFrame(FVector* Verts, BYTE* VertsEnabled, INT Size, FCoords Coords, FLOAT LodLevel) { return(0); } // get the current vertex frame positions
	virtual UBOOL GetMountCoords(FName MountName, INT MountType, FCoords& OutCoords, AActor* ChildActor) { return(0); } // get coords relative to mount point

	virtual void Draw(/* FSceneNode* */void* InFrame, /* FDynamicSprite* */void* InSprite,
		FCoords InCoords, DWORD InPolyFlags) {}

	DECLARE_FUNCTION(execMeshToWorldLocation);
	DECLARE_FUNCTION(execWorldToMeshLocation);
	DECLARE_FUNCTION(execMeshToWorldRotation);
	DECLARE_FUNCTION(execWorldToMeshRotation);

	DECLARE_FUNCTION(execBoneFindNamed);
	DECLARE_FUNCTION(execBoneGetName);
	DECLARE_FUNCTION(execBoneGetParent);
	DECLARE_FUNCTION(execBoneGetChildCount);
	DECLARE_FUNCTION(execBoneGetChild);
	DECLARE_FUNCTION(execBoneGetTranslate);
	DECLARE_FUNCTION(execBoneGetRotate);
	DECLARE_FUNCTION(execBoneGetScale);
	DECLARE_FUNCTION(execBoneSetTranslate);
	DECLARE_FUNCTION(execBoneSetRotate);
	DECLARE_FUNCTION(execBoneSetScale);
    DECLARE_FUNCTION(execGetBounds);
};

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
//============================================================================
//    INLINE CLASS METHODS
//============================================================================
//============================================================================
//    TRAILING HEADERS
//============================================================================

//****************************************************************************
//**
//**    END HEADER MESHBASE.H
//**
//****************************************************************************
#endif // __MESHBASE_H__
