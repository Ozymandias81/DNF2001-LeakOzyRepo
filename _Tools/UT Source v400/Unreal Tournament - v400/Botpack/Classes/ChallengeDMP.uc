class ChallengeDMP expands DeathMatchPlus;

event InitGame( string Options, out string Error )
{
	bChallengeMode = True;

	Super.InitGame( Options, Error );
}

function InitRatedGame(LadderInventory LadderObj, PlayerPawn LadderPlayer)
{
	local Weapon W;

	Super.InitRatedGame(LadderObj, LadderPlayer);

	bCoopWeaponMode = True;
	ForEach AllActors(class'Weapon', W)
		W.SetWeaponStay();
}

defaultproperties
{
     BeaconName="CTDM"
     GameName="Lightning DeathMatch"
	 LadderTypeIndex=5
}
