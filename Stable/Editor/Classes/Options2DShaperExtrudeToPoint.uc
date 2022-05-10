//=============================================================================
// Options2DShaperExtrudeToPoint: Options for extruding to a point in the 2D shaper.
//
//=============================================================================
class Options2DShaperExtrudeToPoint
	extends Options2DShaper
	native;

var() float Depth;

defaultproperties
{
	Depth=256

	DlgCaption="Extrude To Point"
}
