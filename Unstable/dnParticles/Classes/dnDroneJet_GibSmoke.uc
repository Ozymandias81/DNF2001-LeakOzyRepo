//=============================================================================
// dnDroneJet_GibSmoke.            Created by Charlie Wiederhold April 18, 2000
//=============================================================================
class dnDroneJet_GibSmoke expands dnSmokeEffect;

// Smoke trail for the gibs of a blown up Drone Jet
// Does NOT do damage. 

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     SpawnPeriod=0.025000
     PrimeCount=0
     MaximumParticles=0
     Lifetime=1.250000
     LifetimeVariance=0.000000
     RelativeSpawn=False
     InitialVelocity=(X=16.000000,Y=16.000000,Z=64.000000)
     InitialAcceleration=(X=0.000000,Z=64.000000)
     MaxVelocityVariance=(Z=32.000000)
     MaxAccelerationVariance=(Z=32.000000)
     Textures(0)=Texture't_generic.Smoke.gensmoke5aRC'
     Textures(1)=None
     Textures(2)=None
     Textures(3)=None
     DrawScaleVariance=3.000000
     StartDrawScale=1.000000
     EndDrawScale=3.000000
     AlphaStart=1.000000
     AlphaEnd=1.000000
     TriggerOnDismount=True
     TriggerType=SPT_Disable
     PulseSeconds=0.000000
     VisibilityRadius=65535.000000
     VisibilityHeight=4096.000000
}
