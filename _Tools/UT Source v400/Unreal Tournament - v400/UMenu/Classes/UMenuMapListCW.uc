class UMenuMapListCW expands UMenuDialogClientWindow;

var UMenuBotmatchClientWindow BotmatchParent;
var UWindowHSplitter Splitter;

var UMenuMapListExclude Exclude;
var UMenuMapListInclude Include;

var UMenuMapListFrameCW FrameExclude;
var UMenuMapListFrameCW FrameInclude;

var UWindowComboControl DefaultCombo;
var localized string DefaultText;
var localized string DefaultHelp;
var localized string CustomText;

var localized string ExcludeCaption;
var localized string ExcludeHelp;
var localized string IncludeCaption;
var localized string IncludeHelp;

var bool bChangingDefault;

function Created()
{
	Super.Created();
	
	BotmatchParent = UMenuBotmatchClientWindow(OwnerWindow);

	Splitter = UWindowHSplitter(CreateWindow(class'UWindowHSplitter', 0, 0, WinWidth, WinHeight));
	
	FrameExclude = UMenuMapListFrameCW(Splitter.CreateWindow(class'UMenuMapListFrameCW', 0, 0, 100, 100));
	FrameInclude = UMenuMapListFrameCW(Splitter.CreateWindow(class'UMenuMapListFrameCW', 0, 0, 100, 100));

	Splitter.LeftClientWindow  = FrameExclude;
	Splitter.RightClientWindow = FrameInclude;

	Exclude = UMenuMapListExclude(CreateWindow(class'UMenuMapListExclude', 0, 0, 100, 100, Self));
	FrameExclude.Frame.SetFrame(Exclude);
	Include = UMenuMapListInclude(CreateWindow(class'UMenuMapListInclude', 0, 0, 100, 100, Self));
	FrameInclude.Frame.SetFrame(Include);

	Exclude.Register(Self);
	Include.Register(Self);

	Exclude.SetHelpText(ExcludeHelp);
	Include.SetHelpText(IncludeHelp);

	Include.DoubleClickList = Exclude;
	Exclude.DoubleClickList = Include;
	
	Splitter.bSizable = False;
	Splitter.bRightGrow = True;
	Splitter.SplitPos = WinWidth/2;

	DefaultCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 10, 2, 200, 1));
	DefaultCombo.SetText(DefaultText);
	DefaultCombo.SetHelpText(DefaultHelp);
	DefaultCombo.SetFont(F_Normal);
	DefaultCombo.SetEditable(False);
	DefaultCombo.AddItem(CustomText, "");
	DefaultCombo.SetSelectedIndex(0);
	DefaultCombo.EditBoxWidth = 120;
	LoadDefaultClasses();
	LoadMapList();
}

function Paint(Canvas C, float X, float Y)
{
	local Texture T;

	Super.Paint(C, X, Y);

	T = GetLookAndFeelTexture();
	DrawUpBevel( C, 0, 20, WinWidth, 15, T);

	C.Font = Root.Fonts[F_Normal];
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;

	ClipText(C, 10, 23, ExcludeCaption, True);
	ClipText(C, WinWidth/2 + 10, 23, IncludeCaption, True);
}

function Resized()
{
	Super.Resized();

	Splitter.WinTop = 35;
	Splitter.SetSize(WinWidth, WinHeight-35);
	Splitter.SplitPos = WinWidth/2;
}

function LoadDefaultClasses()
{
	local int NumDefaultClasses;
	local string DefaultBaseClass;
	local string NextDefault, NextDesc;
	local int j;

	DefaultBaseClass = string(BotmatchParent.GameClass.Default.MapListType);

	GetPlayerOwner().GetNextIntDesc(DefaultBaseClass, 0, NextDefault, NextDesc);
	while( (NextDefault != "") && (NumDefaultClasses < 50) )
	{
		DefaultCombo.AddItem(NextDesc, NextDefault);
		NumDefaultClasses++;
		GetPlayerOwner().GetNextIntDesc(DefaultBaseClass, NumDefaultClasses, NextDefault, NextDesc);
	}
}

