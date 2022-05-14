class UDukeControlsBindButton extends UWindowDialogControl;

var string ActionText;
var string AssignedText;

var bool Selected;
var bool bIsHeading;

function Paint(Canvas C, float X, float Y)
{
	local float XL, YL;
	local UDukeLookAndFeel LaF;
	local vector P1, P2;

	if (bIsHeading)
		C.Font = Root.Fonts[F_Bold];
	else
		C.Font = Root.Fonts[F_Normal];
	TextSize(C, ActionText, XL, YL);
	ClipText(C, 2, (20-YL)/2, ActionText);
	TextSize(C, AssignedText, XL, YL);
	ClipText(C, WinWidth/2 + 2, (20-YL)/2, AssignedText);

	if (bIsHeading)
	{
		DrawStretchedTexture(C, 0, 1, WinWidth, 1, texture'WhiteTexture');
		DrawStretchedTexture(C, 0, WinHeight-1, WinWidth, 1, texture'WhiteTexture');
	}

	LaF = UDukeLookAndFeel(LookAndFeel);
	if (Selected)
		DrawUpBevel(C, 0, 0, WinWidth, WinHeight, GetLookAndFeelTexture());

	Super.Paint(C, X, Y);
}

simulated function Click(float X, float Y) 
{
	Notify(DE_Click);
	LookAndFeel.PlayMenuSound(Self, MS_SubMenuOpen);
}

function DoubleClick(float X, float Y) 
{
	Notify(DE_DoubleClick);
}

function RClick(float X, float Y) 
{
	Notify(DE_RClick);
}

function MClick(float X, float Y) 
{
	Notify(DE_MClick);
}

defaultproperties
{
     bIgnoreLDoubleClick=True
     bIgnoreMDoubleClick=True
     bIgnoreRDoubleClick=True
}
