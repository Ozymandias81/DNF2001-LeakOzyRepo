class UMenuPlayerSetupClient extends UMenuDialogClientWindow;

var() int ControlOffset;

var class<Pawn> NewPlayerClass;
var string MeshName;
var bool Initialized;
var UMenuPlayerMeshClient MeshWindow;
var string PlayerBaseClass;

// Player Name
var UWindowEditControl NameEdit;
var localized string NameText;
var localized string NameHelp;

// Team Combo
var UWindowComboControl TeamCombo;
var localized string TeamText;
var localized string Teams[4];
var localized string NoTeam;
var localized string TeamHelp;

// Class Combo
var UWindowComboControl ClassCombo;
var localized string ClassText;
var localized string ClassHelp;

// Skin Combo
var UWindowComboControl SkinCombo;
var localized string SkinText;
var localized string SkinHelp;

// Face Combo
var UWindowComboControl FaceCombo;
var localized string FaceText;
var localized string FaceHelp;

function Created()
{
	local string SkinName, FaceName;

	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local int I;
	
	MeshWindow = UMenuPlayerMeshClient(UMenuPlayerClientWindow(ParentWindow.ParentWindow.ParentWindow).Splitter.RightClientWindow);

	Super.Created();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	NewPlayerClass = GetPlayerOwner().Class;

	// Player Name
	NameEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', CenterPos, ControlOffset, CenterWidth, 1));
	NameEdit.SetText(NameText);
	NameEdit.SetHelpText(NameHelp);
	NameEdit.SetFont(F_Normal);
	NameEdit.SetNumericOnly(False);
	NameEdit.SetMaxLength(20);
	NameEdit.SetDelayedNotify(True);

	// Team
	ControlOffset += 25;
	TeamCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	TeamCombo.SetText(TeamText);
	TeamCombo.SetHelpText(TeamHelp);
	TeamCombo.SetFont(F_Normal);
	TeamCombo.SetEditable(False);
	TeamCombo.AddItem(NoTeam, String(255));
	for (I=0; I<4; I++)
		TeamCombo.AddItem(Teams[I], String(i));

	ControlOffset += 25;
	// Load Classes
	ClassCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	ClassCombo.SetText(ClassText);
	ClassCombo.SetHelpText(ClassHelp);
	ClassCombo.SetEditable(False);
	ClassCombo.SetFont(F_Normal);

	// Skin
	ControlOffset += 25;
	SkinCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	SkinCombo.SetText(SkinText);
	SkinCombo.SetHelpText(SkinHelp);
	SkinCombo.SetFont(F_Normal);
	SkinCombo.SetEditable(False);

	ControlOffset += 25;
	FaceCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	FaceCombo.SetText(FaceText);
	FaceCombo.SetHelpText(FaceHelp);
	FaceCombo.SetFont(F_Normal);
	FaceCombo.SetEditable(False);

	LoadClasses();
}


function AfterCreate()
{
	Super.AfterCreate();

	DesiredWidth = 220;
	DesiredHeight = ControlOffset + 25;

	LoadCurrent();
	UseSelected();
		
	Initialized = True;
}

function LoadClasses()
{
	local int NumPlayerClasses;
	local string NextPlayer, NextDesc;
	local int SortWeight;

	GetPlayerOwner().GetNextIntDesc(PlayerBaseClass, 0, NextPlayer, NextDesc);
	while( (NextPlayer != "") && (NumPlayerClasses < 64) )
	{
		ClassCombo.AddItem(NextDesc, NextPlayer, SortWeight);
		NumPlayerClasses++;
		GetPlayerOwner().GetNextIntDesc(PlayerBaseClass, NumPlayerClasses, NextPlayer, NextDesc);
	}
	ClassCombo.Sort();
}

