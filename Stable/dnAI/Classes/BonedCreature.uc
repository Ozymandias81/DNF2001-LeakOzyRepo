/*=============================================================================
	BonedCreature
	Author: Jess Crable

=============================================================================*/
class BonedCreature expands Creature
abstract;


struct SCreatureTrackingInfo
{
	var() float		TrackTimer; // variable-used timer counted down to zero at tick time
	var() rotator	Rotation; // current rotation of the tracking angle
	var() rotator	DesiredRotation; // desired rotation of the tracking angle
	var() rotator	RotationRate; // maximum rate of rotation toward desired
	var() rotator	RotationConstraints; // rotation limits to clamp to
	var() float		Weight; // current weight of tracking rotation against default forward angle, 1.0 is full tracking, 0.0 is no tracking
	var() float		DesiredWeight; // desired weight of tracking angle
	var() float		WeightRate; // maximum rate of change toward desired weight
};
var SCreatureTrackingInfo EyeTracking;
var SCreatureTrackingInfo HeadTracking;
var bool bNoLipSync;
var bool bHeadTrackTimer;
var float HeadTrackTimer;

function Tentacle CreateTentacle( vector MountOrigin, rotator MountAngles, name MountMeshItem, optional actor Target )
{
	local Tentacle T;
	T = Spawn( class'Tentacle', Self );
	
	if( Target != None )
	{
		T.AttachActorToParent( target, true, false );
	}
	else
	{
		T.AttachActorToParent( self, true, true );
	}
	T.MountOrigin = MountOrigin;
	T.MountAngles = MountAngles;
	T.MountMeshItem = MountMeshItem;
	T.MountType = MOUNT_MeshBone;
	T.SetPhysics( PHYS_MovingBrush );
	
	if( T != None )
	{
		return T;
	}
}


function TickTracking(float inDeltaTime)
{
	local rotator r;
	//EvalHeadLook();
	// update head tracking
	

	if( HeadTrackingActor != None )
	{
		HeadTracking.DesiredWeight = 1.0;
	}
	else
	{
		HeadTracking.DesiredWeight = 1.0;
	}
	if (HeadTracking.TrackTimer <= 0.0 && FRand() < 0.25 && HeadTrackingActor == None )
	{
		HeadTracking.TrackTimer = 2.5 + FRand()*1.5;
//		HeadTracking.DesiredRotation = RotRand();
	//	HeadTracking.DesiredRotation.Pitch = 0;
		HeadTracking.DesiredRotation.Roll = 0;
	}

	if (HeadTracking.TrackTimer > 0.0)
	{
		HeadTracking.TrackTimer -= inDeltaTime;
		if (HeadTracking.TrackTimer < 0.0)
			HeadTracking.TrackTimer = 0.0;
	}
/*
	if( HeadTracking.TrackTimer <= 0.0 )
	{
		log( "Initializing" );
		HeadTracking.TrackTimer = 0.5 + FRand() * 1.5;
		HeadTracking.DesiredRotation = RotRand();
		//HeadTracking.DesiredRotation.Pitch = 0;
		HeadTracking.DesiredRotation.Roll = 0;
	}
*/
	HeadTracking.Weight = UpdateRampingFloat(HeadTracking.Weight, HeadTracking.DesiredWeight, HeadTracking.WeightRate*inDeltaTime);
	r = ClampHeadRotation(HeadTracking.DesiredRotation);
	HeadTracking.Rotation.Pitch = FixedTurn(HeadTracking.Rotation.Pitch, r.Pitch, int(HeadTracking.RotationRate.Pitch * inDeltaTime));
	HeadTracking.Rotation.Yaw = FixedTurn(HeadTracking.Rotation.Yaw, r.Yaw, int(HeadTracking.RotationRate.Yaw * inDeltaTime));
	HeadTracking.Rotation.Roll = FixedTurn(HeadTracking.Rotation.Roll, r.Roll, int(HeadTracking.RotationRate.Roll * inDeltaTime));
	HeadTracking.Rotation = ClampHeadRotation(HeadTracking.Rotation);

	// update eye tracking
	if (EyeTracking.TrackTimer > 0.0)
	{
		EyeTracking.TrackTimer -= inDeltaTime;
		if (EyeTracking.TrackTimer < 0.0)
			EyeTracking.TrackTimer = 0.0;
	}
	EyeTracking.Weight = UpdateRampingFloat(EyeTracking.Weight, EyeTracking.DesiredWeight, EyeTracking.WeightRate*inDeltaTime);
	r = EyeTracking.DesiredRotation;
	EyeTracking.Rotation.Pitch = FixedTurn(EyeTracking.Rotation.Pitch, r.Pitch, int(EyeTracking.RotationRate.Pitch * inDeltaTime));
	EyeTracking.Rotation.Yaw = FixedTurn(EyeTracking.Rotation.Yaw, r.Yaw, int(EyeTracking.RotationRate.Yaw * inDeltaTime));
	EyeTracking.Rotation.Roll = FixedTurn(EyeTracking.Rotation.Roll, r.Roll, int(EyeTracking.RotationRate.Roll * inDeltaTime));
	EyeTracking.Rotation = ClampEyeRotation(EyeTracking.Rotation);

	// temporary - random target testing

	if (HeadTrackingActor!=None)
	{
		HeadTrackingLocation = HeadTrackingActor.Location;
		HeadTracking.DesiredRotation = Normalize(rotator(Normal(HeadTrackingLocation - Location)));
		//HeadTracking.DesiredRotation.Pitch = 0;
		HeadTracking.DesiredRotation.Roll = 0;
	}
	
	if (EyeTracking.TrackTimer <= 0.0)
	{
		EyeTracking.TrackTimer = 0.5 + FRand()*1.5;
		EyeTracking.DesiredRotation = Normalize(Rotation + rot(0, int(FRand()*16384.0 - 8192.0), 0));
		EyeTracking.DesiredRotation.Pitch = 0;
		EyeTracking.DesiredRotation.Roll = 0;
	}
	//EyeTracking.DesiredRotation.Yaw = HeadTracking.DesiredRotation.Yaw;
	//EyeTracking.DesiredRotation.Yaw = Rand( 256 );
	//EyeTracking.DesiredRotation = RotRand();
	//log( "EyeTracking desired rotation yaw: "$EyeTracking.DesiredRotation.yaw );
	//EyeTracking.DesiredRotation.Pitch = 0;
	//EyeTracking.DesiredRotation.Roll = 0;
}

