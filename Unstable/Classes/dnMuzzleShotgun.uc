//=============================================================================
// dnMuzzleShotgun.                             created by AB (c)April 13, 2000
//=============================================================================
class dnMuzzleShotgun expands dnMuzzleFX;

#exec OBJ LOAD FILE=..\Textures\m_dnweapon.dtx

defaultproperties
{
     GroupID=999
//     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnMuzzleShotgunSmoke',Mount=True)
  //   AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnMuzzleShotgunSmoke2')
     spawnPeriod=0.000000
     PrimeTime=0.800000
     PrimeTimeIncrement=0.060000
     Lifetime=0.800000
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(X=64.000000,Z=0.000000)
     InitialAcceleration=(X=-64.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_explosionFx.explosion64.R301_090'
     StartDrawScale=0.400000
     EndDrawScale=0.200000
     AlphaStart=0.200000
     AlphaEnd=0.000000
     RotationVariance=4000.000000
     PulseSeconds=0.000000
     bHidden=True
     Physics=PHYS_MovingBrush
     LifeSpan=0.1
     bDirectional=True
     Style=STY_Translucent
     DrawScale=0.500000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
