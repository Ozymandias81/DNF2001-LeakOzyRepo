/*-----------------------------------------------------------------------------
	FireWallBomb
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class FireWallBomb extends dnGrenade;

#exec OBJ LOAD FILE=..\sounds\dnsWeapn.dfx

var SoftParticleSystem Flame;
var class<SoftParticleSystem> FlameClass;
var class<FireWallStarter> FireWallStarterClass;
var class<FireWallCruiser> FireWallCruiserClass;

simulated function PostBeginPlay()
{
	Super(Projectile).PostBeginPlay();

	if ( Role == ROLE_Authority )
	{
		bCollideWorld = true;
		bCanHitOwner = false;

		if ( Instigator.HeadRegion.Zone.bWaterZone )
		{
			Destroy();
			return;
		}
	}

	Flame = spawn( FlameClass );
	Flame.SetPhysics( PHYS_MovingBrush );
	Flame.AttachActorToParent( self, false, false );
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	local FireWallCruiser fwc;
	local FireWallStarter fws;
	local vector X, Y, Z, loc;
	local rotator fwsrot;
	local int i;
	local float walllength;

	SetPhysics( PHYS_None );

	// Spawn the firewall starters.
	// These move sideways and create the actual firewall flames.
//	PlaySound( sound'dnsWeapn.Flamethrower.FTFBallExplPri' );

	loc = Location;

	fwsrot = Rotation;
	fwsrot.Yaw += 16384;
	GetAxes( fwsrot, X, Y, Z );
	fws = spawn( FireWallStarterClass, Instigator,, loc, fwsrot );
	fws.Instigator = Instigator;
	fws.TravelDir = X;
	fws.SpawnRot = Rotation;
	fws.SpawnDir = 1.0;

	fwsrot = Rotation;
	fwsrot.Yaw -= 16384;
	GetAxes( fwsrot, X, Y, Z );
	fws = spawn( FireWallStarterClass, Instigator,, loc, fwsrot );
	fws.Instigator = Instigator;
	fws.TravelDir = X;
	fws.SpawnRot = Rotation;
	fws.SpawnDir = -1.0;

	// Spawn the first firewallcruiser...the starters handle the rest.
	fwc = spawn( FireWallCruiserClass, Instigator,, loc, Rotation );
	fwc.Instigator = Instigator;

	// Spawn the decals.
	SpawnDecals();

	Destroy();
}

simulated function SpawnDecals()
{
	local FireWallStarterScorch fwss;
	local vector X, Y, Z;

	GetAxes( Rotation, X, Y, Z );
	fwss = spawn( class'FireWallStarterScorch', Self,,Location-Y*96,rot(16384,0,0) );
	fwss.DecalRotation.Pitch = 0;
	fwss.DecalRotation.Yaw = Rotation.Yaw + 40000 - 32768;
	fwss.DecalRotation.Roll = 0;
	fwss.Initialize();

	fwss = spawn( class'FireWallStarterScorch', Self,,Location+Y*96,rot(16384,0,0) );
	fwss.DecalRotation.Pitch = 0;
	fwss.DecalRotation.Yaw = Rotation.Yaw + 40000;
	fwss.DecalRotation.Roll = 0;
	fwss.Initialize();
}

simulated function Explode( vector HitLocation, optional vector HitNormal, optional bool bNoDestroy )
{
}

simulated event Destroyed()
{
	Super.Destroyed();
	
	if ( Flame != None )
		Flame.Destroy();
}

event ZoneChange( ZoneInfo NewZone )
{
	if ( NewZone.bWaterZone )
	{
		// Maybe spawn some smoke?
		Destroy();
	}
}

defaultproperties
{
	Speed=500
	MaxSpeed=500
	bHidden=true
	bBurning=true
	AmbientSound=sound'dnsWeapn.Flamethrower.FTFBallTravelLp'
	SoundVolume=220
	SoundRadius=32
	FlameClass=class'dnFlameThrowerFX_BallFire'
	FireWallStarterClass=class'FireWallStarter'
	FireWallCruiserClass=class'FireWallCruiser'
}