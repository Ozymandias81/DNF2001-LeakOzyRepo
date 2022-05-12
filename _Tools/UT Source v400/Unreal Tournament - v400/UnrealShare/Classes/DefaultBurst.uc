//=============================================================================
// DefaultBurst.
//=============================================================================
class DefaultBurst extends AnimSpriteEffect;

#exec AUDIO IMPORT FILE="sounds\general\expl02.wav" NAME="Exple03" GROUP="General"

#exec TEXTURE IMPORT NAME=ExplosionPal FILE=textures\exppal.pcx GROUP=Effects
#exec OBJ LOAD FILE=textures\dtexpl.utx PACKAGE=UnrealShare.DEFBurst

function PostBeginPlay()
{
	PlaySound (EffectSound1,,4.0);
	Super.PostBeginPlay();
}

defaultproperties
{
     EffectSound1=Sound'UnrealShare.General.Exple03'
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=0.400000
     DrawType=DT_SpriteAnimOnce
     Style=STY_Translucent
     Texture=Texture'UnrealShare.DEFBurst.dt_a00'
     Skin=Texture'UnrealShare.Effects.ExplosionPal'
     DrawScale=1.500000
     LightType=LT_TexturePaletteOnce
     LightEffect=LE_NonIncidence
     LightRadius=6
     bCorona=False
}
