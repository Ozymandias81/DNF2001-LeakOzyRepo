/*-----------------------------------------------------------------------------
	HitPackage_GlassDir
	Author: Brandon Reinhart

	For extended directonal glass breaks.
-----------------------------------------------------------------------------*/
class HitPackage_GlassDir extends HitPackage_Glass;

var float DirX, DirY, DirZ;

replication
{
	reliable if ( Role == ROLE_Authority )
		DirX, DirY, DirZ;
}

simulated function Deliver()
{
	// Notify the glass that we hit it.
	Seed(RandomSeed);
	BreakableGlass(Owner).BreakGlassDir( Location, vect(DirX,DirY,DirZ), DirForceScale );
}

defaultproperties
{
}