function LoadCurrent()
{
	local string SN, FN;

	NameEdit.SetValue(GetPlayerOwner().PlayerReplicationInfo.PlayerName);
	TeamCombo.SetSelectedIndex(Max(TeamCombo.FindItemIndex2(string(GetPlayerOwner().PlayerReplicationInfo.Team)), 0));
	if(GetLevel().Game != None && GetLevel().Game.IsA('UTIntro'))
	{
		SN = GetPlayerOwner().GetDefaultURL("Skin");
		FN = GetPlayerOwner().GetDefaultURL("Face");
		ClassCombo.SetSelectedIndex(Max(ClassCombo.FindItemIndex2(GetPlayerOwner().GetDefaultURL("Class"), True), 0));
	}
	else
	{
		ClassCombo.SetSelectedIndex(Max(ClassCombo.FindItemIndex2(string(GetPlayerOwner().Class), True), 0));
		GetPlayerOwner().static.GetMultiSkin(GetPlayerOwner(), SN, FN);
	}
	SkinCombo.SetSelectedIndex(Max(SkinCombo.FindItemIndex2(SN, True), 0));
	FaceCombo.SetSelectedIndex(Max(FaceCombo.FindItemIndex2(FN, True), 0));
}

function SaveConfigs()
{
	Super.SaveConfigs();
	GetPlayerOwner().SaveConfig();
	GetPlayerOwner().PlayerReplicationInfo.SaveConfig();
}

function IterateSkins()
{
	local string SkinName, SkinDesc, TestName, Temp, FaceName;
	local int i;
	local bool bNewFormat;

	SkinCombo.Clear();

	if( ClassIsChildOf(NewPlayerClass, class'Spectator') )
	{
		SkinCombo.HideWindow();
		return;
	}
	else
		SkinCombo.ShowWindow();

	bNewFormat = NewPlayerClass.default.bIsMultiSkinned;

	SkinName = "None";
	TestName = "";
	while ( True )
	{
		GetPlayerOwner().GetNextSkin(MeshName, SkinName, 1, SkinName, SkinDesc);

		if( SkinName == TestName )
			break;

		if( TestName == "" )
			TestName = SkinName;

		if( !bNewFormat )
		{
			Temp = GetPlayerOwner().GetItemName(SkinName);
			if( Left(Temp, 2) != "T_" )
				SkinCombo.AddItem(Temp, SkinName);
		}
		else
		{
			// Multiskin format
			if( SkinDesc != "")
			{			
				Temp = GetPlayerOwner().GetItemName(SkinName);
				if(Mid(Temp, 5, 64) == "")
					// This is a skin
					SkinCombo.AddItem(SkinDesc, Left(SkinName, Len(SkinName) - Len(Temp)) $ Left(Temp, 4));			
			}
		}
	}
	SkinCombo.Sort();
}

function IterateFaces(string InSkinName)
{
	local string SkinName, SkinDesc, TestName, Temp, FaceName;
	local bool bNewFormat;

	FaceCombo.Clear();

	// New format only
	if( !NewPlayerClass.default.bIsMultiSkinned )
	{
		FaceCombo.HideWindow();
		return;
	}
	else
		FaceCombo.ShowWindow();


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
				FaceCombo.AddItem(SkinDesc, Left(SkinName, Len(SkinName) - Len(Temp)) $ Mid(Temp, 5));
		}
	}
	FaceCombo.Sort();
}


