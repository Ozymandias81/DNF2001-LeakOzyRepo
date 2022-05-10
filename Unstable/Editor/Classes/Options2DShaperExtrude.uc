//=============================================================================
// Options2DShaperExtrude: Options for extruding in the 2D shaper.
//
//=============================================================================
class Options2DShaperExtrude
	extends Options2DShaper
	native;

var() float Depth;

defaultproperties
{
	Depth=256

	DlgCaption="Extrude"
}
