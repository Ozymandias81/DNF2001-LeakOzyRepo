class NewCharacterWindow extends NotifyWindow
	config(user);

// New Character
#exec TEXTURE IMPORT NAME=TeamPlate FILE=TEXTURES\NewCharacter\TeamPlate.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=CC11 FILE=TEXTURES\NewCharacter\CC11.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=CC12 FILE=TEXTURES\NewCharacter\CC12.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=CC13 FILE=TEXTURES\NewCharacter\CC13.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=CC14 FILE=TEXTURES\NewCharacter\CC14.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=CC21 FILE=TEXTURES\NewCharacter\CC21.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=CC22 FILE=TEXTURES\NewCharacter\CC22.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=CC23 FILE=TEXTURES\NewCharacter\CC23.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=CC24 FILE=TEXTURES\NewCharacter\CC24.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=CC31 FILE=TEXTURES\NewCharacter\CC31.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=CC32 FILE=TEXTURES\NewCharacter\CC32.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=CC33 FILE=TEXTURES\NewCharacter\CC33.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=CC34 FILE=TEXTURES\NewCharacter\CC34.PCX GROUP=Skins MIPS=OFF

#exec TEXTURE IMPORT NAME=LeftDown FILE=TEXTURES\Buttons\LDwn.PCX GROUP=Skins MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=LeftOver FILE=TEXTURES\Buttons\LOvr.PCX GROUP=Skins MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=LeftUp FILE=TEXTURES\Buttons\LUp.PCX GROUP=Skins MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=RightDown FILE=TEXTURES\Buttons\RDwn.PCX GROUP=Skins MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=RightOver FILE=TEXTURES\Buttons\ROvr.PCX GROUP=Skins MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=RightUp FILE=TEXTURES\Buttons\RUp.PCX GROUP=Skins MIPS=OFF FLAGS=2

#exec TEXTURE IMPORT NAME=Plate FILE=TEXTURES\Ladr\Plate.PCX GROUP=Skins FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=Plate2 FILE=TEXTURES\Ladr\Plate2.PCX GROUP=Skins FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=PlateCap FILE=TEXTURES\Ladr\PlateCap.PCX GROUP=Skins FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=PlateLowCap FILE=TEXTURES\Ladr\PlateLowCap.PCX GROUP=Skins FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=Plate3 FILE=TEXTURES\Ladr\Plate3.PCX GROUP=Skins FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=Plate3Plain FILE=TEXTURES\Ladr\Plate3Plain.PCX GROUP=Skins FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=Plate3Cap FILE=TEXTURES\Ladr\Plate3Cap.PCX GROUP=Skins FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=Plate3LowCap FILE=TEXTURES\Ladr\Plate3LowCap.PCX GROUP=Skins FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=PlateYellow FILE=TEXTURES\Ladr\PlateYellow.PCX GROUP=Skins FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=PlateYellow2 FILE=TEXTURES\Ladr\PlateYellow2.PCX GROUP=Skins FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=PlateYellowCap FILE=TEXTURES\Ladr\PlateYellowCap.PCX GROUP=Skins FLAGS=2 MIPS=OFF 
#exec TEXTURE IMPORT NAME=PlateYellowLowCap FILE=TEXTURES\Ladr\PlateYellowLowCap.PCX GROUP=Skins FLAGS=2 MIPS=OFF

// Background
var texture BG1[4];
var texture BG2[4];
var texture BG3[4];
var string BGName1[4];
var string BGName2[4];
var string BGName3[4];

// Components
var UMenuPlayerMeshClient MeshWindow;
var Class<TournamentPlayer> MaleClass;
var string MaleSkin, MaleFace;
var Class<TournamentPlayer> FemaleClass;
var string FemaleSkin, FemaleFace;

var NotifyButton NameLabel;
var localized string NameText;
var NotifyButton NameButton;
var NameEditBox NameEdit;

var NotifyButton SexLabel;
var localized string SexText;
var NotifyButton SexButton;
var localized string MaleText;
var localized string FemaleText;

var NotifyButton TeamLabel;
var localized string TeamText;
var NotifyButton TeamButton;

var NotifyButton FaceLabel;
var localized string FaceText;
var NotifyButton FaceButton;

var NotifyButton SkillLabel;
var localized string SkillsText;
var NotifyButton SkillButton;
var localized string SkillText[8];
var int CurrentSkill;

var NotifyButton BackButton;
var NotifyButton NextButton;

var NotifyButton TitleButton;
var localized string CCText;

var bool Initialized;

var string FaceDescs[16];
var string Faces[16];

var UTFadeTextArea TeamDescArea;
var NotifyButton Descscrollup;
var NotifyButton Descscrolldown;
var localized string TeamNameString;

// Player
var LadderInventory LadderObj;

