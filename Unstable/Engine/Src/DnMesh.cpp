//****************************************************************************
//**
//**    DNMESH.CPP
//**    DNF Mesh Objects
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================

#include "EnginePrivate.h"

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
class ODukeMeshEffectChannel
: public OMacChannel
{
	OBJ_CLASS_DEFINE(ODukeMeshEffectChannel, OMacChannel);

	AActor* mAnimActor;
	AMeshEffect* mEffectActor;
	DWORD mChannelIndex;

	NBool EvalBones(OMacActor* inActor)
	{
		NBool result = (mAnimActor->eventOnEvalBones(mChannelIndex)!=0);
		if (mEffectActor && mEffectActor->bAffectsBones)
		{
			mEffectActor->eventEvalBones(mChannelIndex, mAnimActor);
			result = 1;
		}
		return(result);
	}
	NBool EvalVerts(OMacActor* inActor, NDword inNumVerts, NWord* inVertRelay, VVec3* ioVerts)
	{
		if (!mEffectActor || !mEffectActor->bAffectsVerts)
			return(0);
		for (DWORD i=0;i<inNumVerts;i++)
			mEffectActor->eventEvalVert(mChannelIndex, mAnimActor, *(FVector*)(&ioVerts[i]));
		return(1);
	}
};
OBJ_CLASS_IMPLEMENTATION(ODukeMeshEffectChannel, OMacChannel, 0);

//============================================================================
//    PRIVATE DATA
//============================================================================
//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    PRIVATE FUNCTIONS
//============================================================================
/*-----------------------------------------------------------------------------
	CDH: Cannibal connection
-----------------------------------------------------------------------------*/
#include "..\..\Cannibal\CannibalUnr.h"

#pragma warning(disable: 4505) // unreferenced local function

class CUnrealLogTarget
: public ILogTarget
{
public:
	void Init(NChar* inTitle) {}
	void Shutdown() {}
	void Write(NChar* inStr)
	{
		if (!inStr)
			return;
		debugf(TEXT("Cannibal Log: %s"), appFromAnsi(inStr));
	}
};

static CUnrealLogTarget GCannibalUnrealLogTarget;

static void CannibalQuit()
{
	appErrorf(TEXT("Cannibal Fatal Error"));
}

static void CannibalInit()
{
	STR_ArgInit(__argc,__argv);
	FILE_BoxInit(NULL);
	LOG_Init("Cannibal", CannibalQuit, LOGLVL_Normal, 0);
	LOG_AddTarget(&GCannibalUnrealLogTarget);
	MSG_Init();
	OBJ_Init(NULL);
	PLG_Init(".\\");
}

/*
static void CannibalShutdown()
{
	OBJ_Shutdown();
	PLG_Shutdown();
	MSG_Shutdown();
	LOG_Shutdown();
}
*/
static void ConvertDukeMesh(UDukeMesh* Mesh, FArchive& Ar)
{
	GWarn->Logf(NAME_Log, TEXT("DukeMesh conversion: Beginning %s"), Mesh->GetName());

	static UBOOL staticInit = 0;
	if (!staticInit)
	{
		CannibalInit();
		staticInit = 1;
	}

	INT meshVersion; Ar << meshVersion;
	FString sceneFileName; Ar << sceneFileName;
	FString modelName; Ar << modelName;
	TArray<UTexture*> textureRelay; Ar << textureRelay;
	TArray<USound*> soundRelay; Ar << soundRelay;
	FVector meshScale; Ar << meshScale;
	FVector meshOrigin; Ar << meshOrigin;
	FRotator meshRotOrigin; Ar << meshRotOrigin;
	DWORD meshFlags = 0;
	if (meshVersion >= 2)
		Ar << meshFlags;

	if (!(*sceneFileName))
	{
		GWarn->Logf(NAME_Log, TEXT("  No scene file name, skipping..."));
		return;
	}
	
	FString InPath, OutPath;
	if ((!GConfig->GetString(TEXT("MeshConfig"), TEXT("MeshConversionIn"), InPath))
	 || (!GConfig->GetString(TEXT("MeshConfig"), TEXT("MeshConversionOut"), OutPath)))
	{
		GWarn->Logf(NAME_Log, TEXT("  Missing \"[MeshConfig] MeshConversionIn=xxx, MeshConversionOut=xxx\" INI strings"));
		return;
	}

	char inFile[256];
	strcpy(inFile, appToAnsi(*InPath));
	strcat(inFile, appToAnsi(*sceneFileName));
	char outFile[256];
	strcpy(outFile, appToAnsi(*OutPath));
	strcat(outFile, STR_FileForcedExt((char*)appToAnsi(*sceneFileName), "cpj"));

	GWarn->Logf(NAME_Log, TEXT("  Input file: %s"), appFromAnsi(inFile));
	GWarn->Logf(NAME_Log, TEXT("  Output file: %s"), appFromAnsi(outFile));

	char tempBuf[256];
	strcpy(tempBuf, "Models\\");
	strcat(tempBuf, STR_FileForcedExt((char*)appToAnsi(*sceneFileName), "cpj"));
	strcat(tempBuf, "\\default");
	Mesh->ConfigName = appFromAnsi(tempBuf);

	GWarn->Logf(NAME_Log, TEXT("  Converting..."));
	
	OCpjProject* prj = OCpjProject::New(NULL,NULL);
	if (!prj->ImportFile(inFile))
	{
		prj->Destroy();
		GWarn->Logf(NAME_Log, TEXT("  IMPORT ERROR: Unable to import input file!"));
		return;
	}
	//GWarn->Logf(NAME_Log, TEXT("  Import complete."));

	// create output directory
	char outDir[256], *ptr;
	strcpy(outDir, STR_FilePath(outFile));
	if (ptr = strrchr(outDir, '\\'))
		*ptr = 0; // get rid of trailing backslash
	GFileManager->MakeDirectory(appFromAnsi(outDir), true);
	//GWarn->Logf(NAME_Log, TEXT("  Directory created."));
	
	OCpjSurface* surf = (OCpjSurface*)prj->FindChunk(OCpjSurface::GetStaticClass(), NULL);
	if (!surf)
	{
		GWarn->Logf(NAME_Log, TEXT("  WARNING: Imported project has no surface description"));
		surf = OCpjSurface::New(prj,NULL);
	}
	INT count = (INT)surf->m_Textures.GetCount();
	if (textureRelay.Num() != count)
	{
		// commented out this warning, turns out it's not necessary... if the textureRelay has too few textures, it means some of them weren't
		// actually used in which case who cares, and if it has too many, it means the mesh has been around a while and used to have more textures
		// than it does now, in which case the extra slots aren't used either.  So if we just use the minimum count, all should be okay.
		
		//GWarn->Logf(NAME_Log, TEXT("  WARNING: Imported project has texture count different from texture relay (%d vs. %d)"), count, textureRelay.Num());
		if (count > textureRelay.Num())
			count = textureRelay.Num();
	}
	for (INT i=0;i<count;i++)
	{
		UTexture* tex = textureRelay(i);
		if (tex)
			strcpy(surf->m_Textures[i].refName, appToAnsi(tex->GetPathName()));
		else
			surf->m_Textures[i].refName[0] = 0;
	}

	OCpjConfig* macinfo = (OCpjConfig*)prj->FindChunk(OCpjConfig::GetStaticClass(), NULL);
	if (!macinfo)
	{
		prj->Destroy();
		GWarn->Logf(NAME_Log, TEXT("  IMPORT ERROR: Unable to find configuration section"));
		return;
	}
	OMacActor* tempMac = OMacActor::New(NULL);
	if (!tempMac->LoadConfig(macinfo))
	{
		tempMac->Destroy();
		prj->Destroy();
		GWarn->Logf(NAME_Log, TEXT("  IMPORT ERROR: Unable to load configuration"));
		return;
	}

	meshOrigin = meshOrigin.ToStd();
	tempMac->mOrigin = VVec3(meshOrigin.X, meshOrigin.Y, meshOrigin.Z);
	tempMac->mRotation = VEulers3((FLOAT)meshRotOrigin.Roll*180.f/32768.f, -(FLOAT)meshRotOrigin.Pitch*180.f/32768.f, -(FLOAT)meshRotOrigin.Yaw*180.f/32768.f);
	meshScale.Y = -meshScale.Y;
	meshScale = meshScale.ToStd();
	tempMac->mScale = VVec3(meshScale.X, meshScale.Y, meshScale.Z);
	FVector boundMin = Mesh->BoundingBox.Min.ToStd();
	tempMac->mBounds[0] = VVec3(boundMin.X, boundMin.Y, boundMin.Z);
	FVector boundMax = Mesh->BoundingBox.Max.ToStd();
	tempMac->mBounds[1] = VVec3(boundMax.X, boundMax.Y, boundMax.Z);

	if (!tempMac->SaveConfig(macinfo))
	{
		tempMac->Destroy();
		prj->Destroy();
		GWarn->Logf(NAME_Log, TEXT("  IMPORT ERROR: Unable to save configuration"));
		return;
	}

	tempMac->Destroy();

	if (!prj->ExportFile(outFile))
	{
		prj->Destroy();
		GWarn->Logf(NAME_Log, TEXT("  EXPORT ERROR: Unable to export output file!"));
		return;
	}
	//GWarn->Logf(NAME_Log, TEXT("  Export complete."));

	prj->Destroy();	
	//GWarn->Logf(NAME_Log, TEXT("  Done."));
}

static void SetMeshBasePath()
{
	if (!CPJ_GetBasePath()[0])
	{
		FString MeshPath;
		if (!GConfig->GetString(TEXT("MeshConfig"), TEXT("MeshBasePath"), MeshPath))
			MeshPath = TEXT("..") PATH_SEPARATOR TEXT("Meshes");			
		
		FString BasePath(appBaseDir());
		BasePath += MeshPath;
		
		CPJ_SetBasePath(appToAnsi(*BasePath));
	}
}

DWORD WINAPI ConfigEditThreadEntry(void* inParam)
{
	static NBool mutex = 0; // don't allow more than one edit box to exist at once
	if (mutex)
		return(0);
	mutex = 1;
	MAC_EditBox(IPC_GetCurrentProcess());
	mutex = 0;
	return(0);
}

