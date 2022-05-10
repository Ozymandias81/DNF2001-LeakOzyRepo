//=============================================================================
// dnSpawnFX_PlayerSpawn. 				   March 7th, 2001 - Charlie Wiederhold
//=============================================================================
class dnSpawnFX_PlayerSpawn expands dnSpawnFX;

// Effect for when an Player spawns into the world.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DestroyWhenEmptyAfterSpawn=True
     SpawnPeriod=0.010000
     Lifetime=0.350000
     SpawnAtRadius=True
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     Apex=(Z=-96.000000)
     ApexInitialVelocity=-256.000000
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.particle_efx.pflare2'
     Textures(1)=Texture't_generic.particle_efx.pflare1'
     Textures(2)=Texture't_generic.particle_efx.pflare3'
     StartDrawScale=0.250000
     EndDrawScale=1.500000
     AlphaStart=0.000000
     UpdateWhenNotVisible=True
     TriggerAfterSeconds=0.500000
     TriggerType=SPT_Disable
     Style=STY_Translucent
     CollisionRadius=48.000000
     CollisionHeight=4.000000
}
