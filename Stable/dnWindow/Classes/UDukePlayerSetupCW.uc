/*-----------------------------------------------------------------------------
	UDukePlayerSetupCW
	Author: Scott Alden, Brandon Reinhart
-----------------------------------------------------------------------------*/
class UDukePlayerSetupCW extends UDukePageWindow;

var() int ControlOffset;

var		class<Pawn>             NewPlayerClass;
var		string                  MeshName;
var		bool                    Initialized;
var		UDukePlayerMeshCW       MeshWindow;
var		string                  PlayerBaseClass;
var		bool                    bInNotify;
var		class<dnVoicePack>		VoicePackClass;

// Player Name
var UWindowLabelControl			NameLabel;
var UWindowEditControl			NameEdit;
var localized string			NameText;
var localized string			NameHelp;
                            
// Sex Combo              
var UWindowLabelControl			SexLabel;
var UWindowComboControl			SexCombo;
var localized string			SexText;
var localized string			SexHelp;
                            
// Mesh Combo
var UWindowLabelControl			MeshLabel;
var UWindowComboControl			MeshCombo;
var localized string			MeshText;
var localized string			MeshHelp;
                                                      
// Face Combo
var UWindowLabelControl			FaceLabel;
var UWindowComboControl			FaceCombo;
var localized string			FaceText;
var localized string			FaceHelp;

// Torso Skin Combo
var UWindowLabelControl			TorsoLabel;
var UWindowComboControl			TorsoCombo;
var localized string			TorsoText;
var localized string			TorsoHelp;

// Arms Skin Combo
var UWindowLabelControl			ArmsLabel;
var UWindowComboControl			ArmsCombo;
var localized string			ArmsText;
var localized string			ArmsHelp;

// Legs Skin Combo
var UWindowLabelControl			LegsLabel; 
var UWindowComboControl			LegsCombo;
var localized string			LegsText;
var localized string			LegsHelp;

// Icon
var UWindowLabelControl			IconLabel;
var UWindowComboControl			IconCombo;
var localized string			IconText;
var localized string			IconHelp;

// Voice
var UWindowLabelControl			VoiceLabel;
var UWindowComboControl			VoiceCombo;
var localized string			VoiceText;
var localized string			VoiceHelp;

// Hit Notification Sound
var UWindowLabelControl			HitSoundLabel;
var UWindowComboControl			HitSoundCombo;
var localized string			HitSoundText;
var localized string			HitSoundHelp;

// Test Sound
var UWindowSmallButton			TestVoiceButton;
var localized string		    TestVoiceText;
var localized string			TestVoiceHelp;

// Test Hit Sound
var UWindowSmallButton			TestHitButton;
var localized string			TestHitText;
var localized string			TestHitHelp;

// Spectator
var UWindowLabelControl			SpectatorLabel;
var UWindowCheckbox				SpectatorCheck;
var localized string			SpectatorText;
var localized string			SpectatorHelp;

