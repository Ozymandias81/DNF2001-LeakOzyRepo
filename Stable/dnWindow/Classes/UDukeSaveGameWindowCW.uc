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
	ShowMainMenu();
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
		FakeWindow.HideWindow();
		return;
	}

	VSplitter = UWindowVSplitter( CreateWindow( class'UWindowVSplitter', 
												10, 10,
												WinWidth-20, WinHeight-20
									          )
	                            );

	Grid = UDukeSaveLoadGrid( VSplitter.CreateWindow( class'UDukeSaveLoadGrid', 
	     										    0, 0,
												    WinWidth, (WinHeight / 2),
                                                    self
								                  )
	                      );

	FakeWindow = VSplitter.CreateWindow( class'UWindowWindow', 
	     										    0, 0,
												    WinWidth, (WinHeight / 2) + 40,
                                                    self
								                  );
	FakeWindow.HideWindow();

	VSplitter.TopClientWindow    = Grid;
	VSplitter.BottomClientWindow = FakeWindow;

	SaveButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 1, 1, 1, 1 ) );
	SaveButton.SetText("Save");
	SaveButton.SetHelpText("Save the current name using this description.");

	DeleteButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 1, 1, 1, 1 ) );
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

	VSplitter.SplitPos = WinHeight*0.46;

	Super.BeforePaint(C, X, Y);

	SaveButton.AutoSize( C );
	DeleteButton.AutoSize( C );

	SaveButton.WinWidth = DeleteButton.WinWidth;
	DeleteButton.WinLeft = WinWidth - DeleteButton.WinWidth - 10;
	DeleteButton.WinTop = WinHeight - DeleteButton.WinHeight - 10;
	SaveButton.WinLeft = DeleteButton.WinLeft - 5 - SaveButton.WinWidth;
	SaveButton.WinTop = DeleteButton.WinTop;
	
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
	local float		GameTime, XL, YL;
	local int		Top;
	local font      oldfont;

	Super.Paint(C, MouseX, MouseY);

	C.Font = Root.Fonts[F_Normal];

	if ( Grid.GetSelectedItem() != None )
	{
		if ( Grid.GetSelectedItem().ID == -1 )
		{
			Location = SaveLocation;
			Saves = SaveNumSaves;
			Loads = SaveNumLoads;
			GameTime = SaveTotalGameTimeSeconds;

			if ( GetPlayerOwner().ScreenshotIsValid() )
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

		Top = 170;

		if ( Texture != None )
		{
			C.DrawColor = Root.WhiteColor;
			LookAndFeel.Bevel_DrawSimpleBevel( Self, C, 20, WinHeight - Texture.VSize - 20, Texture.USize+30, Texture.VSize );
			DrawStretchedTextureSegment( C, 20, WinHeight - Texture.VSize - 20, Texture.USize+30, Texture.VSize, 0, 0, Texture.USize, Texture.VSize, Texture, 1.0, true );
			
			C.DrawColor = LookAndFeel.GetTextColor( Self );
			oldfont = C.Font;
			C.Font = font'mainmenufont';
			ClipText( C, 200, Top,      "Location:");
			ClipText( C, 200, Top+20,   "Saves:");
			ClipText( C, 200, Top+20*2, "Loads:");
			ClipText( C, 200, Top+20*3, "Play Time:");
			
			TextSize( C, Location, XL, YL );
			if ( 310 + XL > WinWidth )
			{
				C.Font = font'mainmenufontsmall';
				ClipText( C, 310, Top+2, Location );
				C.Font = font'mainmenufont';
			} else
				ClipText( C, 310, Top,  Location);
			ClipText( C, 310, Top+20,   ""$Saves);
			ClipText( C, 310, Top+20*2, ""$Loads);
			ClipText( C, 310, Top+20*3, GetTimeFromSeconds(GameTime));
			C.Font = oldfont;
		}
	}
}

//==========================================================================================
//	MessageBoxDone
//==========================================================================================
function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
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
		ConfirmOverwrite = MessageBox("Confirm Overwrite ", "Overwrite '"$OldDescription$"'?", MB_YesNo, MR_No, MR_Yes);	
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
		ConfirmDelete = MessageBox("Confirm Delete ", "Delete '"$GetDescription(Grid.GetSelectedItem(), true)$"'?", MB_YesNo, MR_No, MR_Yes);	
	}
	else if ((E == DE_Click && C == SaveButton) && Grid.GetSelectedItem() != None)
		PreSaveGame();
	else if (E == DE_Change && C == Grid.RowEditBox && Grid.GetSelectedItem() != None)
		SetDescription(Grid.GetSelectedItem(), Grid.RowEditBox.GetValue());
	else if (E == DE_EnterPressed && C == None)
		PreSaveGame();

    bInNotify = false;
}

defaultproperties
{
	LastItem=None
}