/*-----------------------------------------------------------------------------
	ShockWave
-----------------------------------------------------------------------------*/
class ShockWave extends Effects;

var float OldShockDistance, ShockSize;

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
	/*
	 local WarExplosion W;

	 PlaySound(Sound'Expl03', SLOT_Interface, 16.0);
	 PlaySound(Sound'Expl03', SLOT_None, 16.0);
	 PlaySound(Sound'Expl03', SLOT_Misc, 16.0);
	 PlaySound(Sound'Expl03', SLOT_Talk, 16.0);
	 W = spawn(class'WarExplosion',,,Location);
	 W.RemoteRole = ROLE_None;
	 */
}

simulated function Tick( float DeltaTime )
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		ShockSize =  14 * (Default.LifeSpan - LifeSpan) + 3.5/(LifeSpan/Default.LifeSpan+0.05);
		ScaleGlow = Lifespan;
		AmbientGlow = ScaleGlow * 255;
		DrawScale = ShockSize;
	}
}

simulated function Timer( optional int TimerNum )
{
	local actor Victims;
	local float damageScale, dist, MoScale;
	local vector dir;

	ShockSize =  14 * (Default.LifeSpan - LifeSpan) + 3.5/(LifeSpan/Default.LifeSpan+0.05);
	if ( Level.NetMode != NM_DedicatedServer )
	{
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
							class'CrushingDamage'
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
				class'CrushingDamage'
			);
		}
	}	
	OldShockDistance = ShockSize*29;	
}

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=1.500000
     DrawType=DT_Mesh
     Style=STY_Translucent
     AmbientGlow=255
     bUnlit=True
	 bAlwaysRelevant=true
	 bHidden=true
}
