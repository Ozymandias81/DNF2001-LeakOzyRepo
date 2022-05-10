//=============================================================================
// 
// FILE:			UDukeNetTabWindowCreate.uc
// 
// AUTHOR:			Timothy L. Weisser
// 
// DESCRIPTION:		Tabwindow for creating DukeNet games
// 
// NOTES:			TODO: Have this iterate DNF maps and add to MapCombo, 
//					once the maps can be loaded and iterated through.
//
//					TLW: WARNING! The client travel to the new map, after creation
//					is intentionally broken for the moment. Since can't launch maps,
//					leaving the player in the menu helped with debugging 
//					join/create windows
//  
// MOD HISTORY: 
// 
//==========================================================================
class UDukeNetTabWindowCreate expands UDukeNetTabWindow;

var UWindowEditControl editGameName;
var() localized string strGameNameText;
var() localized string strGameNameHelp;

var UWindowEditControl editGamePassword;
var() localized string strGamePasswordText;
var() localized string strGamePasswordHelp;

// Game Type
var UWindowComboControl comboGameType;
var() localized string strGameTypeText;
var() localized string strGameTypeHelp;

// Frag Limit
var UWindowEditControl FragEdit;
var() localized string FragText;
var() localized string FragHelp;

// Time Limit
var UWindowEditControl TimeEdit;
var() localized string TimeText;
var() localized string TimeHelp;

// Max Players
var UWindowEditControl MaxPlayersEdit;
var() localized string MaxPlayersText;
var() localized string MaxPlayersHelp;

var UWindowEditControl editNote;
var() localized string strNoteText;
var() localized string strNoteHelp;

// Weapons Stay
var UWindowCheckbox WeaponsCheck;
var() localized string WeaponsText;
var() localized string WeaponsHelp;

// Map
var UWindowComboControl MapCombo;
var() localized string MapText;
var() localized string MapHelp;

var UDukeScreenshotCW winMapScreenshot;

var UWindowSmallButton buttonCreate;
var() localized string strCreateText;

var UWindowSmallButton buttonDedicated;
var localized string strDedicatedText;
var localized string strDedicatedHelp;


function Created()
{
	local INT iHalfWidth;
	local INT iControlOffset;
	Super.Created();

	iHalfWidth = WinWidth / 2;
	iControlOffset = WinHeight * 0.333333;

	// Map
	MapCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 
												 iHalfWidth / 8, iControlOffset, 
												 iHalfWidth * 0.75, 20
								   )
	);
	MapCombo.SetButtons(True);
	MapCombo.SetText(MapText);
	MapCombo.SetHelpText(MapHelp);
	MapCombo.SetFont(F_Normal);
	MapCombo.SetEditable(False);
	MapCombo.SetValue("DukeFirstMap");	//get default from config?
	IterateMaps("DukeFirstMap");	

	iControlOffset += MapCombo.WinHeight;
	winMapScreenshot = UDukeScreenshotCW(CreateWindow(	class'UDukeScreenshotCW', 
														0, iControlOffset, 
														iHalfWidth, WinHeight - iControlOffset + MapCombo.WinHeight
										 )
	);

	iControlOffset = WinHeight * 0.25;
	editGameName = UWindowEditControl(CreateControl(class'UWindowEditControl', 
													iHalfWidth, iControlOffset, 
													iHalfWidth * 0.75, 20
										 )
	);
	editGameName.SetText(strGameNameText);
	editGameName.SetHelpText(strGameNameHelp);
	editGameName.SetFont(F_Normal);
	editGameName.SetMaxLength(40);
	editGameName.SetValue("Vegas");	//get default from config?

	iControlOffset += 30;
	comboGameType = UWindowComboControl(CreateControl(class'UWindowComboControl', 
													  iHalfWidth, iControlOffset, 
													  iHalfWidth * 0.75, 1
										)
	);
	comboGameType.SetButtons(true);
	comboGameType.SetText(strGameTypeText);
	comboGameType.SetHelpText(strGameTypeHelp);
	comboGameType.SetFont(F_Normal);
	comboGameType.SetValue("FreeForAll");	//get default from config?
	comboGameType.SetEditable(false);
	
	iControlOffset += 30;
	editGamePassword = UWindowEditControl(CreateControl(class'UWindowEditControl', 
													iHalfWidth, iControlOffset, 
													iHalfWidth * 0.75, 20
										 )
	);
	editGamePassword.SetText(strGamePasswordText);
	editGamePassword.SetHelpText(strGamePasswordHelp);
	editGamePassword.SetFont(F_Normal);
	editGamePassword.SetMaxLength(10);

	// Frag Limit
	iControlOffset += 30;
	FragEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', 
												iHalfWidth, iControlOffset, 
												iHalfWidth * 0.75, 20
								  )
	);
	FragEdit.SetText(FragText);
	FragEdit.SetHelpText(FragHelp);
	FragEdit.SetFont(F_Normal);
	FragEdit.SetNumericOnly(True);
	FragEdit.SetMaxLength(3);
	FragEdit.SetValue("0");	//get default from config?

	// Time Limit
	iControlOffset += 30;
	TimeEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', 
												iHalfWidth, iControlOffset, 
												iHalfWidth * 0.75, 20
								  )
	);
	TimeEdit.SetText(TimeText);
	TimeEdit.SetHelpText(TimeHelp);
	TimeEdit.SetFont(F_Normal);
	TimeEdit.SetNumericOnly(True);
	TimeEdit.SetMaxLength(3);

	// Max Players
	iControlOffset += 30;
	MaxPlayersEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', 
													iHalfWidth, iControlOffset, 
													iHalfWidth * 0.75, 20
								  )
	);
	MaxPlayersEdit.SetText(MaxPlayersText);
	MaxPlayersEdit.SetHelpText(MaxPlayersHelp);
	MaxPlayersEdit.SetFont(F_Normal);
	MaxPlayersEdit.SetNumericOnly(True);
	MaxPlayersEdit.SetMaxLength(2);
	MaxPlayersEdit.SetValue("8");	//get default from config?
	MaxPlayersEdit.SetDelayedNotify(True);

	// Note
	iControlOffset += 30;
	editNote = UWindowEditControl(CreateControl(class'UWindowEditControl', 
												iHalfWidth, iControlOffset, 
												iHalfWidth * 0.75, 20
								  )
	);
	editNote.SetText(strNoteText);
	editNote.SetHelpText(strNoteHelp);
	editNote.SetFont(F_Normal);
	MaxPlayersEdit.SetMaxLength(40);
	
	// WeaponsStay
	iControlOffset += 30;
	WeaponsCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 
												 iHalfWidth, iControlOffset, 
											 	 iHalfWidth * 0.75, 20
								   )
	);
	WeaponsCheck.SetText(WeaponsText);
	WeaponsCheck.SetHelpText(WeaponsHelp);
	WeaponsCheck.SetFont(F_Normal);