var config int PreferredSkill;
var config int PreferredSex;
var config int PreferredTeam;
var config int PreferredFace;

var bool bFlashOn;
var float FlashTime;

function Created()
{
	local string MeshName, SkinDesc, Temp;
	local int i;
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos;
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

	// Check ladder object.
	LadderObj = LadderInventory(GetPlayerOwner().FindInventoryType(class'LadderInventory'));
	if (LadderObj == None)
	{
		Log("NewCharacterWindow: Player has no LadderInventory!!");
	}

	/*
	 * Create components.
	 */

	if (class'UTLadderStub'.Static.IsDemo())
		PreferredTeam = class'Ladder'.Default.NumTeams;

	MaleClass = class'Ladder'.Default.LadderTeams[PreferredTeam].Default.MaleClass;
	MaleSkin = class'Ladder'.Default.LadderTeams[PreferredTeam].Default.MaleSkin;

	FemaleClass = class'Ladder'.Default.LadderTeams[PreferredTeam].Default.FemaleClass;
	FemaleSkin = class'Ladder'.Default.LadderTeams[PreferredTeam].Default.FemaleSkin;

	IterateFaces(MaleSkin, GetPlayerOwner().GetItemName(string(MaleClass.Default.Mesh)));

	LadderObj.Face = PreferredFace;

	// MeshView
	XPos = 608.0/1024 * XMod;
	YPos = 88.0/768 * YMod;
	XWidth = 323.0/1024 * XMod;
	YHeight = 466.0/768 * YMod;
	MeshWindow = UMenuPlayerMeshClient(CreateWindow(class'UMenuPlayerMeshClient', XPos, YPos, XWidth, YHeight));
	MeshWindow.SetMeshString(MaleClass.Default.SelectionMesh);
	MeshWindow.ClearSkins();
	MaleClass.static.SetMultiSkin(MeshWindow.MeshActor, MaleSkin, MaleFace, 255);
	GetPlayerOwner().UpdateURL("Class", "Botpack."$string(MaleClass.Name), True);
	GetPlayerOwner().UpdateURL("Skin", MaleSkin, True);
	GetPlayerOwner().UpdateURL("Face", Faces[PreferredFace], True);
	GetPlayerOwner().UpdateURL("Team", "255", True);
	GetPlayerOwner().UpdateURL("Voice", MaleClass.Default.VoiceType, True);

	// Name Label
	XPos = 164.0/1024 * XMod;
	YPos = 263.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	NameLabel = NotifyButton(CreateWindow(class'NotifyButton', XPos, YPos, XWidth, YHeight));
	NameLabel.NotifyWindow = Self;
	NameLabel.Text = NameText;
	TextColor.R = 255;
	TextColor.G = 255;
	TextColor.B = 0;
	NameLabel.SetTextColor(TextColor);
	NameLabel.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	NameLabel.bStretched = True;
	NameLabel.bDisabled = True;
	NameLabel.bDontSetLabel = True;
	NameLabel.LabelWidth = 178.0/1024 * XMod;
	NameLabel.LabelHeight = 49.0/768 * YMod;

	// Name Button
	XPos = 164.0/1024 * XMod;
	YPos = 295.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	NameButton = NotifyButton(CreateWindow(class'NotifyButton', XPos, YPos, XWidth, YHeight));
	NameButton.NotifyWindow = Self;
	TextColor.R = 255;
	TextColor.G = 255;
	TextColor.B = 0;
	NameButton.SetTextColor(TextColor);
	NameButton.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	NameButton.bStretched = True;
	NameButton.bDisabled = True;
	NameButton.DisabledTexture = Texture(DynamicLoadObject("UTMenu.Plate3Plain", Class'Texture'));
	NameButton.bDontSetLabel = True;
	NameButton.LabelWidth = 178.0/1024 * XMod;
	NameButton.LabelHeight = 49.0/768 * YMod;
	NameButton.OverSound = sound'LadderSounds.lcursorMove';
	NameButton.DownSound = sound'SpeechWindowClick';

	// Name Edit
	XPos = 164.0/1024 * XMod;
	YPos = 295.0/768 * YMod;
	XWidth = 178.0/1024 * XMod;
	YHeight = 49.0/768 * YMod;
	NameEdit = NameEditBox(CreateWindow(class'NameEditBox', XPos, YPos, XWidth, YHeight));
	NameEdit.bDelayedNotify = True;
	NameEdit.SetValue(GetPlayerOwner().PlayerReplicationInfo.PlayerName);
	NameEdit.CharacterWindow = Self;
	NameEdit.bCanEdit = True;
	NameEdit.bShowCaret = True;
	NameEdit.bAlwaysOnTop = True;
	NameEdit.bSelectOnFocus = True;
	NameEdit.MaxLength = 20;
	NameEdit.TextColor.R = 255;
	NameEdit.TextColor.G = 255;
	NameEdit.TextColor.B = 0;

	// Sex Label
	XPos = 164.0/1024 * XMod;
	YPos = 338.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	SexLabel = NotifyButton(CreateWindow(class'NotifyButton', XPos, YPos, XWidth, YHeight));
	SexLabel.NotifyWindow = Self;
	SexLabel.Text = SexText;
	TextColor.R = 255;
	TextColor.G = 255;
	TextColor.B = 0;
	SexLabel.SetTextColor(TextColor);
	SexLabel.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	SexLabel.bStretched = True;
	SexLabel.bDisabled = True;
	SexLabel.bDontSetLabel = True;
	SexLabel.LabelWidth = 178.0/1024 * XMod;
	SexLabel.LabelHeight = 49.0/768 * YMod;

	// Sex Button
	XPos = 164.0/1024 * XMod;
	YPos = 370.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	SexButton = NotifyButton(CreateWindow(class'NotifyButton', XPos, YPos, XWidth, YHeight));
	SexButton.NotifyWindow = Self;
	SexButton.Text = MaleText;
	TextColor.R = 255;
	TextColor.G = 255;
	TextColor.B = 0;
	SexButton.SetTextColor(TextColor);
	SexButton.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	SexButton.bStretched = True;
	SexButton.UpTexture = Texture(DynamicLoadObject("UTMenu.Plate3Plain", Class'Texture'));
	SexButton.DownTexture = Texture(DynamicLoadObject("UTMenu.PlateYellow2", Class'Texture'));
	SexButton.OverTexture = Texture(DynamicLoadObject("UTMenu.Plate2", Class'Texture'));
	SexButton.bDontSetLabel = True;
	SexButton.LabelWidth = 178.0/1024 * XMod;
	SexButton.LabelHeight = 49.0/768 * YMod;
	SexButton.bIgnoreLDoubleclick = True;
	SexButton.OverSound = sound'LadderSounds.lcursorMove';
	SexButton.DownSound = sound'SpeechWindowClick';

	// Team Label
	XPos = 164.0/1024 * XMod;
	YPos = 413.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	TeamLabel = NotifyButton(CreateWindow(class'NotifyButton', XPos, YPos, XWidth, YHeight));
	TeamLabel.NotifyWindow = Self;
	TeamLabel.Text = TeamText;
	TextColor.R = 255;
	TextColor.G = 255;
	TextColor.B = 0;
	TeamLabel.SetTextColor(TextColor);
	TeamLabel.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	TeamLabel.bStretched = True;
	TeamLabel.bDisabled = True;
	TeamLabel.bDontSetLabel = True;
	TeamLabel.LabelWidth = 178.0/1024 * XMod;
	TeamLabel.LabelHeight = 49.0/768 * YMod;

	// Team Button
	XPos = 164.0/1024 * XMod;
	YPos = 445.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	TeamButton = NotifyButton(CreateWindow(class'NotifyButton', XPos, YPos, XWidth, YHeight));
	TeamButton.NotifyWindow = Self;
	TextColor.R = 255;
	TextColor.G = 255;
	TextColor.B = 0;
	TeamButton.SetTextColor(TextColor);
	TeamButton.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	TeamButton.bStretched = True;
	TeamButton.UpTexture = Texture(DynamicLoadObject("UTMenu.Plate3Plain", Class'Texture'));
	TeamButton.DownTexture = Texture(DynamicLoadObject("UTMenu.PlateYellow2", Class'Texture'));
	TeamButton.OverTexture = Texture(DynamicLoadObject("UTMenu.Plate2", Class'Texture'));
	TeamButton.bDontSetLabel = True;
	TeamButton.LabelWidth = 178.0/1024 * XMod;
	TeamButton.LabelHeight = 49.0/768 * YMod;
	TeamButton.bIgnoreLDoubleclick = True;
	if ((PreferredTeam == class'Ladder'.Default.NumTeams) && (!class'UTLadderStub'.Static.IsDemo()))
		PreferredTeam = 0;
	TeamButton.Text = class'Ladder'.Default.LadderTeams[PreferredTeam].Default.TeamName;
	LadderObj.Team = class'Ladder'.Default.LadderTeams[PreferredTeam];
	TeamButton.OverSound = sound'LadderSounds.lcursorMove';
	TeamButton.DownSound = sound'SpeechWindowClick';

	// Face Label
	XPos = 164.0/1024 * XMod;
	YPos = 488.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	FaceLabel = NotifyButton(CreateWindow(class'NotifyButton', XPos, YPos, XWidth, YHeight));
	FaceLabel.NotifyWindow = Self;
	FaceLabel.Text = FaceText;
	TextColor.R = 255;
	TextColor.G = 255;
	TextColor.B = 0;
	FaceLabel.SetTextColor(TextColor);
	FaceLabel.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	FaceLabel.bStretched = True;
	FaceLabel.bDisabled = True;
	FaceLabel.bDontSetLabel = True;
	FaceLabel.LabelWidth = 178.0/1024 * XMod;
	FaceLabel.LabelHeight = 49.0/768 * YMod;

	// Face Button
	XPos = 164.0/1024 * XMod;
	YPos = 520.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	FaceButton = NotifyButton(CreateWindow(class'NotifyButton', XPos, YPos, XWidth, YHeight));
	FaceButton.NotifyWindow = Self;
	FaceButton.Text = FaceDescs[PreferredFace];
	TextColor.R = 255;
	TextColor.G = 255;
	TextColor.B = 0;
	FaceButton.SetTextColor(TextColor);
	FaceButton.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	FaceButton.bStretched = True;
	FaceButton.UpTexture = Texture(DynamicLoadObject("UTMenu.Plate3Plain", Class'Texture'));
	FaceButton.DownTexture = Texture(DynamicLoadObject("UTMenu.PlateYellow2", Class'Texture'));
	FaceButton.OverTexture = Texture(DynamicLoadObject("UTMenu.Plate2", Class'Texture'));
	FaceButton.bDontSetLabel = True;
	FaceButton.LabelWidth = 178.0/1024 * XMod;
	FaceButton.LabelHeight = 49.0/768 * YMod;
	FaceButton.bIgnoreLDoubleclick = True;
	FaceButton.OverSound = sound'LadderSounds.lcursorMove';
	FaceButton.DownSound = sound'SpeechWindowClick';

	// Skill Label
	XPos = 164.0/1024 * XMod;
	YPos = 563.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	SkillLabel = NotifyButton(CreateWindow(class'NotifyButton', XPos, YPos, XWidth, YHeight));
	SkillLabel.NotifyWindow = Self;
	SkillLabel.Text = SkillsText;
	TextColor.R = 255;
	TextColor.G = 255;
	TextColor.B = 0;
	SkillLabel.SetTextColor(TextColor);
	SkillLabel.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	SkillLabel.bStretched = True;
	SkillLabel.bDisabled = True;
	SkillLabel.bDontSetLabel = True;
	SkillLabel.LabelWidth = 178.0/1024 * XMod;
	SkillLabel.LabelHeight = 49.0/768 * YMod;

	// Skill Button
	XPos = 164.0/1024 * XMod;
	YPos = 595.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	SkillButton = NotifyButton(CreateWindow(class'NotifyButton', XPos, YPos, XWidth, YHeight));
	SkillButton.NotifyWindow = Self;
	SkillButton.Text = SkillText[1];
	CurrentSkill = 1;
	TextColor.R = 255;
	TextColor.G = 255;
	TextColor.B = 0;
	SkillButton.SetTextColor(TextColor);
	SkillButton.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	SkillButton.bStretched = True;
	SkillButton.UpTexture = Texture(DynamicLoadObject("UTMenu.Plate3Plain", Class'Texture'));
	SkillButton.DownTexture = Texture(DynamicLoadObject("UTMenu.PlateYellow2", Class'Texture'));
	SkillButton.OverTexture = Texture(DynamicLoadObject("UTMenu.Plate2", Class'Texture'));
	SkillButton.bDontSetLabel = True;
	SkillButton.LabelWidth = 178.0/1024 * XMod;
	SkillButton.LabelHeight = 49.0/768 * YMod;
	SkillButton.bIgnoreLDoubleclick = True;
	CurrentSkill = PreferredSkill;
	SkillButton.Text = SkillText[CurrentSkill];
	LadderObj.TournamentDifficulty = CurrentSkill;
	LadderObj.SkillText = SkillText[LadderObj.TournamentDifficulty];
	SkillButton.OverSound = sound'LadderSounds.lcursorMove';
	SkillButton.DownSound = sound'SpeechWindowClick';

	// Title Button
	XPos = 84.0/1024 * XMod;
	YPos = 69.0/768 * YMod;
	XWidth = 342.0/1024 * XMod;
	YHeight = 41.0/768 * YMod;
	TitleButton = NotifyButton(CreateWindow(class'NotifyButton', XPos, YPos, XWidth, YHeight));
	TitleButton.NotifyWindow = Self;
	TitleButton.Text = CCText;
	TextColor.R = 255;
	TextColor.G = 255;
	TextColor.B = 0;
	TitleButton.SetTextColor(TextColor);
	TitleButton.MyFont = class'UTLadderStub'.Static.GetHugeFont(Root);
	TitleButton.bStretched = True;

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

	// Team Desc
	XPos = 609.0/1024 * XMod;
	YPos = 388.0/768 * YMod;
	XWidth = 321.0/1024 * XMod;
	YHeight = 113.0/768 * YMod;
	TeamDescArea = UTFadeTextArea(CreateWindow(Class<UWindowWindow>(DynamicLoadObject("UTMenu.UTFadeTextArea", Class'Class')), XPos, YPos, XWidth, YHeight));
	TeamDescArea.TextColor.R = 255;
	TeamDescArea.TextColor.G = 255;
	TeamDescArea.TextColor.B = 0;
	TeamDescArea.MyFont = class'UTLadderStub'.Static.GetSmallFont(Root);
	TeamDescArea.bAlwaysOnTop = True;
	TeamDescArea.bMousePassThrough = True;
	TeamDescArea.bAutoScrolling = True;
	TeamDescArea.Clear();
	TeamDescArea.AddText(TeamNameString@LadderObj.Team.Static.GetTeamName());
	TeamDescArea.AddText(" ");
	TeamDescArea.AddText(LadderObj.Team.Static.GetTeamBio());

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

	if (PreferredSex == 1)
	{
		LadderObj.Sex = "F";
		SexButton.Text = MaleText;
	} else {
		LadderObj.Sex = "M";
		SexButton.Text = FemaleText;
	}
	SexPressed();

	Initialized = True;
	Root.Console.bBlackout = True;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int i;
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos;

	Super.BeforePaint(C, X, Y);

	class'UTLadderStub'.Static.SetupWinParams(Self, Root, W, H);

	XMod = 4*W;
	YMod = 3*H;

	// Mesh View
	XPos = 608.0/1024 * XMod;
	YPos = 88.0/768 * YMod;
	XWidth = 323.0/1024 * XMod;
	YHeight = 466.0/768 * YMod;
	MeshWindow.SetSize(XWidth, YHeight);
	MeshWindow.WinLeft = XPos;
	MeshWindow.WinTop = YPos;

	// Name Label
	XPos = 164.0/1024 * XMod;
	YPos = 263.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	NameLabel.SetSize(XWidth, YHeight);
	NameLabel.WinLeft = XPos;
	NameLabel.WinTop = YPos;
	NameLabel.LabelWidth = 178/1024 * XMod;
	NameLabel.LabelHeight = 49/768 * YMod;
	NameLabel.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);

	// Name Button
	XPos = 164.0/1024 * XMod;
	YPos = 295.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	NameButton.SetSize(XWidth, YHeight);
	NameButton.WinLeft = XPos;
	NameButton.WinTop = YPos;
	NameButton.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);

	// Name Edit
	XPos = 164.0/1024 * XMod;
	YPos = 295.0/768 * YMod;
	XWidth = 178.0/1024 * XMod;
	YHeight = 49.0/768 * YMod;
	NameEdit.SetSize(XWidth, YHeight);
	NameEdit.WinLeft = XPos;
	NameEdit.WinTop = YPos;

	// Sex Label
	XPos = 164.0/1024 * XMod;
	YPos = 338.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	SexLabel.SetSize(XWidth, YHeight);
	SexLabel.WinLeft = XPos;
	SexLabel.WinTop = YPos;
	SexLabel.LabelWidth = 178.0/1024 * XMod;
	SexLabel.LabelHeight = 49.0/768 * YMod;
	SexLabel.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);

	// Sex Button
	XPos = 164.0/1024 * XMod;
	YPos = 370.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	SexButton.SetSize(XWidth, YHeight);
	SexButton.WinLeft = XPos;
	SexButton.WinTop = YPos;
	SexButton.LabelWidth = 178.0/1024 * XMod;
	SexButton.LabelHeight = 52.0/768 * YMod;
	SexButton.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);

	// Team Label
	XPos = 164.0/1024 * XMod;
	YPos = 413.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	TeamLabel.SetSize(XWidth, YHeight);
	TeamLabel.WinLeft = XPos;
	TeamLabel.WinTop = YPos;
	TeamLabel.LabelWidth = 178.0/1024 * XMod;
	TeamLabel.LabelHeight = 49.0/768 * YMod;
	TeamLabel.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);

	// Team Button
	XPos = 164.0/1024 * XMod;
	YPos = 445.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	TeamButton.SetSize(XWidth, YHeight);
	TeamButton.WinLeft = XPos;
	TeamButton.WinTop = YPos;
	TeamButton.LabelWidth = 178/1024 * XMod;
	TeamButton.LabelHeight = 49/768 * YMod;
	TeamButton.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);

	// Face Label
	XPos = 164.0/1024 * XMod;
	YPos = 488.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	FaceLabel.SetSize(XWidth, YHeight);
	FaceLabel.WinLeft = XPos;
	FaceLabel.WinTop = YPos;
	FaceLabel.LabelWidth = 178/1024 * XMod;
	FaceLabel.LabelHeight = 49/768 * YMod;
	FaceLabel.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);

	// Face Button
	XPos = 164.0/1024 * XMod;
	YPos = 520.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	FaceButton.SetSize(XWidth, YHeight);
	FaceButton.WinLeft = XPos;
	FaceButton.WinTop = YPos;
	FaceButton.LabelWidth = 178/1024 * XMod;
	FaceButton.LabelHeight = 49/768 * YMod;
	FaceButton.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);

	// Skill Label
	XPos = 164.0/1024 * XMod;
	YPos = 563.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	SkillLabel.SetSize(XWidth, YHeight);
	SkillLabel.WinLeft = XPos;
	SkillLabel.WinTop = YPos;
	SkillLabel.LabelWidth = 178/1024 * XMod;
	SkillLabel.LabelHeight = 49/768 * YMod;
	SkillLabel.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);

	// Skill Button
	XPos = 164.0/1024 * XMod;
	YPos = 595.0/768 * YMod;
	XWidth = 256.0/1024 * XMod;
	YHeight = 64.0/768 * YMod;
	SkillButton.SetSize(XWidth, YHeight);
	SkillButton.WinLeft = XPos;
	SkillButton.WinTop = YPos;
	SkillButton.LabelWidth = 178/1024 * XMod;
	SkillButton.LabelHeight = 49/768 * YMod;
	SkillButton.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);

	// Title Button
	XPos = 84.0/1024 * XMod;
	YPos = 69.0/768 * YMod;
	XWidth = 342.0/1024 * XMod;
	YHeight = 41.0/768 * YMod;
	TitleButton.SetSize(XWidth, YHeight);
	TitleButton.WinLeft = XPos;
	TitleButton.WinTop = YPos;
	TitleButton.MyFont = class'UTLadderStub'.Static.GetHugeFont(Root);

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

	// Team Desc
	XPos = 609.0/1024 * XMod;
	YPos = 388.0/768 * YMod;
	XWidth = 321.0/1024 * XMod;
	YHeight = 113.0/768 * YMod;
	TeamDescArea.SetSize(XWidth, YHeight);
	TeamDescArea.WinLeft = XPos;
	TeamDescArea.WinTop = YPos;
	TeamDescArea.MyFont = class'UTLadderStub'.Static.GetSmallFont(Root);

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

