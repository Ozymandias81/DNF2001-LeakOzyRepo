class HealthPack extends TournamentHealth;

#exec MESH IMPORT MESH=hbox ANIVFILE=MODELS\Superhealth_a.3d DATAFILE=MODELS\Superhealth_d.3d LODSTYLE=10
#exec MESH LODPARAMS MESH=hbox STRENGTH=0.5
#exec MESH ORIGIN MESH=hbox X=0 Y=0 Z=0 PITCH=0 ROLL=-64
#exec MESH SEQUENCE MESH=hbox SEQ=All  STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=hbox SEQ=HBOX STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Jhbox1 FILE=MODELS\Superhealth.PCX GROUP=Skins LODSET=2
#exec MESHMAP NEW   MESHMAP=hbox MESH=hbox
#exec MESHMAP SCALE MESHMAP=hbox X=0.08 Y=0.08 Z=0.16
#exec OBJ LOAD FILE=Textures\ShaneFx.utx  PACKAGE=Botpack.ShaneFx
#exec MESHMAP SETTEXTURE MESHMAP=hbox NUM=1 TEXTURE=Jhbox1
#exec MESHMAP SETTEXTURE MESHMAP=hbox NUM=2 TEXTURE=Botpack.ShaneFx.top3

#exec AUDIO IMPORT FILE="Sounds\Pickups\healthSuper.WAV" NAME="UTSuperHeal" GROUP="Pickups"

defaultproperties
{
     HealingAmount=100
     bSuperHeal=True
     PickupMessage="You picked up the Big Keg O' Health +"
     ItemName="Super Health Pack"
     RespawnTime=100.000000
     PickupViewMesh=LodMesh'Botpack.hbox'
     MaxDesireability=2.000000
     PickupSound=Sound'Botpack.Pickups.UTSuperHeal'
     Mesh=LodMesh'Botpack.hbox'
     DrawScale=0.800000
     CollisionRadius=26.000000
     CollisionHeight=19.500000
}
