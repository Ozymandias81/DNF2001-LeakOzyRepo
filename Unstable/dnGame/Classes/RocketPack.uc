/*-----------------------------------------------------------------------------
	RocketPack
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class RocketPack extends Ammo;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx

// Ammo mode/type:
// 0, Normal
// 1, Nuke

defaultproperties
{
	 MaxAmmoMode=2
	 AmmoType=0
	 ModeAmount(0)=5
     MaxAmmo(0)=50
     MaxAmmo(1)=1
     PickupViewMesh=Mesh'c_dnWeapon.a_rocketpackA'
     PickupSound=Sound'dnGame.Pickups.AmmoSnd'
	 PickupIcon=texture'hud_effects.am_rpgrockets'
     Physics=PHYS_Falling
     Mesh=Mesh'c_dnWeapon.a_rocketpackA'
     bMeshCurvy=false
     CollisionRadius=12.000000
     CollisionHeight=11.000000
     bCollideActors=true
	 LodMode=LOD_Disabled
	 ItemName="RPG Rockets"
}