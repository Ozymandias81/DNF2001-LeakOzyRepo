//=============================================================================
// Assault.
//=============================================================================
class Assault extends TeamGamePlus
	config;

var TeamInfo Defender, Attacker;
var() config int Defenses;
var FortStandard Fort[16], BestFort;
var localized string AttackMessage, DefendMessage, TieMessage, WinMessage, ObjectivesMessage;
var int Destroyer;
var int numForts;
var float LastIncoming;
var SpectatorCam EndCam;

var config float SavedTime;
var config int NumDefenses;
var config int CurrentDefender;
var config bool bDefenseSet;
var config bool bTiePartOne;
var config string GameCode;
var config int Part;
var bool	bAssaultWon;
var bool	bFortDown;

var localized string DefenderSuccess;
var Pawn Leader[4];		// current leader of each team (used by bots)
	
function PostBeginPlay()
{
	local int i, Num;
	local FortStandard F;

	Super.PostBeginPlay();

	numForts = 0;
	ForEach AllActors(class'FortStandard', F)
	{
		Fort[numForts] = F;
		numForts++;
	}

	//randomize fort order (so AI doesn't always attack/defend in same order)
	for ( i=0; i<numForts; i++ )
		if ( FRand() < 0.5 )
		{
			F = Fort[numForts-i-1];
			Fort[numForts-i-1]= Fort[i];
			Fort[i] = F;
		}			

	if (GameCode == "")
	{
		while (i<8) 
		{
			Num = Rand(123);
			if ( ((Num >= 48) && (Num <= 57)) || 
				 ((Num >= 65) && (Num <= 91)) ||
				((Num >= 97) && (Num <= 123)) ) 
			{
				GameCode = GameCode$Chr(Num);
				i++;
			}
		}
	}
	if (WorldLog != None)
	{
		WorldLog.LogSpecialEvent("assault_timelimit", TimeLimit);
		WorldLog.LogSpecialEvent("assault_gamecode", GameCode, Part);
	}
	if (LocalLog != None)
	{
		LocalLog.LogSpecialEvent("assault_timelimit", TimeLimit);
		LocalLog.LogSpecialEvent("assault_gamecode", GameCode, Part);
	}
}

function AddDefaultInventory( pawn PlayerPawn )
{
	bUseTranslocator = false; // never allow translocator in assault
	Super.AddDefaultInventory(PlayerPawn);
}	

function InitRatedGame(LadderInventory LadderObj, PlayerPawn LadderPlayer)
{
	Super.InitRatedGame(LadderObj, LadderPlayer);
	Defenses = 3;
	MaxTeams = 2;
	bJumpMatch = false;
}

static function ResetGame()
{
	local int i;

	Default.bDefenseSet = False;
	Default.NumDefenses = 0;
	Default.CurrentDefender = 0;
	Default.SavedTime = 0;
	Default.GameCode = "";
	Default.Part = 1;
	Default.bTiePartOne = false;
	StaticSaveConfig();
}

event InitGame( string Options, out string Error )
{
	local FortStandard F;
	local name EndCamTag;
	
	Super.InitGame(Options, Error);

	TimeLimit = 1;
	if ( SavedTime > 0 )
	{
		RemainingTime = SavedTime;
		ForEach AllActors(class'FortStandard', F)
			if ( F.EndCamTag != '' )
				EndCamTag = F.EndCamTag;
	}
	else
	{
		ForEach AllActors(class'FortStandard', F)
		{
			TimeLimit = Max(TimeLimit, F.DefenseTime);
			if ( F.EndCamTag != '' )
				EndCamTag = F.EndCamTag;
		}
		
		RemainingTime = TimeLimit * 60;
	}
	if ( EndCamTag != '' )
		ForEach AllActors(class'SpectatorCam', EndCam, EndCamTag)
			break;
	GoalTeamScore = 0;
	FragLimit = 0;
	bUseTranslocator = false;
	bJumpMatch = false;
}

function FallBackTo(name F, int Priority)
{
	local int i;

	for ( i=0; i<numForts; i++ )
		if ( Fort[i].tag == F )
		{
			Fort[i].DefensePriority = Priority;
			return;
		}
}

function bool SuccessfulGame()
{
	local int i;

	if (RatedPlayer.PlayerReplicationInfo.Team == Attacker.TeamIndex)
	{
		// If the player is the attacker.
		return bAssaultWon;
	} else {
		// If the player is the defender.
		return !bAssaultWon;
	}
}

