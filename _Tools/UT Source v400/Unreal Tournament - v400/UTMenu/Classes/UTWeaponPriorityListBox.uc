class UTWeaponPriorityListBox expands UMenuWeaponPriorityListBox;

var UWindowDynamicTextArea Description;

function SelectWeapon()
{
	Super.SelectWeapon();

	if(Description == None)
		Description = UWindowDynamicTextArea(GetParent(class'UMenuWeaponPriorityCW').FindChildWindow(class'UWindowDynamicTextArea'));

	Description.Clear();
	Description.AddText(UTWeaponPriorityList(SelectedItem).WeaponDescription);	
}

function ReadWeapon(UMenuWeaponPriorityList L, class<Weapon> WeaponClass)
{
	Super.ReadWeapon(L, WeaponClass);
	UTWeaponPriorityList(L).WeaponDescription = class<TournamentWeapon>(WeaponClass).default.WeaponDescription;
}

defaultproperties
{
	ListClass=class'UTWeaponPriorityList'
	WeaponClassParent="Botpack.TournamentWeapon"
}
