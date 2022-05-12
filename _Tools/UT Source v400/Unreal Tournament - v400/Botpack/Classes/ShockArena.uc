//=============================================================================
// ShockArena.
// replaces all weapons and ammo with Shockrifles and ammo
//=============================================================================

class ShockArena expands Arena;

defaultproperties
{
	AmmoName=ShockCore
	AmmoString="Botpack.ShockCore"
	WeaponName=ShockRifle
	WeaponString="Botpack.ShockRifle"
	DefaultWeapon=class'Botpack.ShockRifle'
}