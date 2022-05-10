//=============================================================================
// UDukeSaveEditBox
// John Pollard
//=============================================================================
class UDukeSaveEditBox extends UWindowEditBox;

function KeyDown(int Key, float X, float Y)
{
	ParentWindow.KeyDown(Key, X, Y);
	Super.KeyDown(Key, X, Y);
}

defaultproperties
{
}
