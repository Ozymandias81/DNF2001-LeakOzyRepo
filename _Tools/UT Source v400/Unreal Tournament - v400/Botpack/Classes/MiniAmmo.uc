//=============================================================================
// Miniammo.
//=============================================================================
class MiniAmmo extends TournamentAmmo;

#exec MESH IMPORT MESH=MiniAmmom ANIVFILE=MODELS\Miniammo_a.3D DATAFILE=MODELS\Miniammo_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=MiniAmmom X=-50 Y=-40 Z=0 YAW=0
#exec MESH SEQUENCE MESH=MiniAmmom SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JM21 FILE=MODELS\miniammo.PCX GROUP="Skins"  LODSET=2
#exec MESHMAP SCALE MESHMAP=MiniAmmom X=0.06 Y=0.06 Z=0.12
#exec MESHMAP SETTEXTURE MESHMAP=MiniAmmom NUM=1 TEXTURE=JM21

defaultproperties
{
     AmmoAmount=50
     MaxAmmo=199
     UsedInWeaponSlot(0)=1
     UsedInWeaponSlot(2)=1
     PickupMessage="You picked up 50 bullets."
     PickupViewMesh=Mesh'Botpack.MiniAmmom'
     Mesh=Mesh'Botpack.MiniAmmom'
     bMeshCurvy=False
     CollisionRadius=22.000000
     CollisionHeight=11.000000
     bCollideActors=True
	 ItemName="Large Bullets"
}