simulated function bool EvalHeadLook()
{
    local int bone;
    local MeshInstance minst;
	local rotator r;
	local float f;
	
	local rotator EyeLook, HeadLook, BodyLook;
	local rotator LookRotation;
	local float HeadFactor, ChestFactor, AbdomenFactor;
	local float PitchCompensation;
    
	local int RandHeadRot;

	if( HeadTrackingActor != None )
	{
		HeadTracking.DesiredWeight = 1.0;
	}
	else
	{
		HeadTracking.DesiredWeight = 0.5;
	}

	minst = GetMeshInstance();
    if (minst==None)
        return(false);

	if( HeadTrackingActor == None )
	{
		//HeadTracking.DesiredRotation = Rotation;
	}
	//HeadLook = minst.WorldToMeshRotation(HeadTracking.Rotation);
//	if( HeadTrackingActor != None )
//	{
//	if( bHeadInitialized )
//	{
//		HeadLook = rot( 0, 0, 0 ) - Rotation;
//		bHeadInitialized = false;
//	}
//	else
	HeadLook = HeadTracking.Rotation - Rotation;
	//HeadLook = rotator( VRand() ) - Rotation;
	HeadLook = Normalize(HeadLook);
	
	HeadLook = Slerp(HeadTracking.Weight, rot(0,0,0), HeadLook);

//	}
//	else
	//r = Normalize(minst.WorldToMeshRotation(ClampHeadRotation(HeadTracking.DesiredRotation)));
	r = Normalize(ClampHeadRotation(HeadTracking.DesiredRotation) - Rotation);
	//BroadcastMessage("RenderDesired: "$r$" RenderCurrent: "$HeadLook);
	
	//EyeLook = minst.WorldToMeshRotation(EyeTracking.Rotation);
	//EyeLook = EyeTracking.Rotation - Rotation;
	
//	if( HeadTrackingActor == None )
//	{
//		EyeTracking.DesiredWeight = 0.0;
//		EyeTracking.WeightRate = 0.0;
//	}
//	else
//		EnableEyeTracking( true );

	// Move the eyes to follow an item of interest.
//	if( HeadTrackingActor == None )
//	{
	EyeLook = EyeTracking.Rotation - Rotation;
	EyeLook = Normalize(EyeLook - HeadLook);
	EyeLook.Yaw *= 0.125; // Minimal eye movements cover large ground, so scale back rotation.
	EyeLook = Slerp(EyeTracking.Weight, rot(0,0,0), EyeLook);
//	}
//	else
//	{
	//EyeLook = Normalize( HeadTracking.DesiredRotation - Rotation );
	//EyeLook = Normalize(EyeLook - HeadLook);
//	EyeLook.Yaw *= 0.125; // minimal eye movements cover large ground, so scale back rotation
//	EyeLook = Slerp(EyeTracking.Weight, rot(0,0,0), EyeLook);
//}

	LookRotation = EyeLook;
	bone = minst.BoneFindNamed('Pupil_L');
	if (bone!=0)
	{			
		r = LookRotation;
		r = rot(r.Pitch,0,-r.Yaw);
		minst.BoneSetRotate(bone, r, true, true);
	}
	bone = minst.BoneFindNamed('Pupil_R');
	if (bone!=0)
	{
		r = LookRotation;
		r = rot(r.Pitch,0,-r.Yaw);
		minst.BoneSetRotate(bone, r, true, true);
	}

//	if (true ) // full body head look
//	{
		LookRotation = HeadLook;
		HeadFactor = 0.65;
				ChestFactor = 0.45;
			AbdomenFactor = 0.35;
			PitchCompensation = 0.0;

		/*HeadFactor = 0.15;
		ChestFactor = 0.45;
		AbdomenFactor = 0.40;
		PitchCompensation = 0.25;//0.25;*/

		bone = minst.BoneFindNamed('Head');
		if (bone!=0)
		{
			r = LookRotation;
//			if( FRand() < 0.5 )
			r = rot( r.Pitch * HeadFactor ,0,-r.Yaw*HeadFactor);
//			r = rot( r.pitch * 0.5, 0, -r.Yaw*HeadFactor );
			if( bHeadTrackTimer )
			{
				minst.BoneSetRotate(bone, r, true, true);
			}
		}
//	}
//	else // head-only head look
//	{
//		LookRotation = HeadLook;
//		bone = minst.BoneFindNamed('Head');
//		if (bone!=0)
//		{
//			r = LookRotation;
//			r = rot(r.Pitch,0,-r.Yaw);
//			minst.BoneSetRotate(bone, r, false, true);
//		}
//	}
	// eye look
	LookRotation = EyeLook;

	bone = minst.BoneFindNamed('Pupil_L');
	if (bone!=0)
	{			
		r = LookRotation;
	//	r = rot(r.Pitch,0,-r.Yaw);
		r = rot(0,0,-r.Yaw);
		minst.BoneSetRotate(bone, r, false, true);
	}
	bone = minst.BoneFindNamed('Pupil_R');
	if (bone!=0)
	{
		r = LookRotation;
		//r = rot(r.Pitch,0,-r.Yaw);
		r = rot(0,0,-r.Yaw);
		minst.BoneSetRotate(bone, r, false, true);
	}
	return(true);
}

