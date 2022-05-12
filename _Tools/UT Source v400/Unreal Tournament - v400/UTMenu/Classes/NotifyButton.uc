class NotifyButton extends UWindowButton;

var NotifyWindow NotifyWindow;

var font MyFont;
var color TextColor;

var string Text;

var bool bDontSetLabel;
var float LabelWidth, LabelHeight;

var bool bLeftJustify;
var float XOffset;

var texture OtherTexture;

function SetColorFont(Font NewFont)
{
	MyFont = NewFont;
}

function bool CheckMousePassThrough(float X, float Y)
{
	if ((X > LabelWidth) && (LabelWidth != 0))
		return true;
	if ((Y > LabelHeight) && (LabelHeight != 0))
		return true;

	return false;
}

function BeforePaint(Canvas C, float X, float Y)
{
}

function Paint(Canvas C, float X, float Y)
{
	local float Wx, Hy;
	local int W, H;

	Super.Paint(C, X, Y);

	W = WinWidth / 4;
	H = W;

	if(W > 256 || H > 256)
	{
		W = 256;
		H = 256;
	}

	if (bDontSetLabel)
	{
		if (LabelWidth == 0)
			LabelWidth = WinWidth;
		if (LabelHeight == 0)
			LabelHeight = WinHeight;
	} else {
		LabelWidth = WinWidth;
		LabelHeight = WinHeight;
	}

	C.DrawColor = TextColor;
	C.Font = MyFont;
	TextSize(C, Text, Wx, Hy);
	if (bLeftJustify)
		ClipText(C, XOffset, 0, Text);
	else
		ClipText(C, (LabelWidth - Wx)/2, (LabelHeight - Hy)/2, Text);
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