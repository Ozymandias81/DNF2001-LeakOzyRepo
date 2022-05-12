class UTLadderStub expands NotifyWindow
	abstract;

static function bool IsDemo()
{
	return (class'GameInfo'.Default.DemoBuild == 1);
}

static function bool DemoHasTuts()
{
	return (class'GameInfo'.Default.DemoHasTuts == 1);
}

static function SetupWinParams(UWindowWindow Win, UWindowRootWindow RootWin, out int W, out int H)
{
	if (RootWin.WinWidth > 1024)
	{
		Win.WinWidth = 1024;
		Win.WinHeight = 768;
		Win.WinLeft = (RootWin.WinWidth - 1024) / 2;
		Win.WinTop = (RootWin.WinHeight - 768) / 2;
	} else {
		Win.WinWidth = (RootWin.WinHeight / 3) * 4;
		Win.WinHeight = RootWin.WinHeight;
		Win.WinTop = 0;
		Win.WinLeft = (RootWin.WinWidth - Win.WinWidth) / 2;
	}

	W = Win.WinWidth / 4;
	H = W;

	if(W > 256 || H > 256)
	{
		W = 256;
		H = 256;
	}
}

static function font GetHugeFont(UWindowRootWindow Root)
{
	if (Root.WinWidth*Root.GUIScale < 512)
		return Font(DynamicLoadObject("LadderFonts.UTLadder12", class'Font'));
	else if (Root.WinWidth*Root.GUIScale < 640)
		return Font(DynamicLoadObject("LadderFonts.UTLadder16", class'Font'));
	else if (Root.WinWidth*Root.GUIScale < 800)
		return Font(DynamicLoadObject("LadderFonts.UTLadder20", class'Font'));
	else if (Root.WinWidth*Root.GUIScale < 1024)
		return Font(DynamicLoadObject("LadderFonts.UTLadder22", class'Font'));
	else
		return Font(DynamicLoadObject("LadderFonts.UTLadder30", class'Font'));
}

static function font GetBigFont(UWindowRootWindow Root)
{
	if (Root.WinWidth*Root.GUIScale < 640)
		return Font(DynamicLoadObject("LadderFonts.UTLadder10", class'Font'));
	else if (Root.WinWidth*Root.GUIScale < 800)
		return Font(DynamicLoadObject("LadderFonts.UTLadder12", class'Font'));
	else if (Root.WinWidth*Root.GUIScale < 1024)
		return Font(DynamicLoadObject("LadderFonts.UTLadder16", class'Font'));
	else
		return Font(DynamicLoadObject("LadderFonts.UTLadder18", class'Font'));
}

static function font GetSmallFont(UWindowRootWindow Root)
{
	if (Root.WinWidth*Root.GUIScale < 800)
		return Font(DynamicLoadObject("LadderFonts.UTLadder10", class'Font'));
	else if (Root.WinWidth*Root.GUIScale < 1024)
		return Font(DynamicLoadObject("LadderFonts.UTLadder14", class'Font'));
	else
		return Font(DynamicLoadObject("LadderFonts.UTLadder16", class'Font'));
}

static function font GetSmallestFont(UWindowRootWindow Root)
{
	if (Root.WinWidth*Root.GUIScale < 800)
		return Font(DynamicLoadObject("LadderFonts.UTLadder10", class'Font'));
	else if (Root.WinWidth*Root.GUIScale < 1024)
		return Font(DynamicLoadObject("LadderFonts.UTLadder12", class'Font'));
	else
		return Font(DynamicLoadObject("LadderFonts.UTLadder14", class'Font'));
}

static function font GetAReallySmallFont(UWindowRootWindow Root)
{
	if (Root.WinWidth*Root.GUIScale < 1024)
		return Font(DynamicLoadObject("LadderFonts.UTLadder8", class'Font'));
	else
		return Font(DynamicLoadObject("LadderFonts.UTLadder10", class'Font'));
}

static function font GetACompletelyUnreadableFont(UWindowRootWindow Root)
{
	if (Root.WinWidth*Root.GUIScale < 1024)
		return Font(DynamicLoadObject("LadderFonts.UTLadder8", class'Font'));
	else
		return Font(DynamicLoadObject("LadderFonts.UTLadder8", class'Font'));
}

function EvaluateMatch(optional bool bTrophyVictory);
