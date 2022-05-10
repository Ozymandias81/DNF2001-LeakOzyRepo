/*-----------------------------------------------------------------------------
	JetpackAccessory
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class JetpackAccessory extends MountableDecoration;

#exec OBJ LOAD FILE=..\Sounds\a_transport.dfx

var SoftParticleSystem HoverEffect;
var SoftParticleSystem MainBurn;
var SoftParticleSystem RightBurn;
var SoftParticleSystem LeftBurn;
var bool			   bJetpackOn, bBurnRight, bBurnLeft, bBurnOn;
var sound			   JetpackOnSound, JetpackOffSound;

replication 
{
	reliable if ( Role==ROLE_Authority )
		bJetpackOn, bBurnOn, bBurnRight, bBurnLeft;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	HoverEffect = spawn( class'dnJetpackFX_HoverRings', Self,, Location, Rotation );
	HoverEffect.SetPhysics( PHYS_MovingBrush );
	HoverEffect.MountType		= MOUNT_MeshSurface;
	HoverEffect.MountMeshItem	= 'JetFlame';
	HoverEffect.AttachActorToParent( Self, false, false );	

	MainBurn = spawn( class'dnJetpackFX_HoverBurn', Self,, Location, Rotation );
	MainBurn.SetPhysics( PHYS_MovingBrush );
	MainBurn.MountType = MOUNT_MeshSurface;
	MainBurn.MountMeshItem = 'JetFlame';
	MainBurn.AttachActorToParent( Self, false, false );

	RightBurn = spawn( class'dnJetpackFX_DirectBurn', Self,, Location, Rotation );
	RightBurn.SetPhysics( PHYS_MovingBrush );
	RightBurn.MountType = MOUNT_MeshSurface;
	RightBurn.MountMeshItem = 'ExhaustR';
	RightBurn.AttachActorToParent( Self, false, false );

	LeftBurn = spawn( class'dnJetpackFX_DirectBurn', Self,, Location, Rotation );
	LeftBurn.SetPhysics( PHYS_MovingBrush );
	LeftBurn.MountType = MOUNT_MeshSurface;
	LeftBurn.MountMeshItem = 'ExhaustL';
	LeftBurn.AttachActorToParent( Self, false, false );

	SetTimer( 0.2, true );
}

simulated function Timer( optional int TimerNum )
{
	local Pawn POwner;
	local vector TestAccel;
	local rotator Rot, PRot;
	local int RotDiff, NormYaw;

	bBurnLeft  = false;
	bBurnRight = false;

	if ( Owner == None )
		return;

	// See if we need to activate a burn.
	if ( Owner.bIsPawn )
	{
		POwner = Pawn(Owner);

		TestAccel = PlayerPawn(Owner).Acceleration;
		TestAccel.Z = 0;

		if ( VSize(TestAccel) > 0 )
		{
			Rot = rotator( normal( TestAccel ) );

			if ( Owner.IsA('PlayerPawn') )
				PRot = PlayerPawn(Owner).ViewRotation;
			else
				PRot = POwner.Rotation;

			Rot = normalize(Rot) - normalize(PRot);
			Rot = normalize(Rot);
			NormYaw = Rot.Yaw;

			if ( (NormYaw > -10) && (NormYaw < 10) )
			{
				// Forward.
				bBurnRight = true;
				bBurnLeft  = true;
			}
			else if ( (NormYaw < -32760) || (NormYaw > 32760) )
			{
				// Backward.
				bBurnRight = true;
				bBurnLeft = true;
			}
			else if ( NormYaw > 0 )
			{
				// Left.
				bBurnLeft = true;
			}
			else if ( NormYaw < 0 )
			{
				// Right.
				bBurnRight = true;
			}
		}
	}
}

simulated event Tick( float DeltaTime )
{
	// Enable/Disable effects
	RightBurn.Enabled   = bBurnRight && bJetpackOn;
	LeftBurn.Enabled    = bBurnLeft  && bJetpackOn;
	MainBurn.Enabled    = bBurnOn    && bJetpackOn;
	HoverEffect.Enabled = bJetpackOn && !bBurnOn;
}

function JetpackDown()
{
	bJetpackOn = true;
	bBurnOn    = true;
}

function JetpackUp()
{
	bBurnOn    = false;
}

function JetpackOff()
{
	bJetpackOn = false;
	bBurnOn    = false;
	PlaySound( JetpackOffSound, SLOT_Interact );
}

function JetpackOn()
{
	bJetpackOn = true;
	bBurnOn    = false;
	PlaySound( JetpackOnSound, SLOT_Interact );
}

simulated function Destroyed()
{
	LeftBurn.Destroy();
	RightBurn.Destroy();
	MainBurn.Destroy();
	HoverEffect.Destroy();
	Super.Destroyed();
}

defaultproperties
{
	mesh=mesh'c_dukeitems.jetpack2'
	MountMeshItem=chest
	MountType=MOUNT_MeshBone
	MountAngles=(Pitch=-10000)
	RemoteRole=ROLE_SimulatedProxy
	JetpackOnSound=sound'a_transport.JetpackOn'
	JetpackOffSound=sound'a_transport.JetpackOff'	
}