//=============================================================================
// OptionsTexAlignFace: Options for "face" texture alignment tool.
//
//=============================================================================
class OptionsTexAlignFace
	extends OptionsProxy
	native;

var() float TileU;
var() float TileV;

defaultproperties
{
	TileU=1
	TileV=1

	DlgCaption="Face"
}
