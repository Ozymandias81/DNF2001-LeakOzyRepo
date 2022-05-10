//=============================================================================
// dnLargeGibEffect.               Created by Charlie Wiederhold April 12, 2000
//=============================================================================
class dnLargeGibEffect expands dnDecorationBigFrag;

// Generic large Gib actor effect.

defaultproperties
{
     FragType(0)=None
     NumberFragPieces=0
     DamageOnHitWall=1000
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnWaterSpray_Effect1')
     SpawnOnDestroyed(1)=(SpawnClass=Class'dnParticles.dnWaterSpray_Effect2')
     VisibilityRadius=65535.000000
     VisibilityHeight=4096.000000
}
