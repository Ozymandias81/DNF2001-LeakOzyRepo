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
var UWindowEditControl      NameEdit;
var localized string        NameText;
var localized string        NameHelp;
                            
// Team Combo               
var UWindowComboControl     TeamCombo;
var localized string        TeamText;
var localized string        Teams[4];
var localized string        NoTeam;
var localized string        TeamHelp;
                            
// Class Combo              
var UWindowComboControl     ClassCombo;
var localized string        ClassText;
var localized string        ClassHelp;

// Sound
var UWindowComboControl     VoiceCombo;
var localized string        VoiceText;
var localized string        VoiceHelp;
                            
// Mesh Combo               
var UWindowComboControl     MeshCombo;
var localized string        MeshText;
var localized string        MeshHelp;
                                                      
// Face Combo               
var UWindowComboControl     FaceCombo;
var localized string        FaceText;
var localized string        FaceHelp;

// Torso Skin Combo               
var UWindowComboControl     TorsoCombo;
var localized string        TorsoText;
var localized string        TorsoHelp;

// Arms Skin Combo               
var UWindowComboControl     ArmsCombo;
var localized string        ArmsText;
var localized string        ArmsHelp;

// Legs Skin Combo               
var UWindowComboControl     LegsCombo;
var localized string        LegsText;
var localized string        LegsHelp;

// Aux skin Combo
var UWindowComboControl     AuxCombo[4];
var localized string        AuxText[4];
var localized string        AuxHelp;

// Test Sound
var UWindowSmallButton		TestVoiceButton;
var localized string        TestVoiceText;
var localized string        TestVoiceHelp;

// Spectator
var UWindowCheckbox			SpectatorCheck;
var localized string		SpectatorText;
var localized string		SpectatorHelp;

var UWindowLabelControl     TestSoundsLabel;
var localized string        TestSoundsText;
var localized string        TestSoundsHelp;

// Hit Notification Sound
var UWindowComboControl     HitSoundCombo;
var localized string        HitSoundText;
var localized string        HitSoundHelp;

// Test Hit Sound
var UWindowSmallButton		TestHitButton;
var localized string        TestHitText;
var localized string        TestHitHelp;