function Created()
{
	local string SkinName, FaceName;
	
    MeshWindow = UDukePlayerMeshCW( UDukePlayerSetupTopCW( ParentWindow.ParentWindow.ParentWindow).Splitter.RightClientWindow );

	Super.Created();

	// Player Name
	NameLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	NameLabel.SetText(NameText);
	NameLabel.SetFont(F_Normal);
	NameLabel.Align = TA_Right;

	NameEdit = UWindowEditControl( CreateControl( class'UWindowEditControl', 1, 1, 1, 1 ) );
	NameEdit.SetHelpText( NameHelp );
	NameEdit.SetFont( F_Normal );
	NameEdit.SetNumericOnly( false );
	NameEdit.SetMaxLength( 20 );
	NameEdit.SetDelayedNotify( true );
	NameEdit.Align = TA_Right;

	// Sex
	SexLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	SexLabel.SetText(SexText);
	SexLabel.SetFont(F_Normal);
	SexLabel.Align = TA_Right;

	SexCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 1, 1, 1, 1));
	SexCombo.SetHelpText( SexHelp );
	SexCombo.SetEditable( false );
	SexCombo.SetFont( F_Normal );
	SexCombo.Align = TA_Right;

    // Sounds
	VoiceLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	VoiceLabel.SetText(VoiceText);
	VoiceLabel.SetFont(F_Normal);
	VoiceLabel.Align = TA_Right;

	VoiceCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 1, 1, 1, 1));
	VoiceCombo.SetHelpText( VoiceHelp );
	VoiceCombo.SetEditable( false );
	VoiceCombo.SetFont( F_Normal );
	VoiceCombo.Align = TA_Right;

    // Meshes
	MeshLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	MeshLabel.SetText(MeshText);
	MeshLabel.SetFont(F_Normal);
	MeshLabel.Align = TA_Right;

	MeshCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 1, 1, 1, 1));
	MeshCombo.SetHelpText( MeshHelp );
	MeshCombo.SetEditable( false );
	MeshCombo.SetFont( F_Normal );
	MeshCombo.Align = TA_Right;

    // Faces
	FaceLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	FaceLabel.SetText(FaceText);
	FaceLabel.SetFont(F_Normal);
	FaceLabel.Align = TA_Right;

	FaceCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 1, 1, 1, 1));
	FaceCombo.SetHelpText( FaceHelp );
	FaceCombo.SetFont( F_Normal );
	FaceCombo.SetEditable( false );
	FaceCombo.Align = TA_Right;

	// Torso Skin
	TorsoLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	TorsoLabel.SetText(TorsoText);
	TorsoLabel.SetFont(F_Normal);
	TorsoLabel.Align = TA_Right;

	TorsoCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 1, 1, 1, 1));
	TorsoCombo.SetHelpText( TorsoHelp );
	TorsoCombo.SetFont( F_Normal );
	TorsoCombo.SetEditable( false );
	TorsoCombo.Align = TA_Right;

    // Arms Skin
	ArmsLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	ArmsLabel.SetText(ArmsText);
	ArmsLabel.SetFont(F_Normal);
	ArmsLabel.Align = TA_Right;

	ArmsCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 1, 1, 1, 1));
	ArmsCombo.SetHelpText( ArmsHelp );
	ArmsCombo.SetFont( F_Normal );
	ArmsCombo.SetEditable( false );
	ArmsCombo.Align = TA_Right;

    // Legs Skin
	LegsLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	LegsLabel.SetText(LegsText);
	LegsLabel.SetFont(F_Normal);
	LegsLabel.Align = TA_Right;

	LegsCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 1, 1, 1, 1));
	LegsCombo.SetHelpText( LegsHelp );
	LegsCombo.SetFont( F_Normal );
	LegsCombo.SetEditable( false );
	LegsCombo.Align = TA_Right;

    // Icon
	IconLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	IconLabel.SetText(IconText);
	IconLabel.SetFont(F_Normal);
	IconLabel.Align = TA_Right;

	IconCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 1, 1, 1, 1));
	IconCombo.SetHelpText( IconHelp );
	IconCombo.SetFont( F_Normal );
	IconCombo.SetEditable( false );
	IconCombo.Align = TA_Right;

	// Hit Sound
	HitSoundLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	HitSoundLabel.SetText(HitSoundText);
	HitSoundLabel.SetFont(F_Normal);
	HitSoundLabel.Align = TA_Right;

	HitSoundCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 1, 1, 1, 1));
	HitSoundCombo.SetHelpText( HitSoundHelp );
	HitSoundCombo.SetFont( F_Normal );
	HitSoundCombo.SetEditable( false );
	HitSoundCombo.Align = TA_Right;

	FillHitSoundCombo();

	// Test Sound
	TestVoiceButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 1, 1, 1, 1 ) );
	TestVoiceButton.SetText( TestVoiceText );
	TestVoiceButton.SetHelpText( TestVoiceHelp );

	// Test Hit Sound
	TestHitButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 1, 1, 1, 1 ) );
	TestHitButton.SetText( TestHitText );
	TestHitButton.SetHelpText( TestHitHelp );

	// Spectator
	SpectatorLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	SpectatorLabel.SetText(SpectatorText);
	SpectatorLabel.SetFont(F_Normal);
	SpectatorLabel.Align = TA_Right;

	SpectatorCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 1, 1, 1, 1));
	SpectatorCheck.SetHelpText( SpectatorHelp );
	SpectatorCheck.SetFont( F_Normal );
	SpectatorCheck.Align = TA_Right;

	IterateClasses();
}

function FillHitSoundCombo()
{
	local PlayerPawn PlayerOwner;
	local int i;

	PlayerOwner = GetPlayerOwner();
	
	for ( i=0; i<DukePlayer(PlayerOwner).NumHitNotificationNames; i++ )
	{
		if ( DukePlayer(PlayerOwner).HitNotificationSounds[i] == None )
			HitSoundCombo.AddItem( "None", string(i) );
		else
			HitSoundCombo.AddItem( DukePlayer(PlayerOwner).HitNotificationNames[i], string(i) );
	}

}

