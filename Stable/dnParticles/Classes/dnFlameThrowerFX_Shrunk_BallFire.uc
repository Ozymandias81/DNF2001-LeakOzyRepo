//=============================================================================
// dnFlamethrowerFX_Shrunk_BallFire. 				May 31st, 2001 - Charlie Wiederhold
//=============================================================================
class dnFlamethrowerFX_Shrunk_BallFire expands dnFlamethrowerFX_Shrunk;

#exec OBJ LOAD FILE=..\Textures\t_firefx.dtx

defaultproperties
{
     bIgnoreBList=True
     DestroyWhenEmptyAfterSpawn=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnFlamethrowerFX_Shrunk_BallFlame_Debris',Mount=True)
     SpawnPeriod=0.050000
     Lifetime=0.250000
     LifetimeVariance=0.125000
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_firefx.firespray.flameblast3RC'
     Textures(1)=Texture't_firefx.firespray.flameblast4RC'
     StartDrawScale=0.02500000
     EndDrawScale=0.075000
     UpdateWhenNotVisible=True
     TriggerType=SPT_Disable
     AlphaEnd=0.000000
     AlphaRampMid=0.900000
     bUseAlphaRamp=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
     LightType=LT_Steady
     LightBrightness=255
     LightHue=16
     LightSaturation=16
     LightRadius=4
}
