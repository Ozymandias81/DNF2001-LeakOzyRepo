//=============================================================================
// WarExplosion.
//=============================================================================
class WarExplosion extends AnimSpriteEffect;

#exec OBJ LOAD FILE=textures\WarExplo.utx PACKAGE=BotPack.WarExplosionS
#exec AUDIO IMPORT FILE="sounds\Warhead\warheadEXPLO.wav" NAME="WarExplo" GROUP="Redeemer"

simulated function PostBeginPlay()
{
	local actor a;

	Super.PostBeginPlay();
	if ( !Level.bHighDetailMode ) 
		Drawscale = 1.9;
	PlaySound (EffectSound1,,12.0,,3000);	
    Texture = Default.Texture;
}

defaultproperties
{
     NumFrames=18
     Pause=0.050000
     RemoteRole=ROLE_SimulatedProxy
	 bNetTemporary=true
     LifeSpan=1.000000
     DrawType=DT_SpriteAnimOnce
     Style=STY_Translucent
     Texture=Texture'BotPack.WarExplosionS.we_a00'
     DrawScale=2.800000
     LightEffect=LE_NonIncidence
     LightRadius=12
     bCorona=False
	 EffectSound1=sound'BotPack.WarExplo'
}
