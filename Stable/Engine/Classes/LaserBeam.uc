/*-----------------------------------------------------------------------------
	LaserBeam
	Author: Brandon Reinhart

	This cl@ss is used in conjunction with hitpackages to create complex
	laser beam effects.
-----------------------------------------------------------------------------*/
class LaserBeam extends Info;

// Classes for effects.
var class<BeamSystem> LaserBeamClass;
var class<BeamSystem> BeamSmokeClass;
var class<SoftParticleSystem> LaserHitClass;
var class<SoftParticleSystem> LaserFlashClass;

// References to effects.
var BeamAnchor Anchor;
var BeamSystem LaserBeam;
var BeamSystem BeamSmoke;
var SoftParticleSystem WallHit;
var SoftParticleSystem LaserFlash;

// Static class so it can be used by the sniper weapon.
// The last particle system in hit is the muzzle flash.
simulated function SpawnLaserBeam( vector End, vector Start, optional bool bOnlyOwnerSee, optional bool bOwnerNoSee	)
{
	// Anchor.
	Anchor = spawn( class'BeamAnchor', Self, , End );
	Anchor.LifeSpan = 10.0;
	Anchor.RemoteRole = ROLE_None;

	// Laser beam.
	LaserBeam = spawn( LaserBeamClass, Owner, , Start );
	LaserBeam.bOnlyOwnerSee = bOnlyOwnerSee;
	LaserBeam.bOwnerNoSee = bOwnerNoSee;
	LaserBeam.DestinationActor[0] = Anchor;
	LaserBeam.NumberDestinations = 1;
	LaserBeam.bIgnoreBList = true;
	LaserBeam.RemoteRole = ROLE_None;

	// Beam smoke.
	BeamSmoke = spawn( BeamSmokeClass, Owner, , Start );
	BeamSmoke.bOnlyOwnerSee = bOnlyOwnerSee;
	BeamSmoke.bOwnerNoSee = bOwnerNoSee;
	BeamSmoke.DestinationActor[0] = Anchor;
	BeamSmoke.NumberDestinations = 1;
	BeamSmoke.bIgnoreBList = true;
	BeamSmoke.RemoteRole = ROLE_None;

	// Wall hit.
	WallHit = spawn( LaserHitClass, Owner, , Start );
	WallHit.bOnlyOwnerSee = bOnlyOwnerSee;
	WallHit.bOwnerNoSee = bOwnerNoSee;

	// Flash
	LaserFlash = spawn( LaserFlashClass, Owner, , End );
	LaserFlash.bOnlyOwnerSee = bOnlyOwnerSee;
	LaserFlash.bOwnerNoSee = bOwnerNoSee;
}