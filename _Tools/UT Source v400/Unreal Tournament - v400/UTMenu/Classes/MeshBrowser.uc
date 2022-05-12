class MeshBrowser expands NotifyWindow
	abstract;

// Background
var texture BG1[4];
var texture BG2[4];
var texture BG3[4];
var string BGName1[4];
var string BGName2[4];
var string BGName3[4];

var UTLadder LadderWindow;

var string GameType;

// Mesh View
var UMenuPlayerMeshClient MeshWindow;
var UTFadeTextArea DescArea;
var localized string NameString;
var localized string ClassString;
var NotifyButton Descscrollup;
var NotifyButton Descscrolldown;
var string TeamMesh;
var texture TeamTex;

// Title
var NotifyButton Title1;
var localized string BrowserName;

var NotifyButton BackButton;
var NotifyButton NextButton;

// Names
var LadderButton Names[8];
var string EmptyText;
var int Selected, NumNames;

var bool Initialized;

// Ladder
var Class<Ladder> Ladder;
var int Match;
var class<RatedMatchInfo> MatchInfo;
var RatedMatchInfo RMI;
var bool bTeamGame, bEnemy;

function Created()
{
	Super.Created();
}

function SetTeamVars()
{
}

function SetInitialBot(class<Bot> InitialBot)
{
}

function SetNumNames()
{
}

