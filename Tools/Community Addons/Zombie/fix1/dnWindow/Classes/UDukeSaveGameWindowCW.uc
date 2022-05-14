//==========================================================================
// 
// FILE:			UDukeSaveGameWindowCW.uc
// 
// AUTHOR:			John Pollard
// 
// DESCRIPTION:		Save Game menu
// 
//==========================================================================
class UDukeSaveGameWindowCW extends UDukeDialogClientWindow;

var UWindowVSplitter				VSplitter;
var	UDukeSaveLoadGrid				Grid;
var string							OldDescription;

var UWindowWindow					FakeWindow;

var UWindowSmallButton				CancelButton;
var UWindowSmallButton				DeleteButton;
var UWindowSmallButton				SaveButton;

var UWindowMessageBox				ConfirmDelete;
var UWindowMessageBox				ConfirmOverwrite;

var bool							bMainCreated;

var bool							bInNotify;

enum EWindowMode
{
	WMode_Main,
};

var EWindowMode						CurrentMode;

var	UDukeSaveLoadList				LastItem;

var LevelInfo						Level;

var int								SaveMonth;
var int								SaveDay;
var int								SaveDayOfWeek;
var int								SaveYear;
var int								SaveHour;
var int								SaveMinute;
var int								SaveSecond;
var string							SaveLocation;
var int								SaveNumSaves;
var int								SaveNumLoads;
var float							SaveTotalGameTimeSeconds;

var string							ExistingLocation;
var int								ExistingNumSaves;
var int								ExistingNumLoads;
var float							ExistingTotalGameTimeSeconds;

var texture							ScreenshotTexture;
var texture							ThumbnailTexture;

const	MainWidth		= 400;
const	MainHeight		= 360;

//==========================================================================================
//	Created
//==========================================================================================
function Created() 
{
	bInNotify = false;

	Super.Created();
	
	Level = GetPlayerOwner().Level;

	// Freeze the current date/time
	SaveYear = Level.Year;
	SaveMonth = Level.Month;
	SaveDay = Level.Day;
	SaveDayOfWeek = Level.DayOfWeek;

	SaveHour = Level.Hour;
	SaveMinute = Level.Minute;
	SaveSecond = Level.Second;
	
	SaveLocation = Level.LocationName;
	SaveNumSaves = Level.NumSaves;
	SaveNumLoads = Level.NumLoads;
	SaveTotalGameTimeSeconds = Level.TotalGameTimeSeconds;

	if (SaveLocation == "")
		SaveLocation = "Unknown";
}

//==========================================================================================
//	AfterCreate
//==========================================================================================
function AfterCreate()
{
	ChangeWindowModes(WMode_Main);
	ScreenshotTexture = GetPlayerOwner().Screenshot(true);
}


//==========================================================================================
//	ShowMainMenu
//==========================================================================================
function ShowMainMenu()
{
	if (bMainCreated)
	{
		VSplitter.ShowWindow();
		Grid.ShowWindow();
		CancelButton.ShowWindow();
		FakeWindow.HideWindow();
		return;
	}

	VSplitter = UWindowVSplitter( CreateWindow( class'UWindowVSplitter', 
												0, 0,
												MainWidth-5, MainHeight
									          )
	                            );

	Grid = UDukeSaveLoadGrid( VSplitter.CreateWindow( class'UDukeSaveLoadGrid', 
	     										    0, 0,
												    MainWidth, MainHeight / 2,
                                                    self
								                  )
	                      );

	FakeWindow = VSplitter.CreateWindow( class'UWindowWindow', 
	     										    0, 0,
												    MainWidth, MainHeight / 2,
                                                    self
								                  );
	FakeWindow.HideWindow();

	VSplitter.TopClientWindow    = Grid;
	VSplitter.BottomClientWindow = FakeWindow;

	SaveButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 170, 305, 64, 16 ) );
	SaveButton.SetText("Save");
	SaveButton.SetHelpText("Save the current name using this description.");

	CancelButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 170+64+5, 305, 64, 16 ) );
	CancelButton.SetText("Cancel");
	CancelButton.SetHelpText("Return to the main menu without saving.");

	DeleteButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 170+64+5+65+5, 305, 64, 16 ) );
	DeleteButton.SetText("Delete");
	DeleteButton.SetHelpText("Delete the current saved game.");

	BuildSaveGameTable();

	Grid.RegisterEditBox(self);
	Grid.Owner = self;

	bMainCreated = true;

}

//==========================================================================================
//	HideMainMenu
//==========================================================================================
function HideMainMenu()
{
	if (bMainCreated)
	{
		VSplitter.HideWindow();
		Grid.HideWindow();
		CancelButton.HideWindow();
	}
}

