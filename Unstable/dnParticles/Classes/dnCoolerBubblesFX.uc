//=============================================================================
// dnCoolerBubblesFX.                         Created by Matt Wood Sept 3, 2000
//=============================================================================
class dnCoolerBubblesFX expands dnBubbleFX;

//water cooler class bubbles

defaultproperties
{
     Enabled=False
     MaximumParticles=20
     Lifetime=0.160000
     InitialVelocity=(Z=65.000000)
     MaxVelocityVariance=(X=32.000000,Y=32.000000,Z=10.000000)
     RealtimeVelocityVariance=(X=10.000000,Y=10.000000,Z=10.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.bubbles.bubbles1aRC'
     DrawScaleVariance=0.080000
     StartDrawScale=0.180000
     EndDrawScale=0.220000
     AlphaStart=0.500000
     AlphaEnd=0.500000
     RotationInitial=300.000000
     RotationVariance=32768.000000
     RotationVelocity=2.000000
     RotationVelocityMaxVariance=4.000000
     TriggerType=SPT_Pulse
     PulseSeconds=0.600000
     Style=STY_Translucent
     CollisionRadius=1.800000
     CollisionHeight=1.000000
}
