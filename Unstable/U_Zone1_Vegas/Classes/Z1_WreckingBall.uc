/*-----------------------------------------------------------------------------
	Z1_WreckingBall
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Z1_WreckingBall extends Zone1_Vegas;

function Landed(vector HitNormal)
{
	// Do nothing on landed.
}

function HitWall(vector HitNormal, actor Wall)
{
}

function Bump( actor Other )
{
	if ( Other.bIsPawn )
		Pawn(Other).TakeDamage( 1000, None, Location, vect(0,0,0), class'CrushingDamage' );
}

defaultproperties
{
	Mesh=mesh'c_zone1_vegas.crane_ball'
	CollisionHeight=80
	CollisionRadius=50
	HealthPrefab=HEALTH_NeverBreak
	MassPrefab=MASS_Heavy
	ItemName="Wrecking Ball"
	bTumble=false
}
