//=============================================================================
// EnergyBurst.
//=============================================================================
class EnergyBurst extends AnimSpriteEffect;

#exec AUDIO IMPORT FILE="sounds\flak\expl2.wav" NAME="Explo1" GROUP="General"

#exec TEXTURE IMPORT NAME=ExplosionPal3 FILE=textures\expal2.pcx GROUP=Effects

#exec OBJ LOAD FILE=textures\maine.utx PACKAGE=UnrealShare.Maineffect

defaultproperties
{
     NumFrames=6
     Pause=+00000.060000
     EffectSound1=UnrealShare.Explo1
     DrawType=DT_SpriteAnimOnce
     Style=STY_Translucent
     Texture=UnrealShare.MainEffect.E6_A00
     Skin=UnrealShare.ExplosionPal3
     DrawScale=+00001.500000
     bMeshCurvy=False
     LightType=LT_TexturePaletteOnce
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=0
     LightSaturation=255
     LightRadius=8
     bCorona=False
     LifeSpan=+00000.500000
     RemoteRole=ROLE_SimulatedProxy
}
