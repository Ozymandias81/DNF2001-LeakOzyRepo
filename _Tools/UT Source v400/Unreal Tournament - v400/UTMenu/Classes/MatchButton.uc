class MatchButton extends UWindowButton;

var font MyFont;
var color TextColor;

var Class<Ladder> Ladder;
var int MatchIndex;

var bool bUnknown;
var localized string UnknownText;

var UTLadder LadderWindow;

var float LabelWidth, LabelHeight;

var texture OtherTexture, OldOverTexture;

function bool CheckMousePassThrough(float X, float Y)
{
	if ((X > LabelWidth) && (LabelWidth != 0))
		return true;
	if ((Y > LabelHeight) && (LabelHeight != 0))
		return true;

	return false;
}

function Paint(Canvas C, float X, float Y)
{
	local float Wx, Hy, XL, YL, XMod, YMod;
	local string MapName;
	local int W, H;

	W = Root.WinWidth / 4;
	H = W;

	if(W > 256 || H > 256)
	{
		W = 256;
		H = 256;
	}

	XMod = 4*W;
	YMod = 3*H;

	Super.Paint(C, X, Y);

	MapName = Ladder.Static.GetMapTitle(MatchIndex);
	C.DrawColor = TextColor;
	C.Font = MyFont;
	if (bUnknown)
	{
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 0;
		MapName = UnknownText;
	}
	if (LabelWidth == 0)
		LabelWidth = WinWidth;

	if (LabelHeight == 0)
		LabelHeight = WinHeight;

	TextSize(C, MapName, XL, YL);
	if ( XL > LabelWidth - (14.0/1024 * XMod) )
	{
		C.Font = class'UTLadderStub'.Static.GetSmallFont(Root);
		TextSize(C, MapName, XL, YL);
		if ( XL > LabelWidth - (14.0/1024 * XMod) )
		{
			// first remove leading "the"
			if ( Left(MapName, 4) ~= "The ")
			{
				MapName = Right(MapName, Len(MapName) - 4);
				TextSize(C, MapName, XL, YL);
			}
			MapName = Left(MapName, Len(MapName) * LabelWidth/XL);
		}
	}

	TextSize(C, MapName, Wx, Hy);
	ClipText(C, (LabelWidth - Wx)/2, (LabelHeight - Hy)/2, MapName);
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
}


function SetTextColor(color NewColor)
{
	TextColor = NewColor;
}

function SetLadder(Class<Ladder> NewLadder)
{
	Ladder = NewLadder;
}

function SetMatchIndex(int NewIndex)
{
	MatchIndex = NewIndex;
}

function Notify(byte E)
{
	if (!bDisabled)
		LadderWindow.Notify(Self, E);
}

defaultproperties
{
	bIgnoreLDoubleClick=False
	UnknownText="? Unknown ?"
}