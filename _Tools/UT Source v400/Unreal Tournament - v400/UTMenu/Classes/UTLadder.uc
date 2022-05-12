class UTLadder extends UTLadderStub
	abstract;

// Ladder
#exec TEXTURE IMPORT NAME=Ladr11 FILE=TEXTURES\Ladr\Ladr11.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=Ladr12 FILE=TEXTURES\Ladr\Ladr12.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=Ladr13 FILE=TEXTURES\Ladr\Ladr13.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=Ladr14 FILE=TEXTURES\Ladr\Ladr14.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=Ladr21 FILE=TEXTURES\Ladr\Ladr21.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=Ladr22 FILE=TEXTURES\Ladr\Ladr22.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=Ladr23 FILE=TEXTURES\Ladr\Ladr23.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=Ladr24 FILE=TEXTURES\Ladr\Ladr24.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=Ladr31 FILE=TEXTURES\Ladr\Ladr31.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=Ladr32 FILE=TEXTURES\Ladr\Ladr32.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=Ladr33 FILE=TEXTURES\Ladr\Ladr33.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=Ladr34 FILE=TEXTURES\Ladr\Ladr34.PCX GROUP=Skins MIPS=OFF

// Arrows
#exec TEXTURE IMPORT NAME=AroDdwn FILE=TEXTURES\Ladr\AroDdwn.PCX GROUP=Skins FLAGS=2  MIPS=OFF
#exec TEXTURE IMPORT NAME=AroDovr FILE=TEXTURES\Ladr\AroDovr.PCX GROUP=Skins FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=AroDup FILE=TEXTURES\Ladr\AroDup.PCX GROUP=Skins FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=AroUdwn FILE=TEXTURES\Ladr\AroUdwn.PCX GROUP=Skins FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=AroUovr FILE=TEXTURES\Ladr\AroUovr.PCX GROUP=Skins FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=AroUup FILE=TEXTURES\Ladr\AroUup.PCX GROUP=Skins FLAGS=2 MIPS=OFF
#exec OBJ LOAD FILE=..\Textures\LadrArrow.utx PACKAGE=LadrArrow

// Sounds
#exec OBJ LOAD FILE=..\Sounds\LadderSounds.uax PACKAGE=LadderSounds

// Trophy Icons
#exec TEXTURE IMPORT NAME=TrophyAS FILE=TEXTURES\Trophy\IconAssault.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=TrophyChal FILE=TEXTURES\Trophy\IconChallenge.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=TrophyCTF FILE=TEXTURES\Trophy\IconCTF.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=TrophyDM FILE=TEXTURES\Trophy\IconDeathMatch.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=TrophyDOM FILE=TEXTURES\Trophy\IconDomination.PCX GROUP=Skins MIPS=OFF

// Background
var texture BG1[4];
var texture BG2[4];
var texture BG3[4];
var string BGName1[4];
var string BGName2[4];
var string BGName3[4];

var texture ArrowTex;
var int PendingPos;
var float ArrowPos;

var texture StaticTex;

var string GameType;

var localized string MapText;
var localized string AuthorText;
var localized string FragText;
var localized string TeamScoreText;
var localized string TrophyMap;

// Player
var LadderInventory LadderObj;

// Title
var NotifyButton Title1;
var localized string LadderName;

// Navigation
var NotifyButton BackButton;
var NotifyButton NextButton;

// Matches
var MatchButton Matches[32];
var int BaseMatch, MaxBaseMatch;
var NotifyButton Scrollup;
var NotifyButton Scrolldown;
var int SelectedMatch;

// Map Screen Shot
var float StaticScale;
var texture MapShot;
var StaticArea MapStatic;
var bool bMapStatic;

// Map Info
var UTFadeTextArea MapInfoArea;
var NotifyButton InfoScrollup;
var NotifyButton InfoScrolldown;

// Ladder
var Class<Ladder> Ladder;
var Class<Ladder> DemoLadder;

var string NotAvailableString;

var bool bTrophyTravelPending;
var texture LadderTrophy;
var int LadderRank;
var int LadderPos;
var int RequiredRungs;

var bool bInitialized;