function Tick(float Delta)
{
	Super.Tick(Delta);

	FlashTime += Delta;
	if (FlashTime > 1)
	{
		FlashTime = 0;
		if (bFlashOn)
		{
			NextButton.UpTexture = Texture(DynamicLoadObject("UTMenu.RightUp", Class'Texture'));
			bFlashOn = False;
		} else {
			NextButton.UpTexture = Texture(DynamicLoadObject("UTMenu.RightOver", Class'Texture'));
			bFlashOn = True;
		}
	}
}

function Paint(Canvas C, float X, float Y)
{
	local int XOffset, YOffset;
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos;

	class'UTLadderStub'.Static.SetupWinParams(Self, Root, W, H);

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

	if (Root.WinWidth > 500)
	{
		DrawStretchedTexture(C, XOffset + (0 * W), YOffset + (0 * H), (W+1)/2, (H+1)/2, texture'TeamPlate');
		DrawStretchedTexture(C, XOffset + (0 * W) + (65.0/1024*XMod), YOffset + (0 * H) + (61.0/768*YMod), (58.0/1024*XMod), (57.0/768*YMod), class'Ladder'.Default.LadderTeams[PreferredTeam].Default.TeamSymbol);
	}
}

function Notify(UWindowWindow B, byte E)
{
	switch (E)
	{
		case DE_DoubleClick:
		case DE_Click:
			switch (B)
			{
				case SexButton:
					SexPressed();
					break;
				case TeamButton:
					TeamPressed();
					break;
				case FaceButton:
					FacePressed();
					break;
				case SkillButton:
					SkillPressed();
					break;
				case NextButton:
					NextPressed();
					break;
				case BackButton:
					BackPressed();
					break;
				case DescScrollup:
					TeamDescArea.ScrollingOffset--;
					if (TeamDescArea.ScrollingOffset < 0)
						TeamDescArea.ScrollingOffset = 0;
					break;
				case DescScrolldown:
					TeamDescArea.ScrollingOffset++;
					if (TeamDescArea.ScrollingOffset > 10)
						TeamDescArea.ScrollingOffset = 10;
					break;
			}
			break;
		case DE_Change:
			switch (B)
			{
				case NameEdit:
					NameChanged();
					break;
			}
			break;
	}
}

