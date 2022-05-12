//=============================================================================
// WarShell.
//=============================================================================
class WarShell extends Projectile;

#exec MESH IMPORT MESH=missile ANIVFILE=MODELS\missile_a.3d DATAFILE=MODELS\missile_d.3d LODSTYLE=2
#exec MESH ORIGIN MESH=missile X=0 Y=0 Z=100 PITCH=192
#exec MESH SEQUENCE MESH=missile SEQ=All                      STARTFRAME=0 NUMFRAMES=100
#exec MESH SEQUENCE MESH=missile SEQ=missile                  STARTFRAME=0 NUMFRAMES=100
#exec MESHMAP NEW   MESHMAP=missile MESH=missile
#exec MESHMAP SCALE MESHMAP=missile X=0.1 Y=0.1 Z=0.2
#exec TEXTURE IMPORT NAME=Jmissile_01 FILE=Models\missile.PCX GROUP=Skins
#exec MESHMAP SETTEXTURE MESHMAP=missile NUM=1 TEXTURE=Jmissile_01 TLOD=30
#exec AUDIO IMPORT FILE="Sounds\Warhead\redeemerrocketfly.wav" NAME="WarFly" GROUP=Redeemer

var float CannonTimer, SmokeRate;
var	redeemertrail trail;

simulated function Timer()
{
	local ut_SpriteSmokePuff b;

	if ( Trail == None )
		Trail = Spawn(class'RedeemerTrail',self);

	CannonTimer += SmokeRate;
	if ( CannonTimer > 0.6 )
	{
		WarnCannons();
		CannonTimer -= 0.6;
	}

	if ( Region.Zone.bWaterZone || (Level.NetMode == NM_DedicatedServer) )
	{
		SetTimer(SmokeRate, false);
		Return;
	}

	if ( Level.bHighDetailMode )
	{
		if ( Level.bDropDetail )
			Spawn(class'LightSmokeTrail');
		else
			Spawn(class'UTSmokeTrail');
		SmokeRate = 152/Speed; 
	}
	else 
	{
		SmokeRate = 0.15;
		b = Spawn(class'ut_SpriteSmokePuff');
		b.RemoteRole = ROLE_None;
	}
	SetTimer(SmokeRate, false);
}

simulated function Destroyed()
{
	if ( Trail != None )
		Trail.Destroy();
	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	SmokeRate = 0.3;
	SetTimer(0.3,false); 
}

function WarnCannons()
{
	local Pawn P;

	for ( P=Level.Pawnlist; P!=None; P=P.NextPawn )
		if ( P.IsA('TeamCannon') && !P.IsInState('TrackWarhead') && P.LineOfSightTo(self) )
		{
			P.target = self;
			P.GotoState('TrackWarhead');
		}
}

singular function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, 
						vector momentum, name damageType )
{
	if ( NDamage > 5 )
	{
		PlaySound(Sound'Expl03',,6.0);
		spawn(class'WarExplosion',,,Location);
		HurtRadius(Damage,350.0, MyDamageType, MomentumTransfer, HitLocation );
		RemoteRole = ROLE_SimulatedProxy;	 		 		
 		Destroy();
	}
}

auto state Flying
{

	simulated function ZoneChange( Zoneinfo NewZone )
	{
		local waterring w;
		
		if ( NewZone.bWaterZone != Region.Zone.bWaterZone )
		{
			w = Spawn(class'WaterRing',,,,rot(16384,0,0));
			w.DrawScale = 0.2;
			w.RemoteRole = ROLE_None; 
		}	
	}

	function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if ( Other != instigator ) 
			Explode(HitLocation,Normal(HitLocation-Other.Location));
	}

	function Explode(vector HitLocation, vector HitNormal)
	{
		if ( Role < ROLE_Authority )
			return;

		HurtRadius(Damage,300.0, MyDamageType, MomentumTransfer, HitLocation );	 		 		
 		spawn(class'ShockWave',,,HitLocation+ HitNormal*16);	
		RemoteRole = ROLE_SimulatedProxy;	 		 		
 		Destroy();
	}

	function BeginState()
	{
		local vector InitialDir;

		initialDir = vector(Rotation);
		if ( Role == ROLE_Authority )	
			Velocity = speed*initialDir;
		Acceleration = initialDir*50;
	}
}

defaultproperties
{
	 ExplosionDecal=class'Botpack.NuclearMark'
     speed=600.000000
     Damage=1000.000000
     MomentumTransfer=100000
     MyDamageType=RedeemerDeath
     bNetTemporary=False
     RemoteRole=ROLE_SimulatedProxy
     Mesh=LodMesh'Botpack.missile'
     AmbientGlow=78
     bUnlit=True
     SoundRadius=100
     SoundVolume=255
     AmbientSound=Sound'Botpack.Redeemer.WarFly'
     CollisionRadius=15.000000
     CollisionHeight=8.000000
     bProjTarget=True
}
