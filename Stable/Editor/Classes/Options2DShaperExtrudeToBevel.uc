//=============================================================================
// Options2DShaperExtrudeToBevel: Options for extruding to a bevel in the 2D shaper.
//
//=============================================================================
class Options2DShaperExtrudeToBevel
	extends Options2DShaper
	native;

var() float Height;
var() float CapHeight;

defaultproperties
{
	Height=128
	CapHeight=32

	DlgCaption="Extrude To Bevel"
}