function Created()
{
	local int i, C;
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos, YOffset;
	local color TextColor;

	Super.Created();

	/*
	 * Setup window parameters.
	 */

	bLeaveOnScreen = True;
	bAlwaysOnTop = True;
	class'UTLadderStub'.Static.SetupWinParams(Self, Root, W, H);

	XMod = 4*W;
	YMod = 3*H;

	/*
	 * Load the background.
	 */

	BG1[0] = Texture(DynamicLoadObject(BGName1[0], Class'Texture'));
	BG1[1] = Texture(DynamicLoadObject(BGName1[1], Class'Texture'));
	BG1[2] = Texture(DynamicLoadObject(BGName1[2], Class'Texture'));
	BG1[3] = Texture(DynamicLoadObject(BGName1[3], Class'Texture'));
	BG2[0] = Texture(DynamicLoadObject(BGName2[0], Class'Texture'));
	BG2[1] = Texture(DynamicLoadObject(BGName2[1], Class'Texture'));
	BG2[2] = Texture(DynamicLoadObject(BGName2[2], Class'Texture'));
	BG2[3] = Texture(DynamicLoadObject(BGName2[3], Class'Texture'));
	BG3[0] = Texture(DynamicLoadObject(BGName3[0], Class'Texture'));
	BG3[1] = Texture(DynamicLoadObject(BGName3[1], Class'Texture'));
	BG3[2] = Texture(DynamicLoadObject(BGName3[2], Class'Texture'));
	BG3[3] = Texture(DynamicLoadObject(BGName3[3], Class'Texture'));

	/*
	 * Create components.
	 */

	// Check ladder object.
	LadderObj = LadderInventory(GetPlayerOwner().FindInventoryType(class'LadderInventory'));
	if (LadderObj == None)
	{
		Log("UTLadder: Player has no LadderInventory!!");
	}
	if (class'UTLadder'.Static.IsDemo())
		LadderObj.CurrentLadder = DemoLadder;
	else
		LadderObj.CurrentLadder = Ladder;

	// Title
	XPos = 74.0/1024 * XMod;
	YPos = 69.0/768 * YMod;
	XWidth = 352.0/1024 * XMod;
	YHeight = 41.0/768 * YMod;	
	Title1 = NotifyButton(CreateWindow(class'NotifyButton', XPos, YPos, XWidth, YHeight));
	Title1.Text = LadderName;
	Title1.NotifyWindow = Self;
	TextColor.R = 255;
	TextColor.G = 255;
	TextColor.B = 0;
	Title1.SetTextColor(TextColor);
	Title1.MyFont = class'UTLadderStub'.Static.GetHugeFont(Root);
	Title1.bStretched = True;

	// Matches
	TextColor.R = 0;
	TextColor.G = 128;
	TextColor.B = 255;
	XPos = 168.0/1024 * XMod;
	YPos = 599.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	YOffset = 48.0/768 * YMod;
	C = Ladder.Default.Matches;
	MaxBaseMatch = C - 8;
	Matches[C-1] = MatchButton(CreateWindow(class'MatchButton', XPos, YPos - i*YOffset, XWidth, YHeight));
	Matches[C-1].SetLadder(LadderObj.CurrentLadder);
	Matches[C-1].SetMatchIndex(C-1);
	Matches[C-1].MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	Matches[C-1].SetTextColor(TextColor);
	Matches[C-1].LadderWindow = Self;
	Matches[C-1].DisabledTexture = Texture(DynamicLoadObject("UTMenu.Plate3Cap", Class'Texture'));
	Matches[C-1].UpTexture = Texture(DynamicLoadObject("UTMenu.Plate3Cap", Class'Texture'));
	Matches[C-1].OverTexture = Texture(DynamicLoadObject("UTMenu.PlateCap", Class'Texture'));
	Matches[C-1].DownTexture = Texture(DynamicLoadObject("UTMenu.PlateCap", Class'Texture'));
	Matches[C-1].OtherTexture = Texture(DynamicLoadObject("UTMenu.PlateYellowCap", Class'Texture'));
	Matches[C-1].OldOverTexture = Matches[C-1].OverTexture;
	Matches[C-1].bStretched = True;
	Matches[C-1].LabelWidth = 178/1024 * XMod;
	Matches[C-1].LabelHeight = 49/768 * YMod;
	Matches[C-1].DownSound = sound'LadderSounds.lsChange1';
	Matches[C-1].OverSound = sound'LadderSounds.lcursorMove';
	for (i=C-2; i>0; i--)
	{
		Matches[i] = MatchButton(CreateWindow(class'MatchButton', XPos, YPos - i*YOffset, XWidth, YHeight));
		Matches[i].SetLadder(LadderObj.CurrentLadder);
		Matches[i].SetMatchIndex(i);
		Matches[i].MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
		Matches[i].SetTextColor(TextColor);
		Matches[i].LadderWindow = Self;
		Matches[i].DisabledTexture = Texture(DynamicLoadObject("UTMenu.Plate3", Class'Texture'));
		Matches[i].UpTexture = Texture(DynamicLoadObject("UTMenu.Plate3", Class'Texture'));
		Matches[i].OverTexture = Texture(DynamicLoadObject("UTMenu.Plate", Class'Texture'));
		Matches[i].DownTexture = Texture(DynamicLoadObject("UTMenu.Plate", Class'Texture'));
		Matches[i].OtherTexture = Texture(DynamicLoadObject("UTMenu.PlateYellow", Class'Texture'));
		Matches[i].OldOverTexture = Matches[i].OverTexture;
		Matches[i].bStretched = True;
		Matches[i].LabelWidth = 178/1024 * XMod;
		Matches[i].LabelHeight = 49/768 * YMod;
		Matches[i].DownSound = sound'LadderSounds.lsChange1';
		Matches[i].OverSound = sound'LadderSounds.lcursorMove';
	}
	Matches[0] = MatchButton(CreateWindow(class'MatchButton', XPos, YPos - i*YOffset, XWidth, YHeight));
	Matches[0].SetLadder(LadderObj.CurrentLadder);
	Matches[0].SetMatchIndex(0);
	Matches[0].MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	Matches[0].SetTextColor(TextColor);
	Matches[0].LadderWindow = Self;
	Matches[0].DisabledTexture = Texture(DynamicLoadObject("UTMenu.Plate3LowCap", Class'Texture'));
	Matches[0].UpTexture = Texture(DynamicLoadObject("UTMenu.Plate3LowCap", Class'Texture'));
	Matches[0].OverTexture = Texture(DynamicLoadObject("UTMenu.PlateLowCap", Class'Texture'));
	Matches[0].DownTexture = Texture(DynamicLoadObject("UTMenu.PlateLowCap", Class'Texture'));
	Matches[0].OtherTexture = Texture(DynamicLoadObject("UTMenu.PlateYellowLowCap", Class'Texture'));
	Matches[0].OldOverTexture = Matches[0].OverTexture;
	Matches[0].bStretched = True;
	Matches[0].LabelWidth = 178/1024 * XMod;
	Matches[0].LabelHeight = 49/768 * YMod;
	Matches[0].DownSound = sound'LadderSounds.lsChange1';
	Matches[0].OverSound = sound'LadderSounds.lcursorMove';

	// Scrollup
	XPos = 357.0/1024 * XMod;
	YPos = 259.0/768 * YMod;
	XWidth = 32.0/1024 * XMod;
	YHeight = 16.0/768 * YMod;
	Scrollup = NotifyButton(CreateWindow(class'NotifyButton', XPos, YPos, XWidth, YHeight));
	Scrollup.NotifyWindow = Self;
	Scrollup.Text = "";
	Scrollup.bStretched = True;
	Scrollup.UpTexture = Texture(DynamicLoadObject("UTMenu.AroUup", Class'Texture'));
	Scrollup.OverTexture = Texture(DynamicLoadObject("UTMenu.AroUovr", Class'Texture'));
	Scrollup.DownTexture = Texture(DynamicLoadObject("UTMenu.AroUdwn", Class'Texture'));
	Scrollup.MyFont = class'UTLadderStub'.Static.GetSmallFont(Root);
	Scrollup.bAlwaysOnTop = True;
	Scrollup.bIgnoreLDoubleClick = True;

	// Scrolldown
	XPos = 357.0/1024 * XMod;
	YPos = 630.0/768 * YMod;
	XWidth = 32.0/1024 * XMod;
	YHeight = 16.0/768 * YMod;
	Scrolldown = NotifyButton(CreateWindow(class'NotifyButton', XPos, YPos, XWidth, YHeight));
	Scrolldown.NotifyWindow = Self;
	Scrolldown.Text = "";
	Scrolldown.bStretched = True;
	Scrolldown.UpTexture = Texture(DynamicLoadObject("UTMenu.AroDup", Class'Texture'));
	Scrolldown.OverTexture = Texture(DynamicLoadObject("UTMenu.AroDovr", Class'Texture'));
	Scrolldown.DownTexture = Texture(DynamicLoadObject("UTMenu.AroDdwn", Class'Texture'));
	Scrolldown.MyFont = class'UTLadderStub'.Static.GetSmallFont(Root);
	Scrolldown.bAlwaysOnTop = True;
	Scrolldown.bIgnoreLDoubleClick = True;

	// Map Info
	XPos = 529.0/1024 * XMod;
	YPos = 586.0/768 * YMod;
	XWidth = 385.0/1024 * XMod;
	YHeight = 113.0/768 * YMod;
	MapInfoArea = UTFadeTextArea(CreateWindow(Class<UWindowWindow>(DynamicLoadObject("UTMenu.UTFadeTextArea", Class'Class')), XPos, YPos, XWidth, YHeight));
	MapInfoArea.TextColor.R = 255;
	MapInfoArea.TextColor.G = 255;
	MapInfoArea.TextColor.B = 0;
	MapInfoArea.MyFont = class'UTLadderStub'.Static.GetSmallestFont(Root);
	MapInfoArea.bAutoScrolling = True;

	// InfoScrollup
	XPos = 923.0/1024 * XMod;
	YPos = 590.0/768 * YMod;
	XWidth = 32.0/1024 * XMod;
	YHeight = 16.0/768 * YMod;
	InfoScrollup = NotifyButton(CreateWindow(class'NotifyButton', XPos, YPos, XWidth, YHeight));
	InfoScrollup.NotifyWindow = Self;
	InfoScrollup.Text = "";
	InfoScrollup.bStretched = True;
	InfoScrollup.UpTexture = Texture(DynamicLoadObject("UTMenu.AroUup", Class'Texture'));
	InfoScrollup.OverTexture = Texture(DynamicLoadObject("UTMenu.AroUovr", Class'Texture'));
	InfoScrollup.DownTexture = Texture(DynamicLoadObject("UTMenu.AroUdwn", Class'Texture'));
	InfoScrollup.MyFont = class'UTLadderStub'.Static.GetSmallFont(Root);
	InfoScrollup.bAlwaysOnTop = True;
	InfoScrollUp.bIgnoreLDoubleClick = True;

	// InfoScrolldown
	XPos = 923.0/1024 * XMod;
	YPos = 683.0/768 * YMod;
	XWidth = 32.0/1024 * XMod;
	YHeight = 16.0/768 * YMod;
	InfoScrolldown = NotifyButton(CreateWindow(class'NotifyButton', XPos, YPos, XWidth, YHeight));
	InfoScrolldown.NotifyWindow = Self;
	InfoScrolldown.Text = "";
	InfoScrolldown.bStretched = True;
	InfoScrolldown.UpTexture = Texture(DynamicLoadObject("UTMenu.AroDup", Class'Texture'));
	InfoScrolldown.OverTexture = Texture(DynamicLoadObject("UTMenu.AroDovr", Class'Texture'));
	InfoScrolldown.DownTexture = Texture(DynamicLoadObject("UTMenu.AroDdwn", Class'Texture'));
	InfoScrolldown.MyFont = class'UTLadderStub'.Static.GetSmallFont(Root);
	InfoScrolldown.bAlwaysOnTop = True;
	InfoScrolldown.bIgnoreLDoubleClick = True;

	// Back Button
	XPos = 192.0/1024 * XMod;
	YPos = 701.0/768 * YMod;
	XWidth = 64.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	BackButton = NotifyButton(CreateWindow(class'NotifyButton', XPos, YPos, XWidth, YHeight));
	BackButton.DisabledTexture = Texture(DynamicLoadObject("UTMenu.LeftUp", Class'Texture'));
	BackButton.UpTexture = Texture(DynamicLoadObject("UTMenu.LeftUp", Class'Texture'));
	BackButton.DownTexture = Texture(DynamicLoadObject("UTMenu.LeftDown", Class'Texture'));
	BackButton.OverTexture = Texture(DynamicLoadObject("UTMenu.LeftOver", Class'Texture'));
	BackButton.NotifyWindow = Self;
	BackButton.Text = "";
	TextColor.R = 255;
	TextColor.G = 255;
	TextColor.B = 0;
	BackButton.SetTextColor(TextColor);
	BackButton.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	BackButton.bStretched = True;
	BackButton.OverSound = sound'LadderSounds.lcursorMove';
	BackButton.DownSound = sound'LadderSounds.ladvance';

	// Next Button
	XPos = 256.0/1024 * XMod;
	YPos = 701.0/768 * YMod;
	XWidth = 64.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	NextButton = NotifyButton(CreateWindow(class'NotifyButton', XPos, YPos, XWidth, YHeight));
	NextButton.DisabledTexture = Texture(DynamicLoadObject("UTMenu.RightUp", Class'Texture'));
	NextButton.UpTexture = Texture(DynamicLoadObject("UTMenu.RightUp", Class'Texture'));
	NextButton.DownTexture = Texture(DynamicLoadObject("UTMenu.RightDown", Class'Texture'));
	NextButton.OverTexture = Texture(DynamicLoadObject("UTMenu.RightOver", Class'Texture'));
	NextButton.NotifyWindow = Self;
	NextButton.Text = "";
	TextColor.R = 255;
	TextColor.G = 255;
	TextColor.B = 0;
	NextButton.SetTextColor(TextColor);
	NextButton.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	NextButton.bStretched = True;
	NextButton.OverSound = sound'LadderSounds.lcursorMove';
	NextButton.DownSound = sound'LadderSounds.ladvance';

	// StaticArea
	XPos = 608.0/1024 * XMod;
	YPos = 90.0/768 * YMod;
	XWidth = 320.0/1024 * XMod;
	YHeight = 319.0/768 * YMod;
	MapStatic = StaticArea(CreateWindow(class'StaticArea', XPos, YPos, XWidth, YHeight));
	MapStatic.VStaticScale = 300.0;

	PendingPos = -1;

	Root.Console.bBlackout = True;

	StaticScale = 1.0;

	bInitialized = True;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int i;
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos, YOffset;

	Super.BeforePaint(C, X, Y);

	class'UTLadderStub'.Static.SetupWinParams(Self, Root, W, H);

	XMod = 4*W;
	YMod = 3*H;

	// Title
	XPos = 74.0/1024 * XMod;
	YPos = 69.0/768 * YMod;
	XWidth = 352.0/1024 * XMod;
	YHeight = 41.0/768 * YMod;	
	Title1.WinLeft = XPos;
	Title1.WinTop = YPos;
	Title1.SetSize(XWidth, YHeight);
	Title1.MyFont = class'UTLadderStub'.Static.GetHugeFont(Root);

	// Matches
	XPos = 168.0/1024 * XMod;
	YPos = 599.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	YOffset = 48.0/768 * YMod;
	if (BaseMatch > 0)
	{
		for (i=0; i<BaseMatch; i++)
			Matches[i].WinLeft = -2 * XMod;
	}
	for (i=BaseMatch+7; i<LadderObj.CurrentLadder.Default.Matches; i++)
		if (Matches[i] != None)
			Matches[i].WinLeft = -2 * XMod;	

	for (i=BaseMatch+7; i>BaseMatch-1; i--)
	{
		if (Matches[i] != None) {
			Matches[i].WinLeft = XPos;
			Matches[i].WinTop = YPos - ((i-BaseMatch) * YOffset);
			Matches[i].SetSize(XWidth, YHeight);
		}
	}

	// Scrollup
	XPos = 354.0/1024 * XMod;
	YPos = 258.0/768 * YMod;
	XWidth = 32.0/1024 * XMod;
	YHeight = 16.0/768 * YMod;
	Scrollup.WinLeft = XPos;
	Scrollup.WinTop = YPos;
	Scrollup.SetSize(XWidth, YHeight);

	// Scrolldown
	XPos = 354.0/1024 * XMod;
	YPos = 632.0/768 * YMod;
	XWidth = 32.0/1024 * XMod;
	YHeight = 16.0/768 * YMod;
	Scrolldown.WinLeft = XPos;
	Scrolldown.WinTop = YPos;
	Scrolldown.SetSize(XWidth, YHeight);

	// Map Info
	XPos = 529.0/1024 * XMod;
	YPos = 590.0/768 * YMod;
	XWidth = 385.0/1024 * XMod;
	YHeight = 105.0/768 * YMod;
	MapInfoArea.WinLeft = XPos;
	MapInfoArea.WinTop = YPos;
	MapInfoArea.SetSize(XWidth, YHeight);
	MapInfoArea.MyFont = class'UTLadderStub'.Static.GetSmallestFont(Root);

	// InfoScrollup
	XPos = 923.0/1024 * XMod;
	YPos = 590.0/768 * YMod;
	XWidth = 32.0/1024 * XMod;
	YHeight = 16.0/768 * YMod;
	InfoScrollup.WinLeft = XPos;
	InfoScrollup.WinTop = YPos;
	InfoScrollup.SetSize(XWidth, YHeight);

	// InfoScrolldown
	XPos = 923.0/1024 * XMod;
	YPos = 683.0/768 * YMod;
	XWidth = 32.0/1024 * XMod;
	YHeight = 16.0/768 * YMod;
	InfoScrolldown.WinLeft = XPos;
	InfoScrolldown.WinTop = YPos;
	InfoScrolldown.SetSize(XWidth, YHeight);

	// Back Button
	XPos = 192.0/1024 * XMod;
	YPos = 701.0/768 * YMod;
	XWidth = 64.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	BackButton.WinLeft = XPos;
	BackButton.WinTop = YPos;
	BackButton.SetSize(XWidth, YHeight);

	// Next Button
	XPos = 256.0/1024 * XMod;
	YPos = 701.0/768 * YMod;
	XWidth = 64.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	NextButton.WinLeft = XPos;
	NextButton.WinTop = YPos;
	NextButton.SetSize(XWidth, YHeight);

	// StaticArea
	XPos = 608.0/1024 * XMod;
	YPos = 90.0/768 * YMod;
	XWidth = 320.0/1024 * XMod;
	YHeight = 319.0/768 * YMod;
	MapStatic.WinLeft = XPos;
	MapStatic.WinTop = YPos;
	MapStatic.SetSize(XWidth, YHeight);

	if (LadderObj != None)
	{
		for (i=0; i<LadderPos+1; i++)
		{
			Matches[i].MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
			Matches[i].LabelWidth = 178/1024 * XMod;
			Matches[i].LabelHeight = 49/768 * YMod;
			Matches[i].SetMatchIndex(i);
			Matches[i].bDisabled = False;
			Matches[i].bUnknown = False;
			if (SelectedMatch == i)
			{
				Matches[i].UpTexture = Matches[i].OtherTexture;
				Matches[i].OverTexture = Matches[i].OtherTexture;
			} else {
				Matches[i].UpTexture = Matches[i].DisabledTexture;
				Matches[i].OverTexture = Matches[i].OldOverTexture;
			}
		}
		for (i=LadderPos+1; i<LadderObj.CurrentLadder.Default.Matches; i++)
		{
			if (LadderObj.CurrentLadder.Default.DemoDisplay[LadderPos] != 1)
			{
				Matches[i].LabelWidth = 178/1024 * XMod;
				Matches[i].LabelHeight = 49/768 * YMod;
				Matches[i].MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
				Matches[i].bDisabled = True;
				Matches[i].bUnknown = True;
				Matches[i].UpTexture = Matches[i].DisabledTexture;
			} else if (LadderObj.CurrentLadder.Default.DemoDisplay[i] == 0) {
				Matches[i].LabelWidth = 178/1024 * XMod;
				Matches[i].LabelHeight = 49/768 * YMod;
				Matches[i].MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
				Matches[i].bDisabled = True;
				Matches[i].bUnknown = True;
				Matches[i].UpTexture = Matches[i].DisabledTexture;
			}
		}
	}
}

