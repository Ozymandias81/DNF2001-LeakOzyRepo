class UTAssaultRulesCW extends UTTeamRCWindow;

function Created()
{
	Super.Created();

	TeamScoreEdit.HideWindow();
	FragEdit.HideWindow();
	TimeEdit.HideWindow();

	WeaponsCheck.WinTop -= 25;
	FFSlider.WinTop -= 25;
	TourneyCheck.WinTop -= 25;

	if (MaxPlayersEdit != None)
		MaxPlayersEdit.WinTop -= 25;

	if (MaxSpectatorsEdit != None)
		MaxSpectatorsEdit.WinTop -= 25;

	if (BalancePlayersCheck != None)
		BalancePlayersCheck.WinTop -= 25;

	if (BalancePlayersCheck != None && ForceRespawnCheck != None)
	{
		ForceRespawnCheck.WinTop = BalancePlayersCheck.WinTop;
		FFSlider.WinTop -= 25;
	}
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	Super.BeforePaint(C, X, Y);

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	if(ForceRespawnCheck != None)
	{
		ForceRespawnCheck.SetSize(ControlWidth, 1);
		ForceRespawnCheck.WinLeft = ControlRight;
	}
}