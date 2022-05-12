//=============================================================================
// SetupGroup: Information about a group of installable files.
//=============================================================================
class SetupGroup extends SetupObject
	native
	perobjectconfig;

var bool       Visible;
var string     Title;
var string     Description;

var array<SetupGroup> RequiredGroups;
var array<SetupLink>  Links;
var array<string>     Files;

defaultproperties
{
	Visible=True
	Title="Group"
	Description="Description"
	RequiredGroups=()
	Links=()
	Files=()
}