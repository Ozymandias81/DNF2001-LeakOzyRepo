//=============================================================================
// Options2DShaper: Options for extruding in the 2D shaper.
//
//=============================================================================
class Options2DShaper
	extends OptionsProxy
	native;

var() enum EAxis
{
	AXIS_X,
	AXIS_Y,
	AXIS_Z
} Axis;

defaultproperties
{
	Axis=AXIS_Y
}
