class ShockExplo extends AnimSpriteEffect;


#exec TEXTURE IMPORT NAME=ExplosionBluePal FILE=textures\expblue.pcx GROUP=Effects
#exec OBJ LOAD FILE=textures\ShockExplo.utx PACKAGE=Botpack.ShockExplo

function MakeSound()
{
	PlaySound(EffectSound1,,12.0,,2000);
}

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_Client )
		MakeSound();
	Super.PostBeginPlay();		
}

simulated function Timer()
{
}

defaultproperties
{
	 RemoteRole=ROLE_None
     NumFrames=15
     Pause=0.050000
     EffectSound1=Sound'UnrealShare.General.Expl03'
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=0.700000
     DrawType=DT_SpriteAnimOnce
     Style=STY_Translucent
     Texture=Texture'Botpack.ShockExplo.asmdex_a00'
     Skin=Texture'Botpack.Effects.ExplosionBluePal'
     DrawScale=1.000000
     bMeshCurvy=False
     LightType=LT_TexturePaletteOnce
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=27
     LightSaturation=71
     LightRadius=6
     bCorona=False
}
