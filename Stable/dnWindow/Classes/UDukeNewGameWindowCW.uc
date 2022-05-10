//==========================================================================
// 
// FILE:			UDukeNewGameWindowCW.uc
// 
// AUTHOR:			John Pollard
// 
// DESCRIPTION:		New Game menu selections
// 
//==========================================================================
class UDukeNewGameWindowCW extends UWindowDialogClientWindow;

//
// NOTEZ -
//	Location is a group of maps.  Each location has a combo box, 
//	with a list of each map that belongs to that location.
//	
//

const	MAX_LOCATIONS	= 128;
const	MAX_MAPS		= 128;

// I didn't want this data in the MapInfoData, because it showed up in the .ini file after a Saveconfig()...
struct MapInfoRunTimeData
{
	var texture				Screenshot;			// Set at run-time
	var int					LocationIndex;		// Location that this map is attached to
};

var MapLocations			MapList;

var MapInfoRunTimeData		MapsRuntime[128];

// 
struct LocationData
{
	var string						Name;
	var	UWindowComboControl			ComboBox;			// Names map back to Name/URL in MapInfoData
	var int							MapIndex;			// Current map selected in this area
};

struct ScreenshotDrawInfo
{
	var int							PosX;
	var int							PosY;
	var texture						Screenshot;
	var bool						bSolid;
};

var ScreenshotDrawInfo				SShots[5];			// 3 visible, 2 offscreen to support scrolling left/right

var UWindowButton					SSButtons[3];		// Buttons used to allow them to click on screenshots

var UDukeArrowButton				NextButton;			// Button to scroll right
var UDukeArrowButton				PrevButton;			// Button to scroll left

var	LocationData					Locations[128];		// Holds combo box with names of all subchunk maps of this location
var	int								NumLocations;		// Number of locations
var int								CurLocation;		// Current location selected
var int								OldLocation;

var int								ScrollingDir;
var float							ScrollPos;
var float							OldScrollPos;

var bool							bMainCreated;
var bool							bInNotify;

var int								LoadWaitTime, LoadWaitLength;

enum EWindowMode
{
	WMode_Main,
};

var EWindowMode						CurrentMode;

const	MainWidth		= 475;
const	MainHeight		= 370;
const	ButtonSpacing	= 20;

const	ButtonWidth		= 256;
const	ButtonHeight	= 192;

const	ButtonY			= 30;
const	ComboYLoc		= 240;
const	ScrollButtonY	= 240;

//==========================================================================================
//	Created
//==========================================================================================
function Created() 
{
	bInNotify = false;

	Super.Created();
}

//==========================================================================================
//	AfterCreate
//==========================================================================================
function AfterCreate()
{
	Super.AfterCreate();

	MapList = New(None) class'MapLocations';

	ShowMainMenu();
//	ChangeWindowModes(WMode_Main);
}

//==========================================================================================
//	SetLocationMapIndex
//==========================================================================================
function SetLocationMapIndex(out LocationData Location, int MapIndex)
{
	Location.MapIndex = MapIndex;
}

//==========================================================================================
//	AddLocation
//==========================================================================================
function int AddLocation(int MapIndex)
{
	local int	W, H, i, LocX, LocY;

	if (NumLocations >= MAX_LOCATIONS)
		return -1;		// Doh, too many locations

	i = NumLocations;

	// Default the locations map to -1
	Locations[i].MapIndex = -1;

	// Setup width and height
	W = ButtonWidth;
	H = ButtonHeight;

	//if (W > 200)
	//	W = 200;

	LocX = (WinWidth - W)*0.5f;
	LocY = ComboYLoc;

	// Combo box
	Locations[i].ComboBox = UWindowComboControl(CreateControl(class'UWindowComboControl', 
													LocX, 
													LocY,
													W,
													1));
	
	Locations[i].ComboBox.bAcceptsFocus = false;
	Locations[i].ComboBox.SetText("");
	Locations[i].ComboBox.SetHelpText("Select your starting sub location here.");
	Locations[i].ComboBox.SetEditable( false );
	Locations[i].ComboBox.Align = TA_Right;

	Locations[i].ComboBox.WinLeft = LocX;
//	Locations[i].ComboBox.EditBoxWidth = W;

	Locations[i].ComboBox.Clear();
	Locations[i].ComboBox.List.MaxVisible = 5;
	Locations[i].ComboBox.List.bAcceptsFocus = false;

	//Locations[i].Name = Map.Location;
	Locations[i].Name = MapList.Maps[MapIndex].Location;

	Locations[i].ComboBox.HideWindow();		// Each combo box not visible by default

	NumLocations++;

	return i;
}

