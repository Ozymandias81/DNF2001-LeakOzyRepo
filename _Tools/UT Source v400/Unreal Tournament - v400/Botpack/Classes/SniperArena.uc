//=============================================================================
// SniperArena.
// replaces all weapons and ammo with Sniperrifles and ammo
//=============================================================================

class SniperArena expands Arena;

defaultproperties
{
	AmmoName=BulletBox
	AmmoString="Botpack.BulletBox"
	WeaponName=SniperRifle
	WeaponString="Botpack.SniperRifle"
	DefaultWeapon=class'Botpack.SniperRifle'
}