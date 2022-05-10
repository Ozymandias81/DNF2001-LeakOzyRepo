/*-----------------------------------------------------------------------------
	ShotgunAmmoAcid_Open
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class ShotgunAmmoAcid_Open extends ShotgunAmmo;

defaultproperties
{
	 AmmoType=1
	 ModeAmount(0)=0
	 ModeAmount(1)=14
	 ParentAmmo=dnGame.shotgunAmmo
     PickupViewMesh=Mesh'c_dnWeapon.shotbox_op_acid'
     Mesh=Mesh'c_dnWeapon.shotbox_op_acid'
	 PickupIcon=texture'hud_effects.am_shotacidshel'
	 ItemName="Acid Shells"
}