MSG_FUNC_C(ODukeMacActor, ConfigEdit, "", (ODukeMacActor* This, IMsg*))
{
	SetMeshBasePath();

	DWORD boxThreadId;
	HANDLE boxThread = CreateThread(NULL, 0, ConfigEditThreadEntry, 0, 0, &boxThreadId);

	IPC_PostMessage(IPC_GetCurrentProcess(), MACEDIT_IPC_PROTOCOL_IN, MACEDIT_IPC_IMSG_SETTITLE, 0, "Edit Mesh Configuration");

	static NChar buf[256];
	strcpy(buf, appToAnsi(*This->mOwnerInstance->Mesh->ConfigName));
	IPC_PostMessage(IPC_GetCurrentProcess(), MACEDIT_IPC_PROTOCOL_IN, MACEDIT_IPC_IMSG_SELECTCONFIG, 0, buf);
	
	return(1);
}
/*
MSG_FUNC_C(ODukeMacActor, ConfigEdit, "", (ODukeMacActor* This, IMsg*))
{
	static NChar buf[256];
	SetMeshBasePath();
	sprintf(buf, "CblMacEd %s %d", CPJ_GetBasePath(), IPC_GetCurrentProcess());

	PROCESS_INFORMATION pinfo;
	STARTUPINFOA sinfo;
	memset(&sinfo, 0, sizeof(STARTUPINFO));
	sinfo.cb = sizeof(STARTUPINFO);

	if (!CreateProcessA(NULL, buf, NULL, NULL, false, 0, NULL, NULL, &sinfo, &pinfo))
	{
		LOG_Logf("CreateProcess failed, GetLastError=%d", GetLastError());
		return(1);
	}
	_sleep(5000);
	NDword kidProcess = IPC_GetNamedProcess("IPC_CBLMACED");
	if (!kidProcess)
		return(1);
	
	//sprintf(buf, "%d", IPC_GetCurrentProcess());
	//_spawnl(_P_NOWAIT, "munchie", "munchie", buf, NULL);	
	//while (!IPC_SendMessage(kidProcess, MACEDIT_IPC_PROTOCOL_IN, MACEDIT_IPC_IMSG_ISREADY, 0, NULL, NULL))
	//	_sleep(0);
	IPC_PostMessage(kidProcess, MACEDIT_IPC_PROTOCOL_IN, MACEDIT_IPC_IMSG_SETTITLE, 0, "Edit Mesh Configuration");
	strcpy(buf, appToAnsi(*This->mOwnerInstance->Mesh->ConfigName));
	IPC_PostMessage(kidProcess, MACEDIT_IPC_PROTOCOL_IN, MACEDIT_IPC_IMSG_SELECTCONFIG, 0, buf);
	
	return(1);
}
*/

MSG_FUNC_C(ODukeMacActor, SetOrigin, "fff", (ODukeMacActor* This, IMsg*, NFloat inX, NFloat inY, NFloat inZ))
{
	This->mOrigin = VVec3(inX,inY,inZ);
	This->mDukeOrigin = FVector(inX,inY,inZ);
	This->mDukeOrigin = This->mDukeOrigin.ToUnr();
	return(1);
}
MSG_FUNC_C(ODukeMacActor, SetRotation, "fff", (ODukeMacActor* This, IMsg*, NFloat inRoll, NFloat inPitch, NFloat inYaw))
{
	This->mRotation = VEulers3(M_DEGTORAD(inRoll),M_DEGTORAD(inPitch),M_DEGTORAD(inYaw));
	inRoll = inRoll*32768.f/180.f;
	inPitch = -inPitch*32768.f/180.f;
	inYaw = -inYaw*32768.f/180.f;
	This->mDukeRotOrigin = FRotator(inPitch, inYaw, inRoll);
	return(1);
}
MSG_FUNC_C(ODukeMacActor, SetScale, "fff", (ODukeMacActor* This, IMsg*, NFloat inX, NFloat inY, NFloat inZ))
{
	This->mScale = VVec3(inX,inY,inZ);
	This->mDukeScale = FVector(inX,inY,inZ);
	This->mDukeScale = This->mDukeScale.ToUnr();
	This->mDukeScale.Y = -This->mDukeScale.Y;
	return(1);
}
MSG_FUNC_C(ODukeMacActor, SetBoundsMin, "fff", (ODukeMacActor* This, IMsg*, NFloat inX, NFloat inY, NFloat inZ))
{
	This->mBounds[0] = VVec3(inX,inY,inZ);
	This->mDukeBounds[0] = FVector(inX,inY,inZ);
	This->mDukeBounds[0] = This->mDukeBounds[0].ToUnr();
	return(1);
}
MSG_FUNC_C(ODukeMacActor, SetBoundsMax, "fff", (ODukeMacActor* This, IMsg*, NFloat inX, NFloat inY, NFloat inZ))
{
	This->mBounds[1] = VVec3(inX,inY,inZ);
	This->mDukeBounds[1] = FVector(inX,inY,inZ);
	This->mDukeBounds[1] = This->mDukeBounds[1].ToUnr();
	return(1);
}

// Getframe utility functions
static float GetFrameBegin(UDukeMeshInstance* const MeshInst, AActor* const AnimOwner)
{
	// create channel objects as needed
	check(MeshInst->Mac->mActorChannels.GetCount() >= 16); // must match up with what actor expects

	FLOAT TweenValue = 1.f;

	for (DWORD i=0;i<16;i++)
	{

		OCpjSequence* Seq = NULL;

		// make sure the channel is empty
		MeshInst->Mac->mActorChannels[i] = NULL;

		FMeshChannel* MeshChan = &MeshInst->MeshChannels[i];

		// Copy stock animation information to channel zero info
		if (!i)
		{
			MeshChan->bAnimFinished = AnimOwner->bAnimFinished;
			MeshChan->bAnimLoop = AnimOwner->bAnimLoop;
			MeshChan->bAnimNotify = AnimOwner->bAnimNotify;
			MeshChan->bAnimBlendAdditive = AnimOwner->bAnimBlendAdditive;
			MeshChan->AnimSequence = AnimOwner->AnimSequence;
			MeshChan->AnimFrame = AnimOwner->AnimFrame;
			MeshChan->AnimRate = AnimOwner->AnimRate;
			MeshChan->AnimBlend = AnimOwner->AnimBlend;
			MeshChan->TweenRate = AnimOwner->TweenRate;
			MeshChan->AnimLast = AnimOwner->AnimLast;
			MeshChan->AnimMinRate = AnimOwner->AnimMinRate;
			MeshChan->OldAnimRate = AnimOwner->OldAnimRate;
			MeshChan->SimAnim = AnimOwner->SimAnim;
			/* AH: wasn't getting copied before, probably should be */
			MeshChan->MeshEffect = AnimOwner->MeshEffect;
		}

		if ((MeshChan->AnimSequence!=NAME_None) && (Seq = MeshInst->Mac->FindSequence(appToAnsi(*MeshChan->AnimSequence))))
		{				
			// channel is a regular sequence
			Seq->CacheIn();
			if (Seq->m_Frames.GetCount())
			{
				OMacSequenceChannel* chan = OMacSequenceChannel::New(NULL);
				chan->mSequence = Seq;
				if (MeshChan->AnimFrame >= 0.f)
				{
					chan->mTime = MeshChan->AnimFrame;
				}
				else
				{					
					// tweening
					chan->mTime = 0.f;					
					//chan->mTime = -MeshChan->AnimFrame / MeshChan->AnimRate; // CDH: this is a test, it looks better than 0.f, but still might not be perfect
																	// Nevermind, commented out because it was fubaring triggercrane and other meshes, need better formula
					if (!i)
						TweenValue = 1.f - ((-MeshChan->AnimFrame) * Seq->m_Frames.GetCount());
				}
				chan->mBlendAlpha = 1.f - MeshChan->AnimBlend;
				chan->mBlendMode = MeshChan->bAnimBlendAdditive ? MACSEQBLEND_ADD : MACSEQBLEND_SET;
				MeshInst->Mac->mActorChannels[i] = chan;
			}
		}
		else
		{
			// channel uses a mesh effect rather than a regular sequence
			ODukeMeshEffectChannel* chan = ODukeMeshEffectChannel::New(NULL);
			chan->mAnimActor = AnimOwner;
			chan->mEffectActor = MeshChan->MeshEffect;
			chan->mChannelIndex = i;
			MeshInst->Mac->mActorChannels[i] = chan;
		}
	}
	return(TweenValue);
}

static void GetFrameEnd(UDukeMeshInstance* const MeshInst)
{
	// wipe out channel objects
	for (DWORD i=0;i<16;i++)
	{
		if (MeshInst->Mac->mActorChannels[i])
		{
			MeshInst->Mac->mActorChannels[i]->Destroy();
			MeshInst->Mac->mActorChannels[i] = NULL;
		}
	}
}

//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
//============================================================================
//    CLASS METHODS
//============================================================================
/*
	ODukeMacActor
*/
OBJ_CLASS_IMPLEMENTATION(ODukeMacActor, OMacActor, 0);

/*
	UDukeMeshInstance
*/
IMPLEMENT_CLASS(UDukeMeshInstance);

void UDukeMeshInstance::DestroyMacActor()
{
	if (!Mac)
		return;
	
	// remove any allocated channels
	for (NDword i=0;i<Mac->mActorChannels.GetCount();i++)
	{
		if (Mac->mActorChannels[i])
		{
			Mac->mActorChannels[i]->Destroy();
			Mac->mActorChannels[i] = NULL;
		}
	}
	// destroy the object itself
	Mac->Destroy();
	Mac = NULL;
}

UDukeMeshInstance::UDukeMeshInstance()
{
	Mesh = NULL;
	Actor = NULL;
	Mac = NULL;
}
void UDukeMeshInstance::Destroy()
{
	DestroyMacActor();
	Super::Destroy();
}

UMesh* UDukeMeshInstance::GetMesh()
{
	return(Mesh);
}

void UDukeMeshInstance::SetMesh(UMesh* InMesh)
{
	STAT(clock(GStat.SetMeshCycles));

	DestroyMacActor();
	
	Mesh = Cast<UDukeMesh>(InMesh);
	if (!Mesh)
	{
		STAT(unclock(GStat.SetMeshCycles));
		return;
	}
	
	// set the base path if it's not already set
	SetMeshBasePath();

	// load the configuration
	OCpjConfig* ConfigMac = (OCpjConfig*)CPJ_FindChunk(NULL, OCpjConfig::GetStaticClass(), appToAnsi(*Mesh->ConfigName));
	if (!ConfigMac)
		ConfigMac = (OCpjConfig*)CPJ_FindChunk(NULL, OCpjConfig::GetStaticClass(), "default.cpj\\default");
	if (!ConfigMac)
		appErrorf(TEXT("UDukeMeshInstance::SetMesh: Default project not found"));
	Mac = ODukeMacActor::New(NULL);
	Mac->mOwnerInstance = this;
	if (!Mac->LoadConfig(ConfigMac))
	{
		appErrorf(TEXT("UDukeMeshInstance::SetMesh: LoadConfig failure on %s"), *Mesh->ConfigName);
		//Mac->Destroy();
		//Mac = NULL;
	}

	// map the configuration's textures
	for (DWORD i=0;i<Mac->mSurfaces.GetCount();i++)
	{
		OCpjSurface* surf = Mac->mSurfaces[i];
		for (DWORD j=0;j<surf->m_Textures.GetCount();j++)
		{
			CCpjSrfTex* tex = &surf->m_Textures[j];
			tex->imagePtr = NULL;
			if (tex->refName[0])
			{				
				tex->imagePtr = FindObject<UTexture>(ANY_PACKAGE, appFromAnsi(tex->refName), 0);
				if (!tex->imagePtr)
				{
					// This is beyond nasty, but LoadObject, due to crappy linker requirements, needs the class to be an exact match... graar :(
					for (TObjectIterator<UClass> It; It; ++It)
					{
						if (It->IsChildOf(UTexture::StaticClass()))
							if (tex->imagePtr = (UTexture*)StaticLoadObject(*It, NULL, appFromAnsi(tex->refName), NULL, LOAD_None, NULL))
								break;
					}
				}
			}
		}
	}

	STAT(unclock(GStat.SetMeshCycles));
}

