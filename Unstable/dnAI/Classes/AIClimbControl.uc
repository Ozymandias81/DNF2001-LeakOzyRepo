class AIClimbControl extends Info;

var() class<HumanNPC>	SpawnClass				?( "HumanNPC class to spawn in." );
var() float				DelayAfterTrigger		?( "Optional delay after triggered." );
var() name				SpawnEvent				?( "Optional event called when HumanNPC is spawned." );
var() class<Weapon>		NPCWeapons[ 9 ]			?( "Override default weapons given to this NPC." );
var() int				NPCPrimaryAmmo[ 9 ];
var() int				NPCAlternateAmmo[ 9 ];
var() bool				bUseWeaponOverride		?( "Use the weapons defined here rather than in the NPC class." );
var() float				JumpHeightFromFloor		?( "Height above the floor that this HumanNPC will jump." );
var() name				AutoHateTag				?( "HumanNPC will auto-hate the actor with this tag when done climbing." );
var() name				AllAnimClimb			?( "Animation to play (on channel ALL) for climbing. Use A_RepelRopeDownA or A_ClimbRopeDown." );
var() float				ClimbSpeed				?( "Scale regular groundspeed by how much? 0.33 is good for climbing. 0.66 for sliding." );
var() name				NPCEvent				?( "Set the event of the HumanNPC spawned here." );
var() bool				bRetractRope			?( "Retract rope when HumanNPC is done climbing." );
var() bool				bMultipleTriggers		?( "Can be triggered multiple times." );
var() bool				bSnatched				?( "This HumanNPC is snatched and visibly snatched." );
var() name				ControlTag				?( "Tag of CombatController to be associated with this (Grunt Only)." );

var dnDecoration		MyRope;
var HumanNPC			Climber;
var PawnClimber			TempClimber;
var vector				FloorLocation;
var AIRopeAnchor		MyAnchor;
var bool				bTriggered;

function Trigger( actor Other, Pawn EventInstigator )
{
	local HumanNPC Test;

	if( bMultipleTriggers && bTriggered )
		return;

	if( DelayAfterTrigger <= 0 )
	{
		// log( "Calling SpawnClimber now" );
		SpawnClimber();
	}
	else
	{
		// log( "Setting Timer for "$DelayAfterTrigger );
		SetTimer( DelayAfterTrigger, false );
	}
	bTriggered = true;
}

function vector GetFloorLocation()
{
	local Actor HitActor;
	local vector HitNormal, HitLocation;
	local AICoverController Test;

	HitActor = Trace( HitLocation, HitNormal, Location + vect( 0, 0, -24000 ), Location, true );

	return HitLocation;
}

function Timer( optional int TimerNum )
{
	// log( "Timer called. Calling SpawnClimber" );
	SpawnClimber();
}

function AnchorRope( vector AnchorLocation )
{
	MyAnchor = Spawn( class'AIRopeAnchor',,, FloorLocation + ( vect( 0, 0, 1 ) ) );
}

function SpawnClimber()
{
	local int i;
	local actor TempActor;

	Climber = Spawn( SpawnClass, self,, Location + vect( 0, 0, -32 ), Rotation );
	Climber.MyClimbControl = self;
	Climber.bSnatched = bSnatched;
	Climber.bVisiblySnatched = bSnatched;
	Climber.bUseSnatchedEffects = bSnatched;
	if( ControlTag != '' && Grunt( Climber ) != None )
	{
		//Grunt( Climber ).MyCombatController = AICombatController( FindActorTagged( class'AICombatController', CombatControlTag ) );
		Grunt( Climber ).ControlTag = ControlTag;
		Grunt( Climber ).InitializeController();
	}

	if( NPCEvent != '' )
		Climber.Event = NPCEvent;

	FloorLocation = GetFloorLocation();

	Climber.GotoState( 'Repelling' );

	if( Grunt( Climber ) != None && bUseWeaponOverride )
	{
		for( i = 0; i <= 8; i++ )
		{
			if( NPCWeapons[ i ] != None )
				Grunt( Climber ).AddWeaponFromFactory( NPCWeapons[ i ], NPCPrimaryAmmo[ i ], NPCAlternateAmmo[ i ] );
			else break;
		}
	}

	if( SpawnEvent != '' )
	{
		foreach allactors( class'Actor', TempActor, SpawnEvent )
			TempActor.Trigger( self, Climber );
	}
}

function Tick( float DeltaTime )
{
	if( Climber != None || TempClimber != None || MyAnchor != None )
		EvalBones();
}

function RetractRope()
{
	TempClimber = Spawn( class'PawnClimber', self,, Climber.Location );
	TempClimber.MyRope = MyRope;
	TempClimber.Dist = Location - TempClimber.Location;
	TempClimber.Controller = self;
	TempClimber.GotoState( 'Climbing' );
}

simulated function EvalBones()
{
    local int bone;
    local MeshInstance minst, endMinst;
	local vector t, tempOfs, StretchMeshOffset, StretchWorldOffset;
	local rotator StretchOrient;
	local actor StretchEnd;
	local name StretchBoneName;
	local name StretchEndTag;
	local Actor LocalClimber;

	minst = MyRope.GetMeshInstance();

	if( TempClimber != None )
		LocalClimber = TempClimber;
	else
		LocalClimber = Climber;

	if( MyAnchor != None )
		LocalClimber = MyAnchor;

	StretchBoneName = 'End';
	
	if (StretchBoneName=='None')
		return;
	
	StretchEnd = LocalClimber;

	bone = minst.BoneFindNamed(StretchBoneName);
	if (bone==0)
		return;
	tempOfs = StretchWorldOffset;
	endMinst = LocalClimber.GetMeshInstance();
	StretchMeshOffset = vect(13,0,0);
	if (endMinst!=None)
		tempOfs += endMinst.MeshToWorldLocation(StretchMeshOffset) - LocalClimber.Location;
	t = minst.WorldToMeshLocation(LocalClimber.Location + tempOfs);
	minst.BoneSetTranslate(bone, t, true);
}

DefaultProperties
{
     SpawnClass=class'dnai.RandomSWAT'
     bDirectional=true
     ClimbSpeed=0.620000
     AllAnimClimb=A_RepelRopeDownA
     bRetractRope=true
     bSnatched=true
}