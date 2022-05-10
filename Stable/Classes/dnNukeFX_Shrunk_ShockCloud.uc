//=============================================================================
// dnNukeFX_Shrunk_ShockCloud. 							June 5th, 2001 - Charlie Wiederhold
//=============================================================================
class dnNukeFX_Shrunk_ShockCloud expands dnNukeFX_Shrunk;

#exec OBJ LOAD FILE=..\Textures\afbproship.dtx

defaultproperties
{
     bIgnoreBList=True
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=2
     MaximumParticles=2
     Lifetime=0.650000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture'AFBProShip.WMD.shockwavetw'
     StartDrawScale=0.000000
     EndDrawScale=5.000000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.750000
     bUseAlphaRamp=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
