/*-----------------------------------------------------------------------------
	SniperCell
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class SniperCell expands Ammo;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\Textures\m_dnWeapon.dtx

defaultproperties
{
     ModeAmount(0)=20
     MaxAmmo(0)=100
	 PickupIcon=texture'hud_effects.am_battery'
     PickupViewMesh=Mesh'c_dnWeapon.a_batteryammo1'
     PickupSound=Sound'dnGame.Pickups.AmmoSnd'
     Physics=PHYS_Falling
     Mesh=Mesh'c_dnWeapon.a_batteryammo1'
     bMeshCurvy=False
     CollisionRadius=12.0
     CollisionHeight=6.0
     bCollideActors=true
	 LodMode=LOD_Disabled
	 ItemName="Sniper Energy Cell"
}