//==========================================================================================
//	AddMap
//==========================================================================================
function AddMap(int MapIndex)
{
	local int			i;

	if (!MapList.Maps[MapIndex].Enabled)
		return;

	// First, see if the location exists
	for (i=0; i<NumLocations; i++)
	{
		if (Locations[i].Name == MapList.Maps[MapIndex].Location)
			break;
	}

	if (i == NumLocations)	
	{
		// Location does not exist, Create a new location
		i = AddLocation(MapIndex);

		if (i == -1)
			return;		// Oh well
	}
	
	// Remember what maplocationindex this map is under
	MapsRuntime[MapIndex].LocationIndex = i;

	
	// Load the maps screenshot
	if (MapList.Maps[MapIndex].SShot != "")
		MapsRuntime[MapIndex].Screenshot = texture(DynamicLoadObject("Screenshots."$MapList.Maps[MapIndex].SShot, class'Texture'));
	
	// If there was not an SShot override, or it failed to load, try for the map URL as SShot
	if (MapsRuntime[MapIndex].Screenshot == None)
		MapsRuntime[MapIndex].Screenshot = texture(DynamicLoadObject("Screenshots."$MapList.Maps[MapIndex].URL, class'Texture'));
	
	// Still no screenshot, last ditch effort, load the default
	if (MapsRuntime[MapIndex].Screenshot == None)
		MapsRuntime[MapIndex].Screenshot = texture(DynamicLoadObject("Screenshots.Default", class'Texture'));

	// Add the map to the combo box under the location it belongs to
	Locations[i].ComboBox.AddItem(MapList.Maps[MapIndex].Name, MapList.Maps[MapIndex].URL);

	// See if we need to set the default (only want to do it on the first map)
	if (Locations[i].ComboBox.GetValue() == "")
	{
		Locations[i].ComboBox.SetValue(MapList.Maps[MapIndex].Name, MapList.Maps[MapIndex].URL);
		SetLocationMapIndex(Locations[i], MapIndex);
	}
}

//==========================================================================================
//	ShowMainMenu
//==========================================================================================
function ShowMainMenu()
{
	local int	LocX, LocY, W, H, i, ButtonLen;

	if (bMainCreated)
		return;

	OldLocation = -1;		// Force update for first time
	OldScrollPos = -1;		// Force update for first time
	ScrollPos = 0;

	W = ButtonWidth;
	H = ButtonHeight;

	ButtonLen = (ButtonWidth+ButtonSpacing)*3;
	LocY = ButtonY;
	LocX = (WinWidth - ButtonLen)*0.5f;

	//
	// Create the buttons
	//
	for (i=0; i<3; i++)
	{
		SSButtons[i] = UWindowButton( CreateControl( class'UWindowButton', LocX, LocY, W, H));
		SSButtons[i].bSolid = false;
		SSButtons[i].SetHelpText("");
		SSButtons[i].bAcceptsFocus = false;
		SSButtons[i].bNoClickSound = true;
		//SSButtons[i].bDisabled = true;

		LocX += ButtonWidth+ButtonSpacing;
	}
	
	for (i=0; i<5; i++)
	{
		SShots[i].bSolid = false;
		SShots[i].PosX = 0;
		SShots[i].PosY = ButtonY;
	}

	// Scroll left button
	PrevButton = UDukeArrowButton( CreateControl( class'UDukeArrowButton', WinWidth/2-256/2-36, ScrollButtonY, 36, 29 ) );
	PrevButton.SetHelpText("Scroll map selection left.");
	PrevButton.bLeft = true;

	// Scroll right button
	NextButton = UDukeArrowButton( CreateControl( class'UDukeArrowButton', WinWidth/2+256/2, ScrollButtonY, 36, 29 ) );
	NextButton.SetHelpText("Scroll map selection right.");

	// Reset the number of locations
	NumLocations = 0;

	if (MapList.NumMaps > MAX_MAPS)
		MapList.NumMaps = MAX_MAPS;

	// Add all the maps
	for (i=0; i< MapList.NumMaps; i++)
		AddMap(i);

	// Update buttons for first time
	UpdateButtons();

	bAcceptsFocus = true;

	bMainCreated = true;
}

