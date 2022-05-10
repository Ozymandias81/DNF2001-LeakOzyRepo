//=============================================================================
// dnLaserHitFX_WallHitSpawnerA. 		  April 18th, 2001 - Charlie Wiederhold
//=============================================================================
class dnLaserHitFX_WallHitSpawnerA expands dnLaserHitFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(Mount=True)
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnLaserHitFX_WallHitSmoke',Mount=True)
     SpawnNumber=0
     PrimeCount=2
     PrimeTimeIncrement=0.000000
     MaximumParticles=2
     Lifetime=0.150000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture'm_dnWeapon.lazerblast.lazerblast3RC'
     Textures(1)=Texture'm_dnWeapon.lazerblast.lazerblast2RC'
     Textures(2)=Texture'm_dnWeapon.lazerblast.lazerblast1RC'
     DrawScaleVariance=0.250000
     StartDrawScale=0.000000
     EndDrawScale=0.500000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=2.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     AlphaMid=1.000000
     AlphaRampMid=0.900000
     VisibilityRadius=6000.000000
     VisibilityHeight=6000.000000
     bBurning=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
     bIgnoreBList=True
}
