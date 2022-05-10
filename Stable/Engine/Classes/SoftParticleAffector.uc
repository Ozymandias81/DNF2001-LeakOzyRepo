//=============================================================================
// SoftParticleAffector. (NJS)
// CollisionRadius is area of influence.
//=============================================================================
class SoftParticleAffector expands ParticleSystem
	native;

var () int  AffectedGroupID;
var () bool AlwaysAffectGroup;

var () enum EParticleAffectorType
{
	PAT_None,		// No type
	PAT_Magnet,		// Attracts or repels particles.
	PAT_Noise,		// Vibration Area
	PAT_Force,		// Applies a basic force to ALL particles in the system - uses magnitude and the rotation of this actor
	PAT_Teleport,	// Randomly teleports particles to other positions in the radius 
	PAT_Destroy,	// Destroy any particles touching the affector.
	PAT_Wake,		// Throw particles about like a boat/rocket wake.
	PAT_Vortex,		// Swirly vortexy kind of thing
} Type;

var    float OriginalMagnitude;		// Original Value of Magnitude
var () float Magnitude;				// Negative magnitude OK
var () float PulseApexMagnitude;	// Magnitude at pulses apex
var () float PulseDuration;			// Duration of the pulse
var    float PulseStartTime;		// Time that the pulse started - 0 is no pulse present.
var () bool  Enabled;				// If this affector is enabled or not.

// Affect only specific axes:
var () bool AffectX;
var () bool AffectY;
var () bool AffectZ;

var () enum EParticleTriggerReaction
{
	PTG_None,
	PTG_Disable,
	PTG_Enable,
	PTG_Toggle,
	PTG_Pulse
} TriggerReaction;

function PostBeginPlay()
{
	super.PostBeginPlay();
	if(!Enabled) Disable('Tick');
	OriginalMagnitude=Magnitude;
}

function Tick( float DeltaSeconds )
{
	local SoftParticleSystem p;
	local float NewMagnitude;
	local float TimeIntoPulse;
	local float PulseAlpha;
	local float HalfPulseDuration;
	local int i;

	if(PulseStartTime!=0)
	{
		TimeIntoPulse=Level.TimeSeconds-PulseStartTime;

		// If I've passed my max duration, then end the pulse:
		if(TimeIntoPulse>=PulseDuration)
		{
			PulseStartTime=0;
			Magnitude=OriginalMagnitude;
		} 
		// Compute Pulse magnitude.
		else
		{
			HalfPulseDuration=PulseDuration/2;

			if(TimeIntoPulse<HalfPulseDuration)
			{
				PulseAlpha=TimeIntoPulse/HalfPulseDuration;
			} else
			{
				PulseAlpha=1.0-((TimeIntoPulse-HalfPulseDuration)/HalfPulseDuration);
			}

			Magnitude=Lerp(PulseAlpha,OriginalMagnitude,PulseApexMagnitude);
		}
	}
	if(AlwaysAffectGroup)
	{
		foreach AllActors( class'SoftParticleSystem', p)
		{
			if(p.GroupID==AffectedGroupID)
				p.AffectParticles(self);
		}

	} else
	{
		foreach RadiusActors( class'SoftParticleSystem', p, CollisionRadius)
		{
			if(p.GroupID==AffectedGroupID)
				p.AffectParticles(self);
		}
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	switch(TriggerReaction)
	{
		case PTG_None:	  break;
		case PTG_Disable: Disable('Tick'); Enabled=false; break;
		case PTG_Enable:  Enable('Tick');  Enabled=true;  break;
		case PTG_Toggle:
			if(Enabled) { Disable('Tick'); Enabled=false; }
			else		{ Enable('Tick');  Enabled=true; }
			break;

		case PTG_Pulse:
			PulseStartTime=Level.TimeSeconds;
			break;
	}
}

defaultproperties
{
	Type=PAT_Magnet
	Magnitude=100
	PulseApexMagnitude=200
	Enabled=True
	TriggerReaction=PTG_Toggle
	PulseStartTime=0
	PulseDuration=1.0
	AlwaysAffectGroup=false
	AffectX=true
	AffectY=true
	AffectZ=true
}
