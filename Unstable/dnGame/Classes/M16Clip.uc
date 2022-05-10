/*-----------------------------------------------------------------------------
	M16Clip
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class M16Clip expands Ammo;

#exec AUDIO IMPORT FILE="Sounds\Pickups\AMMOPUP1.WAV" NAME="AmmoSnd" GROUP="Pickups"
#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx

defaultproperties
{
     ModeAmount(0)=30
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
	 ItemName="M-16 Clip"
}