//=============================================================================
// MapLocations
//=============================================================================
class MapLocations extends Info
	native
	transient;

// User defined map data
struct native MapInfoData
{
	var config string		Location;
	var config string		Name;
	var config string		URL;
	var config string		SShot;
	var config bool			Enabled;
};

var() config int			NumMaps;
var() config MapInfoData	Maps[128];
var() config float			ScrollSpeed;

//==========================================================================================
//	defaultproperties
//==========================================================================================
defaultproperties
{
	ScrollSpeed=7;
	NumMaps = 1;
	Maps[0]=(Location="Lady Killer Rooftop",Name="Lady Killer Rooftop 1",URL="!z1l1_1",SShot="",Enabled=true);
}