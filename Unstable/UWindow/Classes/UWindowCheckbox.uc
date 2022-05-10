/*-----------------------------------------------------------------------------
	UWindowCheckbox
-----------------------------------------------------------------------------*/
class UWindowCheckbox extends UWindowButton;

var bool		bChecked;

function BeforePaint( canvas C, float X, float Y )
{
	LookAndFeel.Checkbox_SetupSizes( Self, C );
	Super.BeforePaint( C, X, Y );
}

function Paint( canvas C, float X, float Y )
{
	if ( !LookAndFeel.Checkbox_Draw(Self, C) )
		Super.Paint( C, X, Y );
}

function LMouseUp( float X, float Y )
{
	if ( !bDisabled )
	{	
		bChecked = !bChecked;
		Notify( DE_Change );
	}
	
	Super.LMouseUp( X, Y );
}

// A terrible abuse of all known programming concepts.
function int GetHeightAdjust()
{
	return -6;
}

defaultproperties
{
}
