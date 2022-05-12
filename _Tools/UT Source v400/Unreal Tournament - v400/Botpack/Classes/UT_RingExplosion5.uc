//=============================================================================
// ut_Ringexplosion5.
//=============================================================================
class UT_RingExplosion5 extends UT_RingExplosion;

simulated function SpawnExtraEffects()
{
	 Spawn(class'EnergyImpact');
	 bExtraEffectsSpawned = true;
}

defaultproperties
{
	 bExtraEffectsSpawned=false
}
