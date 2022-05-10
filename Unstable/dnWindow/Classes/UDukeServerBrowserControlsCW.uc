/*-----------------------------------------------------------------------------
	UDukeServerBrowserControls
	Author: Brandon Reinhart, Scott Alden

	A small window of controls that head up the server browser.
-----------------------------------------------------------------------------*/
class UDukeServerBrowserControlsCW extends UDukePageWindow;

var		UDukeJoinMultiCW			JoinGameWindow;
var     UDukeServerBrowserCW        ServerBrowser;

// Refresh
var     UWindowSmallButton          RefreshButton;
var     localized string            RefreshText;
var     localized string            RefreshHelp;

// Local/Internet
var     UWindowSmallButton          LocalButton;
var     localized string            LocalText;
var     localized string            InternetText;
var     localized string            LocalHelp;

// Use Filters
var		UWindowLabelControl			UseFilterLabel;
var     UWindowCheckBox             UseFilterCheck;
var     localized string            UseFilterText;
var     localized string            UseFilterHelp;

// Filters
var		UWindowSmallButton			FiltersButton;
var		localized string			FiltersText;
var		localized string			FiltersHelp;

// Status Label
var     UWindowLabelControl         StatusLabel;

// Net Speed
var		UWindowLabelControl			NetSpeedLabel;
var		UWindowComboControl			NetSpeedCombo;
var		localized string			NetSpeedText;
var		localized string			NetSpeedHelp;
var		localized string			NetSpeeds[4];

var		bool						bInitialized;

function Created()
{
    // Filter checkbox
	UseFilterLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	UseFilterLabel.SetText(UseFilterText);
	UseFilterLabel.SetFont(F_Normal);
	UseFilterLabel.Align = TA_Right;

    UseFilterCheck = UWindowCheckbox( CreateControl( class'UWindowCheckbox', 1, 1, 1, 1 ) );
	UseFilterCheck.SetHelpText( UseFilterHelp );
	UseFilterCheck.SetFont( F_Normal );
	UseFilterCheck.Align = TA_Right;
    UseFilterCheck.bChecked = true;

    // Filters
	FiltersButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 1, 1, 1, 1 ) );
	FiltersButton.SetText( FiltersText );
	FiltersButton.SetFont( F_Normal );
	FiltersButton.SetHelpText( FiltersHelp );

    // Local
	LocalButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 1, 1, 1, 1 ) );
	LocalButton.SetText( LocalText );
	LocalButton.SetFont( F_Small );
	LocalButton.SetHelpText( LocalHelp );

    // Refresh
	RefreshButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 1, 1, 1, 1 ) );
	RefreshButton.SetText( RefreshText );
	RefreshButton.SetFont( F_Small );
	RefreshButton.SetHelpText( RefreshHelp );

    // Net Speed
	NetSpeedLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	NetSpeedLabel.SetText(NetSpeedText);
	NetSpeedLabel.SetFont(F_Normal);
	NetSpeedLabel.Align = TA_Right;

	NetSpeedCombo = UWindowComboControl( CreateControl( class'UWindowComboControl', 1, 1, 1, 1 ) );
	NetSpeedCombo.SetHelpText( NetSpeedHelp );
	NetSpeedCombo.SetFont( F_Normal );
	NetSpeedCombo.SetEditable( false );
	NetSpeedCombo.AddItem( NetSpeeds[0] );
	NetSpeedCombo.AddItem( NetSpeeds[1] );
	NetSpeedCombo.AddItem( NetSpeeds[2] );
	NetSpeedCombo.AddItem( NetSpeeds[3] );
	NetSpeedCombo.Align = TA_Right;

	if ( class'Player'.default.ConfiguredInternetSpeed > 12500 )
		NetSpeedCombo.SetSelectedIndex( 3 );
	else if ( class'Player'.default.ConfiguredInternetSpeed >= 6000 )
		NetSpeedCombo.SetSelectedIndex( 2 );
	else if ( class'Player'.default.ConfiguredInternetSpeed >= 4000 )
		NetSpeedCombo.SetSelectedIndex( 1 );
	else 
		NetSpeedCombo.SetSelectedIndex( 0 );

    StatusLabel = UWindowLabelControl( CreateControl( class'UWindowLabelControl', 1, 1, 1, 1 ) );
	StatusLabel.SetFont( F_Small );

	bInitialized = true;
	ResizeFrames = 3;
}

