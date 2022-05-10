class BUG_HeavyWeaps_Player extends DukePlayer;

function AddDefaultInventory()
{	
	local class<Weapon> WeaponClass;
	local Weapon		Weap;

	// RPG
	WeaponClass = class<Weapon>(DynamicLoadObject( "dnGame.RPG", class'Class' ));
	Level.Game.GiveWeaponTo( self, WeaponClass, true );
	Weap = Weapon(FindInventoryType( WeaponClass ));
	if (Weap != None)
	{
		Weap.AmmoType.ModeAmount[0] = Weap.AmmoType.MaxAmmo[0];
		Weap.AmmoType.ModeAmount[1] = Weap.AmmoType.MaxAmmo[1];
	}
}

defaultproperties
{
	Mesh=c_characters.EDF2Desert
	GroundSpeed=+00200.000000
}
