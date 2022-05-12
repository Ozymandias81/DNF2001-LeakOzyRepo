//=============================================================================
// Vial.
//=============================================================================
class HealthVial extends TournamentHealth;

#exec MESH IMPORT MESH=Vial ANIVFILE=MODELS\Vial_a.3d DATAFILE=MODELS\Vial_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=Vial STRENGTH=0.6
#exec MESH ORIGIN MESH=Vial X=0 Y=0 Z=0
#exec MESH SEQUENCE MESH=Vial SEQ=All  STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Vial SEQ=VIAL STARTFRAME=0 NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JVial0 FILE=MODELS\vial.PCX GROUP=Skins LODSET=2
#exec OBJ LOAD FILE=Textures\ShaneFx.utx  PACKAGE=Botpack.ShaneFx
#exec MESHMAP NEW   MESHMAP=Vial MESH=Vial
#exec MESHMAP SCALE MESHMAP=Vial X=0.02 Y=0.02 Z=0.04

#exec MESHMAP SETTEXTURE MESHMAP=Vial NUM=0 TEXTURE=JVial0
#exec MESHMAP SETTEXTURE MESHMAP=Vial NUM=1 TEXTURE=Botpack.ShaneFx.bluestuff
#exec MESHMAP SETTEXTURE MESHMAP=Vial NUM=2 TEXTURE=Botpack.ShaneFx.Top

defaultproperties
{
	 PickupSound=sound'Botpack.Pickups.UTHealth'
	 bSuperHeal=true
	 HealingAmount=5
	 RespawnTime=30.000000
     CollisionRadius=+00014.000000
     CollisionHeight=+00016.000000
     PickupMessage="You picked up a Health Vial +"
     PickupViewMesh=Mesh'vial'
     PickupViewScale=1.000000
     Mesh=Mesh'vial'
     DrawScale=1.000000
     ScaleGlow=2.000000
	 ItemName="Health Vial"
}
