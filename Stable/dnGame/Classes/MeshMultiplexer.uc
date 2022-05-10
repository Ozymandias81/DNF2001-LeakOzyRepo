//=============================================================================
// MeshMultiplexer.
//
//  NJS: original blink settings:
//	BlinkRateBase=0.6
//	BlinkRateRandom=5.0
//	BlinkDurationBase=0.300000
//	BlinkDurationRandom=0.050000
//	BlinkEyelidPosition=(X=1.000000,Y=-0.100000,Z=0.000000)
//	BlinkChangeTime=0.250000
//
//=============================================================================
class MeshMultiplexer expands Triggers;

var() mesh Meshes[32] 	?("Meshes to cycle through.");
var   int  MeshCount	?("Number of valid meshes in the above.");
var   int  CurrentMesh  ?("The currently mesh index.");

var() name Sequences[32];
var   int  SequenceCount;
var   int  CurrentSequence;

var() sound Sounds[32];
var   int   SoundCount;
var   int   CurrentSound;

var() struct SSoundSyncScales
{
	var () float Jaw;
	var () float MouthCorner;
	var () float Lip_U;
	var () float Lip_L;
	
} SoundSyncScales[32];

var() name  NextMeshTag;
var   actor NextMeshActor;
var() name  PreviousMeshTag;
var   actor PreviousMeshActor;
var() name  NextSequenceTag;
var   actor NextSequenceActor;
var() name  PreviousSequenceTag;
var   actor PreviousSequenceActor; 
var() name  NextSoundTag;
var   actor NextSoundActor;
var() name  PreviousSoundTag;
var   actor PreviousSoundActor; 

//		if(Tags[i]!='')
//			tr=Spawn(class'TriggerForward',self,Tags[i]);

var bool bHeadBlownOff;
var transient bool bBlinked;
var float LastBlinkTime;
var float BlinkTimer;
var float CurrentBlinkAlpha;

var() float  BlinkRateBase 				?("Base rate of eye blinking.\nFinal rate is randomly chosen between BlinkRateBase and BlinkRateBase+BlinkRateRandom");
var() float  BlinkRateRandom 			?("Random blink rate adjustment above base.\nFinal rate is random chosen between BlinkRateBase and BlinkRateBase+BlinkRateRandom");
var() float  BlinkDurationBase 			?("Base duration of eye blinking.\nFinal duration is randomly chosen between BlinkDurationBase and BlinkDurationBase+BlinkDurationRandom");
var() float  BlinkDurationRandom 		?("Random blink duration adjustment above base.\nFinal duration is randomly chosen between BlinkDurationBase and BlinkDurationBase+BlinkDurationRandom");
var() vector BlinkEyelidPosition 		?("Position eyelid is adjusted by at full blink.\nValues are relative to eyelid bone axes");
var() float  BlinkChangeTime 			?("Time in seconds it takes to go between a fully non-blinked and a fully blinked state");

var() struct SMeshBlinkInfo
{
	var() float  BlinkRateBase				?("Base rate of eye blinking.\nFinal rate is randomly chosen between BlinkRateBase and BlinkRateBase+BlinkRateRandom");
	var() float  BlinkRateRandom			?("Random blink rate adjustment above base.\nFinal rate is random chosen between BlinkRateBase and BlinkRateBase+BlinkRateRandom");
	var() float  BlinkDurationBase			?("Base duration of eye blinking.\nFinal duration is randomly chosen between BlinkDurationBase and BlinkDurationBase+BlinkDurationRandom");
	var() float  BlinkDurationRandom		?("Random blink duration adjustment above base.\nFinal duration is randomly chosen between BlinkDurationBase and BlinkDurationBase+BlinkDurationRandom");
	var() vector BlinkEyelidPosition		?("Position eyelid is adjusted by at full blink.\nValues are relative to eyelid bone axes");
	var() float  BlinkChangeTime			?("Time in seconds it takes to go between a fully non-blinked and a fully blinked state");
} MeshBlinkInfo[32];

