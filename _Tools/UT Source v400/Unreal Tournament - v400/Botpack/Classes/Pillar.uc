//=============================================================================
// pillar.
//=============================================================================
class Pillar extends UT_Decoration;

#exec MESH IMPORT MESH=pillarM ANIVFILE=MODELS\pillar_a.3D DATAFILE=MODELS\pillar_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=pillarM X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=pillarM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=pillarM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jpillar FILE=MODELS\pillar.pcx GROUP=Skins  LODSET=2
#exec MESHMAP SCALE MESHMAP=pillarM X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=pillarM NUM=1 TEXTURE=jpillar

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.pillarM'
     DrawScale=0.500000
     bBlockActors=True
     bBlockPlayers=True
	 CollisionHeight=+60.0
	 CollisionRadius=+12.0
}
