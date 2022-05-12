//=============================================================================
// ut_SuperRing.
//=============================================================================
class UT_SuperRing extends UT_RingExplosion;

#exec MESH IMPORT MESH=UTsRingex ANIVFILE=..\botpack\MODELS\Ring_a.3D DATAFILE=..\botpack\MODELS\Ring_d.3D ZEROTEX=1 LODSTYLE=8
#exec MESH ORIGIN MESH=UTsRingex X=0 Y=0 Z=0 YAW=0 PITCH=64
#exec MESH SEQUENCE MESH=UTsRingex SEQ=All   STARTFRAME=0   NUMFRAMES=9
#exec MESH SEQUENCE MESH=UTsRingex SEQ=Explo STARTFRAME=0   NUMFRAMES=9
#exec TEXTURE IMPORT NAME=ASasRing FILE=..\botpack\models\ring5.pcx GROUP=Effects
#exec MESHMAP SCALE MESHMAP=UTsRingex X=0.4 Y=0.4 Z=0.8 YAW=128
#exec MESHMAP SETTEXTURE MESHMAP=UTsRingex  NUM=0 TEXTURE=ASasRing

simulated function SpawnEffects()
{
}

defaultproperties
{
     Mesh=Mesh'Botpack.UTsRingex'
}
