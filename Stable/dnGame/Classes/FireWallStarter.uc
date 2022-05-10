/*-----------------------------------------------------------------------------
	FireWallStarter
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class FireWallStarter extends FireWallCruiser;

#exec OBJ LOAD FILE=..\sounds\dnsWeapn.dfx

var vector TravelDir, LastPos, SpawnLocation;
var float DistanceTraveled;
var rotator SpawnRot;
var int CruisersSpawned, SpawnDir, SpawnDist;
var class<FireWallCruiser> FireWallCruiserClass;

function PostBeginPlay()
{
	SetPhysics( PHYS_Walking );

	SpawnLocation = Location;
	LastPos = Location;
}

function Tick( float DeltaTime )
{
	local vector X, Y, Z, dir, realdir;
	local float cosAngle, dist;

	Acceleration = TravelDir * AccelRate;

	TimeAlive += DeltaTime;

	if ( (VSize(Velocity) < 10) && (TimeAlive > 0.5) )
	{
		Destroy();
		return;
	}

	dir = TravelDir;
	dir.Z = 0;
	dir = normal(dir);
	realdir = Location - LastPos;
	realdir.Z = 0;
	realdir = normal(realdir);

	cosAngle = realdir dot dir;

	if ( (acos(cosAngle)*(180/PI)>15) && (TimeAlive > 0.1) )
	{
		Destroy();
		return;
	}

	DistanceTraveled += VSize(Location - LastPos);
	if ( DistanceTraveled >= SpawnDist )
	{
		SpawnCruiser();
		DistanceTraveled = 0;
	}

	LastPos = Location;

}

function SpawnCruiser()
{
	local FireWallCruiser fwc;
	local vector X, Y, Z, offset;

//	PlaySound( sound'dnsWeapn.Flamethrower.FTFBallExplSec' );

	GetAxes( SpawnRot, X, Y, Z );
	offset = Y*SpawnDist*CruisersSpawned*SpawnDir;
	offset += SpawnLocation;
	offset.Z = Location.Z;
	fwc = spawn( FireWallCruiserClass, Instigator,, offset, SpawnRot );
	fwc.Instigator = Instigator;

	CruisersSpawned++;
	if ( CruisersSpawned >= 7 )
		Destroy();
}

event Touch( actor Other )
{
}

defaultproperties
{
	CollisionHeight=4
	CollisionRadius=4
	bCollideActors=false
	AccelRate=6000
	GroundSpeed=6000
	CruisersSpawned=1
	FireWallCruiserClass=class'FireWallCruiser'
	SpawnDist=32
}