//=============================================================================
// Domination.
//=============================================================================
class Domination extends TeamGamePlus
	config;

var bool bNeutralPoints;
var config bool bDumbDown;			// reduce efficiency of bot team AI
var ControlPoint ControlPoints[16]; // control point list used for AI
									// (so game could have more than 16, but bots will only understand first 16
var int DomScoreEvent;				// used to track when to dump out periodic stat information

function PostBeginPlay()
{
	local NavigationPoint N;
	local int TempTotal;

	Super.PostBeginPlay();

	for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		if ( N.IsA('ControlPoint') )
		{
			ControlPoints[TempTotal] = ControlPoint(N);
			TempTotal++;
		}
}

function ScoreKill(pawn Killer, pawn Other)
{
	Super.ScoreKill(Killer, Other);

	if ( Other.bIsPlayer && (Killer != None) && Killer.bIsPlayer 
		&& (Killer != Other) && (Killer.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team)
		&& (FriendlyFireScale > 0) )
			Killer.PlayerReplicationInfo.Score -= 1;
}

function InitRatedGame(LadderInventory LadderObj, PlayerPawn LadderPlayer)
{
	bDumbDown = True;
	Super.InitRatedGame(LadderObj, LadderPlayer);
}

function bool SetEndCams(string Reason)
{
	local TeamInfo BestTeam;
	local ControlPoint Best;
	local Pawn P;
	local int i,j, nbest, n;
	local PlayerPawn player;

	// find winner
	BestTeam = Teams[0];
	for ( i=1; i<MaxTeams; i++ )
	{
		if ( int(Teams[i].Score) > int(BestTeam.Score) )
			BestTeam = Teams[i];
		else if ( int(Teams[i].Score) == int(BestTeam.Score) )
		{
			n = 0;
			nbest = 0;
			// check who has more points currently
			for ( j=0; j<16; j++ )
				if ( ControlPoints[j] != None )
				{
					if ( ControlPoints[j].ControllingTeam == BestTeam )
						nbest++;
					else if ( ControlPoints[j].ControllingTeam == Teams[i] )
						n++;
				}

			if ( n > nbest )
				BestTeam = Teams[i];
		}
	}

	GameReplicationInfo.GameEndedComments = TeamPrefix@BestTeam.TeamName@GameEndedMessage;

	ForEach AllActors(class'ControlPoint', Best)
		if ( Best.ControllingTeam == BestTeam )
			break;

	EndTime = Level.TimeSeconds + 3.0;
	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
	{
		player = PlayerPawn(P);
		P.GotoState('GameEnded');
		if ( Player != None )
		{
			player.bBehindView = true;
			player.ViewTarget = Best;
			if (!bTutorialGame)
				PlayWinMessage(Player, (Player.PlayerReplicationInfo.Team == BestTeam.TeamIndex));
			player.ClientGameEnded();
		}
	}
	CalcEndStats();
	return true;
}

function CalcEndStats()
{
	EndStatsClass.Default.TotalGames++;
	EndStatsClass.Static.StaticSaveConfig();
}

function Timer()
{
	local NavigationPoint N;
	local ControlPoint CP;
	local int i;
	local float c;
	local PlayerReplicationInfo PRI;

	if ( !bGameEnded )
	{
		c = 0.2;
		if ( TimeLimit > 0 )
		{
			if ( RemainingTime < 0.25 * TimeLimit )
			{
				if ( RemainingTime < 0.1 * TimeLimit )
					c = 0.8;
				else
					c = 0.4;
			}
		}

		if ( !bRequireReady || (CountDown <= 0) )
			for ( N=Level.NavigationPointList; N!=None; N=N.nextNavigationPoint )
			{
				CP = ControlPoint(N);
				if ( (CP != None) && (CP.ControllingTeam != None) && CP.bScoreReady )
				{
					CP.ControllingTeam.Score += c;
					CP.Controller.PlayerReplicationInfo.Score += c;
				}
			}
		DomScoreEvent++;
		if (DomScoreEvent >= 5)
		{
			DomScoreEvent = 0;
			for (i=0; i<4; i++)
			{
				if (Teams[i].Score > 0)
				{
					if (Level.Game.WorldLog != None)
						Level.Game.WorldLog.LogSpecialEvent("dom_score_update", i, Teams[i].Score);
					if (Level.Game.LocalLog != None)
						Level.Game.LocalLog.LogSpecialEvent("dom_score_update", i, Teams[i].Score);
				}
			}
			for (i=0; i<32; i++)
			{
				PRI = GameReplicationInfo.PRIArray[i];
				if (PRI != None)
				{
					if (Level.Game.WorldLog != None)
						Level.Game.WorldLog.LogSpecialEvent("dom_playerscore_update", PRI.PlayerID, int(PRI.Score));
					if (Level.Game.LocalLog != None)
						Level.Game.LocalLog.LogSpecialEvent("dom_playerscore_update", PRI.PlayerID, int(PRI.Score));				
				}
			}
		}
		if ( GoalTeamScore > 0 )
			for ( i=0; i<4; i++ )
				if ( Teams[i].Score >= GoalTeamScore )
					EndGame("teamscorelimit");
	}
	Super.Timer();
}

