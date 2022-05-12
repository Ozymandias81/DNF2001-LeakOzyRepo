//=============================================================================
// Tree11.
//=============================================================================
class Tree11 extends Tree;


#exec MESH IMPORT MESH=Tree11M ANIVFILE=MODELS\Tree17_a.3D DATAFILE=MODELS\Tree17_d.3D LODSTYLE=2
//#exec MESH LODPARAMS MESH=Tree11M STRENGTH=0.5 
#exec MESH ORIGIN MESH=Tree11M X=0 Y=220 Z=0 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=Tree11M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=Tree11M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JTree111 FILE=MODELS\Tree17.PCX GROUP=Skins FLAGS=2
#exec MESHMAP SCALE MESHMAP=Tree11M X=0.2 Y=0.2 Z=0.4
#exec MESHMAP SETTEXTURE MESHMAP=Tree11M NUM=1 TEXTURE=JTree111

defaultproperties
{
     Mesh=UnrealShare.Tree11M
     CollisionRadius=+00022.000000
     CollisionHeight=+00045.000000
}
