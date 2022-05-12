class SlotWindow extends NotifyWindow
	config(user);

// Slots
#exec TEXTURE IMPORT NAME=Save11 FILE=TEXTURES\Save\Save11.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=Save12 FILE=TEXTURES\Save\Save12.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=Save13 FILE=TEXTURES\Save\Save13.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=Save14 FILE=TEXTURES\Save\Save14.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=Save21 FILE=TEXTURES\Save\Save21.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=Save22 FILE=TEXTURES\Save\Save22.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=Save23 FILE=TEXTURES\Save\Save23.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=Save24 FILE=TEXTURES\Save\Save24.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=Save31 FILE=TEXTURES\Save\Save31.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=Save32 FILE=TEXTURES\Save\Save32.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=Save33 FILE=TEXTURES\Save\Save33.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=Save34 FILE=TEXTURES\Save\Save34.PCX GROUP=Skins MIPS=OFF

#exec TEXTURE IMPORT NAME=SaveButtonsUp FILE=TEXTURES\Save\SaveButtonsUp.PCX GROUP=Skins MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=SBtnLDwn FILE=TEXTURES\Save\SBtnLDwn.PCX GROUP=Skins MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=SBtnLGlow FILE=TEXTURES\Save\SBtnLGlow.PCX GROUP=Skins MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=SBtnRDwn FILE=TEXTURES\Save\SBtnRDwn.PCX GROUP=Skins MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=SBtnRGlow FILE=TEXTURES\Save\SBtnRGlow.PCX GROUP=Skins MIPS=OFF FLAGS=2

// Background
var texture BG1[4];
var texture BG2[4];
var texture BG3[4];
var string BGName1[4];
var string BGName2[4];
var string BGName3[4];

// Slot Buttons
var NotifyButton SlotButton[5];
var localized string EmptyText;
var NotifyButton KillButton[5];
var NotifyButton GoButton[5];

var globalconfig string Saves[5];

var localized string AvgRankStr;
var localized string CompletedStr;

var string Faces[16];
var string FaceDescs[16];

function Created()
{
	local int i;
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

	// Slots
	XWidth = 480.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	XPos = 310.0/1024 * XMod;
	YPos = 89.0/768 * YMod;
	YOffset = 132.0/768 * YMod;
	for (i=0; i<5; i++)
	{
		SlotButton[i] = NotifyButton(CreateWindow(class'NotifyButton', XPos, YPos + YOffset*i, XWidth, YHeight));
		SlotButton[i].NotifyWindow = Self;
		TextColor.R = 255;
		TextColor.G = 255;
		TextColor.B = 0;
		SlotButton[i].SetTextColor(TextColor);
		SlotButton[i].MyFont = class'UTLadderStub'.Static.GetHugeFont(Root);
		SlotButton[i].bStretched = True;
	}

	// Kill Buttons
	XWidth = 80.0/1024 * XMod;
	YHeight = 72.0/768 * YMod;
	XPos = 138.0/1024 * XMod;
	YPos = 89.0/768 * YMod;
	YOffset = 132.0/768 * YMod;
	for (i=0; i<5; i++)
	{
		KillButton[i] = NotifyButton(CreateWindow(class'NotifyButton', XPos, YPos + YOffset*i, XWidth, YHeight));
		KillButton[i].NotifyWindow = Self;
		KillButton[i].Text = "";
		KillButton[i].MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	}

	// Go Buttons
	XWidth = 83.0/1024 * XMod;
	YHeight = 72.0/768 * YMod;
	XPos = 218.0/1024 * XMod;
	YPos = 89.0/768 * YMod;
	YOffset = 132.0/768 * YMod;
	for (i=0; i<5; i++)
	{
		GoButton[i] = NotifyButton(CreateWindow(class'NotifyButton', XPos, YPos + YOffset*i, XWidth, YHeight));
		GoButton[i].NotifyWindow = Self;
		GoButton[i].Text = "";
		GoButton[i].MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	}

	Root.Console.bBlackout = True;
}

