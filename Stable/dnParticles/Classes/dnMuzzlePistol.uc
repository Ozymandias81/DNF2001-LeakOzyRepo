//=============================================================================
// dnMuzzlePistol.               				created by AB (c)April 12, 2000
//=============================================================================
class dnMuzzlePistol expands dnMuzzleFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Textures\t_explosionFx.dtx

defaultproperties
{
     GroupID=999
//     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnMuzzlePistolSmoke',Mount=True)
  //   AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnMuzzlePistolSmoke2')
     spawnPeriod=0.000000
     PrimeTime=0.450000
     PrimeTimeIncrement=0.030000
     Lifetime=0.750000
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(X=48.000000,Z=0.000000)
     InitialAcceleration=(X=-96.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_explosionFx.explosion64.R301_090'
     DrawScaleVariance=0.040000
     StartDrawScale=0.130000
     EndDrawScale=0.000000
     AlphaStart=0.300000
     AlphaEnd=0.150000
     RotationVariance=4000.000000
     TriggerType=SPT_Pulse
     PulseSeconds=0.000001
     bHidden=True
     Physics=PHYS_MovingBrush
     LifeSpan=0.07
     bDirectional=True
     Style=STY_Translucent
     DrawScale=0.250000
     CollisionRadius=0.250000
     CollisionHeight=0.250000
}
