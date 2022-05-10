//=============================================================================
// dnM16GrenadeTrail.                           created by AB (c)April 18, 2000
//=============================================================================
class dnM16GrenadeTrail expands dnMuzzleFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     spawnPeriod=0.050000
     Lifetime=0.500000
     LifetimeVariance=1.000000
     RelativeSpawn=True
     InitialVelocity=(Z=100.000000)
     MaxVelocityVariance=(X=32.000000,Y=32.000000,Z=32.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_generic.Smoke.gensmoke1aRC'
     DrawScaleVariance=0.250000
     StartDrawScale=0.200000
     EndDrawScale=0.500000
     AlphaStart=0.250000
     AlphaEnd=0.000000
     RotationVariance=3.140000
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=0.600000
     PulseSecondsVariance=0.200000
     bHidden=True
     Physics=PHYS_MovingBrush
     Style=STY_Translucent
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
