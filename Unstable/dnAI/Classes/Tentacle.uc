class Tentacle expands RenderActor;
#exec OBJ LOAD FILE=..\sounds\a_Creatures.dfx PACKAGE=a_Creatures

var sound WhipSound;

var bool bNewAttack;

/*-----------------------------------------------------------------------------
	Animation Notifications
-----------------------------------------------------------------------------*/

function PlayRetract()
{
	PlayAnim( 'Retract' );
	if( FRand() < 0.33 )
		PlaySound( Sound'a_Creatures.Tentacle.TentacleExt1' );
	else if( FRand() < 0.33 )
		PlaySound( Sound'a_Creatures.Tentacle.TentacleExt2' );
	else
		PlaySound( Sound'a_Creatures.Tentacle.TentacleExt3' );
}

function PlayExpand()
{
	PlayAnim( 'Expand' );
}

/*-----------------------------------------------------------------------------
	States
-----------------------------------------------------------------------------*/

state MAttackA
{
	function TentacleSwipe( class<DamageType> DamageType )
	{
		local vector HitLocation, HitNormal, TargetPoint;
		local float TargetDist;
		local actor HitActor;
		local bool result;
		if( Pawn( Owner ) != None )
		{
			if( Pawn( Owner ).GetSequence( 0 ) == 'A_KnockDownF_All' )
				return;

			HitActor = Trace( HitLocation, HitNormal, Owner.Location + vector( Pawn( Owner ).Rotation ) * 128, Owner.Location + vector( Pawn( Owner ).Rotation ), true );
			if( HitActor.IsA( 'DukePlayer' ) )
				DukePlayer( HitActor ).HitEffect( HitLocation, DamageType, vect( 0, 0, 0 ), false );

			if( HitActor != None )
				Pawn( HitActor ).TakeDamage( 35*DrawScale, Pawn( Owner ),HitLocation, ( vector( Owner.Rotation ) * vect( 1, 1, 0 ) ) * 22000, DamageType );
		}
	}

	function TentacleSwipeLeft() { TentacleSwipe( class'WhippedLeftDamage' ); }
	function TentacleSwipeRight() { TentacleSwipe( class'WhippedRightDamage' ); }
	function TentacleSwipeDown() { TentacleSwipe( class'WhippedDownDamage' ); }

	function Timer( optional int TimerNum )
	{
		local sound NewWhipSound;

		NewWhipSound = Sound'a_Creatures.Tentacle.TentacleMsc1';
		if( NewWhipSound == WhipSound )
		{
			NewWhipSound = Sound'a_Creatures.Tentacle.TentacleMsc2';
		}
		if( NewWhipSound == WhipSound )
		{
			NewWhipSound = Sound'a_Creatures.Tentacle.TentacleMsc3';
		}
		PlaySound( NewWhipSound );
	}

Begin:
	bHidden = false;
	if( bNewAttack )
		PlayAnim( 'MAttackSwipeA' );
	else
		PlayAnim( 'MAttackA' );
	Sleep( 0.3 );
	if( FRand() < 0.33 )
	{
		WhipSound = Sound'a_Creatures.Tentacle.TentacleMsc1';
	}
	else if( FRand() < 0.33 )
	{
		WhipSound = Sound'a_Creatures.Tentacle.TentacleMsc2';
	}
	else
	{
		WhipSound = Sound'a_Creatures.Tentacle.TentacleMsc3';
	}
	SetTimer( GetSoundDuration( WhipSound ), false );
	PlaySound( WhipSound );
	FinishAnim();
	Destroy();
}

state ShoulderTentacle
{
	function TentacleSwipeLeft();
	function TentacleSwipeRight();
	function TentacleSwipeDown();

	function BeginState() {}

	function PlayIdle()
	{
		local float Decision;

		Decision = FRand();

		if( Decision < 0.33 )
		{
			LoopAnim( 'IdleA' );
		}
		else if( Decision < 0.66 )
		{
			LoopAnim( 'IdleB' );
		}
		else
		{
			LoopAnim( 'IdleC' );
		}
	}

Begin:
	Sleep( FRand() );
	bHidden = false;
	if( FRand() < 0.5 )
	{
		PlaySound( Sound'a_Creatures.Tentacle.TentacleAtk1' );
	}
	else
		PlaySound( Sound'a_Creatures.Tentacle.TentacleAtk3' );

	PlayExpand();
	FinishAnim();
	PlayIdle();
	Sleep( 2 + FRand() );
	PlayRetract();
	FinishAnim();
	if (HumanNPC(Owner) != None)
		HumanNPC(Owner).InitializeTentacles();
	Destroy();
}