function bool CanTranslocate(Bot aBot)
{
	if ( aBot.bNovice && (aBot.Skill < 2) )
		return false;
	return Super.CanTranslocate(aBot);
} 

function ClearControl(Pawn Other)
{
	local NavigationPoint N;
	local Pawn P, Pick;
	local int Num;

	// find a teammate
	if ( !Other.bIsPlayer || (Other.PlayerReplicationInfo.Team == 255) )
		return;

	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if ( P.bIsPlayer && (P != Other) && (P.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team) )
		{
			Num++;
			if ( (Pick == None) || (Rand(Num) == 1) )
				Pick = P;
		}
	for ( N=Level.NavigationPointList; N!=None; N=N.nextNavigationPoint )
		if ( N.IsA('ControlPoint') && (ControlPoint(N).ControllingTeam != None) )
		{
			if ( ControlPoint(N).Controller == Other )
			{
				ControlPoint(N).Controller = Pick;
				ControlPoint(N).UpdateStatus();
			}
		}
}

function Logout( pawn Exiting )
{
	ClearControl(Exiting);
	Super.Logout(Exiting);
}

function bool RestartPlayer( pawn aPlayer )	
{
	local Bot B;

	B = Bot(aPlayer);
	if ( (B != None) && (B.Orders == 'Defend') )
		B.SetOrders('Freelance', None);

	return Super.RestartPlayer(aPlayer);
}

function Actor SetDefenseFor(Bot aBot)
{
	local Actor Result;
	local int i, j;
	local NavigationPoint N;

	if ( ControlPoint(aBot.OrderObject) != None )
		return aBot.OrderObject;

	while ( (i<16) && (ControlPoints[i] != None) )
	{
		if ( (ControlPoints[i].ControllingTeam != None)
			&& (ControlPoints[i].ControllingTeam.TeamIndex == aBot.PlayerReplicationInfo.Team) )
		{
			j++;
			if ( (Result == None) || ( FRand() < 1.0/float(j)) )
				Result = N;
		}	
		i++;
	}

	return Result;		
}