function bool RestartPlayer( pawn aPlayer )	
{
	local Bot B;

	// boost attacker AI a little
	B = Bot(aPlayer);
	if ( (B != None) && (B.PlayerReplicationInfo.Team != Defender.TeamIndex)
		&& (Bot(Leader[B.PlayerReplicationInfo.Team]) != None) ) 
	{
		if ( bNoviceMode && (Level.Game.Difficulty == 3) )
		{
			B.bNovice = false;
			B.skill = 0;
		}
		else
			B.skill = FClamp(Level.Game.Difficulty + 1, B.skill, 3); 
	}
	return Super.RestartPlayer(aPlayer);
}

function RestartGame()
{
	local Pawn P;
	local int i;

	if ( bDontRestart )
		return;

	if ( !bGameEnded || (EndTime > Level.TimeSeconds) ) // still showing end screen
		return;

	// If a team has defended and attacked, the game is over
	// Or in a rated game if the player failed on attack
	if ( bDefenseSet 
		|| (bRatedGame && (RatedPlayer.PlayerReplicationInfo.TeamID == Attacker.TeamIndex) && !bAssaultWon) ) 
	{
		ResetGame();
		Super.RestartGame();
		return;
	}

	bDontRestart = true; // don't restart more than once
	bDefenseSet = true;	
	if ( Defender.TeamIndex == 1 )
		CurrentDefender = 0;
	else
		CurrentDefender = 1;
	Part = 2;
	SavedTime  = TimeLimit * 60 - RemainingTime;

	SaveConfig();
	Level.ServerTravel( "?Restart", false );
}

function PlayStartUpMessage(PlayerPawn NewPlayer)
{
	if ( NewPlayer.PlayerReplicationInfo.Team > 1 )
		return;

	if ( Defender == Teams[NewPlayer.PlayerReplicationInfo.Team] )
		StartupMessage = DefendMessage;
	else
		StartUpMessage = AttackMessage;

	Super.PlayStartupMessage(NewPlayer);
}

// Defenders always use team 0 labelled starts, attackers use team 1 labelled starts	
function NavigationPoint FindPlayerStart(Pawn Player, optional byte InTeam, optional string incomingName)
{
	local Pawn P;
	local int i,d;
	local byte Team;

	if ( (Player != None) && (Player.PlayerReplicationInfo != None) )
		Team = Player.PlayerReplicationInfo.Team;
	else
		Team = InTeam;

	if ( Team != 255 )
	{
		if ( Team > 1 )
			Team = 0;
		if ( Defender == None )
		{
			if ( bDefenseSet )
				d = CurrentDefender;
			else if ( Team == 0 )
				d = 1;
			else 
				d = 0;

			Defender = Teams[d];
			if ( d == 0 )
				Attacker = Teams[1];
			else
				Attacker = Teams[0];

			for ( P=Level.PawnList; P!=None; P=P.NextPawn )
				if ( P.IsA('StationaryPawn') )
					StationaryPawn(P).SetTeam(Defender.TeamIndex);

			for (i=0; i<numForts; i++ )
			{
				if ( d == 0 )
					Fort[i].Skin = texture'JFlag11';
				else if ( d == 1 )
					Fort[i].Skin = texture'JFlag12'; 
			}
			if (WorldLog != None)
			{
				WorldLog.LogSpecialEvent("assault_defender", Defender.TeamIndex);
				WorldLog.LogSpecialEvent("assault_attacker", Attacker.TeamIndex);
			}
			if (LocalLog != None)
			{
				LocalLog.LogSpecialEvent("assault_defender", Defender.TeamIndex);
				LocalLog.LogSpecialEvent("assault_attacker", Attacker.TeamIndex);
			}
		}
		if ( Teams[Team] == Defender )
			Team = 0;
		else
			Team = 1;
	}

	return Super.FindPlayerStart(None, Team, incomingName);
}

function SendStartMessage(PlayerPawn P)
{
	P.ClearProgressMessages();
	P.SetProgressTime(8);
	if ( P.PlayerReplicationInfo.Team == Defender.TeamIndex )
	{
		P.SetProgressMessage(StartMessage, 0);
		P.SetProgressMessage(DefendMessage, 1);
	} else {
		P.SetProgressMessage(StartMessage, 0);
		P.SetProgressMessage(AttackMessage, 1);
	}
	if (RatedPlayer == None)
		P.SetProgressMessage(ObjectivesMessage, 2);
}

