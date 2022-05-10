//=============================================================================
// dnMeadDropShip_MountedFX. 			October 19th, 2000 - Charlie Wiederhold
//=============================================================================
class dnMeadDropShip_MountedFX expands dnMeadDropShip;

// Invisible actor that all the mounted effects are attached to for the
// Drop Ship.

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'dnParticles.dnDropShip_CrashSplash1',MountType=MOUNT_Actor,MountMeshItem=None,AppendToTag=CrashSplash)
     MountOnSpawn(1)=(ActorClass=Class'dnParticles.dnDropShip_CrashSplash2',MountType=MOUNT_Actor,MountMeshItem=None,AppendToTag=CrashSplash)
     MountOnSpawn(2)=(ActorClass=Class'dnParticles.dnDropShip_BlackSmoke',MountOrigin=(X=-96.000000,Z=32.000000),MountType=MOUNT_Actor,MountMeshItem=None,AppendToTag=PreSmoke1)
     MountOnSpawn(3)=(ActorClass=Class'dnParticles.dnDropShip_BlackSmoke',MountOrigin=(X=256.000000,Z=32.000000),MountType=MOUNT_Actor,MountMeshItem=None,AppendToTag=PreSmoke2)
     MountOnSpawn(4)=(ActorClass=Class'dnParticles.dnDropShip_DoorSmoke',MountOrigin=(X=-256.000000,Y=64.000000),AppendToTag=DoorSmoke)
     MountOnSpawn(5)=(ActorClass=Class'dnParticles.dnDropShip_DoorSmoke',MountOrigin=(Y=-64.000000),AppendToTag=DoorSmoke)
     MountOnSpawn(6)=(ActorClass=Class'dnParticles.dnDropShip_DoorSmoke',MountOrigin=(Y=0.000000),AppendToTag=JetskiSpawnLocation)
     HealthMarkers(0)=(Threshold=0,PrefixTagToEvent=False,TriggerEvent=None)
     HealthMarkers(1)=(Threshold=0,PrefixTagToEvent=False,TriggerEvent=None)
     HealthMarkers(2)=(Threshold=0,PrefixTagToEvent=False,TriggerEvent=None)
     HealthMarkers(3)=(Threshold=0,PrefixTagToEvent=False,TriggerEvent=None)
     SpawnOnHit=None
     HealthPrefab=HEALTH_NeverBreak
     Health=100
     bHidden=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bCollideActors=False
     bBlockActors=False
     bBlockPlayers=False
     WaterSplashClass=None
     DrawType=DT_Sprite
     Texture=Texture'hud_effects.ingame_hud.am_hypogun'
     Mesh=None
}