AActor* UDukeMeshInstance::GetActor()
{
	return(Actor);
}
void UDukeMeshInstance::SetActor(AActor* InActor)
{
	Actor = InActor;
}

INT UDukeMeshInstance::GetNumSequences()
{
	if (!Mac)
		return(0);
	return(Mac->mSequences.GetCount());
}
HMeshSequence UDukeMeshInstance::GetSequence(INT SeqIndex)
{
	if (!Mac)
		return(NULL);
	return(Mac->mSequences[SeqIndex]);
}
HMeshSequence UDukeMeshInstance::FindSequence(FName SeqName)
{
	if (!Mac)
		return(NULL);
	return(Mac->FindSequence(appToAnsi(*SeqName)));
}

FName UDukeMeshInstance::GetSeqName(HMeshSequence Seq)
{
	OCpjSequence* S = (OCpjSequence*)Seq;
	return(FName(appFromAnsi(S->GetName())));
}
void UDukeMeshInstance::SetSeqGroupName(FName SequenceName, FName GroupName)
{
	Mesh->SequenceGroupMap.Set(SequenceName, GroupName);
	return;
}
FName UDukeMeshInstance::GetSeqGroupName(FName SequenceName)
{
	FName* GroupName = Mesh->SequenceGroupMap.Find(SequenceName);
	if (GroupName == NULL)
		return NAME_None;
	return *GroupName;
}
INT UDukeMeshInstance::GetSeqNumFrames(HMeshSequence Seq)
{
	OCpjSequence* S = (OCpjSequence*)Seq;
	S->CacheIn();
	return(S->m_Frames.GetCount());
}
FLOAT UDukeMeshInstance::GetSeqRate(HMeshSequence Seq)
{
	OCpjSequence* S = (OCpjSequence*)Seq;
	S->CacheIn();
	return(S->m_Rate);
}
INT UDukeMeshInstance::GetSeqNumEvents(HMeshSequence Seq)
{
	OCpjSequence* S = (OCpjSequence*)Seq;
	S->CacheIn();
	return(S->m_Events.GetCount());
}
EMeshSeqEvent UDukeMeshInstance::GetSeqEventType(HMeshSequence Seq, INT Index)
{
	OCpjSequence* S = (OCpjSequence*)Seq;
	S->CacheIn();
	return((EMeshSeqEvent)S->m_Events[Index].eventType);
}
FLOAT UDukeMeshInstance::GetSeqEventTime(HMeshSequence Seq, INT Index)
{
	OCpjSequence* S = (OCpjSequence*)Seq;
	S->CacheIn();
	return(S->m_Events[Index].time);
}
const TCHAR* UDukeMeshInstance::GetSeqEventString(HMeshSequence Seq, INT Index)
{
	OCpjSequence* S = (OCpjSequence*)Seq;
	S->CacheIn();
	return(appFromAnsi(*S->m_Events[Index].paramString));
}

UBOOL UDukeMeshInstance::PlaySequence(HMeshSequence Seq, BYTE Channel, UBOOL bLoop, FLOAT Rate, FLOAT MinRate, FLOAT TweenTime)
{
	if (!Actor || !Seq)
		return(0);

	FMeshChannel* Chan = &MeshChannels[Channel];

	if (Rate != 0.f)
	{
		// PlayAnim or LoopAnim
		if (!bLoop)
		{
			// PlayAnim - Set one-shot animation
			if( Chan->AnimSequence == NAME_None )
				TweenTime = 0.0;
			Chan->AnimSequence  = GetSeqName(Seq);
			Chan->AnimRate      = Rate * GetSeqRate(Seq) / GetSeqNumFrames(Seq);
			Chan->AnimLast      = 1.0 - 1.0 / GetSeqNumFrames(Seq);
			Chan->bAnimNotify   = GetSeqNumEvents(Seq)!=0;
			Chan->bAnimFinished = 0;
			Chan->bAnimLoop     = 0;
			if( Chan->AnimLast == 0.0 )
			{
				Chan->AnimMinRate   = 0.0;
				Chan->bAnimNotify   = 0;
				Chan->OldAnimRate   = 0;
				if( TweenTime > 0.0 )
					Chan->TweenRate = 1.0 / TweenTime;
				else
					Chan->TweenRate = 10.0; //tween in 0.1 sec
				Chan->AnimFrame = -1.0/GetSeqNumFrames(Seq);
				Chan->AnimRate = 0;
			}
			else if( TweenTime>0.0 )
			{
				Chan->TweenRate = 1.0 / (TweenTime * GetSeqNumFrames(Seq));
				Chan->AnimFrame = -1.0/GetSeqNumFrames(Seq);
			}
			else if ( TweenTime == -1.0 )
			{
				Chan->AnimFrame = -1.0/GetSeqNumFrames(Seq);
				if ( Chan->OldAnimRate > 0 )
					Chan->TweenRate = Chan->OldAnimRate;
				else if ( Chan->OldAnimRate < 0 ) //was velocity based looping
					Chan->TweenRate = ::Max(0.5f * Chan->AnimRate, -1 * Actor->Velocity.Size() * Chan->OldAnimRate );
				else
					Chan->TweenRate = 1.0/(0.025 * GetSeqNumFrames(Seq));
			}
			else
			{
				Chan->TweenRate = 0.0;
				Chan->AnimFrame = 0.001;
			}
			FPlane OldSimAnim = Chan->SimAnim;
			Chan->OldAnimRate = Chan->AnimRate;
			Chan->SimAnim.X = 10000 * Chan->AnimFrame;
			Chan->SimAnim.Y = 5000 * Chan->AnimRate;
			if ( Chan->SimAnim.Y > 32767 )
				Chan->SimAnim.Y = 32767;
			Chan->SimAnim.Z = 1000 * Chan->TweenRate;
			Chan->SimAnim.W = 10000 * Chan->AnimLast;

            if ( OldSimAnim == Chan->SimAnim )
				Chan->SimAnim.W = Chan->SimAnim.W + 1;
		}
		else
		{
			// LoopAnim - Set looping animation
			if ( (Chan->AnimSequence == GetSeqName(Seq)) && Chan->bAnimLoop	&& Actor->IsAnimating(Channel) )
			{
				Chan->AnimRate = Rate * GetSeqRate(Seq) / GetSeqNumFrames(Seq);
				Chan->bAnimFinished = 0;
				Chan->AnimMinRate = MinRate!=0.0 ? MinRate * (GetSeqRate(Seq) / GetSeqNumFrames(Seq)) : 0.0;
				FPlane OldSimAnim = Chan->SimAnim;
				Chan->OldAnimRate = Chan->AnimRate;		
				Chan->SimAnim.Y = 5000 * Chan->AnimRate;
				Chan->SimAnim.W = -10000 * (1.0 - 1.0 / GetSeqNumFrames(Seq));
				if ( OldSimAnim == Chan->SimAnim )
					Chan->SimAnim.W = Chan->SimAnim.W + 1;

				// Copy channel zero information to stock animation info
				if (!Channel)
				{
					Actor->bAnimFinished = Chan->bAnimFinished;
					Actor->bAnimLoop = Chan->bAnimLoop;
					Actor->bAnimNotify = Chan->bAnimNotify;
					Actor->bAnimBlendAdditive = Chan->bAnimBlendAdditive;
					Actor->AnimSequence = Chan->AnimSequence;
					Actor->AnimFrame = Chan->AnimFrame;
					Actor->AnimRate = Chan->AnimRate;
					Actor->AnimBlend = Chan->AnimBlend;
					Actor->TweenRate = Chan->TweenRate;
					Actor->AnimLast = Chan->AnimLast;
					Actor->AnimMinRate = Chan->AnimMinRate;
					Actor->OldAnimRate = Chan->OldAnimRate;
					Actor->SimAnim = Chan->SimAnim;
				}

				return(1);
			}
			if( Chan->AnimSequence == NAME_None )
				TweenTime = 0.0;
			Chan->AnimSequence  = GetSeqName(Seq);
			Chan->AnimRate      = Rate * GetSeqRate(Seq) / GetSeqNumFrames(Seq);
			Chan->AnimLast      = 1.0 - 1.0 / GetSeqNumFrames(Seq);
			Chan->AnimMinRate   = MinRate!=0.0 ? MinRate * (GetSeqRate(Seq) / GetSeqNumFrames(Seq)) : 0.0;
			Chan->bAnimNotify   = GetSeqNumEvents(Seq)!=0;
			Chan->bAnimFinished = 0;
			Chan->bAnimLoop     = 1;
			if ( Chan->AnimLast == 0.0 )
			{
				Chan->AnimMinRate   = 0.0;
				Chan->bAnimNotify   = 0;
				Chan->OldAnimRate   = 0;
				if ( TweenTime > 0.0 )
					Chan->TweenRate = 1.0 / TweenTime;
				else
					Chan->TweenRate = 10.0; //tween in 0.1 sec
				Chan->AnimFrame = -1.0/GetSeqNumFrames(Seq);
				Chan->AnimRate = 0;
			}
			else if( TweenTime>0.0 )
			{
				Chan->TweenRate = 1.0 / (TweenTime * GetSeqNumFrames(Seq));
				Chan->AnimFrame = -1.0/GetSeqNumFrames(Seq);
			}
			else if ( TweenTime == -1.0 )
			{
				Chan->AnimFrame = -1.0/GetSeqNumFrames(Seq);
				if ( Chan->OldAnimRate > 0 )
					Chan->TweenRate = Chan->OldAnimRate;
				else if ( Chan->OldAnimRate < 0 ) //was velocity based looping
					Chan->TweenRate = ::Max(0.5f * Chan->AnimRate, -1 * Actor->Velocity.Size() * Chan->OldAnimRate );
				else
					Chan->TweenRate = 1.0/(0.025 * GetSeqNumFrames(Seq));
			}
			else
			{
				Chan->TweenRate = 0.0;
				Chan->AnimFrame = 0.0001;
			}
			Chan->OldAnimRate = Chan->AnimRate;
			Chan->SimAnim.X = 10000 * Chan->AnimFrame;
			Chan->SimAnim.Y = 5000 * Chan->AnimRate;
			if ( Chan->SimAnim.Y > 32767 )
				Chan->SimAnim.Y = 32767;
			Chan->SimAnim.Z = 1000 * Chan->TweenRate;
			Chan->SimAnim.W = -10000 * Chan->AnimLast;
		}
	}
	else // (Rate == 0.f)
	{
		// TweenAnim - Tweening an animation from wherever it is, to the start of a specified sequence.
		Chan->AnimSequence  = GetSeqName(Seq);
		Chan->AnimLast      = 0.0;
		Chan->AnimMinRate   = 0.0;
		Chan->bAnimNotify   = 0;
		Chan->bAnimFinished = 0;
		Chan->bAnimLoop     = 0;
		Chan->AnimRate      = 0;
		Chan->OldAnimRate   = 0;
		if( TweenTime>0.0 )
		{
			Chan->TweenRate =  1.0/(TweenTime * GetSeqNumFrames(Seq));
			Chan->AnimFrame = -1.0/GetSeqNumFrames(Seq);
		}
		else
		{
			Chan->TweenRate = 0.0;
			Chan->AnimFrame = 0.0;
		}
		Chan->SimAnim.X = 10000 * Chan->AnimFrame;
		Chan->SimAnim.Y = 5000 * Chan->AnimRate;
		if ( Chan->SimAnim.Y > 32767 )
			Chan->SimAnim.Y = 32767;
		Chan->SimAnim.Z = 1000 * Chan->TweenRate;
		Chan->SimAnim.W = 10000 * Chan->AnimLast;
	}

	// Copy channel zero information to stock animation info
	if (!Channel)
	{
		Actor->bAnimFinished = Chan->bAnimFinished;
		Actor->bAnimLoop = Chan->bAnimLoop;
		Actor->bAnimNotify = Chan->bAnimNotify;
		Actor->bAnimBlendAdditive = Chan->bAnimBlendAdditive;
		Actor->AnimSequence = Chan->AnimSequence;
		Actor->AnimFrame = Chan->AnimFrame;
		Actor->AnimRate = Chan->AnimRate;
		Actor->AnimBlend = Chan->AnimBlend;
		Actor->TweenRate = Chan->TweenRate;
		Actor->AnimLast = Chan->AnimLast;
		Actor->AnimMinRate = Chan->AnimMinRate;
		Actor->OldAnimRate = Chan->OldAnimRate;
		Actor->SimAnim = Chan->SimAnim;
	}

	return(1);
}
static void DumpAnimData( AActor *Actor )
{
	debugf( _T( "bAnimFinished %d" ), Actor->bAnimFinished ); 
	debugf( _T( "bAnimLoop %d" ), Actor->bAnimLoop ); 
	debugf( _T( "bAnimNotify %d" ), Actor->bAnimNotify ); 
	debugf( _T( "bAnimBlendAdditive %d" ), Actor->bAnimBlendAdditive ); 
	debugf( _T( "AnimSequence %s" ), *Actor->AnimSequence ); 
	debugf( _T( "AnimFrame %f" ), Actor->AnimFrame ); 
	debugf( _T( "AnimBlend %f" ), Actor->AnimBlend ); 
	debugf( _T( "TweenRate %f" ), Actor->TweenRate ); 
	debugf( _T( "AnimLast %f" ), Actor->AnimLast ); 
	debugf( _T( "AnimMinRate %f" ), Actor->AnimMinRate ); 
	debugf( _T( "OldAnimRate %f" ), Actor->OldAnimRate ); 
	debugf( _T( "bAnimFinished %d" ), Actor->bAnimFinished ); 
	debugf( _T( "\n\n" ) );
}

