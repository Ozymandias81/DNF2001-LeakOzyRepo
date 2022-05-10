//=============================================================================
// dnBrainBlastFX_ImpactSpawnerB.
//=============================================================================
class dnBrainBlastFX_ImpactSpawnerB expands dnBrainBlastFX_ImpactSpawnerA;

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnBrainBlastFX_ImpactFlashB')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnBrainBlastFX_ImpactFireB')
     EndDrawScale=10.000000
     DamageRadius=80.000000
     MomentumTransfer=50000.000000
     AlphaStart=0.600000
     AlphaMid=0.400000
}
