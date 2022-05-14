class UDukePlayerMeshCW extends UDukePageWindow;

var UWindowSmallButton  FaceButton;
var localized string    FaceText, BodyText;
var UWindowButton       CenterButton;
var UWindowButton       LeftButton, RightButton;

var MeshActor           MeshActor;

var rotator             CenterRotator, ViewRotator;
var bool                bFace, bRotate, bTween;

var UWindowComboControl AnimCombo;
var localized string    AnimText;
var localized string    AnimNames[4];
var localized string    Anims[4];
var localized string    AnimHelp;
var name                CurrentAnim;

function Created()
{
    local vector newLoc;
    local int i;

	Super.Created();

	MeshActor       = GetEntryLevel().Spawn( class'MeshActor', GetEntryLevel() );
	MeshActor.Mesh  = GetPlayerOwner().Mesh;

    for ( i=0; i<8; i++ )
    {
        MeshActor.MultiSkins[i] = GetPlayerOwner().MultiSkins[i];
    }

	MeshActor.NotifyClient = Self;

	if ( MeshActor.Mesh != None )
    {        
        CurrentAnim = 'A_IdleStandInactive2';
		MeshActor.PlayAnim( CurrentAnim, 1.0, 0.1 );
    }

    ViewRotator = rot( 0, 32768, 0 );

	CenterButton = UWindowButton( CreateControl( class'UWindowButton', WinWidth/3, 0, WinWidth/3, WinHeight ) );
	CenterButton.bIgnoreLDoubleclick = true;
	
	LeftButton = UWindowButton( CreateControl( class'UWindowButton', 0, 0, WinWidth/3, WinHeight ) );
	LeftButton.bIgnoreLDoubleclick  = true;

	RightButton = UWindowButton( CreateControl( class'UWindowButton', (WinWidth/3)*2, 0, WinWidth/3, WinHeight ) );
	RightButton.bIgnoreLDoubleclick = true;

	FaceButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 0, 16, 48, 16 ) );
	FaceButton.Text                 = FaceText;
	FaceButton.bAlwaysOnTop         = true;
	FaceButton.bIgnoreLDoubleclick  = true;

	AnimCombo = UWindowComboControl( CreateControl( class'UWindowComboControl', WinWidth - 128, 16, 128, 1 ) );
	AnimCombo.SetText(AnimText);
	AnimCombo.SetHelpText(AnimHelp);
	AnimCombo.SetEditable(false);
	AnimCombo.SetFont(F_Normal);
    AnimCombo.bAlwaysOnTop = true;

    for ( i=0; i<4; i++ )
    {
        AnimCombo.AddItem( AnimNames[i], Anims[i] );
    }
    AnimCombo.SetSelectedIndex( 0 );
}

function Resized()
{
	Super.Resized();

	CenterButton.SetSize(WinWidth/3, WinHeight);
	CenterButton.WinLeft	= WinWidth/3;

	LeftButton.SetSize(WinWidth/3, WinHeight);
	LeftButton.WinLeft		= 0;

	RightButton.SetSize(WinWidth/3, WinHeight);
	RightButton.WinLeft		= (WinWidth/3)*2;

	FaceButton.WinLeft		= 10;
	FaceButton.WinTop		= 16;

	AnimCombo.WinLeft		= WinWidth - 128;
	AnimCombo.WinTop		= 16;
}

function BeforePaint( Canvas C, float X, float Y )
{
	FaceButton.AutoWidth(C);

    if ( LeftButton.bMouseDown )
    {
		ViewRotator.Yaw += 512;
    }
    else if ( RightButton.bMouseDown )
    {
		ViewRotator.Yaw -= 512;
	}	
}

function Close( optional bool bByParent )
{
	Super.Close(bByParent);

    if( MeshActor != None )
	{
		MeshActor.Destroy();
		MeshActor = None;
	}
}

function AnimEnd( MeshActor MyMesh )
{
    if( MeshActor.Mesh != None )
    {
	    MeshActor.PlayAnim( CurrentAnim, 1.0, 0.1 );
    }
}

function PlaySoundThruMesh( sound Sound )
{
	if ( MeshActor != None )
	{
		MeshActor.PlaySound( Sound, SLOT_Interface, 1.0f, , , , true );
	}
}