void UDukeMeshInstance::DriveSequences(FLOAT DeltaSeconds)
{
	
	if (!Actor)
		return;

	UBOOL bSimulatedPawn = (Cast<APawn>(Actor) && (Actor->Role==ROLE_SimulatedProxy));

	if (Mac)
		Mac->bBonesDirty = true;		// JEP: Let the bones know they need to re-calculate their positions

	for (INT Channel=0; Channel<16; Channel++)
	{
		FMeshChannel* Chan = &MeshChannels[Channel];

		// Copy stock animation information to channel zero info
		if (!Channel)
		{
			Chan->bAnimFinished = Actor->bAnimFinished;
			Chan->bAnimLoop = Actor->bAnimLoop;
			Chan->bAnimNotify = Actor->bAnimNotify;
			Chan->bAnimBlendAdditive = Actor->bAnimBlendAdditive;
			Chan->AnimSequence = Actor->AnimSequence;
			Chan->AnimFrame = Actor->AnimFrame;
			Chan->AnimRate = Actor->AnimRate;
			Chan->AnimBlend = Actor->AnimBlend;
			Chan->TweenRate = Actor->TweenRate;
			Chan->AnimLast = Actor->AnimLast;
			Chan->AnimMinRate = Actor->AnimMinRate;
			Chan->OldAnimRate = Actor->OldAnimRate;
			Chan->SimAnim = Actor->SimAnim;
		}

		// Update all animation, including multiple passes if necessary.
		INT Iterations = 0;
		FLOAT Seconds = DeltaSeconds;
		while
		(	Actor->IsAnimating(Channel)
		&&	(Seconds>0.0)
		&&	(++Iterations <= 4) )
		{
			// Remember the old frame.
			FLOAT OldAnimFrame = Chan->AnimFrame;

			// Update animation, and possibly overflow it.
			if( Chan->AnimFrame >= 0.0 )
			{
				// Update regular or velocity-scaled animation.
				if( Chan->AnimRate >= 0.0 )
					Chan->AnimFrame += Chan->AnimRate * Seconds;
				else
					Chan->AnimFrame += ::Max( Chan->AnimMinRate, Actor->Velocity.Size() * -Chan->AnimRate ) * Seconds;

				// Handle all animation sequence notifys.
				if( Chan->bAnimNotify )
				{
					HMeshSequence Seq = FindSequence(Chan->AnimSequence);
					if( Seq )
					{
						FLOAT BestElapsedFrames = 100000.0;
						INT BestNotify = -1;
						for( INT i=0; i<GetSeqNumEvents(Seq); i++ )
						{
							if (GetSeqEventType(Seq, i) != MESHSEQEV_Trigger)
								continue;
							FLOAT EventTime = GetSeqEventTime(Seq, i);
							if( OldAnimFrame<EventTime && Chan->AnimFrame>=EventTime )
							{
								FLOAT ElapsedFrames = EventTime - OldAnimFrame;
								if ((BestNotify==-1) || (ElapsedFrames<BestElapsedFrames))
								{
									BestElapsedFrames = ElapsedFrames;
									BestNotify        = i;
								}
							}
						}
						if (BestNotify != -1)
						{
							Seconds   = Seconds * (Chan->AnimFrame - GetSeqEventTime(Seq, BestNotify)) / (Chan->AnimFrame - OldAnimFrame);
							Chan->AnimFrame = GetSeqEventTime(Seq, BestNotify);
							UFunction* Function = Actor->FindFunction( FName(GetSeqEventString(Seq, BestNotify)) );
							if( Function )
								Actor->ProcessEvent( Function, NULL );
							continue;
						}
					}
				}

				// Handle end of animation sequence.
				if( Chan->AnimFrame < Chan->AnimLast )
				{
					// We have finished the animation updating for this tick.
					break;
				}
				else if( Chan->bAnimLoop )
				{
					if( Chan->AnimFrame < 1.0 )
					{
						// Still looping.
						Seconds = 0.0;
					}
					else
					{
						// Just passed end, so loop it.
						Seconds = Seconds * (Chan->AnimFrame - 1.0) / (Chan->AnimFrame - OldAnimFrame);
						Chan->AnimFrame = 0.0;
					}
					if( OldAnimFrame < Chan->AnimLast )
					{
						if ((Actor->GetStateFrame()->LatentAction == EPOLL_FinishAnim)
						 && (Actor->LatentInt == Channel))
						{
							Chan->bAnimFinished = 1;
							if (!Channel)
								Actor->bAnimFinished = 1;
						}
						if( !bSimulatedPawn )
						{
							AActor* Act = Actor; // need to duplicate since this meshinstance may be destroyed if actor dies in animend
							if (!Channel)
							{
								Actor->bAnimFinished = Chan->bAnimFinished;
								Actor->bAnimLoop = Chan->bAnimLoop;
								Actor->bAnimNotify = Chan->bAnimNotify;
								Actor->bAnimBlendAdditive = Chan->bAnimBlendAdditive;
								Actor->AnimSequence = Chan->AnimSequence;
								Actor->AnimFrame = Chan->AnimFrame;
								Actor->AnimRate = Chan->AnimRate;
								Actor->AnimBlend = Chan->AnimBlend;
								Actor->TweenRate = Chan->TweenRate;
								Actor->AnimLast = Chan->AnimLast;
								Actor->AnimMinRate = Chan->AnimMinRate;
								Actor->OldAnimRate = Chan->OldAnimRate;
								Actor->SimAnim = Chan->SimAnim;
								Actor->eventAnimEnd();
							}
							else if (Actor->IsProbing(NAME_AnimEnd))
								Actor->eventAnimEndEx(Channel);
							
							if (!Act->IsValid() || Act->bDeleteMe)
								return;
						}
					}
				}
				else 
				{
					// Just passed end-minus-one frame.
					Seconds = Seconds * (Chan->AnimFrame - Chan->AnimLast) / (Chan->AnimFrame - OldAnimFrame);
					Chan->AnimFrame = Chan->AnimLast;
					Chan->bAnimFinished = 1;
					Chan->AnimRate = 0.0;
					if( !bSimulatedPawn )
					{
						AActor* Act = Actor; // need to duplicate since this meshinstance may be destroyed if actor dies in animend
						if (!Channel)
						{
							Actor->bAnimFinished = Chan->bAnimFinished;
							Actor->bAnimLoop = Chan->bAnimLoop;
							Actor->bAnimNotify = Chan->bAnimNotify;
							Actor->bAnimBlendAdditive = Chan->bAnimBlendAdditive;
							Actor->AnimSequence = Chan->AnimSequence;
							Actor->AnimFrame = Chan->AnimFrame;
							Actor->AnimRate = Chan->AnimRate;
							Actor->AnimBlend = Chan->AnimBlend;
							Actor->TweenRate = Chan->TweenRate;
							Actor->AnimLast = Chan->AnimLast;
							Actor->AnimMinRate = Chan->AnimMinRate;
							Actor->OldAnimRate = Chan->OldAnimRate;
							Actor->SimAnim = Chan->SimAnim;
							Actor->eventAnimEnd();
						}
						else if (Actor->IsProbing(NAME_AnimEnd))
							Actor->eventAnimEndEx(Channel);

						if (!Act->IsValid() || Act->bDeleteMe)
							return;
					}
					
					if ( 
                         ( Actor->bUpdateSimAnim ) ||
                         ( ( Actor->RemoteRole < ROLE_SimulatedProxy) && !Actor->IsA(AWeapon::StaticClass() ) )
                       )
					{
						Chan->SimAnim.X = 10000 * Chan->AnimFrame;
						Chan->SimAnim.Y = 5000 * Chan->AnimRate;
						if ( Chan->SimAnim.Y > 32767 )
							Chan->SimAnim.Y = 32767;
					}
				}
			}
			else
			{
				// Update tweening.
				Chan->AnimFrame += Chan->TweenRate * Seconds;
				if( Chan->AnimFrame >= 0.0 )
				{
					// Finished tweening.
					Seconds = Seconds * (Chan->AnimFrame-0) / (Chan->AnimFrame - OldAnimFrame);
					Chan->AnimFrame = 0.0;
					if( Chan->AnimRate == 0.0 )
					{
						Chan->bAnimFinished = 1;
						if( !bSimulatedPawn )
						{
							AActor* Act = Actor; // need to duplicate since this meshinstance may be destroyed if actor dies in animend
							if (!Channel)
							{
								Actor->bAnimFinished = Chan->bAnimFinished;
								Actor->bAnimLoop = Chan->bAnimLoop;
								Actor->bAnimNotify = Chan->bAnimNotify;
								Actor->bAnimBlendAdditive = Chan->bAnimBlendAdditive;
								Actor->AnimSequence = Chan->AnimSequence;
								Actor->AnimFrame = Chan->AnimFrame;
								Actor->AnimRate = Chan->AnimRate;
								Actor->AnimBlend = Chan->AnimBlend;
								Actor->TweenRate = Chan->TweenRate;
								Actor->AnimLast = Chan->AnimLast;
								Actor->AnimMinRate = Chan->AnimMinRate;
								Actor->OldAnimRate = Chan->OldAnimRate;
								Actor->SimAnim = Chan->SimAnim;
								Actor->eventAnimEnd();
							}
							else if (Actor->IsProbing(NAME_AnimEnd))
								Actor->eventAnimEndEx(Channel);

							if (!Act->IsValid() || Act->bDeleteMe)
								return;
						}
					}
				}
				else
				{
					// Finished tweening.
					break;
				}
			}
		}

		// Copy channel zero information to stock animation info
		if (!Channel)
		{
			Actor->bAnimFinished = Chan->bAnimFinished;
			Actor->bAnimLoop = Chan->bAnimLoop;
			Actor->bAnimNotify = Chan->bAnimNotify;
			Actor->bAnimBlendAdditive = Chan->bAnimBlendAdditive;
			Actor->AnimSequence = Chan->AnimSequence;
			Actor->AnimFrame = Chan->AnimFrame;
			Actor->AnimRate = Chan->AnimRate;
			Actor->AnimBlend = Chan->AnimBlend;
			Actor->TweenRate = Chan->TweenRate;
			Actor->AnimLast = Chan->AnimLast;
			Actor->AnimMinRate = Chan->AnimMinRate;
			Actor->OldAnimRate = Chan->OldAnimRate;
			Actor->SimAnim = Chan->SimAnim;
		}		
	}

}