function BeforePaint(Canvas C, float X, float Y)
{
	local int CenterWidth;
	local int CColLeft, CColRight;

	Super.BeforePaint( C, X, Y );

	if ( ResizeFrames == 0 )
		return;
	ResizeFrames--;

	CenterWidth = (WinWidth/4)*3;
	CColLeft = (WinWidth / 2) - 51;
	CColRight = (WinWidth / 2) - 44;

	NameEdit.SetSize( 200, NameEdit.WinHeight );
	NameEdit.WinLeft = CColRight;
	NameEdit.EditBoxWidth = 200;
	NameEdit.WinTop = 10;

	NameLabel.AutoSize( C );
	NameLabel.WinLeft = CColLeft - NameLabel.WinWidth;
	NameLabel.WinTop = NameEdit.WinTop + 8;

	SexCombo.SetSize( 200, SexCombo.WinHeight );
	SexCombo.WinLeft = CColRight;
	SexCombo.WinTop = NameEdit.WinTop + NameEdit.WinHeight + ControlOffset;

	SexLabel.AutoSize( C );
	SexLabel.WinLeft = CColLeft - SexLabel.WinWidth;
	SexLabel.WinTop = SexCombo.WinTop + 8;

	VoiceCombo.SetSize( 200, VoiceCombo.WinHeight );
	VoiceCombo.WinLeft = CColRight;
	VoiceCombo.WinTop = SexCombo.WinTop + SexCombo.WinHeight + ControlOffset;

	VoiceLabel.AutoSize( C );
	VoiceLabel.WinLeft = CColLeft - VoiceLabel.WinWidth;
	VoiceLabel.WinTop = VoiceCombo.WinTop + 8;

	MeshCombo.SetSize( 200, MeshCombo.WinHeight );
	MeshCombo.WinLeft = CColRight;
	MeshCombo.WinTop = VoiceCombo.WinTop + VoiceCombo.WinHeight + ControlOffset;

	MeshLabel.AutoSize( C );
	MeshLabel.WinLeft = CColLeft - MeshLabel.WinWidth;
	MeshLabel.WinTop = MeshCombo.WinTop + 8;

	FaceCombo.SetSize( 200, FaceCombo.WinHeight );
	FaceCombo.WinLeft = CColRight;
	FaceCombo.WinTop = MeshCombo.WinTop + MeshCombo.WinHeight + ControlOffset;

	FaceLabel.AutoSize( C );
	FaceLabel.WinLeft = CColLeft - FaceLabel.WinWidth;
	FaceLabel.WinTop = FaceCombo.WinTop + 8;

	TorsoCombo.SetSize( 200, TorsoCombo.WinHeight );
	TorsoCombo.WinLeft = CColRight;
	TorsoCombo.WinTop = FaceCombo.WinTop + FaceCombo.WinHeight + ControlOffset;

	TorsoLabel.AutoSize( C );
	TorsoLabel.WinLeft = CColLeft - TorsoLabel.WinWidth;
	TorsoLabel.WinTop = TorsoCombo.WinTop + 8;

	ArmsCombo.SetSize( 200, ArmsCombo.WinHeight );
	ArmsCombo.WinLeft = CColRight;
	ArmsCombo.WinTop = TorsoCombo.WinTop + TorsoCombo.WinHeight + ControlOffset;

	ArmsLabel.AutoSize( C );
	ArmsLabel.WinLeft = CColLeft - ArmsLabel.WinWidth;
	ArmsLabel.WinTop = ArmsCombo.WinTop + 8;

	LegsCombo.SetSize( 200, LegsCombo.WinHeight );
	LegsCombo.WinLeft = CColRight;
	LegsCombo.WinTop = ArmsCombo.WinTop + ArmsCombo.WinHeight + ControlOffset;

	LegsLabel.AutoSize( C );
	LegsLabel.WinLeft = CColLeft - LegsLabel.WinWidth;
	LegsLabel.WinTop = LegsCombo.WinTop + 8;

	IconCombo.SetSize( 200, IconCombo.WinHeight );
	IconCombo.WinLeft = CColRight;
	IconCombo.WinTop = LegsCombo.WinTop + LegsCombo.WinHeight + ControlOffset;

	IconLabel.AutoSize( C );
	IconLabel.WinLeft = CColLeft - IconLabel.WinWidth;
	IconLabel.WinTop = IconCombo.WinTop + 8;

	HitSoundCombo.SetSize( 200, HitSoundCombo.WinHeight );
	HitSoundCombo.WinLeft = CColRight;
	HitSoundCombo.WinTop = IconCombo.WinTop + IconCombo.WinHeight + ControlOffset;

	HitSoundLabel.AutoSize( C );
	HitSoundLabel.WinLeft = CColLeft - HitSoundLabel.WinWidth;
	HitSoundLabel.WinTop = HitSoundCombo.WinTop + 8;

	SpectatorCheck.SetSize( CenterWidth-90+16, SpectatorCheck.WinHeight );
	SpectatorCheck.WinLeft = CColRight;
	SpectatorCheck.WinTop = HitSoundCombo.WinTop + HitSoundCombo.WinHeight + ControlOffset;

	SpectatorLabel.AutoSize( C );
	SpectatorLabel.WinLeft = CColLeft - SpectatorLabel.WinWidth;
	SpectatorLabel.WinTop = SpectatorCheck.WinTop + 10;

	TestVoiceButton.AutoSize( C );
	TestHitButton.AutoSize( C );

	TestVoiceButton.WinLeft = (WinWidth - (TestVoiceButton.WinWidth + TestHitButton.WinWidth + 10)) / 2 + 10 + TestHitButton.WinWidth;
	TestVoiceButton.WinTop = SpectatorCheck.WinTop + SpectatorCheck.WinHeight + ControlOffset;

	TestHitButton.WinLeft = (WinWidth - (TestVoiceButton.WinWidth + TestHitButton.WinWidth + 10)) / 2;
	TestHitButton.WinTop = SpectatorCheck.WinTop + SpectatorCheck.WinHeight + ControlOffset;
}