function Created()
{
	local string SkinName, FaceName;

	local int ControlWidth, ControlHeight, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local int I;
	
    MeshWindow = UDukePlayerMeshCW( UDukePlayerSetupTopCW( ParentWindow.ParentWindow.ParentWindow).Splitter.RightClientWindow );

	Super.Created();

	ControlWidth    = WinWidth/2;
	ControlLeft     = (WinWidth/2 - ControlWidth)/2;
	ControlRight    = WinWidth/2 + ControlLeft;

	CenterWidth     = (WinWidth/4)*3;
	CenterPos       = (WinWidth - CenterWidth)/2;
	ControlHeight	= 20;

	// Player Name
	NameEdit = UWindowEditControl( CreateControl( class'UWindowEditControl', CenterPos, ControlOffset, CenterWidth, 1 ) );
	NameEdit.SetText( NameText );
	NameEdit.SetHelpText( NameHelp );
	NameEdit.SetFont( F_Normal );
	NameEdit.SetNumericOnly( false );
	NameEdit.SetMaxLength( 20 );
	NameEdit.SetDelayedNotify( true );
    
	// Team
	ControlOffset += ControlHeight;
	TeamCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	TeamCombo.SetText( TeamText );
	TeamCombo.SetHelpText( TeamHelp );
	TeamCombo.SetFont( F_Normal );
	TeamCombo.SetEditable( false );
	TeamCombo.AddItem( NoTeam, String(255) );
	for ( i=0; i<4; i++ )
		TeamCombo.AddItem( Teams[i], String(i) );

	// Classes
	ControlOffset += ControlHeight;
	ClassCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	ClassCombo.SetText( ClassText );
	ClassCombo.SetHelpText( ClassHelp );
	ClassCombo.SetEditable( false );
	ClassCombo.SetFont( F_Normal );

    // Sounds
	ControlOffset += ControlHeight;
	VoiceCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	VoiceCombo.SetText( VoiceText );
	VoiceCombo.SetHelpText( VoiceHelp );
	VoiceCombo.SetEditable( false );
	VoiceCombo.SetFont( F_Normal );

    // Meshes
	ControlOffset += ControlHeight;
	MeshCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	MeshCombo.SetText( MeshText );
	MeshCombo.SetHelpText( MeshHelp );
	MeshCombo.SetEditable( false );
	MeshCombo.SetFont( F_Normal );

    // Faces
	ControlOffset += ControlHeight;
	FaceCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	FaceCombo.SetText( FaceText );
	FaceCombo.SetHelpText( FaceHelp );
	FaceCombo.SetFont( F_Normal );
	FaceCombo.SetEditable( false );

	// Torso Skin
	ControlOffset += ControlHeight;
	TorsoCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	TorsoCombo.SetText( TorsoText );
	TorsoCombo.SetHelpText( TorsoHelp );
	TorsoCombo.SetFont( F_Normal );
	TorsoCombo.SetEditable( false );

    // Arms Skin
	ControlOffset += ControlHeight;
	ArmsCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	ArmsCombo.SetText( ArmsText );
	ArmsCombo.SetHelpText( ArmsHelp );
	ArmsCombo.SetFont( F_Normal );
	ArmsCombo.SetEditable( false );

    // Legs Skin
	ControlOffset += ControlHeight;
	LegsCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	LegsCombo.SetText( LegsText );
	LegsCombo.SetHelpText( LegsHelp );
	LegsCombo.SetFont( F_Normal );
	LegsCombo.SetEditable( false );

    for ( i=0; i<4; i++ )
    {
        ControlOffset += ControlHeight;
	    AuxCombo[i] = UWindowComboControl( CreateControl( class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1 ) );
	    AuxCombo[i].SetText( AuxText[i] );
	    AuxCombo[i].SetHelpText( AuxHelp );
	    AuxCombo[i].SetFont( F_Normal );
	    AuxCombo[i].SetEditable( false );
    }

	ControlOffset += ControlHeight;

	HitSoundCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	HitSoundCombo.SetText( HitSoundText );
	HitSoundCombo.SetHelpText( HitSoundHelp );
	HitSoundCombo.SetFont( F_Normal );
	HitSoundCombo.SetEditable( false );

	FillHitSoundCombo();

	ControlOffset += ControlHeight;

	SpectatorCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	SpectatorCheck.SetText( SpectatorText );
	SpectatorCheck.SetHelpText( SpectatorHelp );
	SpectatorCheck.SetFont( F_Normal );
	SpectatorCheck.Align = TA_Left;

	ControlOffset += ControlHeight;

    TestSoundsLabel   = UWindowLabelControl( CreateControl( class'UWindowLabelControl', CenterPos, ControlOffset, CenterWidth, 1 ) );
    TestSoundsLabel.SetText( TestSoundsText );
    TestSoundsLabel.SetHelpText( TestSoundsHelp );
    TestSoundsLabel.SetFont( F_Normal );
    TestSoundsLabel.Align = TA_Center;

	// Test Sound
	TestVoiceButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', CenterPos, ControlOffset, 64, 16 ) );
	TestVoiceButton.SetText( TestVoiceText );
	TestVoiceButton.SetHelpText( TestVoiceHelp );

	// Test Hit Sound
	TestHitButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', CenterPos, ControlOffset, 64, 16 ) );
	TestHitButton.SetText( TestHitText );
	TestHitButton.SetHelpText( TestHitHelp );

	ControlOffset += ControlHeight;

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
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, i;
	local float W;

	W = WinWidth;

	ControlWidth	= W / 2;
	ControlLeft		= ( W / 2 - ControlWidth ) / 2;
	ControlRight	= W / 2 + ControlLeft;

	CenterWidth		= ( W / 7 ) * 6;
	CenterPos		= ( W - CenterWidth ) / 2;

	NameEdit.SetSize( CenterWidth, 1 );
	NameEdit.WinLeft		= CenterPos;
	NameEdit.EditBoxWidth	= ControlWidth;

	TeamCombo.SetSize( CenterWidth, 1 );
	TeamCombo.WinLeft		= CenterPos;
	TeamCombo.EditBoxWidth	= ControlWidth;

	ClassCombo.SetSize( CenterWidth, 1 );
	ClassCombo.WinLeft		= CenterPos;
	ClassCombo.EditBoxWidth = ControlWidth;

	VoiceCombo.SetSize( CenterWidth, 1 );
	VoiceCombo.WinLeft		= CenterPos;
	VoiceCombo.EditBoxWidth = ControlWidth;

    MeshCombo.SetSize( CenterWidth, 1 );
	MeshCombo.WinLeft		= CenterPos;
	MeshCombo.EditBoxWidth	= ControlWidth;

	FaceCombo.SetSize( CenterWidth, 1 );
	FaceCombo.WinLeft		= CenterPos;
	FaceCombo.EditBoxWidth	= ControlWidth;

    TorsoCombo.SetSize( CenterWidth, 1 );
	TorsoCombo.WinLeft		= CenterPos;
	TorsoCombo.EditBoxWidth = ControlWidth;

    ArmsCombo.SetSize( CenterWidth, 1 );
	ArmsCombo.WinLeft		= CenterPos;
	ArmsCombo.EditBoxWidth	= ControlWidth;
    
    LegsCombo.SetSize( CenterWidth, 1 );
	LegsCombo.WinLeft		= CenterPos;
	LegsCombo.EditBoxWidth	= ControlWidth;
    
    for ( i=0; i<4; i++ )
    {
        AuxCombo[i].SetSize( CenterWidth, 1 );
	    AuxCombo[i].WinLeft			= CenterPos;
	    AuxCombo[i].EditBoxWidth	= ControlWidth;
    }

    HitSoundCombo.SetSize( CenterWidth, 1 );
	HitSoundCombo.WinLeft		= CenterPos;
	HitSoundCombo.EditBoxWidth	= ControlWidth;

	TestSoundsLabel.SetSize( 64, 16 );
	TestSoundsLabel.WinLeft = CenterPos;
		
	TestVoiceButton.SetSize( 64, 16 );
	TestVoiceButton.WinLeft = CenterPos + 64 + 8;

	TestHitButton.SetSize( 64, 16 );
	TestHitButton.WinLeft = CenterPos + 128 + 8;

	SpectatorCheck.SetSize( CenterWidth, 1 );
	SpectatorCheck.WinLeft = CenterPos;	
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

	ClassCombo.Clear();

	CharacterClass = "None";
	TestName = "";
	while ( true )
	{
		GetPlayerOwner().GetNextClass( PlayerBaseClass, CharacterClass, 1, CharacterClass, ClassDesc );

		if ( CharacterClass == TestName )
			break;

		if ( TestName == "" )
			TestName = CharacterClass;

		ClassCombo.AddItem( ClassDesc, CharacterClass );
	}

	ClassCombo.Sort();
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
			case TeamCombo:
				TeamChanged();
				break;
			case ClassCombo:
				ClassChanged();
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
            case AuxCombo[0]:
            case AuxCombo[1]:
            case AuxCombo[2]:
            case AuxCombo[3]:
                AuxChanged();
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
    IterateThings( ClassCombo.GetValue2(), "DukeMesh", MeshCombo, "Mesh" );   
    MeshCombo.SetSelectedIndex( 0 );
}

