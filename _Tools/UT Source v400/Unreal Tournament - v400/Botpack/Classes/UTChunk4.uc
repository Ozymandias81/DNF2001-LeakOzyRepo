//=============================================================================
// UTChunk4.
//=============================================================================
class UTChunk4 extends UTChunk;

#exec MESH IMPORT MESH=chunk4M ANIVFILE=MODELS\chunk4_a.3D DATAFILE=MODELS\chunk4_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=chunk4M X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=chunk4M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=chunk4M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=chunk4M X=0.03 Y=0.03 Z=0.06

defaultproperties
{
     LifeSpan=3.000000
     Mesh=LodMesh'Botpack.chunk4M'
}
