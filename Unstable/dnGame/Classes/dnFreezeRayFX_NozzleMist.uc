//=============================================================================
// dnFreezeRayFX_NozzleMist. 				May 25th, 2001 - Charlie Wiederhold
//=============================================================================
	class dnFreezeRayFX_NozzleMist expands dnFreezeRayFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     SpawnPeriod=0.050000
     Lifetime=0.750000
     RelativeSpawn=True
     InitialVelocity=(X=80.000000,Z=0.000000)
     InitialAcceleration=(Z=160.000000)
     MaxVelocityVariance=(X=64.000000,Y=32.000000,Z=32.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_generic.Rain.genrain7RC'
     StartDrawScale=0.500000
     EndDrawScale=2.000000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     TriggerOnSpawn=False
     AlphaEnd=0.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
