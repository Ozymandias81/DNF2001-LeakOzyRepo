//=============================================================================
// dnSpawnFX_ItemSpawn. 				   March 7th, 2001 - Charlie Wiederhold
//=============================================================================
class dnSpawnFX_ItemSpawn expands dnSpawnFX;

// Effect for when an item spawns into the world.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DestroyWhenEmptyAfterSpawn=True
     SpawnPeriod=0.010000
     Lifetime=0.255000
     SpawnAtRadius=True
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     Apex=(Z=-64.000000)
     ApexInitialVelocity=-256.000000
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.particle_efx.pflare2'
     Textures(1)=Texture't_generic.particle_efx.pflare1'
     Textures(2)=Texture't_generic.particle_efx.pflare3'
     StartDrawScale=0.150000
     AlphaStart=0.000000
     UpdateWhenNotVisible=True
     TriggerAfterSeconds=0.500000
     TriggerType=SPT_Disable
     Style=STY_Translucent
     CollisionRadius=32.000000
     CollisionHeight=4.000000
}
