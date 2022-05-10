class dnTeamGame expands dnDeathmatchGame;

var		localized	    string				HumanTeamName;
var		localized	    string				BugTeamName;
var		localized	    string				StartupMessage;
var		localized	    string				StartupTeamMessage;
var		localized	    string				TeamChangeMessage;
var		localized	    string				StartupTeamTrailer;
var		localized	    string				TeamNames[4];
var						dnTeamInfo			Teams[4];
var						bool				bSpawnInTeamArea;
var()					bool	            bScoreTeamKills;
var		globalconfig	bool	            bBalanceTeams;	        // bots balance teams
var		globalconfig	bool	            bPlayersBalanceTeams;	// players balance teams
var()	config			float               FriendlyFireScale;      // scale friendly fire damage by this value
var()	config			float               GoalTeamScore;          // like fraglimit
var()	config			int	                MaxTeamSize;
var()	config			int	                MaxTeams;               // Maximum number of teams 
var()	config			bool	            bNoTeamChanges;
var						int					MaxAllowedTeams;

var						string				HumanTeamClassNames[10];
var						string				HumanTeamClasses[10];
var						int					HumanTeamCost[10];

var						string				BugTeamClassNames[10];
var						string				BugTeamClasses[10];
var						int					BugTeamCost[10];

var 					int 				NumTeamClassNames;
var						class<playerpawn>	OverridePlayerClass[4];
var						string				OverridePlayerClassName[4];

const HUMAN = 0;
const BUG   = 1;

//===============================================================
//InitGame
//===============================================================
event InitGame( string Options, out string Error )
{
	Super.InitGame( Options, Error );
	MaxTeams = Min( MaxTeams,MaxAllowedTeams );
}

//===============================================================
//InitGameReplicationInfo
//===============================================================
function InitGameReplicationInfo()
{
	Super.InitGameReplicationInfo();
	dnDeathMatchGameReplicationInfo( GameReplicationInfo ).GoalTeamScore = GoalTeamScore;
}

//===============================================================
//PostBeginPlay
//===============================================================
function PostBeginPlay()
{
	local int i;

	for ( i=0; i<MaxTeams; i++ )
	{
		Teams[i]			= Spawn( class'dnTeamInfo' );
		Teams[i].Score		= 0;
		Teams[i].Size		= 0;
		Teams[i].TeamName	= TeamNames[i];
		Teams[i].TeamIndex	= i;
		dnDeathmatchGameReplicationInfo( GameReplicationInfo ).Teams[i] = Teams[i];
	}

	Super.PostBeginPlay();
}

//===============================================================
//PostLogin
//===============================================================
event PostLogin( playerpawn NewPlayer )
{
	Super.PostLogin( NewPlayer );
	NewPlayer.ClientChangeTeam( NewPlayer.PlayerReplicationInfo.Team );
}

//===============================================================
//Login
//===============================================================
function PlayerPawn Login
(
	string				Portal,
	string				Options,
	out					string Error,
	class<playerpawn>	SpawnClass
)
{
	local PlayerPawn		newPlayer;
	local NavigationPoint	StartSpot;

	newPlayer = Super.Login( Portal, Options, Error, SpawnClass );

	if ( newPlayer == None )
	{
		return None;
	}

	if ( bSpawnInTeamArea )
	{
		StartSpot = FindPlayerStart( newPlayer, 255, Portal );
		
		if ( StartSpot != None )
		{
			NewPlayer.SetLocation( StartSpot.Location );
			NewPlayer.SetRotation( StartSpot.Rotation );
			NewPlayer.ViewRotation = StartSpot.Rotation;
			NewPlayer.ClientSetRotation( NewPlayer.Rotation );
			StartSpot.PlayTeleportEffect( NewPlayer, true );
		}
	}				
	return newPlayer;
}

//===============================================================
//Logout
//===============================================================
function Logout( Pawn Exiting )
{
	Super.Logout( Exiting );

	// Don't care about specators
	if ( Exiting.PlayerReplicationInfo.bIsSpectator )
		return;

	// Fix the team counter
	Teams[Exiting.PlayerReplicationInfo.Team].Size--;
	ClearOrders(Exiting);

	if ( !bGameEnded && bBalanceTeams )
		ReBalance();
}

