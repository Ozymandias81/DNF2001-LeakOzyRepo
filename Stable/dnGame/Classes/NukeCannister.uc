/*-----------------------------------------------------------------------------
	NukeCannister
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class NukeCannister extends RocketPack;

defaultproperties
{
	 AmmoType=1
	 ModeAmount(0)=0
	 ModeAmount(1)=1
	 ParentAmmo=dnGame.rocketPack
     PickupViewMesh=Mesh'c_dnWeapon.nukecannister'
	 PickupIcon=texture'hud_effects.am_rpgnuke'
     Mesh=Mesh'c_dnWeapon.nukecannister'
     CollisionRadius=12.0
     CollisionHeight=11.0
	 LodMode=LOD_Disabled
	 ItemName="Tac-Nuke Warhead"
}