function bool FindSpecialAttractionFor(Bot aBot)
{
	local float bestweight, newweight;
	local ControlPoint Best, Near;
	local int i, count, maxdist, t;
	local bool bOrdered, bFound, bBehind;

	if ( aBot.LastAttractCheck == Level.TimeSeconds )
		return false;
	aBot.LastAttractCheck = Level.TimeSeconds;

	if ( aBot.Orders == 'Defend' )
	{
		if ( (aBot.OrderObject == None) || !aBot.OrderObject.IsA('ControlPoint') )
			aBot.Orders = 'FreeLance';
		else if ( (ControlPoint(aBot.OrderObject).ControllingTeam == None)
					|| (ControlPoint(aBot.OrderObject).ControllingTeam.TeamIndex != aBot.PlayerReplicationInfo.Team) )
		{
			if ( VSize(aBot.OrderObject.Location - aBot.Location) < 20 )
			{
				aBot.OrderObject.Touch(aBot);
				return false;
			}
			else if ( aBot.ActorReachable(aBot.OrderObject) )
			{
				bFound = true;
				aBot.MoveTarget = aBot.OrderObject;
			}
			else
			{
				aBot.MoveTarget = aBot.FindPathToward(aBot.OrderObject);
				bFound = ( aBot.MoveTarget != None );
			}
			if ( bFound )
			{
				if ( aBot.Enemy != None )
					aBot.bReadyToAttack = true;
				SetAttractionStateFor(aBot);
				return true;
			}
			return false;
		}
		else
			return false;					
	}
	// also "no movetarget"	in fallback		
	bOrdered = (aBot.Orders == 'Follow') || (aBot.Orders == 'Hold');
	if ( !bOrdered && bDumbdown && aBot.bDumbdown && !bNeutralPoints )
	{
		// dumbdown bot if its team isn't too far behind
		for ( i=0; i< MaxTeams; i++ )
			if ( Teams[i].score > Teams[aBot.PlayerReplicationInfo.Team].score + 20 )
				bBehind = true;
		bOrdered = !bBehind;
	}
				
	if ( bOrdered || (aBot.Enemy != None) || (aBot.Weapon == None) 
		|| (aBot.Weapon.AIRating < 0.5) || (aBot.Health < 70) )
	{
		if ( bOrdered )
			MaxDist = 1200;
		else
			MaxDist = 1700;
		// change nearby enemy or neutral controlpoint
		i = 0;
		bNeutralPoints = false;
		while ( (i<16) && (ControlPoints[i] != None) )
		{
			if ( ((ControlPoints[i].ControllingTeam == None) 
				|| (ControlPoints[i].ControllingTeam.TeamIndex != aBot.PlayerReplicationInfo.Team))
				&& (VSize(aBot.Location - ControlPoints[i].Location) < MaxDist)
				&& aBot.LineOfSightTo(ControlPoints[i]) )
			{
				if ( ControlPoints[i].ControllingTeam == None )
				{
					bNeutralPoints = true;
					if ( bOrdered && (aBot.Orders != 'Follow') && (aBot.Orders != 'Hold') )
					{
						aBot.bDumbDown = false; 
						bOrdered = false;
					}
				}
									
				if ( VSize(ControlPoints[i].Location - aBot.Location) < 20 )
				{
					ControlPoints[i].Touch(aBot);
					return false;
				}
				else if ( aBot.ActorReachable(ControlPoints[i]) )
				{
					bFound = true;
					aBot.MoveTarget = ControlPoints[i];
				}
				else if ( !bOrdered )
				{
					aBot.OrderObject = ControlPoints[i];
					BotReplicationInfo(aBot.PlayerReplicationInfo).OrderObject = None;
					aBot.MoveTarget = aBot.FindPathToward(ControlPoints[i]);
					bFound = ( aBot.MoveTarget != None );
				}
				if ( bFound )
				{
					if ( aBot.Enemy != None )
						aBot.bReadyToAttack = true;
					SetAttractionStateFor(aBot);
					return true;
				}
			}	
			i++;
		}
		if ( bOrdered || (aBot.Enemy == None) )
			return false;

		i = 0;
		while ( (i<16) && (ControlPoints[i] != None) )
		{
			if ( (ControlPoints[i].ControllingTeam == None) 
				|| (ControlPoints[i].ControllingTeam.TeamIndex != aBot.PlayerReplicationInfo.Team) )
				Count--;
			else
				Count++;
			i++;
		}
		if ( Count > 0 )
			return false; // already have an advantage in control points
	}

	//log("Find Special Attraction for"@aBot@"in state"@aBot.GetStateName());

	Best = ControlPoint(aBot.OrderObject);
	if ( (Best == None)
		|| ((Best.ControllingTeam != None)
			&& (Best.ControllingTeam.TeamIndex == aBot.PlayerReplicationInfo.Team)))
	{
		bestweight = 10000000;
		while ( (i<16) && (ControlPoints[i] != None) )
		{
			if ( ControlPoints[i].ControllingTeam == None )
				newweight = VSize(ControlPoints[i].location - aBot.location) * 0.1;
			else if ( (ControlPoints[i].ControllingTeam.TeamIndex != aBot.PlayerReplicationInfo.Team) )
			{
				newweight = VSize(ControlPoints[i].location - aBot.location) + 2 * Abs(ControlPoints[i].Location.Z - aBot.Location.Z);
				newweight *= (0.8 + 0.4 * FRand());
			}
			else 
				newweight = 90000000;

			if ( newweight < bestweight )
			{
				bestweight = newweight;
				Best = ControlPoints[i];
			}
			i++;
		}
	}

	if ( Best != None )
	{
		BotReplicationInfo(aBot.PlayerReplicationInfo).OrderObject = None;
		aBot.OrderObject = Best;
		if ( VSize(Best.Location - aBot.Location) < 20 )
		{
			aBot.OrderObject = None;
			Best.Touch(aBot);
			return false;
		}
		else if ( aBot.ActorReachable(Best) )
			aBot.MoveTarget = Best;
		else
			aBot.MoveTarget = aBot.FindPathToward(Best);

		if ( aBot.MoveTarget != None )
		{
			if ( aBot.bVerbose )
				log(aBot$" moving toward "$Best$" using "$aBot.MoveTarget);
			SetAttractionStateFor(aBot);
			return true;
		}
		else 
		{
			if ( FRand() < 0.3 )
				aBot.OrderObject = None;
			if ( aBot.bVerbose )
				log(aBot@"no path to"@Best.PointName);
		}
			
	}
	else if ( aBot.bVerbose )
		log(aBot@"found no best control point");
	return false;
}

