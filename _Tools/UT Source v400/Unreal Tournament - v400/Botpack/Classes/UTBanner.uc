//=============================================================================
// utbanner.
//=============================================================================
class UTBanner extends UT_Decoration;

#exec MESH IMPORT MESH=utbannerM ANIVFILE=MODELS\banner_a.3D DATAFILE=MODELS\banner_d.3D X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=utbannerM STRENGTH=0.5 
#exec MESH ORIGIN MESH=utbannerM X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=utbannerM SEQ=All    STARTFRAME=0   NUMFRAMES=200
#exec MESH SEQUENCE MESH=utbannerM SEQ=Sway  STARTFRAME=30   NUMFRAMES=169
#exec TEXTURE IMPORT NAME=jutbanner FILE=MODELS\banner.pcx GROUP=Skins 
#exec MESHMAP SCALE MESHMAP=utbannerM X=0.3 Y=0.15 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=utbannerM NUM=1 TEXTURE=jutbanner

function beginPlay()
{
		loopanim('sway',0.2);
		animframe = FRand();		
}

defaultproperties
{
     bStatic=False
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.utbannerM'
     DrawScale=0.500000
}