//==========================================================================================
//	HideMainMenu
//==========================================================================================
function HideMainMenu()
{
	local int		i;

	if (bMainCreated)
	{
	}
}

//==========================================================================================
//	SetButtonPos
//==========================================================================================
function SetButtonPos(int ButtonIndex, float Pos)
{
	SShots[ButtonIndex].PosX = Pos;
}

//==========================================================================================
//	SetButtonPositions
//==========================================================================================
function SetButtonPositions(float ScrollPos)
{
	local int		i;
	local float		Pos, ButtonLen;

	ButtonLen = (ButtonWidth+ButtonSpacing) * 5;
	Pos = (WinWidth - ButtonLen)/2 + ScrollPos + 10;

	for (i=0; i< 5; i++)
	{
		SetButtonPos(i, Pos);
		Pos += ButtonWidth+ButtonSpacing;		// Space buttons out equally
	}
}

//==========================================================================================
//	SetupButton
//==========================================================================================
function SetupButton(int ButtonIndex, texture Tex)
{
	SShots[ButtonIndex].Screenshot = Tex;
}

//==========================================================================================
//	SetupButtons
//==========================================================================================
function SetupButtons()
{
	local int		i, i2;

	i2 = CurLocation-2;

	// Assign proper textures to the buttons
	for (i=0; i< 5; i++)
	{
		if (i2 >= 0 && i2 < NumLocations)
			SetupButton(i, MapsRuntime[Locations[i2].MapIndex].Screenshot);
		else
			SetupButton(i, None);

		i2++;
	}
	
	Locations[CurLocation].ComboBox.ShowWindow();
}

//==========================================================================================
//	UpdateButtons
//==========================================================================================
function UpdateButtons()
{
	if (OldSCrollPos != ScrollPos)
	{
		SetButtonPositions(ScrollPos);
		OldSCrollPos = ScrollPos;
	}

	if (OldLocation != CurLocation)
	{
		if (OldLocation >=0 && OldLocation < NumLocations)
			Locations[OldLocation].ComboBox.HideWindow();

		if (CurLocation >=0 && CurLocation < NumLocations)
		{
			SetupButtons();
			Locations[CurLocation].ComboBox.ShowWindow();
		}

		OldLocation = CurLocation;
	}
}

