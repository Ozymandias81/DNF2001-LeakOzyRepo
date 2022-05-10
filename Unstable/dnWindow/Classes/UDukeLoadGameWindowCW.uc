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
	ShowMainMenu();
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
												    WinWidth, WinHeight / 2,
                                                    self
								                  )
	                      );

	FakeWindow = VSplitter.CreateWindow( class'UWindowWindow', 
	     										    0, 0,
												    WinWidth, WinHeight / 2,
                                                    self
								                  );
	FakeWindow.HideWindow();

	VSplitter.TopClientWindow    = Grid;
	VSplitter.BottomClientWindow = FakeWindow;

	LoadButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 1, 1, 1, 1 ) );
	LoadButton.SetText("Load");
	LoadButton.SetHelpText("Load the selected game.");

	DeleteButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 1, 1, 1, 1 ) );
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
//	BeforePaint
//==========================================================================================
function BeforePaint(Canvas C, float X, float Y)
{
	VSplitter.SplitPos = WinHeight*0.46;

	if (LastItem != Grid.GetSelectedItem())
	{
		if (Grid.GetSelectedItem() != None)
			GetPlayerOwner().GetSavedGameLongInfo(Grid.GetSelectedItem().SaveType, Grid.GetSelectedItem().ID, CurLocation, CurNumSaves, CurNumLoads, CurTotalGameTimeSeconds, ThumbnailTexture);
		else
			ThumbnailTexture = None;
		
		LastItem = Grid.GetSelectedItem();
	}

	Super.BeforePaint(C, X, Y);	

	LoadButton.AutoSize( C );
	DeleteButton.AutoSize( C );

	LoadButton.WinWidth = DeleteButton.WinWidth;
	DeleteButton.WinLeft = WinWidth - DeleteButton.WinWidth - 10;
	DeleteButton.WinTop = WinHeight - DeleteButton.WinHeight - 10;
	LoadButton.WinLeft = DeleteButton.WinLeft - 5 - LoadButton.WinWidth;
	LoadButton.WinTop = DeleteButton.WinTop;
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
	local font oldfont;
	local float Top, XL, YL;

	Super.Paint(C, MouseX, MouseY);

	C.Font = Root.Fonts[F_Normal];
	Top = 170;
	if ( ThumbnailTexture != None )
	{
		C.DrawColor = Root.WhiteColor;
		LookAndFeel.Bevel_DrawSimpleBevel( Self, C, 20, WinHeight - ThumbnailTexture.VSize - 20, ThumbnailTexture.USize+30, ThumbnailTexture.VSize );
		DrawStretchedTextureSegment( C, 20, WinHeight - ThumbnailTexture.VSize - 20, ThumbnailTexture.USize+30, ThumbnailTexture.VSize, 0, 0, ThumbnailTexture.USize, ThumbnailTexture.VSize, ThumbnailTexture, 1.0, true );

		C.DrawColor = LookAndFeel.GetTextColor( Self );
		oldfont = C.Font;
		C.Font = font'mainmenufont';
		ClipText( C, 200, Top,      "Location:");
		ClipText( C, 200, Top+20,   "Saves:");
		ClipText( C, 200, Top+20*2, "Loads:");
		ClipText( C, 200, Top+20*3, "Play Time:");
		
		TextSize( C, CurLocation, XL, YL );
		if ( 310 + XL > WinWidth )
		{
			C.Font = font'mainmenufontsmall';
			ClipText( C, 310, Top+2, CurLocation );
			C.Font = font'mainmenufont';
		} else
			ClipText( C, 310, Top,      CurLocation);
		ClipText( C, 310, Top+20,   ""$CurNumSaves);
		ClipText( C, 310, Top+20*2, ""$CurNumLoads);
		ClipText( C, 310, Top+20*3, GetTimeFromSeconds(CurTotalGameTimeSeconds));
		C.Font = oldfont;
	}
}

//==========================================================================================
//	MessageBoxDone
//==========================================================================================
function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
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
		ConfirmLoad = MessageBox("Confirm Load ", "Leave the current game, and load '"$Grid.GetSelectedItem().Description$"'?                                    ", MB_YesNo, MR_No, MR_Yes);	
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
		ConfirmDelete = MessageBox("Confirm Delete", "Delete '"$Grid.GetSelectedItem().Description$"'?", MB_YesNo, MR_No, MR_Yes);	
	}
	else if ((E == DE_Click && C == LoadButton) && Grid.GetSelectedItem() != None)
		MyLoadGame();
 	else if (E == DE_EnterPressed && C == None)
		MyLoadGame();

    bInNotify = false;
}

defaultproperties
{
	LastItem=None
}