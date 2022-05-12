//=============================================================================
// CTFGame.
//=============================================================================
class CTFGame extends TeamGamePlus
	config;

#exec AUDIO IMPORT FILE="Sounds\CTF\RockOnDude.wav" NAME="CaptureSound" GROUP="CTF"
#exec AUDIO IMPORT FILE="Sounds\CTF\ctf9.wav" NAME="CaptureSound2" GROUP="CTF"
#exec AUDIO IMPORT FILE="Sounds\CTF\ctf10.wav" NAME="CaptureSound3" GROUP="CTF"
#exec AUDIO IMPORT FILE="Sounds\CTF\returnf1.wav" NAME="ReturnSound" GROUP="CTF"

var	  int   GrowTimer;
var() sound CaptureSound[4];
var() sound ReturnSound;
var float LastGotFlag;
var float LastSeeFlagCarrier;

function Logout(pawn Exiting)
{
	if ( Exiting.PlayerReplicationInfo.HasFlag != None )
		CTFFlag(Exiting.PlayerReplicationInfo.HasFlag).SendHome();	
	Super.Logout(Exiting);
}

event InitGame( string Options, out string Error )
{
	Super.InitGame(Options, Error);
	if ( bRatedGame )
		GoalTeamScore = 5;

	FragLimit = 0;
}

function ScoreKill(pawn Killer, pawn Other)
{
	local int NextTaunt, i;
	local bool bAutoTaunt;

	if( (killer == Other) || (killer == None) )
		Other.PlayerReplicationInfo.Score -= 1;
	else if ( killer != None )
	{
		killer.killCount++;
		if ( Killer.bIsPlayer && Other.bIsPlayer && (Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team) )
			Killer.PlayerReplicationInfo.Score += 1;
	}
	if ( bAltScoring && (Killer != Other) && (killer != None) && Other.bIsPlayer )
		Other.PlayerReplicationInfo.Score -= 1;

	Other.DieCount++;
	if ( Other.bIsPlayer && (Other.PlayerReplicationInfo.HasFlag != None) )
	{
		if ( (Killer != None) && Killer.bIsPlayer && Other.bIsPlayer && (Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team) )
		{
			killer.PlayerReplicationInfo.Score += 4;
			bAutoTaunt = ((TournamentPlayer(Killer) != None) && TournamentPlayer(Killer).bAutoTaunt);
			if ( (Bot(Killer) != None) || bAutoTaunt )
			{
				NextTaunt = Rand(class<ChallengeVoicePack>(Killer.PlayerReplicationInfo.VoiceType).Default.NumTaunts);
				for ( i=0; i<4; i++ )
				{
					if ( NextTaunt == LastTaunt[i] )
						NextTaunt = Rand(class<ChallengeVoicePack>(Killer.PlayerReplicationInfo.VoiceType).Default.NumTaunts);
					if ( i > 0 )
						LastTaunt[i-1] = LastTaunt[i];
				}	
				LastTaunt[3] = NextTaunt;
				killer.SendGlobalMessage(None, 'AUTOTAUNT', NextTaunt, 5);
			}
		}
		CTFFlag(Other.PlayerReplicationInfo.HasFlag).Drop(0.5 * Other.Velocity);
	}

	BaseMutator.ScoreKill(Killer, Other);
}	

function bool SetEndCams(string Reason)
{
	local TeamInfo Best;
	local FlagBase BestBase;
	local CTFFlag BestFlag;
	local Pawn P;
	local int i;
	local PlayerPawn Player;

	for ( i=0; i<MaxTeams; i++ )
		if ( (Best == None) || (Best.Score < Teams[i].Score) )
			Best = Teams[i];

	for ( i=0; i<MaxTeams; i++ )
		if ( (Best.TeamIndex != i) && (Best.Score == Teams[i].Score) )
		{
			BroadcastLocalizedMessage(class'DeathMatchMessage', 0);
			return false;
		}		

	// find winner
	ForEach AllActors(class'CTFFlag', BestFlag)
		if ( BestFlag.Team == Best.TeamIndex )
			break;

	BestBase = BestFlag.HomeBase;
	GameReplicationInfo.GameEndedComments = TeamPrefix@Best.TeamName@GameEndedMessage;

	EndTime = Level.TimeSeconds + 3.0;
	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
	{
		P.GotoState('GameEnded');
		Player = PlayerPawn(P);
		if ( Player != None )
		{
			Player.bBehindView = true;
			Player.ViewTarget = BestBase;
			if (!bTutorialGame)
				PlayWinMessage(Player, (Player.PlayerReplicationInfo.Team == Best.TeamIndex));
			Player.ClientGameEnded();
		}
	}
	BestBase.bHidden = false;
	BestFlag.bHidden = true;
	CalcEndStats();
	return true;
}