UTexture* UDukeMeshInstance::GetTexture(INT Count)
{
	CCpjSrfTex* Texs = NULL;
	if (Mac && Mac->mSurfaces[0] && Mac->mSurfaces[0]->m_Textures.GetCount())
		Texs = &Mac->mSurfaces[0]->m_Textures[0];
	if( Actor && Actor->GetSkin( Count ) )
		return Actor->GetSkin( Count );
	else if( Count!=Actor->SkinIndex && Texs && Texs[Count].imagePtr )
		return (UTexture*)Texs[Count].imagePtr;
	else if( Actor && Actor->Skin )
		return Actor->Skin;
	else if (Texs)
		return (UTexture*)Texs[Count].imagePtr;
	return(NULL);
}
void UDukeMeshInstance::GetStringValue(FOutputDevice& Ar, const TCHAR* Key, INT Index)
{
	if (!Mesh)
		return;
	
	// the only two values which can be ascertained without a valid Mac
	if (!appStricmp(Key,TEXT("IsDukeMesh")))
		Ar.Logf(TEXT("%d"), 1);
	else if (!appStricmp(Key,TEXT("ConfigName")))
		Ar.Logf(TEXT("%s"), *Mesh->ConfigName);
	
	if (!Mac)
		return;

	// Sequences
	else if (!appStricmp(Key,TEXT("NumAnimSeqs")))
		Ar.Logf(TEXT("%d"), GetNumSequences());
	else if (!appStricmp(Key,TEXT("AnimSeqName")))
	{
		if ((Index >= 0) && (Index < GetNumSequences()))
		{
			HMeshSequence Seq = GetSequence(Index);
			if (Seq && GetSeqName(Seq)!=NAME_None)
				Ar.Logf(TEXT("%s"), *GetSeqName(Seq));
		}
	}
	else if (!appStricmp(Key,TEXT("AnimSeqRate")))
	{
		if ((Index >= 0) && (Index < GetNumSequences()))
		{
			HMeshSequence Seq = GetSequence(Index);
			if (Seq && GetSeqName(Seq)!=NAME_None)
				Ar.Logf(TEXT("%f"), GetSeqRate(Seq));
		}
	}
	else if (!appStricmp(Key,TEXT("AnimSeqFrames")))
	{
		if ((Index >= 0) && (Index < GetNumSequences()))
		{
			HMeshSequence Seq = GetSequence(Index);
			if (Seq && GetSeqName(Seq)!=NAME_None)
				Ar.Logf(TEXT("%d"), GetSeqNumFrames(Seq));
		}
	}
}
void UDukeMeshInstance::SendStringCommand(const TCHAR* Cmd)
{
	if (!Mac)
		return;
	Mac->Msgf((char*)appToAnsi(Cmd));
}
FCoords UDukeMeshInstance::GetBasisCoords(AActor *actor,FCoords Coords)
{
	if (!actor || !Mac)
		return(Coords);
	FLOAT DrawScale = actor->bParticles ? 1.f : actor->DrawScale;
	//DrawScale = 1.f;
	//UBOOL NotWeaponHeuristic = ((!Viewport) || (Owner->Owner != Viewport->Actor));	
	FVector HeightAdjust = actor->bMeshLowerByCollision ? FVector(0, 0, -actor->CollisionHeight) : FVector(0, 0, -actor->MeshLowerHeight);
	// Andy, this is a message from Brandon.  When you make this an actor method, make a Pawn version that adjusts
	// the height by 5 units.
	if ( actor->IsA(APawn::StaticClass()) )
		HeightAdjust.Z -= 5;
	Coords = Coords * (actor->Location + actor->PrePivot) * actor->Rotation * Mac->mDukeRotOrigin
		* HeightAdjust * FScale(Mac->mDukeScale * DrawScale, 0.f, SHEER_None);
	return(Coords);
}

static UBOOL mesh_GetFrameNoTransform = 0;

#define TWEEN_FIX			// JEP

INT UDukeMeshInstance::GetFrame(FVector* ResultVerts, BYTE* VertsEnabled, INT Size, FCoords Coords, FLOAT LodLevel)
{
	
	if (!Actor || !Mac)
		return(0);

	STAT(clock(GStat.GetFrameCycles));

	AActor* AnimOwner = Actor;
	if (Actor->bAnimByOwner && Actor->Owner)
		 AnimOwner = Actor->Owner;

	Coords = GetBasisCoords(AnimOwner,Coords);

	// start up the getframe
	INT NumVerts = 0, MaxVerts = 0;
	FLOAT TweenValue = 1.f;
	TweenValue = GetFrameBegin(this, AnimOwner);
	MaxVerts = Mac->mGeometry->m_Verts.GetCount();

	// snag cached vertices
	UBOOL IsTweening = 0;
	FCacheItem* Item = NULL;
	FLOAT Alpha = 1.f;
	BYTE* Mem = NULL;
	UBOOL WasCached = 1;
	
	QWORD CacheID = MakeCacheID(CID_TweenAnim, Actor, NULL);
	Mem = GCache.Get(CacheID, Item);
	if (!Mem || (*(UDukeMesh**)Mem != Mesh))
	{
		if (Mem)
		{
			// mesh instance changed
			Item->Unlock();
			GCache.Flush(CacheID);
		}
		Mem = GCache.Create(CacheID, Item, sizeof(UDukeMesh*) + sizeof(FLOAT) + sizeof(FName) + MaxVerts*sizeof(FVector));
		WasCached = 0;
	}

	UDukeMesh*& CachedMesh = *(UDukeMesh**)Mem; Mem += sizeof(UDukeMesh*);
	FLOAT& CachedFrame = *(FLOAT*)Mem; Mem += sizeof(FLOAT);
	FName& CachedSeq = *(FName*)Mem; Mem += sizeof(FName);
	FVector* CachedVerts = (FVector*)Mem;
	if (!WasCached)
	{
		CachedMesh = Mesh;
		CachedFrame = 0.f;
		CachedSeq = NAME_None;
	}

	if ((TweenValue < 1.f) && (WasCached))
	{
		IsTweening = 1;
	#ifdef TWEEN_FIX
		Alpha = 1.0 - AnimOwner->AnimFrame / CachedFrame;		// JEP
	#else
		Alpha = TweenValue;
	#endif

		OCpjSequence* Seq = (Mac->mActorChannels[0] && Mac->mActorChannels[0]->IsA(OMacSequenceChannel::GetStaticClass()))
			? ((OMacSequenceChannel*)Mac->mActorChannels[0])->mSequence : NULL;
		if ((CachedSeq!=AnimOwner->AnimSequence) || (Alpha<0.f) || (Alpha>1.f))
		{
			CachedSeq = AnimOwner->AnimSequence;
			CachedFrame = Seq ? (-1.f / Seq->m_Frames.GetCount()) : 0.f;
			Alpha = 0.f;
		}
	}

	// grab the requested vertices
	NumVerts = Mac->EvaluateVerts(LodLevel, Alpha, (VVec3*)CachedVerts);
	if (!mesh_GetFrameNoTransform)
	{
		// normal getframe
		FVector* V = CachedVerts;
		for (INT i=0;i<NumVerts;i++,V++)
		{
			*ResultVerts = (V->ToUnr() - Mac->mDukeOrigin).TransformPointBy(Coords);
			*(BYTE**)&ResultVerts += Size;
		}
	}
	else
	{
		// leave EvaluateVerts results intact
		check(Size == sizeof(FVector));
		memcpy(ResultVerts, CachedVerts, NumVerts*sizeof(FVector));
	}

	if (IsTweening)
		CachedFrame = AnimOwner->AnimFrame;
	Item->Unlock();
	GetFrameEnd(this);

	STAT(unclock(GStat.GetFrameCycles));

	return(NumVerts);
}

UBOOL UDukeMeshInstance::GetBoneCoords(CMacBone *bone, FCoords& OutCoords)
{
	if (!Actor || !Mac || !Mac->mGeometry)
		return(0);

	FLOAT TweenValue = GetFrameBegin(this, Actor);

	if (!bone)
	{
		GetFrameEnd(this);
		return(0);
    }
	VCoords3 c(bone->GetCoords(true));
	FCoords fc(FVector(0,0,0), *((FVector*)&c.r.vX), *((FVector*)&c.r.vY), *((FVector*)&c.r.vZ));
	fc = fc.ToUnr();
	FCoords MeshCoords = GetBasisCoords(GMath.UnitCoords);
	FCoords BoneCoords = GMath.UnitCoords;
	BoneCoords.XAxis = fc.XAxis.TransformVectorBy(MeshCoords); 
    BoneCoords.XAxis.Normalize();
	BoneCoords.YAxis = fc.YAxis.TransformVectorBy(MeshCoords); 
    BoneCoords.YAxis.Normalize();
	BoneCoords.ZAxis = fc.ZAxis.TransformVectorBy(MeshCoords); 
    BoneCoords.ZAxis.Normalize();
	BoneCoords.Origin = *((FVector*)&c.t);
    BoneCoords.Origin = BoneCoords.Origin.ToUnr();
	BoneCoords.Origin = (BoneCoords.Origin - Mac->mDukeOrigin).TransformPointBy(MeshCoords);
	OutCoords = BoneCoords.Transpose();
	GetFrameEnd(this);
	return(1);
}