function Initialize()
{
	local class<Bot> InitialBot;
	local int i;
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos, YOffset;
	local color TextColor;

	GetPlayerOwner().ViewRotation.Pitch = 0;
	GetPlayerOwner().ViewRotation.Roll = 0;

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

	SetTeamVars();

	/*
	 * Create components.
	 */

	// MeshView
	XPos = 608.0/1024 * XMod;
	YPos = 88.0/768 * YMod;
	XWidth = 323.0/1024 * XMod;
	YHeight = 466.0/768 * YMod;
	MeshWindow = UMenuPlayerMeshClient(CreateWindow(class'UMenuPlayerMeshClient', XPos, YPos, XWidth, YHeight));
	MatchInfo = Ladder.Static.GetMatchConfigType(Match);
	RMI = GetPlayerOwner().Spawn(MatchInfo);
	InitialBot = class<Bot>(DynamicLoadObject(RMI.GetBotClassName(0, bTeamGame, bEnemy, GetPlayerOwner()), Class'Class'));
	MeshWindow.SetMeshString(InitialBot.Default.SelectionMesh);
	MeshWindow.ClearSkins();
	SetInitialBot(InitialBot);

	if (bTeamGame)
		InitialBot.static.SetMultiSkin(MeshWindow.MeshActor, RMI.GetBotSkin(0, bTeamGame, True, GetPlayerOwner()), RMI.GetBotFace(0, bTeamGame, True, GetPlayerOwner()), 1);
	else
		InitialBot.static.SetMultiSkin(MeshWindow.MeshActor, RMI.GetBotSkin(0, bTeamGame, True, GetPlayerOwner()), RMI.GetBotFace(0, bTeamGame, True, GetPlayerOwner()), RMI.GetBotTeam(i, bTeamGame, True, GetPlayerOwner()));

	// Title
	XPos = 74.0/1024 * XMod;
	YPos = 69.0/768 * YMod;
	XWidth = 352.0/1024 * XMod;
	YHeight = 41.0/768 * YMod;
	Title1 = NotifyButton(CreateWindow(class'NotifyButton', XPos, YPos, XWidth, YHeight));
	if (!Ladder.Default.bTeamGame)
		Title1.Text = BrowserName;
	else
		Title1.Text = RMI.GetTeamName(bEnemy, GetPlayerOwner());
	TextColor.R = 255;
	TextColor.G = 255;
	TextColor.B = 0;
	Title1.SetTextColor(TextColor);
	Title1.MyFont = class'UTLadderStub'.Static.GetHugeFont(Root);
	Title1.bStretched = True;
	if (!Ladder.Default.bTeamGame)
		Title1.bDisabled = True;
	else
		Title1.NotifyWindow = Self;

	// Names
	SetNumNames();
	TextColor.R = 0;
	TextColor.G = 128;
	TextColor.B = 255;
	XPos = 168.0/1024 * XMod;
	YPos = 255.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	YOffset = 48.0/768 * YMod;
	for (i=0; i<NumNames; i++)
	{
		Names[i] = LadderButton(CreateWindow(class'LadderButton', XPos, YPos + i*YOffset, XWidth, YHeight));
		Names[i].MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
		Names[i].NotifyWindow = Self;
		Names[i].SetTextColor(TextColor);
		Names[i].Text = RMI.GetBotName(i, bTeamGame, bEnemy, GetPlayerOwner());
		Names[i].bStretched = True;
		Names[i].bDontSetLabel = True;
		Names[i].LabelWidth = 178/1024 * XMod;
		Names[i].LabelHeight = 49/768 * YMod;
		Names[i].OverSound = sound'LadderSounds.lcursorMove';
		Names[i].DownSound = sound'SpeechWindowClick';
	}
	Names[0].bBottom = True;
	Names[NumNames-1].bTop = True;

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

	// Desc
	XPos = 609.0/1024 * XMod;
	YPos = 388.0/768 * YMod;
	XWidth = 321.0/1024 * XMod;
	YHeight = 113.0/768 * YMod;
	DescArea = UTFadeTextArea(CreateWindow(Class<UWindowWindow>(DynamicLoadObject("UTMenu.UTFadeTextArea", Class'Class')), XPos, YPos, XWidth, YHeight));
	DescArea.TextColor.R = 255;
	DescArea.TextColor.G = 255;
	DescArea.TextColor.B = 0;
	DescArea.MyFont = class'UTLadderStub'.Static.GetSmallFont(Root);
	DescArea.bAlwaysOnTop = True;
	DescArea.bMousePassThrough = True;
	DescArea.bAutoScrolling = True;
	if (Ladder.Default.bTeamGame)
		TitleClicked();
	else {
		DescArea.Clear();
		DescArea.AddText(NameString$" "$RMI.GetBotName(0, bTeamGame, True, GetPlayerOwner()));
		DescArea.AddText(ClassString$" "$RMI.GetBotClassification(0, bTeamGame, True, GetPlayerOwner()));
		DescArea.AddText("");
		DescArea.AddText(RMI.GetBotDesc(0, bTeamGame, True, GetPlayerOwner()));
	}

	// DescScrollup
	XPos = 715.0/1024 * XMod;
	YPos = 538.0/768 * YMod;
	XWidth = 32.0/1024 * XMod;
	YHeight = 16.0/768 * YMod;
	DescScrollup = NotifyButton(CreateWindow(class'NotifyButton', XPos, YPos, XWidth, YHeight));
	DescScrollup.NotifyWindow = Self;
	DescScrollup.Text = "";
	DescScrollup.bStretched = True;
	DescScrollup.UpTexture = Texture(DynamicLoadObject("UTMenu.AroUup", Class'Texture'));
	DescScrollup.OverTexture = Texture(DynamicLoadObject("UTMenu.AroUovr", Class'Texture'));
	DescScrollup.DownTexture = Texture(DynamicLoadObject("UTMenu.AroUdwn", Class'Texture'));
	DescScrollup.MyFont = class'UTLadderStub'.Static.GetSmallFont(Root);
	DescScrollup.bAlwaysOnTop = True;

	// DescScrolldown
	XPos = 799.0/1024 * XMod;
	YPos = 538.0/768 * YMod;
	XWidth = 32.0/1024 * XMod;
	YHeight = 16.0/768 * YMod;
	DescScrolldown = NotifyButton(CreateWindow(class'NotifyButton', XPos, YPos, XWidth, YHeight));
	DescScrolldown.NotifyWindow = Self;
	DescScrolldown.Text = "";
	DescScrolldown.bStretched = True;
	DescScrolldown.UpTexture = Texture(DynamicLoadObject("UTMenu.AroDup", Class'Texture'));
	DescScrolldown.OverTexture = Texture(DynamicLoadObject("UTMenu.AroDovr", Class'Texture'));
	DescScrolldown.DownTexture = Texture(DynamicLoadObject("UTMenu.AroDdwn", Class'Texture'));
	DescScrolldown.MyFont = class'UTLadderStub'.Static.GetSmallFont(Root);
	DescScrolldown.bAlwaysOnTop = True;

	Initialized = True;
	Root.Console.bBlackout = True;

	if (Ladder.Default.bTeamGame)
		Selected = -1;
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

	// MeshView
	XPos = 608.0/1024 * XMod;
	YPos = 88.0/768 * YMod;
	XWidth = 323.0/1024 * XMod;
	YHeight = 466.0/768 * YMod;
	MeshWindow.SetSize(XWidth, YHeight);
	MeshWindow.WinLeft = XPos;
	MeshWindow.WinTop = YPos;

	// Names
	XPos = 168.0/1024 * XMod;
	YPos = 595.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	YOffset = 47.0/768 * YMod;
	// Reset the names.
	for (i=0; i<NumNames; i++)
	{
		Names[i].MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
		Names[i].WinLeft = XPos;
		Names[i].WinTop = YPos - (i * YOffset);
		Names[i].SetSize(XWidth, YHeight);
		Names[i].LabelWidth = 178/1024 * XMod;
		Names[i].LabelHeight = 49/768 * YMod;
		if (i == Selected)
			Names[i].bSelected = True;
		else
			Names[i].bSelected = False;
	}

	// Back Button
	XPos = 192.0/1024 * XMod;
	YPos = 701.0/768 * YMod;
	XWidth = 64.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	BackButton.SetSize(XWidth, YHeight);
	BackButton.WinLeft = XPos;
	BackButton.WinTop = YPos;

	// Next Button
	XPos = 256.0/1024 * XMod;
	YPos = 701.0/768 * YMod;
	XWidth = 64.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	NextButton.SetSize(XWidth, YHeight);
	NextButton.WinLeft = XPos;
	NextButton.WinTop = YPos;

	// Desc
	XPos = 609.0/1024 * XMod;
	YPos = 388.0/768 * YMod;
	XWidth = 321.0/1024 * XMod;
	YHeight = 113.0/768 * YMod;
	DescArea.SetSize(XWidth, YHeight);
	DescArea.WinLeft = XPos;
	DescArea.WinTop = YPos;
	DescArea.MyFont = class'UTLadderStub'.Static.GetSmallFont(Root);

	// DescScrollup
	XPos = 715.0/1024 * XMod;
	YPos = 538.0/768 * YMod;
	XWidth = 32.0/1024 * XMod;
	YHeight = 16.0/768 * YMod;
	DescScrollup.WinLeft = XPos;
	DescScrollup.WinTop = YPos;
	DescScrollup.SetSize(XWidth, YHeight);

	// DescScrolldown
	XPos = 799.0/1024 * XMod;
	YPos = 538.0/768 * YMod;
	XWidth = 32.0/1024 * XMod;
	YHeight = 16.0/768 * YMod;
	DescScrolldown.WinLeft = XPos;
	DescScrolldown.WinTop = YPos;
	DescScrolldown.SetSize(XWidth, YHeight);
}

