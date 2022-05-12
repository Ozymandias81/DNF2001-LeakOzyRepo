class RipperPulse extends AnimSpriteEffect;

#exec OBJ LOAD FILE=textures\RipperPulse.utx PACKAGE=Botpack.RipperPulse

function MakeSound()
{
	PlaySound(EffectSound1,,7.0);
}

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_Client )
		MakeSound();
	if ( Level.bDropDetail )
		LightRadius = 5;
//	Texture = SpriteAnim[int(FRand()*5)];
	Super.PostBeginPlay();		
}

simulated function Timer()
{
}

defaultproperties
{
     SpriteAnim(0)=Texture'Botpack.RipperPulse.HEexpl1_a00'
     SpriteAnim(1)=Texture'Botpack.RipperPulse.HEexpl1_a00'
     SpriteAnim(2)=Texture'Botpack.RipperPulse.HEexpl1_a00'
     SpriteAnim(3)=Texture'Botpack.RipperPulse.HEexpl1_a00'
     SpriteAnim(4)=Texture'Botpack.RipperPulse.HEexpl1_a00'
     SpriteAnim(5)=Texture'Botpack.RipperPulse.HEexpl1_a00'
     SpriteAnim(6)=Texture'Botpack.RipperPulse.HEexpl1_a00'
     SpriteAnim(7)=Texture'Botpack.RipperPulse.HEexpl1_a00'
     NumFrames=7
     Pause=0.050000
     EffectSound1=Sound'UnrealShare.General.Expl03'
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=0.700000
     DrawType=DT_SpriteAnimOnce
     Style=STY_Translucent
     Texture=Texture'Botpack.RipperPulse.HEexpl1_a00'
     Skin=Texture'UnrealShare.Effects.ExplosionPal'
     DrawScale=1.000000
     LightType=LT_TexturePaletteOnce
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=27
     LightSaturation=71
     LightRadius=7
     bCorona=False
}
