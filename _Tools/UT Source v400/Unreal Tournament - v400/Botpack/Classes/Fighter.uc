//=============================================================================
// fighter.
//=============================================================================
class Fighter extends UT_Decoration;


#exec MESH IMPORT MESH=fighterM ANIVFILE=MODELS\fighter_a.3D DATAFILE=MODELS\fighter_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=fighterM X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=fighterM SEQ=All    STARTFRAME=0   NUMFRAMES=40
#exec MESH SEQUENCE MESH=fighterM SEQ=Sway   STARTFRAME=0   NUMFRAMES=40
#exec TEXTURE IMPORT NAME=Jf2 FILE=MODELS\fighter.pcx GROUP=Skins   LODSET=2
#exec MESHMAP SCALE MESHMAP=fighterM X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=fighterM NUM=1 TEXTURE=Jf2

function beginPlay()
{
		loopanim('sway',0.4);
		animframe = FRand();		
}


defaultproperties
{
     bStatic=False
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.fighterM'
}
