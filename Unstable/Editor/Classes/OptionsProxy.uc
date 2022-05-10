//=============================================================================
// OptionsProxy: Proxy for options.  This is purely a base class.
//
// Classes that begin with "Options" are used by the editor to display
// editable properties to the user for various functions.  They are proxies
// which save having to create scores of dialog boxes to accept input.
//
//=============================================================================
class OptionsProxy
	extends Object
	abstract
	native;

var string DlgCaption;

defaultproperties
{
	DlgCaption=""
}