function SetBotOrders(Bot NewBot)
{
	local Pawn P, L;
	local int num, total;
	local Bot B;

	// only follow players, if there are any
	if ( NumSupportingPlayer == 0 ) 
	{
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
			NumSupportingPlayer++;
			NewBot.SetOrders('Follow',L,true);
			return;
		}
	}
	num = 0;
	For ( P=Level.PawnList; P!=None; P= P.NextPawn )
		if ( P.bIsPlayer && (P.PlayerReplicationInfo.Team == NewBot.PlayerReplicationInfo.Team) )
		{
			total++;
			if ( (P != NewBot) && P.IsA('Bot') )	
			{
				B = Bot(P);
				if ( B.Orders == 'FreeLance' )
				{
					num++;
					if ( (L == None) || (FRand() < 1.0/float(num)) )
						L = P;
				}
				else if ( (B.Orders == 'Follow') && (B.OrderObject == L) )
					L = None;
			}
		}
				
	if ( (L != None) && (total > 3) && (FRand() < (float(num) - 2.0)/(float(total) - 2.5)) )
	{
		NewBot.SetOrders('Follow',L,true);
		return;
	}
	NewBot.SetOrders('Freelance', None,true);
}				 

function EndGame( string Reason )
{
	local int i;
	local PlayerReplicationInfo PRI;

	for (i=0; i<4; i++)
	{
		if (Teams[i].Score > 0)
		{
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogSpecialEvent("dom_score_update", i, Teams[i].Score);
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogSpecialEvent("dom_score_update", i, Teams[i].Score);
		}
	}
	for (i=0; i<32; i++)
	{
		PRI = GameReplicationInfo.PRIArray[i];
		if (PRI != None)
		{
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogSpecialEvent("dom_playerscore_update", PRI.PlayerID, int(PRI.Score));
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogSpecialEvent("dom_playerscore_update", PRI.PlayerID, int(PRI.Score));				
		}
	}

	Super.EndGame( Reason );
}

defaultproperties
{
	 bDumbDown=true
	 bCoopWeaponMode=true
	 bUseTranslocator=true
	 bRatedTranslocator=true
	 bScoreTeamKills=false
     bSpawnInTeamArea=false
     StartUpMessage="Capture and hold control points to win."
     MapListType=Class'BotPack.DOMMapList'
     MapPrefix="DOM"
     BeaconName="DOM"
     GameName="Domination"
	 ScoreBoardType=Class'DominationScoreboard'
	 HUDType=Class'BotPack.ChallengeDominationHUD'
	 LadderTypeIndex=3
	 gamegoal="points wins the match!"
	 GoalTeamScore=100
}
