//=============================================================================
// OptionsBrushScale: Options for scaling brushes.
//
//=============================================================================
class OptionsBrushScale
	extends OptionsProxy
	native;

var() float X;
var() float Y;
var() float Z;

defaultproperties
{
	X=1
	Y=1
	Z=1

	DlgCaption="Brush Scale"
}
