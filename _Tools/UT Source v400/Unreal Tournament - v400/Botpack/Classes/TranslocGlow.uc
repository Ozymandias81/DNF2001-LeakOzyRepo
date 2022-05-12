//=============================================================================
// TranslocGlow.
//=============================================================================
class TranslocGlow extends Effects;

#exec TEXTURE IMPORT NAME=Tranglow FILE=TEXTURES\Tranglow.PCX GROUP="Translocator"
#exec TEXTURE IMPORT NAME=Tranglowg FILE=TEXTURES\Tranglowg.PCX GROUP="Translocator"
#exec TEXTURE IMPORT NAME=Tranglowb FILE=TEXTURES\Tranglowb.PCX GROUP="Translocator"
#exec TEXTURE IMPORT NAME=Tranglowy FILE=TEXTURES\Tranglowy.PCX GROUP="Translocator"

defaultproperties
{
	 bTrailerPrePivot=true
	 RemoteRole=ROLE_SimulatedProxy
	 bNetTemporary=false
     Physics=PHYS_Trailer
     DrawType=DT_Sprite
     Style=STY_Translucent
     Sprite=texture'Botpack.Tranglow'
     Texture=texture'Botpack.Tranglow'
     Skin=texture'Botpack.Tranglow'
     DrawScale=0.50000
     PrePivot=(X=0.000000,Y=0.000000,Z=20.000000)
}
