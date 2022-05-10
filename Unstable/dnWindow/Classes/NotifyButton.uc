class NotifyButton extends UWindowButton;

var NotifyWindow	NotifyWindow;

var font			MyFont;
var color			TextColor;
var string			Text;

var int				Type;

var float			LabelWidth, LabelHeight;
var float			XOffset;
var float			FadeFactor;

var bool			bLeftJustify;
var bool			bHighlightButton;
var bool			bDontSetLabel;


var texture			OtherTexture;
var texture			SelectedTexture;

function Paint( Canvas C, float X, float Y )
{
	local float Wx, Hy;
	local int W, H;
	local color HUDColor;
	
	// Set the color to that of the HUD.
	HUDColor.R = 255;
	HUDColor.G = 255;
	HUDColor.B = 255;
	
	C.DrawColor = HUDColor;

	if ( MouseIsOver() && bHighlightButton )
	{
		C.DrawColor.R = Clamp( C.DrawColor.R + 100, 0, 255 );
		C.DrawColor.G = Clamp( C.DrawColor.G + 100, 0, 255 );
		C.DrawColor.B = Clamp( C.DrawColor.B + 100, 0, 255 );
		TextColor.R = 255;
		TextColor.G = 255;
		TextColor.B = 0;
	} 
	else 
	{
		TextColor.R = 255;
		TextColor.G = 255;
		TextColor.B = 255;
	}

	Super.Paint( C, X, Y );

	W = WinWidth / 4;
	H = W;

	if ( W > 256 || H > 256 )
	{
		W = 256;
		H = 256;
	}

	if ( LabelWidth == 0 )
		LabelWidth = WinWidth;

	if ( LabelHeight == 0 )
		LabelHeight = WinHeight;

	C.DrawColor		= TextColor;
	C.DrawColor.R	= C.DrawColor.R * FadeFactor;
	C.DrawColor.G	= C.DrawColor.G * FadeFactor;
	C.DrawColor.B	= C.DrawColor.B * FadeFactor;
	//C.Font			= MyFont;

	TextSize( C, Text, Wx, Hy );

	if ( bLeftJustify )
	{
		ClipText( C, XOffset, ( LabelHeight - Hy ) / 2, Text );
	}
	else
	{
		ClipText( C, ( LabelWidth - Wx ) / 2, ( LabelHeight - Hy ) / 2, Text );
	}

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
}

function SetTextColor(color NewColor)
{
	TextColor = NewColor;
}

function Notify(byte E)
{
	NotifyWindow.Notify(Self, E);
}

defaultproperties
{
	bIgnoreLDoubleClick=False
}