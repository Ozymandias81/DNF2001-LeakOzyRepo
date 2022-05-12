//=============================================================================
// RocketTrail.
//=============================================================================
class RocketTrail extends Effects;

#exec TEXTURE IMPORT NAME=JRFlare FILE=MODELS\flare9.PCX

defaultproperties
{
	 RemoteRole=ROLE_None
     Physics=PHYS_Trailer
     DrawType=DT_Sprite
     Style=STY_Translucent
     Sprite=Texture'Botpack.JRFlare'
     Texture=Texture'Botpack.JRFlare'
     Skin=Texture'Botpack.JRFlare'
     DrawScale=0.500000
	 bTrailerSameRotation=true
	 bUnlit=true
	 Mass=+8.0
}
