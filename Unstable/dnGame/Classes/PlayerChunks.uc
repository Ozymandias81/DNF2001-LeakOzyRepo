/*-----------------------------------------------------------------------------
	PlayerChunks
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class PlayerChunks extends CreatureChunks;

function PostBeginPlay()
{
	Super.PostBeginPlay();

//	LoopAnim('fly');
}

simulated function Landed(vector HitNormal)
{
	Super.Landed(HitNormal);

	PlayAnim('land');
}

defaultproperties
{
	TrailClass=Class'dnParticles.dnBloodFX_BloodTrail'
	AmbientGlow=60
	Mass=+00030.000000
	Buoyancy=+00018.000000
	RemoteRole=ROLE_None
	bBloodPool=false
	CollisionRadius=10
	CollisionHeight=4
}