function RemoveFort(FortStandard F, Pawn instigator)
{
	local int i;
	local Pawn P;
	local bool bFound;
	local NavigationPoint N;
	local Bot B;

	bFortDown = true;
	if ( instigator.bIsPlayer )
		instigator.PlayerReplicationInfo.Score += 10;
	if ( F.DestroyedMessage != "" )
		BroadcastMessage(F.FortName@F.DestroyedMessage, true, 'CriticalEvent');

	if ( F.bSayDestroyed 
		&& (instigator.IsA('Bot') || ((TournamentPlayer(instigator) != None) && TournamentPlayer(instigator).bAutoTaunt)) )
		instigator.SendTeamMessage(None, 'OTHER', 16, 15);
	else
		bFulfilledSpecial = true;
				
	if ( F.Tag != '' )
		for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
			if ( N.IsA('Defensepoint') && (DefensePoint(N).FortTag == F.Tag) )
			{
				if ( N.taken )
					for ( P=Level.PawnList; P!=None; P=P.NextPawn )
						if ( P.IsA('Bot') && Bot(P).AmbushSpot == N )
							Bot(P).AmbushSpot = None;
				N.taken = true;
			}

	if ( !F.bFinalFort )
	{
		for ( i=0; i<(numForts - 1); i++ )
		{
			if ( Fort[i] == F )
				bFound = true;
			if ( bFound )
				Fort[i] = Fort[i+1];
		}
		Fort[numForts] = None;
		numForts--;
	}
	if ( F.bFinalFort || (numForts == 0) )
	{
		if ( instigator.bIsPlayer )
			instigator.PlayerReplicationInfo.Score += 100;
		bAssaultWon = true;
		EndGame("Assault succeeded!");
	}
	else
	{
		for ( P=Level.PawnList; P!=None; P=P.nextPawn )
		{
			B = Bot(P);
			if ( B != None )
			{
				if ( (BotReplicationInfo(B.PlayerReplicationInfo).RealOrders == 'Defend') && (B.OrderObject == F) )
				{
					B.SetOrders(BotReplicationInfo(B.PlayerReplicationInfo).RealOrders, None, true);
					B.OrderObject = SetDefenseFor(Bot(P));
					BotReplicationInfo(B.PlayerReplicationInfo).OrderObject = B.OrderObject;
				}
				else
					B.Killed(None, F, '');
			}
		}
	}
}

function Killed(pawn killer, pawn Other, name damageType)
{
	Super.Killed(killer, Other, damageType);
	if ( (Other == Leader[Other.PlayerReplicationInfo.Team]) && Other.IsA('Bot') )
		ElectNewLeaderFor(Bot(Other));
}

function bool SetEndCams(string Reason)
{
	local pawn P;
	local PlayerPawn Player;
	local int ConquerTime, Minutes, Seconds;
	local string TimeResult;
	local actor A;
	local bool bTieGame;

	GameReplicationInfo.bStopCountDown = true;
	EndTime = Level.TimeSeconds + EndCam.FadeOutTime;
	if ( bAssaultWon )
	{
		if ( SavedTime > 0 )
 			ConquerTime = SavedTime - RemainingTime;
		else
 			ConquerTime = TimeLimit * 60 - RemainingTime;
		Minutes = ConquerTime/60;
		if ( Minutes > 0 )
			TimeResult = string(Minutes)$":";
		else
			TimeResult = ":";
		Seconds = ConquerTime % 60;
		if ( Seconds == 0 )
			TimeResult = TimeResult$"00";
		else if ( Seconds < 10 )
			TimeResult = TimeResult$"0"$Seconds;
		else
			TimeResult = TimeResult$Seconds;
		GameReplicationInfo.GameEndedComments = TeamPrefix@Attacker.TeamName@GameEndedMessage@TimeResult;
		if ( bDefenseSet )
			GameReplicationInfo.GameEndedComments = GameReplicationInfo.GameEndedComments@WinMessage;
		Attacker.Score += 1;
		if ( (EndCam != None) && (EndCam.Event != '') )
			ForEach AllActors(class'Actor', A, EndCam.Event)
				A.Trigger(None, None);
	}
	else
	{
		GameReplicationInfo.GameEndedComments = TeamPrefix@Defender.TeamName@DefenderSuccess;
		if ( bDefenseSet )
		{
			bTieGame = bTiePartOne;
			if ( bTiePartOne )
				GameReplicationInfo.GameEndedComments = GameReplicationInfo.GameEndedComments@TieMessage;
			else
				GameReplicationInfo.GameEndedComments = GameReplicationInfo.GameEndedComments@WinMessage;
		}
		else
		{
			bTiePartOne = true;
			GameReplicationInfo.GameEndedComments = GameReplicationInfo.GameEndedComments$"!";
		}
		Defender.Score += 1;
	}

	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
	{
		Player = Playerpawn(P);
		if ( Player != None )
		{
			if ( bAssaultWon )
			{
				Player.ViewTarget = EndCam;
				Player.bBehindView = false;
				Player.bFixedCamera = true;
				if ( !bTutorialGame && !bTieGame && bDefenseSet )
					PlayWinMessage(Player, (Player.PlayerReplicationInfo.Team == Attacker.TeamIndex));
			}
			else
			{
				if ( !bTutorialGame && !bTieGame && bDefenseSet)
					PlayWinMessage(Player, (Player.PlayerReplicationInfo.Team == Defender.TeamIndex));
				Player.bBehindView = true;
			}
			Player.ClientGameEnded();
		}
		P.GotoState('GameEnded');
	}
	CalcEndStats();
	return true;
}

