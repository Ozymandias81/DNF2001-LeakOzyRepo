/*-----------------------------------------------------------------------------
	UDukeCreateMultiWindow
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class UDukeCreateMultiWindow extends UDukeFramedWindow;

var UDukeEmbeddedClient ScrollClient;

function BeforePaint( Canvas C, float X, float Y )
{
	local float ClientHeight;
	local Region ClientAreaRegion;

	if ( ScrollClient != None )
	{
		ClientAreaRegion = LookAndFeel.FW_GetClientArea( Self );
		ClientHeight = ScrollClient.ClientArea.DesiredHeight;

		bShowVertSB = ClientHeight > ScrollClient.WinHeight;

		if ( bShowVertSB && !bPlayingSmack )
		{
			if ( !VertSB.bWindowVisible )
				VertSB.ShowWindow();
			VertSB.WinTop = ClientAreaRegion.Y;
			VertSB.WinLeft = WinWidth - LookAndFeel.SBPosIndicator.W - 25;
			VertSB.WinWidth = LookAndFeel.SBPosIndicator.W;
			VertSB.WinHeight = ClientAreaRegion.H;

			VertSB.SetRange( 0, ClientHeight, VertSB.WinHeight, 10 );
		}
		else
		{
			VertSB.HideWindow();
			VertSB.Pos = 0;
		}

		ScrollClient.ClientArea.WinTop = -VertSB.Pos;
	}

	Super(UWindowFramedWindow).BeforePaint( C, X, Y );
}

defaultproperties
{
	ClientClass=class'UDukeCreateMultiSC'
	WindowTitle="Create Multiplayer Game "
}