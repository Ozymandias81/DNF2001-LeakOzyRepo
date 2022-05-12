//=============================================================================
// CannonShot.
//=============================================================================
class CannonShot extends Projectile;

#exec TEXTURE IMPORT NAME=gbProj0 FILE=..\unreali\MODELS\gb_a00.pcx GROUP=Effects
#exec TEXTURE IMPORT NAME=gbProj1 FILE=..\unreali\MODELS\gb_a01.pcx GROUP=Effects
#exec TEXTURE IMPORT NAME=gbProj2 FILE=..\unreali\MODELS\gb_a02.pcx GROUP=Effects
#exec TEXTURE IMPORT NAME=gbProj3 FILE=..\unreali\MODELS\gb_a03.pcx GROUP=Effects
#exec TEXTURE IMPORT NAME=gbProj4 FILE=..\unreali\MODELS\gb_a04.pcx GROUP=Effects
#exec TEXTURE IMPORT NAME=gbProj5 FILE=..\unreali\MODELS\gb_a05.pcx GROUP=Effects

#exec AUDIO IMPORT FILE="..\unrealshare\Sounds\flak\expl2.wav" NAME="expl2" GROUP="flak"

var() texture SpriteAnim[6];
var int i;

simulated function Timer()
{
	if ( Level.Netmode != NM_DedicatedServer )
		Texture = SpriteAnim[i];
	i++;
	if (i>=6) i=0;
}

simulated function PostBeginPlay()
{
	if ( Level.bDropDetail )
		LightType = LT_None;
	if ( Level.NetMode != NM_DedicatedServer )
	{
		Texture = SpriteAnim[0];
		i=1;
		SetTimer(0.15,True);
	}
	if ( Role == ROLE_Authority )
	{
		PlaySound(SpawnSound);
		Velocity = Vector(Rotation) * speed;
		MakeNoise ( 1.0 );
	}
	Super.PostBeginPlay();
}

auto state Flying
{


simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if (Other != instigator)
	{
		if ( Role == ROLE_Authority )
			Other.TakeDamage(Damage, instigator,HitLocation,
					15000.0 * Normal(velocity), 'burned');
		Explode(HitLocation, Vect(0,0,0));
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	Local UT_SpriteBallExplosion s;

	if (FRand() < 0.5)
		MakeNoise(1.0); 
	s = Spawn(class'UT_SpriteBallExplosion',,,HitLocation+HitNormal*9);
	s.RemoteRole = ROLE_None;
	Destroy();
}

Begin:
	Sleep(3);
	Explode(Location, Vect(0,0,0));
}

defaultproperties
{
     SpriteAnim(0)=Texture'Botpack.gbProj0'
     SpriteAnim(1)=Texture'Botpack.gbProj1'
     SpriteAnim(2)=Texture'Botpack.gbProj2'
     SpriteAnim(3)=Texture'Botpack.gbProj3'
     SpriteAnim(4)=Texture'Botpack.gbProj4'
     SpriteAnim(5)=Texture'Botpack.gbProj5'
     speed=2100.000000
     Damage=12.000000
     ImpactSound=Sound'UnrealI.expl2'
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'UnrealI.gbProj0'
     DrawScale=1.800000
     Fatness=0
     bUnlit=True
     bMeshCurvy=False
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=5
     LightSaturation=16
     LightRadius=9
     RemoteRole=ROLE_SimulatedProxy
	 LifeSpan=+3.5
}
