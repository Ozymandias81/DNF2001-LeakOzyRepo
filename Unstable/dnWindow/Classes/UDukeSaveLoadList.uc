//=============================================================================
// UDukeSaveLoadList.uc
//	John Pollard
//=============================================================================
class UDukeSaveLoadList extends UWindowList;

var string			Description;
var string			DateTime;

var int				Year, Month, Day, DayOfWeek, Hour, Minute, Second;		// For sorting

var int				ID;
var ESaveType		SaveType;

var bool			bHidden;

function int Compare(UWindowList T, UWindowList B)
{
	local UDukeSaveLoadList	PT, PB;

	if(B == None) 
		return 0; 

	PT = UDukeSaveLoadList(T);
	PB = UDukeSaveLoadList(B);

	//if (PT.SaveType > PB.SaveType)
	//	return 1;
	//if (PT.SaveType < PB.SaveType)
	//	return -1;
	if (PT.Year < PB.Year)
		return 1;
	else if (PT.Year > PB.Year)
		return -1;
	else if (PT.Month < PB.Month)
		return 1;
	else if (PT.Month > PB.Month)
		return -1;
	else if (PT.Day < PB.Day)
		return 1;
	else if (PT.Day > PB.Day)
		return -1;
	else if (PT.Hour < PB.Hour)
		return 1;
	else if (PT.Hour > PB.Hour)
		return -1;
	else if (PT.Minute < PB.Minute)
		return 1;
	else if (PT.Minute > PB.Minute)
		return -1;
	else if (PT.Second < PB.Second)
		return 1;
	else if (PT.Second > PB.Second)
		return -1;

	return 0;
}

defaultproperties
{
	bHidden=false
}