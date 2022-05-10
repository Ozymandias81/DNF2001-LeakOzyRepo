class dnMapListCW expands UDukePageWindow;

var UDukeCreateMultiCW  myParent;

var dnMapListExclude Exclude;
var dnMapListInclude Include;

var UWindowLabelControl DefaultLabel;
var UWindowComboControl DefaultCombo;
var localized string    DefaultText;
var localized string    DefaultHelp;
var localized string    CustomText;

var localized string    ExcludeCaption;
var localized string    ExcludeHelp;
var localized string    IncludeCaption;
var localized string    IncludeHelp;

var bool bChangingDefault;

function Created()
{
	Super.Created();
	
	myParent = UDukeCreateMultiCW( GetParent( class'UDukeCreateMultiCW' ) );
	if ( myParent == None )
		Log( "Could not find parent for dnMapListCW" );

	Exclude = dnMapListExclude( CreateWindow( class'dnMapListExclude', 0, 0, 100, 100, Self ) );
	Include = dnMapListInclude( CreateWindow( class'dnMapListInclude', 0, 0, 100, 100, Self ) );

	Exclude.Register(Self);
	Include.Register(Self);

	Exclude.SetHelpText(ExcludeHelp);
	Include.SetHelpText(IncludeHelp);

	Include.DoubleClickList = Exclude;
	Exclude.DoubleClickList = Include;

	// Default
	DefaultLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	DefaultLabel.SetText(DefaultText);
	DefaultLabel.SetFont(F_Normal);
	DefaultLabel.Align = TA_Right;

	DefaultCombo = UWindowComboControl( CreateControl( class'UWindowComboControl', 10, 2, 200, 1 ) );
	DefaultCombo.SetHelpText( DefaultHelp );
	DefaultCombo.SetFont( F_Normal );
	DefaultCombo.SetEditable( false );
	DefaultCombo.AddItem( CustomText, "" );
	DefaultCombo.SetSelectedIndex( 0 );
	DefaultCombo.Align = TA_Right;

    LoadDefaultMapLists();
	LoadMapList();
}

function BeforePaint( Canvas C, float X, float Y )
{
	local int CenterWidth;
	local int CColLeft, CColRight;

	Super.BeforePaint(C, X, Y);

//	if ( !bSetSizeNextFrame )
//		return;

	CenterWidth = (WinWidth/4)*3;
	CColLeft = (WinWidth / 2) - 7;
	CColRight = (WinWidth / 2) + 7;

	DefaultLabel.AutoSize( C );
	DefaultLabel.WinLeft = 10;
	DefaultLabel.WinTop = DefaultCombo.WinTop + 8;

	DefaultCombo.SetSize( 200, DefaultCombo.WinHeight );
	DefaultCombo.WinLeft = DefaultLabel.WinLeft + DefaultLabel.WinWidth + 10;
	DefaultCombo.WinTop = 0;

	Exclude.WinLeft = 13;
	Exclude.WinTop = DefaultCombo.WinTop+DefaultCombo.WinHeight+20;
	Exclude.SetSize( WinWidth/2 - 14, WinHeight - (DefaultCombo.WinTop+DefaultCombo.WinHeight+20) - 15 );

	Include.WinLeft = WinWidth/2 + 3;
	Include.WinTop = DefaultCombo.WinTop+DefaultCombo.WinHeight+20;
	Include.SetSize( WinWidth/2 - 15, WinHeight - (DefaultCombo.WinTop+DefaultCombo.WinHeight+20) - 15 );
}

function Paint( Canvas C, float X, float Y )
{
	Super.Paint(C, X, Y);

	LookAndFeel.Bevel_DrawSplitHeaderedBevel( Self, C, 10, DefaultCombo.WinTop+DefaultCombo.WinHeight+5, WinWidth-20, WinHeight-(DefaultCombo.WinTop+DefaultCombo.WinHeight+5)-10, ExcludeCaption, IncludeCaption );
}

function LoadDefaultMapLists()
{
	local string MapListName, TestName, MapListDesc;
	local int j;

	MapListName = "None";
	TestName = "";
	while ( true )
	{
		GetPlayerOwner().GetNextMDSMapList( "", MapListName, 1, MapListName, MapListDesc );

		if( MapListName == TestName )
			break;

		if( TestName == "" )
			TestName = MapListName;

		DefaultCombo.AddItem( MapListDesc, MapListName );
	}	

	DefaultCombo.Sort();
}