function CalcEndStats()
{
	EndStatsClass.Default.TotalGames++;
	EndStatsClass.Static.StaticSaveConfig();
}

function ScoreFlag(Pawn Scorer, CTFFlag theFlag)
{
	local pawn TeamMate;
	local Actor A;

	if ( Scorer.PlayerReplicationInfo.Team == theFlag.Team )
	{
		if (Level.Game.WorldLog != None)
		{
			Level.Game.WorldLog.LogSpecialEvent("flag_returned", Scorer.PlayerReplicationInfo.PlayerID, Teams[theFlag.Team].TeamIndex);
		}
		if (Level.Game.LocalLog != None)
		{
			Level.Game.LocalLog.LogSpecialEvent("flag_returned", Scorer.PlayerReplicationInfo.PlayerID, Teams[theFlag.Team].TeamIndex);
		}
		BroadcastLocalizedMessage( class'CTFMessage', 1, Scorer.PlayerReplicationInfo, None, TheFlag );
		for ( TeamMate=Level.PawnList; TeamMate!=None; TeamMate=TeamMate.NextPawn )
		{
			if ( TeamMate.IsA('PlayerPawn') )
				PlayerPawn(TeamMate).ClientPlaySound(ReturnSound);
			else if ( TeamMate.IsA('Bot') )
				Bot(TeamMate).SetOrders(BotReplicationInfo(TeamMate.PlayerReplicationInfo).RealOrders, BotReplicationInfo(TeamMate.PlayerReplicationInfo).RealOrderGiver, true);
		}
		return;
	}

	if ( bRatedGame && Scorer.IsA('PlayerPawn') )
		bFulfilledSpecial = true;
	Scorer.PlayerReplicationInfo.Score += 7;
	Teams[Scorer.PlayerReplicationInfo.Team].Score += 1.0;

	for ( TeamMate=Level.PawnList; TeamMate!=None; TeamMate=TeamMate.NextPawn )
	{
		if ( TeamMate.IsA('PlayerPawn') )
			PlayerPawn(TeamMate).ClientPlaySound(CaptureSound[Scorer.PlayerReplicationInfo.Team]);
		else if ( TeamMate.IsA('Bot') )
			Bot(TeamMate).SetOrders(BotReplicationInfo(TeamMate.PlayerReplicationInfo).RealOrders, BotReplicationInfo(TeamMate.PlayerReplicationInfo).RealOrderGiver, true);
	}

	if (Level.Game.WorldLog != None)
	{
		Level.Game.WorldLog.LogSpecialEvent("flag_captured", Scorer.PlayerReplicationInfo.PlayerID, Teams[theFlag.Team].TeamIndex);
	}
	if (Level.Game.LocalLog != None)
	{
		Level.Game.LocalLog.LogSpecialEvent("flag_captured", Scorer.PlayerReplicationInfo.PlayerID, Teams[theFlag.Team].TeamIndex);
	}
	EndStatsClass.Default.TotalFlags++;
	BroadcastLocalizedMessage( class'CTFMessage', 0, Scorer.PlayerReplicationInfo, None, TheFlag );
	if ( theFlag.HomeBase.Event != '' )
		foreach allactors(class'Actor', A, theFlag.HomeBase.Event )
			A.Trigger(theFlag.HomeBase,	Scorer);

	if ( (bOverTime || (GoalTeamScore != 0)) && (Teams[Scorer.PlayerReplicationInfo.Team].Score >= GoalTeamScore) )
		EndGame("teamscorelimit");
	else if ( bOverTime )
		EndGame("timelimit");
}
 
function Actor SetDefenseFor(Bot aBot)
{
	return CTFReplicationInfo(GameReplicationInfo).FlagList[aBot.PlayerReplicationInfo.Team].HomeBase;
}