//==========================================================================================
//	AddSaveTypeToList
//==========================================================================================
function AddSaveTypeToList(ESaveType SaveType)
{
	local UDukeSaveLoadList	Item;
	local int				Count;
	local string			Desc;
	local int				i, Month, Day, DayOfWeek, Year, Hour, Minute, Second;

	Count = GetPlayerOwner().GetNumSavedGames(SaveType);

	// Add the saved games off the HD
	for (i=0; i<Count; i++)
	{
		GetPlayerOwner().GetSavedGameInfo(SaveType, i, Desc, Month, Day, DayOfWeek, Year, Hour, Minute, Second);
		Item = Grid.AddSaveLoadItem(Desc, Year, Month, Day, DayOfWeek, Hour, Minute, Second, i, SaveType);
		SetDescription(Item, Desc, true);
	}
}

//==========================================================================================
//	BuildSaveGameTable
//==========================================================================================
function BuildSaveGameTable()
{
	local LevelInfo			Level;
	local UDukeSaveLoadList	Item;

	Grid.EmptyItems();

	OldDescription = "";
	LastITem = None;
	Grid.SelectRow(0);

	Level = GetPlayerOwner().Level;

	// Add the saved game slots on the HD
	AddSaveTypeToList(SAVE_Normal);
	AddSaveTypeToList(SAVE_Quick);
	AddSaveTypeToList(SAVE_Auto);

	// Add the new saved game slot
	Item = Grid.AddSaveLoadItem(SaveLocation, SaveYear, SaveMonth, SaveDay, SaveDayOfWeek, SaveHour, SaveMinute, SaveSecond, -1, SAVE_Normal);
	//Item = Grid.AddSaveLoadItem(SaveLocation, SaveYear, SaveMonth, SaveDay, SaveDayOfWeek, SaveHour, SaveMinute, SaveSecond, -1, SAVE_Quick);
	SetDescription(Item, SaveLocation, true);
	Grid.RowEditBox.SetValue(GetDescription(Item));

	// Sort them
	Grid.Sort();
	
	// Select the new item we added
	Grid.SelectItem(Item);
}

//==========================================================================================
//	ChangeWindowModes
//==========================================================================================
function ChangeWindowModes(EWindowMode Mode)
{
	if (Mode == WMode_Main)
	{
		ShowMainMenu();
	}

	CurrentMode = Mode;
}

//==========================================================================================
//	GetDescription
//==========================================================================================
function string GetDescription(UDukeSaveLoadList Item, optional bool bModify)
{
	if (Item == None)
		return "GetDescription: Invalid Item";

	return Item.Description;
}

//==========================================================================================
//	SetDescription
//==========================================================================================
function SetDescription(UDukeSaveLoadList Item, string Desc, optional bool bModify)
{
	if (Item == None)
		return;

	Item.Description = Desc;
}

//==========================================================================================
//	BeforePaint
//==========================================================================================
function BeforePaint(Canvas C, float X, float Y)
{
	local UDukeSaveLoadList		CurItem;

	VSplitter.SplitPos = WinHeight*0.52;

	Super.BeforePaint(C, X, Y);
	
	// If the row changed on us, restore the last row's description that we may have modified,
	//	remember the new rows description (so we can restore it later as well possibly),
	//	and put the current row's description in the edit box so they can edit it
	CurItem = Grid.GetSelectedItem();

	if (LastItem != CurItem)
	{
		if (OldDescription != "" && LastItem != None && CurItem != None)
			SetDescription(LastItem, OldDescription);

		ThumbnailTexture = None;

		if (CurItem != None)
		{
			GetPlayerOwner().GetSavedGameLongInfo(CurItem.SaveType, CurItem.ID, ExistingLocation, ExistingNumSaves, ExistingNumLoads, ExistingTotalGameTimeSeconds, ThumbnailTexture);
			Grid.RowEditBox.SetValue(GetDescription(CurItem));
			Grid.RowEditBox.MoveHome();
			Grid.RowEditBox.MoveEnd();
			Grid.RowEditBox.Offset = 0;
			OldDescription = GetDescription(CurItem);
		}
		else
		{
			OldDescription = "";
		}
			
		LastItem = CurItem;
	}

	if (CurrentMode == WMode_Main)
	{
		ParentWindow.WinWidth = MainWidth;
		ParentWindow.WinHeight = MainHeight;
	}
	
	WinWidth = ParentWindow.WinWidth;
	WinHeight = ParentWindow.WinHeight;
	
	ParentWindow.WinLeft = (OwnerWindow.OwnerWindow.WinWidth - ParentWindow.WinWidth)*0.5f;
	ParentWindow.WinTop = (OwnerWindow.OwnerWindow.WinHeight - ParentWindow.WinHeight)*0.5f;
}