function LoadMapList()
{
	local string FirstMap, NextMap, TestMap, MapName;
	local int i, IncludeCount;
	local dnMapList L;

	Exclude.Items.Clear();
	FirstMap = GetPlayerOwner().GetMapName(myParent.GameClass.Default.MapPrefix, "", 0);

	NextMap = FirstMap;
	while ( !( FirstMap ~= TestMap ) )
	{
		// Add the map.
		if( !( Left( NextMap, Len( NextMap ) - 4 ) ~= ( myParent.GameClass.Default.MapPrefix$"-tutorial" ) ) )
		{
			L = dnMapList( Exclude.Items.Append( class'dnMapList' ) );
			L.MapName = NextMap;
			if ( Right( NextMap, 4 ) ~= ".dnf" )
				L.DisplayName = Left( NextMap, Len( NextMap ) - 4 );
			else
				L.DisplayName = NextMap;
		}

		NextMap = GetPlayerOwner().GetMapName( myParent.GameClass.Default.MapPrefix, NextMap, 1 );
		TestMap = NextMap;
	}

	// Now load the current maplist into Include, and remove them from Exclude.
	Include.Items.Clear();
	
	IncludeCount = ArrayCount( myParent.GameClass.Default.MapListType.Default.Maps );

	for ( i=0; i<IncludeCount; i++ )
	{
		MapName = myParent.GameClass.Default.MapListType.Default.Maps[i];

		if ( MapName == "" )
			break;

		L = dnMapList( Exclude.Items ).FindMap( MapName );

		if ( L != None )
		{
			L.Remove();
			Include.Items.AppendItem( L );
		}
		else
			Log( "Unknown map in Map List: "$MapName );
	}

	Exclude.Sort();
}

function DefaultComboChanged()
{
	local string MapListName, MapName, MapDesc, TestName;
	local int i;

	if ( bChangingDefault )
		return;

	if ( DefaultCombo.GetSelectedIndex() == 0 )
		return;

	bChangingDefault = true;

	MapListName = DefaultCombo.GetValue2();

	// Clear out the old defaults
	for ( i=0; i<ArrayCount( myParent.GameClass.Default.MapListType.Default.Maps ); i++ )
	{
		myParent.GameClass.Default.MapListType.Default.Maps[i] = "";
	}

	i=0;
	MapName  = "None";
	TestName = "";
	while ( true )
	{
		GetPlayerOwner().GetNextMDSMap( MapListName, MapName, 1, MapName, MapDesc );

		if( MapName == TestName )
			break;

		if( TestName == "" )
			TestName = MapName;

		myParent.GameClass.Default.MapListType.Default.Maps[i] = MapName;
		i++;
	}	

	myParent.GameClass.Default.MapListType.static.StaticSaveConfig();
	LoadMapList();
	bChangingDefault = false;
}

function SaveConfigs()
{
	local int i, IncludeCount;
	local dnMapList L;

	Super.SaveConfigs();

	L = dnMapList(Include.Items.Next);

	IncludeCount = ArrayCount( myParent.GameClass.Default.MapListType.Default.Maps );

	for ( i=0;i<IncludeCount;i++ )
	{
		if ( L == None )
        {
			myParent.GameClass.Default.MapListType.Default.Maps[i] = "";
        }
		else
		{
			myParent.GameClass.Default.MapListType.Default.Maps[i] = L.MapName;
			L = dnMapList( L.Next );
		}
	}
	myParent.GameClass.Default.MapListType.static.StaticSaveConfig();
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
	bNoScanLines=true
	bNoClientTexture=true
	bBuildDefaultButtons=false
	ExcludeCaption="Maps Not Cycled"
	ExcludeHelp="Click and drag a map to the right hand column to include that map in the map cycle list."
	IncludeCaption="Maps Cycled"
	IncludeHelp="Click and drag a map to the left hand column to remove it from the map cycle list, or drag it up or down to re-order it in the map cycle list."
	DefaultText="Use Map List: "
	DefaultHelp="Choose a default map list to load, or choose Custom and configure the map list by hand."
	CustomText="Custom"
}