function SetSaveText(int i, Canvas C)
{
	local string Temp, Sex, Name;
	local int Pos, DMRank, DOMRank, CTFRank, ASRank, ChalRank, AvgRank;
	local int DMPosition, DOMPosition, CTFPosition, ASPosition, ChalPosition, TotPosition;
	local float XL, YL;
	local font CFont;

	// Team
	Temp = Right(Saves[i], Len(Saves[i]) - 2);
	Pos = InStr(Temp, "\\");

	// DMRank
	Temp = Right(Saves[i], Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	DMRank = int(Left(Temp, Pos));

	// DMPosition
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	DMPosition = int(Left(Temp, Pos));

	// DOMRank
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	DOMRank = int(Left(Temp, Pos));

	// DOMPosition
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	DOMPosition = int(Left(Temp, Pos));

	// CTFRank
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	CTFRank = int(Left(Temp, Pos));

	// CTFPosition
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	CTFPosition = int(Left(Temp, Pos));

	// ASRank
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	ASRank = int(Left(Temp, Pos));

	// ASPosition
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	ASPosition = int(Left(Temp, Pos));

	// ChalRank
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	ChalRank = int(Left(Temp, Pos));

	// ChalPosition
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	ChalPosition = int(Left(Temp, Pos));

	// Sex
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");

	// Face
	Temp = Right(Temp, Len(Temp) - Pos - 1);

	// Name
	Temp = Right(Temp, Len(Temp) - 2);
	Name = Temp;

	AvgRank = (DMRank + DOMRank + CTFRank + ASRank)/4;
	if (class'UTLadderStub'.Static.IsDemo())
	{
		if (DMPosition > 0)
		{
			if (DMRank == 4)
				TotPosition += DMPosition;
			else
				TotPosition += DMPosition-1;
		}
		if (DOMPosition > 0)
		{
			if (DOMRank == 4)
				TotPosition += DOMPosition;
			else
				TotPosition += DOMPosition-1;
		}
		if (CTFPosition > 0)
		{
			if (CTFRank == 4)
				TotPosition += CTFPosition;
			else
				TotPosition += CTFPosition-1;
		}
	} else {
		if (DMPosition > 0)
		{
			if (DMRank == 6)
				TotPosition += DMPosition;
			else
				TotPosition += DMPosition-1;
		}
		if (DOMPosition > 0)
		{
			if (DOMRank == 6)
				TotPosition += DOMPosition;
			else
				TotPosition += DOMPosition-1;
		}
		if (CTFPosition > 0)
		{
			if (CTFRank == 6)
				TotPosition += CTFPosition;
			else
				TotPosition += CTFPosition-1;
		}
		if (ASPosition > 0)
		{
			if (ASRank == 6)
				TotPosition += ASPosition;
			else
				TotPosition += ASPosition-1;
		}
	}
	if (ChalPosition > 0)
		TotPosition += ChalPosition;
	if (ChalRank == 6)
		TotPosition++;
	if (C.ClipX > 320)
		SlotButton[i].Text = Name$" - "$CompletedStr@TotPosition;
	else
		SlotButton[i].Text = Name;
	CFont = C.Font;
	C.Font = class'UTLadderStub'.Static.GetHugeFont(Root);
	C.StrLen(SlotButton[i].Text, XL, YL);
	if (XL > SlotButton[i].WinWidth)
		SlotButton[i].Text = Name;
	C.Font = CFont;
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

	XWidth = 480.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	XPos = 310.0/1024 * XMod;
	YPos = 89.0/768 * YMod;
	YOffset = 132.0/768 * YMod;
	for (i=0; i<5; i++)
	{
		SlotButton[i].SetSize(XWidth, YHeight);
		SlotButton[i].WinLeft = XPos;
		SlotButton[i].WinTop = YPos + YOffset*i;
		SlotButton[i].MyFont = class'UTLadderStub'.Static.GetHugeFont(Root);
		if (Saves[i] != "")
			SetSaveText(i, C);
		else
			SlotButton[i].Text = EmptyText;
	}

	// Kill Buttons
	XWidth = 80.0/1024 * XMod;
	YHeight = 72.0/768 * YMod;
	XPos = 138.0/1024 * XMod;
	YPos = 89.0/768 * YMod;
	YOffset = 132.0/768 * YMod;
	for (i=0; i<5; i++)
	{
		KillButton[i].SetSize(XWidth, YHeight);
		KillButton[i].WinLeft = XPos;
		KillButton[i].WinTop = YPos + YOffset*i;
	}

	// Go Buttons
	XWidth = 83.0/1024 * XMod;
	YHeight = 72.0/768 * YMod;
	XPos = 218.0/1024 * XMod;
	YPos = 89.0/768 * YMod;
	YOffset = 132.0/768 * YMod;
	for (i=0; i<5; i++)
	{
		GoButton[i].SetSize(XWidth, YHeight);
		GoButton[i].WinLeft = XPos;
		GoButton[i].WinTop = YPos + YOffset*i;
	}
}

function Paint(Canvas C, float X, float Y)
{
	local int i;
	local int XOffset, YOffset;
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos, YOffset2;

	W = WinWidth / 4;
	H = W;

	if(W > 256 || H > 256)
	{
		Tile(C, Texture'MenuBlack');
		W = 256;
		H = 256;
	}

	XMod = 4*W;
	YMod = 3*H;

	XOffset = (WinWidth - (4 * W)) / 2;
	YOffset = (WinHeight - (3 * H)) / 2;

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

	XWidth = 256.0/1024 * XMod;
	YHeight = 128.0/768 * YMod;
	XPos = 138.0/1024 * XMod;
	YPos = 87.0/768 * YMod;
	YOffset2 = 132.0/768 * YMod;
	for (i=0; i<5; i++)
	{
		if (KillButton[i].bMouseDown)
			DrawStretchedTexture(C, XPos, YPos + YOffset2*i, XWidth, YHeight, texture'SBtnLDwn');
		else if (GoButton[i].bMouseDown)
			DrawStretchedTexture(C, XPos, YPos + YOffset2*i, XWidth, YHeight, texture'SBtnRDwn');
		else if (KillButton[i].MouseIsOver())
			DrawStretchedTexture(C, XPos, YPos + YOffset2*i, XWidth, YHeight, texture'SBtnLGlow');
		else if (GoButton[i].MouseIsOver())
			DrawStretchedTexture(C, XPos, YPos + YOffset2*i, XWidth, YHeight, texture'SBtnRGlow');
		else
			DrawStretchedTexture(C, XPos, YPos + YOffset2*i, XWidth, YHeight, texture'SaveButtonsUp');
	}
}

function Notify(UWindowWindow B, byte E)
{
	local LadderInventory LadderObj;
	local int i;

	switch (E)
	{
		case DE_Click:
			for (i=0; i<5; i++)
			{
				if (B == KillButton[i]) {
					KillGame(i);
				} else if (B == GoButton[i]) {
					RestoreGame(i);
				}
			}
			break;
	}
}

function Close(optional bool bByParent)
{
	HideWindow();
	Root.Console.bNoDrawWorld = Root.Console.ShowDesktop;
	Root.Console.bLocked = False;
	UMenuRootWindow(Root).MenuBar.ShowWindow();

	Super.Close(bByParent);
}

function HideWindow()
{
	Root.Console.bBlackOut = False;

	Super.HideWindow();
}

function KillGame(int i)
{
	local KillGameQueryWindow KGQWindow;

	if (SlotButton[i].Text != EmptyText)
	{
		// Are you sure?
		KGQWindow = KillGameQueryWindow(Root.CreateWindow(class'KillGameQueryWindow', 100, 100, 100, 100));
		KillGameQueryClient(KGQWindow.ClientArea).SlotWindow = Self;
		KillGameQueryClient(KGQWindow.ClientArea).SlotIndex = i;
		ShowModal(KGQWindow);
	}
}

function RestoreGame(int i)
{
	local LadderInventory LadderObj;
	local string Temp, Name, PlayerSkin;
	local Class<TournamentPlayer> PlayerClass;
	local int Pos, Team, j, Face;

	if (Saves[i] == "")
		return;

	// Check ladder object.
	LadderObj = LadderInventory(GetPlayerOwner().FindInventoryType(class'LadderInventory'));
	if (LadderObj == None)
	{
		// Make them a ladder object.
		LadderObj = GetPlayerOwner().Spawn(class'LadderInventory');
		LadderObj.GiveTo(GetPlayerOwner());
	}

	// Fill the ladder object.

	// Slot...
	LadderObj.Slot = i;

	// Difficulty...
	LadderObj.TournamentDifficulty = int(Left(Saves[i], 1));
	LadderObj.SkillText = class'NewCharacterWindow'.Default.SkillText[LadderObj.TournamentDifficulty];

	// Team
	Temp = Right(Saves[i], Len(Saves[i]) - 2);
	Pos = InStr(Temp, "\\");
	Team = int(Left(Temp, Pos));
	LadderObj.Team = class'Ladder'.Default.LadderTeams[Team];

	// DMRank
	Temp = Right(Saves[i], Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	LadderObj.DMRank = int(Left(Temp, Pos));

	// DMPosition
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	LadderObj.DMPosition = int(Left(Temp, Pos));

	// DOMRank
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	LadderObj.DOMRank = int(Left(Temp, Pos));

	// DOMPosition
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	LadderObj.DOMPosition = int(Left(Temp, Pos));

	// CTFRank
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	LadderObj.CTFRank = int(Left(Temp, Pos));

	// CTFPosition
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	LadderObj.CTFPosition = int(Left(Temp, Pos));

	// ASRank
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	LadderObj.ASRank = int(Left(Temp, Pos));

	// ASPosition
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	LadderObj.ASPosition = int(Left(Temp, Pos));

	// ChalRank
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	LadderObj.ChalRank = int(Left(Temp, Pos));

	// ChalPosition
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	LadderObj.ChalPosition = int(Left(Temp, Pos));

	// Sex
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	LadderObj.Sex = Left(Temp, Pos);

	// Face
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	Face = int(Left(Temp, Pos));
	LadderObj.Face = Face;

	// Name
	Temp = Right(Temp, Len(Temp) - 2);
	Name = Temp;
	GetPlayerOwner().ChangeName(Name);
	GetPlayerOwner().UpdateURL("Name", Name, True);

	if (LadderObj.Sex ~= "M")
	{
		PlayerClass = LadderObj.Team.Default.MaleClass;
		PlayerSkin = LadderObj.Team.Default.MaleSkin;
	} else {
		PlayerClass = LadderObj.Team.Default.FemaleClass;
		PlayerSkin = LadderObj.Team.Default.FemaleSkin;
	}

	IterateFaces(PlayerSkin, GetPlayerOwner().GetItemName(string(PlayerClass.Default.Mesh)));
	GetPlayerOwner().UpdateURL("Class", string(PlayerClass), True);
	GetPlayerOwner().UpdateURL("Skin", PlayerSkin, True);
	GetPlayerOwner().UpdateURL("Face", Faces[Face], True);
	GetPlayerOwner().UpdateURL("Voice", PlayerClass.Default.VoiceType, True);
	GetPlayerOwner().UpdateURL("Team", "255", True);

	// Goto Manager
	HideWindow();
	Root.CreateWindow(class'ManagerWindow', 100, 100, 200, 200, Root, True);
}

function IterateFaces(string InSkinName, string MeshName)
{
	local string SkinName, SkinDesc, TestName, Temp, FaceName;
	local bool bNewFormat;
	local int i, Pos;

	for (i=0; i<16; i++)
	{
		FaceDescs[i] = "";
		Faces[i] = "";
	}

	i = 0;

	SkinName = "None";
	TestName = "";
	while ( True )
	{
		GetPlayerOwner().GetNextSkin(MeshName, SkinName, 1, SkinName, SkinDesc);

		if( SkinName == TestName )
			break;

		if( TestName == "" )
			TestName = SkinName;

		// Multiskin format
		if( SkinDesc != "")
		{			
			Temp = GetPlayerOwner().GetItemName(SkinName);
			if(Mid(Temp, 5) != "" && Left(Temp, 4) == GetPlayerOwner().GetItemName(InSkinName))
			{
				Pos = InStr(SkinName, ".");
				FaceDescs[i] = SkinDesc;
				Faces[i++] = Left(SkinName, Pos+1)$Mid(Temp, 5);
			}
		}
	}
}

defaultproperties
{
	EmptyText="UNUSED"
	AvgRankStr="Average Rank:"
	CompletedStr="Matches Won:"
	BGName1(0)="UTMenu.Save11"
	BGName1(1)="UTMenu.Save12"
	BGName1(2)="UTMenu.Save13"
	BGName1(3)="UTMenu.Save14"
	BGName2(0)="UTMenu.Save21"
	BGName2(1)="UTMenu.Save22"
	BGName2(2)="UTMenu.Save23"
	BGName2(3)="UTMenu.Save24"
	BGName3(0)="UTMenu.Save31"
	BGName3(1)="UTMenu.Save32"
	BGName3(2)="UTMenu.Save33"
	BGName3(3)="UTMenu.Save34"
}