/*-----------------------------------------------------------------------------
	dnGasMineFX_Shrunk_Ignition_Residue
	Author: Charlie Wiederhold
-----------------------------------------------------------------------------*/
class dnGasMineFX_Shrunk_Ignition_Residue expands dnGasMineFX_Shrunk;

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
     InitialVelocity=(Z=2.000000)
     MaxVelocityVariance=(X=6.000000,Y=6.000000,Z=6.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_generic.Smoke.gensmoke1dRC'
     Textures(1)=Texture't_generic.Smoke.gensmoke1cRC'
     DrawScaleVariance=0.250000
     EndDrawScale=0.50000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=0.175000
     UpdateWhenNotVisible=True
     TriggerAfterSeconds=20.000000
     TriggerType=SPT_Disable
     AlphaStart=0.750000
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.100000
     CollisionRadius=64.000000
     CollisionHeight=32.000000
     Style=STY_Translucent
}
