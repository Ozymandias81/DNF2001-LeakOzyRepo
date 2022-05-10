class dnMutatorListCW expands UDukePageWindow;

var UDukeCreateMultiCW		myParent;

var dnMutatorListExclude	Exclude;
var dnMutatorListInclude	Include;

var UWindowLabelControl		KeepLabel;
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
		Log( "Could not find parent for dnMutatorListCW" );

	KeepLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	KeepLabel.SetText(KeepText);
	KeepLabel.SetFont(F_Normal);
	KeepLabel.Align = TA_Right;

	KeepCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 10, 2, 190, 1));
	KeepCheck.SetHelpText( KeepHelp );
	KeepCheck.SetFont( F_Normal );
	KeepCheck.bChecked	= myParent.bKeepMutators;
	KeepCheck.Align		= TA_Right;

	Exclude = dnMutatorListExclude( CreateWindow( class'dnMutatorListExclude', 0, 0, 100, 100, Self ) );
	Include = dnMutatorListInclude( CreateWindow( class'dnMutatorListInclude', 0, 0, 100, 100, Self ) );

	Exclude.Register(Self);
	Include.Register(Self);

	Exclude.SetHelpText(ExcludeHelp);
	Include.SetHelpText(IncludeHelp);

	Include.DoubleClickList = Exclude;
	Exclude.DoubleClickList = Include;
	
    LoadMutators();
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

	KeepLabel.AutoSize( C );
	KeepLabel.WinLeft = 10;

	KeepCheck.SetSize( CenterWidth-90+16, KeepCheck.WinHeight );
	KeepCheck.WinLeft = KeepLabel.WinLeft + KeepLabel.WinWidth + 10;
	KeepCheck.WinTop = 0;
	KeepLabel.WinTop = KeepCheck.WinTop + 10;

	Exclude.WinLeft = 13;
	Exclude.WinTop = KeepCheck.WinTop+KeepCheck.WinHeight+20;
	Exclude.SetSize( WinWidth/2 - 14, WinHeight - (KeepCheck.WinTop+KeepCheck.WinHeight+20) - 15 );

	Include.WinLeft = WinWidth/2 + 3;
	Include.WinTop = KeepCheck.WinTop+KeepCheck.WinHeight+20;
	Include.SetSize( WinWidth/2 - 15, WinHeight - (KeepCheck.WinTop+KeepCheck.WinHeight+20) - 15 );
}

function Paint( Canvas C, float X, float Y )
{
	Super.Paint(C, X, Y);

	LookAndFeel.Bevel_DrawSplitHeaderedBevel( Self, C, 10, KeepCheck.WinTop+KeepCheck.WinHeight+5, WinWidth-20, WinHeight-(KeepCheck.WinTop+KeepCheck.WinHeight+5)-10, ExcludeCaption, IncludeCaption );
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
	ExcludeCaption="Mutators not Used"
	ExcludeHelp="Click and drag a mutator to the right hand column to include that mutator in this game."
	IncludeCaption="Mutators Used"
	IncludeHelp="Click and drag a mutator to the left hand column to remove it from the mutator list, or drag it up or down to re-order it in the mutator list."
	MutatorBaseClass="Engine.Mutator"
	KeepText="Always play with these mutators:"
	KeepHelp="If checked, these Mutators will always be used when starting games."

}

