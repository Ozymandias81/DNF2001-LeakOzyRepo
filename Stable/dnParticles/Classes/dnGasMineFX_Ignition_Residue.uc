/*-----------------------------------------------------------------------------
	dnGasMineFX_Ignition_Residue
	Author: Charlie Wiederhold
-----------------------------------------------------------------------------*/
class dnGasMineFX_Ignition_Residue expands dnGasMineFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     bIgnoreBList=True
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=8
     MaximumParticles=8
     Lifetime=9.000000
     LifetimeVariance=2.000000
     InitialVelocity=(Z=16.000000)
     MaxVelocityVariance=(X=24.000000,Y=24.000000,Z=24.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_generic.Smoke.gensmoke1dRC'
     Textures(1)=Texture't_generic.Smoke.gensmoke1cRC'
     DrawScaleVariance=1.00000
     EndDrawScale=2.00000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=0.175000
     UpdateWhenNotVisible=True
     TriggerAfterSeconds=20.000000
     TriggerType=SPT_Disable
     AlphaStart=0.750000
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.100000
     CollisionRadius=160.000000
     CollisionHeight=96.000000
     Style=STY_Translucent
}
