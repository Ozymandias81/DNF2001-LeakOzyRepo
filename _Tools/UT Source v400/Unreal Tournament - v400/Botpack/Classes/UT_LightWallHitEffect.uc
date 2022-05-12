//=============================================================================
// UT_LightWallHitEffect.
//=============================================================================
class UT_LightWallHitEffect extends UT_WallHit;

simulated function SpawnEffects()
{
	local Actor A;

	if ( Role == ROLE_Authority )
		RealRotation = Rotation;
	else
		SetRotation(RealRotation);

	if ( !Level.bDropDetail )
		SpawnSound();

	if ( !Level.bHighDetailMode )
		return;

	if ( Level.bDropDetail )
	{
		if ( FRand() > 0.4 )
			Spawn(class'Pock');
		return;
	}
	Spawn(class'Pock');

	A = Spawn(class'UT_SpriteSmokePuff',,,Location + 8 * Vector(Rotation));
	A.RemoteRole = ROLE_None;
	if ( Region.Zone.bWaterZone )
		return;
	if ( FRand() < 0.5 )
		spawn(class'UT_Spark',,,Location + 8 * Vector(Rotation));
}

defaultproperties
{
	MaxChips=0
	MaxSparks=1
}
