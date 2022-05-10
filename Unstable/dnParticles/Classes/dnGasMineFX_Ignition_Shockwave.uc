//=============================================================================
// dnGasMineFX_Ignition_Shockwave. 							June 27th, 2001 - Charlie Wiederhold
//=============================================================================
class dnGasMineFX_Ignition_Shockwave expands dnGasMineFX;

#exec OBJ LOAD FILE=..\Textures\dnmodulation.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=2
     MaximumParticles=2
     Lifetime=0.425000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture'dnModulation.firebites3stw'
     StartDrawScale=0.000000
     EndDrawScale=12.000000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     AlphaMid=1.000000
     AlphaEnd=0.000000
     bUseAlphaRamp=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
     bIgnoreBList=True
}
