//=============================================================================
// UTchunk2.
//=============================================================================
class UTchunk2 extends UTchunk;

#exec MESH IMPORT MESH=chunk2M ANIVFILE=MODELS\chunk2_a.3D DATAFILE=MODELS\chunk2_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=chunk2M X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=chunk2M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=chunk2M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=chunk2M X=0.03 Y=0.03 Z=0.06

defaultproperties
{
     LifeSpan=3.100000
     Mesh=LodMesh'Botpack.chunk2M'
}