function CalcEndStats()
{
	EndStatsClass.Default.TotalGames++;
	EndStatsClass.Static.StaticSaveConfig();
}

function bool BestFortFor(Bot aBot, FortStandard oldFort, FortStandard currentFort)
{
	if ( (currentFort.DefensePriority > oldFort.DefensePriority)
		|| ((currentFort.DefensePriority == oldFort.DefensePriority)
		   && ((currentFort.Defender == None) || (currentFort.Defender == aBot)
				|| ((oldFort.Defender != None) && (oldFort.Defender != aBot) && (FRand() < 0.5)))) )
	{
		if ( oldFort.Defender == aBot )
			oldFort.Defender = None;
		return true;
	}
	
	return false;
}

function FortStandard AttackFort(Bot aBot, out byte bMultiSame)
{
	local int i;
	
	BestFort = Fort[0];
	bMultiSame = 0;
	for ( i=1; i<numForts; i++ )
	{
		if ( BestFort.DefensePriority < Fort[i].DefensePriority )
			BestFort = Fort[i];
		else if ( BestFort.DefensePriority == Fort[i].DefensePriority )
		{
			if ( aBot.LineOfSightTo(Fort[i]) )
				BestFort = Fort[i];
			bMultiSame = 1;
		}
	}

	return BestFort;
}

function Actor SetDefenseFor(Bot aBot)
{
	local int i, best;
	local FortStandard F;

	if ( aBot.PlayerReplicationInfo.Team != Defender.TeamIndex )
	{
		aBot.SetOrders('Attack', None);	
		return None;
	}

	for ( i=0; i<numForts; i++ )
		if ( (F == None) || BestFortFor(aBot, F, Fort[i])  )
			F = Fort[i];
	
	if ( F != None )
		F.Defender = aBot;
	else
		aBot.SetOrders('FreeLance', None, true);				
	return F;
}

function bool FindPathToFortFor(Bot aBot, Actor Dest)
{
	local FortStandard F;

	if ( Dest == None )
	{
		aBot.SetOrders('Freelance', None, true);
		return false;
	}

	F = FortStandard(Dest);
	if ( (F != None) && (F.NearestPath != None) )
		aBot.MoveTarget = aBot.FindPathToward(F.NearestPath);
	else
		aBot.MoveTarget = aBot.FindPathToward(Dest);

	if ( aBot.MoveTarget == None )
	{
		aBot.bStayFreelance = true;
		aBot.Orders = 'FreeLance';
		if ( aBot.bVerbose )
			log(aBot.PlayerReplicationInfo.PlayerName$" freelance because no path to fort "$F$" from "$aBot.Location);
		return false;
	}
	else
	{
		SetAttractionStateFor(aBot);
		return true;
	}
}

function bool SendBotToGoal(Bot aBot)
{
	local byte bMultiSame;

	return FindPathToFortFor(aBot, AttackFort(aBot,bMultiSame));
}