function bool GetNextValue( string In, out string Out, out string Result )
{
	local int i;
	local bool bFoundStart;

	Result		= "";
	bFoundStart = False;

	for ( i=0; i<Len( In ); i++ ) 
	{
		if ( bFoundStart )
		{
			if ( Mid( In, i, 1 ) == "\\" )
			{
				Out = Right( In, Len( In ) - i );
				return True;
			}
			else
			{
				Result = Result $ Mid(In, i, 1);
			}
		}
		else
		{
			if ( Mid( In, i, 1 ) == "\\" )
			{
				bFoundStart = True;
			}
		}
	}
	return False;
}

function ExtractMesh( string Data, out string MeshName, optional out float Jaw, optional out float MouthCorner, optional out float Lip_L, optional out float Lip_U )
{
	local string	In, Out, Value;
	local bool		bOK;

	In = Data;
	do 
	{
		bOK = GetNextValue( In, Out, Value );	
		In	= Out;
		if ( Value ~= "Mesh" )
		{
			bOK = GetNextValue( In, Out, Value );
			MeshName = Value;
		}
		else if ( Value ~= "Jaw" )
		{
			bOK = GetNextValue( In, Out, Value );
			Jaw = float( Value );
		}
		else if ( Value ~= "MouthCorner" )
		{
			bOK = GetNextValue( In, Out, Value );
			MouthCorner = float( Value );
		}
		else if ( Value ~= "Lip_L" )
		{
			bOK = GetNextValue( In, Out, Value );
			Lip_L = float( Value );
		}
		else if ( Value ~= "Lip_U" )
		{
			bOK = GetNextValue( In, Out, Value );
			Lip_U = float( Value );
		}
		
	} until(!bOK);

}

function IterateClasses()
{
	local string CharacterClass, ClassDesc, TestName, Temp;
	local int i;
	local bool bNewFormat;

	SexCombo.Clear();

	CharacterClass = "None";
	TestName = "";
	while ( true )
	{
		GetPlayerOwner().GetNextClass( PlayerBaseClass, CharacterClass, 1, CharacterClass, ClassDesc );

		if ( CharacterClass == TestName )
			break;

		if ( TestName == "" )
			TestName = CharacterClass;

		SexCombo.AddItem( ClassDesc, CharacterClass );
	}

	SexCombo.Sort();
}