function Paint(Canvas C, float X, float Y)
{
	local int XOffset, YOffset;
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos, DrawPos;
	local bool bOldSmooth;

	class'UTLadderStub'.Static.SetupWinParams(Self, Root, W, H);

	XMod = 4*W;
	YMod = 3*H;

	// Background
	DrawStretchedTexture(C, XOffset + (0 * W), YOffset + (0 * H), W+1, H+1, BG1[0]);
	DrawStretchedTexture(C, XOffset + (1 * W), YOffset + (0 * H), W+1, H+1, BG1[1]);
	DrawStretchedTexture(C, XOffset + (2 * W), YOffset + (0 * H), W+1, H+1, BG1[2]);
	DrawStretchedTexture(C, XOffset + (3 * W), YOffset + (0 * H), W+1, H+1, BG1[3]);

	DrawStretchedTexture(C, XOffset + (0 * W), YOffset + (1 * H), W+1, H+1, BG2[0]);
	DrawStretchedTexture(C, XOffset + (1 * W), YOffset + (1 * H), W+1, H+1, BG2[1]);
	DrawStretchedTexture(C, XOffset + (2 * W), YOffset + (1 * H), W+1, H+1, BG2[2]);
	DrawStretchedTexture(C, XOffset + (3 * W), YOffset + (1 * H), W+1, H+1, BG2[3]);
		
	DrawStretchedTexture(C, XOffset + (0 * W), YOffset + (2 * H), W+1, H+1, BG3[0]);
	DrawStretchedTexture(C, XOffset + (1 * W), YOffset + (2 * H), W+1, H+1, BG3[1]);
	DrawStretchedTexture(C, XOffset + (2 * W), YOffset + (2 * H), W+1, H+1, BG3[2]);
	DrawStretchedTexture(C, XOffset + (3 * W), YOffset + (2 * H), W+1, H+1, BG3[3]);

	// MapShot
	bOldSmooth = C.bNoSmooth;
	C.bNoSmooth = False;
	XPos = 608.0/1024 * XMod;
	YPos = 90.0/768 * YMod;
	XWidth = 320.0/1024 * XMod;
	YHeight = 319.0/768 * YMod;
	if(MapShot != None)
 		DrawStretchedTexture(C, XPos, YPos, XWidth, YHeight, MapShot);
	C.bNoSmooth = bOldSmooth;

	// Static
	XPos = 608.0/1024 * XMod;
	YPos = 90.0/768 * YMod;
	XWidth = 320.0/1024 * XMod;
	YHeight = 319.0/768 * YMod;
	C.DrawColor.R = 255 * StaticScale;
	C.DrawColor.G = 255 * StaticScale;
	C.DrawColor.B = 255 * StaticScale;
	C.Style = GetPlayerOwner().ERenderStyle.STY_Translucent;
 	DrawStretchedTexture(C, XPos, YPos, XWidth, YHeight, StaticTex);
	C.Style = GetPlayerOwner().ERenderStyle.STY_Normal;
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	// Status Arrow
	DrawPos = ArrowPos - BaseMatch;
	XPos = 126.0/1024 * XMod;
	YPos = (607.0 - DrawPos*49)/768 * YMod;
	XWidth = 32.0/1024 * XMod;
	YHeight = 32.0/768 * YMod;
	if ((DrawPos > -1) && (DrawPos < 8))
 		DrawStretchedTexture(C, XPos, YPos, XWidth, YHeight, ArrowTex);

	// Trophy Icon
	if (LadderRank == 6)
	{
		DrawStretchedTexture(C, XOffset + (0 * W), YOffset + (0 * H), (W+1)/2, (H+1)/2, texture'TeamPlate');
		DrawStretchedTexture(C, XOffset + (0 * W) + (65.0/1024*XMod), YOffset + (0 * H) + (61.0/768*YMod), (58.0/1024*XMod), (57.0/768*YMod), LadderTrophy);
	}

	Super.Paint(C, X, Y);
}