//===============================================================
//FindTeamByName - Find a team given its name
//===============================================================
function byte FindTeamByName( string TeamName )
{
	local byte i;

	for ( i=0; i<MaxTeams; i++ )
		if ( Teams[i].TeamName == TeamName )
			return i;

	return 255; // No Team
}

//===============================================================
//ReBalance - Rebalance teams after player changes teams or leaves
//find biggest and smallest teams.  If 2 apart, move bot from 
//biggest to smallest
//===============================================================
function ReBalance()
{
	/*
    local int   big, small, i, bigsize, smallsize;
	local Pawn  P, A;
    local Bot   B;

	if ( bBalancing || (NumBots == 0) )
		return;

	big         = 0;
	small       = 0;
	bigsize     = Teams[0].Size;
	smallsize   = Teams[0].Size;

	for ( i=1; i<MaxTeams; i++ )
	{
		if ( Teams[i].Size > bigsize )
		{
			big = i;
			bigsize = Teams[i].Size;
		}
		else if ( Teams[i].Size < smallsize )
		{
			small = i;
			smallsize = Teams[i].Size;
		}
	}
	
	bBalancing = true;
	while ( bigsize - smallsize > 1 )
	{
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
        {
			if ( P.bIsPlayer && ( P.PlayerReplicationInfo.Team == big )
				&& P.IsA('Bot') )
			{
				B = Bot(P);
				break;
			}
        }

		if ( B != None )
		{
			B.Health = 0;
			B.Died( None, 'Suicided', B.Location );
			bigsize--;
			smallsize++;
			ChangeTeam(B, small);
		}
		else
        {
			break;
        }
	}
	bBalancing = false;
	
    // re-assign orders to follower bots with no leaders
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if ( P.bIsPlayer && P.IsA('Bot') && (BotReplicationInfo(P.PlayerReplicationInfo).RealOrders == 'Follow') )
		{
			A = Pawn(Bot(P).OrderObject);
			if ( (A == None) || A.bDeleteMe || !A.bIsPlayer || (A.PlayerReplicationInfo.Team != P.PlayerReplicationInfo.Team) )
			{
				Bot(P).OrderObject = None;
				SetBotOrders(Bot(P));
			}
		}
    */
}

//===============================================================
//FindPlayerStart (for Team games)
//===============================================================
function NavigationPoint FindPlayerStart( Pawn Player, optional byte InTeam, optional string incomingName )
{
	local PlayerStart		Dest, Candidate[4], Best;
	local float				Score[4], BestScore, NextDist;
	local Pawn				OtherPlayer;
	local int				i, num;
	local Teleporter		Tel;
	local NavigationPoint	N;
	local byte				Team;

	// Get player's team
	if ( ( Player != None ) && ( Player.PlayerReplicationInfo != None ) )
		Team = Player.PlayerReplicationInfo.Team;
	else
		Team = InTeam;

	if( incomingName!="" )
	{
		foreach AllActors( class 'Teleporter', Tel )
		{
			if( string( Tel.Tag ) ~= incomingName )
			{
				return Tel;
			}
		}
	}
			
	num = 0;

	// choose 4 candidates	
	for ( N=Level.NavigationPointList; N!=None; N=N.nextNavigationPoint )
	{
		if ( N.IsA( 'PlayerStart' ) && ( !bSpawnInTeamArea || ( Team == PlayerStart(N).TeamNumber ) ) )
		{
			if ( num < 4 )
			{
				Candidate[num] = PlayerStart( N );
			}
			else if ( Rand(num) < 4 )
			{
				Candidate[Rand(4)] = PlayerStart( N );
			}
			num++;
		}
	}

	// no candidates found.
	if (num == 0 )
	{
		foreach AllActors( class'PlayerStart', Dest )
		{
			if ( !bSpawnInTeamArea || ( Team == Dest.TeamNumber ) )
			{
				if ( num < 4 )
				{
					Candidate[num] = Dest;
				}
				else if (Rand(num) < 4)
				{
					Candidate[Rand(4)] = Dest;
				}
				num++;
			}
		}
	}

	if ( num > 4 )
	{
		num = 4;
	}
	else if ( num == 0 )
	{
		return None;
	}
		
	//assess candidates
	for ( i=0; i<num; i++ )
	{
		Score[i] = 4000 * FRand(); //randomize
	}

	
	for ( OtherPlayer=Level.PawnList; OtherPlayer!=None; OtherPlayer=OtherPlayer.NextPawn )	
	{
		if ( OtherPlayer.bIsPlayer && ( OtherPlayer.Health > 0 ) && !OtherPlayer.PlayerReplicationInfo.bIsSpectator )
		{
			for ( i=0; i<num; i++ )
			{
				if ( OtherPlayer.Region.Zone == Candidate[i].Region.Zone )
				{
					NextDist = VSize( OtherPlayer.Location - Candidate[i].Location );

					if ( NextDist < CollisionRadius + CollisionHeight )
					{
						Score[i] -= 1000000.0;
					}
					else if ( ( NextDist < 1400 ) && ( Team != OtherPlayer.PlayerReplicationInfo.Team ) && OtherPlayer.LineOfSightTo( Candidate[i] ) )
					{
						Score[i] -= 10000.0;
					}
				}
            }
        }
    }
	
	BestScore	= Score[0];
	Best		= Candidate[0];

	for ( i=1; i<num; i++ )
	{
		if ( Score[i] > BestScore )
		{
			BestScore	= Score[i];
			Best		= Candidate[i];
		}
	}				
	return Best;
}