function Paint(Canvas C, float X, float Y)
{
	local int XOffset, YOffset;
	local int W, H, i;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos;

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

	if (Ladder.Default.bTeamGame)
	{
		DrawStretchedTexture(C, XOffset + (0 * W), YOffset + (0 * H), (W+1)/2, (H+1)/2, texture'TeamPlate');
		DrawStretchedTexture(C, XOffset + (0 * W) + (65.0/1024*XMod), YOffset + (0 * H) + (61.0/768*YMod), (58.0/1024*XMod), (57.0/768*YMod), RMI.GetTeamSymbol(bEnemy, GetPlayerOwner()));
	}
}

function TitleClicked()
{
	MeshWindow.SetNoAnimMesh(mesh(DynamicLoadObject(TeamMesh, Class'mesh')));
	MeshWindow.MeshActor.Texture = TeamTex;
	MeshWindow.MeshActor.bMeshEnviroMap = True;
	MeshWindow.MeshActor.DrawScale = 0.13 * 0.35;
	MeshWindow.bRotate = True;
	MeshWindow.bFace = False;
	MeshWindow.FaceButton.HideWindow();
	MeshWindow.ViewRotator = rot(0, 32768, 0);
	MeshWindow.CenterRotator = rot(0, 0, 0);

	Selected = -1;
	DescArea.Clear();
	DescArea.AddText(RMI.GetTeamName(False, GetPlayerOwner()));
	DescArea.AddText("");
	DescArea.AddText(RMI.GetTeamBio(False, GetPlayerOwner()));
}

function CloseUp()
{
	RMI = None;

	Root.Console.bLocked = False;
	Root.Console.bNoDrawWorld = Root.Console.ShowDesktop;
	UMenuRootWindow(Root).MenuBar.ShowWindow();
	Close();
	LadderWindow.Close();
}

function BackPressed()
{
}

function EscClose()
{
	BackPressed();
}

function HideWindow()
{
	Root.Console.bBlackOut = False;

	Super.HideWindow();
}
