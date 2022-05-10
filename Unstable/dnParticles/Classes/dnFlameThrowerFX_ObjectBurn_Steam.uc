//=============================================================================
// dnFlameThrowerFX_ObjectBurn_Steam. 	   June 27th, 2001 - Charlie Wiederhold
//=============================================================================
class dnFlameThrowerFX_ObjectBurn_Steam expands dnFlameThrowerFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     bIgnoreBList=True
     DestroyWhenEmptyAfterSpawn=True
     AdditionalSpawn(0)=(Mount=True)
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=8
     MaximumParticles=8
     Lifetime=1.500000
     LifetimeVariance=0.250000
     InitialVelocity=(Z=32.000000)
     MaxVelocityVariance=(X=32.000000,Y=32.000000,Z=32.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.Smoke.gensmoke1dRC'
     DrawScaleVariance=0.125000
     StartDrawScale=0.125000
     EndDrawScale=0.625000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=1.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_Disable
     AlphaStart=0.625000
     AlphaMid=0.750000
     AlphaEnd=0.000000
     AlphaRampMid=0.250000
     CollisionRadius=12.000000
     CollisionHeight=12.000000
     Style=STY_Translucent
     bUnlit=True
}
