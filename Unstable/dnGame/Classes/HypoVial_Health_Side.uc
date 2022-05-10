/*-----------------------------------------------------------------------------
	HypoVial_Health_Side
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HypoVial_Health_Side expands HypoVial_Health;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\Textures\m_dnWeapon.dtx

defaultproperties
{
	 MaxAmmoMode=3
	 ModeAmount(0)=1
	 ModeAmount(1)=0
	 ModeAmount(2)=0
	 RestSequence=bottle_side
	 ParentAmmo=dnGame.HypoVial_Health
}