function PostBeginPlay()
{
	local int index;
	
	for(index=0;index<ArrayCount(MeshBlinkInfo);index++)
	{
		MeshBlinkInfo[index].BlinkRateBase+=BlinkRateBase;
		MeshBlinkInfo[index].BlinkRateRandom+=BlinkRateRandom;
		MeshBlinkInfo[index].BlinkDurationBase+=BlinkDurationBase;
		MeshBlinkInfo[index].BlinkDurationRandom+=BlinkDurationRandom;
		MeshBlinkInfo[index].BlinkEyelidPosition+=BlinkEyelidPosition;
		MeshBlinkInfo[index].BlinkChangeTime+=BlinkChangeTime;

	}

	CurrentMesh=0;
	BlinkTimer = MeshBlinkInfo[CurrentMesh].BlinkRateBase;	

	for(MeshCount=0;MeshCount<ArrayCount(Meshes);MeshCount++)
		if(Meshes[MeshCount]==none)
			break;

	for(SequenceCount=0;SequenceCount<ArrayCount(Sequences);SequenceCount++)
		if(Sequences[SequenceCount]=='')
			break;

	for(SoundCount=0;SoundCount<ArrayCount(Sounds);SoundCount++)
		if(Sounds[SoundCount]==none)
			break;
			
	if(NextMeshTag!='')         NextMeshActor        =Spawn(class'TriggerSelfForward',self,NextMeshTag);
	if(PreviousMeshTag!='')     PreviousMeshActor    =Spawn(class'TriggerSelfForward',self,PreviousMeshTag);
	if(NextSequenceTag!='')     NextSequenceActor    =Spawn(class'TriggerSelfForward',self,NextSequenceTag);
	if(PreviousSequenceTag!='') PreviousSequenceActor=Spawn(class'TriggerSelfForward',self,PreviousSequenceTag);
	if(NextSoundTag!='')        NextSoundActor       =Spawn(class'TriggerSelfForward',self,NextSoundTag);
	if(PreviousSoundTag!='')    PreviousSoundActor  =Spawn(class'TriggerSelfForward',self,PreviousSoundTag);

	Mesh=Meshes[0];
	LoopAnim(Sequences[0]);
}

function NextMesh()
{
	CurrentMesh=(CurrentMesh+1)%MeshCount;
	mesh=Meshes[CurrentMesh];
}

function PreviousMesh()
{
	CurrentMesh--;
	if(CurrentMesh<0) CurrentMesh=MeshCount-1;

	mesh=Meshes[CurrentMesh];	
}

function NextSequence()
{
	CurrentSequence=(CurrentSequence+1)%SequenceCount;
	LoopAnim(Sequences[CurrentSequence]);
}

function PreviousSequence()
{
	CurrentSequence--;
	if(CurrentSequence<0) CurrentSequence=SequenceCount-1;

	LoopAnim(Sequences[CurrentSequence]);
}

function NextSound()
{
	CurrentSound=(CurrentSound+1)%SoundCount;
	PlaySound(Sounds[CurrentSound],,,,,,true);

}

function PreviousSound()
{
	CurrentSound--;
	if(CurrentSound<0) CurrentSound=SoundCount-1;

	PlaySound(Sounds[CurrentSound],,,,,,true);
}

simulated function bool EvalLipSync()
{
    local int bone;
    local MeshInstance minst;
	local rotator r;
    local vector s, t;
	local float f;
	local float scale;
    
	minst = GetMeshInstance();
    if (minst==None)
        return(false);

    // rotate the jaw downward
	bone = minst.BoneFindNamed('Jaw');
	if (bone!=0)
	{
		scale=SoundSyncScales[CurrentMesh].Jaw;
		if(scale==0) scale=1.0;
		
		r = minst.BoneGetRotate(bone, false);
		r.Pitch = MonitorSoundLevel * -2048.0 * Scale;
		minst.BoneSetRotate(bone, r, false);
	}

	// scale in the mouth corner a bit
    bone = minst.BoneFindNamed('MouthCorner');
	if (bone!=0)
	{
		scale=SoundSyncScales[CurrentMesh].MouthCorner;
		if(scale==0) scale=1.0;

		f = 1.0 - MonitorSoundLevel * 2.0 * Scale;
		s.x = f; s.y = f; s.z = f;
		minst.BoneSetScale(bone, s, true);
	}

	// move the upper lip up a little
    bone = minst.BoneFindNamed('Lip_U');
    if (bone!=0)
	{
		scale=SoundSyncScales[CurrentMesh].Lip_U;
		if(scale==0) scale=1.0;

	    t = minst.BoneGetTranslate(bone, false, true);
		t.x += 0.25 * Scale * MonitorSoundLevel;
		minst.BoneSetTranslate(bone, t, false);
	}

	// same with the lower lip
    bone = minst.BoneFindNamed('Lip_L');
    if (bone!=0)
	{
		scale=SoundSyncScales[CurrentMesh].Lip_L;
		if(scale==0) scale=1.0;

		t = minst.BoneGetTranslate(bone, false, true);
		t.x += -0.5 *Scale  * MonitorSoundLevel;
		minst.BoneSetTranslate(bone, t, false);
	}

	return(true);
}

