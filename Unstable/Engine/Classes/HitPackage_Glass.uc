/*-----------------------------------------------------------------------------
	HitPackage_Glass
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HitPackage_Glass extends HitPackage;

var byte RandomSeed;
var bool DirForce;
var float DirForceScale;

replication
{
	reliable if ( Role == ROLE_Authority )
		RandomSeed, DirForce, DirForceScale;
}

function PostBeginPlay()
{
	// Get a random random seed.
	// We use this to get identical break patterns on client and server.
	RandomSeed = Rand(100);
}

simulated function Deliver()
{
	// Notify the glass that we hit it.
	// Probably the only place BreakGlass should ever be called.
	Seed(RandomSeed);
	BreakableGlass(Owner).BreakGlass( Location, DirForce, DirForceScale );
}

defaultproperties
{
	DirForce=false
	DirForceScale=1.0
}