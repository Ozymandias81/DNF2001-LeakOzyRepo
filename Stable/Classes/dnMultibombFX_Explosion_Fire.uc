//=============================================================================
// dnMultibombFX_Explosion_Fire.							June 28th, 2001 - Charlie Wiederhold
//=============================================================================
class dnMultibombFX_Explosion_Fire expands dnMultibombFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Textures\t_explosionFx.dtx

defaultproperties
{
     DestroyWhenEmpty=True
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=4
     Lifetime=2.100000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=32.000000,Y=32.000000,Z=8.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_explosionFx.explosions.Fije_004'
     DrawScaleVariance=1.000000
     StartDrawScale=2.00000
     EndDrawScale=2.00000
     RotationVariance=6.240000
     RotationVelocityMaxVariance=0.2500000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     SpriteProjForward=32.000000
     CollisionRadius=48.000000
     CollisionHeight=32.000000
     Style=STY_Translucent
     bUnlit=True
     bIgnoreBList=True
}
