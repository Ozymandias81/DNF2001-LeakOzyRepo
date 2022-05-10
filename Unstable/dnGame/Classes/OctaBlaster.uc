class OctaBlaster extends dnWeaponNoMesh;

defaultproperties
{
	AmmoName=Class'dnGame.rocketPack'
	ReloadCount=1
	ReloadClipAmmo=0
	PickupAmmoCount(0)=30
	ItemName="OctaBlaster"

	PickupViewMesh=Mesh'c_dnWeapon.w_rpg'	
	PickupSound=Sound'dnGame.Pickups.WeaponPickup'

	Icon=Texture'hud_effects.mitem_RPG'
	PickupIcon=Texture'hud_effects.am_rpg'

	SoundRadius=64
	SoundVolume=200
	
	CollisionHeight=8.000000
	ProjectileClass=class'dnRocket_BrainBlast'

	AmmoItemClass=class'HUDIndexItem_RPG'
	dnCategoryPriority=3
	dnInventoryCategory=2

	CrosshairIndex=7
	bFireIgnites=true

	RefireDelay=1.0
}