function Tick(float inDeltaTime)
{	
	if (!PlayerCanSeeMe())
	{
		return;
	}

	TopAnimBlend = UpdateRampingFloat(TopAnimBlend, DesiredTopAnimBlend, TopAnimBlendRate*inDeltaTime);
	BottomAnimBlend = UpdateRampingFloat(BottomAnimBlend, DesiredBottomAnimBlend, BottomAnimBlendRate*inDeltaTime);
	SpecialAnimBlend = UpdateRampingFloat( SpecialAnimBlend, DesiredSpecialAnimBlend, SpecialAnimBlendRate*inDeltaTime);
	GetMeshInstance();
	if (MeshInstance!=None)
	{
		MeshInstance.MeshChannels[1].AnimBlend = TopAnimBlend;
		MeshInstance.MeshChannels[2].AnimBlend = BottomAnimBlend;
		MeshInstance.MeshChannels[4].AnimBlend = SpecialAnimBlend;

		if (DesiredTopAnimBlend>=1.0 && TopAnimBlend>=1.0)
		{
			MeshInstance.MeshChannels[1].AnimSequence = 'None';
		}
		if (DesiredBottomAnimBlend>=1.0 && BottomAnimBlend>=1.0)
			MeshInstance.MeshChannels[2].AnimSequence = 'None';
		if( DesiredSpecialAnimBlend>=1.0 && SpecialAnimBlend>=1.0)
			MeshInstance.MeshChannels[4].AnimSequence = 'None';
	}
	TickTracking( inDeltaTime );	
}



function rotator ClampHeadRotation(rotator r)
{
	local rotator adj;
	adj = Rotation;
	r = Normalize(r - adj);
	r.Pitch = Clamp(r.Pitch, -HeadTracking.RotationConstraints.Pitch, HeadTracking.RotationConstraints.Pitch);
	r.Yaw = Clamp(r.Yaw, -HeadTracking.RotationConstraints.Yaw, HeadTracking.RotationConstraints.Yaw);
	r.Roll = Clamp(r.Roll, -HeadTracking.RotationConstraints.Roll, HeadTracking.RotationConstraints.Roll);
	r = Normalize(r + adj);
	return(r);
}


