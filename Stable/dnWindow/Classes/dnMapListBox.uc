class dnMapListBox expands UWindowListBox;

function DrawItem( Canvas C, UWindowList Item, float X, float Y, float W, float H )
{
	C.Font = Root.Fonts[F_Normal];
	C.DrawColor = LookAndFeel.GetTextColor( Self );

	if ( !dnMapList(Item).bSelected )
	{
		C.DrawColor.R = 3 * (C.DrawColor.R / 4);
		C.DrawColor.G = 3 * (C.DrawColor.G / 4);
		C.DrawColor.B = 3 * (C.DrawColor.B / 4);
	}

	ClipText( C, X, Y, dnMapList( Item ).DisplayName );
}

defaultproperties
{
	ListClass=class'dnMapList'
	ItemHeight=13
}
