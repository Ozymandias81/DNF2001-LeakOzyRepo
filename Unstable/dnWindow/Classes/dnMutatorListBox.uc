class dnMutatorListBox expands UWindowListBox;

function DrawItem( Canvas C, UWindowList Item, float X, float Y, float W, float H )
{
	C.Font = Root.Fonts[F_Normal];
	C.DrawColor = LookAndFeel.GetTextColor( Self );

	if ( !dnMutatorList(Item).bSelected )
	{
		C.DrawColor.R = 3 * (C.DrawColor.R / 4);
		C.DrawColor.G = 3 * (C.DrawColor.G / 4);
		C.DrawColor.B = 3 * (C.DrawColor.B / 4);
	}

	ClipText( C, X, Y, dnMutatorList( Item ).MutatorName );
}

defaultproperties
{
	ListClass=class'dnMutatorList'
	ItemHeight=13
}
