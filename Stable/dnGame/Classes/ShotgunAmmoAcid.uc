/*-----------------------------------------------------------------------------
	ShotgunAmmoAcid
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class ShotgunAmmoAcid extends ShotgunAmmo;

defaultproperties
{
	 AmmoType=1
	 ModeAmount(0)=0
	 ModeAmount(1)=14
	 ParentAmmo=dnGame.shotgunAmmo
     PickupViewMesh=Mesh'c_dnWeapon.shotbox_cl_acid'
     Mesh=Mesh'c_dnWeapon.shotbox_cl_acid'
	 PickupIcon=texture'hud_effects.am_shotacidshel'
	 ItemName="Acid Shells"
}