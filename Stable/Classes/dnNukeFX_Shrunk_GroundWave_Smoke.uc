//=============================================================================
// dnNukeFX_Shrunk_GroundWave_Smoke.				June 5th, 2001 - Charlie Wiederhold
//=============================================================================
class dnNukeFX_Shrunk_GroundWave_Smoke expands dnNukeFX_Shrunk;

#exec OBJ LOAD FILE=..\Textures\t_firefx.dtx

defaultproperties
{
     DestroyWhenEmptyAfterSpawn=True
     SpawnNumber=4
     SpawnPeriod=0.075000
     Lifetime=3.000000
     RelativeSpawn=True
     SpawnAtRadius=True
     InitialVelocity=(Z=0.000000)
     InitialAcceleration=(Z=4.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     ApexInitialVelocity=48.000000
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_firefx.firespray.Flamestill1dRC'
     Textures(1)=Texture't_firefx.firespray.flamehotend1RC'
     StartDrawScale=0.062500
     EndDrawScale=0.375000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=2.000000
     UpdateWhenNotVisible=True
     TriggerAfterSeconds=3.000000
     TriggerType=SPT_Disable
     PulseSeconds=0.750000
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.750000
     bUseAlphaRamp=True
     CollisionRadius=4.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
     bIgnoreBList=True
}
