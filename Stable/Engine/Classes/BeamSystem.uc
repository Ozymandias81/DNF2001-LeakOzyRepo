//=============================================================================
// BeamSystem. (NJS)
// Fix Multiple Event Actors
//=============================================================================
class BeamSystem expands ParticleSystem
	native;

var() bool  Enabled;
var() int	TesselationLevel;
var() float BeamStartWidth;
var() float BeamEndWidth;
var() float TimeScale;
var() color	BeamColor;
var() color BeamEndColor;

var(BeamAmplitude) float MaxAmplitude;
var(BeamAmplitude) float AmplitudeLimit;
var(BeamAmplitude) float AmplitudeVelocity;

var(BeamFrequency) float MaxFrequency;
var(BeamFrequency) float FrequencyLimit;
var(BeamFrequency) float FrequencyVelocity;

var(BeamNoise) float Noise;
var(BeamNoise) float NoiseLimit;
var(BeamNoise) float NoiseVelocity;

var(BeamTexture) Texture BeamTexture;
var(BeamTexture) int     SubTextureCount;
var(BeamTexture) float   BeamTextureScaleX,
						 BeamTextureScaleY;
var(BeamTexture) float   BeamTexturePanX,
						 BeamTexturePanY;
var(BeamTexture) float   BeamTexturePanOffsetX,
						 BeamTexturePanOffsetY;
var(BeamTexture) bool    BeamReversePanPass;
var(BeamTexture) bool    FlipHorizontal;
var(BeamTexture) bool	 FlipVertical;
var(BeamTexture) bool    ScaleToWorld;

struct native SControlPoint
{
	var() vector Position;
	var() actor  PositionActor;
}; 

var() SControlPoint ControlPoint[32];
var() int ControlPointCount;

var() enum EBeamType
{
	BST_Straight,
	BST_RandomWalk,
	BST_RecursiveSubdivide,
	BST_SineWave,
	BST_DoubleSineWave,
	BST_Spline,
	BST_Grid
} BeamType;

var() bool DepthCued;
var() bool BeamBrokenIgnoreWorld; // CDH: BeamBroken checks should ignore world geometry

var () enum EBeamSystemTriggerType
{
	BSTT_None,
	BSTT_Enable,
	BSTT_Disable,
	BSTT_Toggle,
	BSTT_Reset,
} TriggerType;

var () class<actor> SpawnClassOnBeamCollision;

// Internal Variables:
var actor DestinationActor[8];
var vector DestinationOffset[8];
var int   NumberDestinations;

// Beam broken actions:
var(BeamBroken) enum EBeamBrokenWhen
{
	BBW_Never,
	BBW_PlayerProximity,
	BBW_ClassProximity,
	BBW_Shot	
} BeamBrokenWhen;

var(BeamBroken) class<actor> BeamBrokenWhenClass;

var(BeamBroken) enum EBeamBrokenAction
{
	BBA_None,
	BBA_TriggerEvent,
	BBA_TriggerBeamBrokenEvent,
	BBA_TriggerBreaker,
	BBA_TriggerBeam,
    BBA_TriggerOwner // CDH
} BeamBrokenAction;

var(BeamBroken) name  BeamBrokenEvent;
var(BeamBroken) bool  BeamBrokenRetriggerable;
var(BeamBroken) float BeamBrokenOtherDamage;

// CDH... camera style mode (for heatvision etc.)
var() enum EBeamPlayerCameraStyleMode
{
    BPCS_None, // don't restrict to a camera style
    BPCS_Equal, // only display if camera style is same
    BPCS_NotEqual // only display if camera style is not the same
} BeamPlayerCameraStyleMode;
var() PlayerPawn.EPlayerCameraStyle BeamPlayerCameraStyle;
// ...CDH

var transient vector BoundingBoxMin;
var transient vector BoundingBoxMax;

// Draw the beams:
function PostBeginPlay()
{
	super.PostBeginPlay();

	ResetDestinationActors();

	BoundingBoxMin=Location-vect(5,5,5);
	BoundingBoxMax=Location+vect(5,5,5);

	Enable('Tick');

	if(((BeamBrokenWhen==BBW_Never)||(BeamBrokenAction==BBA_None))&&(SpawnClassOnBeamCollision==none)) 
	{
		if((FrequencyVelocity==0&&AmplitudeVelocity==0&&NoiseVelocity==0))
		Disable('Tick');
	}
}

