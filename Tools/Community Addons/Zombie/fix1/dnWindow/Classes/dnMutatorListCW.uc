class dnMutatorListCW expands UDukePageWindow;

var UDukeCreateMultiCW		myParent;
var UWindowHSplitter		Splitter;

var dnMutatorListExclude	Exclude;
var dnMutatorListInclude	Include;

var dnMutatorListFrameCW	FrameExclude;
var dnMutatorListFrameCW	FrameInclude;

var UWindowCheckbox			KeepCheck;
var localized string		KeepText;
var localized string		KeepHelp;

var localized string		ExcludeCaption;
var localized string		ExcludeHelp;
var localized string		IncludeCaption;
var localized string		IncludeHelp;

var string MutatorBaseClass;

function Created()
{
	Super.Created();
	
	myParent = UDukeCreateMultiCW( GetParent( class'UDukeCreateMultiCW' ) );

	if ( myParent == None )
	{
		Log( "Could not find parent for dnMutatorListCW" );
	}

	KeepCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 10, 2, 190, 1));
	KeepCheck.SetText( KeepText );
	KeepCheck.SetHelpText( KeepHelp );
	KeepCheck.SetFont( F_Normal );
	KeepCheck.bChecked	= myParent.bKeepMutators;
	KeepCheck.Align		= TA_Right;

	Splitter = UWindowHSplitter( CreateWindow( class'UWindowHSplitter', 0, 0, WinWidth, WinHeight ) );
	
	FrameExclude = dnMutatorListFrameCW( Splitter.CreateWindow( class'dnMutatorListFrameCW', 0, 0, 100, 100 ) );
	FrameInclude = dnMutatorListFrameCW( Splitter.CreateWindow( class'dnMutatorListFrameCW', 0, 0, 100, 100 ) );

	Splitter.LeftClientWindow  = FrameExclude;
	Splitter.RightClientWindow = FrameInclude;

	Exclude = dnMutatorListExclude( CreateWindow( class'dnMutatorListExclude', 0, 0, 100, 100, Self ) );
	FrameExclude.Frame.SetFrame( Exclude );
	Include = dnMutatorListInclude( CreateWindow( class'dnMutatorListInclude', 0, 0, 100, 100, Self ) );
	FrameInclude.Frame.SetFrame( Include );

	Exclude.Register(Self);
	Include.Register(Self);

	Exclude.SetHelpText(ExcludeHelp);
	Include.SetHelpText(IncludeHelp);

	Include.DoubleClickList = Exclude;
	Exclude.DoubleClickList = Include;
	
	Splitter.bSizable		= true;
	Splitter.bRightGrow		= true;
	Splitter.SplitPos		= WinWidth/2;

/*
	DefaultCombo = UWindowComboControl( CreateControl( class'UWindowComboControl', 10, 2, 200, 1 ) );
	DefaultCombo.SetText( DefaultText );
	DefaultCombo.SetHelpText( DefaultHelp );
	DefaultCombo.SetFont( F_Normal );
	DefaultCombo.SetEditable( false );
	DefaultCombo.AddItem( CustomText, "" );
	DefaultCombo.SetSelectedIndex( 0 );
	DefaultCombo.EditBoxWidth = 120;
*/
    LoadMutators();
}

function Paint(Canvas C, float X, float Y)
{
	local Texture T;

	Super.Paint(C, X, Y);

	T = GetLookAndFeelTexture();

	C.Font = Root.Fonts[F_Bold];
	
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	ClipText( C, 10, 23, ExcludeCaption, true );
	ClipText( C, WinWidth/2 + 10, 23, IncludeCaption, true );

	C.Font = Root.Fonts[F_Normal];
}

function BeforePaint( Canvas C, float X, float Y )
{
	Super.BeforePaint( C, X, Y );

	Splitter.WinTop = 35;
	Splitter.SetSize( WinWidth, WinHeight-35 );
}

function Resized()
{
	Super.Resized();

    FrameExclude.SetSize( WinWidth/2, WinHeight );
	FrameInclude.SetSize( WinWidth/2, WinHeight );
	Include.SetSize( WinWidth/2, WinHeight );
	Exclude.SetSize( WinWidth/2, WinHeight );
   
    Splitter.SetSize( WinWidth, WinHeight );
    Splitter.SplitPos = WinWidth * 0.5;
}

function LoadMutators()
{
	local int			NumMutatorClasses,j,k;
	local string		NextMutator, NextDesc;
	local dnMutatorList	L;
	local string		MutatorList;

	GetPlayerOwner().GetNextIntDesc( MutatorBaseClass, 0, NextMutator, NextDesc );

	while( ( NextMutator != "" ) && ( NumMutatorClasses < 200 ) )
	{
		L			   = dnMutatorList(Exclude.Items.Append( class'dnMutatorList' ) );
		L.MutatorClass = NextMutator;

		k = InStr( NextDesc, "," );
		
		if ( k == -1 )
		{
			L.MutatorName = NextDesc;
			L.HelpText = "";
		}
		else
		{
			L.MutatorName = Left( NextDesc, k );
			L.HelpText = Mid( NextDesc, k+1 );
		}

		NumMutatorClasses++;
		GetPlayerOwner().GetNextIntDesc( MutatorBaseClass, NumMutatorClasses, NextMutator, NextDesc );
	}

	MutatorList = myParent.MutatorList;

	while( MutatorList != "" )
	{
		j = InStr( MutatorList, "," );
		
		if ( j == -1 )
		{
			NextMutator = MutatorList;
			MutatorList = "";
		}
		else
		{
			NextMutator = Left( MutatorList, j );
			MutatorList = Mid( MutatorList, j+1 );
		}
		
		L = dnMutatorList( Exclude.Items ).FindMutator( NextMutator );
		
		if( L != None )
		{
			L.Remove();
			Include.Items.AppendItem( L );
		}
		else
		{
			Log( "Unknown mutator in mutator list: "$NextMutator );
		}
	}
	Exclude.Sort();
}

function SaveConfigs()
{
	local dnMutatorList	L;
	local string		MutatorList;

	Super.SaveConfigs();
	
	for( L = dnMutatorList( Include.Items.Next ); L != None; L = dnMutatorList( L.Next ) )
	{
		if ( MutatorList == "" )
			MutatorList = L.MutatorClass;
		else
			MutatorList = MutatorList $ "," $L.MutatorClass;
	}
	myParent.MutatorList = MutatorList;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
		case KeepCheck:
			myParent.bKeepMutators = KeepCheck.bChecked;
			break;
		case Exclude:
		case Include:
			//DefaultCombo.SetSelectedIndex(0);
			break;
		}
		break;
	}
}

defaultproperties
{
     KeepText="Always use this Mutator configuration"
     KeepHelp="If checked, these Mutators will always be used when starting games."
     ExcludeCaption="Mutators not Used"
     ExcludeHelp="Click and drag a mutator to the right hand column to include that mutator in this game."
     IncludeCaption="Mutators Used"
     IncludeHelp="Click and drag a mutator to the left hand column to remove it from the mutator list, or drag it up or down to re-order it in the mutator list."
     MutatorBaseClass="Engine.Mutator"
     bBuildDefaultButtons=False
     bNoScanLines=True
     bNoClientTexture=True
}
