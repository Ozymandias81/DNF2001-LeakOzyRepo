//=============================================================================
// UT_HeavyWallHitEffect.
//=============================================================================
class UT_HeavyWallHitEffect extends UT_WallHit;


simulated function SpawnSound()
{
	local float decision;

	decision = FRand();
	if ( decision < 0.5 ) 
		PlaySound(sound'ricochet',, 4,,1200, 0.5+FRand());		
	else if ( decision < 0.75 )
		PlaySound(sound'Impact1',, 4,,1000);
	else
		PlaySound(sound'Impact2',, 4,,1000);
}

simulated function SpawnEffects()
{
	local Actor A;
	local int j;
	local int NumSparks;
	local vector Dir;

	if ( Role == ROLE_Authority )
		RealRotation = Rotation;
	else
		SetRotation(RealRotation);

	SpawnSound();

	NumSparks = rand(MaxSparks);
	for ( j=0; j<MaxChips; j++ )
		if ( FRand() < ChipOdds ) 
		{
			NumSparks--;
			A = spawn(class'Chip');
			if ( A != None )
				A.RemoteRole = ROLE_None;
		}

	Dir = Vector(Rotation);
	if ( !Level.bHighDetailMode )
		return;
	Spawn(class'Pock');
	A = Spawn(class'UT_SpriteSmokePuff',,,Location + 8 * Vector(Rotation));
	A.RemoteRole = ROLE_None;
	if ( Region.Zone.bWaterZone || Level.bDropDetail )
		return;
	if ( FRand() < 0.4 )
		Spawn(class'UT_Sparks');
	if ( NumSparks > 0 ) 
		for (j=0; j<NumSparks; j++) 
			spawn(class'UT_Spark',,,Location + 8 * Vector(Rotation));
}

defaultproperties
{
	ChipOdds=+0.5
	MaxSparks=4
}