function IterateThings( string CharacterClass, string BaseClass, UWindowComboControl ComboBox, optional string ThingPrefix )
{
	local string ThingName, ThingDesc, TestName, ExtraData, ComboString;
	local int i;
	local bool bNewFormat;
	
	ComboBox.Clear();
	ComboBox.ShowWindow();

    if ( CharacterClass == "" )
        return;

	ThingName	= "None";
	TestName	= "";

	while ( true )
	{		
		GetPlayerOwner().GetNextThing( BaseClass, CharacterClass, ThingName, 1, ThingName, ThingDesc, ExtraData );

		if ( ThingName == TestName )
		{
			break;
		}

		if ( TestName == "" )
		{
			TestName = ThingName;
		}

		if ( ThingPrefix != "" )
		{
			if ( ExtraData == "" )
				ComboString = "\\" $ ThingPrefix $ "\\" $ ThingName $ "\\";
			else
				ComboString = "\\" $ ThingPrefix $ "\\" $ ThingName $ ExtraData;
		}
		else if ( ExtraData != "" )
		{
			ComboString = "\\Thing\\" $ ThingName $ ExtraData;
		}			
		else
		{
			ComboString = ThingName;
		}

		ComboBox.AddItem( ThingDesc, ComboString );			
	}

	ComboBox.Sort();
}

function IterateSkins( string ParentNames[4], string CategoryName, UWindowComboControl SkinCombo )
{
	local string SkinName, SkinDesc, TestName, Temp;
	local int i;
	local bool bNewFormat;

    SkinCombo.Clear();
	SkinCombo.ShowWindow();

    SkinName = "None";
	TestName = "";
	while ( true )
	{
		GetPlayerOwner().GetNextSkin( ParentNames, CategoryName, SkinName, 1, SkinName, SkinDesc );

		//Log( "GetNextSkin" @ CategoryName @ SkinName @ SkinDesc @ TestName );

		if ( SkinName == TestName )
		{
			break;
		}

		if ( TestName == "" )
		{
			TestName = SkinName;
		}

		SkinCombo.AddItem( SkinDesc, SkinName );
	}
	SkinCombo.Sort();
}


function AfterCreate()
{
	Super.AfterCreate();

	DesiredWidth = 220;
	DesiredHeight = ControlOffset + 25;

	LoadCurrent();
	UseSelected();
		
	Initialized = true;
}

function LoadPlayerSoundClass()
{
	if ( VoiceCombo.GetValue2() != "" )
	{
		VoicePackClass	= class<dnVoicePack>( DynamicLoadObject( VoiceCombo.GetValue2(), class'Class' ) );    

		if ( VoicePackClass == None )
			Log	( "Could not load the VoicePack class" @ VoiceCombo.GetValue2() );
	}
}

function VoiceChanged()
{
	LoadPlayerSoundClass();	

	if ( Initialized )
	{
		UseSelected();
	}
}

function TestVoice()
{
	if ( VoicePackClass != None )
	{
		MeshWindow.PlaySoundThruMesh( VoicePackClass.default.TestSound );
	}
}

function TestHitSound()
{
	local int index;
	local PlayerPawn PlayerOwner;

	PlayerOwner = GetPlayerOwner();

	if ( Initialized && DukePlayer( PlayerOwner ) != None )
	{
		index = DukePlayer( PlayerOwner ).HitNotificationIndex;
		PlayerOwner.PlaySound( DukePlayer( PlayerOwner ).HitNotificationSounds[index] );
	}
}

function TeamChanged()
{
	if ( Initialized )
		UseSelected();
}

function Notify( UWindowDialogControl C, byte E )
{
	Super.Notify( C, E );
    
    if ( bInNotify == true )
	{
        return;
	}

    bInNotify = true;

	switch( E )
	{
	case DE_Click:
		switch( C )
		{
		case TestVoiceButton:
			TestVoice();
			break;
		case TestHitButton:
			TestHitSound();
			break;
		}
		break;
	case DE_Change:
		switch( C )
		{
			case NameEdit:
				NameChanged();
				break;
			case SexCombo:
				SexChanged();
				break;
			case VoiceCombo:
				VoiceChanged();
				break;
			case MeshCombo:
				MeshChanged();
				break;
			case FaceCombo:
				FaceChanged();
				break;
			case TorsoCombo:
				TorsoChanged();
				break;
			case ArmsCombo:
				ArmsChanged();
				break;
			case LegsCombo:
				LegsChanged();
				break;
			case IconCombo:
				IconChanged();
				break;
			case SpectatorCheck:
				SpectatorChanged();
				break;
			case HitSoundCombo:
				HitSoundChanged();
				break;
		}
	}
    bInNotify = false;
}

function FillMeshes()
{
    // Load Meshes based on the class
    IterateThings( SexCombo.GetValue2(), "DukeMesh", MeshCombo, "Mesh" );   
    MeshCombo.SetSelectedIndex( 0 );
}