//===============================================================
//PlayStartUpMessage
//===============================================================
function PlayStartUpMessage( PlayerPawn NewPlayer, optional int Countdown )
{
	local int	i;
	local color WhiteColor;

	// Clear out any progress messages
	NewPlayer.ClearProgressMessages();
	
	// Game Name
	NewPlayer.SetProgressMessage( GameName, i++ );

	// Startup Message
	NewPlayer.SetProgressMessage( StartUpMessage, i++ );

	// If there's a team score goal, let the player know on the progress messages
	if ( GoalTeamScore > 0 )
	{
		NewPlayer.SetProgressMessage( int( GoalTeamScore ) @ GameGoal, i++ );
	}

	// Team Name
	if ( NewPlayer.PlayerReplicationInfo.Team < 2 )
	{		
		NewPlayer.SetProgressMessage( StartupTeamMessage @ Teams[NewPlayer.PlayerReplicationInfo.Team].TeamName $ StartupTeamTrailer, i++ );

		WhiteColor.R = 255;
		WhiteColor.G = 255;
		WhiteColor.B = 255;
		
		NewPlayer.SetProgressColor( WhiteColor, i );
		NewPlayer.SetProgressMessage( TeamChangeMessage, i++ );
	}
}

//============================================================================
//GetRules
//============================================================================
function string GetRules()
{
	local string ResultSet;

	ResultSet = Super.GetRules();

	ResultSet = ResultSet$"\\timelimit\\"$TimeLimit;
	ResultSet = ResultSet$"\\goalteamscore\\"$int(GoalTeamScore);
	Resultset = ResultSet$"\\minplayers\\"$MinPlayers;
	Resultset = ResultSet$"\\changelevels\\"$bChangeLevels;
	ResultSet = ResultSet$"\\balanceteams\\"$bBalanceTeams;
	ResultSet = ResultSet$"\\playersbalanceteams\\"$bPlayersBalanceTeams;
	ResultSet = ResultSet$"\\friendlyfire\\"$int(FriendlyFireScale*100)$"%";

    /*
    if ( bMegaSpeed )
	    Resultset = ResultSet$"\\gamestyle\\Turbo";
    else if( bHardcoreMode )
	    Resultset = ResultSet$"\\gamestyle\\Hardcore";
    else
	    Resultset = ResultSet$"\\gamestyle\\Classic";
        (

    if( MinPlayers > 0 )
	    Resultset = ResultSet$"\\botskill\\"$class'ChallengeBotInfo'.default.Skills[Difficulty];
    */

	return ResultSet;
}

//============================================================================
//ReduceDamage - Use reduce damage for teamplay modifications, etc.
//============================================================================
function int ReduceDamage( int Damage, class<DamageType> DamageType, Pawn Injured, Pawn InstigatedBy )
{
	Damage = Super.ReduceDamage( Damage, DamageType, injured, instigatedBy );
	
	if ( instigatedBy == None )
		return Damage;

    // Check for friendly fire
	if ( 
         ( instigatedBy != injured ) && 
         ( injured.bIsPlayer )		 && 
         ( instigatedBy.bIsPlayer )  &&
         ( injured.PlayerReplicationInfo.Team == instigatedBy.PlayerReplicationInfo.Team ) 
       )
	{
        /*
		if ( injured.IsA('Bot') )
			Bot(Injured).YellAt(instigatedBy);
            */

		return ( Damage * FriendlyFireScale );
	}
	else
    {
		return Damage;
    }
}

