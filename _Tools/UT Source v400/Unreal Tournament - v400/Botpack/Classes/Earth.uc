//=============================================================================
// earth.
//=============================================================================
class Earth extends UT_Decoration;


#exec MESH IMPORT MESH=earth1 ANIVFILE=MODELS\earth_a.3D DATAFILE=MODELS\earth_d.3D X=0 Y=0 Z=0 ZEROTEX=1
#exec MESH ORIGIN MESH=earth1 X=0 Y=0 Z=0 YAW=0 ROLL=7
#exec MESH SEQUENCE MESH=earth1 SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=earth1 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jearth1 FILE=MODELS\earth.pcx GROUP=Skins   LODSET=2
#exec MESHMAP SCALE MESHMAP=earth1 X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=earth1 NUM=0 TEXTURE=Jearth1

defaultproperties
{
     bStatic=False
     Physics=PHYS_Rotating
     DrawType=DT_Mesh
     Skin=Texture'Botpack.Skins.Jearth1'
     Mesh=LodMesh'Botpack.earth1'
     DrawScale=2.000000
     bFixedRotationDir=True
     RotationRate=(Yaw=1500)
     DesiredRotation=(Yaw=500)
}
