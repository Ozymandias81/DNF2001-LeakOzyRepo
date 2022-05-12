class NameEditBox extends UWindowEditBox;

var NewCharacterWindow CharacterWindow;
var color TextColor;

function Notify(byte E)
{
	if(CharacterWindow != None)
	{
		CharacterWindow.Notify(Self, E);
	} else {
		Super.Notify(E);
	}
}

function Paint(Canvas C, float X, float Y)
{
	local float W, H, W2, H2;
	local float TextY;

	C.Font = class'UTLadderStub'.Static.GetBigFont(Root);

	TextSize(C, Value, W, H);
	if (W > WinWidth)
		C.Font = class'UTLadderStub'.Static.GetSmallFont(Root);

	TextSize(C, Value, W, H);
	if (W > WinWidth)
		C.Font = class'UTLadderStub'.Static.GetSmallestFont(Root);

	TextSize(C, Value, W, H);
	if (W > WinWidth)
		C.Font = class'UTLadderStub'.Static.GetAReallySmallFont(Root);

	TextSize(C, Value, W, H);
	if (W > WinWidth)
		C.Font = class'UTLadderStub'.Static.GetACompletelyUnreadableFont(Root);

	TextSize(C, "A", W, H);
	TextY = (WinHeight - H) / 2;

	TextSize(C, Left(Value, CaretOffset), W, H);


	C.DrawColor = TextColor;


	if(W + Offset < 0)
	{
		Offset = -W;
	}

	if(W + Offset > (WinWidth - 2))
	{
		Offset = (WinWidth - 2) - W;
		if(Offset > 0) Offset = 0;
	}

	C.DrawColor = TextColor;

	if(bAllSelected)
	{
		DrawStretchedTexture(C, Offset + 1, TextY, W, H, Texture'UWindow.WhiteTexture');

		// Invert Colors
		C.DrawColor.R = 255 ^ C.DrawColor.R;
		C.DrawColor.G = 255 ^ C.DrawColor.G;
		C.DrawColor.B = 255 ^ C.DrawColor.B;
	}

	TextSize(C, Value, W2, H2);
	Offset = (WinWidth - W2) / 2;
	ClipText(C, Offset + 1, TextY,  Value);

	if((!bHasKeyboardFocus) || (!bCanEdit))
	{
		bShowCaret = False;
	}
	else
	{
		if((GetLevel().TimeSeconds > LastDrawTime + 0.3) || (GetLevel().TimeSeconds < LastDrawTime))
		{
			LastDrawTime = GetLevel().TimeSeconds;
			bShowCaret = !bShowCaret;
		}
	}

	if(bShowCaret)
		ClipText(C, Offset + W - 1, TextY, "|");
}