function float GameThreatAdd(Bot aBot, Pawn Other)
{
	local CTFFlag aFlag;

	if ( Other.PlayerReplicationInfo.HasFlag != None )
		return 10;
	else
		return 0;
}

function bool FindPathToBase(Bot aBot, FlagBase aBase)
{
	if ( (aBot.AlternatePath != None) 
		&& (aBot.AlternatePath.team == aBase.team) )
	{
		if ( aBot.ActorReachable(aBot.AlternatePath) )
		{
			aBot.MoveTarget = aBot.AlternatePath;
			aBot.AlternatePath = None;
		}
		else
		{
			aBot.MoveTarget = aBot.FindPathToward(aBot.AlternatePath);
			if ( aBot.MoveTarget == None )
			{
				aBot.AlternatePath = None;
				aBot.MoveTarget = aBot.FindPathToward(aBase);
			}
		}
	}
	else						
		aBot.MoveTarget = aBot.FindPathToward(aBase);

	return (aBot.bNoClearSpecial || (aBot.MoveTarget != None));
}

function byte AssessBotAttitude(Bot aBot, Pawn Other)
{
	if ( aBot.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team )
		return 3; //teammate
	else if ( (Other.bIsPlayer && (Other.PlayerReplicationInfo.HasFlag != None)) 
				|| (aBot.PlayerReplicationInfo.HasFlag != None) )
		return 1;
	else 
		return Super.AssessBotAttitude(aBot, Other);
}

