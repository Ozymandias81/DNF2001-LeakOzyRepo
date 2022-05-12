//=============================================================================
// UT_SpriteBallExplosion.
//=============================================================================
class UT_SpriteBallExplosion extends AnimSpriteEffect;

#exec TEXTURE IMPORT NAME=ExplosionPal FILE=..\unrealshare\textures\exppal.pcx GROUP=Effects
#exec OBJ LOAD FILE=textures\UT_Explosion.utx PACKAGE=Botpack.UT_Explosions

var int ExpCount, MissCount;

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_Client )
		MakeSound();
	if ( !Level.bDropDetail )
		Texture = SpriteAnim[Rand(3)];	
	if ( (Level.NetMode!=NM_DedicatedServer) && Level.bHighDetailMode && !Level.bDropDetail ) 
		SetTimer(0.05+FRand()*0.04,False);
	else
		LightRadius = 6;
	Super.PostBeginPlay();		
}

simulated Function Timer()
{
	if ( Level.bDropDetail )
		return;
	if ( FRand() < 0.4 + (MissCount - 1.5 * ExpCount) * 0.25 )
	{
		ExpCount++;
		Spawn(class'UT_SpriteBallChild',Self, '', Location + (20 + 20 * FRand()) * (VRand() + Vect(0,0,0.5)) );
	}
	else
		MissCount++;
	if ( (ExpCount < 3) && (LifeSpan > 0.45) ) 
		SetTimer(0.05+FRand()*0.05,False);
	
}

function MakeSound()
{
	PlaySound(EffectSound1,,12.0,,2200);
}

defaultproperties
{
     NumFrames=8
     Pause=0.050000
     EffectSound1=Sound'UnrealShare.Explo1'
     DrawType=DT_SpriteAnimOnce
     Style=STY_Translucent
     Skin=Texture'UnrealShare.ExplosionPal'
     bMeshCurvy=False
     LightType=LT_TexturePaletteOnce
     LightEffect=LE_NonIncidence
     LightBrightness=192
     LightHue=27
     LightSaturation=71
     LightRadius=9
     bCorona=False
     LifeSpan=0.700000
     RemoteRole=ROLE_SimulatedProxy
     SpriteAnim(0)=Texture'Botpack.UT_Explosions.exp1_a00'
     SpriteAnim(1)=Texture'Botpack.UT_Explosions.Exp6_a00'
     SpriteAnim(2)=Texture'Botpack.UT_Explosions.Exp7_a00'
     Texture=Texture'Botpack.UT_Explosions.exp1_a00'
     DrawScale=1.400000
}