function FillSounds()
{
    // Load Sounds based on the class
    IterateThings( SexCombo.GetValue2(), "VoicePack", VoiceCombo );
    VoiceCombo.SetSelectedIndex( 0 );
}

function FillSkins( UWindowComboControl SkinCombo, string Category, string ParentNames[4], optional bool noClear, optional bool bNoDefault )
{
    local string    SaveSelection;
    local int       i,SelectionIndex;
	local string	SkinNames[32], SkinDescs[32];

    SaveSelection  = SkinCombo.GetValue2();

    //IterateSkins( ParentNames, Category, SkinCombo ); 

	if ( !noClear )
		SkinCombo.Clear();

	SkinCombo.ShowWindow();

	GetPlayerOwner().GetSkinList( Category, ParentNames, SkinNames, SkinDescs );

	if ( SkinNames[i] == "" && !bNoDefault ) // No matches
	{
		SkinCombo.AddItem( "Default", "" );
		SkinCombo.SetSelectedIndex( 0 );
	}
	else
	{
		for( i=0; i<32; i++ )
		{
			//Log( "SkinNames[" $ i $ "]=" $ SkinNames[i] );
			if ( SkinNames[i] == "" )
				break;

			SkinCombo.AddItem( SkinDescs[i], SkinNames[i] );
		}
	
		SelectionIndex = SkinCombo.FindItemIndex2( SaveSelection, false );

		if ( SelectionIndex >= 0 )
		{
			SkinCombo.SetSelectedIndex( SelectionIndex );
		}
		else
		{
			SkinCombo.SetSelectedIndex( 0 );
		}
	}
}

function FillIcons()
{
    local string ParentNames[4];
	local string MeshName;

	// MeshIcon is based on the Mesh
	ExtractMesh( MeshCombo.GetValue2(), MeshName );
    ParentNames[0] = MeshName;
	FillSkins( IconCombo, "MeshIcon", ParentNames, false, true );

    // FaceIcon is based on the Face
    ParentNames[0] = FaceCombo.GetValue2();
    FillSkins( IconCombo, "FaceIcon", ParentNames, true, true );

	// DefaultIcon is anything
	ParentNames[0] = "";
	FillSkins( IconCombo, "DefaultIcon", ParentNames, true, true );
}

function FillFaces()
{
    local string ParentNames[4];    
	local string MeshName;

	// Face is based on Mesh
	ExtractMesh( MeshCombo.GetValue2(), MeshName );
    ParentNames[0] = MeshName;

    FillSkins( FaceCombo, "Face", ParentNames );
}

function FillTorso()
{
    local string ParentNames[4];
	local string MeshName;

    // Torso is based on the Mesh and Face
	ExtractMesh( MeshCombo.GetValue2(), MeshName );
    ParentNames[0] = MeshName;
    ParentNames[1] = FaceCombo.GetValue2();

    FillSkins( TorsoCombo, "Torso", ParentNames );
}

function FillArms()
{
    local string ParentNames[4];
	local string MeshName;

    // Arms are based on the Mesh, Face, and Torso
	ExtractMesh( MeshCombo.GetValue2(), MeshName );
    ParentNames[0] = MeshName;
    ParentNames[1] = FaceCombo.GetValue2();
    ParentNames[2] = TorsoCombo.GetValue2();

    FillSkins( ArmsCombo, "Arms", ParentNames );
}

function FillLegs()
{
    local string ParentNames[4];
	local string MeshName;

    // Legs are based on the Mesh, Face, and Torso
	ExtractMesh( MeshCombo.GetValue2(), MeshName );
    ParentNames[0] = MeshName;
    ParentNames[1] = FaceCombo.GetValue2();

    FillSkins( LegsCombo, "Legs", ParentNames );
}

function ArmsChanged()
{
    if ( Initialized )
	{
        UseSelected();
	}
}

function LegsChanged()
{
    if ( Initialized )
	{
        UseSelected();
	}
}

function IconChanged()
{
    if ( Initialized )
	{
        UseSelected();
	}
}

function TorsoChanged()
{
    local bool OldInitialized;
    
    OldInitialized  = Initialized;
	Initialized     = false;

    FillArms();
    FillLegs();

    Initialized = OldInitialized;

    if ( Initialized )
	{
        UseSelected();
	}
}