function NameChanged()
{
	local string N;
	if (Initialized)
	{
		Initialized = False;
		N = NameEdit.GetValue();
		ReplaceText(N, " ", "_");
		NameEdit.SetValue(N);
		Initialized = True;

		GetPlayerOwner().ChangeName(NameEdit.GetValue());
		GetPlayerOwner().UpdateURL("Name", NameEdit.GetValue(), True);
	}
}

function SexPressed()
{
	local int CurrentSex;
	local string MeshName;

	if (SexButton.Text ~= MaleText)
	{
		PreferredSex = 0;
		LadderObj.Sex = "M";
		if (FemaleClass == None)
			return;

		SexButton.Text = FemaleText;

		IterateFaces(FemaleSkin, GetPlayerOwner().GetItemName(string(FemaleClass.Default.Mesh)));

		// Make player female.
		MeshName = FemaleClass.Default.SelectionMesh;
		MeshWindow.SetMeshString(MeshName);
		FemaleClass.static.SetMultiSkin(MeshWindow.MeshActor, FemaleSkin, Faces[PreferredFace], 255);
		GetPlayerOwner().UpdateURL("Class", "Botpack."$string(FemaleClass.Name), True);
		GetPlayerOwner().UpdateURL("Skin", FemaleSkin, True);
		GetPlayerOwner().UpdateURL("Voice", FemaleClass.Default.VoiceType, True);
		CurrentSex = 1;
		GetPlayerOwner().UpdateURL("Face", Faces[PreferredFace], True);

		FaceButton.Text = FaceDescs[PreferredFace];

		LadderObj.Sex = "F";
	} else {
		PreferredSex = 1;
		LadderObj.Sex = "F";
		if (MaleClass == None)
			return;

		SexButton.Text = MaleText;

		IterateFaces(MaleSkin, GetPlayerOwner().GetItemName(string(MaleClass.Default.Mesh)));

		// Make player male.
		MeshName = MaleClass.Default.SelectionMesh;
		MeshWindow.SetMeshString(MeshName);
		MaleClass.static.SetMultiSkin(MeshWindow.MeshActor, MaleSkin, Faces[PreferredFace], 255);
		GetPlayerOwner().UpdateURL("Class", "Botpack."$string(MaleClass.Name), True);
		GetPlayerOwner().UpdateURL("Skin", MaleSkin, True);
		GetPlayerOwner().UpdateURL("Voice", MaleClass.Default.VoiceType, True);
		GetPlayerOwner().UpdateURL("Face", Faces[PreferredFace], True);
		CurrentSex = 0;

		FaceButton.Text = FaceDescs[PreferredFace];

		LadderObj.Sex = "M";
	}
	PreferredSex = CurrentSex;
	SaveConfig();
}

