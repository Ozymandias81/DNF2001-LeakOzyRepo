//=============================================================================
// TFemaleMasterChunk
//=============================================================================
class TFemaleMasterChunk extends UTMasterCreatureChunk;

simulated function ClientExtraChunks()
{
	local carcass carc;
	local UT_BloodBurst b;
	local PlayerPawn P;

	If ( Level.NetMode == NM_DedicatedServer )
		return;
	if ( class'GameInfo'.Default.bLowGore )
	{
		Destroy();
		return;
	}

	b = Spawn(class 'UT_Bloodburst');
	if ( bGreenBlood )
		b.GreenBlood();
	b.RemoteRole = ROLE_None;

	if ( CarcassAnim != 'Dead6' )
	{
		carc = Spawn(class'UT_HeadFemale');
		if ( carc != None )
			carc.Initfor(self);
	}

	// arm, leg and thigh
	if ( Level.bHighDetailMode && !Level.bDropDetail )
	{
		if ( FRand() < 0.3 )
		{
			carc = Spawn(class 'UTLiver');
			if (carc != None)
				carc.Initfor(self);
		}
		else if ( FRand() < 0.5 )
		{
			carc = Spawn(class 'UTStomach');
			if (carc != None)
				carc.Initfor(self);
		}
		else
		{
			carc = Spawn(class 'UTHeart');
			if (carc != None)
				carc.Initfor(self);
		}
		if ( FRand() < 0.5 )
		{
			carc = Spawn(class 'UT_FemaleFoot');
			if (carc != None)
				carc.Initfor(self);
		}
	}

	carc = Spawn(class 'UT_Thigh');
	if (carc != None)
		carc.Initfor(self);
	carc = Spawn(class 'UT_FemaleTorso');
	if (carc != None)
		carc.Initfor(self);
	if ( !Level.bDropDetail )
	{
		carc = Spawn(class 'UT_FemaleFoot');
		if (carc != None)
			carc.Initfor(self);
	}

	carc = Spawn(class 'UT_FemaleArm');
	if (carc != None)
		carc.Initfor(self);
}

defaultproperties
{
}