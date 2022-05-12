//=============================================================================
// FlakBox.
//=============================================================================
class FlakBox extends Ammo;

#exec TEXTURE IMPORT NAME=I_FlakAmmo FILE=TEXTURES\HUD\i_flak.PCX GROUP="Icons" MIPS=OFF

#exec MESH IMPORT MESH=flakboxMesh ANIVFILE=MODELS\flakb_a.3D DATAFILE=MODELS\flakb_d.3D X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=flakboxMesh STRENGTH=0.6 
#exec MESH ORIGIN MESH=flakboxMesh X=0 Y=0 Z=0 YAW=0 ROLL=128
#exec MESH SEQUENCE MESH=flakboxMesh SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JPickup1 FILE=MODELS\pickup.PCX GROUP="Skins"
#exec MESHMAP SCALE MESHMAP=flakboxMesh X=0.045 Y=0.045 Z=0.09
#exec MESHMAP SETTEXTURE MESHMAP=flakboxMesh NUM=1 TEXTURE=JPickup1

defaultproperties
{
     AmmoAmount=10
     MaxAmmo=50
     UsedInWeaponSlot(6)=1
     PickupMessage="You picked up 10 Flak Shells"
     PickupViewMesh=Mesh'UnrealI.flakboxMesh'
     MaxDesireability=0.320000
     PickupSound=Sound'UnrealShare.Pickups.AmmoSnd'
     Icon=Texture'UnrealI.Icons.I_FlakAmmo'
     Mesh=Mesh'UnrealI.flakboxMesh'
     bMeshCurvy=False
     CollisionRadius=16.000000
     CollisionHeight=11.000000
     bCollideActors=True
}
