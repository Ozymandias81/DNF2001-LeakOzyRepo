//=============================================================================
// dnFreezeRayFX_IceNuke_ResidualCold.		May 28th, 2001 - Charlie Wiederhold
//=============================================================================
class dnFreezeRayFX_IceNuke_ResidualCold expands dnFreezeRayFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DestroyWhenEmptyAfterSpawn=True
     SpawnPeriod=0.750000
     Lifetime=5.000000
     InitialVelocity=(Z=-32.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     Textures(1)=Texture't_firefx.icespray2.iceshardC3RC'
     StartDrawScale=1.250000
     EndDrawScale=1.250000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     TriggerAfterSeconds=20.000000
     TriggerType=SPT_Disable
     SystemAlphaScale=1.500000
     AlphaStart=0.000000
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.250000
     bUseAlphaRamp=True
     CollisionRadius=96.000000
     CollisionHeight=32.000000
     Style=STY_Translucent
}