function bool AttackOnlyLocalFort(Bot aBot)
{
	local FortStandard F;
	local bool bVisible, bPressOn;
	local byte bMultiSame;
	local float dist;

	F = AttackFort(aBot,bMultiSame);
	if ( F != None )
	{
		bPressOn = ( !Leader[aBot.PlayerReplicationInfo.Team].IsA('PlayerPawn')
					|| aBot.Region.Zone.bWaterZone
					|| (Leader[aBot.PlayerReplicationInfo.Team].Health <= 0)
					|| ((VSize(Leader[aBot.PlayerReplicationInfo.Team].Location - F.Location) < 1500)
						&& Leader[aBot.PlayerReplicationInfo.Team].LineOfSightTo(F))
					|| ((aBot.Enemy != None) && (Level.TimeSeconds - aBot.LastSeenTime < 1.5)) );

		dist = VSize(aBot.Location - F.Location);
		if ( F.bTriggerOnly )
		{
			if ( (bMultiSame == 1) || ((dist < F.ChargeDist)
				&& (aBot.Region.Zone == F.Region.Zone) && (F.bForceRadius || aBot.LineOfSightTo(F))) )
			{
				if ( aBot.ActorReachable(F) )
				{
					SetAttractionStateFor(aBot);
					aBot.MoveTarget = F;
					return true;
				}
				else if ( !F.bForceRadius && !bPressOn )
					return false;
				else
					return FindPathToFortFor(aBot, F);
				}
		}
		else if ( dist < 2 * F.ChargeDist ) 
		{
			bVisible = aBot.LineOfSightTo(F);
			if ( F.bForceRadius || bVisible || (bPressOn  && ((bMultiSame == 1) || (aBot.Region.Zone == F.Region.Zone))) )
			{
				aBot.SetEnemy(F);
				if ( aBot.Enemy == F )
				{
					if ( bVisible && (dist < 1200) )
					{
						aBot.GotoState('RangedAttack');
						return true;
					}
					else
						return FindPathToFortFor(aBot, F);
				}
			}
		}
	}
	if ( FortStandard(aBot.Enemy) != None )
	{
		aBot.Enemy = aBot.OldEnemy;
		aBot.OldEnemy = None;
		if ( FortStandard(aBot.Enemy) != None )
			aBot.Enemy = None;
	}
	return false;
}

