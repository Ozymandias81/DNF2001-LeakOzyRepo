//=====================================================================
// ULANGamesCW.uc  - Window for the LAN Games Interface
//
// NOTES:		    Creates 4 subsections (Create, Join, Controls, Setup)	
//  
//                  Create   - allows the user to configure and launch a LAN game
//                  Join     - allows the user to join a LAN game in prograss
//                  Controls - Shortcut to the controls menu
//                  Setup    - Shortcut to the player setup menu
//=====================================================================
class ULANGamesCW expands UDukePageWindow;

enum eTabType  
{
    eTAB_TYPE_CREATE,
    eTAB_TYPE_JOIN,
    eTAB_TYPE_PLAYERSETUP,
    eTAB_TYPE_MAX
};

const TAB_OFFSET  = 10;
const VERT_OFFSET = 10;

var()   localized string            strTabsText[4];		//eTAB_TYPE_MAX
var     UDukeTabControl             tabVerticalTabs[4]; //eTAB_TYPE_MAX
var     UDukeCreateMultiSC          winTabClientCreate;
var     UDukeJoinMultiSC            winTabClientJoin;
var     UDukePlayerSetupTopSC       winTabPlayerSetup;

function Created() 
{
	local INT i, iButtonPos_Y;
	local string strTexNames[4];
	local string strPlayerName;
	local Texture texButton;
	
    Super.Created();

	strTexNames[0] = "DukeLookAndFeel.DNCreate";
	strTexNames[1] = "DukeLookAndFeel.DNJoin";
    strTexNames[2] = "DukeLookAndFeel.DNJoin"; //"DukeLookAndFeel.DNControls";
    strTexNames[3] = "DukeLookAndFeel.DNJoin";

	for(i = eTabType.eTAB_TYPE_CREATE; i < eTabType.eTAB_TYPE_MAX; i++)
    {
		texButton       = Texture(DynamicLoadObject( strTexNames[i], class'Texture' ) );
		iButtonPos_Y    = ( WinHeight * ( ( i * 2 + 1 ) * 0.125 ) ) - (texButton.VSize / 2 );

		tabVerticalTabs[i] = UDukeTabControl( CreateWindow( class'UDukeTabControl', 
											 			    TAB_OFFSET / 2, iButtonPos_Y, 
											 			    texButton.USize, texButton.VSize * 1.2,
														    self ) );
		tabVerticalTabs[i].UpTexture   = texButton;
		tabVerticalTabs[i].OverTexture = Texture(DynamicLoadObject(strTexNames[i] $ "_fl", class'Texture'));
		tabVerticalTabs[i].DownTexture = texButton;
		tabVerticalTabs[i].SetText(strTabsText[i]);
		tabVerticalTabs[i].TextY = texButton.VSize;
	}

    // Make the window for the "Create a New Game" dialog
	winTabClientCreate = UDukeCreateMultiSC( CreateWindow(
                                                class'UDukeCreateMultiSC',
											    tabVerticalTabs[0].WinWidth + TAB_OFFSET, VERT_OFFSET, 
											    WinWidth - tabVerticalTabs[0].WinWidth - TAB_OFFSET, WinHeight - VERT_OFFSET,
											    self )
                                           );
    winTabClientCreate.HideWindow();

    // Make the window for the "Join a Game" dialog
	winTabClientJoin = UDukeJoinMultiSC( CreateWindow(
											    class'UDukeJoinMultiSC', 
											    tabVerticalTabs[0].WinWidth + TAB_OFFSET, VERT_OFFSET, 
												WinWidth - tabVerticalTabs[0].WinWidth - TAB_OFFSET, WinHeight - VERT_OFFSET,
												self )
                                            );
    
    winTabClientJoin.serverListFactoryType = "dnWindow.UDukeLocalFact";
    winTabClientJoin.HideWindow();

    // Make the window for the "Player Setup" dialog
	winTabPlayerSetup = UDukePlayerSetupTopSC( CreateWindow(
											   class'UDukePlayerSetupTopSC', 
											   tabVerticalTabs[0].WinWidth + TAB_OFFSET, VERT_OFFSET, 
											   WinWidth - tabVerticalTabs[0].WinWidth - TAB_OFFSET, WinHeight - VERT_OFFSET,
											   self )
                                             );
	winTabPlayerSetup.HideWindow();

    UDukeRootWindow(Root).Desktop.bHideSunglasses = true;

	//Setup tabs by clicking on the one to have open initially
    //Put code here to automatically click on one of the tabs if we need it
}

function Resized()
{
    local INT i;

    Super.Resized();

    for(i = eTabType.eTAB_TYPE_CREATE; i < eTabType.eTAB_TYPE_MAX; i++)
    {
        tabVerticalTabs[i].WinTop  = ( WinHeight * ( ( i * 2 + 1 ) * 0.125 ) ) - (tabVerticalTabs[i].UpTexture.VSize / 2 );
    }

    winTabClientJoin.SetSize( WinWidth - tabVerticalTabs[0].WinWidth - TAB_OFFSET, WinHeight - VERT_OFFSET );
    winTabClientCreate.SetSize( WinWidth - tabVerticalTabs[0].WinWidth - TAB_OFFSET, WinHeight - VERT_OFFSET );
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);
}

function ClosePressed()
{
	Close();
}

function Close( optional bool bByParent )
{
    UDukeRootWindow(Root).Desktop.bHideSunglasses = false;
    Super.Close( bByParent );
}

function SelectedThisTab(UDukeTabControl tabSelected)
{
    local INT i;
	
	//Want to unselect all the tabs, and hide all the windows,
	for(i = eTabType.eTAB_TYPE_CREATE; i < eTabType.eTAB_TYPE_MAX; i++)
		tabVerticalTabs[i].bTabIsDown = false;

	winTabClientCreate.HideWindow();
	winTabClientJoin.HideWindow();
	winTabPlayerSetup.HideWindow();

	//...then show the newly selected one
	if( tabSelected == tabVerticalTabs[eTabType.eTAB_TYPE_CREATE] ) 
		winTabClientCreate.ShowWindow();
	else if( tabSelected == tabVerticalTabs[eTabType.eTAB_TYPE_JOIN] ) 
		winTabClientJoin.ShowWindow();
	else if( tabSelected == tabVerticalTabs[eTabType.eTAB_TYPE_PLAYERSETUP] ) 
		winTabPlayerSetup.ShowWindow();
	else  
		Log("UI: ERROR! SelectedThisTab() called with invalid tabtype:"@tabSelected);
}

defaultproperties
{
     strTabsText(0)="Create"
     strTabsText(1)="Join"
     strTabsText(2)="Player Setup"
     bBuildDefaultButtons=False
     bNoScanLines=True
     bNoClientTexture=True
}
