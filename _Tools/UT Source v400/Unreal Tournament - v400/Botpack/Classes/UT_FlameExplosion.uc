//=============================================================================
// UT_FlameExplosion.
//=============================================================================
class UT_FlameExplosion expands AnimSpriteEffect;

#exec OBJ LOAD FILE=textures\UT_Explosion.utx PACKAGE=Botpack.UT_Explosions
#exec TEXTURE IMPORT NAME=ExplosionPal2 FILE=..\UnrealShare\textures\exppal.pcx GROUP=Effects
#exec AUDIO IMPORT FILE="..\UnrealShare\sounds\general\expl04.wav" NAME="Expl04" GROUP="General"

function MakeSound()
{
	PlaySound (EffectSound1,,3.0);	
}

simulated function PostBeginPlay()
{
	local actor a;

	Super.PostBeginPlay();
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if (!Level.bHighDetailMode) 
			Drawscale = 1.4;
		else 
			Spawn(class'UT_ShortSmokeGen');
	}
	MakeSound();
}

defaultproperties
{
     NumFrames=8
     Pause=0.050000
     EffectSound1=Sound'UnrealShare.General.Expl04'
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=0.500000
     DrawType=DT_SpriteAnimOnce
     Style=STY_Translucent
     Skin=Texture'UnrealShare.Effects.ExplosionPal2'
     bMeshCurvy=False
     LightType=LT_TexturePaletteOnce
     LightEffect=LE_NonIncidence
     LightBrightness=159
     LightHue=32
     LightSaturation=79
     LightRadius=8
     bCorona=False
     Texture=Texture'Botpack.UT_Explosions.Exp2_a00'
     DrawScale=2.000000
}
