//=============================================================================
// FlameExplosion.
//=============================================================================
class FlameExplosion extends AnimSpriteEffect;

#exec TEXTURE IMPORT NAME=ExplosionPal2 FILE=textures\exppal.pcx GROUP=Effects
#exec OBJ LOAD FILE=textures\FlameEffect.utx PACKAGE=UnrealShare.FlameEffect

#exec AUDIO IMPORT FILE="sounds\general\expl04.wav" NAME="Expl04" GROUP="General"

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
		if (!Level.bHighDetailMode) Drawscale = 1.4;
		else 
		{	
			a = Spawn(class'ShortSmokeGen');
			a.RemoteRole = ROLE_None;	
		}
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
     Texture=Texture'UnrealShare.FlameEffect.e_a01'
     Skin=Texture'UnrealShare.Effects.ExplosionPal2'
     DrawScale=2.800000
     bMeshCurvy=False
     LightType=LT_TexturePaletteOnce
     LightEffect=LE_NonIncidence
     LightBrightness=159
     LightHue=32
     LightSaturation=79
     LightRadius=8
     bCorona=False
}
