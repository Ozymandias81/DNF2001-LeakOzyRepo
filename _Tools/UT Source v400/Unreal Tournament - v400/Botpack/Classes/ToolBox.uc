//=============================================================================
// toolbox.
//=============================================================================
class ToolBox extends ut_Decoration;

#exec MESH IMPORT MESH=toolboxM ANIVFILE=MODELS\toolbox_a.3D DATAFILE=MODELS\toolbox_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=toolboxM X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=toolboxM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=toolboxM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jtoolbox FILE=MODELS\toolbox.pcx GROUP=Skins  LODSET=2
#exec MESHMAP SCALE MESHMAP=toolboxM X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=toolboxM NUM=1 TEXTURE=jtoolbox

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.toolboxM'
     DrawScale=0.250000
     CollisionHeight=30.000000
     bBlockActors=True
     bBlockPlayers=True
}