//==========================================================================================
//	HandleScrolling
//==========================================================================================
function HandleScrolling()
{
	local int		Index;
	local float		ButtonLen;

	if (ScrollingDir == 0)
	{
		SShots[2].bSolid = true;
		return;
	}

	SShots[2].bSolid = false;

	ButtonLen = (ButtonWidth+ButtonSpacing)*3;

	if (ScrollingDir < 0)
	{
		ScrollPos -= MapList.ScrollSpeed*GetPlayerOwner().Level.TimeDeltaSeconds*100.0f;

		if (ScrollPos <= -(ButtonWidth+ButtonSpacing))
		{
			CurLocation++;

			if ((NextButton.bMouseDown || SSButtons[2].bMouseDown) && ScrollLeft())		// Keep scrolling
			{
				ScrollPos += (ButtonWidth+ButtonSpacing);
			}
			else
			{
				ScrollPos = 0;
				ScrollingDir = 0;
			}
		}
	}

	if (ScrollingDir > 0)
	{
		ScrollPos += MapList.ScrollSpeed*GetPlayerOwner().Level.TimeDeltaSeconds*100.0f;

		if (ScrollPos >= (ButtonWidth+ButtonSpacing))
		{
			CurLocation--;

			if ((PrevButton.bMouseDown || SSButtons[0].bMouseDown) && ScrollRight())	// Keep scrolling
			{
				ScrollPos -= (ButtonWidth+ButtonSpacing);
			}
			else
			{
				ScrollPos = 0;
				ScrollingDir = 0;
			}
		}
	}
	
	Index = FindMapByURLAndName(Locations[CurLocation].ComboBox.GetValue(), Locations[CurLocation].ComboBox.GetValue2());
		
	if (Index != -1)
		SetLocationMapIndex(Locations[CurLocation], Index);
}

//==========================================================================================
//	BeforePaint
//==========================================================================================
function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

//	UpdateWindowMode();

	if ( LoadWaitTime > 0 )
		return;

	if (NextButton.bMouseDown || SSButtons[2].bMouseDown)
		ScrollLeft();
	else if (PrevButton.bMouseDown || SSButtons[0].bMouseDown)
		ScrollRight();
	
	if (ScrollingDir != 0 && Locations[CurLocation].ComboBox.bListVisible)
		Locations[CurLocation].ComboBox.CloseUp();

	HandleScrolling();

	UpdateButtons();
}

//==========================================================================================
//	Paint
//==========================================================================================
function Paint( Canvas C, float MouseX, float MouseY )
{
	local float			W, H, LocX, LocY;
	local int			TopMargin, i;

	Super.Paint( C, MouseX, MouseY );

	C.DrawColor = Root.WhiteColor;

	TopMargin = LookAndFeel.ColumnHeadingHeight;

	// F_Normal = 0, F_Bold, F_Large = 2, F_LargeBold, F_Heavy, F_HeavyBold
	if ( CurLocation >=0 && CurLocation < NumLocations )
	{
		C.Font = Root.Fonts[F_Bold];
		C.DrawColor = LookAndFeel.GetTextColor( Self );

		TextSize( C, Locations[CurLocation].Name, W, H );

		ClipText( C, (WinWidth-W)*0.5f, TopMargin-5, Locations[CurLocation].Name);
	}
	
	LocX = (WinWidth - ButtonWidth)*0.5;
	LocY = ButtonY;

	LookAndFeel.Bevel_DrawSimpleBevel( Self, C, LocX, LocY, ButtonWidth, ButtonHeight );

	C.DrawColor = Root.WhiteColor;
	if ( (MouseX > LocX) && (MouseX < LocX + ButtonWidth) && (MouseY > LocY) && (MouseY < LocY+ButtonHeight) && (ScrollingDir == 0) )
	{
		C.Style = 3;
		DrawStretchedTexture( C, LocX+2, LocY, ButtonWidth-4, 2, Texture'WhiteTexture', 0.5 );					// Top
		DrawStretchedTexture( C, LocX+2, LocY+ButtonHeight-2, ButtonWidth-4, 2, Texture'WhiteTexture', 0.5 );	// Botton
		DrawStretchedTexture( C, LocX, LocY, 2, ButtonHeight, Texture'WhiteTexture', 0.5 );						// Left
		DrawStretchedTexture( C, LocX+ButtonWidth-2, LocY, 2, ButtonHeight, Texture'WhiteTexture', 0.5 );		// Right
	}

	// Paint the screenshots
	for ( i=0; i<5; i++ )
	{
		if ( SShots[i].PosX > WinWidth )
			continue;
		if ( SShots[i].PosX+ButtonWidth < 0 )
			continue;

		C.Style = 1;

		if ( SShots[i].Screenshot != None )
		{
			W = SShots[i].Screenshot.USize;
			H = SShots[i].Screenshot.VSize;

			if ( SShots[i].bSolid )
			{
				C.Style = GetPlayerOwner().ERenderStyle.STY_Translucent;
				DrawStretchedTexture(C, SShots[i].PosX, SShots[i].PosY - 32, W, H, SShots[i].Screenshot, 1.0);
			}
			else
			{
				DrawStretchedTexture(C, SShots[i].PosX, SShots[i].PosY - 32, W, H, SShots[i].Screenshot, 0.7);
			}
		}
	}
}