function FillSounds()
{
    // Load Sounds based on the class
    IterateThings( ClassCombo.GetValue2(), "VoicePack", VoiceCombo );
    VoiceCombo.SetSelectedIndex( 0 );
}

function FillSkins( UWindowComboControl SkinCombo, string Category, string ParentNames[4] )
{
    local string    SaveSelection;
    local int       SelectionIndex;

    SaveSelection  = SkinCombo.GetValue2();
    
    IterateSkins( ParentNames, Category, SkinCombo ); 

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

function FillAux()
{
    local string ParentNames[4];
	local string MeshName;

	ExtractMesh( MeshCombo.GetValue2(), MeshName );
    ParentNames[0] = MeshName;
	
    FillSkins( AuxCombo[0], "Aux1", ParentNames );
    FillSkins( AuxCombo[1], "Aux2", ParentNames );
    FillSkins( AuxCombo[2], "Aux3", ParentNames );
    FillSkins( AuxCombo[3], "Aux4", ParentNames );
}

function FillFaces()
{
    local string ParentNames[4];    
	local string MeshName;

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

function AuxChanged()
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
    FillAux();

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
    FillAux();

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
    FillAux();

    Initialized = OldInitialized;

    if ( Initialized )
	{
        UseSelected();
	}
}

function ClassChanged()
{
    local bool OldInitialized;
    
    if ( ClassCombo.GetValue2() == "" )
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
        FillAux();
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
    
    for ( i=0; i<4; i++ )
	{
        AuxCombo[i].Clear();
	}
}

function UseSelected()
{
	local int		NewTeam;
	local string	MeshName;
	local float		Jaw, Mouth, Lip_U, Lip_L;

	ExtractMesh( MeshCombo.GetValue2(), MeshName, Jaw, Mouth, Lip_L, Lip_U );

	if (Initialized)
	{
		GetPlayerOwner().UpdateURL( "Class", ClassCombo.GetValue2(),  true );
        GetPlayerOwner().UpdateURL( "Mesh",  MeshName,				  true );        
		GetPlayerOwner().UpdateURL( "Face",  FaceCombo.GetValue2(),   true );
        GetPlayerOwner().UpdateURL( "Torso", TorsoCombo.GetValue2(),  true );
        GetPlayerOwner().UpdateURL( "Arms",  ArmsCombo.GetValue2(),   true );
        GetPlayerOwner().UpdateURL( "Legs",  LegsCombo.GetValue2(),   true );
		GetPlayerOwner().UpdateURL( "Team",  TeamCombo.GetValue2(),   true );
        GetPlayerOwner().UpdateURL( "Aux1",  AuxCombo[0].GetValue2(), true );
        GetPlayerOwner().UpdateURL( "Aux2",  AuxCombo[1].GetValue2(), true );
        GetPlayerOwner().UpdateURL( "Aux3",  AuxCombo[2].GetValue2(), true );
        GetPlayerOwner().UpdateURL( "Aux4",  AuxCombo[3].GetValue2(), true );
		GetPlayerOwner().UpdateURL( "Voice", VoiceCombo.GetValue2(),  true );

		if ( SpectatorCheck.bChecked )
			GetPlayerOwner().UpdateURL( "Spectate", "1", true );
		else
			GetPlayerOwner().UpdateURL( "Spectate", "", true );

		NewTeam = Int( TeamCombo.GetValue2() );			

		if ( GetPlayerOwner().PlayerReplicationInfo.Team != NewTeam )
			GetPlayerOwner().ChangeTeam( NewTeam );
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
                        AuxCombo[0].GetValue2(),
                        AuxCombo[1].GetValue2(),
                        AuxCombo[2].GetValue2(),
                        AuxCombo[3].GetValue2()
                      );

    // Send changes to the server
    GetPlayerOwner().ServerChangeMesh( MeshName );
    GetPlayerOwner().ServerChangeSkin( FaceCombo.GetValue2(), 
                                       TorsoCombo.GetValue2(),
                                       ArmsCombo.GetValue2(), 
                                       LegsCombo.GetValue2(),
                                       AuxCombo[0].GetValue2(),
                                       AuxCombo[1].GetValue2(),
                                       AuxCombo[2].GetValue2(),
                                       AuxCombo[3].GetValue2()
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
	local string CN,MN,FN,TN,AN,LN,A1,A2,A3,A4,VN;
	local string Voice, Spectate;

	// Name
    NameEdit.SetValue( GetPlayerOwner().PlayerReplicationInfo.PlayerName );

    // Team
	TeamCombo.SetSelectedIndex( Max( TeamCombo.FindItemIndex2( string(GetPlayerOwner().PlayerReplicationInfo.Team ) ), 0 ) );

    // Class 
    CN = GetPlayerOwner().GetDefaultURL( "Class" );
    ClassCombo.SetSelectedIndex( Max( ClassCombo.FindItemIndex2( CN, true ), 0 ) );

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
        A1 = GetPlayerOwner().GetDefaultURL( "Aux1"  );
        A2 = GetPlayerOwner().GetDefaultURL( "Aux2"  );
        A3 = GetPlayerOwner().GetDefaultURL( "Aux3"  );
        A4 = GetPlayerOwner().GetDefaultURL( "Aux4"  );		

    	FaceCombo.SetSelectedIndex(	  Max( FaceCombo.FindItemIndex2(   FN, true ), 0 ) );
        TorsoCombo.SetSelectedIndex(  Max( TorsoCombo.FindItemIndex2(  TN, true ), 0 ) );
        ArmsCombo.SetSelectedIndex(	  Max( ArmsCombo.FindItemIndex2(   AN, true ), 0 ) );
        LegsCombo.SetSelectedIndex(	  Max( LegsCombo.FindItemIndex2(   LN, true ), 0 ) );
        AuxCombo[0].SetSelectedIndex( Max( AuxCombo[0].FindItemIndex2( A1, true ), 0 ) );
        AuxCombo[1].SetSelectedIndex( Max( AuxCombo[1].FindItemIndex2( A2, true ), 0 ) );
        AuxCombo[2].SetSelectedIndex( Max( AuxCombo[2].FindItemIndex2( A3, true ), 0 ) );
        AuxCombo[3].SetSelectedIndex( Max( AuxCombo[3].FindItemIndex2( A4, true ), 0 ) );		
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
		Initialized = false;
		N = NameEdit.GetValue();
		ReplaceText( N, " ", "_" );
		NameEdit.SetValue(N);
		Initialized = true;

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
     ControlOffset=25
     PlayerBaseClass="dnGame.DukePlayer"
     NameText="Name:"
     NameHelp="Set your player name."
     TeamText="Team:"
     Teams(0)="Red"
     Teams(1)="Blue"
     Teams(2)="Green"
     Teams(3)="Gold"
     NoTeam="None"
     TeamHelp="Select the team you wish to play on."
     ClassText="Class:"
     ClassHelp="Select your player class."
     VoiceText="Sounds:"
     VoiceHelp="Select your player's sounds."
     MeshText="Mesh:"
     MeshHelp="Choose a model for your player."
     FaceText="Face:"
     FaceHelp="Choose a face for your player."
     TorsoText="Torso:"
     TorsoHelp="Choose a torso for your player."
     ArmsText="Arms:"
     ArmsHelp="Choose arms for your player."
     LegsText="Legs:"
     LegsHelp="Choose legs for your player."
     AuxText(0)="Decal 1:"
     AuxText(1)="Decal 2:"
     AuxText(2)="Decal 3:"
     AuxText(3)="Decal 4:"
     AuxHelp="Select auxilary decals for your player."
     TestVoiceText="Voice"
     TestVoiceHelp="Test the player's sounds."
     SpectatorText="Join as Spectator:"
     SpectatorHelp="Join the server as a Spectator."
     TestSoundsText="Test Sounds:"
     TestSoundsHelp="Use these buttons to test your sounds for your player."
     HitSoundText="HitSound:"
     HitSoundHelp="Sound effect to play when you damage an enemy"
     TestHitText="HitSound"
     TestHitHelp="Test the hit sound"
     bBuildDefaultButtons=False
}
