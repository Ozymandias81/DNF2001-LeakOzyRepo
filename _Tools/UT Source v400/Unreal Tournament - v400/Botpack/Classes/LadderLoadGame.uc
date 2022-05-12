class LadderLoadGame extends UTIntro;

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

	for( Inv=PlayerPawn.Inventory; Inv!=None; Inv=Next )
	{
		Inv.Destroy();
	}

	TournamentConsole(PlayerPawn(PlayerPawn).Player.Console).LoadGame();
	PlayerPawn.Weapon = None;
	PlayerPawn.SelectedItem = None;
}

function PlayTeleportEffect( actor Incoming, bool bOut, bool bSound)
{
}