//============================================================================
//ScoreKill
//============================================================================
function ScoreKill( pawn Killer, pawn Other )
{
	if ( 
         ( Killer == None    ) || 
         ( Killer == Other   ) || 
         ( !Other.bIsPlayer  ) || 
         ( !Killer.bIsPlayer ) ||
         ( Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team )
       )
    {
		Super.ScoreKill(Killer, Other);
    }

	if ( !bScoreTeamKills )
		return;

	if ( Other.bIsPlayer && ( ( Killer == None ) || Killer.bIsPlayer ) )
	{
		if ( ( Killer == Other ) || ( Killer == None ) )
        {   
            // Killed self or just died
			Teams[Other.PlayerReplicationInfo.Team].Score -= 1;
        }
		else if ( Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team )
        {   
            // Enemy team kill
			Teams[Killer.PlayerReplicationInfo.Team].Score += 1;
        }
		else if ( FriendlyFireScale > 0 )
		{
            // Killed own teammate
			Teams[Other.PlayerReplicationInfo.Team].Score -= 1;
			Killer.PlayerReplicationInfo.Score            -= 1;
		}
	}

    // Check for end of game
	if ( 
	     ( bOverTime || ( GoalTeamScore > 0 ) ) && 
	     ( Killer.bIsPlayer )   				&& 
		 ( Teams[killer.PlayerReplicationInfo.Team].Score >= GoalTeamScore )
	   )
	{
		EndGame( "teamscorelimit" );
	}
}

//============================================================================
//ChangeTeam
//============================================================================
function bool ChangeTeam( Pawn Other, int NewTeam )
{
	local int           i, s, DesiredTeam;
	local pawn          APlayer, P;
	local dnTeamInfo    SmallestTeam;

    // Find smallest team
	for( i=0; i<MaxTeams; i++ )
    {
		if ( ( SmallestTeam == None ) || (SmallestTeam.Size > Teams[i].Size) )
		{
			s = i;
			SmallestTeam = Teams[i];
		}
    }

	if ( bPlayersBalanceTeams && ( Level.NetMode != NM_Standalone ) )
	{
		if ( NumBots == 1 )
		{
			// join bot's team, because he will leave
			for ( P=Level.PawnList; P!=None; P=P.NextPawn )
				if ( P.IsA('Bot') )
					break;
			
			if ( 
                 ( P != None ) && 
                 ( P.PlayerReplicationInfo != None ) &&
                 ( Teams[P.PlayerReplicationInfo.Team].Size == SmallestTeam.Size )
               )
            {
				Other.PlayerReplicationInfo.Team = 255;
				NewTeam                          = P.PlayerReplicationInfo.Team;
			}
			else if ( ( NewTeam >= MaxTeams ) || ( Teams[NewTeam].Size > SmallestTeam.Size ) )
			{	
				Other.PlayerReplicationInfo.Team = 255;
				NewTeam                          = 255;
			}
		}
		else if ( ( NewTeam >= MaxTeams ) || ( Teams[NewTeam].Size > SmallestTeam.Size ) )
		{	
            // Don't join if the new team > MaxTeams, or if the new Team's size is > the smallest team
			Other.PlayerReplicationInfo.Team = 255;
			NewTeam                          = 255;
		}
	}

    // Player wants to switch to an invalid team, so set them to the smallest team
	if ( ( NewTeam == 255) || ( NewTeam >= MaxTeams ) )
    {
		Log( "AddToTeam::Changing player to smallest team" );
		NewTeam = s;
    }

    // Player is a spectator, just put them on 255 and return
	if ( Other.PlayerReplicationInfo.bIsSpectator )
	{
		Log( "ChangeTeam::Putting spectator on team 255" );
		Other.PlayerReplicationInfo.Team = 255;
		return true;
	}

	if ( 
         ( Other.PlayerReplicationInfo.Team != 255 ) &&
         ( Other.PlayerReplicationInfo.Team == NewTeam ) && 
         ( bNoTeamChanges )
       )
    {
        // Player is trying to change teams and there is no TeamChanging allowed
		Log( "ChangeTeam::No Changing teams allowed" );
		return false;
    }

	if ( Other.PlayerReplicationInfo.Team != 255 )
	{
        // Looks like a valid team change is going to happen, so fix clear orders and fix old team size
		Log( "ChangeTeam::Fixing old team size" @ Other.PlayerReplicationInfo.Team );
		ClearOrders( Other );
		Teams[Other.PlayerReplicationInfo.Team].Size--;
	}

	Log( "Checking New Team's Size: Teams[NewTeam].Size < MaxTeamSize" @ Teams[NewTeam].Size @ MaxTeamSize );
	if ( Teams[NewTeam].Size < MaxTeamSize )
	{
        // Add the player to the new team if it's under the max size requirement
		Log( "ChangeTeam::Adding player to team" @ NewTeam );
		AddToTeam( NewTeam, Other );
		return true;
	}

	if ( 
         ( Other.PlayerReplicationInfo.Team == 255 ) || 
         ( ( SmallestTeam != None) && ( SmallestTeam.Size < MaxTeamSize ) )
       )
	{
        // if the player is on 255, then put them in the smallest team
		
        // check for weird s values and set to 0 if necessary
        if ( s == 255 )
			s = 0;

		Log( "ChangeTeam::Player was on 255, now adding to team" @ s );
		AddToTeam( s, Other );
		return true;
	}

	return false;
}

