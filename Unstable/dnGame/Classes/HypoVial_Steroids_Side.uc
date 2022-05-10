/*-----------------------------------------------------------------------------
	HypoVial_Steroids_Side
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HypoVial_Steroids_Side expands HypoVial_Health;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\Textures\m_dnWeapon.dtx

defaultproperties
{
	MaxAmmoMode=3
	AmmoType=1
	ModeAmount(0)=0
	ModeAmount(1)=1
	ModeAmount(2)=0
	RestSequence=bottle_side
	ParentAmmo=dnGame.HypoVial_Health
	MultiSkins(2)=texture'm_dnWeapon.vial_efx_red'
	ItemName="Steroids HypoVial"
	PickupIcon=texture'hud_effects.am_steroids'
}