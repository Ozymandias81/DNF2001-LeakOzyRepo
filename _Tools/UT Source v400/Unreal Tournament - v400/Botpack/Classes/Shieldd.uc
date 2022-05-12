//=============================================================================
// shieldd.
//=============================================================================
class Shieldd extends Decoration;


#exec MESH IMPORT MESH=shieldM ANIVFILE=MODELS\shield_a.3D DATAFILE=MODELS\shield_d.3D X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=shieldM STRENGTH=0.2
#exec MESH ORIGIN MESH=shieldM X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=shieldM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=shieldM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Js2 FILE=MODELS\shield.pcx GROUP=Skins  LODSET=2
#exec MESHMAP SCALE MESHMAP=shieldM X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=shieldM NUM=1 TEXTURE=Js2 TLOD=30

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=shieldM
     bMeshCurvy=False
}
