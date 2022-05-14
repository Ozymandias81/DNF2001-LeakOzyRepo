class dnMutatorListBox expands UWindowListBox;

function DrawItem( Canvas C, UWindowList Item, float X, float Y, float W, float H )
{	
	UDukeLookAndFeel( LookAndFeel ).List_DrawItem( self,
		C,X,Y,W,H,
		dnMutatorList( Item ).MutatorName,
		dnMutatorList( Item ).bSelected
		);
}

defaultproperties
{
     ItemHeight=13.000000
     ListClass=Class'dnWindow.dnMutatorList'
}
