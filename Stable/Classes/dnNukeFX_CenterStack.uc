//=============================================================================
// dnNukeFX_CenterStack.					June 6th, 2001 - Charlie Wiederhold
//=============================================================================
class dnNukeFX_CenterStack expands dnNukeFX;

#exec OBJ LOAD FILE=..\Textures\t_firefx.dtx

defaultproperties
{
     bIgnoreBList=True
     DestroyWhenEmptyAfterSpawn=True
     SpawnPeriod=0.075000
     Lifetime=2.000000
     RelativeSpawn=True
     SpawnAtRadius=True
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000,Z=64.000000)
     Apex=(Z=-512.000000)
     ApexInitialVelocity=224.000000
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_firefx.firespray.flamehotend1RC'
     Textures(2)=Texture't_firefx.firespray.flamehotend3RC'
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=2.000000
     UpdateWhenNotVisible=True
     TriggerAfterSeconds=4.000000
     TriggerType=SPT_Disable
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.750000
     bUseAlphaRamp=True
     CollisionRadius=128.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
