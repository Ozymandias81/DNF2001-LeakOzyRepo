//=============================================================================
// UTFlakShell.
//=============================================================================
class UTFlakShell extends Projectile;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	Velocity = Vector(Rotation) * Speed;     
	Velocity.z += 200; 
	if ( Level.bHighDetailMode  && !Level.bDropDetail ) 
		SetTimer(0.05,True);
	else 
		SetTimer(0.25,True);
}

function ProcessTouch (Actor Other, vector HitLocation)
{
	if ( Other != instigator ) 
		Explode(HitLocation,Normal(HitLocation-Other.Location));
}

function Landed( vector HitNormal )
{
	Explode(Location,HitNormal);
}

simulated function Timer()
{
	local ut_SpriteSmokePuff s;

	if (Level.NetMode!=NM_DedicatedServer) 
	{
		s = Spawn(class'ut_SpriteSmokePuff');
		s.RemoteRole = ROLE_None;
	}	
}

function Explode(vector HitLocation, vector HitNormal)
{
	local vector start;

	HurtRadius(damage, 150, 'FlakDeath', MomentumTransfer, HitLocation);	
	start = Location + 10 * HitNormal;
 	Spawn( class'FlameExplosion',,,Start);
	Spawn( class 'UTChunk2',, '', Start);
	Spawn( class 'UTChunk3',, '', Start);
	Spawn( class 'UTChunk4',, '', Start);
	Spawn( class 'UTChunk1',, '', Start);
 	Destroy();
}

defaultproperties
{
	 ExplosionDecal=class'Botpack.BlastMark'
     speed=1200.000000
     Damage=70.000000
     MomentumTransfer=75000
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=6.000000
     Mesh=Mesh'UnrealI.FlakSh'
     AmbientGlow=67
     bUnlit=True
     bMeshCurvy=False
     NetPriority=2.500000
	 bNetTemporary=false
}
