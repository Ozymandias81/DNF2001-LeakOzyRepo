/*-----------------------------------------------------------------------------
	UWindowSmallButton
-----------------------------------------------------------------------------*/
class UWindowSmallButton extends UWindowButton;

function Created()
{
	bNoKeyboard = True;

	Super.Created();

	ToolTipString = "";
	SetText( "" );
	SetFont( F_Normal );
}

function AutoSize( Canvas C )
{
	LookAndFeel.Button_AutoSize( Self, C );
}

function BeforePaint( Canvas C, float X, float Y )
{
	local float W, H;

	Super.BeforePaint( C, X, Y );
	
	C.Font = Root.Fonts[Font];
	TextSize( C, RemoveAmpersand(Text), W, H );

	TextX = (WinWidth-W)/2;
	if ( Font == F_Small )
		TextY = (WinHeight-H)/2-1;
	else
		TextY = (WinHeight-H)/2+1;

	if ( bMouseDown )
	{
		TextX += 1;
		TextY += 1;
	}		
}

function Paint( Canvas C, float X, float Y )
{
	LookAndFeel.Button_DrawSmallButton( Self, C );
	Super.Paint( C, X, Y );
}
