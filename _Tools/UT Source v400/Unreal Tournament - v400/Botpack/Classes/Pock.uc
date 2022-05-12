//=============================================================================
// pock.
//=============================================================================
class Pock expands Scorch;

#exec TEXTURE IMPORT NAME=pock0_t FILE=TEXTURES\DECALS\pock0_t.PCX LODSET=2
#exec TEXTURE IMPORT NAME=pock2_t FILE=TEXTURES\DECALS\pock2_t.PCX LODSET=2
#exec TEXTURE IMPORT NAME=pock4_t FILE=TEXTURES\DECALS\pock4_t.PCX LODSET=2

var() texture PockTex[3];

simulated function BeginPlay()
{
	if ( Level.bDropDetail )
		Texture = PockTex[0];
	else
		Texture = PockTex[Rand(3)];
	bAttached = AttachDecal(100, vect(0,0,1));
}

defaultproperties
{
	 bImportant=false
	 MultiDecalLevel=0
     PockTex(0)=Texture'Botpack.pock0_t'
     PockTex(1)=Texture'Botpack.pock2_t'
     PockTex(2)=Texture'Botpack.pock4_t'
     bHighDetail=True
     DrawScale=0.190000
}
