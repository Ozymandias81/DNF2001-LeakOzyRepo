//=============================================================================
// boulder2.
//=============================================================================
class Boulder2 extends ut_Decoration;

#exec MESH IMPORT MESH=boulder2M ANIVFILE=MODELS\boulder2_a.3D DATAFILE=MODELS\boulder2_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=boulder2M X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=boulder2M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=boulder2M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jboulder2 FILE=MODELS\boulder2.pcx GROUP=Skins   LODSET=2
#exec MESHMAP SCALE MESHMAP=boulder2M X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=boulder2M NUM=1 TEXTURE=jboulder2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.boulder2M'
     DrawScale=0.250000
     bBlockActors=True
     bBlockPlayers=True
}