//==========================================================================================
//	MessageBoxDone
//==========================================================================================
function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	ParentWindow.ShowWindow();
}

//==========================================================================================
//	FindMapByURLAndName
//==========================================================================================
function int FindMapByURLAndName(string Name, string URL)
{
	local int		i;

	if (URL == "")
		return -1;

	for (i=0; i< MapList.NumMaps; i++)
	{
		if (MapList.Maps[i].Name == Name && MapList.Maps[i].URL == URL)
			return i;
	}

	return -1;
}

//==========================================================================================
//	ScrollLeft
//==========================================================================================
function bool ScrollLeft()
{
	// Scroll left
	if (CurLocation < NumLocations-1)
	{
		ScrollingDir = -1;
		return true;
	}
	
	return false;
}

//==========================================================================================
//	ScrollRight
//==========================================================================================
function bool ScrollRight()
{
	// Scroll right
	if (CurLocation > 0)
	{
		ScrollingDir = 1;
		return true;
	}

	return false;
}

//==========================================================================================
//	SelectCurrentLocation
//==========================================================================================
function SelectCurrentLocation()
{
	if (CurLocation == -1)
		return;

	if (ScrollPos != 0)
		return;

	// Load the map if it's valid, and unlocked
	if ( Locations[CurLocation].MapIndex != -1 && MapList.Maps[Locations[CurLocation].MapIndex].Enabled )
	{
		LoadWaitTime = 0;
		UDukeNewGameWindow(ParentWindow.ParentWindow).bLocked = false;
		ParentWindow.ParentWindow.DelayedClose();
		Root.Console.CloseUWindow();	
		GetPlayerOwner().ClientTravel( Locations[CurLocation].ComboBox.GetValue2() $ "?noauto", TRAVEL_Absolute, false );
	}
}

//==========================================================================================
//	Notify
//==========================================================================================
function Notify( UWindowDialogControl C, byte E )
{
	local int		Index;

	if ( LoadWaitTime > 0 )
		return;

	Super.Notify( C, E );
    
    if (bInNotify == true)
        return;

    bInNotify = true;

	if (E == DE_Click && C == NextButton)
	{
	}
	else if (E == DE_Click && C == PrevButton)
	{
	}
	else if (E == DE_Click && C == SSButtons[0])
	{
		// Scroll right
		//ScrollRight();
	}
	else if (E == DE_Click && C == SSButtons[2])
	{
		// Scroll left
		//ScrollLeft();
	}
	else if (E == DE_Click && C == SSButtons[1])		// They pressed the selection button
	{
		// They pressed the middle button, load up the current map at this location
		LoadWaitLength = UDukeLookAndFeel(LookAndFeel).GetGameStartDuration( Self );
		LookAndFeel.PlayMenuSound( Self, MS_GameStart );
		LoadWaitTime = GetLevel().TimeSeconds;
		UDukeNewGameWindow(ParentWindow.ParentWindow).bLocked = true;
	}
 	else if (E == DE_Change && C == Locations[CurLocation].ComboBox)
	{
		// Update the location with the map that is selected in the combo box
		Index = FindMapByURLAndName(UWindowComboControl(C).GetValue(), UWindowComboControl(C).GetValue2());
		
		if (Index != -1)
		{
			SetLocationMapIndex(Locations[CurLocation], Index);
			SetupButtons();
		}
	}

    bInNotify = false;
}

