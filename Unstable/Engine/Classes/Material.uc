//=============================================================================
// Material. (NJS)
//=============================================================================
class Material extends InfoActor
	native
	abstract;

// No longer used:
var() struct DamageCategoryEffectStruct
{
	var() class<actor>   HitEffect;		// Effect when a bullet hits this surface.
	var() class<actor>	 HitSpawn;		// Actor to spawn when a bullet hits.
	var() sound			 HitSounds[8];	// Sounds to randomly choose from when a bullet hits.
	var() name			 HitTrigger;	// Event to trigger.
} DamageCategoryEffect[10];

var() sound FootstepSounds[32];			// Sounds to play when material is walked upon
var() int   FootstepSoundsCount;		// Number of sounds above.
var() name	FootstepTrigger;			// Trigger this event whenever a pawn walks upon this material.
var() bool  FootstepSoundWhenCrouching; // Whether to play a footstep sound when I'm crouching.

var() sound FootstepLandSound;			// Played when one lands on the surface

var() float Friction;					// The surfaces friction: 0.0=none, 1.0=normal
var() bool  bClimbable;					// True if the surface is climbable
var() bool  bLockClimbers;				// True if climbers should be locked to this surface while climbing

var() bool  bPenetrable;				// If the wall is capable of being penetrated.
var() bool  bIsMirror;

var() bool  TriggerSurfEventOnHit;		// If true, trigger the surface on hit.
var() bool	TriggerSurfEventOnce;

var() vector AppliedForce;				// Force to be applied to objects standing on this.

var() bool	bBurrowableStone;
var() bool	bBurrowableDirt;

var() mesh					BurrowMesh;
var() class<SoftParticleSystem>		BurrowParticlesUp;
var() class<SoftParticleSystem>		BurrowParticlesDown;

defaultproperties
{
	TriggerSurfEventOnce=true
}