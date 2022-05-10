class MeshActor extends RenderActor;

var() float		SoundSyncScale_Jaw;
var() float		SoundSyncScale_MouthCorner;
var() float		SoundSyncScale_Lip_U;
var() float		SoundSyncScale_Lip_L;

var	transient bool	bBlinked;
var   float		LastBlinkTime;
var	  float		BlinkTimer;
var	  float		CurrentBlinkAlpha;
var() float		BlinkRateBase			?("Base rate of eye blinking.\nFinal rate is randomly chosen between BlinkRateBase and BlinkRateBase+BlinkRateRandom");
var() float		BlinkRateRandom			?("Random blink rate adjustment above base.\nFinal rate is random chosen between BlinkRateBase and BlinkRateBase+BlinkRateRandom");
var() float		BlinkDurationBase		?("Base duration of eye blinking.\nFinal duration is randomly chosen between BlinkDurationBase and BlinkDurationBase+BlinkDurationRandom");
var() float		BlinkDurationRandom		?("Random blink duration adjustment above base.\nFinal duration is randomly chosen between BlinkDurationBase and BlinkDurationBase+BlinkDurationRandom");
var() vector	BlinkEyelidPosition		?("Position eyelid is adjusted by at full blink.\nValues are relative to eyelid bone axes");
var() float		BlinkChangeTime			?("Time in seconds it takes to go between a fully non-blinked and a fully blinked state");

var	  texture	Icon;

var UDukePlayerMeshCW NotifyClient;

function AnimEnd()
{
	NotifyClient.AnimEnd( Self );
}

event bool OnEvalBones( int Channel )
{
	// Update head.
    if (Channel == 8)
	{
		EvalBlinking();
		if( MonitorSoundLevel > 0.0 )
			EvalLipSync();
	}

	return Super.OnEvalBones( Channel );
}

function bool EvalLipSync()
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
		scale=SoundSyncScale_Jaw;
		if(scale==0) scale=1.0;
		
		r = minst.BoneGetRotate(bone, false);
		r.Pitch = MonitorSoundLevel * -2048.0 * Scale;
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

simulated function bool EvalBlinking()
{
    local int bone;
    local MeshInstance minst;
    local vector t;
	local float deltaTime;
    
	minst = GetMeshInstance();
    if (minst==None)
        return(false);

	if (BlinkDurationBase <= 0.0)
		return(false);

	deltaTime = Level.TimeSeconds - LastBlinkTime;
	LastBlinkTime = Level.TimeSeconds;

	BlinkTimer -= deltaTime;
	if (BlinkTimer <= 0.0)
	{
		if (!bBlinked)
		{
			bBlinked = true;
			BlinkTimer = BlinkDurationBase + FRand()*BlinkDurationRandom;
		}
		else
		{
			bBlinked = false;
			BlinkTimer = BlinkRateBase + FRand()*BlinkRateRandom;
		}
	}

	if (BlinkChangeTime <= 0.0)
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
			CurrentBlinkAlpha += deltaTime/BlinkChangeTime;
			if (CurrentBlinkAlpha > 1.0)
				CurrentBlinkAlpha = 1.0;
		}
		else
		{
			CurrentBlinkAlpha -= deltaTime/BlinkChangeTime;
			if (CurrentBlinkAlpha < 0.0)
				CurrentBlinkAlpha = 0.0;
		}
	}

	// blink the left eye
	bone = minst.BoneFindNamed('Eyelid_L');
	if (bone!=0)
	{
		t = minst.BoneGetTranslate(bone, false, true);
		t -= BlinkEyelidPosition*CurrentBlinkAlpha;
		minst.BoneSetTranslate(bone, t, false);
	}

	// blink the right eye
	bone = minst.BoneFindNamed('Eyelid_R');
	if (bone!=0)
	{
		t = minst.BoneGetTranslate(bone, false, true);
		t -= BlinkEyelidPosition*CurrentBlinkAlpha;
		minst.BoneSetTranslate(bone, t, false);
	}

	return(true);
}


defaultproperties
{
	Physics=PHYS_Rotating
	CollisionRadius=0
	CollisionHeight=0
	bCollideActors=False
	bCollideWorld=False
	bBlockActors=False
	bBlockPlayers=False
	bOnlyOwnerSee=True
	RemoteRole=ROLE_None
	DrawType=DT_Mesh
	bUnlit=True
	bHidden=False
	DrawScale=1.0
	bAlwaysTick=True
	AmbientGlow=255
	bStatic=False
    bMeshLowerByCollision=false
	SoundSyncScale_Jaw=0.900000
	SoundSyncScale_MouthCorner=0.700000
	SoundSyncScale_Lip_L=0.700000
	SoundSyncScale_Lip_U=0.750000
	BlinkRateBase=0.6
	BlinkRateRandom=5.0
	BlinkDurationBase=0.300000
	BlinkDurationRandom=0.050000
	BlinkEyelidPosition=(X=1.000000,Y=-0.100000,Z=0.000000)
	BlinkChangeTime=0.250000
}