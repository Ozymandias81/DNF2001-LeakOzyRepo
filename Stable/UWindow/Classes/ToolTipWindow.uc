/*-----------------------------------------------------------------------------
	ToolTipWindow
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class ToolTipWindow extends UWindowWindow transient;

var string ToolTip;
var color ToolColor, TextColor;

function Created()
{
	bLeaveOnScreen = true;

	Super.Created();
}

function Paint( Canvas C, float X, float Y )
{
	local float XL, YL;
	local color OldColor;

	C.Font = Root.Fonts[F_Bold];
	TextSize(C, ToolTip, XL, YL);
	SetSize(XL + 8, YL + 8);

	OldColor = C.DrawColor;
	C.DrawColor = ToolColor;
//	DrawUpBevel( C, 0, 0, WinWidth, WinHeight, GetLookAndFeelTexture(), LookAndFeel.vecGUIWindowsHSV.z, true, true );

	C.DrawColor = TextColor;
	ClipText( C, 4, 4, ToolTip );

	C.DrawColor = OldColor;
	Super.Paint( C, X, Y );
}

defaultproperties
{
	ToolTip="Tool Tip"
}