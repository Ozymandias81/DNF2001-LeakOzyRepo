class EDF_Shotgun_Player extends DukePlayer;

function AddDefaultInventory()
{	
	local class<Weapon> WeaponClass;
	local Weapon		Weap;

	// Shotgun
	WeaponClass = class<Weapon>(DynamicLoadObject( "dnGame.Shotgun", class'Class' ));
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
	Mesh=c_characters.PigCop
	GroundSpeed=+00250.000000
}
