//=============================================================================
// TeamGame.
//=============================================================================
class TeamGame extends DeathMatchGame;

var() config bool   bSpawnInTeamArea;
var() config bool	bNoTeamChanges;
var() config float  FriendlyFireScale; //scale friendly fire damage by this value
var() config int	MaxTeams; //Maximum number of teams allowed in (up to 16)
var	TeamInfo Teams[16]; 
var() config float  GoalTeamScore; //like fraglimit
var() config int	MaxTeamSize;
var  localized string NewTeamMessage;
var		int			NextBotTeam;
var byte TEAM_Red, TEAM_Blue, TEAM_Green, TEAM_Gold;
var localized string TeamColor[4];

function PostBeginPlay()
{
	local int i;
	for (i=0;i<4;i++)
	{
		Teams[i] = Spawn(class'TeamInfo');
		Teams[i].Size = 0;
		Teams[i].Score = 0;
		Teams[i].TeamName = TeamColor[i];
		Teams[i].TeamIndex = i;
	}
	Super.PostBeginPlay();
}

event InitGame( string Options, out string Error )
{
	Super.InitGame(Options, Error);
	GoalTeamScore = FragLimit;
}

//------------------------------------------------------------------------------
// Player start functions


//FindPlayerStart
//- add teamnames as new teams enter
//- choose team spawn point if bSpawnInTeamArea

function playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local PlayerPawn newPlayer;
	local NavigationPoint StartSpot;

	newPlayer = Super.Login(Portal, Options, Error, SpawnClass);
	if ( newPlayer == None)
		return None;

	if ( bSpawnInTeamArea )
	{
		StartSpot = FindPlayerStart(newPlayer,255, Portal);
		if ( StartSpot != None )
		{
			NewPlayer.SetLocation(StartSpot.Location);
			NewPlayer.SetRotation(StartSpot.Rotation);
			NewPlayer.ViewRotation = StartSpot.Rotation;
			NewPlayer.ClientSetRotation(NewPlayer.Rotation);
			StartSpot.PlayTeleportEffect( NewPlayer, true );
		}
	}
				
	return newPlayer;
}

function Logout(pawn Exiting)
{
	Super.Logout(Exiting);
	if ( Exiting.IsA('Spectator') )
		return;
	Teams[Exiting.PlayerReplicationInfo.Team].Size--;
}
	
function NavigationPoint FindPlayerStart( Pawn Player, optional byte InTeam, optional string incomingName )
{
	local PlayerStart Dest, Candidate[4], Best;
	local float Score[4], BestScore, NextDist;
	local pawn OtherPlayer;
	local int i, num;
	local Teleporter Tel;
	local NavigationPoint N;
	local byte Team;

	if ( (Player != None) && (Player.PlayerReplicationInfo != None) )
		Team = Player.PlayerReplicationInfo.Team;
	else
		Team = InTeam;

	if( incomingName!="" )
		foreach AllActors( class 'Teleporter', Tel )
			if( string(Tel.Tag)~=incomingName )
				return Tel;
			
	num = 0;
	//choose candidates	
	for ( N=Level.NavigationPointList; N!=None; N=N.nextNavigationPoint )
		if ( N.IsA('PlayerStart') 
			&& (!bSpawnInTeamArea || (Team == PlayerStart(N).TeamNumber)) )
		{
			if (num<4)
				Candidate[num] = PlayerStart(N);
			else if (Rand(num) < 4)
				Candidate[Rand(4)] = PlayerStart(N);
			num++;
		}

	if (num == 0 )
	{
		foreach AllActors( class'PlayerStart', Dest )
		{
			if (num<4)
				Candidate[num] = Dest;
			else if (Rand(num) < 4)
				Candidate[Rand(4)] = Dest;
			num++;
		}
	}

	if (num>4) num = 4;
	else if (num == 0)
		return None;
		
	//assess candidates
	for (i=0;i<num;i++)
		Score[i] = 4000 * FRand(); //randomize
		
	for ( OtherPlayer=Level.PawnList; OtherPlayer!=None; OtherPlayer=OtherPlayer.NextPawn)	
		if ( OtherPlayer.bIsPlayer && (OtherPlayer.Health > 0) && !OtherPlayer.IsA('Spectator') )
			for (i=0;i<num;i++)
				if ( OtherPlayer.Region.Zone == Candidate[i].Region.Zone )
				{
					NextDist = VSize(OtherPlayer.Location - Candidate[i].Location);
					if (NextDist < CollisionRadius + CollisionHeight)
						Score[i] -= 1000000.0;
					else if ( (NextDist < 1400) && (Team != OtherPlayer.PlayerReplicationInfo.Team) && OtherPlayer.LineOfSightTo(Candidate[i]) )
						Score[i] -= 10000.0;
				}
	
	BestScore = Score[0];
	Best = Candidate[0];
	for (i=1;i<num;i++)
	{
		if (Score[i] > BestScore)
		{
			BestScore = Score[i];
			Best = Candidate[i];
		}
	}			
				
	return Best;
}

