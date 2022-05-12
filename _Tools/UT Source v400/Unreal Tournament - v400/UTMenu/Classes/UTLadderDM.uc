class UTLadderDM extends UTLadder;

function Created()
{
	Super.Created();

	if (LadderObj.DMPosition == -1) {
		LadderObj.DMPosition = 1;
		SelectedMatch = 0;
	} else {
		SelectedMatch = LadderObj.DMPosition;
	}
	SetupLadder(LadderObj.DMPosition, LadderObj.DMRank);

	if (class'UTLadderStub'.Static.IsDemo())
		RequiredRungs = 4;
}

function FillInfoArea(int i)
{
	MapInfoArea.Clear();
	if ( (LadderObj.CurrentLadder.Default.DemoDisplay[i] == 1) ||
		(class'UTLadderStub'.Static.IsDemo() && !class'UTLadderStub'.Static.DemoHasTuts() && i == 0) )
		MapInfoArea.AddText(NotAvailableString);
	MapInfoArea.AddText(MapText$" "$LadderObj.CurrentLadder.Static.GetMapTitle(i));
	MapInfoArea.AddText(FragText$" "$LadderObj.CurrentLadder.Static.GetFragLimit(i));
	MapInfoArea.AddText(LadderObj.CurrentLadder.Static.GetDesc(i));
}

function NextPressed()
{
	local EnemyBrowser EB;
	local string MapName;

	if (PendingPos > ArrowPos)
		return;

	if (SelectedMatch == 0)
	{
		MapName = LadderObj.CurrentLadder.Default.MapPrefix$Ladder.Static.GetMap(0);
		if (class'UTLadderStub'.Static.IsDemo())
		{
			if (class'UTLadderStub'.Static.DemoHasTuts())
			{
				CloseUp();
				StartMap(MapName, 0, "Botpack.TrainingDM");
			}
		} else {
			CloseUp();
			StartMap(MapName, 0, "Botpack.TrainingDM");
		}
	} else {
		HideWindow();
		EB = EnemyBrowser(Root.CreateWindow(class'EnemyBrowser', 100, 100, 200, 200, Root, True));
		EB.LadderWindow = Self;
		EB.Ladder = LadderObj.CurrentLadder;
		EB.Match = SelectedMatch;
		EB.GameType = GameType;
		EB.Initialize();
	}
}

function StartMap(string StartMap, int Rung, string GameType)
{
	local Class<GameInfo> GameClass;

	GameClass = Class<GameInfo>(DynamicLoadObject(GameType, Class'Class'));
	GameClass.Static.ResetGame();

	StartMap = StartMap
				$"?Game="$GameType
				$"?Mutator="
				$"?Tournament="$Rung
				$"?Name="$GetPlayerOwner().PlayerReplicationInfo.PlayerName
				$"?Team=255";

	Root.Console.CloseUWindow();
	GetPlayerOwner().ClientTravel(StartMap, TRAVEL_Absolute, True);
}

function EvaluateMatch(optional bool bTrophyVictory)
{
	local int Pos;
	local string MapName;

	if (LadderObj.PendingPosition > LadderObj.DMPosition)
	{
		if (class'UTLadderStub'.Static.IsDemo() && LadderObj.PendingPosition > 4)
		{
			PendingPos = 4;
		} else {
			PendingPos = LadderObj.PendingPosition;
			LadderObj.DMPosition = LadderObj.PendingPosition;
		}
	}
	if (LadderObj.PendingRank > LadderObj.DMRank)
	{
		LadderObj.DMRank = LadderObj.PendingRank;
		LadderObj.PendingRank = 0;
	}
	LadderPos = LadderObj.DMPosition;
	LadderRank = LadderObj.DMRank;
	if (LadderObj.DMRank == 6)
		Super.EvaluateMatch(True);
	else
		Super.EvaluateMatch();
}

function CheckOpenCondition()
{
	if (class'UTLadderStub'.Static.IsDemo())
	{
		if (LadderObj.DMRank == 4)
		{
			PendingPos = -1;
			BackPressed();
		}
	} else
		Super.CheckOpenCondition();
}

defaultproperties
{
	GameType="Botpack.DeathMatchPlus"
	LadderName="Deathmatch"
	Ladder=class'Botpack.LadderDM'
	DemoLadder=class'Botpack.LadderDMDemo'
	TrophyMap="EOL_DeathMatch.unr"
	LadderTrophy=TrophyDM
}