simulated function bool EvalLipSync()
{
    local int bone;
    local MeshInstance minst;
	local rotator r;
    local vector s, t;
	local float f;
	local float scale;

    if( bNoLipSync )
		return false;

	minst = GetMeshInstance();
    if (minst==None)
        return(false);

    // rotate the jaw downward
	bone = minst.BoneFindNamed('Jaw');
	if (bone!=0)
	{
		scale=SoundSyncScale_Jaw;
		if(scale==0) scale=1.0;
		
		r = minst.BoneGetRotate(bone, false);
		r.Pitch = MonitorSoundLevel * -6048.0 * Scale;
		minst.BoneSetRotate(bone, r, false);
	}

	// scale in the mouth corner a bit
    bone = minst.BoneFindNamed('MouthCorner');
	if (bone!=0)
	{
		scale=SoundSyncScale_MouthCorner;
		if(scale==0) scale=1.0;

		f = 1.0 - MonitorSoundLevel * 2.0 * Scale;
		s.x = f; s.y = f; s.z = f;
		minst.BoneSetScale(bone, s, true);
	}

	// move the upper lip up a little
    bone = minst.BoneFindNamed('Lip_U');
    if (bone!=0)
	{
		scale=SoundSyncScale_Lip_U;
		if(scale==0) scale=1.0;

	    t = minst.BoneGetTranslate(bone, false, true);
		t.x += 0.25 * Scale * MonitorSoundLevel;
		minst.BoneSetTranslate(bone, t, false);
	}

	// same with the lower lip
    bone = minst.BoneFindNamed('Lip_L');
    if (bone!=0)
	{
		scale=SoundSyncScale_Lip_L;
		if(scale==0) scale=1.0;

		t = minst.BoneGetTranslate(bone, false, true);
		t.x += -0.5 *Scale  * MonitorSoundLevel;
		minst.BoneSetTranslate(bone, t, false);
	}

	return(true);
}


simulated event bool OnEvalBones(int Channel)
{
	if (!bHumanSkeleton)
		return false;

	// Update head.
    if (Channel == 8)
	{
		if( !PlayerCanSeeMe() )
			return false;
		if( Health > 0 )
		{
			EvalBlinking();
			EvalHeadLook();
		}	
		if( !bNoLipSync )
			EvalLipSync();
	}

	return true;
}

function EnableHeadTracking(bool bEnable)
{
//	if (bEnable)
//	{
		bHeadTrackTimer = true;
		HeadTracking.DesiredWeight = 1.1;
		HeadTracking.WeightRate = 1.0;
//	}
//	else
//	{
		//HeadTracking.DesiredWeight = 0.0;
		//HeadTracking.WeightRate = 2.0;
//	}
}
/*
simulated event bool OnEvalBones(int Channel)
{
	if (!bHumanSkeleton)
		return false;

	// Update head.
    if (Channel == 8)
	{
		EvalBlinking();
		EvalHeadLook();
	}
	return Super.OnEvalBones(Channel);
}
*/

function float UpdateRampingFloat(float inCurrent, float inDesired, float inMaxChange)
{
	if (inCurrent < inDesired)
	{
		inCurrent += inMaxChange;
		if (inCurrent > inDesired)
			inCurrent = inDesired;
	}
	else
	{
		inCurrent -= inMaxChange;
		if (inCurrent < inDesired)
			inCurrent = inDesired;
	}
	return(inCurrent);
}
/*
	FixedTurn - Takes a current rotation angle and a desired rotation angle, with a positive
	maximum to rotate by.  Returns a resulting angle.  Based on the internal physics "fixedTurn" method.
	FIXME: Perhaps this should be moved into a general native utility function.
*/
function int FixedTurn(int inCurrent, int inDesired, int inMaxChange, optional out int outDelta)
{
	local int result, delta;

	inCurrent = inCurrent & 65535;
	if (inMaxChange==0)
		return(inCurrent);
	inDesired = inDesired & 65535;
	inMaxChange = int(Abs(inMaxChange));
	
	if (inCurrent > inDesired)
	{
		if ((inCurrent - inDesired) < 32768)
			delta = -Min((inCurrent - inDesired), inMaxChange);
		else
			delta = Min(((inDesired + 65536) - inCurrent), inMaxChange);
	}
	else
	{
		if ((inDesired - inCurrent) < 32768)
			delta = Min((inDesired - inCurrent), inMaxChange);
		else
			delta = -Min(((inCurrent + 65536) - inDesired), inMaxChange);
	}
	outDelta = delta;
	inCurrent += delta;
	return(inCurrent);
}

defaultproperties
{
     HeadTracking=(RotationRate=(Pitch=40000,Yaw=65000),RotationConstraints=(Pitch=8000,Yaw=16000))
     bHumanSkeleton=true
}