simulated function bool EvalBlinking()
{
    local int bone;
    local MeshInstance minst;
    local vector t;
	local float deltaTime;
    
	minst = GetMeshInstance();
    if (minst==None)
        return(false);

	if (MeshBlinkInfo[CurrentMesh].BlinkDurationBase <= 0.0)
		return(false);

	deltaTime = Level.TimeSeconds - LastBlinkTime;
	LastBlinkTime = Level.TimeSeconds;

	BlinkTimer -= deltaTime;
	if (BlinkTimer <= 0.0)
	{
		if (!bBlinked)
		{
			bBlinked = true;
			BlinkTimer = MeshBlinkInfo[CurrentMesh].BlinkDurationBase + FRand()*MeshBlinkInfo[CurrentMesh].BlinkDurationRandom;
		}
		else
		{
			bBlinked = false;
			BlinkTimer = MeshBlinkInfo[CurrentMesh].BlinkRateBase + FRand()*MeshBlinkInfo[CurrentMesh].BlinkRateRandom;
		}
	}

	if (MeshBlinkInfo[CurrentMesh].BlinkChangeTime <= 0.0)
	{
		if (bBlinked)
			CurrentBlinkAlpha = 1.0;
		else
			CurrentBlinkAlpha = 0.0;
	}
	else
	{
		if (bBlinked)
		{
			CurrentBlinkAlpha += deltaTime/MeshBlinkInfo[CurrentMesh].BlinkChangeTime;
			if (CurrentBlinkAlpha > 1.0)
				CurrentBlinkAlpha = 1.0;
		}
		else
		{
			CurrentBlinkAlpha -= deltaTime/MeshBlinkInfo[CurrentMesh].BlinkChangeTime;
			if (CurrentBlinkAlpha < 0.0)
				CurrentBlinkAlpha = 0.0;
		}
	}

	// blink the left eye
	bone = minst.BoneFindNamed('Eyelid_L');
	if (bone!=0)
	{
		t = minst.BoneGetTranslate(bone, false, true);
		t -= MeshBlinkInfo[CurrentMesh].BlinkEyelidPosition*CurrentBlinkAlpha;
		minst.BoneSetTranslate(bone, t, false);
	}

	// blink the right eye
	bone = minst.BoneFindNamed('Eyelid_R');
	if (bone!=0)
	{
		t = minst.BoneGetTranslate(bone, false, true);
		t -= MeshBlinkInfo[CurrentMesh].BlinkEyelidPosition*CurrentBlinkAlpha;
		minst.BoneSetTranslate(bone, t, false);
	}

	// TEST... move brow
	bone = minst.BoneFindNamed('Brow');
	if (bone!=0)
	{
		t = minst.BoneGetTranslate(bone, false, true);
//		if (Health < Default.Health)
//		{
//			if (Health < int(Default.Health * 0.3))
				t += MeshBlinkInfo[CurrentMesh].BlinkEyelidPosition*0.5; // surprise and alarm brow
//			else
//				t -= MeshBlinkInfo[CurrentMesh].BlinkEyelidPosition*0.75; // angry brow
//		}
		minst.BoneSetTranslate(bone, t, false);
	}

	// TEST... mouth corner brow
	bone = minst.BoneFindNamed('MouthCorner');
	if (bone!=0)
	{
		t = minst.BoneGetTranslate(bone, false, true);
//		if (Health < Default.Health)
//		{
////			if (Health < int(Default.Health * 0.3))
	//			t -= MeshBlinkInfo[CurrentMesh].BlinkEyelidPosition*0.5; // frowny
	//		else
				t += MeshBlinkInfo[CurrentMesh].BlinkEyelidPosition*0.5; // smiley
	//	}
		minst.BoneSetTranslate(bone, t, false);
	}

	return(true);
}
simulated function bool OnEvalBones(int channel)
{
    if (channel==3)
	{
		EvalBlinking();
		EvalLipSync();
		return(true);
	}

	return(Super.OnEvalBones(channel));
}

function Trigger( actor Other, pawn EventInstigator )
{
	if(Other==NextMeshActor) 			  NextMesh();
	else if(Other==PreviousMeshActor)     PreviousMesh();
	else if(Other==NextSequenceActor)	  NextSequence();
	else if(Other==PreviousSequenceActor) PreviousSequence();
	else if(Other==NextSoundActor)		  NextSound();
	else if(Other==PreviousSoundActor)    PreviousSound();
}

defaultproperties
{
     Sequences(0)=T_IdleSwatFly
     Sequences(1)=A_Run
     Sequences(2)=T_IdleLoadGun
     Sequences(3)=A_Death_Hitback2
     NextMeshTag=NextMesh
     PreviousMeshTag=PreviousMesh
     NextSequenceTag=NextSequence
     PreviousSequenceTag=PreviousSequence
     NextSoundTag=NextSound
     PreviousSoundTag=PreviousSound
     DrawType=DT_Mesh
     Texture=None
     Mesh=DukeMesh'c_characters.Dam_Guide'
	 BlinkRateBase=0.6
	 BlinkRateRandom=5.0
	 BlinkDurationBase=0.300000
	 BlinkDurationRandom=0.050000
	 BlinkEyelidPosition=(X=1.000000,Y=-0.100000,Z=0.000000)
	 BlinkChangeTime=0.250000
}
