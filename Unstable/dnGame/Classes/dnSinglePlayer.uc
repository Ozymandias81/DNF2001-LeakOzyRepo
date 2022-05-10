/*-----------------------------------------------------------------------------
	dnSinglePlayer
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class dnSinglePlayer expands GameInfo;

#exec OBJ LOAD FILE=..\Sounds\a_dukevoice.dfx

var DukePlayer SinglePlayerDuke;
var Actor SpeechCoordinator;
var bool bGruntSpeechDisabled;
var() bool bNoPistol;

function PostBeginplay()
{
	local Info I, TestI;
	local class<Actor> SpeechController;	
	
	foreach allactors( class'Info', I )
	{
		if( I != None && I.IsA( 'EDFSpeechCoordinator' ) )
			TestI = I;
	}

	if( TestI == None )
	{
		SpeechController = class<Actor>(DynamicLoadObject( "dnai.EDFSpeechCoordinator", class'Class' ) );
		if( SpeechController != None )
			SpeechCoordinator = Spawn( SpeechController );
	}
	
	Super.PostBeginPlay();
}

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
	SinglePlayerDuke = DukePlayer(NewPlayer);
	SinglePlayerDuke.Tag = 'DukePlayer';

	return NewPlayer;
}

function AddDefaultInventory( pawn InventoryPawn )
{
	local Inventory Inv;
	local Weapon Weap;
	local Inventory InventoryItem;

	// Assign default inventory.
	Super.AddDefaultInventory( InventoryPawn );

	// Pistol
	if ( !bNoPistol )
		GiveWeaponTo( InventoryPawn, class'pistol', true );

	// Todo List
	// Mod authors: We decided not to implement an objectives list system, so this is only partially implemented and not enabled.
	// You might be able to trace through all the elements of the objectives/todo list code and do something with it.
	// Perhaps modeling your own objectives system after it.
//	Inv = spawn(class'ToDoList');
//	Inv.GiveTo( InventoryPawn );
}

function bool RestartPlayer( pawn aPlayer )	
{
	// We don't do restarts this way.
	// Instead, we'll pop up the end game sequence after some time.
	return false;
}

function Tick(float DeltaTime)
{
	local Pawn P;

	// After we are done loading, disable boot sequence (only show that if we start normally).
	if( Level.LevelAction != LEVACT_Connecting )
	{
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		{
			if ( P.IsA('PlayerPawn') &&	(PlayerPawn(P).Player != None) &&
				 WindowConsole(PlayerPawn(P).Player.Console) != None &&
				 PlayerPawn(P).ProgressMessage[0] == "" )
			{
				Disable('Tick');
				WindowConsole(PlayerPawn(P).Player.Console).CancelBootSequence();
				break;
			}
		}
	}
	else
		Disable('Tick');
}

defaultproperties
{
	DefaultWeapon=class'dnGame.mightyfoot'
	MapPrefix="!Z"
	BeaconName="!Z"
	bRestartLevel=true
	HUDType=class'dnGame.DukeHUD'
	bPlayDeathSequence=true
	bPlayStartLevelSequence=true
}