function bool FindSpecialAttractionFor(Bot aBot)
{
	local Pawn P;
	local int num, needed;
	local Bot B;
	local float dist;

	if ( aBot.LastAttractCheck == Level.TimeSeconds )
		return false;
	aBot.LastAttractCheck = Level.TimeSeconds;

	if ( aBot.PlayerReplicationInfo.Team != Defender.TeamIndex )
	{
		if ( !aBot.Weapon.bMeleeWeapon
			&& (FortStandard(aBot.Enemy) != None) && (aBot.OldEnemy == None)
			&& aBot.LineOfSightTo(aBot.Enemy) )
		{
			if ( FortStandard(aBot.Enemy).bTriggerOnly )
			{
				if ( aBot.ActorReachable(aBot.Enemy) )
				{
					SetAttractionStateFor(aBot);
					aBot.MoveTarget = aBot.Enemy;
					return true;
				}
			}
			else
			{
				aBot.GotoState('RangedAttack');
				return true;
			}
		}
		else if ( aBot.Orders == 'Hold' ) 
			return AttackOnlyLocalFort(aBot);
		else if ( (aBot.Orders == 'Follow')	&& ((TimeLimit == 0) || (RemainingTime > 100)) 
				&& (!aBot.Region.Zone.IsA('KillingField') || aBot.OrderObject.IsA('PlayerPawn') || (Pawn(aBot.OrderObject).Health <= 0)) )
		{
			if ( !aBot.CloseToPointMan(Pawn(aBot.OrderObject)) )
			{
				if ( aBot.OrderObject.IsA('Bot') && ((aBot.Weapon == None) || (aBot.Weapon.AIRating < 0.5)) )
					return false;
				if ( aBot.ActorReachable(aBot.OrderObject) )
					aBot.MoveTarget = aBot.OrderObject;
				else
					aBot.MoveTarget = aBot.FindPathToward(aBot.OrderObject);
				if ( (aBot.MoveTarget != None) && (VSize(aBot.Location - aBot.MoveTarget.Location) > 2 * aBot.CollisionRadius) )
				{
					SetAttractionStateFor(aBot);
					return true;
				}
			}
			return AttackOnlyLocalFort(aBot);
		}
		else if ( aBot == Leader[aBot.PlayerReplicationInfo.Team] ) // if leader, make sure followers are close
		{
			if ( aBot.Orders != 'Attack' )
				aBot.SetOrders('Attack', None);
			if ( (aBot.Weapon == None) || (aBot.Weapon.AIRating < 0.5) )
				return false;

			if ( aBot.Region.Zone.bWaterZone || aBot.Region.Zone.IsA('KillingField') || ((TimeLimit > 0) && (RemainingTime < 100)) )
				needed = 0;
			else
			{
				needed = Min(2, Teams[aBot.PlayerReplicationInfo.Team].Size - 2 );
				for ( P=Level.PawnList; P!=None; P=P.NextPawn )
				{
					if ( P.bIsPlayer && (P.PlayerReplicationInfo.Team == aBot.PlayerReplicationInfo.Team)
						&& (P != aBot) )
					{
						B = Bot(P);
						if ( B != None )
						{
							Dist = VSize(B.Location - aBot.Location);
							if ( (Dist < 600) || ((Dist < 1600) && (B.LineOfSightTo(aBot))) )
							{
								num++;
								if ( num == needed )
									break;
							}
						}
					}
				}
			}
			aBot.GoalString="Leader has"@num@"vs"@needed;
			if ( num < needed )
			{
				if ( AttackOnlyLocalFort(aBot) )
					return true;
				if ( aBot.Enemy == None )
				{
					aBot.CampTime = 1.0;
					aBot.bCampOnlyOnce = true;
					aBot.GotoState('Roaming', 'Camp');
					return true;
				}
				else if ( !aBot.LineOfSightTo(aBot.Enemy) )
				{
					aBot.GotoState('StakeOut');
					return true;
				}
				else
					return FindPathToFortFor(aBot, BestFort);
			}
		}
	}

	if ( (aBot.Weapon == None) || (aBot.Weapon.AIRating < 0.5) )
		return false;

	if ( aBot.PlayerReplicationInfo.Team == Defender.TeamIndex )
	{
		aBot.GoalString = "Defender of"@aBot.OrderObject;
		if ( (aBot.Enemy != None) && (Level.TimeSeconds - LastIncoming > 12) )
		{
			LastIncoming = Level.TimeSeconds;
			aBot.SendTeamMessage(None, 'OTHER', 14, 15); //"Incoming!"
		}			
		if ( !aBot.bKamikaze && (aBot.Health < 40) )
		{
			aBot.bKamikaze = ( FRand() < 0.1 );
			return false;
		}

		if ( (aBot.Enemy != None) && (FRand() < 0.2) )
		{
			aBot.Orders = 'FreeLance';
			aBot.GoalString = "FreeLancer";
		}
		else if ( (aBot.Enemy == None) && (BotReplicationInfo(aBot.PlayerReplicationInfo).RealOrders == 'Defend') )
		{
			aBot.Orders = 'Defend';
			aBot.GoalString = "Defending";
		}
		if ( aBot.Orders != 'Defend' )
			return false;
		else
		{
			if ( (aBot.Enemy == None) && aBot.FindAmbushSpot() )
				return true;

			if ( aBot.AmbushSpot != None )
			{
				if ( aBot.LineOfSightTo(aBot.AmbushSpot) )
					return false;
				else if ( aBot.Enemy == None )
				{ 
					aBot.MoveTarget = aBot.FindPathToward(aBot.Ambushspot);
					if ( aBot.MoveTarget != None )
					{
						SetAttractionStateFor(aBot);
						return true;
					}
				}
			}
			else if ( aBot.LineOfSightTo(aBot.OrderObject) )
				return false;
			return FindPathToFortFor(aBot, aBot.OrderObject);
		}
	}		
	else
	{
		if ( AttackOnlyLocalFort(aBot) )
			return true;		

		if ( aBot.Orders == 'Freelance' )
		{
			if ( BotReplicationInfo(aBot.PlayerReplicationInfo).RealOrders == 'Freelance' )
				return false;
			if ( (FRand() < 0.1) || ((TimeLimit > 0) && (RemainingTime < 120)) )
				aBot.SetOrders(BotReplicationInfo(aBot.PlayerReplicationInfo).RealOrders, BotReplicationInfo(aBot.PlayerReplicationInfo).RealOrderGiver, true);
			else
				return false;
		}

		return FindPathToFortFor(aBot, BestFort);
	}

	return false;
}
	