function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local float W;

	W = Min(WinWidth, 220);

	ControlWidth = W/3;
	ControlLeft = (W/2 - ControlWidth)/2;
	ControlRight = W/2 + ControlLeft;

	CenterWidth = (W/7)*6;
	CenterPos = (W - CenterWidth)/2;

	NameEdit.SetSize(CenterWidth, 1);
	NameEdit.WinLeft = CenterPos;
	NameEdit.EditBoxWidth = 105;

	TeamCombo.SetSize(CenterWidth, 1);
	TeamCombo.WinLeft = CenterPos;
	TeamCombo.EditBoxWidth = 105;

	SkinCombo.SetSize(CenterWidth, 1);
	SkinCombo.WinLeft = CenterPos;
	SkinCombo.EditBoxWidth = 105;

	FaceCombo.SetSize(CenterWidth, 1);
	FaceCombo.WinLeft = CenterPos;
	FaceCombo.EditBoxWidth = 105;

	ClassCombo.SetSize(CenterWidth, 1);
	ClassCombo.WinLeft = CenterPos;
	ClassCombo.EditBoxWidth = 105;

}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
			case NameEdit:
				NameChanged();
				break;
			case TeamCombo:
				TeamChanged();
				break;
			case SkinCombo:
				SkinChanged();
				break;
			case ClassCombo:
				ClassChanged();
				break;
			case FaceCombo:
				FaceChanged();
				break;
		}
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

function TeamChanged()
{
	if (Initialized)
		UseSelected();
}

function SkinChanged()
{
	local bool OldInitialized;

	OldInitialized = Initialized;
	Initialized = False;
	IterateFaces(SkinCombo.GetValue2());
	FaceCombo.SetSelectedIndex(0);
	Initialized = OldInitialized;

	if (Initialized)
		UseSelected();
}

function FaceChanged()
{
	if (Initialized)
		UseSelected();
}

function ClassChanged()
{
	local string SkinName, SkinDesc;
	local bool OldInitialized;

	// Get the class.
	NewPlayerClass = class<Pawn>(DynamicLoadObject(ClassCombo.GetValue2(), class'Class'));

	// Get the meshname
	MeshName = GetPlayerOwner().GetItemName(String(NewPlayerClass.Default.Mesh));

	OldInitialized = Initialized;
	Initialized = False;

	IterateSkins();
	SkinCombo.SetSelectedIndex(0);
	IterateFaces(SkinCombo.GetValue2());
	FaceCombo.SetSelectedIndex(0);
	Initialized = OldInitialized;

	if (Initialized)
		UseSelected();
}


function UseSelected()
{
	local int NewTeam;

	if (Initialized)
	{
		GetPlayerOwner().UpdateURL("Class", ClassCombo.GetValue2(), True);
		GetPlayerOwner().UpdateURL("Skin", SkinCombo.GetValue2(), True);
		GetPlayerOwner().UpdateURL("Face", FaceCombo.GetValue2(), True);
		GetPlayerOwner().UpdateURL("Team", TeamCombo.GetValue2(), True);

		NewTeam = Int(TeamCombo.GetValue2());

		// if the same class as current class, change skin
		if( ClassCombo.GetValue2() ~= String( GetPlayerOwner().Class ))
			GetPlayerOwner().ServerChangeSkin(SkinCombo.GetValue2(), FaceCombo.GetValue2(), NewTeam);

		if( GetPlayerOwner().PlayerReplicationInfo.Team != NewTeam )
			GetPlayerOwner().ChangeTeam(NewTeam);
	}

	MeshWindow.SetMeshString(NewPlayerClass.Default.SelectionMesh);
	MeshWindow.ClearSkins();
	NewPlayerClass.static.SetMultiSkin(MeshWindow.MeshActor, SkinCombo.GetValue2(), FaceCombo.GetValue2(), Int(TeamCombo.GetValue2()));
}

defaultproperties
{
	NameText="Name:"
	NameHelp="Set your player name."
	TeamText="Team:"
	TeamHelp="Select the team you wish to play on."
	SkinText="Skin:"
	SkinHelp="Choose a skin for your player."
	FaceText="Face:"
	FaceHelp="Choose a face for your player."
	ClassText="Class:"
	ClassHelp="Select your player class."
	Teams(0)="Red"
	Teams(1)="Blue"
	Teams(2)="Green"
	Teams(3)="Gold"
	NoTeam="None"
	PlayerBaseClass="UnrealiPlayer"
	ControlOffset=25
}