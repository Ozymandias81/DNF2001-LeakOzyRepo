/*-----------------------------------------------------------------------------
	UDukeArrowButton
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class UDukeArrowButton extends UWindowButton;

var bool bLeft;

function BeforePaint( Canvas C, float X, float Y )
{
	Super.BeforePaint( C, X, Y );

	UpTexture = GetLookAndFeelTexture2();
	OverTexture = GetLookAndFeelTexture2();
	DownTexture = GetLookAndFeelTexture2();

	if ( bLeft )
	{
		UpRegion = LookAndFeel.ArrowButtonLeftUp;
		OverRegion = LookAndFeel.ArrowButtonLeftUp;
		DownRegion = LookAndFeel.ArrowButtonLeftDown;
	}
	else
	{
		UpRegion = LookAndFeel.ArrowButtonRightUp;
		OverRegion = LookAndFeel.ArrowButtonRightUp;
		DownRegion = LookAndFeel.ArrowButtonRightDown;
	}
}

defaultproperties
{
	bUseRegion=true
	bSolid=true
}