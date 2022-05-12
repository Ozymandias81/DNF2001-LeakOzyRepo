//=============================================================================
// SawHit.
//=============================================================================
class SawHit extends UT_WallHit;

simulated function SpawnSound()
{
}

simulated function SpawnEffects()
{
	local Actor A;
	local int j;
	local int NumSparks;

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
			A = spawn(class'Chip',,,Location + 8 * Vector(Rotation));
			if ( A != None )
				A.RemoteRole = ROLE_None;
		}

	if ( !Level.bHighDetailMode )
	{
		Destroy();
		return;
	}
	Spawn(class'WallCrack');

	A = Spawn(class'UT_SpriteSmokePuff',,,Location + 8 * Vector(Rotation));
	A.RemoteRole = ROLE_None;
	if ( Region.Zone.bWaterZone || Level.bDropDetail )
	{
		Destroy();
		return;
	}
	Spawn(class'UT_Sparks');
	if ( NumSparks > 0 ) 
		for (j=0; j<NumSparks; j++) 
			spawn(class'UT_Spark',,,Location + 8 * Vector(Rotation));
	Destroy();
}

defaultproperties
{
	ChipOdds=+0.7
	MaxSparks=4
}
