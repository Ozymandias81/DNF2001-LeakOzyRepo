//=============================================================================
// ShockProj.
//=============================================================================
class ShockProj extends Projectile;

#exec OBJ LOAD FILE=textures\ASMDAlt.utx PACKAGE=Botpack.ASMDAlt

var() Sound ExploSound;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( Level.bDropDetail )
		LightType = LT_None;
}

function SuperExplosion()
{
	HurtRadius(Damage*3, 250, MyDamageType, MomentumTransfer*2, Location );
	
	Spawn(Class'ut_ComboRing',,'',Location, Instigator.ViewRotation);
	PlaySound(ExploSound,,20.0,,2000,0.6);	
	
	Destroy(); 
}

auto state Flying
{
	function ProcessTouch (Actor Other, vector HitLocation)
	{
		If ( (Other!=Instigator) && (!Other.IsA('Projectile') || (Other.CollisionRadius > 0)) )
			Explode(HitLocation,Normal(HitLocation-Other.Location));
	}

	function BeginState()
	{
		Velocity = vector(Rotation) * speed;	
	}
}


function Explode(vector HitLocation,vector HitNormal)
{
	PlaySound(ImpactSound, SLOT_Misc, 0.5,,, 0.5+FRand());
	HurtRadius(Damage, 70, MyDamageType, MomentumTransfer, Location );
	if (Damage > 60)
		Spawn(class'ut_RingExplosion3',,, HitLocation+HitNormal*8,rotator(HitNormal));
	else
		Spawn(class'ut_RingExplosion',,, HitLocation+HitNormal*8,rotator(Velocity));		

	Destroy();
}

defaultproperties
{
	 ExplosionDecal=class'Botpack.EnergyImpact'
     speed=1000.000000
     Damage=55.000000
     MomentumTransfer=70000
     MyDamageType=Jolted
	 ExploSound=Sound'UnrealShare.General.SpecialExpl'
     ImpactSound=Sound'UnrealShare.General.Expla02'
     bNetTemporary=False
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=10.000000
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'Botpack.ASMDAlt.ASMDAlt_a00'
     DrawScale=0.400000
     bUnlit=True
     CollisionRadius=12.000000
     CollisionHeight=12.000000
     bProjTarget=True
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=165
     LightSaturation=72
     LightRadius=6
     bFixedRotationDir=True
     RotationRate=(Pitch=45345,Yaw=33453,Roll=63466)
     DesiredRotation=(Pitch=23442,Yaw=34234,Roll=34234)
}