function byte AssessBotAttitude(Bot aBot, Pawn Other)
{
	local Pawn P;
	local int num, needed;
	local Bot B;
	local float Dist;

	if ( Other.IsA('FortStandard') )
	{
		if ( aBot.PlayerReplicationInfo.Team == Defender.TeamIndex )
			return 3;
		else
			return 1;
	}
	else if ( BotReplicationInfo(aBot.PlayerReplicationInfo).RealOrders == 'Attack' ) 
	{
		if ( (aBot == Leader[aBot.PlayerReplicationInfo.Team])
			&& ((Other.Location.Z > aBot.Location.Z + 512) || Other.IsA('TeamCannon')) )
		{
			// ignore if enough followers to press on
			needed = Min(2, Teams[aBot.PlayerReplicationInfo.Team].Size - 2 );
			for ( P=Level.PawnList; P!=None; P=P.NextPawn )
			{
				if ( P.bIsPlayer && (P.PlayerReplicationInfo.Team == aBot.PlayerReplicationInfo.Team)
					&& (P != aBot) )
				{
					B = Bot(P);
					if ( (B != None)
						&& (B.Orders == 'Follow') && (B.OrderObject == aBot) )
					{
						Dist = VSize(B.Location - aBot.Location);
						if ( (Dist < 600) || ((Dist < 1600) && (B.LineOfSightTo(aBot))) )
						{
							num++;
							if ( num == needed )
								break;
						}
					}
				}
			}
			if ( num < needed )
				return 1;
			else
				return 2; //ignore
		}
		else if ( Other.bIsPlayer && (aBot.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team) )
			return 3;
		else 
			return 1;
	}
	else 
		return Super.AssessBotAttitude(aBot, Other);
}
 
function float GameThreatAdd(Bot aBot, Pawn Other)
{
	if ( Other.IsA('FortStandard') && (aBot.PlayerReplicationInfo.Team != Defender.TeamIndex) )
		return 5;
	if ( Other.IsA('TeamCannon') || (Other.Location.Z - Location.Z > 500) )
		return -5;
}

function SetBotOrders(Bot NewBot)
{
	local Pawn P, L;
	local int num;

	NewBot.BaseAggressiveness += 0.3;
	if ( IsOnTeam(NewBot,0) )
	{
		NewBot.SetOrders('Defend', None, true);
		return;
	}

	NewBot.SetOrders('Attack', None, true);

	// only follow players, if there are any
	For ( P=Level.PawnList; P!=None; P= P.NextPawn )
		if ( P.IsA('PlayerPawn') && (P.PlayerReplicationInfo.Team == NewBot.PlayerReplicationInfo.Team)
			&& !P.IsA('Spectator') )
	{
		num++;
		if ( (L == None) || (FRand() < 1.0/float(num)) )
			L = P;
	}
	
	if ( L != None ) 
	{
		Leader[NewBot.PlayerReplicationInfo.Team] = L;
		NumSupportingPlayer++;
		NewBot.SetOrders('Follow',L, true);
		return;
	}

	if ( NewBot.Orders == 'Defend' )
		return;

	// if no player to support, support a bot
	if ( Leader[NewBot.PlayerReplicationInfo.Team] == None )
	{
		// pick NewBot as leader
		Leader[NewBot.PlayerReplicationInfo.Team] = NewBot;
		NewBot.bLeading = true;
		return;
	}
		
	NewBot.SetOrders('Follow',Leader[NewBot.PlayerReplicationInfo.Team],true);
}	


function bool IsOnTeam(Pawn Other, int TeamNum)
{
	if ( (Other == None) || (Other.PlayerReplicationInfo == None) )
		return false;
	if ( Defender == Teams[Other.PlayerReplicationInfo.Team] )
		return (TeamNum == 0);

	return (TeamNum != 0);
}	

function PickAmbushSpotFor(Bot aBot)
{
	local NavigationPoint N;
	local bool bFreeDefense, bFortDefense, bFoundDefense;

	for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		if ( N.IsA('Defensepoint') && !N.taken && IsOnTeam(aBot,DefensePoint(N).team) )
		{
			if ( aBot.OrderObject != None )
			{
				bFreeDefense = (DefensePoint(N).FortTag == '');
				bFortDefense = !bFreeDefense && (DefensePoint(N).FortTag == aBot.OrderObject.Tag);
				if ( !bFoundDefense )
				{
					if ( bFortDefense )
					{
						bFoundDefense = true;
						aBot.AmbushSpot = AmbushPoint(N);
					}
					else if ( bFreeDefense && ((aBot.AmbushSpot == None) || (FRand() < 0.4)) )
						aBot.AmbushSpot = AmbushPoint(N);
				}
				else if ( bFortDefense )
				{
					if ( DefensePoint(N).priority > DefensePoint(aBot.Ambushspot).priority )
						aBot.Ambushspot = Ambushpoint(N);
					else if ( (DefensePoint(N).priority == DefensePoint(aBot.Ambushspot).priority)
						&& (FRand() < 0.4) ) 
						aBot.Ambushspot = Ambushpoint(N);
				}		
			}
			else if ( (aBot.AmbushSpot == None)
					|| (VSize(aBot.Location - aBot.Ambushspot.Location)
						> VSize(aBot.Location - N.Location)) )
				aBot.Ambushspot = Ambushpoint(N);
		}
}