//============================================================================
//AddToTeam
//============================================================================
function AddToTeam( int num, Pawn Other )
{
	local dnTeamInfo    aTeam;
	local Pawn          P;
	local bool          bSuccess;
	local string        SkinName, FaceName;

	if ( Other == None )
	{
		log( "dnTeamGame:Error: Added None to team!!!");
		return;
	}

	// Get the team and increase its size
    aTeam = Teams[num];
	aTeam.Size++;

    // Set the replications
	Other.PlayerReplicationInfo.Team        = num;
	Other.PlayerReplicationInfo.TeamName    = aTeam.TeamName;

	bSuccess = false;
	if ( Other.IsA( 'PlayerPawn' ) )
	{
		Other.PlayerReplicationInfo.TeamID = 0;
		PlayerPawn(Other).ClientChangeTeam( Other.PlayerReplicationInfo.Team );
	}
	else
    {
		Other.PlayerReplicationInfo.TeamID = 1;
    }

    // Find empty ID slot
	while ( !bSuccess )
	{
		bSuccess = true;
		for ( P=Level.PawnList; P!=None; P=P.nextPawn )
        {
            if ( 
                 ( P.bIsPlayer ) && 
                 ( P != Other ) &&
                 ( P.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team ) &&
                 ( P.PlayerReplicationInfo.TeamId == Other.PlayerReplicationInfo.TeamId ) 
               )
            {
				bSuccess = false;
            }
        }

		if ( !bSuccess )
			Other.PlayerReplicationInfo.TeamID++;
	}

	BroadcastLocalizedMessage( DMMessageClass, 3, Other.PlayerReplicationInfo, None, aTeam );

	//Other.static.GetMultiSkin( Other, SkinName, FaceName );
	//Other.static.SetMultiSkin( Other, SkinName, FaceName, num );

	if ( bBalanceTeams )
    {
		ReBalance();
    }
}

//===============================================================
//CanSpectate
//===============================================================
function bool CanSpectate( pawn Viewer, actor ViewTarget )
{
	if ( 
        ( ViewTarget.bIsPawn ) && 
        ( Pawn( ViewTarget ).PlayerReplicationInfo != None ) &&
        ( Pawn(ViewTarget).PlayerReplicationInfo.bIsSpectator )
       )
    {
		return false;
    }

	if ( Viewer.PlayerReplicationInfo.bIsSpectator && ( Viewer.PlayerReplicationInfo.Team == 255 ) )
    {
		return true;
    }

	return ( ( Pawn( ViewTarget ) != None ) && Pawn( ViewTarget ).bIsPlayer 
		&& ( Pawn( ViewTarget ).PlayerReplicationInfo.Team == Viewer.PlayerReplicationInfo.Team ) );
}

