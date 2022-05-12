//=============================================================================
// BulletBox.
//=============================================================================
class BulletBox extends TournamentAmmo;

#exec MESH IMPORT MESH=BulletBoxM ANIVFILE=MODELS\rifleammo_a.3D DATAFILE=MODELS\rifleammo_d.3D LODSTYLE=10
#exec MESH ORIGIN MESH=BulletBoxM X=0 Y=-200 Z=0 YAW=0
#exec MESH SEQUENCE MESH=BulletBoxM SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=BulletBoxT FILE=MODELS\rifleammo.PCX GROUP="Skins"  LODSET=2
#exec MESHMAP SCALE MESHMAP=BulletBoxM X=0.035 Y=0.035 Z=0.07
#exec MESHMAP SETTEXTURE MESHMAP=BulletBoxM NUM=0 TEXTURE=BulletBoxT

defaultproperties
{
	 Physics=PHYS_Falling
     AmmoAmount=10
     MaxAmmo=50
     UsedInWeaponSlot(9)=1
     PickupMessage="You got a box of rifle rounds."
	 ItemName="Box of Rifle Rounds"
     PickupViewMesh=Mesh'Botpack.BulletBoxM'
     MaxDesireability=0.240000
     Icon=Texture'UnrealI.Icons.I_RIFLEAmmo'
     Mesh=Mesh'Botpack.BulletBoxM'
     bMeshCurvy=False
     CollisionRadius=15.000000
     CollisionHeight=10.000000
     bCollideActors=True
	 Skin=Texture'Botpack.BulletBoxT'
	 DrawScale=1.0
}