state ShoulderDamageTentacle expands ShoulderTentacle
{
	function BeginState()
	{
		bHidden = false;
	}

Begin:
	PlayExpand();
	FinishAnim();
	LoopAnim( 'IdleB' );
	Sleep( FRand() + 1 );
	PlayRetract();
	FinishAnim();
	HumanNPC( Owner ).InitializeTentacles();
	Destroy();
}

state TentacleDeath
{
	function BeginState()
	{
		bHidden = false;
	}

Begin:
	bHidden = false;	
//	PlayExpand();
//	FinishAnim();
	LoopAnim( 'HeadWiggleA', 6.3 );
	DrawScale *= 1.2;
	Sleep( 4.0 + FRand() );
//	PlayRetract();
	FinishAnim();
	Destroy();
}

state ArmTentacle
{
	function BeginState()
	{
		bHidden = false;
	}

	function Timer( optional int TimerNum )
	{
		Disable( 'Tick' );
		HumanNPC( Owner ).HeadTrackingActor = HumanNPC( Owner ).Enemy;
	}

	function Tick( float DeltaTime )
	{
		HumanNPC( Owner ).HeadTrackingActor = self;
	}

Begin:
	PlayExpand();
	SetTimer( 1.0, false );
	FinishAnim();
	LoopAnim( 'IdleA', 6.3 );
}

state DogTentacle
{
	function TentacleSwipe( class<DamageType> DamageType )
	{
		local vector HitLocation, HitNormal, TargetPoint;
		local float TargetDist;
		local actor HitActor;
		local bool result;
		if( Pawn( Owner ) != None )
		{
			HitActor = Trace( HitLocation, HitNormal, Owner.Location + vector( Pawn( Owner ).Rotation ) * 128, Owner.Location + vector( Pawn( Owner ).Rotation ), true );
			if( HitActor != None )
			{
				if( HitActor.IsA( 'DukePlayer' ) )
					DukePlayer( HitActor ).HitEffect( HitLocation, DamageType, vect( 0, 0, 0 ), false );
				Pawn( HitActor ).TakeDamage(15, Pawn( Owner ),HitLocation, ( vector( Owner.Rotation ) * vect( 1, 1, 0 ) ) * 22000, DamageType);
			}
		}
	}

	function TentacleSwipeLeft() { TentacleSwipe( class'WhippedLeftDamage' ); }
	function TentacleSwipeRight() { TentacleSwipe( class'WhippedRightDamage' ); }
	function TentacleSwipeDown() { TentacleSwipe( class'WhippedDownDamage' ); }

	function Timer( optional int TimerNum )
	{
		local sound NewWhipSound;

		NewWhipSound = Sound'a_Creatures.Tentacle.TentacleMsc1';
		if( NewWhipSound == WhipSound )
		{
			NewWhipSound = Sound'a_Creatures.Tentacle.TentacleMsc2';
		}
		if( NewWhipSound == WhipSound )
		{
			NewWhipSound = Sound'a_Creatures.Tentacle.TentacleMsc3';
		}
		PlaySound( NewWhipSound );
	}

Begin:
	bHidden = false;
	PlayAnim( 'DogTailAttackA' );
	Sleep( 0.3 );
	if( FRand() < 0.33 )
	{
		WhipSound = Sound'a_Creatures.Tentacle.TentacleMsc1';
	}
	else if( FRand() < 0.33 )
	{
		WhipSound = Sound'a_Creatures.Tentacle.TentacleMsc2';
	}
	else
	{
		WhipSound = Sound'a_Creatures.Tentacle.TentacleMsc3';
	}
	SetTimer( GetSoundDuration( WhipSound ), false );
	PlaySound( WhipSound );
	FinishAnim();
	Destroy();
}

defaultproperties
{
     bHidden=true
     Physics=PHYS_MovingBrush
     DrawType=DT_Mesh
     Mesh=DukeMesh'c_characters.GenericTentacle'
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bHeated=True
     HeatIntensity=255.000000
     LightDetail=LTD_AmbientOnly
}
