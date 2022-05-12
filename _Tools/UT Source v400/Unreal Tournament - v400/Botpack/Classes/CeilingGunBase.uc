//=============================================================================
// ceilinggunbase.
//=============================================================================
class CeilingGunBase extends UT_Decoration;

#exec MESH IMPORT MESH=cdbaseM ANIVFILE=MODELS\cdbase_a.3D DATAFILE=MODELS\cdbase_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=cdbaseM X=0 Y=150 Z=0 PITCH=0 YAW=-64 ROLL=-64
#exec MESH SEQUENCE MESH=cdbaseM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=cdbaseM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jcdbase FILE=MODELS\cdgunbase.pcx GROUP=Skins 
#exec MESHMAP SCALE MESHMAP=cdbaseM X=0.08 Y=0.08 Z=0.16
#exec MESHMAP SETTEXTURE MESHMAP=cdbaseM NUM=1 TEXTURE=jcdbase

defaultproperties
{
	 RemoteRole=ROLE_None
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.cdbaseM'
	 bStatic=false
}