UBOOL UDukeMeshInstance::GetMountCoords(FName MountName, INT MountType, FCoords& OutCoords, AActor* ChildActor)
{

	if (!Actor || !Mac || !Mac->mGeometry)
		return(0);

	STAT(clock(GStat.GetMountCoordsCycles));

	FLOAT TweenValue = GetFrameBegin(this, Actor);

	if (MountType == MOUNT_MeshBone)
	{
		CMacBone* bone = Mac->FindBone(appToAnsi(*MountName));
		if (!bone)
		{
			GetFrameEnd(this);
			STAT(unclock(GStat.GetMountCoordsCycles));
			return(0);
		}
		VCoords3 c(bone->GetCoords(true));
		FCoords fc(FVector(0,0,0), *((FVector*)&c.r.vX), *((FVector*)&c.r.vY), *((FVector*)&c.r.vZ));
		fc = fc.ToUnr();
		FCoords MeshCoords = GetBasisCoords(GMath.UnitCoords);
		FCoords BoneCoords = GMath.UnitCoords;
		BoneCoords.XAxis = fc.XAxis.TransformVectorBy(MeshCoords); BoneCoords.XAxis.Normalize();
		BoneCoords.YAxis = fc.YAxis.TransformVectorBy(MeshCoords); BoneCoords.YAxis.Normalize();
		BoneCoords.ZAxis = fc.ZAxis.TransformVectorBy(MeshCoords); BoneCoords.ZAxis.Normalize();
		BoneCoords.Origin = *((FVector*)&c.t); BoneCoords.Origin = BoneCoords.Origin.ToUnr();
		BoneCoords.Origin = (BoneCoords.Origin - Mac->mDukeOrigin).TransformPointBy(MeshCoords);
		OutCoords = BoneCoords.Transpose();
		GetFrameEnd(this);
		STAT(unclock(GStat.GetMountCoordsCycles));
		return(1);
	}
	
	if (MountType == MOUNT_MeshSurface)
	{
		FVector v[3], origV[3];
		INT triIndex;
		FVector triBarys;
		VCoords3 triBase;

		if (MountName == NAME_None)
		{
			// no named mount, use child actor mounting information
			if (!ChildActor || (ChildActor->MountMeshSurfaceTri < 0) || (ChildActor->MountMeshSurfaceTri >= (INT)Mac->mGeometry->m_Tris.GetCount()))
			{
				GetFrameEnd(this);
				STAT(unclock(GStat.GetMountCoordsCycles));
				return(0);
			}
			triIndex = ChildActor->MountMeshSurfaceTri;
			triBarys = ChildActor->MountMeshSurfaceBarys;
			triBase = VCoords3();
		}
		else
		{
			// find the geometry mount matching the given name
			CCpjGeoMount* mount = NULL;
			for (DWORD iMount=0; iMount<Mac->mGeometry->m_Mounts.GetCount(); iMount++)
			{
				if (!appStricmp(*MountName, appFromAnsi(Mac->mGeometry->m_Mounts[iMount].name)))
				{
					mount = &Mac->mGeometry->m_Mounts[iMount];
					break;
				}
			}
			if (!mount) // mount not found
			{
				GetFrameEnd(this);
				STAT(unclock(GStat.GetMountCoordsCycles));
				return(0);
			}
			triIndex = mount->triIndex;
			triBarys = *((FVector*)&mount->triBarys);
			triBase = mount->baseCoords;
		}

		// snag cached vertices
		FLOAT Alpha = 1.f;
		if (TweenValue < 1.f)
		{
			FCacheItem* Item = NULL;
			QWORD CacheID = MakeCacheID(CID_TweenAnim, Actor, NULL);
			BYTE* Mem = GCache.Get(CacheID, Item);
			if (Mem && (*(UDukeMesh**)Mem == Mesh))
			{
				Mem += sizeof(UDukeMesh*);
			#ifdef TWEEN_FIX
				FLOAT& CachedFrame = *(FLOAT*)Mem;		// JEP
			#endif
				Mem += sizeof(FLOAT);
				FName CachedSeq = *(FName*)Mem; Mem += sizeof(FName);
				FVector* CachedVerts = (FVector*)Mem;
				
			#ifdef TWEEN_FIX
				Alpha = 1.0 - Actor->AnimFrame / CachedFrame;		// JEP
			#else
				Alpha = TweenValue;
			#endif

				OCpjSequence* Seq = (Mac->mActorChannels[0] && Mac->mActorChannels[0]->IsA(OMacSequenceChannel::GetStaticClass()))
					? ((OMacSequenceChannel*)Mac->mActorChannels[0])->mSequence : NULL;
				if ((CachedSeq!=Actor->AnimSequence) || (Alpha<0.f) || (Alpha>1.f))
					Alpha = 0.f;
				for (INT j=0;j<3;j++)
					origV[j] = CachedVerts[Mac->mGeometry->m_Tris[triIndex].edgeRing[j]->tailVertex - &Mac->mGeometry->m_Verts[0]];				
			}
			if (Mem)
				Item->Unlock();
		}

		if (!Mac->EvaluateTriVerts(triIndex, Alpha, (VVec3*)&origV[0]))
		{
			GetFrameEnd(this);
			STAT(unclock(GStat.GetMountCoordsCycles));
			return(0);
		}
		FVector BackupLoc = Actor->Location;
		Actor->Location = FVector(0,0,0); // need to change actor origin to avoid floating point error below
		FCoords MeshCoords = GetBasisCoords(GMath.UnitCoords);
		Actor->Location = BackupLoc;

		for (INT i=0;i<3;i++)
			v[i] = (origV[i].ToUnr() - Mac->mDukeOrigin).TransformPointBy(MeshCoords);

		FCoords triCoords;		
		triCoords.Origin = v[0]*triBarys.X + v[1]*triBarys.Y + v[2]*triBarys.Z;
		triCoords.ZAxis = (v[2] - v[0]) ^ (v[0] - v[1]);
		triCoords.ZAxis.Normalize();
		triCoords.XAxis = v[0] - triCoords.Origin;
		triCoords.XAxis.Normalize();
		triCoords.YAxis = triCoords.ZAxis ^ triCoords.XAxis;
		triCoords.YAxis.Normalize();

		MeshCoords = GetBasisCoords(GMath.UnitCoords); // now that axes are computed, floating point error isn't an issue, recompute for origin
		for (i=0;i<3;i++)
			v[i] = (origV[i].ToUnr() - Mac->mDukeOrigin).TransformPointBy(MeshCoords);
		triCoords.Origin = v[0]*triBarys.X + v[1]*triBarys.Y + v[2]*triBarys.Z;

		FCoords baseCoords(FVector(0,0,0), *((FVector*)&triBase.r.vX), *((FVector*)&triBase.r.vY), *((FVector*)&triBase.r.vZ));
		baseCoords = baseCoords.ToUnr();
		
		triCoords = baseCoords * triCoords.Transpose();
		
		FVector ScaleFactor = Mac->mDukeScale;
		if (ChildActor)
			ScaleFactor *= ChildActor->DrawScale;
		triCoords.Origin += ((FVector(triBase.t.x, triBase.t.y, triBase.t.z).ToUnr()).TransformVectorBy(triCoords.Transpose())) * ScaleFactor;
		
		OutCoords = triCoords.Transpose();

		GetFrameEnd(this);
		STAT(unclock(GStat.GetMountCoordsCycles));
		return(1);
	}

	GetFrameEnd(this);
	STAT(unclock(GStat.GetMountCoordsCycles));
	return(0);

}

void UDukeMeshInstance::Draw(/* FSceneNode* */void* InFrame, /* FDynamicSprite* */void* InSprite,
	FCoords InCoords, DWORD InPolyFlags)
{
}

UBOOL UDukeMeshInstance::LineCheck(FCheckResult& Result, AActor* Owner, FVector End, FVector Start, FVector Extent, DWORD ExtraNodeFlags, UBOOL bMeshAccurate)
{
	if ((Extent != FVector(0,0,0))
	 || !Actor || (Actor!=Owner) || !Mac)
	{
		// Use cylinder.
		return UPrimitive::LineCheck( Result, Owner, End, Start, Extent, ExtraNodeFlags, bMeshAccurate );
	}
	else
	{
		if (!bMeshAccurate)
			return UPrimitive::LineCheck( Result, Owner, End, Start, FVector(0,0,0), ExtraNodeFlags, bMeshAccurate );

		Result.MeshBoneName = NAME_None;
		Result.MeshTri = -1;
		Result.MeshBarys = FVector(0.33,0.33,0.34);
		Result.MeshTexture = NULL;

		UBOOL PrimResult = UPrimitive::LineCheck( Result, Owner, End, Start, FVector(0,0,0), ExtraNodeFlags, bMeshAccurate );
		if (PrimResult)
			return(PrimResult); // cylinder failed, no need to go further

		// get vertices and triangles
		FMemMark Mark(GMem);
		SMacTri* TempTris = New<SMacTri>(GMem, Mac->mGeometry->m_Tris.GetCount());
		VVec3* TempVerts = New<VVec3>(GMem, Mac->mGeometry->m_Verts.GetCount());
		INT NumTris = Mac->EvaluateTris(1.f, TempTris);
		mesh_GetFrameNoTransform = 1;
		INT NumVerts = GetFrame((FVector*)TempVerts, NULL, sizeof(VVec3), GMath.UnitCoords, 1.f);
		mesh_GetFrameNoTransform = 0;

		// transform the start and end into mesh space
		FCoords MTWCoords = GetBasisCoords(GMath.UnitCoords) / FScale(Mac->mDukeScale * Actor->DrawScale, 0.f, SHEER_None);
		MTWCoords /= FScale(Mac->mDukeScale * Actor->DrawScale, 0.f, SHEER_None);
		FCoords WTMCoords = MTWCoords.Transpose();
		FVector EndTrans = (End.TransformPointBy(WTMCoords) + Mac->mDukeOrigin).ToStd();
		FVector StartTrans = (Start.TransformPointBy(WTMCoords) + Mac->mDukeOrigin).ToStd();
		VVec3 RayStart = *((VVec3*)&StartTrans);
		VVec3 RayEnd = *((VVec3*)&EndTrans);

		// get a line to trace
		VLine3 Ray; Ray.TwoPoint(RayStart, RayEnd);
		FLOAT RayLen = RayStart & RayEnd;

		// trace it
		DWORD HitTri;
		FLOAT HitDist;
		VVec3 HitBarys;
		CCpjSklBone* HitBone;
		UBOOL TraceRes = Mac->TraceRay(NumTris, TempTris, NumVerts, TempVerts, Ray, &HitTri, &HitDist, &HitBarys, &HitBone);
		if (TraceRes)
		{
			Result.Time = HitDist / RayLen;
			Result.Location = Start + (End - Start)*Result.Time;
			Result.Actor = Actor;
			Result.Primitive = NULL;
			
			FVector TriV[3];
			for (INT j=0;j<3;j++)
			{
				FVector* V = (FVector*)&TempVerts[TempTris[HitTri].vertIndex[j]];
				TriV[j] = (V->ToUnr() - Mac->mDukeOrigin).TransformPointBy(MTWCoords);
			}
			Result.Normal = FVector((TriV[1]-TriV[0]) ^ (TriV[2]-TriV[0]));
			Result.Normal *= (1.f / appSqrt(Result.Normal.SizeSquared()+0.001f));

			Result.MeshBoneName = HitBone ? FName(appFromAnsi(*HitBone->name)) : NAME_None;
			Result.MeshTri = HitTri;
			Result.MeshBarys = *((FVector*)&HitBarys);
			Result.MeshTexture = TempTris[HitTri].texture ? (UTexture*)(TempTris[HitTri].texture->imagePtr) : NULL;

			VVec2 UV = *TempTris[HitTri].texUV[0] * Result.MeshBarys.X +
						 *TempTris[HitTri].texUV[1] * Result.MeshBarys.Y +
						 *TempTris[HitTri].texUV[2] * Result.MeshBarys.Z;
			Result.PointUV.X = UV.x;
			Result.PointUV.Y = UV.y;
		}

		Mark.Pop();
		return(TraceRes==0);
	}
}

