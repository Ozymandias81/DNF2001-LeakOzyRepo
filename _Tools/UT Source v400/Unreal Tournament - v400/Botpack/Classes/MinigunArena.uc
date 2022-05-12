//=============================================================================
// MinigunArena.
// replaces all weapons and ammo with Sniperrifles and ammo
//=============================================================================

class MinigunArena expands Arena;

defaultproperties
{
	AmmoName=MiniAmmo
	AmmoString="Botpack.MiniAmmo"
	WeaponName=Minigun2
	WeaponString="Botpack.Minigun2"
	DefaultWeapon=class'Botpack.Minigun2'
}