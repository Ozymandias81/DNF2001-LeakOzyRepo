//=============================================================================
// dnMeadDropShip_JetRoot. 				October 18th, 2000 - Charlie Wiederhold
//=============================================================================
class dnMeadDropShip_JetRoot expands dnMeadDropShip_JetExploder;

// Invisible actor that the jet engines are spawned from and rooted to.

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'dnParticles.dnDropShip_BlueJets')
     MountOnSpawn(1)=(ActorClass=Class'dnParticles.dnDropShip_FireJet')
     MountOnSpawn(2)=(ActorClass=Class'dnParticles.dnDropShip_SmokeJet')
     MountOnSpawn(3)=(ActorClass=Class'U_Zone2_Dam.dnMeadDropShip_JetExploder',SetMountOrigin=True,MountOrigin=(Z=32.000000),TakeParentTag=True)
     DamageOnTrigger=0
     SpawnOnDestroyed(0)=(SpawnClass=None)
     HealthPrefab=HEALTH_NeverBreak
}
