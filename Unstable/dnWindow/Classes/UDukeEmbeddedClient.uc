/*-----------------------------------------------------------------------------
	UDukeEmbeddedClient
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class UDukeEmbeddedClient extends UWindowClientWindow;

var UWindowDialogClientWindow	ClientArea;
var class<UWindowDialogClientWindow> ClientClass;

function Created()
{
	Super.Created();

	ClientArea = UWindowDialogClientWindow(CreateWindow(ClientClass, 0, 0, WinWidth, WinHeight, OwnerWindow));
}

function BeforePaint( Canvas C, float X, float Y )
{
	local float ClientHeight;

	ClientHeight = ClientArea.DesiredHeight;
	if ( ClientHeight < WinHeight )
		ClientHeight = WinHeight;

	ClientArea.SetSize( WinWidth, ClientHeight );

	Super.BeforePaint( C, X, Y );
}