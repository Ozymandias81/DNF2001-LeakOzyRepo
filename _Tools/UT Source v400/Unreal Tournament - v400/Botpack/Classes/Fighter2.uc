//=============================================================================
// fighter2.
//=============================================================================
class Fighter2 extends UT_Decoration;


#exec MESH IMPORT MESH=fighter2M ANIVFILE=MODELS\fighter2_a.3D DATAFILE=MODELS\fighter2_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=fighter2M X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=fighter2M SEQ=All    STARTFRAME=0   NUMFRAMES=80
#exec MESH SEQUENCE MESH=fighter2M SEQ=Sway  STARTFRAME=0   NUMFRAMES=80
#exec TEXTURE IMPORT NAME=Jff2 FILE=MODELS\fighter2.pcx GROUP=Skins   LODSET=2
#exec MESHMAP SCALE MESHMAP=fighter2M X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=fighter2M NUM=1 TEXTURE=Jff2

function beginPlay()
{
		loopanim('sway',0.4);
		animframe = FRand();		
}



defaultproperties
{
     bStatic=False
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.fighter2M'
}
