//=============================================================================
// deathmatchtrophy.
//=============================================================================
class DeathMatchTrophy extends Trophy;

#exec MESH IMPORT MESH=deathmatchtrophyM ANIVFILE=MODELS\deathmatchtrophy_a.3D DATAFILE=MODELS\deathmatchtrophy_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=deathmatchtrophyM X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=deathmatchtrophyM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=deathmatchtrophyM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jdeathmatchtrophy FILE=MODELS\deathmatchtrophy.pcx GROUP=Skins   LODSET=2
#exec MESHMAP SCALE MESHMAP=deathmatchtrophyM X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=deathmatchtrophyM NUM=1 TEXTURE=jdeathmatchtrophy

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.deathmatchtrophyM'
     DrawScale=0.200000
}
