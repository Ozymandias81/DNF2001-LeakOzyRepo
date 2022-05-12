class UTLadderDOM extends UTLadder;

function Created()
{
	Super.Created();

	if (LadderObj.DOMPosition == -1) {
		LadderObj.DOMPosition = 1;
		SelectedMatch = 0;
	} else {
		SelectedMatch = LadderObj.DOMPosition;
	}
	SetupLadder(LadderObj.DOMPosition, LadderObj.DOMRank);

	if (class'UTLadderStub'.Static.IsDemo())
		RequiredRungs = 1;
}

function FillInfoArea(int i)
{
	MapInfoArea.Clear();
	if ( (LadderObj.CurrentLadder.Default.DemoDisplay[i] == 1) ||
		(class'UTLadderStub'.Static.IsDemo() && !class'UTLadderStub'.Static.DemoHasTuts() && i == 0) )
		MapInfoArea.AddText(NotAvailableString);
	MapInfoArea.AddText(MapText$" "$LadderObj.CurrentLadder.Static.GetMapTitle(i));
	MapInfoArea.AddText(TeamScoreText$" "$LadderObj.CurrentLadder.Static.GetGoalTeamScore(i));
	MapInfoArea.AddText(LadderObj.CurrentLadder.Static.GetDesc(i));
}

function NextPressed()
{
	local TeamBrowser TB;
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
				StartMap(MapName, 0, "Botpack.TrainingDOM");
			}
		} else {
			CloseUp();
			StartMap(MapName, 0, "Botpack.TrainingDOM");
		}
	} else {
		if (LadderObj.CurrentLadder.Default.DemoDisplay[SelectedMatch] == 1)
			return;

		HideWindow();
		TB = TeamBrowser(Root.CreateWindow(class'TeamBrowser', 100, 100, 200, 200, Root, True));
		TB.LadderWindow = Self;
		TB.Ladder = LadderObj.CurrentLadder;
		TB.Match = SelectedMatch;
		TB.GameType = GameType;
		TB.Initialize();
	}
}

function EvaluateMatch(optional bool bTrophyVictory)
{
	local int Pos;
	local string MapName;

	if (LadderObj.PendingPosition > LadderObj.DOMPosition)
	{
		if (class'UTLadderStub'.Static.IsDemo() && LadderObj.PendingPosition > 1)
		{
			PendingPos = 1;
		} else {
			PendingPos = LadderObj.PendingPosition;
			LadderObj.DOMPosition = LadderObj.PendingPosition;
		}
	}
	if (LadderObj.PendingRank > LadderObj.DOMRank)
	{
		LadderObj.DOMRank = LadderObj.PendingRank;
		LadderObj.PendingRank = 0;
	}
	LadderPos = LadderObj.DOMPosition;
	LadderRank = LadderObj.DOMRank;
	if (LadderObj.DOMRank == 6)
		Super.EvaluateMatch(True);
	else
		Super.EvaluateMatch();
}

function CheckOpenCondition()
{
	if (class'UTLadderStub'.Static.IsDemo())
	{
		if (LadderObj.DOMRank == 4)
		{
			PendingPos = -1;
			BackPressed();
		}
	} else
		Super.CheckOpenCondition();
}

defaultproperties
{
	GameType="Botpack.Domination"
	LadderName="Domination"
	Ladder=class'Botpack.LadderDOM'
	DemoLadder=class'Botpack.LadderDOMDemo'
	TrophyMap="EOL_Domination.unr"
	LadderTrophy=TrophyDOM
}
