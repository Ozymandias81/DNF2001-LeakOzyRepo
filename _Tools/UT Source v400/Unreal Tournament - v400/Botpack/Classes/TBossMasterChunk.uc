//=============================================================================
// TBossMasterChunk
//=============================================================================
class TBossMasterChunk extends UTMasterCreatureChunk;

simulated function ClientExtraChunks()
{
	local carcass carc;
	local UT_bloodburst b;
	local PlayerPawn P;

	If ( Level.NetMode == NM_DedicatedServer )
		return;
	if ( class'GameInfo'.Default.bLowGore )
	{
		Destroy();
		return;
	}

	b = Spawn(class 'UT_BloodBurst');
	if ( bGreenBlood )
		b.GreenBlood();
	b.RemoteRole = ROLE_None;

	if ( (CarcassAnim != 'Dead4') && (CarcassAnim != 'Dead5') )
	{
		carc = Spawn(class'UT_BossHead');
		if ( carc != None )
			carc.Initfor(self);
	}

	if ( CarcassAnim != 'Dead5' )
	{
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
				carc = Spawn(class 'UT_MaleFoot');
				if (carc != None)
					carc.Initfor(self);
			}
		}
		carc = Spawn(class 'UT_MaleTorso');
		if (carc != None)
			carc.Initfor(self);
		carc = Spawn(class 'UT_BossArm');
		if (carc != None)
			carc.Initfor(self);
	}
	if ( !Level.bDropDetail )
	{
		carc = Spawn(class 'UT_MaleFoot');
		if (carc != None)
			carc.Initfor(self);
	}
	carc = Spawn(class 'UT_BossThigh');
	if (carc != None)
		carc.Initfor(self);
}

defaultproperties
{
}