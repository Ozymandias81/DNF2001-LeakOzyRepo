class UTLadderCTF extends UTLadder;

var localized string ShortTitle;

function Created()
{
	Super.Created();

	if (LadderObj.CTFRank == 6)
		Title1.Text = ShortTitle;

	if (LadderObj.CTFPosition == -1) {
		LadderObj.CTFPosition = 1;
		SelectedMatch = 0;
	} else {
		SelectedMatch = LadderObj.CTFPosition;
	}
	SetupLadder(LadderObj.CTFPosition, LadderObj.CTFRank);

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
				StartMap(MapName, 0, "Botpack.TrainingCTF");
			}
		} else {
			CloseUp();
			StartMap(MapName, 0, "Botpack.TrainingCTF");
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
	if (LadderObj.PendingPosition > LadderObj.CTFPosition)
	{
		if (class'UTLadderStub'.Static.IsDemo() && LadderObj.PendingPosition > 1)
		{
			PendingPos = 1;
		} else {
			PendingPos = LadderObj.PendingPosition;
			LadderObj.CTFPosition = LadderObj.PendingPosition;
		}
	}
	if (LadderObj.PendingRank > LadderObj.CTFRank)
	{
		LadderObj.CTFRank = LadderObj.PendingRank;
		LadderObj.PendingRank = 0;
	}
	LadderPos = LadderObj.CTFPosition;
	LadderRank = LadderObj.CTFRank;
	if (LadderObj.CTFRank == 6)
		Super.EvaluateMatch(True);
	else
		Super.EvaluateMatch();
}

function CheckOpenCondition()
{
	if (class'UTLadderStub'.Static.IsDemo())
	{
		if (LadderObj.CTFRank == 4)
		{
			PendingPos = -1;
			Close();
			Root.CreateWindow(class'DemoStoryWindow', 100, 100, 200, 200, Root, True);
		}
	} else
		Super.CheckOpenCondition();
}

defaultproperties
{
	GameType="Botpack.CTFGame"
	LadderName="Capture The Flag"
	ShortTitle="CTF"
	Ladder=class'Botpack.LadderCTF'
	DemoLadder=class'Botpack.LadderCTFDemo'
	TrophyMap="EOL_CTF.unr"
	LadderTrophy=TrophyCTF
}