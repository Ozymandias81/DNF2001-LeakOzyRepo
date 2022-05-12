//=============================================================================
// UTChunk1.
//=============================================================================
class UTChunk1 extends UTChunk;

#exec MESH IMPORT MESH=chunkM ANIVFILE=MODELS\chunk5_a.3D DATAFILE=MODELS\chunk5_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=chunkM X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=chunkM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=chunkM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=chunkM X=0.03 Y=0.03 Z=0.06

defaultproperties
{
     Mesh=LodMesh'Botpack.chunkM'
}
