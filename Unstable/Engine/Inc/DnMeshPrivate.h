#ifndef __DNMESHPRIVATE_H__
#define __DNMESHPRIVATE_H__
//****************************************************************************
//**
//**    DNMESHPRIVATE.H
//**    Header - DNF Mesh Objects - Private
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "..\..\Cannibal\CannibalUnr.h"

#ifndef CPJVECTOR
#define CPJVECTOR FVector
#endif
#ifndef CPJQUAT
#define CPJQUAT FQuat
#endif

#pragma pack(push,1)
#include "..\..\Cannibal\CpjFmt.h"
#pragma pack(pop)

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
class UDukeMeshInstance;

class ODukeMacActor
: public OMacActor
{
	OBJ_CLASS_DEFINE(ODukeMacActor, OMacActor);

	UDukeMeshInstance* mOwnerInstance;
	FVector mDukeOrigin;
	FRotator mDukeRotOrigin;
	FVector mDukeScale;
	FVector mDukeBounds[2];

	void Create()
	{
		Super::Create();
		mOwnerInstance = NULL;
		mDukeOrigin = FVector(0,0,0);
		mDukeRotOrigin = FRotator(0,0,0);
		mDukeScale = FVector(1,1,1);
		mDukeBounds[0] = FVector(-1,-1,-1);
		mDukeBounds[1] = FVector(1,1,1);
	}
};

class ENGINE_API UDukeMeshInstance : public UMeshInstance
{
	DECLARE_CLASS(UDukeMeshInstance,UMeshInstance,CLASS_Transient)

	AActor* Actor;
	UDukeMesh* Mesh;
	ODukeMacActor* Mac;

	// UObject
	UDukeMeshInstance();
	void Destroy();

	// UPrimitive
	UBOOL LineCheck(FCheckResult& Result, AActor* Owner, FVector End, FVector Start, FVector Extent, DWORD ExtraNodeFlags, UBOOL bMeshAccurate=0);
	FBox GetRenderBoundingBox(const AActor* Owner, UBOOL Exact);

	// UMeshInstance
	UMesh* GetMesh();
	void SetMesh(UMesh* InMesh);

	AActor* GetActor();
	void SetActor(AActor* InActor);

	INT GetNumSequences();
	HMeshSequence GetSequence(INT SeqIndex);
	HMeshSequence FindSequence(FName SeqName);
	
	FName GetSeqName(HMeshSequence Seq);
	void SetSeqGroupName(FName SequenceName, FName GroupName);
	FName GetSeqGroupName(FName SequenceName);
	INT GetSeqNumFrames(HMeshSequence Seq);
	FLOAT GetSeqRate(HMeshSequence Seq);
	INT GetSeqNumEvents(HMeshSequence Seq);
	EMeshSeqEvent GetSeqEventType(HMeshSequence Seq, INT Index);
	FLOAT GetSeqEventTime(HMeshSequence Seq, INT Index);
	const TCHAR* GetSeqEventString(HMeshSequence Seq, INT Index);

	UBOOL PlaySequence(HMeshSequence Seq, BYTE Channel, UBOOL bLoop, FLOAT Rate, FLOAT MinRate, FLOAT TweenTime);
	void DriveSequences(FLOAT DeltaSeconds);

	UTexture* GetTexture(INT Count);
	void GetStringValue(FOutputDevice& Ar, const TCHAR* Key, INT Index);
	void SendStringCommand(const TCHAR* Cmd);
	FCoords GetBasisCoords(AActor *actor,FCoords Coords);
	inline FCoords GetBasisCoords(FCoords Coords){return GetBasisCoords(Actor,Coords);}
	INT GetFrame(FVector* Verts, BYTE* VertsEnabled, INT Size, FCoords Coords, FLOAT LodLevel);
	UBOOL GetMountCoords(FName MountName, INT MountType, FCoords& OutCoords, AActor* ChildActor);
    UBOOL GetBoneCoords(CMacBone *bone, FCoords& OutCoords);

	void Draw(/* FSceneNode* */void* InFrame, /* FDynamicSprite* */void* InSprite,
		FCoords InCoords, DWORD InPolyFlags);

	// UDukeMeshInstance
	void DestroyMacActor();
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
//**    END HEADER DNMESHPRIVATE.H
//**
//****************************************************************************
#endif // __DNMESHPRIVATE_H__
