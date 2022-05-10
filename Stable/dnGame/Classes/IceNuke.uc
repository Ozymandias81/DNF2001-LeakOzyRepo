/*-----------------------------------------------------------------------------
	IceNuke
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class IceNuke expands dnGrenade;

simulated function Landed( vector HitNormal )
{
	Explode( Location + vect(0,0,64) );
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	Explode( Location + vect(0,0,64) );
}

defaultproperties
{
	ExplosionClass=class'dnWeaponFX_IceNukeSphere'
}