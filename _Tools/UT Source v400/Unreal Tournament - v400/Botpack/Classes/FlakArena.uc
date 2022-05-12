//=============================================================================
// FlakArena.
// replaces all weapons and ammo with FlakCannons and ammo
//=============================================================================

class FlakArena expands Arena;

defaultproperties
{
	AmmoName=FlakAmmo
	AmmoString="Botpack.flakammo"
	WeaponName=UT_FlakCannon
	WeaponString="Botpack.UT_FlakCannon"
	DefaultWeapon=class'Botpack.UT_FlakCannon'
}