function SetupLadder(int Pos, int Rank)
{
	LadderPos = Pos;
	LadderRank = Rank;

	ArrowPos = LadderPos;
	if (SelectedMatch > 7)
		BaseMatch = SelectedMatch - 7;
	FillInfoArea(SelectedMatch);
	SetMapShot(SelectedMatch);
}

function FillInfoArea(int i)
{
}

function Notify(UWindowWindow B, byte E)
{
	local int i;

	if (!bInitialized)
		return;

	switch (E)
	{
		case DE_DoubleClick:
			for (i=0; i<LadderObj.CurrentLadder.Default.Matches; i++)
			{
				if (B == Matches[i])
					NextPressed();
			}
			break;
		case DE_Click:
			switch (B)
			{
				case Scrollup:
					if (Ladder.Default.Matches > 8)
					{
						BaseMatch++;
						if (BaseMatch > MaxBaseMatch)
							BaseMatch = MaxBaseMatch;
					}
					break;
				case Scrolldown:
					BaseMatch--;
					if (BaseMatch < 0)
						BaseMatch = 0;
					break;
				case InfoScrollup:
					MapInfoArea.ScrollingOffset--;
					if (MapInfoArea.ScrollingOffset < 0)
						MapInfoArea.ScrollingOffset = 0;
					break;
				case InfoScrolldown:
					MapInfoArea.ScrollingOffset++;
					if (MapInfoArea.ScrollingOffset > 10)
						MapInfoArea.ScrollingOffset = 10;
					break;
				case BackButton:
					BackPressed();
					break;
			}
			for (i=0; i<LadderObj.CurrentLadder.Default.Matches; i++)
			{
				if (B == Matches[i])
				{
					SelectedMatch = i;
					FillInfoArea(i);
					SetMapShot(i);
				}
			}
			if (B == NextButton)
				NextPressed();
			break;
	}
}