function bool FindSpecialAttractionFor(Bot aBot)
{
	local CTFFlag FriendlyFlag, EnemyFlag;
	local bool bSeeFlag, bReachHome, bOrdered;
	local float Dist;

	if ( aBot.LastAttractCheck == Level.TimeSeconds )
		return false;
	aBot.LastAttractCheck = Level.TimeSeconds;

	//log(aBot@"find special attraction in state"@aBot.GetStateName()@"at"@Level.TimeSeconds);	
	FriendlyFlag = CTFReplicationInfo(GameReplicationInfo).FlagList[aBot.PlayerReplicationInfo.Team];
	
	if ( aBot.PlayerReplicationInfo.Team == 0 )
		EnemyFlag = CTFReplicationInfo(GameReplicationInfo).FlagList[1];
	else
		EnemyFlag = CTFReplicationInfo(GameReplicationInfo).FlagList[0];
	
	bOrdered = aBot.bSniping || (aBot.Orders == 'Follow') || (aBot.Orders == 'Hold');

	if ( !FriendlyFlag.bHome  )
	{
		bSeeFlag = aBot.LineOfSightTo(FriendlyFlag.Position());
		FriendlyFlag.bKnownLocation = FriendlyFlag.bKnownLocation || bSeeFlag;

		if ( bSeeFlag && (FriendlyFlag.Holder == None) && aBot.ActorReachable(FriendlyFlag) )
		{
			if ( Level.TimeSeconds - LastGotFlag > 6 )
			{	
				LastGotFlag = Level.TimeSeconds;
				aBot.SendTeamMessage(None, 'OTHER', 8, 20);
			}
			aBot.MoveTarget = FriendlyFlag;
			SetAttractionStateFor(aBot);
			return true;
		}

		if ( EnemyFlag.Holder != aBot )
		{
			if ( bSeeFlag && (FriendlyFlag.Holder != None) )
			{	
				FriendlyFlag.bKnownLocation = true;
				if ( Level.TimeSeconds - LastSeeFlagCarrier > 6 )
				{
					LastSeeFlagCarrier = Level.TimeSeconds;
					aBot.SendTeamMessage(None, 'OTHER', 12, 10);
				}
				aBot.SetEnemy(FriendlyFlag.Holder);
				aBot.Orders = 'Freelance';
				aBot.MoveTarget = FriendlyFlag.Holder;
				if ( aBot.IsInState('Attacking') )
					return false;
				else
				{
					aBot.GotoState('Attacking');
					return true;
				}
			}
			else if ( aBot.Orders == 'Attack' )
			{
				// break off attack only if needed
				if ( bSeeFlag || (EnemyFlag.Holder != None) 
					|| (((FriendlyFlag.Position().Region.Zone != FriendlyFlag.Homebase.Region.Zone) || (VSize(FriendlyFlag.Homebase.Location - FriendlyFlag.Position().Location) > 1000)) 
						&& ((aBot.Region.Zone != EnemyFlag.Region.Zone)
							|| (VSize(aBot.Location - EnemyFlag.Location) > 1600) || (VSize(aBot.Location - FriendlyFlag.Position().Location) < 1200))) )
				{
					FriendlyFlag.bKnownLocation = true;
					aBot.MoveTarget = aBot.FindPathToward(FriendlyFlag.Position());
					aBot.AlternatePath = None;
					if ( aBot.MoveTarget != None )
					{
						SetAttractionStateFor(aBot);
						return true;
					}
				}
			}
			else if ( (!bOrdered || ABot.OrderObject.IsA('Bot')) 
				&& (FriendlyFlag.bKnownLocation || (FRand() < 0.1)) ) 
			{
				FriendlyFlag.bKnownLocation = true;
				aBot.MoveTarget = aBot.FindPathToward(FriendlyFlag.Position());
				if ( aBot.MoveTarget != None )
				{
					SetAttractionStateFor(aBot);
					return true;
				}
			}
		}
	}

	if ( EnemyFlag.Holder == aBot )
	{
		aBot.bCanTranslocate = false;
		bReachHome = aBot.ActorReachable(FriendlyFlag.HomeBase);
		if ( bReachHome && !FriendlyFlag.bHome )
		{
			aBot.SendTeamMessage(None, 'OTHER', 1, 25);
			aBot.Orders = 'Freelance';
			return false;
		}
		if ( bReachHome && (VSize(aBot.Location - FriendlyFlag.Location) < 30) )
			FriendlyFlag.Touch(aBot);
		if ( aBot.Enemy != None )
		{
			if ( aBot.Health < 60 )
				aBot.SendTeamMessage(None, 'OTHER', 13, 25);
			if ( !aBot.IsInState('FallBack') )
			{
				aBot.bNoClearSpecial = true;
				aBot.TweenToRunning(0.1);
				aBot.GotoState('Fallback', 'SpecialNavig');
			}
			if ( bReachHome )
				aBot.MoveTarget = FriendlyFlag.HomeBase;
			else
				return FindPathToBase(aBot, FriendlyFlag.HomeBase);
		}
		else
		{
			if ( !aBot.IsInState('Roaming') )
			{
				aBot.bNoClearSpecial = true;
				aBot.TweenToRunning(0.1);
				aBot.GotoState('Roaming', 'SpecialNavig');
			}
			if ( bReachHome )
				aBot.MoveTarget = FriendlyFlag.HomeBase;
			else
				return FindPathToBase(aBot, FriendlyFlag.HomeBase);
		}		
		return true;
	}

	if ( EnemyFlag.Holder == None )
	{
		if ( aBot.ActorReachable(EnemyFlag) )
		{
			aBot.MoveTarget = EnemyFlag;
			SetAttractionStateFor(aBot);
			return true;
		}
		else if ( (aBot.Orders == 'Attack')
				 || ((aBot.Orders == 'Follow') && aBot.OrderObject.IsA('Bot')
					&& ((Pawn(aBot.OrderObject).Health <= 0) 
						 || ((EnemyFlag.Region.Zone == aBot.Region.Zone) && (VSize(EnemyFlag.Location - aBot.Location) < 2000)))) )
		{
			if ( !aBot.bKamikaze
				&& ( (aBot.Weapon == None) || (aBot.Weapon.AIRating < 0.4)) )
			{
				aBot.bKamikaze = ( FRand() < 0.1 );
				return false;
			}

			if ( (aBot.Enemy != None) 
				&& (aBot.Enemy.IsA('PlayerPawn') || (aBot.Enemy.IsA('Bot') && (Bot(aBot.Enemy).Orders == 'Attack')))
				&& (((aBot.Enemy.Region.Zone == FriendlyFlag.HomeBase.Region.Zone) && (EnemyFlag.HomeBase.Region.Zone != FriendlyFlag.HomeBase.Region.Zone)) 
					|| (VSize(aBot.Enemy.Location - FriendlyFlag.HomeBase.Location) < 0.6 * VSize(aBot.Location - EnemyFlag.HomeBase.Location))) )
				{
					aBot.SendTeamMessage(None, 'OTHER', 14, 15); //"Incoming!"
					aBot.Orders = 'Freelance';
					return false;
				}

			if ( EnemyFlag.bHome )
				FindPathToBase(aBot, EnemyFlag.HomeBase);
			else
				aBot.MoveTarget = aBot.FindPathToward(EnemyFlag);
			if ( aBot.MoveTarget != None )
			{
				SetAttractionStateFor(aBot);
				return true;
			}
			else
			{
				if ( aBot.bVerbose )
					log(aBot$" no path to flag");
				return false;
			}
		}
		return false;
	}

	if ( (bOrdered && !aBot.OrderObject.IsA('Bot')) || (aBot.Weapon == None) || (aBot.Weapon.AIRating < 0.4) )
		return false;

	if ( (aBot.Enemy == None) && (aBot.Orders != 'Defend') )
	{
		Dist = VSize(aBot.Location - EnemyFlag.Holder.Location);
		if ( (Dist > 500) || (VSize(EnemyFlag.Holder.Velocity) > 230)
			|| !aBot.LineOfSightTo(EnemyFlag.Holder) )
		{
			aBot.MoveTarget = aBot.FindPathToward(EnemyFlag.Holder);
			if ( !aBot.IsInState('Roaming') )
			{
				aBot.bNoClearSpecial = true;
				aBot.TweenToRunning(0.1);
				aBot.GotoState('Roaming', 'SpecialNavig');
				return true;
			}
			return (aBot.MoveTarget != None);
		}
		else
		{
			if ( !aBot.bInitLifeMessage )
			{
				aBot.bInitLifeMessage = true;
				aBot.SendTeamMessage(EnemyFlag.Holder.PlayerReplicationInfo, 'OTHER', 3, 10);
			}
			if ( FRand() < 0.35 )
				aBot.GotoState('Wandering');
			else
			{
				aBot.CampTime = 1.0;
				aBot.bCampOnlyOnce = true;
				aBot.GotoState('Roaming', 'Camp');
			}
			return true;
		}
	}
	return false;
}		

