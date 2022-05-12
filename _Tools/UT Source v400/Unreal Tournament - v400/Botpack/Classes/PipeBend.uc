//=============================================================================
// pipebend.
//=============================================================================
class PipeBend extends UT_Decoration;

#exec MESH IMPORT MESH=pipebendM ANIVFILE=MODELS\pipebend_a.3D DATAFILE=MODELS\pipebend_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=pipebendM X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=pipebendM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=pipebendM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jpipebend FILE=MODELS\pipebend.pcx GROUP=Skins  LODSET=2
#exec MESHMAP SCALE MESHMAP=pipebendM X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=pipebendM NUM=1 TEXTURE=jpipebend

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.pipebendM'
     DrawScale=0.500000
}
