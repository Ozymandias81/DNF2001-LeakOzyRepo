//==========================================================================
// 
// FILE:			UDukeLoadGameWindowCW.uc
// 
// AUTHOR:			John Pollard
// 
// DESCRIPTION:		Load Game menu
// 
//==========================================================================
class UDukeLoadGameWindowCW extends UDukeDialogClientWindow;

var UWindowVSplitter				VSplitter;
var	UDukeSaveLoadGrid				Grid;

var UWindowWindow					FakeWindow;

var UWindowSmallButton				CancelButton;
var UWindowSmallButton				DeleteButton;
var UWindowSmallButton				LoadButton;

var UWindowMessageBox				ConfirmDelete;
var UWindowMessageBox				ConfirmLoad;

var bool							bMainCreated;

var bool							bInNotify;

var	UDukeSaveLoadList				LastItem;

enum EWindowMode
{
	WMode_Main,
};

var EWindowMode						CurrentMode;

var int								CurMonth;
var int								CurDay;
var int								CurDayOfWeek;
var int								CurYear;
var int								CurHour;
var int								CurMinute;
var int								CurSecond;
var string							CurLocation;
var int								CurNumSaves;
var int								CurNumLoads;
var float							CurTotalGameTimeSeconds;

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
}

//==========================================================================================
//	AfterCreate
//==========================================================================================
function AfterCreate()
{
	ChangeWindowModes(WMode_Main);
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

	LoadButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 170, 305, 64, 16 ) );
	LoadButton.SetText("Load");
	LoadButton.SetHelpText("Load the selected game.");

	CancelButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 170+64+5, 305, 64, 16 ) );
	CancelButton.SetText("Cancel");
	CancelButton.SetHelpText("Return to the main menu without loading.");

	DeleteButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 170+64+5+65+5, 305, 64, 16 ) );
	DeleteButton.SetText("Delete");
	DeleteButton.SetHelpText("Delete the current saved game.");

	BuildSaveGameTable();

	bMainCreated = true;
	
	Grid.Owner = self;
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
	}
}

//==========================================================================================
//	BuildSaveGameTable
//==========================================================================================
function BuildSaveGameTable()
{
	LastItem = None;
	ThumbnailTexture = None;

	Grid.EmptyItems();
	Grid.SelectRow(0);

	// Add the saved game slots on the HD
	AddSaveTypeToList(SAVE_Normal);
	AddSaveTypeToList(SAVE_Quick);
	AddSaveTypeToList(SAVE_Auto);

	Grid.Sort();
	Grid.SelectRow(0);
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
//	BeforePaint
//==========================================================================================
function BeforePaint(Canvas C, float X, float Y)
{
	VSplitter.SplitPos = WinHeight*0.52;

	if (LastItem != Grid.GetSelectedItem())
	{
		if (Grid.GetSelectedItem() != None)
			GetPlayerOwner().GetSavedGameLongInfo(Grid.GetSelectedItem().SaveType, Grid.GetSelectedItem().ID, CurLocation, CurNumSaves, CurNumLoads, CurTotalGameTimeSeconds, ThumbnailTexture);
		else
			ThumbnailTexture = None;
		
		LastItem = Grid.GetSelectedItem();
	}

	Super.BeforePaint(C, X, Y);
	
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
	Super.Paint(C, MouseX, MouseY);

	C.Font = Root.Fonts[F_Normal];

	if (ThumbnailTexture != None)
	{
		DrawStretchedTextureSegment(C, 
									8, MainHeight-ThumbnailTexture.VSize-39, 
									ThumbnailTexture.USize+20, ThumbnailTexture.VSize,
									0, 0,
									ThumbnailTexture.USize, ThumbnailTexture.VSize, 
									ThumbnailTexture, 1.0, true);
		
		ClipText( C, 175, 215, "Location:");
		ClipText( C, 175, 230, "Saves:");
		ClipText( C, 175, 245, "Loads:");
		ClipText( C, 175, 260, "Play Time:");
		
		ClipText( C, 240, 215, CurLocation);
		ClipText( C, 240, 230, ""$CurNumSaves);
		ClipText( C, 240, 245, ""$CurNumLoads);
		ClipText( C, 240, 260, GetTimeFromSeconds(CurTotalGameTimeSeconds));
	}
}

//==========================================================================================
//	MessageBoxDone
//==========================================================================================
function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	ParentWindow.ShowWindow();
	
	if(W == ConfirmDelete && Result == MR_Yes && Grid.GetSelectedItem() != None)
	{
		GetPlayerOwner().DeleteSavedGame(Grid.GetSelectedItem().SaveType, Grid.GetSelectedItem().ID);
		BuildSaveGameTable();
	}
	else if(W == ConfirmLoad && Result == MR_Yes)
	{
		MyLoadGame(true);
	}
}

//==========================================================================================
//	MyLoadGame
//==========================================================================================
function MyLoadGame(optional bool bForce)
{
	//local string	MapName;

	//MapName = Left(GetPlayerOwner().GetURLMap(), 5);

	//if (!bForce && MapName != "Entry")
	if(!bForce && GetPlayerOwner().Level != GetPlayerOwner().GetEntryLevel())
	{
		ParentWindow.HideWindow();
		ConfirmLoad = MessageBox("Confirm Load", "Leave the current game, and load   '"@Grid.GetSelectedItem().Description@"'?                                    ", MB_YesNo, MR_No, MR_Yes);	
		return;
	}

	HideWindow();
	GetPlayerOwner().LoadGame(Grid.GetSelectedItem().SaveType, Grid.GetSelectedItem().ID);
	Root.CloseActiveWindow();
	Root.Console.CloseUWindow();	
	Close();
	//BuildSaveGameTable();
	//Root.Close();
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

	if (E == DE_Click && C == DeleteButton && Grid.GetSelectedItem() != None)
	{
		ParentWindow.HideWindow();
		ConfirmDelete = MessageBox("Confirm Delete", "Delete '"@Grid.GetSelectedItem().Description@"'?", MB_YesNo, MR_No, MR_Yes);	
	}
	else if ((E == DE_Click && C == LoadButton) && Grid.GetSelectedItem() != None)
		MyLoadGame();
	else if (E == DE_Click && C == CancelButton)
		Close();
 	else if (E == DE_EnterPressed && C == None)
		MyLoadGame();

    bInNotify = false;
}

defaultproperties
{
}
