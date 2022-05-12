//=============================================================================
// FlakAmmo.
//=============================================================================
class FlakAmmo extends TournamentAmmo;

#exec MESH IMPORT MESH=FlakAmmoM ANIVFILE=MODELS\flakammo_a.3D DATAFILE=MODELS\flakammo_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=FlakAmmoM X=0 Y=0 Z=0 YAW=0 ROLL=0
#exec MESH SEQUENCE MESH=FlakAmmoM SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JFA1 FILE=MODELS\FlakAmmo.PCX GROUP="Skins"  LODSET=2
#exec MESHMAP SCALE MESHMAP=FlakAmmoM X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=FlakAmmoM NUM=1 TEXTURE=JFA1

defaultproperties
{
     AmmoAmount=10
     MaxAmmo=50
     UsedInWeaponSlot(6)=1
     PickupMessage="You picked up 10 Flak Shells."
     PickupViewMesh=Mesh'Botpack.FlakAmmoM'
     MaxDesireability=0.320000
     Mesh=Mesh'Botpack.FlakAmmoM'
     bMeshCurvy=False
     CollisionRadius=16.000000
     CollisionHeight=11.000000
     bCollideActors=True
	 ItemName="Flak Shells"
}