function Paint( Canvas C, float X, float Y ) 
{
	local float OldFov;
    local vector newLoc;
    local MeshInstance minst;
    local vector min, max;
    local float OffsetX, OffsetY, OffsetZ;
    local float FOV;

	if ( MeshActor != None )
	{    
        minst = MeshActor.GetMeshInstance();
        
        OldFov = GetPlayerOwner().FOVAngle;		

        GetPlayerOwner().SetFOVAngle(30);

        if ( minst != None )
        {
            // Center the model in the port
            minst.GetBounds( min, max );            

        	FOV = GetPlayerOwner().FOVAngle * Pi / 180;
	
            if ( bFace )
                OffsetX = ( 0.18 * ( Max.Z - Min.Z ) ) / tan( FOV/2 );
            else
                OffsetX = ( 0.5 * ( Max.Z - Min.Z ) ) / tan( FOV/2 );

            OffsetY = -0.5 * ( Min.Y + Max.Y );
            OffsetZ = -0.5 * ( Min.Z + Max.Z );
        }
		
        if ( bFace )
            OffsetZ += OffsetZ * 0.7;

		DrawClippedActor( C, WinWidth/2, WinHeight/2, MeshActor, false, ViewRotator, vect( OffsetX, OffsetY, OffsetZ ) );
		
        GetPlayerOwner().SetFOVAngle( OldFov );
	}
}

function Notify(UWindowDialogControl C, byte E)
{
	switch (E)
	{
		case DE_Click:
			switch (C)
			{
				case FaceButton:
					FacePressed();
					break;
				case CenterButton:
					ViewRotator = rot(0, 32768, 0) + CenterRotator;
					break;
			}
			break;
        case DE_Change:
            switch (C)
            {
            case AnimCombo:
                AnimChanged();
                break;
            }
            break;
	}
}

function AnimChanged()
{
    local string val;
    
    val = AnimCombo.GetValue2();

    if ( MeshActor != None )
    {
        CurrentAnim = MeshActor.NameForString( val );
        AnimEnd( MeshActor );
    }
}

function FacePressed()
{
	bFace = !bFace;
	if (bFace)
		FaceButton.Text = BodyText;
	else
		FaceButton.Text = FaceText;
}

function Tick( float Delta )
{
	if ( bRotate )
		ViewRotator.Yaw += 128;
}

function SetMesh( mesh NewMesh )
{
	MeshActor.bMeshEnviroMap    = false;
	MeshActor.DrawScale         = MeshActor.Default.DrawScale;
	MeshActor.Mesh              = NewMesh;
}

function SetMeshString( string MeshName )
{
    local DukeMesh NewMesh;

    NewMesh = DukeMesh( DynamicLoadObject( MeshName, Class'DukeMesh') );

    if ( NewMesh != None )
    	SetMesh( NewMesh );
}

function ClearSkins()
{
	local int i;

	MeshActor.Skin = None;
	for( i=0; i<4; i++ )
    {
        MeshActor.MultiSkins[i] = None;
    }
}

function SetSkin( string Face, string Torso, string Arms, string Legs, string Aux1, string Aux2, string Aux3, string Aux4 )
{
    local int i;

	ClearSkins();

    if ( Face != "" )
        MeshActor.MultiSkins[0] = Texture( DynamicLoadObject( Face,  class'Texture' ) );
    
    if ( Torso != "" )
        MeshActor.MultiSkins[1] = Texture( DynamicLoadObject( Torso, class'Texture' ) );
    
    if ( Legs != "" )
        MeshActor.MultiSkins[2] = Texture( DynamicLoadObject( Legs,  class'Texture' ) );
    
    if ( Arms != "" )
        MeshActor.MultiSkins[3] = Texture( DynamicLoadObject( Arms,  class'Texture' ) );
    
    if ( Aux1 != "" )
        MeshActor.MultiSkins[4] = Texture( DynamicLoadObject( Aux1, class'Texture' ) );

    if ( Aux2 != "" )
        MeshActor.MultiSkins[5] = Texture( DynamicLoadObject( Aux2, class'Texture' ) );
    
    if ( Aux3 != "" )
        MeshActor.MultiSkins[6] = Texture( DynamicLoadObject( Aux3, class'Texture' ) );
    
    if ( Aux4 != "" )
        MeshActor.MultiSkins[7] = Texture( DynamicLoadObject( Aux4, class'Texture' ) );
}

defaultproperties
{
     FaceText="Zoom Face"
     BodyText="Zoom Body"
     AnimText="Anim:"
     AnimNames(0)="Idle"
     AnimNames(1)="Walk"
     AnimNames(2)="Run"
     AnimNames(3)="Freeze"
     Anims(0)="A_IdleStandInactive2"
     Anims(1)="A_Walk"
     Anims(2)="A_Run"
     Anims(3)="None"
     AnimHelp="Choose an anim to look at"
     bBuildDefaultButtons=False
}
