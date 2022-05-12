//=============================================================================
// ut_SuperRing2.
//=============================================================================
class UT_SuperRing2 extends UT_SuperRing;

simulated function SpawnExtraEffects()
{
	local actor a;

	bExtraEffectsSpawned = true;
	a = Spawn(class'SuperShockExplo');
	a.RemoteRole = ROLE_None;

	Spawn(class'EnergyImpact');

	if ( Level.bHighDetailMode && !Level.bDropDetail )
	{
		a = Spawn(class'Ut_Superring');
		a.RemoteRole = ROLE_None;
	}
}

defaultproperties
{
	 bExtraEffectsSpawned=false
}
