//=============================================================================
// U.
//=============================================================================
class U extends Decoration;

#exec MESH IMPORT MESH=U ANIVFILE=MODELS\U_a.3d DATAFILE=MODELS\U_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=U X=0 Y=0 Z=0
#exec MESH SEQUENCE MESH=U SEQ=All                      STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=U SEQ=sit                      STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP NEW   MESHMAP=U MESH=U
#exec MESHMAP SCALE MESHMAP=U X=0.1 Y=0.1 Z=0.2

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=U
	Skin=texture'GoldSkin2'
	Texture=texture'GoldSkin2'
	bMeshEnviroMap=True
	bNoDelete=False
	bStatic=False
}

