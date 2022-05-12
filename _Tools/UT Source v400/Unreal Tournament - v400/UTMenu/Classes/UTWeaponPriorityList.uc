class UTWeaponPriorityList expands UMenuWeaponPriorityList;

var string WeaponDescription;

function bool ShowThisItem()
{
	return bFound && Left(WeaponClassName, 8) ~= "Botpack.";
}
