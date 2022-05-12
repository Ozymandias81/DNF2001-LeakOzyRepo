//=============================================================================
// Stukka
//=============================================================================
class Stukka expands Decoration;

#exec MESH IMPORT MESH=stukkam ANIVFILE=MODELS\stukka_a.3D DATAFILE=MODELS\stukka_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=stukkam X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=-64
#exec MESH SEQUENCE MESH=stukkam SEQ=All  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jstukka1 FILE=MODELS\stukka.PCX
#exec MESHMAP SCALE MESHMAP=stukkam X=0.03 Y=0.03 Z=0.06 
#exec MESHMAP SETTEXTURE MESHMAP=stukkam NUM=1 TEXTURE=Jstukka1

var bool bDiveBomber;


defaultproperties
{
     LifeSpan=0.000000
     Mesh=Mesh'Botpack.stukkam'
     AmbientGlow=10
     SoundRadius=9
     SoundVolume=255
	 CollisionRadius=0
	 CollisionHeight=0
	 bCollideWorld=false
	 bBlockActors=false
}
