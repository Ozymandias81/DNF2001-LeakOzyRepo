//=============================================================================
// UTChunk.
//=============================================================================
class UTChunk extends Projectile;

var	chunktrail trail;
var Texture AnimFrame[12];
var int Count;

#exec OBJ LOAD FILE=textures\ChunkGlow.utx PACKAGE=Botpack.ChunkGlow

	simulated function PostBeginPlay()
	{
		local rotator RandRot;

		if ( !Region.Zone.bWaterZone )
			Trail = Spawn(class'ChunkTrail',self);
		if ( Level.NetMode != NM_DedicatedServer )
			SetTimer(0.1, true);

		if ( Role == ROLE_Authority )
		{
			RandRot = Rotation;
			RandRot.Pitch += FRand() * 2000 - 1000;
			RandRot.Yaw += FRand() * 2000 - 1000;
			RandRot.Roll += FRand() * 2000 - 1000;
			Velocity = Vector(RandRot) * (Speed + (FRand() * 200 - 100));
			if (Region.zone.bWaterZone)
				Velocity *= 0.65;
		}
		Super.PostBeginPlay();
	}

	simulated function ProcessTouch (Actor Other, vector HitLocation)
	{
		if ( (Chunk(Other) == None) && ((Physics == PHYS_Falling) || (Other != Instigator)) )
		{
			speed = VSize(Velocity);
			If ( speed > 200 )
			{
				if ( Role == ROLE_Authority )
					Other.TakeDamage(damage, instigator,HitLocation,
						(MomentumTransfer * Velocity/speed), MyDamageType );
				if ( FRand() < 0.5 )
					PlaySound(Sound 'ChunkHit',, 2.0,,1000);
			}
			Destroy();
		}
	}

	simulated function Timer() 
	{
		Count++;
		Texture = AnimFrame[Count];
		if ( Count == 11 )
			SetTimer(0.0,false);
	}

	simulated function Landed( Vector HitNormal )
	{
		SetPhysics(PHYS_None);
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
		local float Rand;
		local SmallSpark s;

		if ( (Mover(Wall) != None) && Mover(Wall).bDamageTriggered )
		{
			if ( Level.NetMode != NM_Client )
				Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
			Destroy();
			return;
		}
		if ( Physics != PHYS_Falling ) 
		{
			SetPhysics(PHYS_Falling);
			if ( !Level.bDropDetail && (Level.Netmode != NM_DedicatedServer) && !Region.Zone.bWaterZone ) 
			{
				if ( FRand() < 0.5 )
				{
					s = Spawn(Class'SmallSpark',,,Location+HitNormal*5,rotator(HitNormal));
					s.RemoteRole = ROLE_None;
				}
				else
					Spawn(class'WallCrack',,,Location, rotator(HitNormal));
			}
		}
		Velocity = 0.8*(( Velocity dot HitNormal ) * HitNormal * (-1.8 + FRand()*0.8) + Velocity);   // Reflect off Wall w/damping
		SetRotation(rotator(Velocity));
		speed = VSize(Velocity);
		if ( speed > 100 ) 
		{
			MakeNoise(0.3);
			Rand = FRand();
			if (Rand < 0.33)	PlaySound(sound 'Hit1', SLOT_Misc,0.6,,1000);	
			else if (Rand < 0.66) PlaySound(sound 'Hit3', SLOT_Misc,0.6,,1000);
			else PlaySound(sound 'Hit5', SLOT_Misc,0.6,,1000);
		}
	}

	simulated function zonechange(Zoneinfo NewZone)
	{
		if (NewZone.bWaterZone)
		{
			if ( Trail != None )
				Trail.Destroy();
			SetTimer(0.0, false);
			Texture = AnimFrame[11];
			Velocity *= 0.65;
		}
	}

defaultproperties
{
	 AnimFrame(0)=Texture'Botpack.ChunkGlow.Chunk_a00'
	 AnimFrame(1)=Texture'Botpack.ChunkGlow.Chunk_a01'
	 AnimFrame(2)=Texture'Botpack.ChunkGlow.Chunk_a02'
	 AnimFrame(3)=Texture'Botpack.ChunkGlow.Chunk_a03'
	 AnimFrame(4)=Texture'Botpack.ChunkGlow.Chunk_a04'
	 AnimFrame(5)=Texture'Botpack.ChunkGlow.Chunk_a05'
	 AnimFrame(6)=Texture'Botpack.ChunkGlow.Chunk_a06'
	 AnimFrame(7)=Texture'Botpack.ChunkGlow.Chunk_a07'
	 AnimFrame(8)=Texture'Botpack.ChunkGlow.Chunk_a08'
	 AnimFrame(9)=Texture'Botpack.ChunkGlow.Chunk_a09'
	 AnimFrame(10)=Texture'Botpack.ChunkGlow.Chunk_a10'
	 AnimFrame(11)=Texture'Botpack.ChunkGlow.Chunk_a11'
	 MyDamageType=Shredded
     speed=2500.000000
     MaxSpeed=2700.000000
     Damage=16.000000
     MomentumTransfer=10000
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=2.900000
     bUnlit=True
     bNoSmooth=True
     bMeshCurvy=False
     bBounce=True
     NetPriority=2.500000
     AmbientGlow=255
     DrawScale=0.400000
     Texture=Texture'Botpack.ChunkGlow.Chunk_a00'
}