//===============================================================
//GetTeam
//===============================================================
function dnTeamInfo GetTeam(int TeamNum )
{
	if ( TeamNum < ArrayCount(Teams) )
		return Teams[TeamNum];

	else return None;
}

//===============================================================
//IsOnTeam
//===============================================================
function bool IsOnTeam( Pawn Other, int TeamNum )
{
	if ( Other.PlayerReplicationInfo.Team == TeamNum )
		return true;

	return false;
}

//===============================================================
//AddBot
//===============================================================
function bool AddBot()
{
}

//===============================================================
//ClearOrders
//===============================================================
function ClearOrders(Pawn Leaving)
{
}

//===============================================================
//AddDefaultInventory
//===============================================================
function AddDefaultInventory( pawn P )
{
	// Ask the mutator to modify the player.
	BaseMutator.ModifyPlayer( P );

	if ( P.IsSpectating() )
		return;
	
	P.AddDefaultInventory();
}

//===============================================================
//GetClassNameForString
//===============================================================
function string GetClassNameForString( string newClassName )
{
	local int i;

	for ( i=0; i<numTeamClassNames; i++ )
	{
		if ( newClassName == HumanTeamClassNames[i] )
			return HumanTeamClasses[i];
		else if ( newClassName == BugTeamClassNames[i] )
			return BugTeamClasses[i];
	}

	return "";
}

/*
//===============================================================
//GetClassForString
//===============================================================
function class<PlayerPawn> GetClassForString( string NewClassName )
{
	local int i;

	for ( i=0; i<numTeamClassNames; i++ )
	{
		if ( newClassName == HumanTeamClassNames[i] )
			return HumanTeamClasses[i];
		else if ( newClassName == BugTeamClassNames[i] )
			return BugTeamClasses[i];
	}

	return None;
}
*/

//===============================================================
//GetCreditCostForString
//===============================================================
function int GetCreditCostForString( string NewClassName )
{
	local int i;

	for ( i=0; i<numTeamClassNames; i++ )
	{
		if ( newClassName == HumanTeamClassNames[i] )
			return HumanTeamCost[i];
		else if ( newClassName == BugTeamClassNames[i] )
			return BugTeamCost[i];
	}

	return 0;
}

//===============================================================
//GetOverridePlayerClass
//===============================================================
function class<playerpawn> GetOverridePlayerClass( int InTeam )
{
	if ( InTeam == HUMAN )
		return OverridePlayerClass[HUMAN];
	else if ( InTeam == BUG )
		return OverridePlayerClass[BUG];
	else
		return None;
}

//===============================================================
//GetOverridePlayerClassName
//===============================================================
function string GetOverridePlayerClassName( int InTeam )
{
	if ( InTeam == HUMAN )
		return OverridePlayerClassName[HUMAN];
	else if ( InTeam == BUG )
		return OverridePlayerClassName[BUG];
	else
		return "";
}

//===============================================================
//ResetClasses
//===============================================================
function ResetClasses()
{
	local Pawn		P;
	local string	NewClass;

	for ( P = Level.PawnList; P!=None; P=P.nextPawn )
    {
		if ( P.bIsPlayer && P.IsA( 'PlayerPawn') )
		{
			// If the player was killed in the previous round, set them back to the default class
			if ( bOverridePlayerClass && PlayerPawn( P ).PlayerReplicationInfo.Score < 1 )
			{
				PlayerPawn( P ).EnterWaiting();

				NewClass = Level.Game.GetOverridePlayerClassName( P.PlayerReplicationInfo.Team );							

				if ( NewClass != "" )
				{
					PlayerPawn( P ).ServerChangeClass( NewClass, true, true );
				}
			}	
		}
	}
}