//==========================================================================================
//	GetTimeFromSeconds
//==========================================================================================
function string GetTimeFromSeconds(int Seconds)
{
	local int		Hours, Minutes;
	local string	Time;

	Minutes = Seconds/60;
	Seconds -= Minutes*60;
	Hours = Minutes/60;
	Minutes -= Hours*60;

	Time = ""$Hours;

	if (Minutes < 10)
		Time = Time$"\:0"$Minutes;
	else
		Time = Time$"\:"$Minutes;

	if (Seconds < 10)
		Time = Time$"\:0"$Seconds;
	else
		Time = Time$"\:"$Seconds;

	return Time;
}

//==========================================================================================
//	Paint
//==========================================================================================
function Paint(Canvas C, float MouseX, float MouseY)
{
	local texture	Texture;
	local string	Location;
	local int		Saves;
	local int		Loads;
	local float		GameTime;
	local int		Top;

	Super.Paint(C, MouseX, MouseY);

	C.Font = Root.Fonts[F_Normal];

if (Grid.GetSelectedItem() != None)
{
	if (Grid.GetSelectedItem().ID == -1)		// New saved slot
	{
		Location = SaveLocation;
		Saves = SaveNumSaves;
		Loads = SaveNumLoads;
		GameTime = SaveTotalGameTimeSeconds;

		if (GetPlayerOwner().ScreenshotIsValid())
			Texture = ScreenshotTexture;
		else
			Texture = None;
	}
	else
	{
		Location = ExistingLocation;
		Saves = ExistingNumSaves;
		Loads = ExistingNumLoads;
		GameTime = ExistingTotalGameTimeSeconds;
		Texture = ThumbnailTexture;
	}

	Top = 215;

	if (Texture != None)
	{
		DrawStretchedTextureSegment(C, 
									10, MainHeight-Texture.VSize-39, 
									Texture.USize+20, Texture.VSize,
									0, 0,
									Texture.USize, Texture.VSize, 
									Texture, 1.0, true);
		
		ClipText( C, 175, Top,      "Location:");
		ClipText( C, 175, Top+15,   "Saves:");
		ClipText( C, 175, Top+15*2, "Loads:");
		ClipText( C, 175, Top+15*3, "Play Time:");
		
		ClipText( C, 240, Top,      Location);
		ClipText( C, 240, Top+15,   ""$Saves);
		ClipText( C, 240, Top+15*2, ""$Loads);
		ClipText( C, 240, Top+15*3, GetTimeFromSeconds(GameTime));
	}
}
}

//==========================================================================================
//	MessageBoxDone
//==========================================================================================
function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	ParentWindow.ShowWindow();
	
	if (W == ConfirmDelete && Result == MR_Yes && Grid.GetSelectedItem() != None)
	{
		GetPlayerOwner().DeleteSavedGame(Grid.GetSelectedItem().SaveType, Grid.GetSelectedItem().ID);
		BuildSaveGameTable();
	}
	else if (W == ConfirmOverwrite && Result == MR_Yes)
	{
		SaveGame();
	}
}

//==========================================================================================
//	SaveGame
//==========================================================================================
function SaveGame()
{
	local int				Index;
	local UDukeSaveLoadList	Item;

	Index = Grid.GetSelectedItem().ID;		// Will be -1 if new saved slot

	ParentWindow.HideWindow();

	Item = Grid.GetSelectedItem();

	if (Item == None)
		return;

	GetPlayerOwner().SaveGame(Item.SaveType, Index, GetDescription(Item, true), ScreenshotTexture);
	SaveNumSaves = Level.NumSaves;
	Close();
	//BuildSaveGameTable();
}

//==========================================================================================
//	PreSaveGame
//==========================================================================================
function PreSaveGame()
{
	if (Grid.GetSelectedItem().ID != -1)
	{
		ParentWindow.HideWindow();
		ConfirmOverwrite = MessageBox("Confirm Overwrite", "Overwrite '"@OldDescription@"'?", MB_YesNo, MR_No, MR_Yes);	
	}
	else
		SaveGame();
}

//==========================================================================================
//	Notify
//==========================================================================================
function Notify( UWindowDialogControl C, byte E )
{
	Super.Notify( C, E );
    
    if (bInNotify == true)
        return;

    bInNotify = true;

	if (E == DE_Click && C == DeleteButton && Grid.GetSelectedItem() != None && (Grid.GetSelectedItem().ID != -1))
	{
		ParentWindow.HideWindow();
		ConfirmDelete = MessageBox("Confirm Delete", "Delete '"@GetDescription(Grid.GetSelectedItem(), true)@"'?", MB_YesNo, MR_No, MR_Yes);	
	}
	else if ((E == DE_Click && C == SaveButton) && Grid.GetSelectedItem() != None)
		PreSaveGame();
	else if (E == DE_Click && C == CancelButton)
		Close();
	else if (E == DE_Change && C == Grid.RowEditBox && Grid.GetSelectedItem() != None)
		SetDescription(Grid.GetSelectedItem(), Grid.RowEditBox.GetValue());
	else if (E == DE_EnterPressed && C == None)
		PreSaveGame();

    bInNotify = false;
}

defaultproperties
{
}
