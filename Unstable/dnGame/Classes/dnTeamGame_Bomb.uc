class dnTeamGame_Bomb expands dnTeamGame;

var(Settings)	int			NumLives;
var(Settings)	int			AttackingTeam;
var(Settings)	int			DefendingTeam;
var(Settings)	float		RoundDelayTime;
var(Settings)   bool		bAlwaysChangeClass;
var(Settings)   bool		bCanStartMatch;
var				float		ClassChangeTime;
var				float		EndMatchTime;
var				int			WinCredits;
var				int			LoseCredits;
var				float		MatchTimeLimit;
var				float		BombDelayTime;
var				float		ResetClassTime;


//================================================================================
//InitGame
//================================================================================
event InitGame( string Options, out string Error )
{
	Super.InitGame( Options, Error );

	/*
	if ( FragLimit == 0 )
		Lives = 1;
	else
		Lives = Fraglimit;
	*/
}

//================================================================================
//CanCarryBomb
//================================================================================
function bool CanCarryBomb( Pawn p )
{
	return ( ( !p.IsSpectating() )	&& 
			 ( p.bIsPlayer )			&& 
			 ( p.PlayerReplicationInfo.Team == AttackingTeam ) 
		   );
}

//================================================================================
//GiveBomb
//================================================================================
function GiveBomb()
{
	local Pawn				p;	
	local Inventory			InventoryItem;
	local class<Inventory>	InvClass;
	local int				NumAttackers, Pick, Num;

	// Count number of humans
	for ( p=Level.PawnList; p!=None; p=p.nextPawn )
	{
		if ( CanCarryBomb( p ) )
		{
			NumAttackers++;
		}
	}
	
	// Pick a person on that team to give the bomb
	Pick = Rand( NumAttackers );

	Num = 0;

	for ( p=Level.PawnList; p!=None; p=p.nextPawn )
	{
		if ( CanCarryBomb( p ) )
		{
			if ( Pick == Num++ )
			{
				InvClass		= class<Inventory>(DynamicLoadObject( "dnGame.Bomb", class'Class' ));
				InventoryItem	= p.FindInventoryType( InvClass );

				if ( InventoryItem == None )
				{
					InventoryItem = spawn( InvClass );
					InventoryItem.GiveTo( p );
					return;
				}
			}
		}
	}
}

//================================================================================
//ScoreKill
//================================================================================
function ScoreKill(pawn Killer, pawn Other)
{
	// Kills take away a player's score.  When their score <= 0 they will not respawn.
	if ( Other != None )
	{
		if (Other.PlayerReplicationInfo.Score > 0)
		{
			Other.PlayerReplicationInfo.Score -= 1;
		}

		Other.PlayerReplicationInfo.Deaths += 1;
	}

	if ( ( Killer != Other ) && ( Killer != None ) )
	{
		Killer.PlayerReplicationInfo.Kills   += 1;
		Killer.PlayerReplicationInfo.Credits += 1;
	}

	BaseMutator.ScoreKill( Killer, Other );

	CheckEndRound();
}	

//================================================================================
//RestartPlayer
//================================================================================
function bool RestartPlayer( Pawn P )	
{			
	// Only do this stuff if the player is going into waiting	

	// Score < 1 means you're out
	if ( P.PlayerReplicationInfo.Score < 1 )
	{	
		P.Enemy               = None;
		P.RotateToDesiredView = false;
		
		P.UnShrink();

		if ( PlayerPawn( P ) != None )
		{
			PlayerPawn( P ).bCanPlantBomb = false;
			PlayerPawn( P ).EnterWaiting();

			//PlayerPawn( P ).ServerTimeStamp     = 0;
			//PlayerPawn( P ).TimeMargin          = 0;
		}
		return false;
	}
	else
	{
		return Super.RestartPlayer( P );
	}
}

//================================================================================
//Login
//================================================================================
event playerpawn Login
(
	string				Portal,
	string				Options,
	out string			Error,
	class<playerpawn>	SpawnClass
)
{
	local playerpawn NewPlayer;
	local Pawn P;

	NewPlayer = Super.Login(Portal, Options, Error, SpawnClass);
	
	NewPlayer.PlayerReplicationInfo.Score = NumLives;

	if ( ( NewPlayer != None ) && !NewPlayer.IsSpectating() )
	{				
		// match already started, so go into waiting mode
		//if ( bStartMatch )
		//	NewPlayer.EnterWaiting();		
	}

	return NewPlayer;
}

//================================================================================
//CheckEndRound
//================================================================================
function CheckEndRound()
{
	local Pawn	p;	
	local int   numAlive[2];

	if ( bGameEnded || bRoundEnded )
		return;

	// Count up the number of players alive on both teams
	for ( p=Level.PawnList; p!=None; p=p.nextPawn )
	{
		if ( p.bIsPlayer )
		{
			if ( p.PlayerReplicationInfo.Score > 0 )
			{
				numAlive[p.PlayerReplicationInfo.Team]++;
			}
		}
	}

	Log( "dnTeamGame_Bomb::CheckEndRound: Num Human Alive:" @ numAlive[HUMAN] @ "Num Bug Alive:" @ numAlive[BUG] );

	// End the game if there is only one team alive, or neither team alive
	if ( ( numAlive[HUMAN] > 0 && numAlive[BUG] < 1 ) )
		EndRound( HUMAN );
	else if ( ( numAlive[HUMAN] < 1 && numAlive[BUG] > 0 ) )
		EndRound( BUG );
	else if ( ( numAlive[HUMAN] < 1 && numAlive[BUG] < 1 ) )
		EndRound( -1 );
}