function FacePressed()
{
	PreferredFace++;
	if (Faces[PreferredFace] == "")
		PreferredFace = 0;
	FaceButton.Text = FaceDescs[PreferredFace];
	if (SexButton.Text ~= MaleText)
	{
		MaleClass.static.SetMultiSkin(MeshWindow.MeshActor, MaleSkin, Faces[PreferredFace], 255);
		GetPlayerOwner().UpdateURL("Face", Faces[PreferredFace], True);
	} else {
		FemaleClass.static.SetMultiSkin(MeshWindow.MeshActor, FemaleSkin, Faces[PreferredFace], 255);
		GetPlayerOwner().UpdateURL("Face", Faces[PreferredFace], True);
	}

	LadderObj.Face = PreferredFace;
	SaveConfig();
}

function TeamPressed()
{
	local string MeshName;

	if (!class'UTLadderStub'.Static.IsDemo())
	{
		PreferredTeam++;
		if (PreferredTeam == class'Ladder'.Default.NumTeams)
			PreferredTeam = 0;
	}
	TeamButton.Text = class'Ladder'.Default.LadderTeams[PreferredTeam].Default.TeamName;
	LadderObj.Team = class'Ladder'.Default.LadderTeams[PreferredTeam];

	// Update mesh
	MaleClass = class'Ladder'.Default.LadderTeams[PreferredTeam].Default.MaleClass;
	MaleSkin = class'Ladder'.Default.LadderTeams[PreferredTeam].Default.MaleSkin;
	FemaleClass = class'Ladder'.Default.LadderTeams[PreferredTeam].Default.FemaleClass;
	FemaleSkin = class'Ladder'.Default.LadderTeams[PreferredTeam].Default.FemaleSkin;

	if ((MaleClass == None) && (SexButton.Text ~= MaleText))
		TeamPressed();
	if ((FemaleClass == None) && (SexButton.Text ~= FemaleText))
		TeamPressed();

	if (SexButton.Text ~= MaleText)
	{
		IterateFaces(MaleSkin, GetPlayerOwner().GetItemName(string(MaleClass.Default.Mesh)));

		PreferredFace = 0;

		MeshName = MaleClass.Default.SelectionMesh;
		MeshWindow.SetMeshString(MeshName);
		MaleClass.static.SetMultiSkin(MeshWindow.MeshActor, MaleSkin, Faces[PreferredFace], 255);
		GetPlayerOwner().UpdateURL("Class", string(MaleClass), True);
		GetPlayerOwner().UpdateURL("Voice", MaleClass.Default.VoiceType, True);
		GetPlayerOwner().UpdateURL("Skin", MaleSkin, True);
		GetPlayerOwner().UpdateURL("Face", Faces[PreferredFace], True);

		FaceButton.Text = FaceDescs[PreferredFace];
		SexButton.Text = MaleText;
		PreferredSex = 0;
		LadderObj.Sex = "M";
	} else {
		IterateFaces(FemaleSkin, GetPlayerOwner().GetItemName(string(FemaleClass.Default.Mesh)));

		PreferredFace = 0;

		MeshName = FemaleClass.Default.SelectionMesh;
		MeshWindow.SetMeshString(MeshName);
		FemaleClass.static.SetMultiSkin(MeshWindow.MeshActor, FemaleSkin, Faces[PreferredFace], 255);
		GetPlayerOwner().UpdateURL("Class", string(FemaleClass), True);
		GetPlayerOwner().UpdateURL("Voice", FemaleClass.Default.VoiceType, True);
		GetPlayerOwner().UpdateURL("Skin", FemaleSkin, True);
		GetPlayerOwner().UpdateURL("Face", Faces[PreferredFace], True);

		FaceButton.Text = FaceDescs[PreferredFace];
		SexButton.Text = FemaleText;
		PreferredSex = 1;
		LadderObj.Sex = "F";
	}

	TeamDescArea.Clear();
	TeamDescArea.AddText(TeamNameString@LadderObj.Team.Static.GetTeamName());
	TeamDescArea.AddText(" ");
	TeamDescArea.AddText(LadderObj.Team.Static.GetTeamBio());

	SaveConfig();
}