function bool AddBot()
{
	local NavigationPoint StartSpot;
	local bots NewBot;
	local int BotN, DesiredTeam;

	BotN = BotConfig.ChooseBotInfo();
	
	// Find a start spot.
	StartSpot = FindPlayerStart(None, 255);
	if( StartSpot == None )
	{
		log("Could not find starting spot for Bot");
		return false;
	}

	// Try to spawn the player.
	NewBot = Spawn(BotConfig.GetBotClass(BotN),,,StartSpot.Location,StartSpot.Rotation);

	if ( NewBot == None )
		return false;

	if ( (bHumansOnly || Level.bHumansOnly) && !NewBot.bIsHuman )
	{
		NewBot.Destroy();
		log("Failed to spawn bot");
		return false;
	}

	StartSpot.PlayTeleportEffect(NewBot, true);

	// Init player's information.
	BotConfig.Individualize(NewBot, BotN, NumBots);
	NewBot.ViewRotation = StartSpot.Rotation;

	// broadcast a welcome message.
	BroadcastMessage( NewBot.PlayerReplicationInfo.PlayerName$EnteredMessage, true );

	AddDefaultInventory( NewBot );
	NumBots++;

	DesiredTeam = BotConfig.GetBotTeam(BotN);
	if ( (DesiredTeam == 255) || !ChangeTeam(NewBot, DesiredTeam) )
	{
		ChangeTeam(NewBot, NextBotTeam);
		NextBotTeam++;
		if ( NextBotTeam >= MaxTeams )
			NextBotTeam = 0;
	}

	if ( bSpawnInTeamArea )
	{
		StartSpot = FindPlayerStart(newBot, 255);
		if ( StartSpot != None )
		{
			NewBot.SetLocation(StartSpot.Location);
			NewBot.SetRotation(StartSpot.Rotation);
			NewBot.ViewRotation = StartSpot.Rotation;
			NewBot.ClientSetRotation(NewBot.Rotation);
			StartSpot.PlayTeleportEffect( NewBot, true );
		}
	}

	return true;
}

//-------------------------------------------------------------------------------------
// Level gameplay modification

//Use reduce damage for teamplay modifications, etc.
function int ReduceDamage(int Damage, name DamageType, pawn injured, pawn instigatedBy)
{
	local int reducedDamage;

	if (injured.Region.Zone.bNeutralZone)
		return 0;
	
	if ( instigatedBy == None )
		return Damage;

	Damage *= instigatedBy.DamageScaling;

	if ( (instigatedBy != injured) 
		&& (injured.PlayerReplicationInfo.Team ~= instigatedBy.PlayerReplicationInfo.Team) )
		return (Damage * FriendlyFireScale);
	else
		return Damage;
}

function Killed(pawn killer, pawn Other, name damageType)
{
	Super.Killed(killer, Other, damageType);

	if( (killer == Other) || (killer == None) )
		Teams[Other.PlayerReplicationInfo.Team].Score -= 1.0;
	else
		Teams[killer.PlayerReplicationInfo.Team].Score += 1.0;

	if ( (GoalTeamScore > 0) && (Teams[killer.PlayerReplicationInfo.Team].Score >= GoalTeamScore) )
		EndGame("teamscorelimit");
}