function EndMatch( optional string Reason )
{
	// Defending team wins in a timelimit situation
	if ( Reason == "timelimit" )
		EndRound( DefendingTeam );
}

//================================================================================
//PickupQuery
//================================================================================
function bool PickupQuery( Pawn Other, Inventory item )
{
	if ( item.IsA( 'Bomb' ) && Other.IsA( 'PlayerPawn' ) )
	{
		return ( PlayerPawn( Other ).PlayerReplicationInfo.Team == AttackingTeam );
	}
	else
	{
		return true;
	}
}

//================================================================================
//CleanupLevel
//================================================================================
function CleanupLevel()
{
	local Actor a;

	foreach AllActors( class 'Actor', a )
	{
		if ( a.IsA( 'Bomb' ) )
			a.Destroy();
		else if ( a.IsA( 'PlantedBomb' ) )
			a.Destroy();
		else if ( a.IsA( 'dnCarcass' ) )
			a.Destroy();
	}
}

//================================================================================
//StartMatch
//================================================================================
function StartMatch()
{
	local Pawn		P;

	bRoundEnded = false;

	RemainingTime = 60 * MatchTimeLimit;
	GameReplicationInfo.RemainingTime = RemainingTime;

	ClassChangeTime = Level.TimeSeconds + default.ClassChangeTime;

	// Give all players Lives
	for ( P = Level.PawnList; P!=None; P=P.nextPawn )
    {
		if ( P.bIsPlayer && P.IsA( 'PlayerPawn') )
		{
			PlayerPawn( P ).ResetInventory();
			P.PlayerReplicationInfo.Score   = NumLives;	
		}
	}

	Super.StartMatch();

	// Cleanup the level from the last round
	CleanupLevel();

	// Find a human and give them a bomb
	SetCallbackTimer( BombDelayTime, false, 'GiveBomb' );
}

//================================================================================
//EndRound
//================================================================================
function EndRound( int WinningTeam )
{
	local Pawn P;

	bRoundEnded = true;

	BroadcastLocalizedMessage( class'dnTeamGameMessage', WinningTeam );

	// -1 means a tie, otherwise the winning team is passed in.
	if ( WinningTeam >= 0 )
		Teams[WinningTeam].Score += 1;

	// Players on both teams get credits
	for ( P = Level.PawnList; P!=None; P=P.nextPawn )
	{
		if ( P.bIsPlayer && P.IsA( 'PlayerPawn') )
		{
			if ( P.PlayerReplicationInfo.Team == WinningTeam )
			{
				P.PlayerReplicationInfo.Credits += WinCredits;
			}
			else
			{
				P.PlayerReplicationInfo.Credits += LoseCredits;			
			}
		}
	}

	// Do a restart on the round after a bit of time.  We must Reset the classes before
	// we restart the match
	SetCallbackTimer( ResetClassTime, false, 'ResetClasses' );
	SetCallbackTimer( RoundDelayTime, false, 'StartMatch'	);
}

//================================================================================
//BombPlanted
//================================================================================
function BombPlanted()
{
}

//================================================================================
//BombDefused
//================================================================================
function BombDefused()
{
	EndRound( DefendingTeam );
}

//================================================================================
//BombDetonated
//================================================================================
function BombDetonated()
{	
	EndRound( AttackingTeam );
}

//================================================================================
//CanChangeClass
//================================================================================
function bool CanChangeClass( PlayerPawn P, string NewClassName )
{
	local int CreditCost;
	
	if ( bAlwaysChangeClass )
		return true;

	Log( "CanChangeClass" @ P @ NewClassName );

	// Check to see if it's too late to change classes
	if ( Level.TimeSeconds > ClassChangeTime )
	{
		P.ReceiveLocalizedMessage( class'dnTeamGameMessage', 2 );
		return false;
	}
	else 
	{
		CreditCost = GetCreditCostForString( NewClassName );

		Log( "CreditCost is" @ CreditCost );

		// Check if we can pay
		if ( CreditCost > P.PlayerReplicationInfo.Credits )
		{
			P.ReceiveLocalizedMessage( class'dnTeamGameMessage', 3 );
			return false;
		}
		
		// Deduct the cost
		P.PlayerReplicationInfo.Credits -= CreditCost;
		return true;
	}
}

//================================================================================
//CanStartMatch
//================================================================================
function bool CanStartMatch()
{

	if ( bCanStartMatch )
		return true;

	// In order to start the match there should be at least 1 player on each team
	if ( ( Teams[HUMAN] != None ) && ( Teams[BUG] != None ) )
	{
		return ( Teams[HUMAN].Size > 0 && Teams[BUG].Size > 0 );
	}
	else
	{
		return false;
	}
}

//================================================================================
//defaultproperties
//================================================================================
defaultproperties
{
    GameName="Bug Hunt - Plant/Disarm the Bomb"
    MapPrefix="BH"
    BeaconName="!Z"
    bRestartLevel=true
    bPlayDeathSequence=false
    bPlayStartLevelSequence=false
	bMeshAccurateHits=false
	GoalTeamScore=0
	AttackingTeam=0
	DefendingTeam=1
	NumLives=1
	bFirstBlood=true		// No first blood by setting this to true
	bDoSpree=false		
	bSearchBodies=false
	WinCredits=2
	LoseCredits=1
	bShowScores=false
	MatchTimeLimit=8	// Minutes
	ClassChangeTime=90	// Seconds	
	ResetClassTime=4    // Seconds
	RoundDelayTime=8	// Seconds
	BombDelayTime=3		// Seconds
	bAlwaysChangeClass=true
	bCanStartMatch=true
}
