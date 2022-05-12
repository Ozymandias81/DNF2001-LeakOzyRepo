//=============================================================================
// Moon.
//=============================================================================
class Moon extends Decoration;


#exec MESH IMPORT MESH=Moon1 ANIVFILE=MODELS\moon_a.3D DATAFILE=MODELS\moon_d.3D ZEROTEX=1 MLOD=0
#exec MESH ORIGIN MESH=Moon1 X=0 Y=0 Z=0 YAW=0 ROLL=7
#exec MESH SEQUENCE MESH=Moon1 SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=Moon1 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JMoon1 FILE=MODELS\moon.pcx GROUP=Skins TLOD=100 
#exec MESHMAP SCALE MESHMAP=Moon1 X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=Moon1 NUM=0 TEXTURE=JMoon1

defaultproperties
{
     bStatic=False
     DrawType=DT_Mesh
     Skin=UnrealI.JMoon1
     Mesh=UnrealI.Moon1
     DrawScale=+00002.000000
     Physics=PHYS_Rotating
     bFixedRotationDir=True
     RotationRate=(Yaw=500)
     DesiredRotation=(Yaw=500)
}
