class UDukeRightClickMenu extends UWindowRightClickMenu;

var UWindowPulldownMenuItem Play, Refresh, RefreshServer, PingAll, Info, Favorites;

var localized string PlayName;
var localized string RefreshName;
var localized string InfoName;
var localized string FavoritesName;
var localized string RefreshServerName;
var localized string PingAllName;

var UDukeServerGrid	Grid;
var UDukeServerList	List;

function Created()
{
	Super.Created();
	
	Info = AddMenuItem( InfoName, None );
	Play = AddMenuItem( PlayName, None );	
	AddMenuItem("-", None);
	AddFavoriteItems();
	AddMenuItem("-", None);
	RefreshServer = AddMenuItem( RefreshServerName, None );
	PingAll = AddMenuItem( PingAllName, None );
	Refresh = AddMenuItem( RefreshName, None );
}

function AddFavoriteItems()
{
	Favorites = AddMenuItem( FavoritesName, None );
}

function ExecuteItem( UWindowPulldownMenuItem I ) 
{
	switch(I)
	{
	case Play:
		Grid.JoinServer( List );
		break;
	case Info:
		if( !Info.bDisabled ) 
			Grid.ShowInfo( List );
		break;
	case Favorites:
		UDukeServerBrowserCW( Grid.GetParent( class'UDukeServerBrowserCW' ) ).AddFavorite( List );
		break;
	case Refresh:
		Grid.Refresh();
		break;
	case PingAll:
		Grid.RePing();
		break;
	case RefreshServer:
		Grid.RefreshServer();
		break;
	}

	Super.ExecuteItem( I );
}

function ShowWindow()
{
    Info.bDisabled          = List == None || List.GamePort == 0;
	Play.bDisabled          = List == None || List.GamePort == 0;
	Favorites.bDisabled     = List == None;
	RefreshServer.bDisabled = List == None;
	Selected                = None;

	Super.ShowWindow();
}

defaultproperties
{
	PlayName="&Play on This Server"
	RefreshServerName="P&ing This Server"
	RefreshName="&Refresh All Servers"
	PingAllName="Ping &All Servers"
	InfoName="&Server and Player Info"
	FavoritesName="Add to &Favorites"
}
