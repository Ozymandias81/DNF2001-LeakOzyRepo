/*-----------------------------------------------------------------------------
	ShotgunFlash
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class ShotgunFlash extends Effects;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=mesh'c_dnweapon.flash_shotgun'
	LifeSpan=0.06
	LODMode=LOD_Disabled
	RemoteRole=ROLE_None
	bIgnoreBList=true
}