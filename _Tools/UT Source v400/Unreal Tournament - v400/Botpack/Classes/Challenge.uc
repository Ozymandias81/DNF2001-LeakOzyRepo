//=============================================================================
// challenge.
//=============================================================================
class Challenge extends Trophy;

#exec MESH IMPORT MESH=challengeM ANIVFILE=MODELS\challenge_a.3D DATAFILE=MODELS\challenge_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=challengeM X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=challengeM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=challengeM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jchallenge FILE=MODELS\challenge.pcx GROUP=Skins 
#exec MESHMAP SCALE MESHMAP=challengeM X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=challengeM NUM=1 TEXTURE=jchallenge

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.challengeM'
     DrawScale=0.200000
}
