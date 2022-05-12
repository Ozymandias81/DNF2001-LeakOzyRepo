//=============================================================================
// ShockWave.
//=============================================================================
class ShockWave extends Effects;

#exec MESH IMPORT MESH=ShockWavem ANIVFILE=MODELS\SW_a.3D DATAFILE=MODELS\SW_d.3D X=0 Y=0 Z=0 
#exec MESH ORIGIN MESH=ShockWavem X=0 Y=0 Z=0 YAW=0 PITCH=64
#exec MESH SEQUENCE MESH=ShockWavem SEQ=All       STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=ShockWavem SEQ=Explosion STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=ShockWavem SEQ=Implode   STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Shockt1 FILE=MODELS\shockw.PCX GROUP="Skins"
#exec MESHMAP SCALE MESHMAP=ShockWavem X=1.0 Y=1.0 Z=2.0 
#exec MESHMAP SETTEXTURE MESHMAP=ShockWavem NUM=1 TEXTURE=Shockt1

var float OldShockDistance, ShockSize;
var int ICount;

simulated function Tick( float DeltaTime )
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		ShockSize =  13 * (Default.LifeSpan - LifeSpan) + 3.5/(LifeSpan/Default.LifeSpan+0.05);
		ScaleGlow = Lifespan;
		AmbientGlow = ScaleGlow * 255;
		DrawScale = ShockSize;
	}
}

simulated function Timer()
{

	local actor Victims;
	local float damageScale, dist, MoScale;
	local vector dir;

	ShockSize =  13 * (Default.LifeSpan - LifeSpan) + 3.5/(LifeSpan/Default.LifeSpan+0.05);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if (ICount==4) spawn(class'WarExplosion2',,,Location);
		ICount++;

		if ( Level.NetMode == NM_Client )
		{
			foreach VisibleCollidingActors( class 'Actor', Victims, ShockSize*29, Location )
				if ( Victims.Role == ROLE_Authority )
				{
					dir = Victims.Location - Location;
					dist = FMax(1,VSize(dir));
					dir = dir/dist +vect(0,0,0.3); 
					if ( (dist> OldShockDistance) || (dir dot Victims.Velocity <= 0))
					{
						MoScale = FMax(0, 1100 - 1.1 * Dist);
						Victims.Velocity = Victims.Velocity + dir * (MoScale + 20);	
						Victims.TakeDamage
						(
							MoScale,
							Instigator, 
							Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
							(1000 * dir),
							'RedeemerDeath'
						);
					}
				}	
			return;
		}
	}

	foreach VisibleCollidingActors( class 'Actor', Victims, ShockSize*29, Location )
	{
		dir = Victims.Location - Location;
		dist = FMax(1,VSize(dir));
		dir = dir/dist + vect(0,0,0.3); 
		if (dist> OldShockDistance || (dir dot Victims.Velocity < 0))
		{
			MoScale = FMax(0, 1100 - 1.1 * Dist);
			if ( Victims.bIsPawn )
				Pawn(Victims).AddVelocity(dir * (MoScale + 20));
			else
				Victims.Velocity = Victims.Velocity + dir * (MoScale + 20);	
			Victims.TakeDamage
			(
				MoScale,
				Instigator, 
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(1000 * dir),
				'RedeemerDeath'
			);
		}
	}	
	OldShockDistance = ShockSize*29;	
}

simulated function PostBeginPlay()
{
	local Pawn P;

	if ( Role == ROLE_Authority ) 
	{
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
			if ( P.IsA('PlayerPawn') && (VSize(P.Location - Location) < 3000) )
				PlayerPawn(P).ShakeView(0.5, 600000.0/VSize(P.Location - Location), 10);

		if ( Instigator != None )
			MakeNoise(10.0);
	}

	SetTimer(0.1, True);

	if ( Level.NetMode != NM_DedicatedServer )
		SpawnEffects();
}

simulated function SpawnEffects()
{
	 local WarExplosion W;

	 PlaySound(Sound'Expl03',,6.0);
	 W = spawn(class'WarExplosion',,,Location);
	 W.RemoteRole = ROLE_None;
}

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=1.500000
     DrawType=DT_Mesh
     Style=STY_Translucent
     Mesh=Mesh'Botpack.ShockWavem'
     AmbientGlow=255
     bUnlit=True
	 bAlwaysRelevant=true
}
