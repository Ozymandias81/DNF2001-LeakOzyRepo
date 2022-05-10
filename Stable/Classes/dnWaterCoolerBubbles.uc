//=============================================================================
// dnWaterCoolerBubbles
//====================================Created Sept 6th, 2000 - Brandon Reinhart
class dnWaterCoolerBubbles extends SoftParticleSystem;

defaultproperties
{
     Enabled=False
     SpawnPeriod=0.080000
     MaximumParticles=16
     Lifetime=0.200000
     InitialVelocity=(Z=40.000000)
     MaxVelocityVariance=(X=24.000000,Y=24.000000,Z=10.000000)
     RealtimeVelocityVariance=(X=200.000000,Y=200.000000,Z=10.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.bubbles.bubbles1fRC'
     Textures(1)=Texture't_generic.bubbles.bubbles1hRC'
     Textures(2)=Texture't_generic.bubbles.bubbles1eRC'
     Textures(3)=Texture't_generic.bubbles.bubbles1dRC'
     DrawScaleVariance=0.080000
     StartDrawScale=0.140000
     EndDrawScale=0.180000
     AlphaStart=0.600000
     AlphaEnd=0.280000
     RotationInitial=10.000000
     RotationVariance=10.000000
     RotationVelocityMaxVariance=20.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_Pulse
     PulseSeconds=0.600000
     Style=STY_Translucent
     DrawScale=0.050000
     CollisionRadius=1.800000
     CollisionHeight=1.000000
}
