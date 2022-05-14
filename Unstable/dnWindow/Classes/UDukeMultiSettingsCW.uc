class UDukeMultiSettingsCW expands UDukePageWindow;

// Respawn Markers
var UWindowCheckbox     RespawnMarkersCheck;
var localized string    RespawnMarkersText;
var localized string    RespawnMarkersHelp;
var bool				Initialized;
var UDukeCreateMultiCW  myParent;

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight, ControlOffset;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

    Super.Created();

	ControlWidth    = WinWidth/2.5;
	ControlLeft     = ( WinWidth/2 - ControlWidth )/2;
	ControlRight    = WinWidth/2 + ControlLeft;

	CenterWidth     = ( WinWidth/4 )*3;
	CenterPos       = ( WinWidth - CenterWidth )/2;

	ButtonWidth     = WinWidth - 140;
	ButtonLeft      = WinWidth - ButtonWidth - 40;

	myParent        = UDukeCreateMultiCW( GetParent( class'UDukeCreateMultiCW' ) );

	if ( myParent == None )
    {
		Log( "Error: UDukeMultiSettingsCW without UDukeCreateMultiCW parent." );
    }

	ControlOffset += 25;
	// Respawn Markers
	RespawnMarkersCheck = UWindowCheckbox( CreateControl( class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1 ) );
	RespawnMarkersCheck.SetText( RespawnMarkersText );
	RespawnMarkersCheck.SetHelpText( RespawnMarkersHelp );
	RespawnMarkersCheck.SetFont( F_Normal );
	RespawnMarkersCheck.bChecked = myParent.GameClass.Default.bRespawnMarkers;
	RespawnMarkersCheck.Align = TA_Right;
	ControlOffset += 25;
}

function AfterCreate()
{
	LoadCurrentValues();
	Initialized = true;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	Super.BeforePaint( C, X, Y );

	ControlWidth = WinWidth/2.5;
	ControlLeft = ( WinWidth/2 - ControlWidth )/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = ( WinWidth/4 )*3;
	CenterPos = ( WinWidth - CenterWidth )/2;

	RespawnMarkersCheck.SetSize( ControlWidth, 1 );
	RespawnMarkersCheck.WinLeft = ControlLeft;
}

function LoadCurrentValues()
{
	RespawnMarkersCheck.bChecked = Class<dnDeathMatchGame>(myParent.GameClass).Default.bRespawnMarkers;
}

function RespawnMarkersChecked()
{
	Class<dnDeathMatchGame>(myParent.GameClass).Default.bRespawnMarkers = RespawnMarkersCheck.bChecked;
}

function Notify( UWindowDialogControl C, byte E )
{
	if ( !Initialized )
		return;

	Super.Notify( C, E );

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
		case RespawnMarkersCheck:
				RespawnMarkersChecked();
				break;
		}
	}
}

defaultproperties
{
     RespawnMarkersText="Respawn Markers"
     RespawnMarkersHelp="If checked, respawn markers will be visible."
     bBuildDefaultButtons=False
     bNoScanLines=True
     bNoClientTexture=True
}
