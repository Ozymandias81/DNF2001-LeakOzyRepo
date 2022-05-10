/*-----------------------------------------------------------------------------
	HypoAir
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HypoAir extends Ammo;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\Textures\m_dnWeapon.dtx

function Tick( float Delta )
{
	BroadcastMessage("HYPOAIR IS OUTDATED REMOVE ME!!!! HYPO GUNS DON'T USE AIR ANY MORE!!!!");
}

defaultproperties
{
	MaxAmmoMode=1
	AmmoType=0
	ModeAmount(0)=10
	MaxAmmo(0)=10

	AnimSequence=bottle_up
    PickupViewMesh=Mesh'c_dnWeapon.w_c02'
    PickupSound=Sound'dnGame.Pickups.AmmoSnd'
    Physics=PHYS_Falling
    Mesh=Mesh'c_dnWeapon.w_c02'
    bMeshCurvy=false
    CollisionRadius=12.0
    CollisionHeight=5.0
    bCollideActors=true
	MultiSkins(2)=texture'm_dnWeapon.vial_efx_blue'
	LodMode=LOD_Disabled
	PickupIcon=texture'hud_effects.am_c02'
	ItemName="Hypo Air"

	VendTitle(0)=texture'ezvend.descriptions.co2_00'
	VendTitle(1)=texture'ezvend.descriptions.co2_01'
	VendTitle(2)=texture'ezvend.descriptions.co2_02'
	VendTitle(3)=texture'ezvend.descriptions.co2_03'
	VendIcon=texture'smk6.co2_spn'
	VendSound=sound'a_dukevoice.ezvend.ez-sportsdrink'
	VendPrice=BUCKS_25
}
