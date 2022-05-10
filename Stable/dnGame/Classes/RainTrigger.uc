/*-----------------------------------------------------------------------------
	RainTrigger
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class RainTrigger expands Triggers;

var(RainOverlay) bool					bSetRainOverlay;
var(RainOverlay) bool					bRainOverlay;

var(RainMist) bool						bSetMistEffect;
var(RainMist) class<SoftParticleSystem>	MistEffect;

var(RainMount) bool						bSetMountedRain;
var(RainMount) class<SoftParticleSystem>MountedRain;
var(RainMount) name						DisableFakeRain;
var(RainMount) name						EnableFakeRain;

var(RainSounds) bool					bSetCanHearThunder;
var(RainSounds) bool					bCanHearThunder;
var(RainSounds) bool					bSetAmbientRain;
var(RainSounds) bool					bAmbientRain;
var(RainSounds) byte					AmbientRainVolume;

var() bool								bTriggerOnTouch;
var() bool								bTriggerOnUnTouch;
var() bool								bUseSinglePlayer;

function Touch( Actor Other )
{
	if ( bTriggerOnTouch )
		Trigger( Other, Pawn(Other) );
}

function UnTouch( Actor Other )
{
	if ( bTriggerOnUnTouch )
		Trigger( Other, Pawn(Other) );
}

function Trigger( Actor Other, Pawn EventInstigator )
{
	local DukePlayer DukeOther;
	local SoftParticleSystem FakeRain;
	local Pawn P;

	if ( (EventInstigator != None) && EventInstigator.IsA('DukePlayer') )
		DukeOther = DukePlayer(EventInstigator);

	if ( bUseSinglePlayer )
	{
		for ( P=Level.PawnList; P != None; P = P.NextPawn )
		{
			if ( P.IsA('DukePlayer') )
				DukeOther = DukePlayer(P);
		}
	}

	if ( DukeOther == None )
		return;

	if ( bSetRainOverlay )
		DukeOther.bRainOverlay = bRainOverlay;

	if ( bSetMistEffect )
	{
		if ( (DukeOther.Mist != None) && (MistEffect != DukeOther.Mist) )
		{
			// Destroy the old mist effect if we are adding a new one.
			DukeOther.Mist.DestroyWhenEmpty = true;
			DukeOther.Mist.Enabled = false;
			DukeOther.OldMist = DukeOther.Mist;
		}

		if ( MistEffect != None )
			DukeOther.Mist = spawn( MistEffect );
	}

	if ( bSetMountedRain )
	{
		if ( (DukeOther.Rain != None) && (MountedRain != DukeOther.Rain) )
		{
			// Destroy the old rain effect if we are adding a new one.
			DukeOther.Rain.DestroyWhenEmpty = true;
			DukeOther.Rain.Enabled = false;
			DukeOther.OldRain = DukeOther.Rain;
		}

		if ( MountedRain != None )
			DukeOther.Rain = spawn( MountedRain );
	}

	if ( DisableFakeRain != '' )
	{
		foreach AllActors( class'SoftParticleSystem', FakeRain, DisableFakeRain )
		{
			FakeRain.Enabled = false;
		}
	}

	if ( EnableFakeRain != '' )
	{
		foreach AllActors( class'SoftParticleSystem', FakeRain, EnableFakeRain )
		{
			FakeRain.Enabled = true;
		}
	}

	if ( bSetAmbientRain )
	{
		if ( bAmbientRain )
		{
			DukeOther.AmbientSound = DukeOther.AmbientRain;
			DukeOther.SoundVolume = AmbientRainVolume;
		}
		else
		{
			DukeOther.AmbientSound = None;
		}
	}

	if ( bSetCanHearThunder )
	{
		DukeOther.bCanHearThunder = bCanHearThunder;
		if ( bCanHearThunder )
			DukeOther.NextThunderTime = Level.TimeSeconds + 30.0 + 30*FRand();
		else
			DukeOther.NextThunderTime = 0.0;
	}
}

defaultproperties
{
	AmbientRainVolume=128
	bTriggerOnTouch=true
	bTriggerOnUnTouch=false
}