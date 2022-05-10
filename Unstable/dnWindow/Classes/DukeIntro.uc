//=============================================================================
// FILE:			DukeIntro.uc
// 
// AUTHOR:			Timothy L. Weisser
// 
// DESCRIPTION:		Bastardized version of UTIntro
// 
// NOTES:			used this for Entry.unr to get into USystem automatically
//					could be expanded on to do other things as well
//
// MOD HISTORY:		
// 
//=============================================================================
class DukeIntro expands GameInfo;

var		float	fIntroTime;
var()	float	fTimeOutTilLaunchUSystem;
var		float	WaitCounter;

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local PlayerPawn NewPlayer;

	NewPlayer = Super.Login(Portal, Options, Error, SpawnClass);
	NewPlayer.bHidden = true;

	return NewPlayer;
}

function AddDefaultInventory( pawn P )
{
}

function AcceptInventory(pawn PlayerPawn)
{
	local Inventory Inv;

	for( Inv=PlayerPawn.Inventory; Inv!=None; Inv=Inv.Inventory )
		Inv.Destroy();
	PlayerPawn.Weapon = None;
	PlayerPawn.SelectedItem = None;
}

function PlayTeleportEffect( actor Incoming, bool bOut, bool bSound)
{
}

function float PlaySpawnEffect(inventory Inv)
{
}

function bool SetPause( BOOL bPause, PlayerPawn P )
{
	return false;
}

function Tick(float DeltaTime)
{
	local Pawn P;

	if ( WaitCounter < 3.0 )
	{
		WaitCounter += DeltaTime;
		return;
	}

	//	TLW: Wait for the game to stop loading things, then go into launching UWindow.
	if( Level.LevelAction != LEVACT_Connecting )
	{
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		{
			if ( P.IsA('PlayerPawn') &&	(PlayerPawn(P).Player != None) &&
				 WindowConsole(PlayerPawn(P).Player.Console) != None &&
				 PlayerPawn(P).ProgressMessage[0] == "" )
			{
				Disable('Tick');
				WindowConsole(PlayerPawn(P).Player.Console).LaunchUWindow();
				break;
			}
		}
	}
	else
		Disable('Tick');
}

function bool CanSpectate( pawn Viewer, actor ViewTarget )
{
	return false;
}

defaultproperties
{
     fTimeOutTilLaunchUSystem=1.000000
	 bCanViewOthers=false
	 bGameEnded=true
     bPauseable=True
     DefaultWeapon=None
     HUDType=Class'Botpack.CHNullHUD'
}