function FaceChanged()
{
    local bool OldInitialized;
    
    OldInitialized  = Initialized;
	Initialized     = false;

    FillTorso();
    FillArms();
    FillLegs();
	FillIcons();

    Initialized = OldInitialized;

    if ( Initialized )
	{
        UseSelected();
	}
}

function MeshChanged()
{
    local bool OldInitialized;
    
    OldInitialized  = Initialized;
	Initialized     = false;
    
    FillFaces();
    FillTorso();
    FillArms();
    FillLegs();
	FillIcons();

    Initialized = OldInitialized;

    if ( Initialized )
	{
        UseSelected();
	}
}

function SexChanged()
{
    local bool OldInitialized;
    
    if ( SexCombo.GetValue2() == "" )
        return;

    OldInitialized  = Initialized;
	Initialized     = false;

	FillSounds();
    FillMeshes();
    
    if ( MeshCombo.GetValue2() == "" )
    {
        ClearSkinCombos();
    }
    else
    {
        FillFaces();
        FillTorso();
        FillArms();
        FillLegs();
		FillIcons();
    }

    Initialized = OldInitialized;

    if ( Initialized )
	{
        UseSelected();
	}
}

function ClearSkinCombos()
{
    local int i;

    FaceCombo.Clear();
    TorsoCombo.Clear();
    ArmsCombo.Clear();
    LegsCombo.Clear();  
    IconCombo.Clear();
}

function UseSelected()
{
	local int		NewTeam;
	local string	MeshName;
	local float		Jaw, Mouth, Lip_U, Lip_L;

	ExtractMesh( MeshCombo.GetValue2(), MeshName, Jaw, Mouth, Lip_L, Lip_U );

	if (Initialized)
	{
		GetPlayerOwner().UpdateURL( "Class", SexCombo.GetValue2(),  true );
        GetPlayerOwner().UpdateURL( "Mesh",  MeshName,				  true );        
		GetPlayerOwner().UpdateURL( "Face",  FaceCombo.GetValue2(),   true );
        GetPlayerOwner().UpdateURL( "Torso", TorsoCombo.GetValue2(),  true );
        GetPlayerOwner().UpdateURL( "Arms",  ArmsCombo.GetValue2(),   true );
        GetPlayerOwner().UpdateURL( "Legs",  LegsCombo.GetValue2(),   true );
		GetPlayerOwner().UpdateURL( "Voice", VoiceCombo.GetValue2(),  true );
		GetPlayerOwner().UpdateURL( "Icon",  IconCombo.GetValue2(),  true );

		if ( SpectatorCheck.bChecked )
			GetPlayerOwner().UpdateURL( "Spectate", "1", true );
		else
			GetPlayerOwner().UpdateURL( "Spectate", "", true );
	}

    // Update the mesh to the new look
	MeshWindow.SetMeshString( MeshName );

	if ( MeshWindow.MeshActor != None )
	{
		MeshWindow.MeshActor.SoundSyncScale_Jaw			= Jaw;
		MeshWindow.MeshActor.SoundSyncScale_MouthCorner	= Mouth;
		MeshWindow.MeshActor.SoundSyncScale_Lip_L		= Lip_L;
		MeshWindow.MeshActor.SoundSyncScale_Lip_U		= Lip_U;
	}

	MeshWindow.ClearSkins();
    MeshWindow.SetSkin( FaceCombo.GetValue2(), 
                        TorsoCombo.GetValue2(), 
                        ArmsCombo.GetValue2(), 
                        LegsCombo.GetValue2(),
						IconCombo.GetValue2()
                      );

    // Send changes to the server
    GetPlayerOwner().ServerChangeMesh( MeshName );
    GetPlayerOwner().ServerChangeSkin( FaceCombo.GetValue2(), 
                                       TorsoCombo.GetValue2(),
                                       ArmsCombo.GetValue2(), 
                                       LegsCombo.GetValue2(),
                                       IconCombo.GetValue2()
                                     );

	// Load the current sound class
	LoadPlayerSoundClass();
	GetPlayerOwner().ServerChangeVoice( VoicePackClass );

	if ( DukePlayer( GetPlayerOwner() ) != None )
	{
		DukePlayer( GetPlayerOwner() ).HitNotificationIndex = HitSoundCombo.GetSelectedIndex();
	}
}


