//=============================================================================
// dnLaserHitFX_FlashSpawnerA. 			  April 18th, 2001 - Charlie Wiederhold
//=============================================================================
class dnLaserHitFX_FlashSpawnerA expands dnLaserHitFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(Mount=True)
     SpawnNumber=0
     PrimeCount=2
     PrimeTimeIncrement=0.000000
     MaximumParticles=2
     Lifetime=0.100000
     RelativeLocation=True
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture'm_dnWeapon.lazerblast.lazerflare2RC'
     StartDrawScale=0.000000
     EndDrawScale=0.175000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     AlphaMid=1.000000
     AlphaRampMid=1.000000
     bBurning=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
     bIgnoreBList=True
}
