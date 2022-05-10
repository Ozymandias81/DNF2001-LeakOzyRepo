//=============================================================================
// dnMeadDropShip.						October 12th, 2000 - Charlie Wiederhold
//=============================================================================
class dnMeadDropShip expands dnVehicles;

// Drop ship used exclusively for the Lake Mead map
// Whole lotta stuff spawned off of it.

#exec OBJ LOAD FILE=..\meshes\c_vehicles.dmx
#exec OBJ LOAD FILE=..\textures\m_vehicles.dtx
#exec OBJ LOAD FILE=..\sounds\a_transport.dfx

// Most of this stuff is going to be used heavily in the vehicle based maps, but I can
// see some cool stuff in the normal maps as well. It's really really simple to use.

// It has 4 SpecialEvents that are called when it reaches each 
// HealthMarker. By default the events are called <Tag>DamageLevel#. 
// This way you can have as many drop ships you want out there, and each one
// will call different events when they reach certain levels of damage.

// Each thruster is handled by itself and is named <Tag>Thrust#. The 
// engine is one, and when you trigger <Tag>Thrust# it turns off the 
// engine, spawns an explosion, and causes the engine to burn and smoke.
// After about 10 seconds the fire burns out but the engine will continue to
// smoke. You can only trigger an engine once, it won't turn back on (this is
// on purpose, it can change if there is a need).

// There are two black smoke streams that you can turn on and are named
// <Tag>EffectPreSmoke#. I use this to indicate damage to the ship before
// blowing up the engines.

// The rear door has opening animations, and to go along with that there is
// an effect for smoke spewing out called <Tag>EffectDoorSmoke.

// This version of the drop ship has a splash effect for when it hits 
// the water. <Tag>EffectCrashSplash. There currently isn't an explosion for
// it hitting the ground, but I can easily make one if people want it.
// Generally vehicles this big look best blowing up just barely over ledges.
// If anyone needs a version that blows up though, just let me know and I'll
// make it.

// Finally, this ship comes with JetSki spawners mounted named 
// <Tag>EffectJetskiSpawn_2. Again, if we need a version of it that 
// spawns something different out the back it will be easy to make. Just let
// me know.

// That's the gist of it. This should give you total control over unique
// ships in the map by using one TriggerSpawn.

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'U_Zone2_Dam.dnMeadDropShip_JetRoot',SetMountOrigin=True,MountType=MOUNT_MeshSurface,MountMeshItem=Thrust1,AppendToTag=Thrust1,TakeParentTag=True)
     MountOnSpawn(1)=(ActorClass=Class'U_Zone2_Dam.dnMeadDropShip_JetRoot',SetMountOrigin=True,MountType=MOUNT_MeshSurface,MountMeshItem=Thrust2,AppendToTag=Thrust2,TakeParentTag=True)
     MountOnSpawn(2)=(ActorClass=Class'U_Zone2_Dam.dnMeadDropShip_JetRoot',SetMountOrigin=True,MountType=MOUNT_MeshSurface,MountMeshItem=Thrust3,AppendToTag=Thrust3,TakeParentTag=True)
     MountOnSpawn(3)=(ActorClass=Class'U_Zone2_Dam.dnMeadDropShip_JetRoot',SetMountOrigin=True,MountType=MOUNT_MeshSurface,MountMeshItem=Thrust4,AppendToTag=Thrust4,TakeParentTag=True)
     MountOnSpawn(4)=(ActorClass=Class'U_Zone2_Dam.dnMeadDropShip_MountedFX',SetMountOrigin=True,AppendToTag=Effect,TakeParentTag=True)
     MountOnSpawn(5)=(SetMountOrigin=True,MountOrigin=(X=-256.000000),TakeParentTag=True)
     MountOnSpawn(6)=(SetMountOrigin=True,MountOrigin=(X=-64.000000,Y=48.000000,Z=-48.000000),TakeParentTag=True)
     MountOnSpawn(7)=(SetMountOrigin=True,MountOrigin=(X=-64.000000,Y=-48.000000,Z=-48.000000),TakeParentTag=True)
     HealthMarkers(0)=(Threshold=9800,PrefixTagToEvent=True,TriggerEvent=DamageLevel1)
     HealthMarkers(1)=(Threshold=9600,PrefixTagToEvent=True,TriggerEvent=DamageLevel2)
     HealthMarkers(2)=(Threshold=9400,PrefixTagToEvent=True,TriggerEvent=DamageLevel3)
     HealthMarkers(3)=(Threshold=9200,PrefixTagToEvent=True,TriggerEvent=DamageLevel4)
     HealthPrefab=HEALTH_UseHealthVar
     LodMode=LOD_StopMinimum
     VisibilityRadius=65535.000000
     VisibilityHeight=4096.000000
     Health=10000
     bNotTargetable=True
     CollisionRadius=488.000000
     CollisionHeight=160.000000
     bCollideWorld=False
     Physics=PHYS_MovingBrush
     Mesh=DukeMesh'c_vehicles.edfdropship'
     SoundRadius=255
     SoundVolume=255
}
