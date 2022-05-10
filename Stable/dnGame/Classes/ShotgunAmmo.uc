/*-----------------------------------------------------------------------------
	ShotgunAmmo
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class ShotgunAmmo extends Ammo;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx

function class<Ammo> GetClassForMode( int Mode )
{
	switch ( Mode )
	{
		case 0:
			return class'ShotgunAmmo';
		case 1:
			return class'ShotgunAmmoAcid';
	}
}


defaultproperties
{
	 MaxAmmoMode=2
	 ModeAmount(0)=14
     MaxAmmo(0)=140
     MaxAmmo(1)=140
     PickupSound=Sound'dnGame.Pickups.AmmoSnd'
     Physics=PHYS_Falling
     PickupViewMesh=Mesh'c_dnWeapon.shotbox_cl_reg'
	 PickupIcon=texture'hud_effects.am_shot12gauge'
     Mesh=Mesh'c_dnWeapon.shotbox_cl_reg'
     bMeshCurvy=false
     CollisionRadius=12.0
     CollisionHeight=4.0
     bCollideActors=true
	 LodMode=LOD_Disabled
	 ItemName="Shotgun Shells"
	 SpawnOnHitClassString="dnParticles.dnBulletFX_FabricSpawner"
}