function ResetDestinationActors()
{
	local actor a;
	local int i;

	NumberDestinations=0;
	foreach allactors(class 'actor',a,Event)
	{
		DestinationActor[NumberDestinations]=a;
		NumberDestinations++;
		if(NumberDestinations>=ArrayCount(DestinationActor)) break;
	}
}

function Trigger( actor Other, Pawn Instigator )
{
	switch(TriggerType)
	{
		case BSTT_None: break;
		case BSTT_Enable:  Enabled=true; break;
		case BSTT_Reset:   ResetDestinationActors();		break;
		case BSTT_Disable: Enabled=false;break;
		case BSTT_Toggle:  Enabled=!Enabled;
						   break;
	}
}

function Tick(float DeltaSeconds)
{
	local actor HitActor;
	local vector HitLocation, HitNormal;
	local int i;
	local bool UseActorsForTrace;

	if(NoiseVelocity!=0)
	{
		Noise+=(NoiseVelocity*DeltaSeconds);
		if(NoiseVelocity<0)
		{
			if(Noise<NoiseLimit) Noise=NoiseLimit;
		} else
		{
			if(Noise>NoiseLimit) Noise=NoiseLimit;
		}
	}

	if(AmplitudeVelocity!=0)
	{
		MaxAmplitude+=(AmplitudeVelocity*DeltaSeconds);

		if(AmplitudeVelocity<0)
		{
			if(MaxAmplitude<AmplitudeLimit) MaxAmplitude=AmplitudeLimit;
		} else
		{
			if(MaxAmplitude>AmplitudeLimit) MaxAmplitude=AmplitudeLimit;
		}
	}

	if(FrequencyVelocity!=0)
	{
		MaxFrequency+=(FrequencyVelocity*DeltaSeconds);

		if(FrequencyVelocity<0)
		{
			if(MaxFrequency<FrequencyLimit) MaxFrequency=FrequencyLimit;
		} else
		{
			if(MaxFrequency>FrequencyLimit) MaxFrequency=FrequencyLimit;
		}
	}

	if(!Enabled) 
		return;

	UseActorsForTrace=false;
	if(SpawnClassOnBeamCollision==none) UseActorsForTrace=true;

	for(i=0;i<NumberDestinations;i++)
	{
		HitActor=Trace(HitLocation, HitNormal,DestinationActor[i].Location,Location,UseActorsForTrace);
        // CDH...
        if (BeamBrokenIgnoreWorld)
        {
            if (LevelInfo(HitActor)!=none || Brush(HitActor)!=none)
                HitActor = none;
        }
        // ...CDH
		if(HitActor!=none) break;
	}
	if(HitActor==none) return;

	if(SpawnClassOnBeamCollision!=none)
	{
		Spawn(SpawnClassOnBeamCollision,,,HitLocation+HitNormal, Rotator(HitNormal));
	} 

	switch(BeamBrokenWhen)
	{
		case BBW_Never:				return;		// Can't be broken
		case BBW_PlayerProximity:	
			if(!HitActor.IsA('PlayerPawn')) return; 
			if(BeamBrokenOtherDamage!=0) 
				PlayerPawn(HitActor).TakeDamage( BeamBrokenOtherDamage, None, HitLocation, HitNormal, class'ElectricalDamage' );
			break;
		case BBW_ClassProximity:	if(!HitActor.IsA(BeamBrokenWhenClass.name)) return; break;
		case BBW_Shot:				return;		// Not yet implemented.
	}

	switch(BeamBrokenAction)
	{
		case BBA_None: return;
		case BBA_TriggerEvent:			 GlobalTrigger(Event); break;
		case BBA_TriggerBeamBrokenEvent: GlobalTrigger(BeamBrokenEvent); break;
		case BBA_TriggerBreaker:		 HitActor.Trigger(HitActor,Instigator); break;
		case BBA_TriggerBeam:			 Trigger(HitActor,Instigator); break;
        case BBA_TriggerOwner:           if (Owner!=None) Owner.Trigger(Self,Instigator); break; // CDH
	}

	if(!BeamBrokenRetriggerable) { Disable('Tick'); return; }
}

defaultproperties
{
	TriggerType=BSTT_Toggle
	Enabled=true
	BeamType=BST_RandomWalk
	TesselationLevel=10
	MaxAmplitude=50
	MaxFrequency=0.0001
	DepthCued=true
	BeamBrokenRetriggerable=true
	BeamBrokenAction=BBA_TriggerBeam
	BeamBrokenWhen=BBW_Never
	TimeScale=1.0
	SubTextureCount=1
	BeamTextureScaleX=1.000
	BeamTextureScaleY=1.000
	ControlPointCount=-1
}
