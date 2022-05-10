class UDukeRightClickBuddyMenu extends UWindowRightClickMenu;

var UWindowPulldownMenuItem Delete;
var localized string		DeleteName;
var UWindowPulldownMenuItem DeleteAll;
var localized string		DeleteAllName;

var UDukeServerFilterCW     ServerFilter;
var UDukeBuddyListBox       BuddyListBox;

var UDukeBuddyList			List;

function Created()
{
	Super.Created();
	
	Delete = AddMenuItem( DeleteName, None );
	DeleteAll = AddMenuItem( DeleteAllName, None );
}

function DeleteAllBuddies()
{
	if ( ServerFilter != None )
		ServerFilter.DeleteAllBuddies();
	if ( BuddyListBox != None )
		BuddyListBox.DeleteSelection();
}

function DeleteBuddy()
{
	// Remove the current list item
	if ( List != None )
	{
		List.Remove(); 
		List = None;
	
		// Re-apply the filter to the parent
		if ( ServerFilter != None )
		{
			ServerFilter.DeletedBuddy();
		}

		if ( BuddyListBox != None )
		{
			BuddyListBox.DeleteSelection();
		}
	}
}

function ExecuteItem( UWindowPulldownMenuItem I ) 
{
	switch(I)
	{
	case Delete:
		DeleteBuddy();
		break;
	case DeleteAll:
		DeleteAllBuddies();
		break;
	}

	Super.ExecuteItem( I );
}

function ShowWindow()
{
	Delete.bDisabled    = List == None;
	DeleteAll.bDisabled = false;
	Super.ShowWindow();

	Delete.SetCaption( DeleteName );
}

defaultproperties
{
	DeleteName="&Delete this Buddy"
	DeleteAllName="&Delete all Buddies"
}
