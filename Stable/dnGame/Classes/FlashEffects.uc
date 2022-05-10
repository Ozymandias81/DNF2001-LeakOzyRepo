/*-----------------------------------------------------------------------------
	FlashEffects
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class FlashEffects extends Effects;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx

defaultproperties
{
	DrawType=DT_Mesh
	LifeSpan=0.06
	LODMode=LOD_Disabled
	RemoteRole=ROLE_None
	bIgnoreBList=true
}