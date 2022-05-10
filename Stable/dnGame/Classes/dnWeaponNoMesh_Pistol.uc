/*-----------------------------------------------------------------------------
	dnWeaponNoMesh_Pistol
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class dnWeaponNoMesh_Pistol expands dnWeaponNoMesh;

defaultproperties
{
	AmmoName=Class'dnGame.pistolClip'
	AmmoLoaded=15
	ReloadCount=15
	PickupAmmoCount=45
	bInstantHit=True

	PickupSound=Sound'dnGame.Pickups.WeaponPickup'
	Icon=Texture'hud_effects.mitem_deagle'
	PickupIcon=Texture'hud_effects.am_deserteagle'

	SoundRadius=64
	SoundVolume=200
	CollisionHeight=6.0
	CollisionRadius=18.0
	Mass=1.000000

	PickupViewMesh=DukeMesh'c_dnWeapon.w_pistol_black'

	AltAmmoItemClass=class'HUDIndexItem_PistolAlt'
	AmmoItemClass=class'HUDIndexItem_Pistol'
	bMultiMode=true

	ItemName="Desert Eagle, No Mesh Test"

	dnInventoryCategory=1
	dnCategoryPriority=1

	bTraceHitRicochets=true
	bBeamTraceHit=true

	CrosshairIndex=11

	bFireIgnites=true
	TraceDamageType=class'PistolDamage'
}