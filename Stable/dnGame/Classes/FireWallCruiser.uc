/*-----------------------------------------------------------------------------
	FireWallCruiser
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class FireWallCruiser extends Pawn;

#exec OBJ LOAD FILE=..\sounds\dnsWeapn.dfx

var SoftParticleSystem FireWallEffect;
var class<SoftParticleSystem> FireWallEffectClass;
var float TimeAlive, FireDamage;
var bool bCanDie;

// Called by the engine right after the object is spawned or loaded from the level file.
simulated event PreBeginPlay()
{
	// Add us to the global pawn list.
//	AddPawn();

	// Call super.
	Super(RenderActor).PreBeginPlay();

	// If we were destroyed by the above process, don't do anything else.
	if ( bDeleteMe )
		return;

	// Init some values.
	DesiredRotation = Rotation;
	SightCounter = 0.2 * FRand();  //offset randomly 
	if ( Level.Game != None )
		Skill += Level.Game.Difficulty; 
	Skill = FClamp(Skill, 0, 3);
	PreSetMovement();

	// Modify our collision and health given our drawscale.
	if ( DrawScale != Default.Drawscale )
	{
		SetCollisionSize(CollisionRadius*DrawScale/Default.DrawScale, CollisionHeight*DrawScale/Default.DrawScale);
		Health = Health * DrawScale/Default.DrawScale;
	}
}

function PostBeginPlay()
{
	local vector effectloc;

	effectloc = location;
	effectloc.z -= 12;
	FireWallEffect = spawn( FireWallEffectClass, Self,, effectloc );
	FireWallEffect.SetPhysics( PHYS_MovingBrush );
	FireWallEffect.AttachActorToParent( Self, false, false );

	SetPhysics( PHYS_Walking );
}

function Tick( float DeltaTime )
{
	local vector X, Y, Z, dir, realdir;
	local float cosAngle, dist;

	GetAxes( Rotation, X, Y, Z );
	Acceleration = X * AccelRate;

	TimeAlive += DeltaTime;

	if ( (VSize(Velocity) < 10) && (TimeAlive > 0.5) )
	{
		Destroy();
		return;
	}

	dir = vector(Rotation);
	dir.Z = 0;
	dir = normal(dir);
	realdir = Velocity;
	realdir.Z = 0;
	realdir = normal(realdir);

	cosAngle = realdir dot dir;

	if ( (acos(cosAngle)*(180/PI)>15) && (TimeAlive > 0.1) )
	{
		Destroy();
		return;
	}
}

function bool FindBestPathToward(actor desired, bool bClearPaths)
{
}

event bool OnEvalBones(int Channel)
{
	return true;
}

function TakeDamage( int Damage, Pawn InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
}

function HitWall( vector HitNormal, actor Wall )
{
}

event MayFall()
{
	bCanJump = true;
}

event Landed( vector HitNormal )
{
	SetPhysics( PHYS_Walking );
}

event Falling()
{
	SetPhysics( PHYS_Falling );
}

event ZoneChange( ZoneInfo NewZone )
{
	if ( NewZone.bWaterZone )
	{
		// Maybe spawn some smoke?
		Destroy();
	}
}

event Destroyed()
{
	if ( FRand() > 0.5 )
		PlaySound( sound'dnsWeapn.Flamethrower.FTFBallExplPri',,0.6,,,0.9+FRand()*0.2 );
	else
		PlaySound( sound'dnsWeapn.Flamethrower.FTFBallExplSec',,0.6,,,0.9+FRand()*0.2 );

	if ( FireWallEffect != None )
		FireWallEffect.Destroy();

	Super.Destroyed();
}

event Touch( actor Other )
{
	if ( Other.bIsPawn && !Other.IsA('FireWallCruiser') )
	{
		if ( Level.NetMode != NM_Client )
			Other.TakeDamage( FireDamage, Instigator, vect(0,0,0), vect(0,0,0), class'FirewallDamage' );
		Destroy();
	}
	else if ( Other.IsA('Decoration') )
	{
		if ( Level.NetMode != NM_Client )
			Other.TakeDamage( FireDamage, Instigator, vect(0,0,0), vect(0,0,0), class'FirewallDamage' );
	}
}

function Carcass SpawnCarcass( optional class<DamageType> DamageType, optional vector HitLocation, optional vector Momentum )
{
}

defaultproperties
{
	bIsPlayer=false
	bHidden=true
	DrawType=DT_Sprite
	AccelRate=2000
	GroundSpeed=550
	DesiredSpeed=1
	bCollideWorld=true
	bCollideActors=true
	bBlockPlayers=false
	bBlockActors=false
	bAvoidLedges=false
	bAdvancedTactics=false
	CollisionRadius=64
	CollisionHeight=24
	FireDamage=30.0
	Lifespan=10.0
	bBurning=true
	AmbientSound=sound'dnsWeapn.Flamethrower.FTFWallTravelLp'
	SoundVolume=120
	SoundRadius=64
	RemoteRole=ROLE_None
	Intelligence=BRAINS_NONE
	FireWallEffectClass=class'dnParticles.dnFlameThrowerFX_WallFlame'
}