/*-----------------------------------------------------------------------------
	HypoVial_Steroids
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HypoVial_Steroids expands HypoVial_Health;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\Textures\m_dnWeapon.dtx
#exec OBJ LOAD FILE=..\Textures\SMK6.dtx
#exec OBJ LOAD FILE=..\Sounds\a_dukevoice.dfx

defaultproperties
{
	MaxAmmoMode=3
	AmmoType=1
	ModeAmount(0)=0
	ModeAmount(1)=1
	ModeAmount(2)=0
	AnimSequence=bottle_up
	ParentAmmo=dnGame.HypoVial_Health
	MultiSkins(2)=texture'm_dnWeapon.vial_efx_red'
	ItemName="Steroids HypoVial"
	PickupIcon=texture'hud_effects.am_steroids'
	VendTitle(0)=texture'ezvend.descriptions.stroid_desc0'
	VendTitle(1)=texture'ezvend.descriptions.stroid_desc1'
	VendTitle(2)=texture'ezvend.descriptions.stroid_desc2'
	VendTitle(3)=texture'ezvend.descriptions.stroid_desc3'
	VendIcon=texture'smk6.steroid_spn'
	VendSound=sound'a_dukevoice.ezvend.ez-sportsdrink'
	VendPrice=BUCKS_50
}