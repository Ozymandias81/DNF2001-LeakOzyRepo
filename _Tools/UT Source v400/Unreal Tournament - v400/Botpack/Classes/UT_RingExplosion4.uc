//=============================================================================
// RingExplosion4.
//=============================================================================
class UT_RingExplosion4 extends ut_ComboRing;

simulated function SpawnExtraEffects()
{
	bExtraEffectsSpawned = true;
	SetRotation(Owner.Rotation);
}

simulated function SpawnEffects()
{
}

defaultproperties
{
	 bExtraEffectsSpawned=false
}