//=============================================================================
// dnFireworks2a. ( AHB3d )
//=============================================================================
class dnFireworks2a expands dnFireworks2;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     BSPOcclude=False
     DestroyWhenEmpty=False
     SpawnOnDestruction(0)=(SpawnClass=None)
     SpawnNumber=40
     SpawnPeriod=0.000000
     PrimeTime=0.000000
     PrimeTimeIncrement=0.000000
     MaximumParticles=40
     Lifetime=3.000000
     SpawnAtRadius=True
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(Z=256.000000)
     InitialAcceleration=(Z=1024.000000)
     MaxVelocityVariance=(X=512.000000,Y=512.000000,Z=512.000000)
     ApexInitialVelocity=1024.000000
     LineStartColor=(R=232,G=142,B=113)
     LineEndColor=(R=255,G=253,B=176)
     Textures(0)=Texture't_generic.particle_efx.pflare4ABC'
     DrawScaleVariance=0.020000
     StartDrawScale=6.000000
     EndDrawScale=0.010000
     AlphaStart=1.000000
     AlphaEnd=-1.000000
     RotationVariance=32768.000000
     RotationVelocity=2.000000
     RotationVelocityMaxVariance=4.000000
     PulseSeconds=6.000000
     PulseSecondsVariance=0.000000
     bHidden=True
     LifeSpan=5.000000
     VisibilityRadius=32768.000000
     VisibilityHeight=32768.000000
     DestroyOnDismount=False
}
