class LadderTransition extends UTIntro;

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local PlayerPawn NewPlayer;
	local SpectatorCam Cam;

	NewPlayer = Super.Login(Portal, Options, Error, SpawnClass);
	NewPlayer.bHidden = True;

	foreach AllActors(class'SpectatorCam', Cam) 
		NewPlayer.ViewTarget = Cam;

	return NewPlayer;
}

function AcceptInventory(pawn PlayerPawn)
{
	local inventory Inv, Next;
	local LadderInventory LadderObj;

	// DeathMatchPlus accepts LadderInventory
	for( Inv=PlayerPawn.Inventory; Inv!=None; Inv=Next )
	{
		Next = Inv.Inventory;
		if (Inv.IsA('LadderInventory'))
		{
			LadderObj = LadderInventory(Inv);
			if (LadderObj != None) 
			{
				if (LadderObj.PendingChange > 0)
					TournamentConsole(PlayerPawn(PlayerPawn).Player.Console).EvaluateMatch(LadderObj.PendingChange, True);
				else
					TournamentConsole(PlayerPawn(PlayerPawn).Player.Console).EvaluateMatch(LadderObj.LastMatchType, False);
			}
		} else {	
			Inv.Destroy();
		}
	}
	PlayerPawn.Weapon = None;
	PlayerPawn.SelectedItem = None;
}

function PlayTeleportEffect( actor Incoming, bool bOut, bool bSound)
{
}