function BeforePaint( Canvas C, float X, Float Y )
{
	local int CenterWidth;
	local int CColLeft, CColRight;

	Super.BeforePaint(C, X, Y);

	if ( ResizeFrames == 0 )
		return;
	ResizeFrames--;

	CenterWidth = (WinWidth/4)*3;
	CColLeft = (WinWidth / 2) - 7;
	CColRight = (WinWidth / 2) + 7;

	FiltersButton.AutoSize(C);

	UseFilterLabel.AutoSize( C );
	UseFilterCheck.SetSize( 32, UseFilterCheck.WinHeight );

	UseFilterLabel.WinLeft = 10;
	UseFilterCheck.WinLeft = UseFilterLabel.WinLeft + UseFilterLabel.WinWidth + 5;

	UseFilterCheck.WinTop = (FiltersButton.WinHeight - UseFilterCheck.WinHeight)/2;
	UseFilterLabel.WinTop = UseFilterCheck.WinTop + 10;

	FiltersButton.WinTop = 0;
	FiltersButton.WinLeft = UseFilterCheck.WinLeft + UseFilterCheck.WinWidth + 20;

	NetSpeedLabel.AutoSize( C );
	NetSpeedCombo.SetSize( 150, NetSpeedCombo.WinHeight );

	NetSpeedLabel.WinLeft = FiltersButton.WinLeft + FiltersButton.WinWidth + 20;
	NetSpeedCombo.WinLeft = NetSpeedLabel.WinLeft + NetSpeedLabel.WinWidth + 5;

	NetSpeedCombo.WinTop = (FiltersButton.WinHeight - NetSpeedCombo.WinHeight)/2;
	NetSpeedLabel.WinTop = NetSpeedCombo.WinTop + 8;

	RefreshButton.AutoSize(C);
	RefreshButton.WinTop = FiltersButton.WinTop + FiltersButton.WinHeight;
	RefreshButton.WinLeft = 10;

	LocalButton.AutoSize(C);
	LocalButton.WinTop = RefreshButton.WinTop;
	LocalButton.WinLeft = RefreshButton.WinLeft + RefreshButton.WinWidth + 5;

	StatusLabel.AutoSize(C);
	StatusLabel.WinLeft = FiltersButton.WinLeft + 4;
	StatusLabel.WinTop = RefreshButton.WinTop + (RefreshButton.WinHeight - StatusLabel.WinHeight)/2;
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
            case FiltersButton:
				Root.ShowModal( JoinGameWindow.ServerFilterWindow );
//				JoinGameWindow.ServerFilterWindow.ShowWindow();
                break;
			case LocalButton:
				if ( LocalButton.Text == LocalText )
				{
					JoinGameWindow.ChangeBrowserMode(1);
					LocalButton.SetText( InternetText );
				}
				else
				{
					JoinGameWindow.ChangeBrowserMode(0);
					LocalButton.SetText( LocalText );
				}
				ResizeFrames = 3;
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

defaultproperties
{
    RefreshHelp="Refresh the list of servers."
    RefreshText="Refresh"
    UseFilterText="Use Filters:"
    UseFilterHelp="Turn on/off custom filters."
	NetSpeedText="Net Speed:"
	NetSpeedHelp="Select the closest match to your internet connection. Try selecting a lower setting if you're getting lag."
	NetSpeeds(0)="Modem (28.8K - 56K)"
	NetSpeeds(1)="ISDN"
	NetSpeeds(2)="Cable, xDSL"
	NetSpeeds(3)="LAN"
	FiltersText="Filters"
	FiltersHelp="Click to set up your custom server filters."
	LocalText="Local"
	InternetText="Internet"
	LocalHelp="Switch between LAN and Internet search."
}