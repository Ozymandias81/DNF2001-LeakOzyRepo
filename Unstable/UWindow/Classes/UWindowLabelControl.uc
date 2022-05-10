class UWindowLabelControl extends UWindowDialogControl;

function Created()
{
	TextX = 0;
	TextY = 0;
}

function BeforePaint(Canvas C, float X, float Y)
{
	AutoSize( C );

	Super.BeforePaint(C, X, Y);
}

function Paint(Canvas C, float X, float Y)
{
	C.DrawColor = LookAndFeel.GetTextColor(Self);
	LookAndFeel.ClipText(Self, C, TextX, TextY, Text);
}

function AutoSize( Canvas C )
{
	local float W, H;

	C.Font = Root.Fonts[Font];
	TextSize( C, Text, W, H );
	WinHeight = H+1;
	WinWidth = W;
	TextY = (WinHeight - H) / 2;
	switch (Align)
	{
		case TA_Left:
			break;
		case TA_Center:
			TextX = (WinWidth - W)/2;
			break;
		case TA_Right:
			TextX = WinWidth - W;
			break;
	}

}

defaultproperties
{
}
