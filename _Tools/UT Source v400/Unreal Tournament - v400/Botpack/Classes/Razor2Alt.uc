//=============================================================================
// RazorBladeAlt.
//=============================================================================
class Razor2Alt extends Razor2;

#exec AUDIO IMPORT FILE="Sounds\Ripper\RazorjackAltFire.WAV" NAME="RazorAlt" GROUP="Ripper"

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( Level.bDropDetail )
		LightType = LT_None;
}

auto state Flying
{
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		local RipperPulse s;

		if ( Other != Instigator ) 
		{
			if ( Role == ROLE_Authority )
			{
				Other.TakeDamage(damage, instigator,HitLocation,
					(MomentumTransfer * Normal(Velocity)), MyDamageType );
			}
			s = spawn(class'RipperPulse',,,HitLocation);	
 			s.RemoteRole = ROLE_None;
			MakeNoise(1.0);
 			Destroy();
		}
	}

	simulated function HitWall (vector HitNormal, actor Wall)
	{
		Super(Projectile).HitWall( HitNormal, Wall );
	}

	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		local RipperPulse s;

		s = spawn(class'RipperPulse',,,HitLocation + HitNormal*16);	
 		s.RemoteRole = ROLE_None;
		BlowUp(HitLocation);

 		Destroy();
	}

	function BlowUp(vector HitLocation)
	{
		local actor Victims;
		local float damageScale, dist;
		local vector dir;

		if( bHurtEntry )
			return;

		bHurtEntry = true;
		foreach VisibleCollidingActors( class 'Actor', Victims, 180, HitLocation )
		{
			if( Victims != self )
			{
				dir = Victims.Location - HitLocation;
				dist = FMax(1,VSize(dir));
				dir = dir/dist;
				dir.Z = FMin(0.45, dir.Z); 
				damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/180);
				Victims.TakeDamage
				(
					damageScale * Damage,
					Instigator, 
					Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
					damageScale * MomentumTransfer * dir,
					MyDamageType
				);
			} 
		}
		bHurtEntry = false;
		MakeNoise(1.0);
	}
}

defaultproperties
{
	 ExplosionDecal=class'Botpack.RipperMark'
	 MyDamageType=RipperAltDeath
	 SpawnSound=sound'Botpack.Ripper.RazorAlt'
	 Damage=+34.0000
     MomentumTransfer=87000
     LifeSpan=6.000000
     AnimSequence=spin
     Mesh=Mesh'Botpack.RazorBlade'
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=23
     LightSaturation=0
     LightRadius=3
}
