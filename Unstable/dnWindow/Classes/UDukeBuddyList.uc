class UDukeBuddyList expands UWindowListBoxItem;

var string PlayerName;

function int Compare( UWindowList T, UWindowList B )
{
	if ( Caps( UDukeBuddyList( T ).PlayerName ) < Caps( UDukeBuddyList( B ).PlayerName ) )
		return -1;

	return 1;
}

// Call only on sentinel
function UDukeBuddyList FindName( string FindPlayerName )
{
	local UDukeBuddyList I;

	for ( I = UDukeBuddyList( Next ); I != None; I = UDukeBuddyList ( I.Next ) )
		if ( I.PlayerName ~= FindPlayerName )
			return I;

	return None;
}

function DeleteName( UDukeBuddyList L )
{
	L.Remove();
}
