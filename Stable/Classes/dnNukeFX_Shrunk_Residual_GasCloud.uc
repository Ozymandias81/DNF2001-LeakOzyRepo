//=============================================================================
// dnNukeFX_Shrunk_Residual_GasCloud. 					November 1st, 2000 - Charlie Wiederhold
//=============================================================================
class dnNukeFX_Shrunk_Residual_GasCloud expands dnNukeFX_Shrunk;

// Creates the gas cloud that hovers around a gas spawner

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     bIgnoreBList=True
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     SpawnPeriod=0.500000
     Lifetime=10.000000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_generic.Smoke.greensmoke1aRC'
     DrawScaleVariance=0.500000
     StartDrawScale=1.500000
     EndDrawScale=1.500000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=0.175000
     UpdateWhenNotVisible=True
     TriggerAfterSeconds=2.500000
     TriggerType=SPT_Pulse
     PulseSeconds=20.000000
     AlphaStart=0.000000
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.250000
     bUseAlphaRamp=True
     CollisionRadius=128.000000
     CollisionHeight=64.000000
     bCollideActors=True
     Style=STY_Translucent
}
