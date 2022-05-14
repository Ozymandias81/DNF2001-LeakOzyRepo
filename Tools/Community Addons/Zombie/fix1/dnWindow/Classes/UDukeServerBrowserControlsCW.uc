class UDukeServerBrowserControlsCW extends UDukePageWindow;

var     UDukeServerBrowserCW        ServerBrowser;

// Buttons
var     UWindowSmallButton          RefreshButton;
var     localized string            RefreshText;
var     localized string            RefreshHelp;

// Use Filters
var     UWindowCheckBox             UseFilterCheck;
var     localized string            UseFilterText;
var     localized string            UseFilterHelp;

// Status Label
var     UWindowLabelControl         StatusLabel;
var     UWindowSmallButton          TestButton;

// Net Speed
var		UWindowComboControl			NetSpeedCombo;
var		localized string			NetSpeedText;
var		localized string			NetSpeedHelp;
var		localized string			NetSpeeds[4];

var		bool						bInitialized;

function Created()
{
    local int ControlWidth, ControlHeight;
    local int XOffset, YOffset;

    ControlWidth    = WinWidth / 10;
    ControlHeight   = 16;

    YOffset = ( WinHeight - ControlHeight ) / 2;
    XOffset = 10;

    // Filter checkbox
    UseFilterCheck = UWindowCheckbox( CreateControl( class'UWindowCheckbox', XOffset, YOffset, ControlWidth, ControlHeight ) );
	UseFilterCheck.SetText( UseFilterText );
	UseFilterCheck.SetHelpText( UseFilterHelp );
	UseFilterCheck.SetFont( F_Normal );
	UseFilterCheck.Align = TA_Left;
    UseFilterCheck.bChecked = true;
    
	XOffset += ControlWidth+5;

    // Refresh
	RefreshButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', XOffset, YOffset, ControlWidth, ControlHeight ) );
	RefreshButton.SetText( RefreshText );
	RefreshButton.SetFont( F_Normal );
	RefreshButton.SetHelpText( RefreshHelp );

    XOffset += ControlWidth+5;    

    // Net Speed
	ControlWidth = (WinWidth/4);
	NetSpeedCombo = UWindowComboControl( CreateControl( class'UWindowComboControl', XOffset, YOffset, ControlWidth , ControlHeight ) );
	NetSpeedCombo.SetText( NetSpeedText );
	NetSpeedCombo.SetHelpText( NetSpeedHelp );
	NetSpeedCombo.SetFont( F_Normal );
	NetSpeedCombo.SetEditable( false );
	NetSpeedCombo.AddItem( NetSpeeds[0] );
	NetSpeedCombo.AddItem( NetSpeeds[1] );
	NetSpeedCombo.AddItem( NetSpeeds[2] );
	NetSpeedCombo.AddItem( NetSpeeds[3] );

	if (class'Player'.default.ConfiguredInternetSpeed > 12500)
		NetSpeedCombo.SetSelectedIndex(3);
	else if (class'Player'.default.ConfiguredInternetSpeed >= 6000) 
		NetSpeedCombo.SetSelectedIndex(2);
	else if (class'Player'.default.ConfiguredInternetSpeed >= 4000) 
		NetSpeedCombo.SetSelectedIndex(1);
	else 
		NetSpeedCombo.SetSelectedIndex(0);

    // Test
    //TestButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', XOffset, YOffset, ControlWidth, ControlHeight ) );
	//TestButton.SetText( "Test" );
	//TestButton.SetFont( F_Normal );	

    XOffset += ControlWidth+15;    
    StatusLabel = UWindowLabelControl( CreateControl( class'UWindowLabelControl', XOffset, YOffset, WinWidth - XOffset, ControlHeight ) );

	bInitialized = true;
}

function Notify( UWindowDialogControl C, byte E )
{
	Super.Notify( C, E );
    
	switch( E )
	{
        case DE_Click:
            switch ( C )
            {
            case RefreshButton:
                if ( ServerBrowser != None )
                {
                    ServerBrowser.Refresh();
                }
                break;
            case TestButton:
                if ( ServerBrowser != None )
                {
                    ServerBrowser.TestList();
                    ServerBrowser.ApplyFilter();
                }
                break;
            }
            break;
        case DE_Change:
            switch ( C )
            {
            case UseFilterCheck:
                FilterChanged();
                break;
            case NetSpeedCombo:
                NetSpeedChanged();
                break;
            }
    }
}

function FilterChanged()
{
    if ( ServerBrowser != None )
    {
        ServerBrowser.bUseFilter = UseFilterCheck.bChecked;
        ServerBrowser.ApplyFilter();
    }
}

function NetSpeedChanged()
{
	local int NewSpeed;

	if ( !bInitialized )
		return;

	switch( NetSpeedCombo.GetSelectedIndex() )
	{
		case 0:
			NewSpeed = 2600;
			break;
		case 1:
			NewSpeed = 5000;
			break;
		case 2:
			NewSpeed = 10000;
			break;
		case 3:
			NewSpeed = 20000;
			break;
	}
	GetPlayerOwner().ConsoleCommand( "NETSPEED "$NewSpeed );
}

function BeforePaint( Canvas C, float X, Float Y )
{
    Super.BeforePaint( C, X, Y );    
}

defaultproperties
{
     RefreshText="Refresh"
     RefreshHelp="Refresh the list of servers"
     UseFilterText="Filters"
     UseFilterHelp="Turn on/off custom filters"
     NetSpeedText="Net Speed"
     NetSpeedHelp="Select the closest match to your internet connection. Try selecting a lower setting if you're getting huge lag."
     NetSpeeds(0)="Modem (28.8K - 56K)"
     NetSpeeds(1)="ISDN"
     NetSpeeds(2)="Cable, xDSL"
     NetSpeeds(3)="LAN"
     bBuildDefaultButtons=False
     bNoScanLines=True
     bNoClientTexture=True
}