function SkillPressed()
{
	CurrentSkill++;
	if (CurrentSkill == 8)
		CurrentSkill = 0;
	SkillButton.Text = SkillText[CurrentSkill];
	LadderObj.TournamentDifficulty = CurrentSkill;
	LadderObj.SkillText = SkillText[LadderObj.TournamentDifficulty];
	PreferredSkill = CurrentSkill;
	SaveConfig();
}

function BackPressed()
{
	Close();
}

function NextPressed()
{
	local int i;
	local ManagerWindow ManagerWindow;

	if (LadderObj.Sex ~= "F")
	{
		SexButton.Text = MaleText;
	} else {
		SexButton.Text = FemaleText;
	}
	SexPressed();

	// Go to the ladder selection screen.
	LadderObj.DMRank = 0;
	LadderObj.DMPosition = -1;
	LadderObj.CTFRank = 0;
	LadderObj.CTFPosition = -1;
	LadderObj.DOMRank = 0;
	LadderObj.DOMPosition = -1;
	LadderObj.ASRank = 0;
	LadderObj.ASPosition = -1;
	LadderObj.ChalRank = 0;
	LadderObj.ChalPosition = 0;

	LadderObj = None;
	Super.Close();
	ManagerWindow = ManagerWindow(Root.CreateWindow(class'ManagerWindow', 100, 100, 200, 200, Root, True));
}

