//=============================================================================
// dnNukeFX_Shrunk_dnNukeFX_Shrunk_MiddleCover. 						June 6th, 2001 - Charlie Wiederhold
//=============================================================================
class dnNukeFX_Shrunk_MiddleCover expands dnNukeFX_Shrunk;

#exec OBJ LOAD FILE=..\Textures\t_firefx.dtx

defaultproperties
{
     bIgnoreBList=True
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     SpawnNumber=2
     Lifetime=2.000000
     SpawnAtRadius=True
     RelativeLocation=True
     InitialVelocity=(Z=128.000000)
     InitialAcceleration=(Z=-64.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     ApexInitialVelocity=32.000000
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_firefx.firespray.flamehotend1RC'
     Textures(1)=Texture't_firefx.firespray.flamehotend3RC'
     Textures(2)=Texture't_firefx.firespray.Flamestill1dRC'
     Textures(3)=Texture't_firefx.firespray.Flamestill1aRC'
     Textures(4)=Texture't_firefx.firespray.flamehotend2RC'
     StartDrawScale=0.25000000
     EndDrawScale=0.750000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=2.000000
     UpdateWhenNotVisible=True
     TriggerAfterSeconds=2.000000
     TriggerType=SPT_Pulse
     PulseSeconds=2.500000
     SystemAlphaScale=0.000000
     SystemAlphaScaleVelocity=0.900000
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.750000
     bUseAlphaRamp=True
     CollisionRadius=4.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