function bool RestartPlayer(Pawn aPlayer)
{
	local NavigationPoint N;
	local int num;
	local float totalWeight, selection, partialWeight;
	local bool bResult, bPowerPlay;
	local bot B;
	local Pawn P;
	
	bResult = Super.RestartPlayer(aPlayer);

	B = Bot(aPlayer);
	if ( B == None )
		return bResult;

	B.AlternatePath = None;
	
	if ( B.bPowerPlay || (BotReplicationInfo(B.PlayerReplicationInfo).RealOrders == 'Defend') )
	{
		// if bot only team and already one defender, 50% chance of powerplay for this guy if defender
		if ( FRand() < 0.5 )
		{
			B.bPowerPlay = false;
			B.SetOrders('Defend', None, true);
		}
		else
		{
			// check for bot only team and already a valid defender
			for ( P=Level.PawnList; P!=None; P=P.NextPawn )
			{
				if ( P.bIsPlayer && (P.PlayerReplicationInfo.Team == B.PlayerReplicationInfo.Team) )
				{
					if ( P.IsA('PlayerPawn') )
					{
						bPowerPlay = false;
						break;
					}
					else if ( P.IsA('Bot') && (Bot(P).Orders == 'Defend') )
						bPowerPlay = true;
				}
			}
			if ( bPowerPlay )
			{
				B.bPowerPlay = true;
				B.SetOrders('Attack', None, true);
			}
		}
	}

	if ( BotReplicationInfo(B.PlayerReplicationInfo).RealOrders != 'Attack' )
		return bResult;

	if ( FRand() < 0.8 )
	{
		for ( N=Level.NavigationPointList; N!=None; N=N.nextNavigationPoint )
			if ( N.IsA('AlternatePath') && (AlternatePath(N).team != B.PlayerReplicationInfo.team)
				&& !AlternatePath(N).bReturnOnly )
				TotalWeight += AlternatePath(N).SelectionWeight;
		selection = FRand() * TotalWeight;
		for ( N=Level.NavigationPointList; N!=None; N=N.nextNavigationPoint )
			if ( N.IsA('AlternatePath') && (AlternatePath(N).team != B.PlayerReplicationInfo.team) )
			{
				B.AlternatePath = AlternatePath(N);
				PartialWeight += AlternatePath(N).SelectionWeight;
				if ( PartialWeight > selection )
					break;
			}
	}
	return bResult;
}

