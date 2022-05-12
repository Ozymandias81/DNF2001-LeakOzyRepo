//=============================================================================
// pot.
//=============================================================================
class Pot extends UT_Decoration;

#exec MESH IMPORT MESH=potM ANIVFILE=MODELS\pot_a.3D DATAFILE=MODELS\pot_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=potM X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=potM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=potM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jpot FILE=MODELS\pot.pcx GROUP=Skins 
#exec MESHMAP SCALE MESHMAP=potM X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=potM NUM=1 TEXTURE=jpot

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.potM'
     DrawScale=0.200000
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
}
