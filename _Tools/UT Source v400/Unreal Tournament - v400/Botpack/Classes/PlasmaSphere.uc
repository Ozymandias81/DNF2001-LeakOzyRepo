//=============================================================================
// PlasmaSphere.
//=============================================================================
class PlasmaSphere extends Projectile;

#exec OBJ LOAD FILE=textures\PlasmaExplo.utx PACKAGE=Botpack.PlasmaExplo
 
#exec AUDIO IMPORT FILE="..\unrealshare\Sounds\Dispersion\DFly1.WAV" NAME="PulseFly" GROUP="PulseGun"
#exec AUDIO IMPORT FILE="Sounds\Pulsegun\PulseExp.WAV" NAME="PulseExp" GROUP="PulseGun"

var bool bExploded, bExplosionEffect, bHitPawn;
var() texture ExpType;
var() Sound EffectSound1;
var() texture SpriteAnim[20];
var() int NumFrames;
var Float AnimTime;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(0.8, true);
	if ( Level.NetMode == NM_Client )
		LifeSpan = 2.0;
	else
		Velocity = Speed * vector(Rotation);
	if ( Level.bDropDetail )
		LightType = LT_None;
}

simulated function Timer()
{
	if ( Level.bDropDetail )
		LightType = LT_None;
	if ( (Physics == PHYS_None) && (LifeSpan > 0.5) )
		LifeSpan = 0.5;
}

simulated function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, 
					Vector momentum, name damageType)
{
	bExploded = True;
}

function BlowUp(vector HitLocation)
{
	PlaySound(EffectSound1,,7.0);	
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if ( !bExplosionEffect )
	{
		if ( Role == ROLE_Authority )
			BlowUp(HitLocation);
		bExplosionEffect = true;
		if ( !Level.bHighDetailMode || bHitPawn || Level.bDropDetail )
		{
			if ( bExploded )
			{
				Destroy();
				return;
			}
			else
				DrawScale = 0.45;
		}
		else
			DrawScale = 0.65;

	    LightType = LT_Steady;
		LightRadius = 5;
		SetCollision(false,false,false);
		LifeSpan = 0.5;
		Texture = ExpType;
		DrawType = DT_SpriteAnimOnce;
		Style = STY_Translucent;
		if ( Region.Zone.bMoveProjectiles && (Region.Zone.ZoneVelocity != vect(0,0,0)) )
		{
			bBounce = true;
			Velocity = Region.Zone.ZoneVelocity;
		}
		else
			SetPhysics(PHYS_None);
	}
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	If ( Other!=Instigator  && PlasmaSphere(Other)==None )
	{
		if ( Other.bIsPawn )
		{
			bHitPawn = true;
			bExploded = !Level.bHighDetailMode || Level.bDropDetail;
		}
		if ( Role == ROLE_Authority )
			Other.TakeDamage( Damage, instigator, HitLocation, MomentumTransfer*Vector(Rotation), MyDamageType);	
		Explode(HitLocation, vect(0,0,1));
	}
}

auto State Flying
{
Begin:
	LifeSpan = 2.0;
}

defaultproperties
{
	 ExplosionDecal=class'Botpack.BoltScorch'
	 MyDamageType=Pulsed
     SpriteAnim(0)=Texture'Botpack.pblst00'
     SpriteAnim(1)=Texture'Botpack.pblst01'
     SpriteAnim(2)=Texture'Botpack.pblst02'
     SpriteAnim(3)=Texture'Botpack.pblst03'
     SpriteAnim(4)=Texture'Botpack.pblst04'
     SpriteAnim(5)=Texture'Botpack.pblst05'
     SpriteAnim(6)=Texture'Botpack.pblst06'
     SpriteAnim(7)=Texture'Botpack.pblst07'
     SpriteAnim(8)=Texture'Botpack.pblst08'
     SpriteAnim(9)=Texture'Botpack.pblst09'
     SpriteAnim(10)=Texture'Botpack.pblst10'
     NumFrames=11
     EffectSound1=Sound'PulseExp'
     speed=1450.000000
     MomentumTransfer=10000
     ExploWallOut=10.000000
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=0.500000
     Style=STY_Translucent
     DrawScale=0.190000
     AmbientGlow=187
     bUnlit=True
     SoundRadius=10
     SoundVolume=218
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightRadius=3
     LightBrightness=255
     LightHue=83
     LightSaturation=0
     bFixedRotationDir=True
     ExpType=Texture'PlasmaExplo.pblst_a00'
     Damage=20.000000
	 DrawType=DT_Sprite
     Texture=Texture'Botpack.PlasmaExplo.pblst_a00'
}
