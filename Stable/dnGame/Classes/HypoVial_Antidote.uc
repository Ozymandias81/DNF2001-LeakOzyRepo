/*-----------------------------------------------------------------------------
	HypoVial_Antidote
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HypoVial_Antidote expands HypoVial_Health;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\Textures\m_dnWeapon.dtx

defaultproperties
{
	MaxAmmoMode=3
	AmmoType=2
	ModeAmount(0)=0
	ModeAmount(1)=0
	ModeAmount(2)=1
	AnimSequence=bottle_up
	ParentAmmo=dnGame.HypoVial_Health
	MultiSkins(2)=texture'm_dnWeapon.vial_efx_green'
	ItemName="Antidote HypoVial"
	PickupIcon=texture'hud_effects.am_antidote'
}