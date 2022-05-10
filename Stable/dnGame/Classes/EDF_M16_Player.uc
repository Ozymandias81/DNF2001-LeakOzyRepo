class EDF_M16_Player extends DukePlayer;

function AddDefaultInventory()
{	
	local class<Weapon> WeaponClass;
	local Weapon		Weap;

	// M16
	WeaponClass = class<Weapon>( DynamicLoadObject( "dnGame.M16", class'Class' ) );
	Level.Game.GiveWeaponTo( self, class'M16' );	
	Weap = Weapon( FindInventoryType( WeaponClass ) );
	
	if (Weap != None)
	{
		Weap.AmmoType.ModeAmount[0]		= Weap.AmmoType.MaxAmmo[0];
		Weap.AltAmmoType.ModeAmount[0]	= Weap.AltAmmoType.MaxAmmo[0];
	}
}

defaultproperties
{
	Mesh=c_characters.EDF1
	GroundSpeed=+00250.000000
}
