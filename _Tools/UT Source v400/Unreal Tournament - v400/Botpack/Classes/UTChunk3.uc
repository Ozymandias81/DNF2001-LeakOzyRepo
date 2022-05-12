//=============================================================================
// UTChunk3.
//=============================================================================
class UTChunk3 extends UTChunk;

#exec MESH IMPORT MESH=chunk3M ANIVFILE=MODELS\chunk2_a.3D DATAFILE=MODELS\chunk2_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=chunk3M X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=chunk3M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=chunk3M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=chunk3M X=0.03 Y=0.03 Z=0.06

defaultproperties
{
     Mesh=LodMesh'Botpack.chunk3M'
}