//===============================================================
//dnTeamGame::defaultproperties
//===============================================================
defaultproperties
{
    GameName="Team Deathmatch"
    DefaultWeapon=None
    MapPrefix="BH"
    BeaconName="!Z"
    bSpawnInTeamArea=true
    bTeamGame=true
    bScoreTeamKills=true
    MaxTeams=2    
	MaxAllowedTeams=2
	MaxTeamSize=16
	TeamNames(0)="Human"
	TeamNames(1)="Bug"
	StartUpTeamMessage="You are a"
	StartupTeamTrailer="."
    TeamChangeMessage="Use Voice Menu to change teams/class."
	StartUpMessage="Work with your teammates against the other team."

    // Classes to use
	HUDType=class'dnGame.dnTeamGameHUD'    
    ScoreboardType=class'dnGame.dnTeamGameScoreboard'

	OverridePlayerClass(0)=class'dnGame.EDF_Grunt_Player'
	OverridePlayerClass(1)=class'dnGame.BUG_Grunt_Player'
	OverridePlayerClassName(0)="EDF-Grunt"
	OverridePlayerClassName(1)="BUG-Grunt"
	bOverridePlayerClass=true

	HumanTeamClassNames(0)="EDF-Grunt"
	HumanTeamClassNames(1)="EDF-Attack Dog"
	HumanTeamClassNames(2)="EDF-Soldier"
	HumanTeamClassNames(3)="EDF-Sapper"
	HumanTeamClassNames(4)="EDF-Sniper"
	HumanTeamClassNames(5)="EDF-Flamer"
	HumanTeamClassNames(6)="EDF-Freezer"
	HumanTeamClassNames(7)="EDF-Captain"
	HumanTeamClassNames(8)="EDF-EDF-209"
	HumanTeamClassNames(9)="EDF-Duke Nukem"
	
	HumanTeamClasses(0)="dnGame.EDF_Grunt_Player"
	HumanTeamClasses(1)="dnGame.EDF_AttackDog_Player"
	HumanTeamClasses(2)="dnGame.EDF_Soldier_Player"
	HumanTeamClasses(3)="dnGame.EDF_Sapper_Player"
	HumanTeamClasses(4)="dnGame.EDF_Sniper_Player"
	HumanTeamClasses(5)="dnGame.EDF_Flamer_Player"
	HumanTeamClasses(6)="dnGame.EDF_Freezer_Player"
	HumanTeamClasses(7)="dnGame.EDF_Captain_Player"
	HumanTeamClasses(8)="dnGame.EDF_209_Player"
	HumanTeamClasses(9)="dnGame.EDF_DukeNukem_Player"

	HumanTeamCost(0)=0 
	HumanTeamCost(1)=1
	HumanTeamCost(2)=4
	HumanTeamCost(3)=4
	HumanTeamCost(4)=4
	HumanTeamCost(5)=4
	HumanTeamCost(6)=4
	HumanTeamCost(7)=8
	HumanTeamCost(8)=8
	HumanTeamCost(9)=15

	BugTeamClassNames(0)="BUG-Grunt"
	BugTeamClassNames(1)="BUG-Octabrain"
	BugTeamClassNames(2)="BUG-Soldier"
	BugTeamClassNames(3)="BUG-Sapper"
	BugTeamClassNames(4)="BUG-Sniper"
	BugTeamClassNames(5)="BUG-Flamer"
	BugTeamClassNames(6)="BUG-Freezer"
	BugTeamClassNames(7)="BUG-Captain"
	BugTeamClassNames(8)="BUG-EDF-209"
	BugTeamClassNames(9)="BUG-Duke Nukem"
	
	BugTeamClasses(0)="dnGame.BUG_Grunt_Player"
	BugTeamClasses(1)="dnGame.BUG_Octabrain_Player"
	BugTeamClasses(2)="dnGame.BUG_Soldier_Player"
	BugTeamClasses(3)="dnGame.BUG_Sapper_Player"
	BugTeamClasses(4)="dnGame.BUG_Sniper_Player"
	BugTeamClasses(5)="dnGame.BUG_Flamer_Player"
	BugTeamClasses(6)="dnGame.BUG_Freezer_Player"
	BugTeamClasses(7)="dnGame.BUG_Captain_Player"
	BugTeamClasses(8)="dnGame.BUG_209_Player"
	BugTeamClasses(9)="dnGame.BUG_DukeNukem_Player"

	BugTeamCost(0)=0 
	BugTeamCost(1)=1
	BugTeamCost(2)=4
	BugTeamCost(3)=4
	BugTeamCost(4)=4
	BugTeamCost(5)=4
	BugTeamCost(6)=4
	BugTeamCost(7)=8
	BugTeamCost(8)=8
	BugTeamCost(9)=15

	numTeamClassNames=10
}
