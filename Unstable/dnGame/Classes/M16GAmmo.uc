/*-----------------------------------------------------------------------------
	M16GAmmo
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class M16GAmmo expands Ammo;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx

defaultproperties
{
     ModeAmount(0)=5
     MaxAmmo(0)=20
     PickupViewMesh=Mesh'c_dnWeapon.A_M16G'
     MaxDesireability=0.300000
     PickupSound=Sound'dnGame.Pickups.AmmoSnd'
     Physics=PHYS_Falling
     Mesh=Mesh'c_dnWeapon.A_M16G'
     bMeshCurvy=False
     CollisionRadius=12.0
     CollisionHeight=4.0
     bCollideActors=True
	 LodMode=LOD_Disabled
	 PickupIcon=texture'hud_effects.am_m16grenades'
	 ItemNAme="40mm Grenades"
}