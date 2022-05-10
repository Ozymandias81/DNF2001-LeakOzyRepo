// UnrealMesh private header

class ENGINE_API UUnrealMeshInstance : public UMeshInstance
{
	DECLARE_CLASS(UUnrealMeshInstance,UMeshInstance,CLASS_Transient)

	UUnrealMesh* Mesh;
	AActor* Actor;

	// UObject
	UUnrealMeshInstance();

	// UMeshInstance
	UMesh* GetMesh();
	void SetMesh(UMesh* InMesh);

	AActor* GetActor();
	void SetActor(AActor* InActor);

	INT GetNumSequences();
	HMeshSequence GetSequence(INT SeqIndex);
	HMeshSequence FindSequence(FName SeqName);
	
	FName GetSeqName(HMeshSequence Seq);
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
	FCoords GetBasisCoords(FCoords Coords);
	INT GetFrame(FVector* Verts, BYTE* VertsEnabled, INT Size, FCoords Coords, FLOAT LodLevel);

	void Draw(/* FSceneNode* */void* InFrame, /* FDynamicSprite* */void* InSprite,
		FCoords InCoords, DWORD InPolyFlags);

	// UUnrealMeshInstance
	INT AMD3DGetFrame(FVector* Verts, BYTE* VertsEnabled, INT Size, FCoords Coords, FLOAT LodLevel);
};
