//=============================================================================
// dnDroneJet_BaseGib2.
//=============================================================================
class dnDroneJet_BaseGib2 expands dnDroneJet_BaseGib;

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'dnParticles.dnDroneJet_GibFire2',SurviveDismount=False)
     MountOnSpawn(1)=(ActorClass=Class'dnParticles.dnDroneJet_GibFire2')
     BounceElasticity=0.250000
     SpawnOnDestroyed(0)=(SpawnClass=None)
     SpawnOnDestroyed(1)=(SpawnClass=None)
     DrawScale=0.125000
}
