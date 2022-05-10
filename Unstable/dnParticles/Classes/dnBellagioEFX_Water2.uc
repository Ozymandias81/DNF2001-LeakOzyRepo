//=============================================================================
// dnBellagioEFX_Water2. ( AHB3d )
//=============================================================================
class dnBellagioEFX_Water2 expands dnBellagioEFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

// Bellagio Water Fountain effect
// Rotate towards the +X axis

defaultproperties
{
     Enabled=False
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnBellagioEFX_Water2_1')
     SpawnPeriod=0.025000
     Lifetime=2.000000
     RelativeSpawn=True
     InitialVelocity=(X=1200.000000,Z=0.000000)
     InitialAcceleration=(X=50.000000,Z=100.000000)
     MaxVelocityVariance=(X=300.000000,Y=0.000000)
     Textures(0)=Texture't_generic.bubbles.bubbles1aRC'
     DrawScaleVariance=1.000000
     StartDrawScale=0.250000
     EndDrawScale=3.000000
     AlphaEnd=0.000000
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=2.000000
     Physics=PHYS_MovingBrush
     LifeSpan=5.000000
     Style=STY_Translucent
     VisibilityRadius=16384.000000
     VisibilityHeight=16384.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bFixedRotationDir=True
     RotationRate=(Pitch=3000)
}
