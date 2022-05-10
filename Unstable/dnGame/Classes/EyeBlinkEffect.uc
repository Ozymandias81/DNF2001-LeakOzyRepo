//=============================================================================
// EyeBlinkEffect. (CDH)
// Performs a random blink on the eyelids of the actor.
// Geared for humanoids; assumes the common humanoid bone layout is in use.
//=============================================================================
class EyeBlinkEffect extends MeshEffect;

var transient int bBlinked;

var() float BlinkRateBase ?("Base rate of eye blinking.\nFinal rate is randomly chosen between BlinkRateBase and BlinkRateBase+BlinkRateRandom");
var() float BlinkRateRandom ?("Random blink rate adjustment above base.\nFinal rate is random chosen between BlinkRateBase and BlinkRateBase+BlinkRateRandom");
var() float BlinkDurationBase ?("Base duration of eye blinking.\nFinal duration is randomly chosen between BlinkDurationBase and BlinkDurationBase+BlinkDurationRandom");
var() float BlinkDurationRandom ?("Random blink duration adjustment above base.\nFinal duration is randomly chosen between BlinkDurationBase and BlinkDurationBase+BlinkDurationRandom");
var() vector BlinkEyelidPosition ?("Position eyelid is adjusted by at full blink.\nValues are relative to eyelid bone axes");
var() name LeftEyeBoneName ?("Bone name of left eyelid to blink");
var() name RightEyeBoneName ?("Bone name of right eyelid to blink");
var() float BlinkChangeTime ?("Time in seconds it takes to go between a fully non-blinked and a fully blinked state");

var float CurrentBlinkAlpha;

simulated function Timer(optional int TimerNum)
{
    bBlinked = bBlinked ^ 1;
    if (bBlinked > 0)
        SetTimer(BlinkDurationBase + FRand()*BlinkDurationRandom, true);
    else
        SetTimer(BlinkRateBase + FRand()*BlinkRateRandom, true);
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	SetTimer(BlinkRateBase, true);
}

simulated function Tick(float inDeltaTime)
{
	Super.Tick(inDeltaTime);

	if (BlinkChangeTime <= 0.0)
	{
		if (bBlinked > 0)
			CurrentBlinkAlpha = 1.0;
		else
			CurrentBlinkAlpha = 0.0;
		return;
	}

	if (bBlinked > 0)
	{
		CurrentBlinkAlpha += inDeltaTime/BlinkChangeTime;
		if (CurrentBlinkAlpha > 1.0)
			CurrentBlinkAlpha = 1.0;
	}
	else
	{
		CurrentBlinkAlpha -= inDeltaTime/BlinkChangeTime;
		if (CurrentBlinkAlpha < 0.0)
			CurrentBlinkAlpha = 0.0;
	}
}

simulated function SetInfo(int channel, actor a, MeshEffect inTemplate)
{
	local EyeBlinkEffect inf;
	inf = EyeBlinkEffect(inTemplate);
	if (inf == None)
		return;

    BlinkRateBase = inf.BlinkRateBase;
    BlinkRateRandom = inf.BlinkRateRandom;
    BlinkDurationBase = inf.BlinkDurationBase;
    BlinkDurationRandom = inf.BlinkDurationRandom;
    BlinkEyelidPosition = inf.BlinkEyelidPosition;
    LeftEyeBoneName = inf.LeftEyeBoneName;
    RightEyeBoneName = inf.RightEyeBoneName;
	BlinkChangeTime = inf.BlinkChangeTime;
}

simulated function EvalBones(int channel, actor a)
{
    local int bone;
    local MeshInstance minst;
    local vector t;
    minst = a.GetMeshInstance();
    if (minst==None)
        return;

	if (BlinkDurationBase <= 0.0)
		return;
	
	// blink the left eye
	bone = minst.BoneFindNamed(LeftEyeBoneName);
	if (bone!=0)
	{
		t = minst.BoneGetTranslate(bone, false, true);
		t -= BlinkEyelidPosition*CurrentBlinkAlpha;
		minst.BoneSetTranslate(bone, t, false);
	}

	// blink the right eye
	bone = minst.BoneFindNamed(RightEyeBoneName);
	if (bone!=0)
	{
		t = minst.BoneGetTranslate(bone, false, true);
		t -= BlinkEyelidPosition*CurrentBlinkAlpha;
		minst.BoneSetTranslate(bone, t, false);
	}
}

defaultproperties
{
    bAffectsBones=True
	BlinkRateBase=0.6
	BlinkRateRandom=5.0
	BlinkDurationBase=0.05
	BlinkDurationRandom=0.05
	LeftEyeBoneName=Eyelid_L
	RightEyeBoneName=Eyelid_R
    BlinkEyelidPosition=(X=1.000000,Y=-0.050000,Z=0.000000)
	BlinkChangeTime=0.250000
}