function Close(optional bool bByParent)
{
	LadderObj = None;

	Super.Close(bByParent);
}

function EscClose()
{
	BackPressed();
}

function BackPressed()
{
	Root.CreateWindow(class'ManagerWindow', 100, 100, 200, 200, Root, True);
	Close();
}

// Called after individual ladders evaluate.
function EvaluateMatch(optional bool bTrophyVictory)
{
	local string SaveString;
	local int Team, i;

	// Save the game.
	if (LadderObj != None)
	{
		SaveString = string(LadderObj.TournamentDifficulty);
		if (!class'UTLadderStub'.Static.IsDemo())
		{
			for (i=0; i<class'Ladder'.Default.NumTeams; i++)
			{
				if (class'Ladder'.Default.LadderTeams[i] == LadderObj.Team)
					Team = i;
			}
		} else {
			if (class'Ladder'.Default.LadderTeams[class'Ladder'.Default.NumTeams] == LadderObj.Team)
				Team = class'Ladder'.Default.NumTeams;
			else
				Team = class'Ladder'.Default.NumTeams+1;
		}
		SaveString = SaveString$"\\"$Team;
		SaveString = SaveString$"\\"$LadderObj.DMRank;
		SaveString = SaveString$"\\"$LadderObj.DMPosition;
		SaveString = SaveString$"\\"$LadderObj.DOMRank;
		SaveString = SaveString$"\\"$LadderObj.DOMPosition;
		SaveString = SaveString$"\\"$LadderObj.CTFRank;
		SaveString = SaveString$"\\"$LadderObj.CTFPosition;
		SaveString = SaveString$"\\"$LadderObj.ASRank;
		SaveString = SaveString$"\\"$LadderObj.ASPosition;
		SaveString = SaveString$"\\"$LadderObj.ChalRank;
		SaveString = SaveString$"\\"$LadderObj.ChalPosition;
		SaveString = SaveString$"\\"$LadderObj.Sex;
		SaveString = SaveString$"\\"$LadderObj.Face;
		SaveString = SaveString$"\\"$GetPlayerOwner().PlayerReplicationInfo.PlayerName;
		class'SlotWindow'.Default.Saves[LadderObj.Slot] = SaveString;
		class'SlotWindow'.Static.StaticSaveConfig();

		if (LadderObj.PendingPosition > 7)
		{
			SelectedMatch = LadderObj.PendingPosition;
			BaseMatch = LadderObj.PendingPosition - 7;
			ArrowPos = LadderObj.PendingPosition - 1;
			PendingPos = LadderObj.PendingPosition;
		}
		LadderObj.PendingPosition = 0;
		if (bTrophyVictory)
			bTrophyTravelPending = True;

		SelectedMatch = LadderPos;
		SetMapShot(LadderPos);
		FillInfoArea(LadderPos);
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
				$"?Team=0";

	Root.SetMousePos((Root.WinWidth*Root.GUIScale)/2, (Root.WinHeight*Root.GUIScale)/2);
	Root.Console.CloseUWindow();
	GetPlayerOwner().ClientTravel(StartMap, TRAVEL_Absolute, True);
}

function CloseUp()
{
	Root.Console.bLocked = False;
	Root.Console.bNoDrawWorld = Root.Console.ShowDesktop;
	UMenuRootWindow(Root).MenuBar.ShowWindow();
	Close();
}

function ShowWindow()
{
	if (class'UTLadder'.Static.IsDemo())
		LadderObj.CurrentLadder = DemoLadder;
	else
		LadderObj.CurrentLadder = Ladder;
	Super.ShowWindow();
}

function HideWindow()
{
	Root.Console.bBlackOut = False;

	Super.HideWindow();
}

function CheckOpenCondition()
{
	if ((PendingPos == RequiredRungs) && (LadderObj.PendingChange < 4))
	{
		PendingPos = -1;
		BackPressed();
	}
}

function Tick(float Delta)
{
	if (PendingPos > ArrowPos)
		ArrowPos += Delta/3;
	if ((PendingPos > 0) && (ArrowPos >= PendingPos))
	{
		ArrowPos = PendingPos;

		// After the arrow has moved, check for special event.
		CheckOpenCondition();
		PendingPos = -1;
	}

	if (StaticScale > 0)
		StaticScale -= Delta;
	if (StaticScale < 0)
	{
		if (bMapStatic)
		{
			MapStatic.bVPanStatic = True;
			bMapStatic = False;
		}
		StaticScale = 0.0;
	}

	if (bTrophyTravelPending)
	{
		bTrophyTravelPending = False;
		CloseUp();
		StartMap(TrophyMap, -1, "Botpack.TrophyGame");
	}
}

function SetMapShot(int i)
{
	local int Pos;
	local string MapName;

	Pos = InStr(LadderObj.CurrentLadder.Static.GetMap(i), ".");
	MapName = Left(LadderObj.CurrentLadder.Static.GetMap(i), Pos);
	MapName = LadderObj.CurrentLadder.Default.MapPrefix$MapName;
	MapShot = texture(DynamicLoadObject(MapName$"."$"Screenshot", class'Texture'));

	StaticScale = 1.0;
	bMapStatic = True;
}

function NextPressed()
{
}

defaultproperties
{
	ArrowTex=texture'LadrArrow.arrow_a00'
	StaticTex=texture'Botpack.LadrStatic.Static_a00'
	MapText="Map:"
	AuthorText="Author:"
	FragText="Frag Limit:"
	TeamScoreText="Team Score Limit:"
	BGName1(0)="UTMenu.Ladr11"
	BGName1(1)="UTMenu.Ladr12"
	BGName1(2)="UTMenu.Ladr13"
	BGName1(3)="UTMenu.Ladr14"
	BGName2(0)="UTMenu.Ladr21"
	BGName2(1)="UTMenu.Ladr22"
	BGName2(2)="UTMenu.Ladr23"
	BGName2(3)="UTMenu.Ladr24"
	BGName3(0)="UTMenu.Ladr31"
	BGName3(1)="UTMenu.Ladr32"
	BGName3(2)="UTMenu.Ladr33"
	BGName3(3)="UTMenu.Ladr34"
	NotAvailableString="Not Available In Demo"
	RequiredRungs=4
}