/*-----------------------------------------------------------------------------
	PlantedBomb
	Author: Scott Alden
-----------------------------------------------------------------------------*/
class PlantedBomb extends dnDecoration;

#exec OBJ LOAD FILE=..\Sounds\a_generic.dfx

var		int				DefuseTime;
var		int				DetonateTime;
var		Actor			Defuser;
var		bool			bDefused;
var		sound			TickSound;
var		float			MomentumTransfer;
var		float			Damage;
var		class<Actor>	ExplosionClass;

function Used( actor Other, Pawn EventInstigator )
{
	if ( bDefused || Defuser != None )
	{
		BroadcastMessage( "Someone is defusing the bomb" );
		return;
	}
	
	// Save off the defuser
	Defuser			= other;

	// Set this to false so nobody else can use it
	bUseTriggered	= false;

	// Reset the defuse time
	DefuseTime = default.DefuseTime;

	// Set a defuse timer
	SetCallbackTimer( 1.0f, true, 'CheckDefuse' );

	// Tell the client to bring up a hud display
	if ( Defuser != None && Defuser.IsA( 'PlayerPawn' ) )
		PlayerPawn( Defuser ).ClientStartDefuseBomb( self );
}

function UnUsed( actor Other, pawn EventInstigator )
{
	StopDefuse();
}

function StopDefuse()
{
	EndCallbackTimer( 'CheckDefuse' );

	bUseTriggered = true;

	if ( Defuser != None && Defuser.IsA( 'PlayerPawn' ) )
		PlayerPawn( Defuser ).ClientStopDefuseBomb( self );

	Defuser = None;
}

simulated function ClientStartDefuse()
{
	if ( Level.NetMode == NM_Client )
	{
		DefuseTime = default.DefuseTime;
		SetCallBackTimer( 1.0f, true, 'ClientDefuseTick' );	
	}
}

simulated function ClientStopDefuse()
{
	if ( Level.NetMode == NM_Client )
	{
		DefuseTime = default.DefuseTime;
		EndCallbackTimer( 'ClientDefuseTick' );
	}
}

simulated function ClientDefuseTick()
{
	DefuseTime -= 1;

	if ( DefuseTime <= 0 )
		DefuseTime = 0;
}

function Tick( float DeltaSeconds )
{
	local vector Delta;
	local float  Dist, Dot;

	Super.Tick( DeltaSeconds );

	if ( Defuser != None && PlayerPawn( Defuser ) != None )
	{
		Delta = self.Location - Defuser.Location;
		Dist  = VSize( Delta );
		Delta /= Dist;

		Dot   = Delta dot Vector( PlayerPawn( Defuser ).ViewRotation );

		if ( Dot < 0.75 )
			StopDefuse();
		else if ( Dist > 100 )
			StopDefuse();
	}
}

function StartCountdown()
{
	DetonateTime = default.DetonateTime;
	SetCallbackTimer( 1.0f, true, 'CheckDetonate' );
}

function CheckDefuse()
{
	DefuseTime--;

	if ( DefuseTime <= 0 )
	{
		DefuseTime = 0;

		if ( ( dnTeamGame_Bomb( Level.Game ) != None ) && ( Role == ROLE_Authority ) )
		{  
			dnTeamGame_Bomb( Level.Game ).BombDefused();
		}

		EndCallbackTimer( 'CheckDetonate' );

		bDefused = true;

		self.Destroy();
	}
}

function CheckDetonate()
{
	if ( bDefused )
		return;

	DetonateTime--;

	PlaySound( TickSound );

	if ( DetonateTime <= 0 )
	{
		Detonate();  // Boom!
	} 
	else if ( DetonateTime == 10 )
	{
		BroadcastLocalizedMessage( class'dnBombMessage', 4 );
	}
}

function Detonate()
{
	local Actor s;

	if ( dnTeamGame_Bomb( Level.Game ) != None )
	{
		dnTeamGame_Bomb( Level.Game ).BombDetonated();
	}

  	s = spawn( ExplosionClass,,,Location );
	HurtRadius( Damage, 1000, class'GrenadeDamage', MomentumTransfer, Location );

	self.Destroy();
}

defaultproperties
{
	Damage=1000
	ExplosionClass=class'dnGrenadeFX_Explosion_Flash'
	MomentumTransfer=100000
	bStatic=false
	ItemName="Planted Bomb"
	Mesh=Mesh'c_dukeitems.jetpack2'
	CollisionRadius=+00022.000000
	CollisionHeight=+00020.000000	 
	Mass=+00001.000000
	bUseTriggered=true
	bClientUse=true
	bNotifyUnUsed=true
	bProjTarget=true
	DrawType=DT_Mesh
	bNoDamage=true
	DetonateTime=45
	DefuseTime=15
	TickSound=sound'a_generic.keypad.KeyPdType59'
}