function LoadCurrent()
{
	local string CN,MN,FN,TN,AN,LN,VN,IC;
	local string Voice, Spectate;

	// Name
    NameEdit.SetValue( GetPlayerOwner().PlayerReplicationInfo.PlayerName );

    // Class 
    CN = GetPlayerOwner().GetDefaultURL( "Class" );
    SexCombo.SetSelectedIndex( Max( SexCombo.FindItemIndex2( CN, true ), 0 ) );

	// Voice
	VN = GetPlayerOwner().GetDefaultURL( "Voice" );
	VoiceCombo.SetSelectedIndex(  Max( VoiceCombo.FindItemIndex2( VN, true ), 0 ) );

    // Mesh
    MN = GetPlayerOwner().GetDefaultURL("Mesh" );
    MeshCombo.SetSelectedIndex( Max( MeshCombo.FindItemIndex2( "\\Mesh\\" $ MN $ "\\", true, true ), 0 ) );

    // If no mesh list was found, then just clear out the skin combos.
    if ( MeshCombo.GetValue2() == "" )
    {
        ClearSkinCombos();
    }
    else
    {
        // Skins
        FN = GetPlayerOwner().GetDefaultURL( "Face"  );
        TN = GetPlayerOwner().GetDefaultURL( "Torso" );
        AN = GetPlayerOwner().GetDefaultURL( "Arms"  );
        LN = GetPlayerOwner().GetDefaultURL( "Legs"  );
		IC = GetPlayerOwner().GetDefaultURL( "Icon"  );	

    	FaceCombo.SetSelectedIndex(	  Max( FaceCombo.FindItemIndex2(   FN, true ), 0 ) );
        TorsoCombo.SetSelectedIndex(  Max( TorsoCombo.FindItemIndex2(  TN, true ), 0 ) );
        ArmsCombo.SetSelectedIndex(	  Max( ArmsCombo.FindItemIndex2(   AN, true ), 0 ) );
        LegsCombo.SetSelectedIndex(	  Max( LegsCombo.FindItemIndex2(   LN, true ), 0 ) );
		IconCombo.SetSelectedIndex(	  Max( IconCombo.FindItemIndex2(   IC, true ), 0 ) );
    }

	Spectate                = GetPlayerOwner().GetDefaultURL( "Spectate" );
	SpectatorCheck.bChecked = ( (Spectate != "" ) && ( Spectate == "1" ) );

	if ( DukePlayer( GetPlayerOwner() ) != None )
	{
		HitSoundCombo.SetSelectedIndex( DukePlayer(GetPlayerOwner()).HitNotificationIndex );
	}
}

function NameChanged()
{
	local string N;

    if ( Initialized )
	{
//		Initialized = false;
//		N = NameEdit.GetValue();
//		ReplaceText( N, " ", "_" );
//		NameEdit.SetValue(N);
//		Initialized = true;

		GetPlayerOwner().ChangeName( NameEdit.GetValue() );
		GetPlayerOwner().UpdateURL( "Name", NameEdit.GetValue(), true );
	}
}

function SpectatorChanged()
{
	if ( SpectatorCheck.bChecked )
	{		
		GetPlayerOwner().UpdateURL( "Spectate", "1", true );
	}
	else
	{
		GetPlayerOwner().UpdateURL( "Spectate",	"", true );
	}
}

function HitSoundChanged()
{	
	if ( Initialized )
		UseSelected();
}

function SaveConfigs()
{
	Super.SaveConfigs();
	GetPlayerOwner().SaveConfig();
}

defaultproperties
{
	ControlOffset=1
	NameText="Name:"
	NameHelp="Set your player name."
	SexText="Sex:"
	SexHelp="Select your player sex."
	MeshText="Mesh:"
	MeshHelp="Choose a model for your player."
	TorsoText="Torso:"
	TorsoHelp="Choose a torso for your player."
	ArmsText="Arms:"
	ArmsHelp="Choose arms for your player."
	LegsText="Legs:"
	LegsHelp="Choose legs for your player."
	FaceText="Face:"
	FaceHelp="Choose a face for your player."
	VoiceText="Voice:"
	VoiceHelp="Select your player's voice."
	TestVoiceText="Test Voice"
	TestVoiceHelp="Test the player's Voice."
	IconText="Icon:"
	IconHelp="Choose an icon for your player."
	PlayerBaseClass="dnGame.DukePlayer"
    bBuildDefaultButtons=false
	SpectatorText="Spectator:"
	SpectatorHelp="Join the server as a spectator."
	HitSoundText="HitSound:"
	HitSoundHelp="Sound effect to play when you damage an enemy"
	TestHitText="Test HitSound"
	TestHitHelp="Test the player's hit sound."
}
