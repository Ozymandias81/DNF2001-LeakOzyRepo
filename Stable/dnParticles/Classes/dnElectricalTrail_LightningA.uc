//=============================================================================
// dnElectricalTrail_LightningA.
//=============================================================================
class dnElectricalTrail_LightningA expands dnElectricalTrail_Sparks;

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=None,Mount=False)
     SpawnNumber=2
     SpawnPeriod=0.100000
     LifetimeVariance=0.300000
     MaxVelocityVariance=(X=140.000000,Y=140.000000,Z=140.000000)
     MaxAccelerationVariance=(X=60.000000,Y=60.000000,Z=60.000000)
     RealtimeVelocityVariance=(X=20.000000,Y=20.000000,Z=20.000000)
     RealtimeAccelerationVariance=(X=8.000000,Y=8.000000,Z=8.000000)
     BounceElasticity=0.400000
     Bounce=True
     ParticlesCollideWithWorld=True
     UseZoneGravity=True
     LineStartColor=(R=17,G=166,B=255)
     LineEndColor=(R=6,G=162,B=255)
     LineStartWidth=6.000000
     LineEndWidth=6.000000
     Textures(0)=Texture't_generic.particle_efx.pflare5ABC'
     DrawScaleVariance=0.200000
     StartDrawScale=1.000000
     EndDrawScale=0.010000
     AlphaStart=0.700000
     AlphaMid=0.600000
     AlphaEnd=0.100000
     AlphaRampMid=0.600000
     bUseAlphaRamp=True
     CollisionRadius=16.000000
     CollisionHeight=16.000000
}