FBox UDukeMeshInstance::GetRenderBoundingBox(const AActor* Owner, UBOOL Exact)
{
	// replace for accurate bounding box with respect to current bone bounding boxes
	UMesh* Mesh = GetMesh();
	if (!Mesh)
		return(FBox());
	return(Mesh->GetRenderBoundingBox(Owner, Exact));
}

/*
	UMeshInstance
	Bone intrinsics specific to DukeMeshes
*/
void UMeshInstance::execMeshToWorldLocation( FFrame& Stack, RESULT_DECL )
{

	P_GET_VECTOR(InLocation);
	P_GET_UBOOL_OPTX(bFromStd,0);
	P_FINISH;

	UDukeMeshInstance* dmi = Cast<UDukeMeshInstance>(this);
	if (!dmi || !dmi->Actor || !dmi->Mac)
	{
		*(FVector*)Result = InLocation;
		return;
	}
	if (bFromStd)
		InLocation = InLocation.ToUnr();
	*(FVector*)Result = (InLocation - dmi->Mac->mDukeOrigin).TransformPointBy(GetBasisCoords(GMath.UnitCoords));

}
IMPLEMENT_FUNCTION( UMeshInstance, INDEX_NONE, execMeshToWorldLocation );

void UMeshInstance::execWorldToMeshLocation( FFrame& Stack, RESULT_DECL )
{

	P_GET_VECTOR(InLocation);
	P_GET_UBOOL_OPTX(bToStd,0);
	P_FINISH;

	UDukeMeshInstance* dmi = Cast<UDukeMeshInstance>(this);
	if (!dmi || !dmi->Actor || !dmi->Mac)
	{
		*(FVector*)Result = InLocation;
		return;
	}
	*(FVector*)Result = InLocation.TransformPointBy((GetBasisCoords(GMath.UnitCoords)).Transpose()) + dmi->Mac->mDukeOrigin;
	if (bToStd)
		*(FVector*)Result = (*(FVector*)Result).ToStd();

}
IMPLEMENT_FUNCTION( UMeshInstance, INDEX_NONE, execWorldToMeshLocation );

void UMeshInstance::execMeshToWorldRotation( FFrame& Stack, RESULT_DECL )
{

	P_GET_ROTATOR(InRotation);
	P_FINISH;

	UDukeMeshInstance* dmi = Cast<UDukeMeshInstance>(this);
	if (!dmi || !dmi->Actor || !dmi->Mac)
	{
		*(FRotator*)Result = InRotation;
		return;
	}
	FCoords MeshCoords = GetBasisCoords(GMath.UnitCoords);
	MeshCoords = MeshCoords / InRotation;
	MeshCoords = MeshCoords.Transpose();
	*(FRotator*)Result = MeshCoords.OrthoRotation();

}
IMPLEMENT_FUNCTION( UMeshInstance, INDEX_NONE, execMeshToWorldRotation );

void UMeshInstance::execWorldToMeshRotation( FFrame& Stack, RESULT_DECL )
{

	P_GET_ROTATOR(InRotation);
	P_FINISH;

	UDukeMeshInstance* dmi = Cast<UDukeMeshInstance>(this);
	if (!dmi || !dmi->Actor || !dmi->Mac)
	{
		*(FRotator*)Result = InRotation;
		return;
	}
	FCoords MeshCoords = GetBasisCoords(GMath.UnitCoords);
	MeshCoords = MeshCoords / InRotation;
	*(FRotator*)Result = MeshCoords.OrthoRotation();

}
IMPLEMENT_FUNCTION( UMeshInstance, INDEX_NONE, execWorldToMeshRotation );

void UMeshInstance::execBoneFindNamed( FFrame& Stack, RESULT_DECL )
{

	P_GET_NAME(BoneName);
	P_FINISH;

	UDukeMeshInstance* dmi = Cast<UDukeMeshInstance>(this);
	if (!dmi || !dmi->Mac)
	{
		*(INT*)Result = 0;
		return;
	}
	CMacBone* bone = dmi->Mac->FindBone(appToAnsi(*BoneName));
	*(INT*)Result = (INT)bone;

}
IMPLEMENT_FUNCTION( UMeshInstance, INDEX_NONE, execBoneFindNamed );

void UMeshInstance::execBoneGetName( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(BoneHandle);
	P_FINISH;

	CMacBone* bone = (CMacBone*)BoneHandle;
	if (!bone)
	{
		*(FName*)Result = NAME_None;
		return;
	}
	*(FName*)Result = FName(appFromAnsi(*bone->mSklBone->name));

}
IMPLEMENT_FUNCTION( UMeshInstance, INDEX_NONE, execBoneGetName );

void UMeshInstance::execBoneGetParent( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(BoneHandle);
	P_FINISH;

	CMacBone* bone = (CMacBone*)BoneHandle;
	if (!bone)
	{
		*(INT*)Result = 0;
		return;
	}
	*(INT*)Result = (INT)(bone->mParent);

}
IMPLEMENT_FUNCTION( UMeshInstance, INDEX_NONE, execBoneGetParent );

void UMeshInstance::execBoneGetChildCount( FFrame& Stack, RESULT_DECL )
{
	
	P_GET_INT(BoneHandle);
	P_FINISH;

	CMacBone* bone = (CMacBone*)BoneHandle;
	if (!bone)
	{
		*(INT*)Result = 0;
		return;
	}
	INT count = 0;
	for (CMacBone* b = bone->mFirstChild; b; b = b->mNextSibling)
		count++;
	*(INT*)Result = count;
	
}
IMPLEMENT_FUNCTION( UMeshInstance, INDEX_NONE, execBoneGetChildCount );

void UMeshInstance::execBoneGetChild( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(BoneHandle);
	P_GET_INT(ChildIndex);
	P_FINISH;

	CMacBone* bone = (CMacBone*)BoneHandle;
	if (!bone)
	{
		*(INT*)Result = 0;
		return;
	}
	INT count = 0;
	for (CMacBone* b = bone->mFirstChild; b && (count < ChildIndex); b = b->mNextSibling)
		count++;
	*(INT*)Result = (INT)b;
	
}
IMPLEMENT_FUNCTION( UMeshInstance, INDEX_NONE, execBoneGetChild );

void UMeshInstance::execBoneGetTranslate( FFrame& Stack, RESULT_DECL )
{
	P_GET_INT(BoneHandle);
	P_GET_UBOOL_OPTX(bAbsolute,0);
	P_GET_UBOOL_OPTX(bDefault,0);
	P_GET_FLOAT_OPTX(fScale,1.f);
	P_FINISH;

	CMacBone* bone = (CMacBone*)BoneHandle;
	if (!bone)
	{
		*(FVector*)Result = FVector(0,0,0);
		return;
	}
	VCoords3 c;
	if (!bDefault)
	{
		c = bone->GetCoords(bAbsolute!=0);
	}
	else
	{
		c = bone->mSklBone->baseCoords;
		if (bAbsolute)
		{
			for (CMacBone* b = bone->mParent; b; b = b->mParent)
				c <<= b->mSklBone->baseCoords;
		}
	}
	c *= fScale;
	FVector v(*(FVector*)&c.t);
	*(FVector*)Result = v.ToUnr();

}
IMPLEMENT_FUNCTION( UMeshInstance, INDEX_NONE, execBoneGetTranslate );

void UMeshInstance::execBoneGetRotate( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(BoneHandle);
	P_GET_UBOOL_OPTX(bAbsolute,0);
	P_GET_UBOOL_OPTX(bDefault,0);
	P_FINISH;

	CMacBone* bone = (CMacBone*)BoneHandle;
	if (!bone)
	{
		*(FRotator*)Result = FRotator(0,0,0);
		return;
	}
	VCoords3 c;
	if (!bDefault)
	{
		c = bone->GetCoords(bAbsolute!=0);
	}
	else
	{
		c = bone->mSklBone->baseCoords;
		if (bAbsolute)
		{
			for (CMacBone* b = bone->mParent; b; b = b->mParent)
				c <<= b->mSklBone->baseCoords;
		}
	}
	FCoords fc(FVector(0,0,0), *((FVector*)&c.r.vX), *((FVector*)&c.r.vY), *((FVector*)&c.r.vZ));
	fc = fc.ToUnr();
	*(FRotator*)Result = fc.OrthoRotation();

}
IMPLEMENT_FUNCTION( UMeshInstance, INDEX_NONE, execBoneGetRotate );
void UMeshInstance::execBoneGetScale( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(BoneHandle);
	P_GET_UBOOL_OPTX(bAbsolute,0);
	P_GET_UBOOL_OPTX(bDefault,0);
	P_FINISH;

	CMacBone* bone = (CMacBone*)BoneHandle;
	if (!bone)
	{
		*(FVector*)Result = FVector(1,1,1);
		return;
	}
	VCoords3 c;
	if (!bDefault)
	{
		c = bone->GetCoords(bAbsolute!=0);
	}
	else
	{
		c = bone->mSklBone->baseCoords;
		if (bAbsolute)
		{
			for (CMacBone* b = bone->mParent; b; b = b->mParent)
				c <<= b->mSklBone->baseCoords;
		}
	}
	FVector v(*(FVector*)&c.s);
	v = v.ToUnr();
	v.Y = -v.Y;
	*(FVector*)Result = v;

}
IMPLEMENT_FUNCTION( UMeshInstance, INDEX_NONE, execBoneGetScale );

