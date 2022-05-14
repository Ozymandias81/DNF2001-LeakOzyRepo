class dnMapListBox expands UWindowListBox;

function DrawItem( Canvas C, UWindowList Item, float X, float Y, float W, float H )
{	
	UDukeLookAndFeel( LookAndFeel ).List_DrawItem( self, C, X,Y,W,H,dnMapList( Item ).DisplayName,dnMapList( Item ).bSelected );
}

defaultproperties
{
     ItemHeight=13.000000
     ListClass=Class'dnWindow.dnMapList'
}
