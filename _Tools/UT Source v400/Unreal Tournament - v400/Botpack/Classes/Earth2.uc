//=============================================================================
// earth2.
//=============================================================================
class Earth2 extends UT_Decoration;


#exec MESH IMPORT MESH=earth21 ANIVFILE=MODELS\earth_a.3D DATAFILE=MODELS\earth_d.3D X=0 Y=0 Z=0 ZEROTEX=1
#exec MESH ORIGIN MESH=earth21 X=0 Y=0 Z=0 YAW=0 ROLL=7
#exec MESH SEQUENCE MESH=earth21 SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=earth21 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jearth21 FILE=MODELS\earth2.pcx GROUP=Skins   LODSET=2
#exec MESHMAP SCALE MESHMAP=earth21 X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=earth21 NUM=0 TEXTURE=Jearth21

defaultproperties
{
     bStatic=False
     Physics=PHYS_Rotating
     DrawType=DT_Mesh
     Style=STY_Translucent
     Skin=Texture'Botpack.Skins.Jearth21'
     Mesh=LodMesh'Botpack.earth21'
     DrawScale=2.050000
     ScaleGlow=0.700000
     bFixedRotationDir=True
     RotationRate=(Yaw=800)
     DesiredRotation=(Yaw=500)
}
