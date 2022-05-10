//=============================================================================
// dnWallOil.                                                     created by AB
//=============================================================================
class dnWallOil expands dnWallFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnWallSpark')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnWallOilDrip')
     spawnPeriod=0.010000
     PrimeTime=0.100000
     PrimeTimeIncrement=0.100000
     Lifetime=0.750000
     LifetimeVariance=0.750000
     RelativeSpawn=True
     InitialVelocity=(X=96.000000,Z=64.000000)
     MaxVelocityVariance=(X=4.000000,Y=8.000000,Z=8.000000)
     BounceElasticity=0.250000
     Bounce=True
     ParticlesCollideWithWorld=True
     LineStartColor=(R=232,G=142,B=113)
     LineEndColor=(R=255,G=253,B=176)
     Textures(0)=Texture't_generic.Smoke.gensmoke2aRC'
     Textures(1)=Texture't_generic.Smoke.gensmoke2bRC'
     StartDrawScale=0.001000
     EndDrawScale=0.200000
     RotationVariance=32768.000000
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=3.500000
     PulseSecondsVariance=0.500000
     bHidden=True
     Physics=PHYS_MovingBrush
     Style=STY_Modulated
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bFixedRotationDir=True
     RotationRate=(Pitch=-6000)
}