function SetBotOrders(Bot NewBot)
{
	local Pawn P, L, M;
	local int num;
	local bool bAvailable;

	if ( CurrentOrders[NewBot.PlayerReplicationInfo.Team] == 'Freelance' )
		CurrentOrders[NewBot.PlayerReplicationInfo.Team] = 'Attack';
	else if ( CurrentOrders[NewBot.PlayerReplicationInfo.Team] == 'Defend' )
		CurrentOrders[NewBot.PlayerReplicationInfo.Team] = 'Freelance';
	else 
	{
		CurrentOrders[NewBot.PlayerReplicationInfo.Team] = 'Defend';		
		if ( bNoviceMode )
			for ( P=Level.PawnList; P!=None; P= P.NextPawn )
				if ( P.bIsPlayer && (P != NewBot) && (P.PlayerReplicationInfo.Team == NewBot.PlayerReplicationInfo.Team)
					&& P.IsA('Bot') && (BotReplicationInfo(P.PlayerReplicationInfo).RealOrders == 'Defend') && (FRand() < 0.5) )
					{	
						CurrentOrders[NewBot.PlayerReplicationInfo.Team] = 'Attack';
						break;
					}
	}		

	if ( ((CurrentOrders[NewBot.PlayerReplicationInfo.Team] == 'Attack') || (CurrentOrders[NewBot.PlayerReplicationInfo.Team] == 'Freelance'))	
		&& (NumSupportingPlayer == 0) )
	{
		For ( P=Level.PawnList; P!=None; P=P.NextPawn )
			if ( P.IsA('PlayerPawn') && (P.PlayerReplicationInfo.Team == NewBot.PlayerReplicationInfo.Team)
				&& !P.IsA('Spectator') )
		{
			num++;
			if ( (L == None) || (FRand() < 1.0/float(num)) )
				L = P;
		}

		if ( L != None )
		{
			NumSupportingPlayer++;
			NewBot.SetOrders('Follow',L, true);
			return;
		}
		else if ( FRand() < 0.8 )
		{
			// no players on this team - possibly support other bot
			num = 0;
			For ( P=Level.PawnList; P!=None; P=P.NextPawn )
				if ( P.IsA('Bot') && (P.PlayerReplicationInfo.Team == NewBot.PlayerReplicationInfo.Team) 
					&& (Bot(P).Orders == 'Attack') )
			{
				num++;
				if ( (L == None) || (FRand() < 1.0/float(num)) )
				{
					// make sure P doesn't already have a follower
					bAvailable = true;
					for ( M=Level.PawnList; M!=None; M=M.NextPawn )
						if ( M.IsA('Bot') && (M.PlayerReplicationInfo.Team == NewBot.PlayerReplicationInfo.Team) 
							&& (Bot(M).Orders == 'Follow') && (Bot(M).OrderObject == P) )
							bAvailable = false;
					if ( bAvailable )
						L = P;
				}
			}

			if ( L != None )
			{
				NewBot.SetOrders('Follow',L, true);
				return;
			}
		}
	}
	
	if ( CurrentOrders[NewBot.PlayerReplicationInfo.Team] == 'Freelance' )
		NewBot.SetOrders('Attack', None, true);
	else	
		NewBot.SetOrders(CurrentOrders[NewBot.PlayerReplicationInfo.Team], None, true);
}

// AllowTranslocation - return true if Other can teleport to Dest
function bool AllowTranslocation(Pawn Other, vector Dest )
{
	if ( Other.PlayerReplicationInfo.HasFlag != None )
		CTFFlag(Other.PlayerReplicationInfo.HasFlag).Drop(0.5 * Other.Velocity);

	return true;
}

// ShouldTranslocate - return true if abot should use translocation
function bool CanTranslocate(Bot aBot)
{
	if ( aBot.PlayerReplicationInfo.HasFlag != None )
		return false;

	return Super.CanTranslocate(aBot);
}

