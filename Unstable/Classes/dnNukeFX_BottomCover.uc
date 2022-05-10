//=============================================================================
// dnNukeFX_dnNukeFX_BottomCover. 						June 6th, 2001 - Charlie Wiederhold
//=============================================================================
class dnNukeFX_BottomCover expands dnNukeFX;

#exec OBJ LOAD FILE=..\Textures\t_firefx.dtx

defaultproperties
{
     bIgnoreBList=True
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     SpawnNumber=3
     Lifetime=2.000000
     SpawnAtRadius=True
     RelativeLocation=True
     InitialVelocity=(Z=512.000000)
     InitialAcceleration=(Z=-384.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     ApexInitialVelocity=192.000000
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_firefx.firespray.flamehotend1RC'
     Textures(1)=Texture't_firefx.firespray.flamehotend3RC'
     Textures(2)=Texture't_firefx.firespray.Flamestill1dRC'
     Textures(3)=Texture't_firefx.firespray.Flamestill1aRC'
     Textures(4)=Texture't_firefx.firespray.flamehotend2RC'
     StartDrawScale=0.500000
     EndDrawScale=2.000000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=2.000000
     UpdateWhenNotVisible=True
     TriggerAfterSeconds=1.000000
     TriggerType=SPT_Pulse
     PulseSeconds=3.500000
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.750000
     bUseAlphaRamp=True
     CollisionRadius=16.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
