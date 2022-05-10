//=============================================================================
// dnWake_Stationary. 					October 12th, 2000 - Charlie Wiederhold
//=============================================================================
class dnWake_Stationary expands dnLakeMeadFX;

// Water wake effect for the stationary boat.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     SpawnPeriod=0.050000
     PrimeTimeIncrement=1.000000
     MaximumParticles=45
     Lifetime=2.500000
     LifetimeVariance=1.000000
     InitialVelocity=(Y=1224.000000,Z=0.000000)
     InitialAcceleration=(Y=128.000000)
     MaxVelocityVariance=(X=30.000000,Y=80.000000)
     RealtimeVelocityVariance=(X=32.000000,Y=100.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.waterwake.wake2aRC'
     Textures(1)=Texture't_generic.waterwake.wake2bRC'
     Textures(2)=Texture't_generic.waterwake.wake2cRC'
     Textures(3)=Texture't_generic.waterwake.wake2dRC'
     Textures(4)=Texture't_generic.waterwake.wake2eRC'
     Textures(5)=Texture't_generic.waterwake.wake2hRC'
     DrawScaleVariance=3.000000
     StartDrawScale=0.500000
     EndDrawScale=20.000000
     AlphaStart=0.500000
     AlphaEnd=0.000000
     UpdateWhenNotVisible=True
     Physics=PHYS_MovingBrush
     bDirectional=True
     bEdShouldSnap=True
     Style=STY_Translucent
     bUnlit=True
}