//	WeaponsCheck.bChecked = BotmatchParent.GameClass.Default.bCoopWeaponMode;
	
	buttonCreate = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 
													WinWidth - 40, WinHeight - 20, 
													40, 20
									  )
	);
	buttonCreate.SetText(strCreateText);

	buttonDedicated = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 
													WinWidth - 100, WinHeight - 20, 
													60, 20
									  )
	);
	buttonDedicated.SetText(strDedicatedText);
	buttonDedicated.SetHelpText(strDedicatedHelp);

}

function IterateMaps(string DefaultMap)
{
	local string FirstMap, NextMap, TestMap;
	local int Selected;

/*	TODO: Have this iterate DNF maps and add to MapCombo
	FirstMap = GetPlayerOwner().GetMapName(BotmatchParent.GameClass.Default.MapPrefix, "", 0);

	MapCombo.Clear();
	NextMap = FirstMap;

	while (!(FirstMap ~= TestMap))
	{
		// Add the map.
		if(!(Left(NextMap, Len(NextMap) - 4) ~= (BotmatchParent.GameClass.Default.MapPrefix$"-tutorial")))
			MapCombo.AddItem(Left(NextMap, Len(NextMap) - 4), NextMap);

		// Get the map.
		NextMap = GetPlayerOwner().GetMapName(BotmatchParent.GameClass.Default.MapPrefix, NextMap, 1);

		// Text to see if this is the last.
		TestMap = NextMap;
	}
	MapCombo.Sort();

	MapCombo.SetSelectedIndex(Max(MapCombo.FindItemIndex2(DefaultMap, True), 0));	
*/
}

function Notify(UWindowDialogControl C, byte E)
{
	local string URL;
	local string strGameString;
	local string strCheckSum;
	local bool bDedicatedLaunch;
	
	if(E == DE_Click)  {
	
		bDedicatedLaunch = (C == buttonDedicated);
		if(bDedicatedLaunch || C == buttonCreate)  {
			Log("TIM: Got Notify(DE_Click) from buttonCreate, trying to start a game");
			strGameString = "/GAME:";

			//Build game string from values entered into edit controls
			strGameString = strGameString $ UDukeNetCW(ParentWindow).GetLocalIPAddress();
			strGameString = strGameString $ "," $ editGameName.GetValue();

			strGameString = strGameString $ "," $ MapCombo.GetValue();
			strGameString = strGameString $ "," $ comboGameType.GetValue();

			strGameString = strGameString $ "," $ FragEdit.GetValue();
			strGameString = strGameString $ ",1"; //current number players = self
			strGameString = strGameString $ "," $ MaxPlayersEdit.GetValue();
	
			strGameString = strGameString $ "," $ editNote.GetValue();
		
			UDukeNetCW(ParentWindow).dnClient.Message(strGameString);	
		
			URL = MapCombo.GetValue() $ 
				  "?Game=" $ comboGameType.GetValue() $ 
			//	  "?Mutator=" $ MutatorList $
				  "?Listen";

			// Reset the game class.
			if (!bDedicatedLaunch)
			{
			//	GameClass.Static.ResetGame();
			}

		//	ParentWindow.Close();
		//	Root.Console.CloseUWindow();

			if(bDedicatedLaunch)
				GetPlayerOwner().ConsoleCommand("RELAUNCH " $ URL $	" -server");
			else
			//	GetPlayerOwner().ClientTravel(URL, TRAVEL_Absolute, false);
				Log("TIM: Would have lanched this URL - " $ URL);
		}
	}
}

