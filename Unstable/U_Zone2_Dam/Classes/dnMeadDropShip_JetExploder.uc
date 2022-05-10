//=============================================================================
// dnMeadDropShip_JetExploder.			October 12th, 2000 - Charlie Wiederhold
//=============================================================================
class dnMeadDropShip_JetExploder expands dnMeadDropShip;

// Invisible actor used to spawn the explosions on specific jets

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=None,MountType=MOUNT_Actor,MountMeshItem=None,AppendToTag=None)
     MountOnSpawn(1)=(ActorClass=None,MountOrigin=(Z=-48.000000),SetMountAngles=True,MountType=MOUNT_Actor,MountMeshItem=None,AppendToTag=None)
     MountOnSpawn(2)=(ActorClass=None,MountOrigin=(Z=-64.000000),MountType=MOUNT_Actor,MountMeshItem=None,AppendToTag=None)
     MountOnSpawn(3)=(ActorClass=None,SetMountOrigin=False,MountType=MOUNT_Actor,MountMeshItem=None,AppendToTag=None,TakeParentTag=False)
     MountOnSpawn(4)=(ActorClass=None,SetMountOrigin=False,TakeParentTag=False)
     MountOnSpawn(5)=(SetMountOrigin=False,MountOrigin=(X=0.000000),TakeParentTag=False)
     MountOnSpawn(6)=(SetMountOrigin=False,MountOrigin=(X=0.000000,Y=0.000000,Z=0.000000),TakeParentTag=False)
     MountOnSpawn(7)=(SetMountOrigin=False,MountOrigin=(X=0.000000,Y=0.000000,Z=0.000000),TakeParentTag=False)
     HealthMarkers(0)=(Threshold=0,TriggerEvent=None)
     HealthMarkers(1)=(Threshold=0,TriggerEvent=None)
     HealthMarkers(2)=(Threshold=0,TriggerEvent=None)
     HealthMarkers(3)=(Threshold=0,TriggerEvent=None)
     FragType(0)=None
     DamageOnTrigger=10
     SpawnOnHit=None
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion2_Spawner2')
     bTumble=False
     HealthPrefab=HEALTH_Easy
     VisibilityRadius=0.000000
     VisibilityHeight=0.000000
     Health=10
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
