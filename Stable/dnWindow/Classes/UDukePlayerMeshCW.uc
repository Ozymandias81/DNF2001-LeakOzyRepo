/*-----------------------------------------------------------------------------
	UDukePlayerMeshCW
	Author: Scott Alden, Brandon Reinhart
-----------------------------------------------------------------------------*/
class UDukePlayerMeshCW extends UDukePageWindow;

var UWindowSmallButton  FaceButton, NextButton;
var localized string    ZoomText, AnimText;
var UWindowButton       CenterButton;
var UWindowButton       LeftButton, RightButton;

var MeshActor           MeshActor;

var rotator             CenterRotator, ViewRotator;
var bool                bFace, bRotate, bTween;

var localized string    AnimNames[4];
var localized string    Anims[4];
var name                CurrentAnim;
var int					IconSize;
var int					AnimIndex;

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

	// Center
	CenterButton = UWindowButton( CreateControl( class'UWindowButton', 1, 1, 1, 1 ) );
	CenterButton.bIgnoreLDoubleclick = true;
	
	// Spin Left
	LeftButton = UWindowButton( CreateControl( class'UWindowButton', 1, 1, 1, 1 ) );
	LeftButton.bIgnoreLDoubleclick  = true;

	// Spin Right
	RightButton = UWindowButton( CreateControl( class'UWindowButton', 1, 1, 1, 1 ) );
	RightButton.bIgnoreLDoubleclick = true;

	// Face
	FaceButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 1, 1, 1, 1 ) );
	FaceButton.SetText( ZoomText );
	FaceButton.bAlwaysOnTop         = true;
	FaceButton.bIgnoreLDoubleclick  = true;

	// Next
	NextButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 1, 1, 1, 1 ) );
	NextButton.SetText( AnimText );
	NextButton.bAlwaysOnTop         = true;
	NextButton.bIgnoreLDoubleclick  = true;

	ResizeFrames = 3;
}

function BeforePaint( Canvas C, float X, float Y )
{
	local float BBWidth, BBHeight;

	if ( ResizeFrames == 0 )
		return;
	ResizeFrames--;

	BBWidth = (WinWidth-40)/3.f;
	BBHeight = WinHeight-180;

	NextButton.AutoSize( C );
	NextButton.WinTop = 10;
	NextButton.WinLeft = WinWidth - 10 - NextButton.WinWidth;

	FaceButton.AutoSize( C );
	FaceButton.WinTop = 10;
	FaceButton.WinLeft = NextButton.WinLeft - 5 - FaceButton.WinWidth;

	LeftButton.SetSize( BBWidth, BBHeight );
	LeftButton.WinTop = 100;
	LeftButton.WinLeft = 10;

	CenterButton.SetSize( BBWidth, BBHeight );
	CenterButton.WinTop = 100;
	CenterButton.WinLeft = LeftButton.WinLeft + LeftButton.WinWidth;

	RightButton.SetSize( BBWidth, BBHeight );
	RightButton.WinTop = 100;
	RightButton.WinLeft = CenterButton.WinLeft + CenterButton.WinWidth;

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

	LookAndFeel.Bevel_DrawSimpleBevel( Self, C, 7, FaceButton.WinTop + FaceButton.WinHeight + 10, WinWidth-22, WinHeight-80 );

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

		if ( MeshActor.Icon != None )
		{
			C.SetPos( 7, FaceButton.WinTop + FaceButton.WinHeight + 10 );
			C.DrawTile( MeshActor.Icon, IconSize, IconSize, 0, 0, MeshActor.Icon.USize, MeshActor.Icon.VSize );
		}

		ClipText( C, 7, WinHeight-35, "Animation:"@AnimNames[AnimIndex] );
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
				case NextButton:
					AnimChanged();
					break;
				case CenterButton:
					ViewRotator = rot(0, 32768, 0) + CenterRotator;
					break;
			}
			break;
	}
}

function AnimChanged()
{
	AnimIndex++;
	if ( AnimIndex > 3 )
		AnimIndex = 0;

    if ( MeshActor != None )
    {
        CurrentAnim = MeshActor.NameForString( Anims[AnimIndex] );
        AnimEnd( MeshActor );
    }
}

function FacePressed()
{
	bFace = !bFace;
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
	for( i=0; i<8; i++ )
    {
        MeshActor.MultiSkins[i] = None;
    }
}

function SetSkin( string Face, string Torso, string Arms, string Legs, string Icon )
{
    local int i;

	ClearSkins();
	
	MeshActor.Icon = None;

    if ( Face != "" )
        MeshActor.MultiSkins[0] = Texture( DynamicLoadObject( Face,  class'Texture' ) );
    
    if ( Torso != "" )
        MeshActor.MultiSkins[1] = Texture( DynamicLoadObject( Torso, class'Texture' ) );
    
    if ( Legs != "" )
        MeshActor.MultiSkins[2] = Texture( DynamicLoadObject( Legs,  class'Texture' ) );
    
    if ( Arms != "" )
        MeshActor.MultiSkins[3] = Texture( DynamicLoadObject( Arms,  class'Texture' ) );
    
	if ( Icon != "" )
        MeshActor.Icon = Texture( DynamicLoadObject( Icon, class'Texture' ) );
}

defaultproperties
{
    bBuildDefaultButtons=false
	ZoomText="Zoom"
	AnimText="Anim"
    AnimNames(0)="Idle"
    AnimNames(1)="Walk"
    AnimNames(2)="Run"
    AnimNames(3)="Freeze"
    Anims(0)="A_IdleStandInactive2"
    Anims(1)="A_Walk"
    Anims(2)="A_Run"
    Anims(3)="None"
	IconSize=64
	AnimIndex=0
}
