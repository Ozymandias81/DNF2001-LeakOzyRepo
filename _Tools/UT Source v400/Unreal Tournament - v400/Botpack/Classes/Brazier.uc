//=============================================================================
// brazier.
//=============================================================================
class Brazier extends ut_Decoration;

#exec MESH IMPORT MESH=brazierM ANIVFILE=MODELS\brazier_a.3D DATAFILE=MODELS\brazier_d.3D X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=brazierM STRENGTH=0.5 
#exec MESH ORIGIN MESH=brazierM X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=brazierM SEQ=All    STARTFRAME=0   NUMFRAMES=40
#exec MESH SEQUENCE MESH=brazierM SEQ=Sway  STARTFRAME=1   NUMFRAMES=39
#exec TEXTURE IMPORT NAME=jbrazier FILE=MODELS\brazier.pcx GROUP=Skins   LODSET=2
#exec MESHMAP SCALE MESHMAP=brazierM X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=brazierM NUM=1 TEXTURE=jbrazier

function beginPlay()
{

		loopanim('sway',0.2);
}

defaultproperties
{
     bStatic=False
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.brazierM'
     DrawScale=0.500000
     bBlockActors=True
     bBlockPlayers=True
	 CollisionHeight=+60.0
	 CollisionRadius=+12.0
}