function Close(optional bool bByParent)
{
	LadderObj = None;
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
	CCText="   Character Creation"
	NameText="Name"
	SexText="Gender"
	TeamText="Team"
	FaceText="Face"
	SkillsText="Skill"
	MaleText="Male"
	FemaleText="Female"
	SkillText(0)="Novice"
	SkillText(1)="Average"
	SkillText(2)="Experienced"
	SkillText(3)="Skilled"
	SkillText(4)="Adept"
	SkillText(5)="Masterful"
	SkillText(6)="Inhuman"
	SkillText(7)="Godlike"
	BGName1(0)="UTMenu.CC11"
	BGName1(1)="UTMenu.CC12"
	BGName1(2)="UTMenu.CC13"
	BGName1(3)="UTMenu.CC14"
	BGName2(0)="UTMenu.CC21"
	BGName2(1)="UTMenu.CC22"
	BGName2(2)="UTMenu.CC23"
	BGName2(3)="UTMenu.CC24"
	BGName3(0)="UTMenu.CC31"
	BGName3(1)="UTMenu.CC32"
	BGName3(2)="UTMenu.CC33"
	BGName3(3)="UTMenu.CC34"
	PreferredSex=0
	PreferredSkill=1
	PreferredTeam=0
	PreferredFace=0
	TeamNameString="Team Name:"
}
