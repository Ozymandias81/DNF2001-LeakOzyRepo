//=============================================================================
// Lightcone.
//=============================================================================
class LightCone expands Decoration;


#exec MESH IMPORT MESH=lightcone1 ANIVFILE=MODELS\lightcone_a.3D DATAFILE=MODELS\lightcone_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=lightcone1 X=0 Y=0 Z=0 ROLL=-64 
#exec MESH SEQUENCE MESH=lightcone1 SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jlightcone11 FILE=MODELS\lightcone.PCX GROUP="Skins"
#exec MESHMAP SCALE MESHMAP=lightcone1 X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=lightcone1 NUM=1 TEXTURE=Jlightcone11

defaultproperties
{
     DrawType=DT_Mesh
     Style=STY_Modulated
     Mesh=Mesh'Botpack.lightcone1'
     ScaleGlow=0.300000
     bUnlit=True
}
