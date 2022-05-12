//=============================================================================
// ImpactMark.
//=============================================================================
class ImpactMark extends UT_WallHit;

simulated function SpawnSound()
{
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
	Spawn(class'ImpactHole');
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