function LoadMapList()
{
	local string FirstMap, NextMap, TestMap, MapName;
	local int i, IncludeCount;
	local UMenuMapList L;

	Exclude.Items.Clear();
	FirstMap = GetPlayerOwner().GetMapName(BotmatchParent.GameClass.Default.MapPrefix, "", 0);
	NextMap = FirstMap;
	while (!(FirstMap ~= TestMap))
	{
		// Add the map.
		if(!(Left(NextMap, Len(NextMap) - 4) ~= (BotmatchParent.GameClass.Default.MapPrefix$"-tutorial")))
		{
			L = UMenuMapList(Exclude.Items.Append(class'UMenuMapList'));
			L.MapName = NextMap;
			if(Right(NextMap, 4) ~= ".unr")
				L.DisplayName = Left(NextMap, Len(NextMap) - 4);
			else
				L.DisplayName = NextMap;
		}

		NextMap = GetPlayerOwner().GetMapName(BotmatchParent.GameClass.Default.MapPrefix, NextMap, 1);
		TestMap = NextMap;
	}

	// Now load the current maplist into Include, and remove them from Exclude.
	Include.Items.Clear();
	IncludeCount = ArrayCount(BotmatchParent.GameClass.Default.MapListType.Default.Maps);
	for(i=0;i<IncludeCount;i++)
	{
		MapName = BotmatchParent.GameClass.Default.MapListType.Default.Maps[i];
		if(MapName == "")
			break;

		L = UMenuMapList(Exclude.Items).FindMap(MapName);

		if(L != None)
		{
			L.Remove();
			Include.Items.AppendItem(L);
		}
		else
			Log("Unknown map in Map List: "$MapName);
	}

	Exclude.Sort();
}

function DefaultComboChanged()
{
	local class<MapList> C;
	local int i, Count;

	if(bChangingDefault)
		return;

	if(DefaultCombo.GetSelectedIndex() == 0)
		return;

	bChangingDefault = True;

	C = class<MapList>(DynamicLoadObject(DefaultCombo.GetValue2(), class'Class'));
	if(C != None)
	{
		Count = ArrayCount(C.Default.Maps);
		for(i=0;i<Count;i++)
			BotmatchParent.GameClass.Default.MapListType.Default.Maps[i] = C.Default.Maps[i];

		BotmatchParent.GameClass.Default.MapListType.static.StaticSaveConfig();

		LoadMapList();	
	}

	bChangingDefault = False;
}

function SaveConfigs()
{
	local int i, IncludeCount;
	local UMenuMapList L;

	Super.SaveConfigs();

	L = UMenuMapList(Include.Items.Next);

	IncludeCount = ArrayCount(BotmatchParent.GameClass.Default.MapListType.Default.Maps);
	for(i=0;i<IncludeCount;i++)
	{
		if(L == None)
			BotmatchParent.GameClass.Default.MapListType.Default.Maps[i] = "";
		else
		{
			BotmatchParent.GameClass.Default.MapListType.Default.Maps[i] = L.MapName;
			L = UMenuMapList(L.Next);
		}
	}

	BotmatchParent.GameClass.Default.MapListType.static.StaticSaveConfig();
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
		case DefaultCombo:
			DefaultComboChanged();
			break;
		case Exclude:
		case Include:
			DefaultCombo.SetSelectedIndex(0);
			break;
		}
		break;
	}
}

defaultproperties
{
	ExcludeCaption="Maps Not Cycled"
	ExcludeHelp="Click and drag a map to the right hand column to include that map in the map cycle list."
	IncludeCaption="Maps Cycled"
	IncludeHelp="Click and drag a map to the left hand column to remove it from the map cycle list, or drag it up or down to re-order it in the map cycle list."
	DefaultText="Use Map List: "
	DefaultHelp="Choose a default map list to load, or choose Custom and configure the map list by hand."
	CustomText="Custom"
}