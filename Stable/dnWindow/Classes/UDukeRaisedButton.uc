class UDukeRaisedButton extends UWindowButton;

var int Index;

function Created()
{
	Super.Created();

	TextX = 0;
	TextY = 0;
	Font = F_Normal;
//	TextColor.R = 0;
//	TextColor.G = 0;
//	TextColor.B = 0;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;

	Super.BeforePaint(C, X, Y);

	WinHeight = 18;

	TextSize(C, Text, W, H);

	TextY = (WinHeight - H) / 2;

	switch(Align)
	{
	case TA_Left:
		TextX = 3;
		break;
	case TA_Right:
		TextX = WinWidth - W - 3;
		break;
	case TA_Center:	
		TextX = (WinWidth - W) / 2;
		break;
	}
}

function Paint(Canvas C, float X, float Y)
{
	local int iBevelType;
	local Texture Tex;
	
	iBevelType = 0;
	if(bMouseDown || bDisabled)
		iBevelType = 1;

	//TLW: Changed this function to deal with Misc being None, since Duke LookAndFeel doesn't
	//		have one (moved it into the active/inactive grouping)
	Tex = LookAndFeel.Misc;
	if(Tex == None)
		Tex = GetLookAndFeelTexture();
		
	DrawMiscBevel(C, 0, 0, WinWidth, WinHeight, Tex, iBevelType);

	Super.Paint(C, X, Y);
}

function KeyDown(int Key, float X, float Y)
{
	ParentWindow.KeyDown(Key, X, Y);
}

defaultproperties
{
}