// return true when leader has died/respawned, and bots should wait for him to show back up
// before advancing - and not fallback to the start
function bool WaitForPoint(bot aBot)
{
	if ( !aBot.Region.Zone.bWaterZone && bFortDown && (Level.TimeSeconds - aBot.PointDied < 12) && aBot.OrderObject.IsA('PlayerPawn') )
	{
		if ( (Pawn(aBot.OrderObject).Health > 0) && (VSize(aBot.Location - aBot.OrderObject.Location) < 1200) && aBot.LineOfSightTo(aBot.OrderObject) )
			aBot.PointDied = -1000;
		return (Level.TimeSeconds - aBot.PointDied < 12);
	}
	return false;
}

function ElectNewLeaderFor(bot OldLeader)
{
	local Pawn P;
	local Bot Best;
	local float BestDist, Dist;
	// leader died, find an appropriate new one
	// (closest to old leader)

	BestDist = 1000000;
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		if ( P.bIsPlayer && (P.PlayerReplicationInfo.Team == OldLeader.PlayerReplicationInfo.Team)
			&& (P != OldLeader) && (P.Health > 0)
			&& P.IsA('Bot') )
		{
			Dist = VSize(P.Location - OldLeader.Location);
			if ( Dist < BestDist )
			{
				BestDist = Dist;
				Best = Bot(P);
			}		
		}
	}
	if ( Best == None ) // keep old leader
		return;
	OldLeader.SetOrders('Follow', Best);
	Best.SetOrders('Attack', None);
	Best.GotoState('Attacking');
	Leader[OldLeader.PlayerReplicationInfo.Team] = Best;
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if ( P.bIsPlayer && (P.PlayerReplicationInfo.Team == OldLeader.PlayerReplicationInfo.Team)
			&& P.IsA('Bot')
			&& (BotReplicationInfo(P.PlayerReplicationInfo).RealOrders == 'Follow') )
			Bot(P).SetOrders('Follow',Best);
}	 

function bool HandleTieUp(Bot Bumper, Bot Bumpee)
{
	local Pawn P;

	if ( (Bumper == Leader[Bumper.PlayerReplicationInfo.Team])
		&& (FRand() < 0.35) 
		&& (VSize(Bumpee.Velocity) < 100) )
	{
		Leader[Bumper.PlayerReplicationInfo.Team] = Bumpee;	
		Bumper.SetOrders('Follow', Bumpee);
		Bumpee.SetOrders('Attack', None);
		Bumpee.GotoState('Attacking');
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
			if ( P.bIsPlayer && (P.PlayerReplicationInfo.Team == Bumper.PlayerReplicationInfo.Team)
				&& P.IsA('Bot')
				&& (BotReplicationInfo(P.PlayerReplicationInfo).RealOrders == 'Follow') )
				Bot(P).SetOrders('Follow',Bumpee);
		return true;
	}
	return false;
}

	
function bool NeverStakeOut(bot Other)
{
	if ( Other.Region.Zone.bWaterZone || Other.Region.Zone.IsA('KillingField') )
		return true;
	return false;
}

function bool ChangeTeam(Pawn Other, int NewTeam)
{
	local bool bRealBalance, bResult;

	bRealBalance = bPlayersBalanceTeams;
	if ( bDefenseSet )
		bPlayersBalanceTeams = false;
	if ( NewTeam > 1 )
		NewTeam = 255;
	bResult = Super.ChangeTeam(Other, NewTeam);
	bPlayersBalanceTeams = bRealBalance;
	return bResult;
}
			
defaultproperties
{
	 bCoopWeaponMode=true
     MaxTeams=2
	 MaxAllowedTeams=2
     Defenses=3
     AttackMessage="Take the enemy base!"
     DefendMessage="Defend your base against the enemy!"
	 ObjectivesMessage="Press F3 for an objectives briefing."
     bSpawnInTeamArea=True
     StartUpMessage=""
     MapListType=Class'BotPack.ASMapList'
     MapPrefix="AS"
     BeaconName="ASLT"
     GameName="Assault"
     HUDType=Class'BotPack.AssaultHUD'
	 bScoreTeamKills=false
     ScoreBoardType=Class'Botpack.AssaultScoreBoard'
	 GameEndedMessage="conquered the base in"
	 DefenderSuccess="defended the base"
	 TieMessage="Tie!"
	 WinMessage="and wins!"
	 LadderTypeIndex=4
     RulesMenuType="UTMenu.UTAssaultRulesSC"
	 NetWait=25
}
