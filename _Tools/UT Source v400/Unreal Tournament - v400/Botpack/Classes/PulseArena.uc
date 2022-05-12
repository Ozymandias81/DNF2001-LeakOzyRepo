//=============================================================================
// PulseArena.
// replaces all weapons and ammo with Pulseguns and pulsegun ammo
//=============================================================================

class PulseArena expands Arena;

defaultproperties
{
	AmmoName=PAmmo
	AmmoString="Botpack.PAmmo"
	WeaponName=PulseGun
	WeaponString="Botpack.PulseGun"
	DefaultWeapon=class'Botpack.PulseGun'
}