class UTLadderAS extends UTLadder;

function Created()
{
	Super.Created();

	if (LadderObj.ASPosition == -1) {
		LadderObj.ASPosition = 1;
		SelectedMatch = 0;
	} else {
		SelectedMatch = LadderObj.ASPosition;
	}
	SetupLadder(LadderObj.ASPosition, LadderObj.ASRank);
}

function FillInfoArea(int i)
{
	MapInfoArea.Clear();
	MapInfoArea.AddText(MapText$" "$Ladder.Static.GetMapTitle(i));
	MapInfoArea.AddText(Ladder.Static.GetDesc(i));
}

function NextPressed()
{
	local ObjectiveBrowser OB;

	if (PendingPos > ArrowPos)
		return;

	HideWindow();
	OB = ObjectiveBrowser(Root.CreateWindow(class'ObjectiveBrowser', 100, 100, 200, 200, Root, True));
	OB.LadderWindow = Self;
	OB.Ladder = Ladder;
	OB.Match = SelectedMatch;
	OB.GameType = GameType;
	OB.Initialize();
}

function EvaluateMatch(optional bool bTrophyVictory)
{
	if (LadderObj.PendingPosition > LadderObj.ASPosition)
	{
		PendingPos = LadderObj.PendingPosition;
		LadderObj.ASPosition = LadderObj.PendingPosition;
	}
	if (LadderObj.PendingRank > LadderObj.ASRank)
	{
		LadderObj.ASRank = LadderObj.PendingRank;
		LadderObj.PendingRank = 0;
	}
	LadderPos = LadderObj.ASPosition;
	LadderRank = LadderObj.ASRank;
	if (LadderObj.ASRank == 6)
		Super.EvaluateMatch(True);
	else
		Super.EvaluateMatch();
}

defaultproperties
{
	GameType="Botpack.Assault"
	LadderName="Assault"
	Ladder=class'Botpack.LadderAS'
	TrophyMap="EOL_Assault.unr"
	LadderTrophy=TrophyAS
}
