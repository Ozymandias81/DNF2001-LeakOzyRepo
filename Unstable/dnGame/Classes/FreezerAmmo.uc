/*-----------------------------------------------------------------------------
	FreezerAmmo
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class FreezerAmmo expands Ammo;

defaultproperties
{
     ModeAmount(0)=50
     MaxAmmo(0)=300
	 PickupIcon=texture'hud_effects.am_m16nato'
     PickupViewMesh=Mesh'c_dnWeapon.A_M16Clip'
     PickupSound=Sound'dnGame.Pickups.AmmoSnd'
     Physics=PHYS_Falling
     Mesh=Mesh'c_dnWeapon.A_M16Clip'
     bMeshCurvy=False
     CollisionRadius=12.0
     CollisionHeight=6.0
     bCollideActors=True
	 LodMode=LOD_Disabled
	 ItemName="Freezer Ammo Thing"
}