void UMeshInstance::execBoneSetTranslate( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(BoneHandle);
	P_GET_VECTOR(Translate);
	P_GET_UBOOL_OPTX(bAbsolute, 0);
	P_FINISH;

	CMacBone* bone = (CMacBone*)BoneHandle;
	if (!bone)
	{
		*(DWORD*)Result = 0;
		return;
	}
	VCoords3 c(bone->GetCoords(bAbsolute!=0));
	FVector v(Translate.ToStd());
	c.t = *(VVec3*)&v;
	bone->SetCoords(c, bAbsolute!=0);
	*(DWORD*)Result = 1;

}
IMPLEMENT_FUNCTION( UMeshInstance, INDEX_NONE, execBoneSetTranslate );

void UMeshInstance::execBoneSetRotate( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(BoneHandle);
	P_GET_ROTATOR(Rotate);
	P_GET_UBOOL_OPTX(bAbsolute, 0);
	P_GET_UBOOL_OPTX(bRelCurrent, 0);
	P_FINISH;

	CMacBone* bone = (CMacBone*)BoneHandle;
	if (!bone)
	{
		*(DWORD*)Result = 0;
		return;
	}

	VCoords3 c(bone->GetCoords(bAbsolute!=0));
	FCoords fc = GMath.UnitCoords / Rotate;
	fc = fc.ToStd();
	VAxes3 a;
	a.vX = *(VVec3*)&fc.XAxis;
	a.vY = *(VVec3*)&fc.YAxis;
	a.vZ = *(VVec3*)&fc.ZAxis;
	if (!bRelCurrent)
		c.r = a;
	else
		c.r = a << c.r;
	bone->SetCoords(c, bAbsolute!=0);
	*(DWORD*)Result = 1;

}
IMPLEMENT_FUNCTION( UMeshInstance, INDEX_NONE, execBoneSetRotate );

void UMeshInstance::execBoneSetScale( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(BoneHandle);
	P_GET_VECTOR(Scale);
	P_GET_UBOOL_OPTX(bAbsolute, 0);
	P_FINISH;

	CMacBone* bone = (CMacBone*)BoneHandle;
	if (!bone)
	{
		*(DWORD*)Result = 0;
		return;
	}
	VCoords3 c(bone->GetCoords(bAbsolute!=0));
	FVector v(Scale);
	v.Y = -v.Y;
	v = v.ToStd();
	c.s = *(VVec3*)&v;
	bone->SetCoords(c, bAbsolute!=0);
	*(DWORD*)Result = 1;
	
}

IMPLEMENT_FUNCTION( UMeshInstance, INDEX_NONE, execBoneSetScale );

void UMeshInstance::execGetBounds( FFrame& Stack, RESULT_DECL )
{
	P_GET_VECTOR_REF( Min );
    P_GET_VECTOR_REF( Max );
	P_FINISH;

	UDukeMeshInstance* dmi = Cast<UDukeMeshInstance>(this);
	if (!dmi || !dmi->Mac)
	{
		return;
	}

    *Min = dmi->Mac->mDukeBounds[0];
	*Max = dmi->Mac->mDukeBounds[1];
}

IMPLEMENT_FUNCTION( UMeshInstance, INDEX_NONE, execGetBounds );

/*
	UDukeMesh
*/
IMPLEMENT_CLASS(UDukeMesh);

UDukeMesh::UDukeMesh()
{
}
void UDukeMesh::Serialize(FArchive& Ar)
{
	Super::Serialize(Ar);

	if (Ar.IsLoading() && (Ar.MergeVer() > 63))
	{		
		ConvertDukeMesh(this, Ar);
		return;
	}

	Ar << ConfigName;
}

FBox UDukeMesh::GetRenderBoundingBox(const AActor* Owner, UBOOL Exact)
{
	
	FBox Bound = BoundingBox;

	UDukeMeshInstance* Inst = Cast<UDukeMeshInstance>(GetInstance((AActor*)Owner));
	if (!Inst || !Inst->Mac)
		return(Bound);

	if ( Owner->bIsRenderActor && ((ARenderActor*) Owner)->bCollisionForRenderBox )
		return GetCollisionBoundingBox( Owner );

	Bound.Min = Inst->Mac->mDukeBounds[0];
	Bound.Max = Inst->Mac->mDukeBounds[1];

	// Transform Bound by owner's scale and origin.
//	Bound = FBox( Inst->Mac->mDukeScale*Owner->DrawScale*(Bound.Min - Inst->Mac->mDukeOrigin), Inst->Mac->mDukeScale*Owner->DrawScale*(Bound.Max - Inst->Mac->mDukeOrigin) ).ExpandBy(1.0);
	Bound = FBox( Inst->Mac->mDukeScale*Owner->DrawScale*(Bound.Min - Inst->Mac->mDukeOrigin), Inst->Mac->mDukeScale*Owner->DrawScale*(Bound.Max - Inst->Mac->mDukeOrigin) );
//	Bound.Min *= Owner->DrawScale * Inst->Mac->mDukeScale;
//	Bound.Max *= Owner->DrawScale * Inst->Mac->mDukeScale;
	FVector HeightAdjust = Owner->bMeshLowerByCollision ? FVector(0, 0, -Owner->CollisionHeight) : FVector(0, 0, -Owner->MeshLowerHeight);
	// Andy, this is a message from Brandon.  When you make this an actor method, make a Pawn version that adjusts
	// the height by 5 units.
	if ( Owner->IsA(APawn::StaticClass()) )
		HeightAdjust.Z -= 5;
#if 0	
	FCoords Coords = GMath.UnitCoords / HeightAdjust / Inst->Mac->mDukeRotOrigin / Owner->Rotation;
	
	Coords.Origin += Owner->Location + Owner->PrePivot /*- Inst->Mac->mDukeOrigin*/;
	return Bound.TransformBy( Coords.Transpose() );
#else
	FCoords Coords = GMath.UnitCoords * (Owner->Location+Owner->PrePivot) * Owner->Rotation * HeightAdjust * Inst->Mac->mDukeRotOrigin;
	return Bound.TransformBy( Coords);
#endif
}

UClass* UDukeMesh::GetInstanceClass()
{
	return(UDukeMeshInstance::StaticClass());
}

UBOOL UDukeMesh::LineCheck(FCheckResult& Result, AActor* Owner, FVector End, FVector Start, FVector Extent, DWORD ExtraNodeFlags, UBOOL bMeshAccurate)
{
	return UPrimitive::LineCheck( Result, Owner, End, Start, Extent, ExtraNodeFlags, bMeshAccurate );
}

/*
	AMeshDecal
*/
void AMeshDecal::execBuildDecal( FFrame& Stack, RESULT_DECL )
{

	P_GET_OBJECT(AActor, InActor);
	P_GET_OBJECT(UTexture, InTexture);
	P_GET_INT(InTri);
	P_GET_VECTOR(InBaryCenter);
	P_GET_FLOAT(InRollRadians);
	P_GET_FLOAT(InDimU);
	P_GET_FLOAT(InDimV);
	P_FINISH;

	Texture = NULL;
	Actor = NULL;
	Mesh = NULL;
	Tris.Empty();
	Tris.Shrink();
	
	// an actor and texture are required
	if (!InTexture || !InActor || !InActor->Mesh)
	{
		*(INT*)Result = 0;
		return;
	}

	// grab the mesh instance
	UDukeMeshInstance* MeshInst = Cast<UDukeMeshInstance>(InActor->GetMeshInstance());
	if (!MeshInst)
	{
		*(INT*)Result = 0;
		return;
	}

	if ((InTri < 0) || (InTri >= (INT)MeshInst->Mac->mGeometry->m_Tris.GetCount()))
	{
		*(INT*)Result = 0;
		return;
	}

	// get vertices and triangles
	FMemMark Mark(GMem);
	SMacTri* TempTris = New<SMacTri>(GMem, MeshInst->Mac->mGeometry->m_Tris.GetCount());
	VVec3* TempVerts = New<VVec3>(GMem, MeshInst->Mac->mGeometry->m_Verts.GetCount());
	INT NumTris = MeshInst->Mac->EvaluateTris(1.f, TempTris);
	mesh_GetFrameNoTransform = 1;
	INT NumVerts = MeshInst->GetFrame((FVector*)TempVerts, NULL, sizeof(VVec3), GMath.UnitCoords, 1.f);
	mesh_GetFrameNoTransform = 0;

	// pull out vertices of base triangle
	VVec3 v[3];
	for (INT i=0;i<3;i++)
		v[i] = TempVerts[MeshInst->Mac->mGeometry->m_Tris[InTri].edgeRing[i]->tailVertex - &MeshInst->Mac->mGeometry->m_Verts[0]];

	// compute coords using this base
	VCoords3 baseCoords;
	baseCoords.t = v[0]*InBaryCenter.X + v[1]*InBaryCenter.Y + v[2]*InBaryCenter.Z;
	baseCoords.r.vZ = (v[2]-v[0]) ^ (v[1]-v[0]);
	baseCoords.r.vZ.Normalize();
	baseCoords.r.vY = v[0] - baseCoords.t;
	baseCoords.r.vY.Normalize();
	baseCoords.r.vX = baseCoords.r.vY ^ baseCoords.r.vZ;
	baseCoords.r.vX.Normalize();
	//VQuat3 q; q.AxisAngle(VVec3(0,0,1), InRollRadians);
	//baseCoords.f <<= q;
	VCoords3 deltaCoords = /*VCoords3() & */baseCoords;

	// compute which triangles fall into the rectangle of the decal and add them
	for (i=0;i<NumTris;i++)
	{
		SMacTri* Tri = &TempTris[i];
		for (DWORD j=0;j<3;j++)
		{
			v[j] = TempVerts[Tri->vertIndex[j]];
			v[j] >>= deltaCoords;
			///*
			v[j].x /= InDimU;
			v[j].y /= -InDimV;
			v[j].x += 0.5f;
			v[j].y += 0.5f;
			//*/
		}
		
		if ((v[0].x<0.f) && (v[1].x<0.f) && (v[2].x<0.f)) continue;
		if ((v[0].y<0.f) && (v[1].y<0.f) && (v[2].y<0.f)) continue;
		if ((v[0].x>1.f) && (v[1].x>1.f) && (v[2].x>1.f)) continue;
		if ((v[0].y>1.f) && (v[1].y>1.f) && (v[2].y>1.f)) continue;

		FMeshDecalTri* DecalTri = &Tris(Tris.Add());
		DecalTri->TriIndex = i;
		for (j=0;j<3;j++)
		{
			DecalTri->TexU[j] = v[j].x;
			DecalTri->TexV[j] = v[j].y;
		}
	}

	// return generated triangles
	if (Tris.Num())
	{
		Texture = InTexture;
		Actor = InActor;
		Mesh = InActor->Mesh;
	}
	
	*(INT*)Result = Tris.Num();
	
	Mark.Pop();
	
}
//IMPLEMENT_FUNCTION( AMeshDecal, INDEX_NONE, execBuildDecal );


//****************************************************************************
//**
//**    END MODULE DNMESH.CPP
//**
//****************************************************************************

