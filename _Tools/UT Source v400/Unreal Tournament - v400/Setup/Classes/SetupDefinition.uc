//=============================================================================
// SetupDefinition: Definition of the current installation.
//=============================================================================
class SetupDefinition extends SetupProduct
	native
	perobjectconfig;

var localized string DefaultFolder;
var string        DefaultLanguage;
var string        License;
var string        ReadMe;
var string        Logo;
var localized string SetupWindowTitle, AutoplayWindowTitle;
var array<string> Requires;

defaultproperties
{
	Product="Product"
	DefaultFolder="C:\Folder"
	DefaultLanguage="int"
	License="..\\Help\\License.txt"
	ReadMe="..\\Help\\ReadMe.txt"
	Logo="..\\Help\\Logo.bmp"
	SetupWindowTitle="Setup"
	AutoplayWindowTitle="Autoplay Options"
	RequiredProducts=()
}
