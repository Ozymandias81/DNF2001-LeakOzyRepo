/*=============================================================================
	AIJetskiCarcass
	Author: Jess Crable

	Carcass for Jetskis.
=============================================================================*/
class AIJetskiCarcass extends CreaturePawnCarcass;

#exec OBJ LOAD FILE=..\Sounds\a_transport.dfx

var JetskiTorpedo MyTorpedo;
var bool bCanDestroy;
var int DestroyTime;
var dnBloodFX_SmokeTrail_Medium MySmokeTrail;
var float SoundDampening;
var bool bAlreadySplashed;
var int Count;

simulated function ZoneChange( Zoneinfo NewZone )
{

	if( NewZone.bWaterZone )
	{
		Enable( 'Tick' );
		if( !bAlreadySplashed && Count > 0 )
		{
			if( FRand() < 0.5 )
				PlaySound( sound'a_Transport.JetskiSplash1', SLOT_None,,, SoundDampening * 0.8 );
			else
				PlaySound( sound'a_Transport.JetskiSplash2', SLOT_None,,, SoundDampening * 0.8 );
			Spawn( class'dnJetski_Splash1' );
			Mesh = None;
			bAlreadySplashed = true;
		}
		Count++;
		if( bCanDestroy )
		{
			Destroy();
			return;
		}
	}
	buoyancy = RandRange( 100, 750 );
	SetPhysics( PHYS_Falling );
	bRotateToDesired = true;
	bFixedRotationDir=False;
	DesiredRotation = RotRand();
}

function PostBeginPlay()
{
	SetTimer( DestroyTime, false );
	MySmokeTrail = Spawn( class'dnBloodFX_SmokeTrail_Medium', self );
	MySmokeTrail.AttachActorToParent( self, false, false );
	MySmokeTrail.SetPhysics( PHYS_MovingBrush );
	MySmokeTrail.MountType = MOUNT_Actor;
	MySmokeTrail.VisibilityRadius = 8000;
}

function Timer( optional int TimerNum )
{
	bCanDestroy = true;
}

function AddVelocity( vector NewVelocity)
{
	SetPhysics(PHYS_Falling);
	if ( (Velocity.Z > 380) && (NewVelocity.Z > 0) )
		NewVelocity.Z *= 0.5;
	Velocity += NewVelocity;
}

function HitWall( vector HitNormal, actor HitWall )
{
	Destroy();
}



function Destroyed()
{
	if( MyTorpedo != None )
		MyTorpedo.Destroy();
	if( MySmokeTrail != None )
		MySmokeTrail.Destroy();
}


/*function ZoneChange( ZoneInfo NewZone )
{
	if( NewZone.bWaterZone )
	{
		broadcastmessage( "CARC ZONECHANGE" );
		SetPhysics( PHYS_Falling );
		Velocity.Z = 10550;
	}
}
*/

defaultproperties
{
     DestroyTime=3.000000
     CollisionHeight=1.0
     CollisionRadius=16.0
     bBlockPlayers=true
     Mass=100.000000
     Buoyancy=1020.0
	 Mesh=DukeMesh'c_vehicles.jetski'
     Physics=PHYS_Falling
     ItemName="Jetski"
	 bRandomName=false
	 bCanHaveCash=false
 	 bSearchable=false
	 bNotTargetable=true
 	 MasterReplacement=None
	 RotationRate=(Pitch=75000,Yaw=75000,Roll=75000)
}