function int ReduceDamage(int Damage, name DamageType, pawn injured, pawn instigatedBy)
{
	if ( (instigatedBy != None) 
		&& (injured.PlayerReplicationInfo.Team != instigatedBy.PlayerReplicationInfo.Team)
		&& injured.IsA('Bot') 
		&& ((injured.health < 35) || (injured.PlayerReplicationInfo.HasFlag != None)) )
			Bot(injured).SendTeamMessage(None, 'OTHER', 4, 15);

	return Super.ReduceDamage(Damage, DamageType, injured, instigatedBy);
}

function byte PriorityObjective(Bot aBot)
{
	local CTFFlag FriendlyFlag;

	FriendlyFlag = CTFReplicationInfo(GameReplicationInfo).FlagList[aBot.PlayerReplicationInfo.Team]; 

	if ( aBot.PlayerReplicationInfo.HasFlag != None )
	{
		if ( (VSize(aBot.Location - FriendlyFlag.HomeBase.Location) < 2000)
			&& aBot.LineOfSightTo(FriendlyFlag.HomeBase) )
			return 255;
		return 2;
	}

	if ( FriendlyFlag.Holder != None )
		return 1;

	return 0;
}

function PickAmbushSpotFor(Bot aBot)
{
	if ( CheckForTranslocators(aBot) )
	{
		aBot.bSpecialAmbush = true;
		return;
	}
	Super.PickAmbushSpotFor(aBot);
}

function bool CheckForTranslocators(Bot aBot)
{
	local TranslocatorTarget T;

	// check for translocators near base
	ForEach AllActors(class'TranslocatorTarget', T)
		if ( CheckThisTranslocator(aBot, T) )
			return true;

	return false;
}

function bool CheckThisTranslocator(Bot aBot, TranslocatorTarget T)
{
	local FlagBase F;

	if ( aBot.Weapon.bMeleeWeapon )
		return false;
	F = CTFReplicationInfo(GameReplicationInfo).FlagList[aBot.PlayerReplicationInfo.Team].HomeBase;

	if ( (T.Region.Zone == F.Region.Zone)
		&& (T.Instigator.PlayerReplicationInfo.Team != aBot.PlayerReplicationInfo.Team)
		&& !T.Disrupted()
		&& (VSize(T.Location - F.Location) < 1000) )
	{
		if ( (VSize(aBot.Location - T.Location) < 850)
				&& aBot.LineOfSightTo(T) )
		{
			aBot.AmbushSpot = None;
			aBot.ShootTarget(T);
			return true;
		}
		else
		{
			aBot.MoveTarget = aBot.FindPathToward(T);
			if ( aBot.MoveTarget != None )
			{
				if ( VSize(aBot.Location - aBot.MoveTarget.Location) < 1.5 * aBot.CollisionRadius )
				{
					aBot.CampTime = 3.0;
					aBot.GotoState('Roaming', 'Camp');
				}
				aBot.AmbushSpot = None;
				return true;
			}
		}
	}
	return false;
}

defaultproperties
{
     CurrentOrders(0)=Freelance
     CurrentOrders(1)=Freelance
     CurrentOrders(2)=Freelance
     CurrentOrders(3)=Freelance
	 bCoopWeaponMode=true
	 ReturnSound=sound'ReturnSound'
	 CaptureSound(0)=sound'CaptureSound2'
	 CaptureSound(1)=sound'CaptureSound3'
	 CaptureSound(2)=sound'CaptureSound2'
	 CaptureSound(3)=sound'CaptureSound3'
     bNoMonsters=False
     bHumansOnly=True
     bUseTranslocator=True
	 bRatedTranslocator=True
     bSpawnInTeamArea=True
	 bNoMonsters=False
	 bScoreTeamKills=false
     MaxTeams=2
	 MaxAllowedTeams=2
	 InitialBots=0
	 BeaconName="CTF"
	 StartUpMessage=""
	 GameName="Capture the Flag"
     MapPrefix="CTF"
     BotConfigType=Class'BotPack.ChallengeBotInfo'
     MapListType=Class'BotPack.CTFmaplist'
	 HUDType=Class'BotPack.ChallengeCTFHUD'
     GameReplicationInfoClass=Class'BotPack.CTFReplicationInfo'
	 ScoreBoardType=Class'BotPack.UnrealCTFScoreboard'
	 LadderTypeIndex=2
	 gamegoal="captures wins the match!"
	 GoalTeamScore=3
}
