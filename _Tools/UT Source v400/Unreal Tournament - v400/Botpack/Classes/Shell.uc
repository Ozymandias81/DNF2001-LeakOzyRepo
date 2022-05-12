//=============================================================================
// shell.
//=============================================================================
class Shell extends UT_Decoration;

#exec MESH IMPORT MESH=shellM ANIVFILE=MODELS\shell_a.3D DATAFILE=MODELS\shell_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=shellM X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=shellM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=shellM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jshell FILE=MODELS\shell.pcx GROUP=Skins  LODSET=2
#exec MESHMAP SCALE MESHMAP=shellM X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=shellM NUM=1 TEXTURE=jshell

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.shellM'
     DrawScale=0.300000
     CollisionRadius=10.000000
     CollisionHeight=36.000000
     bCollideActors=True
}