function bool ChangeTeam(Pawn Other, int NewTeam)
{
	local int i, s;
	local pawn APlayer;
	local teaminfo SmallestTeam;
	local string SkinName, FaceName;

	for( i=0; i<MaxTeams; i++ )
		if ( (Teams[i].Size < MaxTeamSize) 
				&& ((SmallestTeam == None) || (SmallestTeam.Size > Teams[i].Size)) )
		{
			s = i;
			SmallestTeam = Teams[i];
		}

	if ( NewTeam == 255 )
		NewTeam = s;

	if ( Other.IsA('Spectator') )
	{
		Other.PlayerReplicationInfo.Team = NewTeam;
		Other.PlayerReplicationInfo.TeamName = Teams[NewTeam].TeamName;
		return true;
	}
	if ( Other.PlayerReplicationInfo.Team != 255 )
	{
		if ( bNoTeamChanges )
			return false;
		Teams[Other.PlayerReplicationInfo.Team].Size--;	
	}

	for( i=0; i<MaxTeams; i++ )
	{
		if ( i == NewTeam )
		{
			if (Teams[i].Size < MaxTeamSize)
			{
				AddToTeam(i, Other);
				return true;
			}
			else 
				break;
		}
	}

	if ( (SmallestTeam != None) && (SmallestTeam.Size < MaxTeamSize) )
	{
		AddToTeam(s, Other);
		return true;
	}

	return false;
}

function AddToTeam( int num, Pawn Other )
{
	local teaminfo aTeam;
	local Pawn P;
	local bool bSuccess;
	local string SkinName, FaceName;

	aTeam = Teams[num];

	aTeam.Size++;
	Other.PlayerReplicationInfo.Team = num;
	Other.PlayerReplicationInfo.TeamName = aTeam.TeamName;
	bSuccess = false;
	if ( Other.IsA('PlayerPawn') )
		Other.PlayerReplicationInfo.TeamID = 0;
	else
		Other.PlayerReplicationInfo.TeamID = 1;

	while ( !bSuccess )
	{
		bSuccess = true;
		for ( P=Level.PawnList; P!=None; P=P.nextPawn )
                        if ( P.bIsPlayer && (P != Other) 
							&& (P.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team) 
							&& (P.PlayerReplicationInfo.TeamId == Other.PlayerReplicationInfo.TeamId) )
				bSuccess = false;
		if ( !bSuccess )
			Other.PlayerReplicationInfo.TeamID++;
	}

	BroadcastMessage(Other.PlayerReplicationInfo.PlayerName$NewTeamMessage$aTeam.TeamName, false);

	Other.static.GetMultiSkin(Other, SkinName, FaceName);
	Other.static.SetMultiSkin(Other, SkinName, FaceName, num);
}

function bool CanSpectate( pawn Viewer, actor ViewTarget )
{
	return ( (Spectator(Viewer) != None) 
			|| ((Pawn(ViewTarget) != None) && (Pawn(ViewTarget).PlayerReplicationInfo.Team == Viewer.PlayerReplicationInfo.Team)) );
}

defaultproperties
{
     MaxTeams=2
     MaxTeamSize=16
     NewTeamMessage=" is now on "
     bCanChangeSkin=False
     bTeamGame=True
     ScoreBoardType=Class'UnrealShare.UnrealTeamScoreBoard'
     GameMenuType=Class'UnrealShare.UnrealTeamGameOptionsMenu'
     HUDType=Class'UnrealShare.UnrealTeamHUD'
     BeaconName="Team"
     GameName="Team Game"
     TeamColor(0)="Red"
     TeamColor(1)="Blue"
     TeamColor(2)="Green"
     TeamColor(3)="Gold"
     TEAM_Blue=1
     TEAM_Green=2
     TEAM_Gold=3
 	 RulesMenuType="UMenu.UMenuTeamGameRulesSClient"
 	 SettingsMenuType="UMenu.UMenuGameSettingsSClient"
}