function Tick( float Delta )
{
	if ( LoadWaitTime > 0 )
	{
		if ( GetLevel().TimeSeconds > LoadWaitTime + LoadWaitLength )
			SelectCurrentLocation();
		return;
	}
}

//
// This code belongs in the combo box class, but I put it here for now
//

//==========================================================================================
//	FindComboItem
//==========================================================================================
function int FindComboItem(UWindowList List, UWindowList Item)
{
	local UWindowList	l;
	local int			i;

	if (Item == None)
		return -1;

	i = 0;

	for (l=List.Next; l!=None; l=l.Next) 
	{
		if (l == Item)
			return i;

		i++;
	}

	return -1;
}

//==========================================================================================
//	ScrollComboItem
//==========================================================================================
function ScrollComboItem(int Dir)
{
	local UWindowComboListItem	NewSelected, Item;
	local UWindowComboList		List;
	local int					Count, i;

	List = Locations[CurLocation].ComboBox.List;

	i = FindComboItem(List.Items, List.Selected);

	if (i == -1)
		i = 0;

	Count = 0;
	for( Item = UWindowComboListItem(List.Items.Next);Item != None; Item = UWindowComboListItem(Item.Next) )
		Count++;

	if (Dir > 0)
	{
		i++;

		if (i > Count-1)
			i = Count-1;
		
		if (i >= List.VertSB.Pos + List.MaxVisible)
			List.VertSB.Scroll(1);
	}
	else if (Dir < 0)
	{
		i--;

		if (i < 0)
			i = 0;
		
		if (i < List.VertSB.Pos)
			List.VertSB.Scroll(-1);
	}
	
	NewSelected = UWindowComboListItem(List.Items.FindEntry(i));

	ChangeComboItem(NewSelected);
}

//==========================================================================================
//	ChangeComboItem
//==========================================================================================
function ChangeComboItem( UWindowComboListItem NewSelected )
{
	local UWindowComboList List;

	List = Locations[CurLocation].ComboBox.List;

	if ( NewSelected != List.Selected )
	{
		if ( NewSelected == None ) 
			List.Selected = None;
		else  
		{
			List.Selected = NewSelected;
			Locations[CurLocation].ComboBox.SetValue( List.Selected.Value, List.Selected.Value2 );
		}
	}	
}

//==========================================================================================
//	DropDownComboBox
//==========================================================================================
function DropDownComboBox()
{
	local UWindowComboList		List;

	Locations[CurLocation].ComboBox.DropDown();

	if (Locations[CurLocation].ComboBox.List.Selected == None)
	{
		List = Locations[CurLocation].ComboBox.List;
		ChangeComboItem(UWindowComboListItem(List.Items.FindEntry(0)));
	}
}

//==========================================================================================
//	KeyDown
//==========================================================================================
function KeyDown(int Key, float X, float Y)
{
	local PlayerPawn P;

	P = GetPlayerOwner();

	switch (Key)
	{
		case P.EInputKey.IK_Left:
			// Scroll right
			ScrollRight();
			PrevButton.bMouseDown = true;
			break;
		case P.EInputKey.IK_Right:
			// Scroll Left
			ScrollLeft();
			NextButton.bMouseDown = true;
			break;
		case P.EInputKey.IK_Down:
			if (!Locations[CurLocation].ComboBox.bListVisible)
				DropDownComboBox();
			else
				ScrollComboItem(1);
			break;
				
		case P.EInputKey.IK_Up:
			if (Locations[CurLocation].ComboBox.bListVisible)
				ScrollComboItem(-1);
			break;
	}
			
}

//==========================================================================================
//	KeyDown
//==========================================================================================
function KeyUp(int Key, float X, float Y)
{
	local PlayerPawn P;

	P = GetPlayerOwner();

	switch (Key)
	{
		case P.EInputKey.IK_Left:
			PrevButton.bMouseDown = false;
			break;
		case P.EInputKey.IK_Right:
			NextButton.bMouseDown = false;
			break;
	}
}

//==========================================================================================
//	defaultproperties
//==========================================================================================
defaultproperties
{
}