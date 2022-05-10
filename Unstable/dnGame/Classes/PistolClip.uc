/*-----------------------------------------------------------------------------
	PistolClip
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class PistolClip expands Ammo;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\Textures\m_dnWeapon.dtx

// Ammo mode/type:
// 0, Normal
// 1, Hollow Point
// 2, Armor Piercing

function class<Ammo> GetClassForMode(int Mode)
{
	switch (Mode)
	{
		case 0:
			return class'PistolClip';
		case 1:
			return class'PistolClipHP';
		case 2:
			return class'PistolClipAP';
	}
}

defaultproperties
{
	 MaxAmmoMode=3
	 ModeDamageMultiplier(0)=1.0
	 ModeDamageMultiplier(1)=2.0
	 ModeDamageMultiplier(2)=1.0
	 ModeAccuracyModifier(0)=0.0
	 ModeAccuracyModifier(1)=0.02
	 ModeAccuracyModifier(2)=-0.015
 	 CanPierceArmor(2)=1
	 ModeAmount(0)=15
     MaxAmmo(0)=150
     MaxAmmo(1)=150
     MaxAmmo(2)=150

     PickupViewMesh=Mesh'c_dnWeapon.A_PistolClip'
     PickupSound=Sound'dnGame.Pickups.AmmoSnd'
     Physics=PHYS_Falling
     Mesh=Mesh'c_dnWeapon.A_PistolClip'
     bMeshCurvy=False
     CollisionRadius=12.0
     CollisionHeight=5.0
     bCollideActors=True
	 Skin=texture'm_dnWeapon.blackclip1BC'
	 LodMode=LOD_Disabled
	 PickupIcon=texture'hud_effects.am_eaglenormal'

	 ItemName="Standard Clip"
}