function BeforePaint(Canvas C, float X, float Y)
{
	local INT iHalfWidth,
			  iControlWidth;
	
	Super.BeforePaint(C, X, Y);

	iHalfWidth = WinWidth / 2;
	iControlWidth = iHalfWidth * 0.75;

	MapCombo.SetSize(iControlWidth, MapCombo.WinHeight);
	editGameName.SetSize(iControlWidth, editGameName.WinHeight);
	editGamePassword.SetSize(iControlWidth, editGamePassword.WinHeight);
	comboGameType.SetSize(iControlWidth, comboGameType.WinHeight);
	FragEdit.SetSize(iControlWidth, 1);
	TimeEdit.SetSize(iControlWidth, 1);
	WeaponsCheck.SetSize(iControlWidth, 1);

	MapCombo.EditBoxWidth = MapCombo.WinWidth / 2;
	comboGameType.EditBoxWidth = comboGameType.WinWidth / 2;
	editGameName.EditBoxWidth = editGameName.WinWidth / 2;
	editGamePassword.EditBoxWidth = editGamePassword.WinWidth / 2;
	FragEdit.EditBoxWidth = FragEdit.WinWidth / 2;
	TimeEdit.EditBoxWidth = TimeEdit.WinWidth / 2;
	
	MapCombo.WinLeft = iHalfWidth / 8;
	comboGameType.WinLeft = iHalfWidth + CONTROL_SPACING;
	editGameName.WinLeft = comboGameType.WinLeft;
	editGamePassword.WinLeft = comboGameType.WinLeft;
	FragEdit.WinLeft = comboGameType.WinLeft;
	TimeEdit.WinLeft = comboGameType.WinLeft;
	WeaponsCheck.WinLeft = comboGameType.WinLeft;	

	buttonCreate.WinLeft = WinWidth - 40;
	buttonDedicated.Winleft = WinWidth - 100; 
	buttonCreate.WinTop = WinHeight - 20;
	buttonDedicated.WinTop = buttonCreate.WinTop;
	
	MapCombo.WinTop = WinHeight * 0.333333;
	winMapScreenshot.WinTop = MapCombo.WinTop + MapCombo.WinHeight;	
	winMapScreenshot.SetSize(iHalfWidth, WinHeight - winMapScreenshot.WinTop);
	winMapScreenshot.WinTop =  WinHeight - winMapScreenshot.WinHeight;

	if(MaxPlayersEdit != None)
	{
		MaxPlayersEdit.SetSize(iControlWidth, 1);
		MaxPlayersEdit.WinLeft = iHalfWidth + CONTROL_SPACING;
		MaxPlayersEdit.EditBoxWidth = MaxPlayersEdit.WinWidth / 2;
	}

	editNote.SetSize(iControlWidth, 1);
	editNote.WinLeft = iHalfWidth + CONTROL_SPACING;
	editNote.EditBoxWidth = editNote.WinWidth / 2;
}

function Paint(Canvas C, float X, float Y)
{
	Super.Paint(C, X, Y);

	//If no map, draw a black square rather than nothing to show something is missing
	if(winMapScreenshot.Screenshot == None)
		DrawStretchedTexture(C, 
							 winMapScreenshot.WinLeft,  winMapScreenshot.WinTop, 
							 winMapScreenshot.WinWidth, winMapScreenshot.WinHeight, 
							 Texture'BlackTexture', 
							 1.0f	//opaque
		);

	//TODO: Replace with Unreal's name for the map
	WrapClipText(C, (WinWidth / 8), (WinHeight / 2), "Map ScreenShot", True);
}

defaultproperties
{
     strGameNameText="Name:"
     strGameNameHelp="Name of the game to create"
     strGamePasswordText="Password:"
     strGamePasswordHelp="To make the game private, enter a password here"
     strGameTypeText="Game Type"
     strGameTypeHelp="Select the type of game to play"
     FragText="Frag Limit"
     FragHelp="The game will end if a player achieves this many frags. A value of 0 sets no frag limit."
     TimeText="Time Limit"
     TimeHelp="The game will end if after this many minutes. A value of 0 sets no time limit."
     MaxPlayersText="Max Connections"
     MaxPlayersHelp="Maximum number of human players allowed to connect to the game."
     strNoteText="Note:"
     strNoteHelp="Special note to other players"
     WeaponsText="Weapons Stay"
     WeaponsHelp="If checked, weapons will stay at their pickup location after being picked up, instead of respawning."
     MapText="Map Name :"
     MapHelp="Select the map to play."
     strCreateText="Create"
     strDedicatedText="Dedicated"
     strDedicatedHelp="Press to launch a dedicated server."
}
