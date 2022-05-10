//=============================================================================
// dnExplosiveBarrelFire.
//=============================================================================
class dnExplosiveBarrelFire expands dnFireEffect;

defaultproperties
{
     Enabled=False
     PrimeCount=1
     Lifetime=0.500000
     LifetimeVariance=0.200000
     RelativeLocation=False
     RelativeRotation=False
     RelativeSpawn=True
     SpawnAtApex=True
     InitialVelocity=(X=0.000000,Z=150.000000)
     InitialAcceleration=(Y=0.000000,Z=0.000000)
     MaxVelocityVariance=(X=180.000000,Y=180.000000)
     Apex=(Z=25.000000)
     Textures(1)=Texture't_generic.fireflames.flame2aRC'
     Textures(2)=Texture't_generic.fireflames.flame3aRC'
     Textures(3)=Texture't_generic.fireflames.flame4bRC'
     DieOnLastFrame=True
     DrawScaleVariance=0.250000
     EndDrawScale=0.250000
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=4.000000
     DamageRadius=0.000000
     MomentumTransfer=0.000000
}
