class UDukeLabelControl extends UWindowLabelControl;

function Created()
{
	Super.Created();

	Font = F_Normal;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;
	
	Super.BeforePaint(C, X, Y);
	if(IsValidString(Text))
		C.DrawColor = LookAndFeel.HeadingActiveTitleColor;
}

defaultproperties
{
}
