//=============================================================================
// Options2DShaperBezierDetail: Options for custom detail levels in beziers
//
//=============================================================================
class Options2DShaperBezierDetail
	extends OptionsProxy
	native;

var() int DetailLevel;

defaultproperties
{
	DetailLevel=10

	DlgCaption="Bezier Detail"
}
