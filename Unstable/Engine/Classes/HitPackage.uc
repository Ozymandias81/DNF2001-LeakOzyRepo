/*-----------------------------------------------------------------------------
	HitPackage
	Author: Brandon Reinhart

	A single actor that spawns a set of hit effects on the client.
	Used with trace-fire weapons.

	Types:
		Flesh, Steel, Shield

	Handles:
		Hit decals
		Shot traces
		Pawn flesh hit effect
		Carcass flesh hit effect
-----------------------------------------------------------------------------*/
class HitPackage extends Effects;

// Replicated variables for flesh hit.
var float HitDamage;

// Replicated variables for beams.
var float ShotOriginX, ShotOriginY, ShotOriginZ;
var float TraceOriginX, TraceOriginY, TraceOriginZ;
var bool bTraceBeam, bLaserBeam;

// Replicated for level packages.
var int TraceHitCategory;
var bool bRicochet;

// Values for mesh hit effects.  Not replicated.
var name HitMeshBone;
var vector HitMeshBarys, HitLocation, HitNormal, HitMomentum;
var int HitMeshTri;

// Extra info.
var bool bNoCreationSounds;
var bool bNoBloodHit;

// Sniper beam class.
var string LaserBeamClassName;

replication
{
	reliable if ( Role == ROLE_Authority )
		HitDamage, ShotOriginX, ShotOriginY, ShotOriginZ, TraceOriginX, TraceOriginY, TraceOriginZ, bTraceBeam, bLaserBeam;
	reliable if ( (Role == ROLE_Authority) && (Owner == Level) )
		TraceHitCategory, bRicochet;
}

simulated function PostNetInitial()
{
	if ( Role < ROLE_Authority )
		Deliver();
}

// Everything spawned here should have no remote role.
simulated function Deliver()
{
	local vector EndTrace, StartTrace, Direction, ViewVector;
	local actor Other;
	local bool bMeshAccurate;

	if ( Level.NetMode == NM_DedicatedServer )
		return;
	if ( Instigator == None )
		return;

	HitMomentum = normal( Location - vect(ShotOriginX, ShotOriginY, ShotOriginZ) );

	// Draw a beam if necessary.
	if ( bTraceBeam )
		SpawnTraceBeam( Location, vect(TraceOriginX, TraceOriginY, TraceOriginZ) );
	else if ( bLaserBeam )
	{
		TraceHitCategory = 1;
		SpawnLaserBeam( Location, vect(TraceOriginX, TraceOriginY, TraceOriginZ) );
	}

	// Find out what we hit. (Triangle, Barys, Bone)
	EndTrace = Location;
	StartTrace = vect(ShotOriginX, ShotOriginY, ShotOriginZ);
	Direction = normal(StartTrace - EndTrace);
	EndTrace -= Direction*10;
	bMeshAccurate = true;
    Other = Instigator.Trace( HitLocation, HitNormal, EndTrace, StartTrace, true, , bMeshAccurate, HitMeshTri, HitMeshBarys, HitMeshBone );

	MakeNoise( 1.0 );
	// Spawn a hit effect where we hit.
	if ( (Owner != None) && ((Level.NetMode != NM_Client) || !bNoBloodHit) )
	{
		if ( Owner.bIsPawn )
			Pawn(Owner).HitEffect( Location, class'BulletDamage', HitMomentum, bNoCreationSounds );
		else if ( Owner.IsA('Carcass') )
			Carcass(Owner).FakeDamage( HitDamage, HitMeshBone, Instigator, Location, HitMomentum, class'BulletDamage', bNoCreationSounds );
	}
}

simulated function SpawnTraceBeam( vector End, vector Start )
{
	local BeamSystem bs;
	local mesh OldMesh;

	if ( FRand() > 0.5 )
		return;

	bs = spawn(class'BeamSystem', Instigator, , Start);
	bs.bOwnerNoSee = true;
	bs.Style = STY_Translucent;
	bs.Tesselationlevel = 1;
	bs.BeamBrokenAction = BBA_None;
	bs.BeamType = BST_Straight;
	bs.BeamColor.R = 232/2;
	bs.BeamColor.G = 235/2;
	bs.BeamColor.B = 141/2;
	bs.MaxFrequency = 0;
	bs.DepthCued = false;
	bs.BeamStartWidth = 1.1;
	bs.BeamEndWidth = 1.1;
	bs.DestinationActor[0] = spawn(class'BeamAnchor', Self, , End);
	bs.LifeSpan = 0.05;
	bs.DestinationActor[0].LifeSpan = 1.0;
	bs.NumberDestinations = 1;
	bs.bIgnoreBList = true;
	bs.RemoteRole = ROLE_None;
	bs.SetLocation( Start );
}

// Spawns an extended laser beam effect.
simulated function SpawnLaserBeam( vector End, vector Start )
{
	local class<LaserBeam> LaserBeamClass;
	local LaserBeam Laser;

	LaserBeamClass = class<LaserBeam>( DynamicLoadObject( LaserBeamClassName, class'Class' ) );
	Laser = spawn( LaserBeamClass, Instigator );
	Laser.SpawnLaserBeam( Start, End, false, true );
	Laser.Destroy();
}

defaultproperties
{
	Texture=None
	DrawType=DT_Sprite
	bNetTemporary=true
	bHidden=false
	RemoteRole=ROLE_SimulatedProxy
	bReplicateInstigator=true
	LifeSpan=1.0
	LaserBeamClassName="dnGame.dnLaserBeam"
}