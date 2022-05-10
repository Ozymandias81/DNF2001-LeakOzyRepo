//=============================================================================
// dnEDFGJet.
//=============================================================================
class dnEDFGJet expands dnVehicles
	obsolete;

defaultproperties
{
     DelayedDamageTime=0.250000
     DelayedDamageAmount=1000
     FragType=None
     FragBaseScale=0.125000
     DamageOnHitWall=1000
     DamageOnHitWater=1000
     SpawnOnDestroyed(6)=(SpawnClass=Class'dnParticles.dnEDFGameExplosion')
     Physics=PHYS_MovingBrush
     Mesh=None
     DrawScale=0.125000
     CollisionRadius=32.000000
     CollisionHeight=7.000000
}
