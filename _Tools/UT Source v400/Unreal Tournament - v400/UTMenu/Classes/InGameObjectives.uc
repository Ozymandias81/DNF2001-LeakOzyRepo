class InGameObjectives extends NotifyWindow;

// Background
var texture BG1[4];
var texture BG2[4];
var texture BG3[4];
var string BGName1[4];
var string BGName2[4];
var string BGName3[4];

// Title
var NotifyButton Title1;
var localized string BrowserName;

var NotifyButton BackButton;
var NotifyButton NextButton;

var UTFadeTextArea ObjDescArea;
var NotifyButton Descscrollup;
var NotifyButton Descscrolldown;

// Names
var LadderButton Names[8];
var localized string ObjectiveString;
var string EmptyText;
var int SelectedO, NumNames;

var bool Initialized;

// Map Screen Shot
var float StaticScale;
var texture MapShot;
var StaticArea MapStatic;
var bool bMapStatic;
var texture StaticTex;

var localized string StandByText;
var localized string OrdersTransmissionText;

var AssaultInfo AI;

function Created()
{
	local class<Bot> InitialMate;
	local int i;
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos, YOffset;
	local color TextColor;
	local AssaultInfo AIS;

	Super.Created();

	GetPlayerOwner().ViewRotation.Pitch = 0;
	GetPlayerOwner().ViewRotation.Roll = 0;

	AI = AssaultInfo(DynamicLoadObject(Left(GetLevel().GetLocalURL(), 9)$".AssaultInfo0", class'AssaultInfo'));

	foreach GetPlayerOwner().AllActors(class'AssaultInfo', AIS)
	{
		AI = AIS;
	}

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

	// Title
	XPos = 74.0/1024 * XMod;
	YPos = 69.0/768 * YMod;
	XWidth = 352.0/1024 * XMod;
	YHeight = 41.0/768 * YMod;
	Title1 = NotifyButton(CreateWindow(class'NotifyButton', XPos, YPos, XWidth, YHeight));
	Title1.Text = BrowserName;
	TextColor.R = 255;
	TextColor.G = 255;
	TextColor.B = 0;
	Title1.NotifyWindow = Self;
	Title1.SetTextColor(TextColor);
	Title1.MyFont = class'UTLadderStub'.Static.GetHugeFont(Root);
	Title1.bStretched = True;
	Title1.bDisabled = True;

	// Names
	TextColor.R = 0;
	TextColor.G = 128;
	TextColor.B = 255;
	XPos = 168.0/1024 * XMod;
	YPos = 255.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	YOffset = 48.0/768 * YMod;
	NumNames = AI.NumObjShots;
	for (i=0; i<NumNames; i++)
	{
		Names[i] = LadderButton(CreateWindow(class'LadderButton', XPos, YPos + i*YOffset, XWidth, YHeight));
		Names[i].MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
		Names[i].NotifyWindow = Self;
		Names[i].SetTextColor(TextColor);
		Names[i].bStretched = True;
		Names[i].bDontSetLabel = True;
		Names[i].LabelWidth = 178.0/1024 * XMod;
		Names[i].LabelHeight = 49.0/768 * YMod;
		Names[i].OverSound = sound'LadderSounds.lcursorMove';
		Names[i].DownSound = sound'SpeechWindowClick';
		Names[i].Text = ObjectiveString@i+1;
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

	// Obj Desc
	XPos = 529.0/1024 * XMod;
	YPos = 586.0/768 * YMod;
	XWidth = 385.0/1024 * XMod;
	YHeight = 113.0/768 * YMod;
	ObjDescArea = UTFadeTextArea(CreateWindow(Class<UWindowWindow>(DynamicLoadObject("UTMenu.UTFadeTextArea", Class'Class')), XPos, YPos, XWidth, YHeight));
	ObjDescArea.TextColor.R = 255;
	ObjDescArea.TextColor.G = 255;
	ObjDescArea.TextColor.B = 0;
	ObjDescArea.MyFont = class'UTLadderStub'.Static.GetSmallFont(Root);
	ObjDescArea.bAlwaysOnTop = True;
	ObjDescArea.bAutoScrolling = True;

	// DescScrollup
	XPos = 923.0/1024 * XMod;
	YPos = 590.0/768 * YMod;
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
	XPos = 923.0/1024 * XMod;
	YPos = 683.0/768 * YMod;
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

	// StaticArea
	XPos = 608.0/1024 * XMod;
	YPos = 90.0/768 * YMod;
	XWidth = 320.0/1024 * XMod;
	YHeight = 319.0/768 * YMod;
	MapStatic = StaticArea(CreateWindow(class'StaticArea', XPos, YPos, XWidth, YHeight));
	MapStatic.VStaticScale = 300.0;

	Initialized = True;
	Root.Console.bBlackout = True;

	SelectedO = 0;
	SetMapShot(AI.ObjShots[0]);
	AddObjDesc();
	StaticScale = 1.0;
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

	// Names
	XPos = 168.0/1024 * XMod;
	YPos = 595.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	YOffset = 47.0/768 * YMod;
	for (i=0; i<NumNames; i++)
	{
		Names[i].MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
		Names[i].WinLeft = XPos;
		Names[i].WinTop = YPos - (i * YOffset);
		Names[i].SetSize(XWidth, YHeight);
		Names[i].LabelWidth = 178/1024 * XMod;
		Names[i].LabelHeight = 49/768 * YMod;
		if (i == SelectedO)
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

	// Obj Desc
	XPos = 529.0/1024 * XMod;
	YPos = 586.0/768 * YMod;
	XWidth = 385.0/1024 * XMod;
	YHeight = 113.0/768 * YMod;
	ObjDescArea.SetSize(XWidth, YHeight);
	ObjDescArea.WinLeft = XPos;
	ObjDescArea.WinTop = YPos;
	ObjDescArea.MyFont = class'UTLadderStub'.Static.GetSmallFont(Root);

	// DescScrollup
	XPos = 923.0/1024 * XMod;
	YPos = 590.0/768 * YMod;
	XWidth = 32.0/1024 * XMod;
	YHeight = 16.0/768 * YMod;
	DescScrollup.WinLeft = XPos;
	DescScrollup.WinTop = YPos;
	DescScrollup.SetSize(XWidth, YHeight);

	// DescScrolldown
	XPos = 923.0/1024 * XMod;
	YPos = 683.0/768 * YMod;
	XWidth = 32.0/1024 * XMod;
	YHeight = 16.0/768 * YMod;
	DescScrolldown.WinLeft = XPos;
	DescScrolldown.WinTop = YPos;
	DescScrolldown.SetSize(XWidth, YHeight);

	// StaticArea
	XPos = 608.0/1024 * XMod;
	YPos = 90.0/768 * YMod;
	XWidth = 320.0/1024 * XMod;
	YHeight = 319.0/768 * YMod;
	MapStatic.WinLeft = XPos;
	MapStatic.WinTop = YPos;
	MapStatic.SetSize(XWidth, YHeight);
}

function Paint(Canvas C, float X, float Y)
{
	local int XOffset, YOffset;
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos;
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
}

function Notify(UWindowWindow B, byte E)
{
	local int i;

	switch (E)
	{
		case DE_Click:
			for (i=0; i<8; i++)
			{
				if (B == Names[i])
				{
					if (!Names[i].bDisabled)
						NameSelected(i);
					return;
				}
			}
			switch (B)
			{
				case NextButton:
					Close();
					break;
				case BackButton:
					Close();
					break;
				case DescScrollup:
					ObjDescArea.ScrollingOffset--;
					if (ObjDescArea.ScrollingOffset < 0)
						ObjDescArea.ScrollingOffset = 0;
					break;
				case DescScrolldown:
					ObjDescArea.ScrollingOffset++;
					if (ObjDescArea.ScrollingOffset > 10)
						ObjDescArea.ScrollingOffset = 10;
					break;
			}
			break;
	}
}

function NameSelected(int i)
{
	SelectedO = i;
	SetMapShot(AI.ObjShots[SelectedO]);
	AddObjDesc();
}

function Close(optional bool bByParent)
{
	HideWindow();
	Root.Console.bNoDrawWorld = Root.Console.ShowDesktop;
	Root.Console.bLocked = False;
	UMenuRootWindow(Root).MenuBar.ShowWindow();
	Root.Console.CloseUWindow();

	Super.Close(bByParent);
}

function HideWindow()
{
	Root.Console.bBlackOut = False;

	Super.HideWindow();
}

function AddObjDesc()
{
	ObjDescArea.Clear();
	ObjDescArea.AddText(OrdersTransmissionText);
	ObjDescArea.AddText("---");
	ObjDescArea.AddText(AI.ObjDesc[SelectedO]);
}

function Tick(float Delta)
{
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
}

function SetMapShot(texture NewShot)
{
	StaticScale = 1.0;
	MapShot = NewShot;
	bMapStatic = True;
}

defaultproperties
{
	StaticTex=texture'Botpack.LadrStatic.Static_a00'
	OrdersTransmissionText="Orders Transmission Follows"
	ObjectiveString="Objective"
	EmptyText=""
	BrowserName="Mission Objectives"
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
}