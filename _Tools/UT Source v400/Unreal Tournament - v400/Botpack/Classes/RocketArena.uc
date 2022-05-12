//=============================================================================
// RocketArena.
// replaces all weapons and ammo with RocketLaunchers and ammo
//=============================================================================

class RocketArena expands Arena;

defaultproperties
{
	AmmoName=RocketPack
	AmmoString="Botpack.RocketPack"
	WeaponName=UT_Eightball
	WeaponString="Botpack.UT_Eightball"
	DefaultWeapon=class'Botpack.UT_Eightball'
}