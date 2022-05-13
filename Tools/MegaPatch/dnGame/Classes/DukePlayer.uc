/*-----------------------------------------------------------------------------
	DukePlayer, Duke Nukem Forever's PlayerPawn
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class DukePlayer extends PlayerPawn
	config(User);

#exec OBJ LOAD FILE=..\Textures\hud_effects.dtx
#exec OBJ LOAD FILE=..\Meshes\c_characters.dmx
#exec OBJ LOAD FILE=..\Sounds\a_ambient.dfx
#exec OBJ LOAD FILE=..\Sounds\a_dukevoice.dfx
#exec OBJ LOAD FILE=..\Sounds\a_generic.dfx
#exec OBJ LOAD FILE=..\Sounds\a_inventory.dfx
#exec OBJ LOAD FILE=..\sounds\a_impact.dfx
#exec OBJ LOAD FILE=..\sounds\dnsweapn.dfx

#exec AUDIO IMPORT FILE="..\Sounds\scorehit.wav" NAME="HitNotificationSound" 

var string		            DefaultSkinName;
var string		            DefaultPackage;

// EMP sound
var(Sounds) sound			EMPDegaussSound;
var(Sounds) sound			EMPStaticSound;

// Chat sound
var(Sounds) sound			ChatBeepSound;

// Swallowing Food
var float					SwallowTime;

var bool                    bLastJumpAlt;
var globalconfig bool       bNoMatureLanguage;
var globalconfig bool       bNoVoiceMessages; // don't receive any voice messages
var bool                    b3DSound;

var NavigationPoint         StartSpot; //where player started the match

// Heat vision overlay
var texture                 HeatVisionOverlay;
var string					HeatVisionOverlayString;
var texture                 HeatVisionGlow;
var string					HeatVisionGlowString;

// Night vision overlay
var texture                 NightVisionOverlay;
var string					NightVisionOverlayString;
var texture                 NightVisionGlow;
var string					NightVisionGlowString;

// Zoom vision overlay
var texture                 ZoomVisionSubtleStatic;
var string					ZoomVisionSubtleStaticString;
var texture                 ZoomVisionGlow;
var string					ZoomVisionGlowString;
var texture                 ZoomVisionOverlay;
var string					ZoomVisionOverlayString;

// EMP
var texture					HeavyVisionStatic[10];
var string					HeavyVisionStaticString[10];
var smackertexture			OverloadBootStart;
var string					OverloadBootStartString;
var smackertexture			OverloadBootLoop;
var string					OverloadBootLoopString;
var smackertexture			OverloadGPFStart;
var string					OverloadGPFStartString;
var smackertexture			OverloadGPFLoop;
var string					OverloadGPFLoopString;
var smackertexture			DegaussOverlay;
var string					DegaussOverlayString;
var texture					OverloadDegaussing;
var string					OverloadDegaussingString;
var texture					OverloadOverload;
var string					OverloadOverloadString;
var bool					bGPFStart, bFlash, bDegauss;
var int						RebootPhase;
var float					EmpTime, FlashTime, PostDegaussFade;

// Rain
var smackertexture			LensWaterLight;
var string					LensWaterLightString;
var smackertexture			LensWaterHeavy;
var string					LensWaterHeavyString;
var float					RainFade;
var float					NextThunderTime;
var sound					ThunderFar[2];
var sound					ThunderMed[2];
var bool					bRainOverlay;
var bool					bCanHearThunder;
var SoftParticleSystem		Mist, OldMist;
var SoftParticleSystem		Rain, OldRain;
var(Sounds) sound			AmbientRain;
var(Sounds) sound			AmbientRainGusty;

var DukeHand				DukesHand;
var bool					DrawHand;
var dnThirdPersonShield		ThirdPersonShield;

// Duke Voice
var unbound int				CurrentMirrorSound;
var unbound float			NextMirrorEgoTime;
var unbound float			NextTalkTime;

var dnCashMan				CashMan;

var name                    HitBones[12];

var float					JetpackTime;
var float					LastJetpackTime;
var float					JetpackMax;
var float                   JetPackStateTime;
var EJetpackState			DesiredJetpackState;
var int                     OldHitCounter, HitCounter;
var sound					HitNotificationSounds[8];
var localized string 		HitNotificationNames[8];
var globalconfig int		HitNotificationIndex;
var int                     numHitNotificationNames;

// Stepping on guys.
var Pawn					SmashPawn;

// Piss
var SoftParticleSystem		DukePiss;
var	sound					ZipperSound, PissSound;
var string					MyClassName;

// SOS calling stuff
enum ESOSStatus
{
	SOS_Done,
	SOS_IncomingCall,
	SOS_AnsweringCallFadingOut,
	SOS_AnsweringCall,
	SOS_AnsweringCallFadingIn,
	SOS_CallInProgress,
	SOS_EndingCallFadingOut,
	SOS_EndingCall,
	SOS_EndingCallFadingIn,
};

var ESOSStatus				SOSStatus;
var SOSTrigger				SOSInstigator;
var float					IncomingCallTime;
var vector					CurrentFlashScale;
var float					NextRingTime;
var texture					IncomingCallTexture;
var sound					PhoneRingOutSound;
var string					SOSFreqString;

var string					LastKilledByPlayerName;
var texture					LastKilledByPlayerIcon;

replication
{
	reliable if ( Role==ROLE_Authority && bNetOwner )
		HitCounter;
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		ClientPlayTakeHit;
	reliable if ( Role == ROLE_Authority )
		DoAirHud;

	// Things the client should send to the server.
	reliable if ( Role < ROLE_Authority )
		ServerUpdateAmmoMode, ServerQuickKick, ServerSmashTheGuy;
}

/*-----------------------------------------------------------------------------
	Object / Initialization
-----------------------------------------------------------------------------*/

exec function ToggleGruntSpeech()
{
	if( Level.Game.IsA( 'dnSinglePlayer' ) )
		dnSinglePlayer( Level.Game ).bGruntSpeechDisabled = !dnSinglePlayer( Level.Game ).bGruntSpeechDisabled;
	if( !dnSinglePlayer( Level.Game ).bGruntSpeechDisabled )
		BroadcastMessage( "Grunt speech is now on." );
	else
		BroadcastMessage( "Grunt speech is now off." );
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

//	if ( Level.NetMode != NM_DedicatedServer )
//		Shadow = Spawn(class'PlayerShadow',self);

	b3DSound = bool(ConsoleCommand("get ini:Engine.Engine.AudioDevice Use3dHardware"));
	RegisterSequenceGroups();

	DukesHand = spawn( class'DukeHand', Self );    
	SOSStatus=SOS_Done;
}

function SpawnThirdPersonShield()
{
    if ( Role == ROLE_Authority )
    {
        ThirdPersonShield = spawn( class'dnThirdPersonShield', self );    
        ThirdPersonShield.AttachActorToParent( self, false, false );
        ThirdPersonShield.bHidden = true;
    }
}

function RegisterSequenceGroups()
{
	SetAnimGroup('A_IdleStandActive',   'Waiting');
	SetAnimGroup('A_IdleStandInactive', 'Waiting');
	SetAnimGroup('A_IdleStandInactive2','Waiting');
	SetAnimGroup('A_IdleStandWeapon',   'Waiting');
}

/*-----------------------------------------------------------------------------
	Audio
-----------------------------------------------------------------------------*/

simulated function ClientPlaySound(sound ASound, optional bool bInterrupt, optional bool bVolumeControl )
{	
	local actor SoundPlayer;
	local int Volume;

	if ( b3DSound )
		Volume = 1;
	else
		Volume = 4;

	LastPlaySound = Level.TimeSeconds;	// so voice messages won't overlap
	if ( ViewTarget != None )
		SoundPlayer = ViewTarget;
	else
		SoundPlayer = self;

	Volume = 1;
	if ( Volume == 0 )
		return;
	SoundPlayer.PlaySound(ASound, SLOT_None, 1.0, bInterrupt);
	if ( Volume == 1 )
		return;
	SoundPlayer.PlaySound(ASound, SLOT_Interface, 1.0, bInterrupt);
	if ( Volume == 2 )
		return;
	SoundPlayer.PlaySound(ASound, SLOT_Misc, 1.0, bInterrupt);
	if ( Volume == 3 )
		return;
	SoundPlayer.PlaySound(ASound, SLOT_Talk, 1.0, bInterrupt);
}

function NearMiss()
{
	// We nearly hit a player!
	spawn( class'BulletWhiz', Self );
}


/*-----------------------------------------------------------------------------
	Client Side Weapons
-----------------------------------------------------------------------------*/

function ServerUpdateAmmoMode( int NewAmmoMode )
{
	if ( (Weapon != None) && (Weapon.IsA('dnWeapon')) )
		dnWeapon(Weapon).UpdateAmmoMode( NewAmmoMode );
}

function bool JetpackReady()
{
	local Inventory Inv;
	local class<Inventory> InvClass;

	InvClass = class<Inventory>( DynamicLoadObject( "dnGame.Jetpack", class'Class' ) );
	Inv = FindInventoryType( InvClass );

	return ( Inv.Charge > 0 && Physics != PHYS_Falling );
}

function JetpackDown()
{
	local Inventory Inv;
	local class<Inventory> InvClass;

	// We pressed jump while we are wearing a jetpack.
	Super.JetpackDown();

	InvClass = class<Inventory>( DynamicLoadObject( "dnGame.Jetpack", class'Class' ) );
	Inv = FindInventoryType( InvClass );
	if ( Inv != None )
		Inv.SpecialAction( 0 );
}

function JetpackUp()
{
	local Inventory Inv;
	local class<Inventory> InvClass;

	// We let go of jump while we are wearing a jetpack.
	Super.JetpackUp();

	InvClass = class<Inventory>( DynamicLoadObject( "dnGame.Jetpack", class'Class' ) );
	Inv = FindInventoryType( InvClass );
	if ( Inv != None )
		Inv.SpecialAction( 1 );
}


function JetpackOff()
{
	local Inventory Inv;
	local class<Inventory> InvClass;

	// Jetpack turned off
	Super.JetpackOff();

	InvClass = class<Inventory>( DynamicLoadObject( "dnGame.Jetpack", class'Class' ) );
	Inv = FindInventoryType( InvClass );
	if ( Inv != None )
		Inv.SpecialAction ( 2 );
}

function JetpackOn()
{
	local Inventory Inv;
	local class<Inventory> InvClass;

	// Jetpack turned on
	Super.JetpackOn();

	InvClass = class<Inventory>( DynamicLoadObject( "dnGame.Jetpack", class'Class' ) );
	Inv = FindInventoryType( InvClass );
	if ( Inv != None )
		Inv.SpecialAction ( 3 );
}


/*-----------------------------------------------------------------------------
	Bump for Smashing
-----------------------------------------------------------------------------*/

simulated event Bump( Actor Other )
{
	local vector ViewVector, LookAtPoint;
	local rotator DesiredView;

	if ( (Other != None) && (Other != Self) && Other.bIsPawn )
	{
		StepOnPawn( Other );
		GetSteppedOnByPawn( Other );
	}

	Super.Bump( Other );
}

simulated function StepOnPawn( Actor Other )
{
	local vector ViewVector, LookAtPoint;
	local rotator DesiredView;

	// Check to see if we get bumped by a shrunken pawn.
	if ( (GetPostureState() == PS_Standing) &&
		 ((Pawn(Other).GetPostureState() == PS_Standing) || (Pawn(Other).GetPostureState() == PS_Crouching)) &&
		 !Shrunken() && Pawn(Other).bFullyShrunk && !bEatInput &&
		 (SmashPawn == None) && (IsLocallyControlled() || (Role == ROLE_Authority)) )
	{
		// We bumped a shrunken pawn.  If he's in front of us, smash him.
		ViewVector = vector(Rotation);
		ViewVector.z = 0;
		if ( Normal(Other.Location - Location) dot ViewVector >= 0 )
		{
			// Store some information to smash the guy with.
			SmashPawn = Pawn(Other);

			// Put the other guy in the frozen state.
			Pawn(Other).PrepareForStomp( Self );
			Pawn(Other).SetControlState( CS_Frozen );
			Pawn(Other).PlayAnim( 'A_DontStepOnMe1' );

			Velocity = vect(0,0,0);
			Acceleration = vect(0,0,0);

			if ( IsLocallyControlled() )
			{
				// They are in front of us.  Rotate us to look at 'em.
				LookAtPoint = Other.Location;
				LookAtPoint.Z -= 20;
				DesiredView = rotator( LookAtPoint - Location );
				RotateViewTo( DesiredView, 0.25 );
				SetCallbackTimer( 0.25, false, 'SmashTheGuy' );

				// Smash!
				RotateViewCallback = '';
				bEatInput = true;
			}
		}
	}
}

simulated function GetSteppedOnByPawn( Actor Other )
{
	local vector ViewVector, LookAtPoint;
	local rotator DesiredView;

	// Check to see if we are shrunken and were bumped by a non-shrunken pawn.
	if ( ((GetPostureState() == PS_Standing) || (GetPostureState() == PS_Crouching)) &&
		 (Pawn(Other).GetPostureState() == PS_Standing) &&
		 bFullyShrunk && !Pawn(Other).bFullyShrunk && 
		 !RotateToDesiredView && IsLocallyControlled() )
	{
		// We are shrunk and may be getting stepped on.
		if ( Other.IsA('HumanNPC') )
		{
			// Handle humans here.
		}
		else if ( Other.IsA('PlayerPawn') )
		{
			// Crap, a player is stepping on us.
			ViewVector = vector(Other.Rotation);
			ViewVector.z = 0;
			if ( Normal(Location - Other.Location) dot ViewVector >= 0 )
			{
				// We are in front of them, so they are a-stompin'.
				// Rotate us to look at our doom.
				DesiredView = rotator( Other.Location - Location );
				RotateViewTo( DesiredView, 0.25 );
				SetCallbackTimer( 0.25, false, 'GettingSmashed' );

				// No callback.
				RotateViewCallback = '';
			}
		}
	}
}

// Callback that is called when we have rotated to view our killer.
simulated function GettingSmashed()
{
	RotateToDesiredView = false;
}

// Callback that is called when we have rotated to view our victim.
simulated function SmashTheGuy()
{
	RotateToDesiredView = false;
	if ( SmashPawn != None )
	{
		SetCallbackTimer( 0.1, false, 'ServerSmashTheGuy' );
		SetCallbackTimer( 0.3, false, 'DoneSmashing' );
		QuickKick( true, true );
	}
}

// Client is asking if there is somebody to smash.
// Used with the MightyFoot FootSmash notificatons.
simulated function ServerSmashTheGuy()
{
	if ( SmashPawn != None )
	{
		SmashPawn.Died( Self, class'BootSmashDamage', SmashPawn.Location );
		SmashPawn = None;
	}
}

// Called when finished smashing to release the player's view.
simulated function DoneSmashing()
{
	SmashPawn = None;
	bEatInput = false;
}


/*-----------------------------------------------------------------------------
	Network
-----------------------------------------------------------------------------*/
	
function PreSetMovement()
{
	bCanJump = true;
	bCanWalk = true;
	bCanSwim = true;
	bCanFly = false;
	bCanOpenDoors = true;
	bCanDoSpecial = true;
}

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID)
{
	if ( bNoVoiceMessages )
		return;

	Super.ClientVoiceMessage(Sender, Recipient, messagetype, messageID);
}

function SendGlobalMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait)
{
	if ( Level.TimeSeconds - OldMessageTime < 5 )
		return;

	SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID, 'GLOBAL');
}


function SendTeamMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait)
{
	if ( Level.TimeSeconds - OldMessageTime < 10 )
		return;

	SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID, 'TEAM');
}




/*-----------------------------------------------------------------------------
	Animation Core Functions
-----------------------------------------------------------------------------*/

function name GetApproximateHitBone( vector HitLoc )
{
    local int           bone, closestBone, i;
    local vector        v, delta;
    local float         DotProduct, closestDist;
    local MeshInstance  minst;

    closestDist = 99999999;
    minst = GetMeshInstance();

    if ( minst == None )
        return 'None';

    // Go through all the bones in HitBones array and determine closest with a dotProduct
    for ( i=0; i<ArrayCount( HitBones ); i++ )
    {             
        bone = minst.BoneFindNamed( HitBones[i] );
	    if ( bone != 0 )
		{
		    v  = minst.BoneGetTranslate( bone, true, false );
            v  = minst.MeshToWorldLocation( v );

            delta       = v - HitLoc;
            DotProduct  = delta dot delta;

            if ( DotProduct < closestDist )
            {
                closestDist = DotProduct;
                closestBone = i;
            }
        }
    }
    return HitBones[closestBone];
}

function PlayDying( class<DamageType> DamageType, vector HitLoc )
{
	local EPawnBodyPart BodyPart;

	PlayDyingSound();

    if ( !Level.GRI.bMeshAccurateHits )
    {
        // If the game doesn't allow for mesh accurate hits, then try to figure out which bone got hit.
        BodyPart = GetPartForBone( GetApproximateHitBone( HitLoc ) );
    }
    else
    {
    	BodyPart = GetPartForBone( DamageBone );
    }

    PlayDeath( BodyPart, DamageType );
}

function bool InFrontOfWall()
{
	local actor HitActor;
	local vector HitLocation, HitNormal;

	HitActor = Trace( HitLocation, HitNormal, Location + ( vector( Rotation ) * -48 ) + vect( 0, 0, 16 ), Location, true );

	if( HitActor != None && HitActor.IsA( 'LevelInfo' ) )
	{
		return true;
	}
	return false;
}

function bool FacingWall()
{
	local actor HitActor;
	local vector HitLocation, HitNormal;
	local vector CollisionOffset;

	HitActor = Trace( HitLocation, HitNormal, Location + ( vector( Rotation ) * 48 ), Location, true );

	if( HitActor != None && HitActor.IsA( 'LevelInfo' ) )
	{
		CollisionOffset.X = -0.38 * VSize( Location - HitLocation );
		PrePivot = CollisionOffset;
		return true;
	}
}

function PlayDeath( EPawnBodyPart BodyPart, class<DamageType> DamageType )
{
	local name DeathSequence;
	local MeshInstance minst;
	local int chance;

	PlayTopAnim('None');
	PlayBottomAnim('None');
    PlaySpecialAnim( 'None' );
    
	if ( Physics == PHYS_Jetpack )
	{
		PlayAllAnim( 'A_FlyAir_B',, 0.1, true );
		return;
	}

	// Drowned
    if ( ClassIsChildOf(DamageType, class'DrowningDamage') )
	{
		PlayAllAnim( 'A_Death_Choke',, 0.1, false );
		return;
	}

    // Crouch death
    if( GetPostureState() == PS_Crouching )
	{
		PlayAllAnim( 'A_Death_KneelA',, 0.12, false );
		return;
	}

    // Wall death
    if( InFrontOfWall() )
	{
		if( FRand() < 0.5 )
			PlayAllAnim( 'A_Death_HitWall1',, 0.1, false );
		else 
			PlayAllAnim( 'A_Death_HitWall2',, 0.1, false );
		return;
	}

	if( FacingWall() )
	{
		PlayAllAnim( 'A_Death_HitWall_F',, 0.1, false );
		return;
	}

	// Flame
	if ( ClassIsChildOf( DamageType, class'FireDamage' ) )
	{
		PlayAllAnim( 'A_Death_BurnA',, 0.1, false );
		return;
	}

	// Explosive damage
	if ( ClassIsChildOf( DamageType, class'ExplosionDamage' ) )
	{
		chance = Rand( 2 );

		switch ( chance )
		{
			case 0:
				PlayAllAnim( 'A_Death_SpinLeft',, 0.1, false );
				break;
			case 1:
				PlayAllAnim( 'A_Death_FlipChest',, 0.1, false );
				break;
		}
		return;
	}

	// Shotgun
	if ( ClassIsChildOf( DamageType, class'ShotgunDamage' ) )
	{
		chance = Rand( 3 );

		switch ( chance )
		{
			case 0:
				PlayAllAnim( 'A_Death_FlipChest',, 0.1, false );
				break;
			case 1:
				PlayAllAnim( 'A_Death_HitLShoulder',, 0.1, false );
				break;
			case 2:
				PlayAllAnim( 'A_Death_HitRShoulder',, 0.1, false );
				break;
		}
		return;
	}

	switch(BodyPart)
	{
	    case BODYPART_Head:    	    DeathSequence = 'A_Death_HitHead';      	break;
	    case BODYPART_Chest:		DeathSequence = 'A_Death_HitChest';			break;
	    case BODYPART_Stomach:		DeathSequence = 'A_Death_HitStomach';		break;
	    case BODYPART_Crotch:		DeathSequence = 'A_Death_Fallstraightdown';	break;
	    case BODYPART_ShoulderLeft: DeathSequence = 'A_Death_HitLShoulder';		break;
	    case BODYPART_ShoulderRight:DeathSequence = 'A_Death_HitRShoulder';		break;			
	    case BODYPART_HandLeft:		DeathSequence = 'A_Death_HitLShoulder';		break;
	    case BODYPART_HandRight:	DeathSequence = 'A_Death_HitRShoulder';		break;
	    case BODYPART_KneeLeft:		DeathSequence = 'A_Death_Hitback1';			break;
	    case BODYPART_KneeRight:	DeathSequence = 'A_Death_Hitback1';			break;
	    case BODYPART_FootLeft:		DeathSequence = 'A_Death_Hitback2';			break;
	    case BODYPART_FootRight:	DeathSequence = 'A_Death_Hitback2';			break;
	    case BODYPART_Default:		DeathSequence = 'A_Death_HitStomach';		break;
	}

	PlayAllAnim(DeathSequence,,0.1,false);
}

function PlayDyingSound()
{
	local int rnd;

	if ( HeadRegion.Zone.bWaterZone )
	{
		PlaySound( PlayerReplicationInfo.VoiceType.default.UnderWaterPain, SLOT_Pain,16,,,Frand() * 0.2 + 0.9 );
		return;
	}

	rnd = rand( ArrayCount( PlayerReplicationInfo.VoiceType.default.DeathSounds ) );
	PlaySound( PlayerReplicationInfo.VoiceType.default.DeathSounds[rnd], SLOT_Talk, 16 );
	PlaySound( PlayerReplicationInfo.VoiceType.default.DeathSounds[rnd], SLOT_Pain, 16 );
}

simulated function PlayBeepSound()
{
	PlaySound( ChatBeepSound, SLOT_Interface, 2.0 );
}

function PlayChatting()
{
//	if ( mesh != None )
//		LoopAnim('Chat1', 0.7, 0.25);
}

function CheckBob(float DeltaTime, float Speed2D, vector Y)
{
	local float OldBobTime;
	//local int m,n;

	OldBobTime = BobTime;
	if ( Speed2D < 10 )
		BobTime += 0.2 * DeltaTime;
	else
		BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/GroundSpeed);
	WalkBob = Y * 0.4 * Bob * Speed2D * sin(8 * BobTime);
	AppliedBob = FMin(1, 16 * deltatime) * LandBob + AppliedBob * (1 - FMin(1, 16 * deltatime));
	if ( Speed2D < 10 )
		WalkBob.Z = AppliedBob;
	else
		WalkBob.Z = AppliedBob + 0.3 * Bob * Speed2D * sin(16 * BobTime);
	LandBob *= (1 - 8*Deltatime);
}

//-----------------------------------------------------------------------------
// Sound functions

function ClientPlayTakeHit(vector HitLoc, byte Damage, bool bServerGuessWeapon)
{
	HitLoc += Location;
	if ( bServerGuessWeapon && ((Weapon != None)) )
		return;
	Enable('AnimEnd');
	bAnimTransition = true;
	PlayTakeHit(0.1, HitLoc, Damage);
}	

function PlayGaspSound()
{
	if ( Role != ROLE_Authority )
		return;
	if ( RemainingAir < 2 )
		PlaySound( PlayerReplicationInfo.VoiceType.default.GaspSound, SLOT_Talk, 2.0 );
	else
		PlaySound( PlayerReplicationInfo.VoiceType.default.BreathAgain, SLOT_Talk, 2.0 );
}

//-----------------------------------------------------------------------------
// Animation functions

function bool IsSwimming()
{
    return ( ( GetControlState() == CS_Swimming ) || ( Physics == PHYS_Swimming ) );
}

function PlayGutHit(float tweentime)
{
	if ( (AnimSequence == 'GutHit') || (AnimSequence == 'Dead2') )
	{
		if (FRand() < 0.5)
			TweenAnim('LeftHit', tweentime);
		else
			TweenAnim('RightHit', tweentime);
	}
	else if ( FRand() < 0.6 )
		TweenAnim('GutHit', tweentime);
	else
		TweenAnim('Dead2', tweentime);

}

function PlayHeadHit(float tweentime)
{
	if ( (AnimSequence == 'HeadHit') || (AnimSequence == 'Dead4') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		TweenAnim('HeadHit', tweentime);
	else
		TweenAnim('Dead4', tweentime);
}

function PlayLeftHit(float tweentime)
{
	if ( (AnimSequence == 'LeftHit') || (AnimSequence == 'Dead3') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		TweenAnim('LeftHit', tweentime);
	else 
		TweenAnim('Dead3', tweentime);
}

function PlayRightHit(float tweentime)
{
	if ( (AnimSequence == 'RightHit') || (AnimSequence == 'Dead5') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		TweenAnim('RightHit', tweentime);
	else
		TweenAnim('Dead5', tweentime);
}

function UpperBodyStateChange_ShieldUp( EUpperBodyState OldState ) 
{
    Super.UpperBodyStateChange_ShieldUp( OldState );

	if ( ThirdPersonShield == None )
		return;

    if ( ShieldProtection ) 
	{
    	ThirdPersonShield.bHidden = false;
	}
    else
	{
        ThirdPersonShield.bHidden = true;
	}
}

function UpperBodyStateChange_ShieldDown(EUpperBodyState OldState) 
{
	Super.UpperBodyStateChange_ShieldDown(OldState);
}

function UpperBodyStateChange_ShieldAlert(EUpperBodyState OldState) 
{
	Super.UpperBodyStateChange_ShieldAlert(OldState);
}

function ShieldPlayIdle()
{
	if ( RiotShield(ShieldItem) == None )
		return;
    PlayTopAnim( RiotShield(ShieldItem).IdleAnim,,0.1,true );
}

function ShieldPlayUp()
{
	if ( RiotShield(ShieldItem) == None )
		return;
    PlayTopAnim( RiotShield(ShieldItem).UpAnim,2,0.05 );
}

function ShieldPlayDown()
{
	if ( RiotShield(ShieldItem) == None )
		return;
    PlayTopAnim( RiotShield(ShieldItem).DownAnim,2,0.05 );
}

function PlayHoldOneHanded()
{
    PlayTopAnim( 'T_MultiBombIdle',1, 0.01, true );
}

function PlayHoldTwoHanded()
{
    PlayTopAnim( 'T_GrabBigIdle',1, 0.01, true );
}

function PlayTopWeaponIdle( optional bool force )
{    
	if ( !force && ( (GetControlState() == CS_Swimming) || (Physics == PHYS_Swimming) ) )
        return;

    // Special case for riot shield
    if ( ShieldProtection )
    {
		if ( UpperBodyState == UB_ShieldAlert )
			ShieldPlayIdle();
    }
    else if ( force || ( UpperBodyState == UB_Relaxed ) || ( UpperBodyState == UB_Alert ) )
    {
        // Only change the upper if we're in Relaxed or Alert state as to not interfere with other anims
        if ( Weapon != None )
            PlayWAM( Weapon.IdleAnim );
    }
}

function PlayTopWeaponCrouchIdle( optional bool force )
{
    // Only change the upper if we're in Relaxed or Alert state as to not interfere with other anims    
    if ( force || ( UpperBodyState == UB_Relaxed ) || ( UpperBodyState == UB_Alert ) )
    {
        //Log( "..PlayTopWeaponCrouchIdle" );       
        if ( Weapon != None )
            PlayWAM( Weapon.CrouchIdleAnim );
    }
}

function PlayToWaiting( optional float TweenTime )
{
    //Log( "PlayToWaiting" );

	if( TweenTime == 0.0 )
		TweenTime = 0.1;

	if ( !bIsTurning )
        PlayBottomAnim('None');

	if ( (GetControlState() == CS_Swimming) || (Physics == PHYS_Swimming) )
	{
		PlayAllAnim('A_SwimStroke',,TweenTime,true);
	}
	else
	{
        PlayAllAnim('A_IdleStandActive',,0.5,true);
        PlayTopWeaponIdle();
    }
}

function PlayWaiting()
{
	local float IdleChance;

    if ( bIsTyping )
	{
		PlayChatting();
		return;
	}

    // If we're not turning, then clear out bottom anim
    if ( !bIsTurning )
    {
        PlayBottomAnim('None');
    }

	// Play the right animation.
	if ( (GetControlState() == CS_Swimming) || (Physics == PHYS_Swimming) )
	{		
		PlayAllAnim('A_SwimStroke',,0.1,true);
	}
    else
    {
        PlayAllAnim('A_IdleStandActive',,0.1,true);
        PlayTopWeaponIdle();
	}
}

function PlayToWalking()
{
    //Log( "PlayToWalking" );
    PlayBottomAnim('None');
    PlayWalking();
}

function PlayWalking()
{
    //Log( "PlayWalking" );
	PlayAllAnim('A_WalkWeapon',,0.1,true);
    PlayTopWeaponIdle();
}

function PlayBackpeddle()
{
    //Log( "PlayBackPeddle" );
    PlayAllAnim('A_BackPeddle',,0.1,true); 
    PlayTopWeaponIdle();    
}

function PlayToRunning()
{	
    //Log( "PlayToRunning" );
	PlayBottomAnim('None');
	PlayRunning();
}

function PlayRunning()
{
	//Log( "PlayRunning" );
    if ( bBackPedaling )
    {
        PlayBackpeddle();
    }
	else 
	{	        
        if ( Weapon != None )
        {
            if ( !PlayWAM( Weapon.RunAnim ) )
            {
                // If weapon has no run anim, then play the A_Run anim
                PlayAllAnim('A_Run',,0.1,true);
            }
        }
        else
        {
            PlayAllAnim('A_Run',,0.1,true);
        }
       
        // then, put the weapon's hold animation on the upper body if it exists
        PlayTopWeaponIdle();
	}
}

function PlaySwimming( optional ESwimDepth sd )
{
    //Log( "PlaySwimming" );
    if ( sd == Swim_None )
    {
        if ( HeadRegion.Zone.bWaterZone )
            sd = Swim_Deep;
        else
            sd = Swim_Shallow;
    }

    if ( sd == Swim_Deep )
    {
        PlayTopAnim( 'None' );
        PlayBottomAnim( 'None' );
    	PlayAllAnim('A_SwimStroke',,0.1,true);
    }
    else if ( sd == Swim_Shallow )
    {
        PlayAllAnim( 'None' );
        PlayBottomAnim('B_SwimKickWade',,0.1,true);
        PlayTopWeaponIdle( true );
    }
}

function PlayRopeIdle()
{
    //Log( "PlayRopeIdle" );
    PlayTopAnim( 'None' );
    PlayBottomAnim( 'None' );
    PlayAllAnim( 'A_ClimbRopeIdle',,0.1,true );
}

function PlayRopeClimbUp()
{
    //Log( "PlayRopeClimbUp" );
    PlayTopAnim( 'None' );
    PlayBottomAnim( 'None' );
    PlayAllAnim( 'A_ClimbRopeUp',,0.1,true );
}

function PlayRopeClimbDown()
{
    //Log( "PlayRopeClimbDown" );
    PlayTopAnim( 'None' );
    PlayBottomAnim( 'None' );
    PlayAllAnim( 'A_ClimbRopeDown',,0.1,true );
}

function PlayLadderIdle()
{
    //Log( "PlayLadderIdle" );
    PlayTopAnim( 'None' );
    PlayBottomAnim( 'None' );

    PlayAllAnim('A_ClimbLadderIdle',,0.1,true);        
}

function PlayLadderClimbUp()
{
    //Log( "PlayLadderClimbUp" );

    if ( LadderState == LADDER_Forward )
    {
        PlayTopAnim( 'None' );
        PlayBottomAnim( 'None' );
        PlayAllAnim( 'A_ClimbLadderUp',,0.1,true );
    }
    else
    {
        PlayWalking();
    }
}

function PlayLadderClimbDown()
{
    //Log( "PlayLadderClimbDown" );

    if ( LadderState == LADDER_Forward )
    {
        PlayTopAnim( 'None' );
        PlayBottomAnim( 'None' );    
        PlayAllAnim( 'A_ClimbLadderDown',,0.1,true );
    }
    else
    {
        PlayWalking();
    }
}

function PlayTurning( float Yaw )
{
    //Log( "PlayTurning" );
	if (Yaw > 0)
		PlayBottomAnim( 'B_StepLeft',,0.1,false );
	else
		PlayBottomAnim( 'B_StepRight',,0.1,false );
}

function ChangeJetpackState( EJetpackState NewState )
{
	local name AnimSeq;
	
	switch ( NewState )
	{
		case JS_Idle:
			AnimSeq='B_Jetpack_Idle';
			break;
		case JS_Forward:
			AnimSeq='B_Jetpack_F';
			break;
		case JS_Backward:
			AnimSeq='B_Jetpack_B';
			break;
		case JS_Left:
			AnimSeq='B_Jetpack_R';
			break;
		case JS_Right:
			AnimSeq='B_Jetpack_L';
			break;
	}

	// Put the previous anim on channel 3 and use it for blending.
	PlayAnim( MeshInstance.MeshChannels[2].AnimSequence, 1.0, -1.0, 3 );
	// Loop the new animation
	LoopAnim( AnimSeq ,1.0, -1.0, , 2 );

	JetpackState	= NewState;
	JetpackTime		= JetpackMax;
	LastJetpackTime = Level.TimeSeconds;
}

function PlayJetpacking()
{
	local vector	TestAccel;
	local rotator	Rot, PRot;
	local int		NormYaw;
	local float		Factor;
	local float     Blend;

	TestAccel   = Acceleration;
	TestAccel.Z = 0;
	
	GetMeshInstance();

	if ( JetpackState == JS_None )
		{
			LoopAnim( 'B_Jetpack_Idle',1.0,-1.0,,2 );			
			PlayAnim( 'None',,,3 );
			JetpackState		= JS_Idle;
			JetpackTime			= JetpackMax;
			LastJetpackTime		= Level.TimeSeconds;
			DesiredJetpackState = JS_Idle;
		}
	else if ( VSize(TestAccel) == 0 )
	{
		if ( DesiredJetpackState != JS_Idle )
		{
			DesiredJetpackState	= JS_Idle;
			JetpackStateTime	= Level.TimeSeconds;
		}
	}
	else
	{
		Rot		= rotator( normal( TestAccel ) );
		PRot	= ViewRotation;
		Rot		= normalize(Rot) - normalize(PRot);
		Rot		= normalize(Rot);
		NormYaw = Rot.Yaw;		

		if ( bWasForward ) //if ( (NormYaw > -10) && (NormYaw < 10) )
		{
			if ( DesiredJetpackState != JS_Forward )
			{
				DesiredJetpackState	 = JS_Forward;
				JetpackStateTime = Level.TimeSeconds;
			}
		}
		else if ( bWasBack ) //if ( (NormYaw < -32760) || (NormYaw > 32760) )
		{
			if ( DesiredJetpackState != JS_Backward )
			{
				DesiredJetpackState	= JS_Backward;
				JetpackStateTime	= Level.TimeSeconds;
			}
		}
		else if ( bWasLeft ) //if ( NormYaw > 0 )
		{
			if ( DesiredJetpackState != JS_Left )
			{
				DesiredJetpackState	= JS_Left;
				JetpackStateTime	= Level.TimeSeconds;
			}
		}
		else if ( bWasRight ) //if ( NormYaw < 0 )
		{
			if ( DesiredJetpackState != JS_Right )
			{
				DesiredJetpackState	= JS_Right;
				JetpackStateTime	= Level.TimeSeconds;
			}
		}
	}

	if ( ( Level.TimeSeconds > ( JetpackStateTime + 0.3 ) ) && 
		 ( DesiredJetpackState != JetpackState ) )
	{
		ChangeJetpackState( DesiredJetpackState );				
	} 
	
	if ( JetpackTime > 0 )
		JetpackTime		-= Level.TimeSeconds - LastJetpackTime;
	if ( JetpackTime < 0 )
		JetpackTime = 0;

	LastJetpackTime  = Level.TimeSeconds;

	Factor = JetpackTime / JetpackMax; 
	MeshInstance.MeshChannels[2].AnimBlend = Factor;
	MeshInstance.MeshChannels[3].AnimBlend = 1.0 - Factor;

	// Clear out the old anim from channel 3
	if ( Factor == 0 )
		MeshInstance.MeshChannels[3].AnimSequence = 'None';

	if ( AnimSequence == 'None' )
		PlayAllAnim( 'A_IdleStandActive', , 0.5, true );
}

function PlayAllCrawling() 
{
    //Log( "..PlayAllCrawling" );
    if ( Weapon != None )
        PlayWAM( Weapon.CrouchWalkAnim );    

    /*
    if ((dnWeapon(Weapon) != None) && (dnWeapon(Weapon).CrouchWalkAnim != ''))	
      PlayAllAnim(dnWeapon(Weapon).CrouchWalkAnim,,0.1,true);            
      */
}

function PlayBottomCrawling()
{
	local vector X,Y,Z,Dir;

    //Log( "..PlayBottomCrawling" );

    GetAxes( Rotation, X,Y,Z );
	Dir = Normal( Acceleration );

	if ( ( Dir Dot X < 0.75 ) && ( Dir != vect(0,0,0) ) )
	{
		// Strafing or backing up.
		if ( Dir Dot X < -0.75 )
			PlayBottomAnim( 'B_CrchWalk_Backwards',,0.1,true );
		else if ( Dir Dot Y > 0 )
			PlayBottomAnim( 'B_CrchWalk_R',,0.1,true );
		else
			PlayBottomAnim( 'B_CrchWalk_L',,0.1,true );
    }
}

function PlayToCrawling()
{
    //Log( "PlayToCrawling" );    
    PlayAllCrawling();
    PlayBottomCrawling();
	PlayTopAnim( 'None' );
}

function PlayCrawling()
{
    //Log( "PlayCrawling" );
    PlayAllCrawling();
    PlayBottomCrawling();
	PlayTopAnim( 'None' );
}

function PlayRise()
{
    //Log( "PlayRise" );
	PlayTopAnim('None');
	PlayBottomAnim('None');
	
    PlayAllAnim('A_IdleStandInactive',,0.4,false);	
    PlayTopWeaponIdle();
}

function PlayDuck()
{	
    //Log( "PlayDuck" );
	PlayBottomAnim('None');
	PlayAllAnim('A_CrchIdle',,0.2,true);
    PlayTopWeaponCrouchIdle();
}

function PlayCrouching()
{
    //Log( "PlayCrouching" );
    PlayDuck();
}
	
function PlayJump()
{
	local Pawn P;
	local float Dist;

    //Log( "PlayJump" );
    if ( Level.Netmode == NM_StandAlone )
    {
    	for( P=Level.PawnList; P!=None; P=P.NextPawn )
	    {
		    Dist=VSize(P.Location-Location);
		    if(Dist<128 && P.CanSee(self))
		    {
			    P.ReactToJump();
		    }
	    }
    }
	if ( Physics != PHYS_Jetpack )
		PlayAllAnim('A_JumpAir_U',,0.1,false);
}

function PlayInAir()
{
    //Log( "PlayInAir" );
	PlayBottomAnim( 'B_Jetpack_Idle',,0.1,true );	
	PlayTopWeaponIdle();
}

function PlayLanded(float impactVel)
{	
    //Log( "PlayLanded" );

	super.PlayLanded( impactVel ); // super plays the landing sound
	PlayAllAnim( 'A_JumpLand',,0.1,false );
	PlayBottomAnim( 'None' );
}

function PlayUpdateRotation( int Yaw )
{
    //Log( "PlayUpdateRotation" );
    if ( IsSwimming() )
        return;

	if (Yaw > 0)
		PlayBottomAnim( 'B_StepLeft',,0.1,false );
	else
		PlayBottomAnim( 'B_StepRight',,0.1,false );
}

function WpnPlayFireStart()
{
    //Log( "WpnPlayFireStart" );
    SetUpperBodyState( UB_Firing );
	
    if ( IsSwimming() )
    {
        return;
    }
    else if ( GetPostureState() == PS_Crouching )
	{
		if ( Weapon != None )
			PlayWAM( Weapon.GetCrouchFireAnim() );
	} 
    else 
    {
		if ( Weapon != None )
			PlayWAM( Weapon.FireStartAnim );
	}
}

function WpnPlayFire()
{
    //Log( "WpnPlayFire" );
    SetUpperBodyState( UB_Firing );
	
    if ( IsSwimming() )
    {
        return;
    }
    else if ( GetPostureState() == PS_Crouching )
	{
		if ( Weapon != None )
			PlayWAM( Weapon.GetCrouchFireAnim() );
	} 
    else 
    {
		if ( Weapon != None )
			PlayWAM( Weapon.GetFireAnim() );
	}
}

function WpnPlayThrow()
{
    //Log( "WpnPlayThrow" );	
    SetUpperBodyState( UB_Firing );

    if ( IsSwimming() )
        return;

    if ( Weapon != None )
        PlayWAM( Weapon.ThrowAnim );
}

// Used for playing animations based on other weapons that aren't currently being wielded (i.e. MightyFoot)
function WpnAuxPlayFire( Weapon AuxWeapon )
{
    //Log( "WpnAuxPlayFire" );	
    SetUpperBodyState( UB_Firing );

    if ( IsSwimming() )
        return;

    if ( GetPostureState() == PS_Crouching )
	{
		if ( AuxWeapon != None )
			PlayWAM( AuxWeapon.GetCrouchFireAnim() );
	} 
    else 
    {
		if ( AuxWeapon != None )
			PlayWAM( AuxWeapon.GetFireAnim() );
	}
}

function WpnPlayAltFire()
{
    //Log( "WpnPlayAltFire" );
    SetUpperBodyState( UB_Firing );

    if ( IsSwimming() )
        return;

    if ( Weapon != None )
        PlayWAM( Weapon.AltFireAnim );
}

function WpnPlayReloadStart()
{
    //Log( "WpnPlayReloadStart" );
	if ( ( Weapon != None) && Weapon.ReloadLoops )
		SetUpperBodyState( UB_Reloading );
	else
		SetUpperBodyState( UB_ReloadFinished );

    if ( ( GetControlState() == CS_Swimming ) || ( Physics == PHYS_Swimming ) )
        return;

    if ( Weapon != None )
        PlayWAM( Weapon.ReloadStartAnim );
}

function WpnPlayReload()
{
    //Log( "WpnPlayReload" );
    if ( IsSwimming() )
        return;

    if ( Weapon != None )
        PlayWAM( Weapon.ReloadLoopAnim );
}

function WpnPlayReloadStop()
{
    //Log( "WpnPlayReloadStop" );
    SetUpperBodyState( UB_ReloadFinished );

    if ( IsSwimming() )
        return;

    if ( Weapon != None )
        PlayWAM( Weapon.ReloadStopAnim );
}

function WpnPlayActivate()
{
    //Log( "WpnPlayActivate" );	
	SetUpperBodyState( UB_WeaponUp );

    if ( IsSwimming() )
        return;

	PlayTopAnim( 'T_WeaponChange2', 1.0, 0.05 );
}

function WpnPlayDeactivated()
{
    //Log( "WpnPlayDeactivated" );
    SetUpperBodyState( UB_WeaponDown );

    if ( IsSwimming() )
        return;

	PlayTopAnim( 'T_WeaponChange1', 1.0, 0.05 );
}

function WpnPlayFireStop()
{}

function PlayTopAlertIdle()
{
    //Log( "PlayTopAlertIdle" );
    if (GetPostureState() == PS_Crouching)
        PlayTopWeaponCrouchIdle(true);
    else
        PlayTopWeaponIdle(true);
}

function PlayTopRelaxedIdle()
{
    //Log( "PlayTopRelaxedIdle" );   
    // Relaxed and alert act the same for now (possibly forever).
    if (GetPostureState() == PS_Crouching)
        PlayTopWeaponCrouchIdle(true);
    else
        PlayTopWeaponIdle(true);
}

function PlayPain(EPawnBodyPart BodyPart, optional bool bShortAnim, optional vector HitLoc )
{
}

function TossThirdPersonShield(float Force, float ZForce )
{
    local vector X,Y,Z, StartLocation;
    local Decoration shield;
	local float ForceScale;
	local rotator AdjustedAim, TossRotation;
    local vector newLocation;

    GetAxes( ViewRotation,X, Y, Z );
	
    shield = spawn( class'dnThirdPersonShieldBroken' );
    shield.SetLocation( Location + X*shield.CollisionRadius*2);
    shield.SetRotation( ViewRotation );
    shield.Tossed();
    AdjustedAim = AdjustAim( 1000000, shield.Location, 0, false, false );
	shield.Velocity += Normal(vector(AdjustedAim)) * Force * shield.GetForceScale();
	shield.Velocity.Z += ZForce * (1.0 - abs(Normal(vector(AdjustedAim)).Z));
    shield.Instigator = self;
	if ( ThirdPersonShield != None )
		shield.DrawScale = ThirdPersonShield.DrawScale;
}

function ClientShieldBringUp()
{
    Super.ClientShieldBringUp();
    SetUpperBodyState( UB_ShieldDown ); // Start the animation by setting to UB_ShieldDown state
}

function ClientShieldPutDown()
{
    Super.ClientShieldBringUp();
    SetUpperBodyState( UB_ShieldDown );
}

function ClientShieldDestroyed()
{
    Super.ClientShieldDestroyed();
    SetUpperBodyState( UB_Alert );    
}

function ServerShieldBringUp()
{	
    Super.ServerShieldBringUp();
    SetUpperBodyState( UB_ShieldDown ); // Start the animation by setting to UB_ShieldDown state
}

function ServerShieldPutDown()
{
    Super.ServerShieldPutDown();
    SetUpperBodyState( UB_ShieldDown );
}

function ServerDestroyShield()
{
    Super.ServerDestroyShield();
    SetUpperBodyState( UB_Alert );
    
    TossThirdPersonShield(200,100);

	ThirdPersonShield.bHidden = true;
	ThirdPersonShield.Destroy();
}


/*-----------------------------------------------------------------------------
	Duke's Hand
-----------------------------------------------------------------------------*/

function Hand_WeaponUp()
{
	// Here's some violation of encapsulation for your ass!
	if ( ( DukesHand.AnimSequence == 'HitButton_Deactivate' )  )
	{
		if ( DukesHand.IsAnimating() )
			DukesHand.bPuttingDown = true;
		else
		{
			bDukeHandUp = false;
			DukesHand.bHidden = true;
			DrawHand = false;			
			WeaponUp();
		}
	} else
		DukesHand.PutDown();
}

function Hand_BringUp( optional bool bWeaponDownOnly, optional bool bWaitOnly, optional bool bTranslucentHand )
{
	if ( bTranslucentHand )
		DukesHand.Style = STY_Translucent;
	else
		DukesHand.Style = STY_Normal;

	if ( !bWaitOnly )
	{
		bDukeHandUp = true;
		WeaponDown();

		if ( QuestItem(UsedItem) != None )
			PutDownQuestItem();
	}

	if ( !bWeaponDownOnly )
		DukesHand.WaitToBringup();
}

function Hand_QuickAnim(name AnimName1, optional name AnimName2, optional float AnimTime)
{
	bDukeHandUp = true;
	DukesHand.WaitForQuickAnim(AnimName1, AnimName2, AnimTime);
	Hand_BringUp( true );
}

function Hand_PutDown( optional bool bNoWeapon )
{
	DukesHand.PutDown( bNoWeapon );
}

function Hand_PressButton()
{
	DukesHand.PressButton();
}

function Hand_SwipeItem( Inventory Item, Actor Other, Pawn EventInstigator )
{
//	bDukeHandUp = true;
	DukesHand.StartSwipeItem( Item, Other, EventInstigator );
}



/*-----------------------------------------------------------------------------
	SOS Functions
-----------------------------------------------------------------------------*/

exec function DoNightVision()
{
	local Inventory Inv;
	local class<Inventory> InvClass;

	InvClass = class<Inventory>( DynamicLoadObject( "dnGame.Upgrade_NightVision", class'Class' ) );
	Inv = FindInventoryType( InvClass );
	if ( Inv != None )
		Inv.Activate();
}

exec function DoHeatVision()
{
	local Inventory Inv;
	local class<Inventory> InvClass;

	InvClass = class<Inventory>( DynamicLoadObject( "dnGame.Upgrade_HeatVision", class'Class' ) );
	Inv = FindInventoryType( InvClass );
	if ( Inv != None )
		Inv.Activate();
}

exec function DoEMPPulse()
{
	local Inventory Inv;    
	local class<Inventory> InvClass;

	InvClass = class<Inventory>( DynamicLoadObject( "dnGame.Upgrade_EMP", class'Class' ) );
	Inv = FindInventoryType( InvClass );
	if ( Inv != None )
		ServerInventoryActivate( Inv.Class );
}

exec function DoZoomDown()
{
	local Inventory Inv;
	local class<Inventory> InvClass;

	InvClass = class<Inventory>( DynamicLoadObject( "dnGame.Upgrade_ZoomMode", class'Class' ) );
	Inv = FindInventoryType( InvClass );
	if ( Inv != None )
		Super.ZoomDown();
}

exec function UseMedKit()
{
	local Inventory Inv;
	local class<Inventory> InvClass;

	InvClass = class<Inventory>( DynamicLoadObject( "dnGame.MedKit", class'Class' ) );
	Inv = FindInventoryType( InvClass );
	if ( Inv != none )
	{
		SelectedItem = Inv;
		InventoryActivate();
	}
}

function bool CanBeGassed()
{
	if ( (UsedItem != None) && UsedItem.IsA('Rebreather') )
		return false;
	else
		return true;
}


/*-----------------------------------------------------------------------------
	Player commands.
-----------------------------------------------------------------------------*/

exec function FireDown()
{
	if (SOSStatus != SOS_Done && SOSStatus != SOS_IncomingCall)		// JEP
		return;

	if (DrawHand)
	{
		bFireUse = true;
		UseDown();
	} else
		Super.FireDown();
}

exec function AllAmmo()
{
	local Inventory Inv;
	local Weapon Weap;
	local Inventory InventoryItem;
	local class<Weapon> WeaponClass;
	local class<Inventory> InvClass;

	if( !bCheatsEnabled )
		return;

	if ( Level.Netmode != NM_Standalone )
		return;

	WeaponClass = class<Weapon>(DynamicLoadObject( "dnGame.DukeChainsaw", class'Class' ));
	Level.Game.GiveWeaponTo( self, WeaponClass, true );

	// Pistol.
	WeaponClass = class<Weapon>(DynamicLoadObject( "dnGame.Pistol", class'Class' ));
	Level.Game.GiveWeaponTo( self, WeaponClass, true );
	Weap = Weapon(FindInventoryType( WeaponClass ));
	if ( Weap != None )
	{
		Weap.AmmoType.ModeAmount[0] = Weap.AmmoType.MaxAmmo[0];
		Weap.AmmoType.ModeAmount[1] = Weap.AmmoType.MaxAmmo[1];
		Weap.AmmoType.ModeAmount[2] = Weap.AmmoType.MaxAmmo[2];
	}

	// Shotgun.
	WeaponClass = class<Weapon>(DynamicLoadObject( "dnGame.Shotgun", class'Class' ));
	Level.Game.GiveWeaponTo( self, WeaponClass, true );
	Weap = Weapon(FindInventoryType( WeaponClass ));
	if (Weap != None)
	{
		Weap.AmmoType.ModeAmount[0] = Weap.AmmoType.MaxAmmo[0];
		Weap.AmmoType.ModeAmount[1] = Weap.AmmoType.MaxAmmo[1];
	}

	// M-16
	WeaponClass = class<Weapon>(DynamicLoadObject( "dnGame.M16", class'Class' ));
	Level.Game.GiveWeaponTo( self, WeaponClass, true );
	Weap = Weapon(FindInventoryType( WeaponClass ));
	if (Weap != None)
	{
		Weap.AmmoType.ModeAmount[0] = Weap.AmmoType.MaxAmmo[0];
		Weap.AltAmmoType.ModeAmount[0] = Weap.AltAmmoType.MaxAmmo[0];
	}

	// RPG
	WeaponClass = class<Weapon>(DynamicLoadObject( "dnGame.RPG", class'Class' ));
	Level.Game.GiveWeaponTo( self, WeaponClass, true );
	Weap = Weapon(FindInventoryType( WeaponClass ));
	if (Weap != None)
	{
		Weap.AmmoType.ModeAmount[0] = Weap.AmmoType.MaxAmmo[0];
		Weap.AmmoType.ModeAmount[1] = Weap.AmmoType.MaxAmmo[1];
	}

	// TripMine
	WeaponClass = class<Weapon>(DynamicLoadObject( "dnGame.TripMine", class'Class' ));
	Level.Game.GiveWeaponTo( self, WeaponClass, true );
	Weap = Weapon(FindInventoryType( WeaponClass ));
	if (Weap != None)
		Weap.AmmoType.ModeAmount[0] = Weap.AmmoType.MaxAmmo[0];

	// Shrinkray
	WeaponClass = class<Weapon>(DynamicLoadObject( "dnGame.ShrinkRay", class'Class' ));
	Level.Game.GiveWeaponTo( self, WeaponClass, true );
	Weap = Weapon(FindInventoryType( WeaponClass ));
	if (Weap != None)
		Weap.AmmoType.ModeAmount[0] = Weap.AmmoType.MaxAmmo[0];

	// Flamer
	WeaponClass = class<Weapon>(DynamicLoadObject( "dnGame.Flamethrower", class'Class' ));
	Level.Game.GiveWeaponTo( self, WeaponClass, true );
	Weap = Weapon(FindInventoryType( WeaponClass ));
	if (Weap != None)
		Weap.AmmoType.ModeAmount[0] = Weap.AmmoType.MaxAmmo[0];

	// HypoGun
	WeaponClass = class<Weapon>(DynamicLoadObject( "dnGame.Hypogun", class'Class' ));
	Level.Game.GiveWeaponTo( self, WeaponClass, true );
	Weap = Weapon(FindInventoryType( WeaponClass ));
	if (Weap != None)
	{
		Weap.AmmoType.ModeAmount[0] = Weap.AmmoType.MaxAmmo[0];
		Weap.AmmoType.ModeAmount[1] = Weap.AmmoType.MaxAmmo[1];
		Weap.AmmoType.ModeAmount[2] = Weap.AmmoType.MaxAmmo[2];
	}

	// MultiBomb
	WeaponClass = class<Weapon>(DynamicLoadObject( "dnGame.MultiBomb", class'Class' ));
	Level.Game.GiveWeaponTo( self, WeaponClass, true );
	Weap = Weapon(FindInventoryType( WeaponClass ));
	if (Weap != None)
		Weap.AmmoType.ModeAmount[0] = Weap.AmmoType.MaxAmmo[0];

	// Freezer
	WeaponClass = class<Weapon>(DynamicLoadObject( "dnGame.Freezer", class'Class' ));
	Level.Game.GiveWeaponTo( self, WeaponClass, true );
	Weap = Weapon(FindInventoryType( WeaponClass ));
	if (Weap != None)
		Weap.AmmoType.ModeAmount[0] = Weap.AmmoType.MaxAmmo[0];

	// Sniper Rifle
	WeaponClass = class<Weapon>(DynamicLoadObject( "dnGame.SniperRifle", class'Class' ));
	Level.Game.GiveWeaponTo( self, WeaponClass, true );
	Weap = Weapon(FindInventoryType( WeaponClass ));
	if (Weap != None)
		Weap.AmmoType.ModeAmount[0] = Weap.AmmoType.MaxAmmo[0];

	// Heat Vision
	InvClass = class<Inventory>(DynamicLoadObject( "dnGame.Upgrade_HeatVision", class'Class' ));
	InventoryItem = FindInventoryType( InvClass );
	if ( InventoryItem == None )
	{
		InventoryItem = spawn( InvClass );
		InventoryItem.GiveTo( self );
	}

	// Night Vision
	InvClass = class<Inventory>(DynamicLoadObject( "dnGame.Upgrade_NightVision", class'Class' ));
	InventoryItem = FindInventoryType( InvClass );
	if ( InventoryItem == None )
	{
		InventoryItem = spawn( InvClass );
		InventoryItem.GiveTo( self );
	}

	// Zoom Vision
	InvClass = class<Inventory>(DynamicLoadObject( "dnGame.Upgrade_ZoomMode", class'Class' ));
	InventoryItem = FindInventoryType( InvClass );
	if ( InventoryItem == None )
	{
		InventoryItem = spawn( InvClass );
		InventoryItem.GiveTo( self );
	}

	// EMP
	InvClass = class<Inventory>(DynamicLoadObject( "dnGame.Upgrade_EMP", class'Class' ));
	InventoryItem = FindInventoryType( InvClass );
	if ( InventoryItem == None )
	{
		InventoryItem = spawn( InvClass );
		InventoryItem.GiveTo( self );
	}

	// Rebreather
	InvClass = class<Inventory>(DynamicLoadObject( "dnGame.Rebreather", class'Class' ));
	InventoryItem = FindInventoryType( InvClass );
	if ( InventoryItem == None )
	{
		InventoryItem = spawn( InvClass );
		InventoryItem.GiveTo( self );
	}

	// Med Kit
	InvClass = class<Inventory>(DynamicLoadObject( "dnGame.MedKit", class'Class' ));
	InventoryItem = FindInventoryType( InvClass );
	if ( InventoryItem == None )
	{
		InventoryItem = spawn( InvClass );
		InventoryItem.GiveTo( self );
	}

	// Riot Shield
	InvClass = class<Inventory>(DynamicLoadObject( "dnGame.RiotShield", class'Class' ));
	InventoryItem = FindInventoryType( InvClass );
	if ( InventoryItem == None )
	{
		InventoryItem = spawn( InvClass );
		InventoryItem.GiveTo( self );
		InventoryItem.Activate();
	}

	// Power Cells
	InvClass = class<Inventory>(DynamicLoadObject( "dnGame.PowerCell", class'Class' ));
	InventoryItem = FindInventoryType( InvClass );
	if ( InventoryItem == None )
	{
		InventoryItem = spawn( InvClass );
		PowerCell(InventoryItem).NumCopies = 4;
		InventoryItem.GiveTo( self );
	}

	// Jetpack
	InvClass = class<Inventory>(DynamicLoadObject( "dnGame.Jetpack", class'Class' ));
	InventoryItem = FindInventoryType( InvClass );
	if ( InventoryItem == None )
	{
		InventoryItem = spawn( InvClass );
		InventoryItem.GiveTo( self );
	}

	AddEnergy(101 - Energy);
}

exec function SetAirControl(float F)
{
	if ( bAdmin || (Level.Netmode == NM_Standalone) )
		AirControl = F;
}

exec function Summon( string ClassName )
{
	local class<actor> NewClass;
	if( !bCheatsEnabled )
		return;

	if( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;

	if( instr(ClassName,".")==-1 )
		ClassName = "dnGame." $ ClassName;

	Super.Summon( ClassName );
}

exec function Mount( string ClassName )
{
    local class<actor> NewClass;
    local vector EndPos;
    local actor a;
	local bool mounted;

	if( !bCheatsEnabled )
		return;
	if( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;
	if( instr(ClassName,".")==-1 )
		ClassName = "dnMountables." $ ClassName;
	NewClass = class<actor>( DynamicLoadObject( ClassName, class'Class' ) );
	if( NewClass!=None )
    {
		a = Trace(EndPos,,Location+vect(0,0,EyeHeight) + 72 * Vector(ViewRotation));
		if (a==none)
			a = Spawn( NewClass,Self,,Location+vect(0,0,EyeHeight) + 72 * Vector(ViewRotation) );
		else
			a = Spawn( NewClass,Self,,EndPos );
		if ( (a!=none) && a.IsA('MountableDecoration') )
		{
			mounted = AddMountable(Decoration(a), true, true);
			if (!mounted)
			{
				BroadcastMessage("Failed to mount the object, you have too many mounts already.");
				a.Destroy();
			}
		}
	}
}

exec function MountTrace( string ClassName )
{
    local class<actor> NewClass;
    local vector EndPos;
    local actor a, t;
	local bool mounted;

	if( !bCheatsEnabled )
		return;
	if( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;
	if( instr(ClassName,".")==-1 )
		ClassName = "dnMountables." $ ClassName;
	NewClass = class<actor>( DynamicLoadObject( ClassName, class'Class' ) );
	if( NewClass!=None )
    {
		t = TraceFromCrosshair(1000);
		if (Pawn(t) == none)
			return;
		a = Trace(EndPos,,Location+vect(0,0,EyeHeight) + 72 * Vector(ViewRotation));
		if (a==none)
			a = Spawn( NewClass,t,,Location+vect(0,0,EyeHeight) + 72 * Vector(ViewRotation) );
		else
			a = Spawn( NewClass,t,,EndPos );
		if ( (a!=none) && a.IsA('MountableDecoration') )
		{
			mounted = Pawn(t).AddMountable(Decoration(a), true, true);
			if (!mounted)
			{
				BroadcastMessage("Failed to mount the object, you have too many mounts already.");
				a.Destroy();
			}
		}
	}
}

exec function QuickKick( optional bool bNoTraceHit, optional bool bForceKick )
{
	// Can't quick kick if we are in stasis.
	if ( GetControlState() == CS_Stasis )
		return;

	// Can't quick kick if we have a shield up.
	if ( ShieldProtection || ( (ShieldItem != None) && ShieldItem.IsInState('ShieldUp') ) )
		return;

	if ( (Weapon != None) && (Weapon.IsA('dnWeapon')) )
	{
		if ( Role < ROLE_Authority )
			dnWeapon(Weapon).ClientQuickKick( bForceKick );
		ServerQuickKick( bNoTraceHit, bForceKick );
	}
}

function ServerQuickKick( optional bool bNoTraceHit, optional bool bForceKick )
{
	if ( (Weapon != None) && (Weapon.IsA('dnWeapon')) )
		dnWeapon(Weapon).QuickKick( bNoTraceHit, bForceKick  );
}

exec function SetHealth( int NewHealth )
{
	Health = NewHealth;
}

exec function dnCashMan()
{
	if (CashMan == None)
	{
		CashMan = spawn(class'dnParticles.dnCashMan', Self);
		CashMan.SetPhysics(PHYS_MovingBrush);
		CashMan.MountType = MOUNT_Actor;
		CashMan.AttachActorToParent( Self, false, true );
	}
	CashMan.Enabled = !CashMan.Enabled;
}

exec function PissDown()
{
	local vector PissLocation, X, Y, Z;
	local rotator PissRotation;

	if (DukePiss == None)
	{
		GetAxes( ViewRotation, X, Y, Z );
		PissLocation = Location;
		PissLocation.Z += 30;
		PissRotation = ViewRotation;
		DukePiss = spawn( class'dnDukePiss', Self, , PissLocation, PissRotation );
		DukePiss.UpdateWhenNotVisible = true;
		DukePiss.InitialVelocity.X = 250;
		DukePiss.InitialVelocity.Y = 0;
		DukePiss.InitialVelocity.Z = 80;
	}
	DukePiss.Enabled = true;
	DukeVoice.DukeSay( ZipperSound );
	SetCallbackTimer( 0.3, true, 'PlayPissSound' );
}

exec function PissUp()
{
	DukePiss.Enabled = false;
	EndCallbackTimer( 'PlayPissSound' );
	DukeVoice.StopSound( SLOT_Talk );
	DukeVoice.StopSound( SLOT_Ambient );
	DukeVoice.StopSound( SLOT_Interface );
}

function PlayPissSound()
{
	DukeVoice.DukeSay( PissSound );
	SetCallbackTimer( 1.0, true, 'PlayPissSound' );
}

exec function ShowCyl()
{
	if (MyHUD.IsA('DukeHUD'))
		DukeHUD(MyHUD).bDrawCyl = !DukeHUD(MyHUD).bDrawCyl;
}

exec function ShowBounds()
{
	if (MyHUD.IsA('DukeHUD'))
		DukeHUD(MyHUD).bDrawBounds = !DukeHUD(MyHUD).bDrawBounds;
}


/*-----------------------------------------------------------------------------
	Damage and Hit Effects
-----------------------------------------------------------------------------*/


function EMPBlast( float inEMPtime, optional Pawn Instigator )
{
	Super.EMPBlast( inEMPtime, Instigator );

	// Reset the smacks.
	bGPFStart = true;
	RebootPhase = 0;
	EmpTime = 10.0;

	if ( OverloadGPFStart == None )
		OverloadGPFStart = SmackerTexture( DynamicLoadObject( OverloadGPFStartString, class'SmackerTexture' ) );
	OverloadGPFStart.currentFrame = 0;

	if ( OverloadGPFLoop == None )
		OverloadGPFLoop = SmackerTexture( DynamicLoadObject( OverloadGPFLoopString, class'SmackerTexture' ) );
	OverloadGPFLoop.currentFrame = 0;

	if ( OverloadBootStart == None )
		OverloadBootStart = SmackerTexture( DynamicLoadObject( OverloadBootStartString, class'SmackerTexture' ) );
	OverloadBootStart.currentFrame = 0;

	if ( OverloadBootLoop == None )
		OverloadBootLoop = SmackerTexture( DynamicLoadObject( OverloadBootLoopString, class'SmackerTexture' ) );
	OverloadBootLoop.currentFrame = 0;

	AmbientSound = EMPStaticSound;
}

function UnEMP()
{
	Super.UnEMP();

	// Stop the smacks.
	if ( OverloadGPFLoop == None )
		OverloadGPFLoop = SmackerTexture( DynamicLoadObject( OverloadGPFLoopString, class'SmackerTexture' ) );
	OverloadGPFLoop.pause = true;

	if ( OverloadGPFStart == None )
		OverloadGPFStart = SmackerTexture( DynamicLoadObject( OverloadGPFStartString, class'SmackerTexture' ) );
	OverloadGPFStart.pause = true;

	if ( OverloadBootStart == None )
		OverloadBootStart = SmackerTexture( DynamicLoadObject( OverloadBootStartString, class'SmackerTexture' ) );
	OverloadBootStart.pause = true;

	if ( OverloadBootLoop == None )
		OverloadBootLoop = SmackerTexture( DynamicLoadObject( OverloadBootLoopString, class'SmackerTexture' ) );
	OverloadBootLoop.pause = true;

	// Degauss.
	bEMPulsed = false;
	DesiredFOV = DefaultFOV;
	FOVAngle = 1;
	bDegauss = true;

	if ( DegaussOverlay == None )
		DegaussOverlay= SmackerTexture( DynamicLoadObject( DegaussOverlayString, class'SmackerTexture' ) );
	DegaussOverlay.pause = false;
	DegaussOverlay.currentFrame = 0;
	AmbientSound = None;
	PlayOwnedSound( EMPDegaussSound,,,true );
}

function TakeDamage( int Damage, Pawn InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	local vector ViewVector;
	local int PlayerDamage, ShieldDamage;

	// If we don't have a shield, shield not active, or shield doesnt block, player takes all damage like normal.
	if ( RiotShield(ShieldItem) == None || !ShieldProtection || !DamageType.default.bShieldBlocks )
	{
		Super.TakeDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType );
		return;
	}

	// If the damage is more than the shield can take, split it between the shield and the player.
	if ( Damage > RiotShield(ShieldItem).Charge ) 
	{
		PlayerDamage = Damage - RiotShield(ShieldItem).Charge;
		ShieldDamage = RiotShield(ShieldItem).Charge;
	}
	else
	{
		ShieldDamage = Damage;
		PlayerDamage = 0;
	}

	// Check to see if the shield was hit.
	ViewVector = vector(ViewRotation);
	ViewVector.z = 0;
	if ( (Normal(HitLocation - Location) dot ViewVector >= 0) && ShieldProtection && DamageType.default.bShieldBlocks )
	{
		// Riot shield absorbs the damage.
		RiotShield(ShieldItem).TakeDamage( ShieldDamage, InstigatedBy, HitLocation, Momentum, DamageType );
	}
	else
	{
		// We got hit from behind, take the damage.
		PlayerDamage = ShieldDamage;
	}

	if ( (PlayerDamage > 0) || !DamageType.default.bShieldBlocks )
	{
		// Normal damage.
		Super.TakeDamage( PlayerDamage, InstigatedBy, HitLocation, Momentum, DamageType );
	}

}

simulated function HitEffect( vector HitLocation, class<DamageType> DamageType, vector Momentum, bool bNoCreationSounds )
{
	local vector ViewVector;

	ViewVector = vector(ViewRotation);
	ViewVector.z = 0;
	if ( ShieldProtection && (ShieldItem != None) && ShieldItem.IsA('RiotShield') && (Normal(HitLocation - Location) dot ViewVector >= 0) )
		return;

	if ( DamageType == class'WhippedDownDamage' )
		DukeHUD(MyHUD).RegisterBloodSlash(0);
	else if ( DamageType == class'WhippedLeftDamage' )
		DukeHUD(MyHUD).RegisterBloodSlash(1);
	else if ( DamageType == class'WhippedRightDamage' )
		DukeHUD(MyHUD).RegisterBloodSlash(2);

	Super.HitEffect( HitLocation, DamageType, Momentum, bNoCreationSounds );
}

simulated function class<HitPackage> GetHitPackageClass( vector HitLocation )
{
	local vector ViewVector;

	ViewVector = vector(ViewRotation);
	ViewVector.z = 0;
	if ( ShieldProtection && (ShieldItem != None) && ShieldItem.IsA('RiotShield') && (Normal(HitLocation - Location) dot ViewVector >= 0) )
		return class'HitPackage_ShieldHeld';
	else
		return HitPackageClass;
}

function ShakeView( float shaketime, float RollMag, float vertmag)
{
	if ( (ExamineActor == None) || !ExamineActor.IsA('InputDecoration') )
		Super.ShakeView( shaketime, RollMag, vertmag );
}

function Died( Pawn Killer, class<DamageType> DamageType, vector HitLocation, optional Vector Momentum )
{
	local StickyBomb Sticky;
	local int i;

	// Blow up all the stickybombs attached to me.
	class'StickyBomb'.static.BlowUpStickies( Sticky, Self );

	// Destroy the shield, but don't shatter it
	if ( ThirdPersonShield != None )
	{
		for ( i=0; i < ArrayCount(ThirdPersonShield.FragType); i++ )
			ThirdPersonShield.FragType[i] = None;

		ThirdPersonShield.Destroy();
	}

	// Check and drop the bomb if we have one
	CheckDropBomb();

	Super.Died( Killer, DamageType, HitLocation, Momentum );
}


/*-----------------------------------------------------------------------------
	Timers.
-----------------------------------------------------------------------------*/
event PlayerTick( float DeltaSeconds )
{
	local vector X, Y, Z;
	local rotator PissRotation;

	if ( ( Role < ROLE_Authority ) && ( HitCounter > OldHitCounter ) )
	{
		if ( HitNotificationSounds[HitNotificationIndex] != None )
			PlaySound( HitNotificationSounds[HitNotificationIndex], SLOT_Talk, 16 );
	}
	OldHitCounter = HitCounter;
	
	Super.PlayerTick( DeltaSeconds);

	// JEP ...
	// Handle fading in/out
	if (SOSStatus == SOS_AnsweringCallFadingIn || SOSStatus == SOS_EndingCallFadingIn)
	{
		FlashScale = CurrentFlashScale;

		if (FlashScale.X >= 1)
		{
			FlashScale = vect(1,1,1);

			if (SOSStatus == SOS_AnsweringCallFadingIn)
				SOSStatus = SOS_CallInProgress;
			else 
				SOSStatus = SOS_Done;
		}

		FlashScale += vect(1,1,1)*Level.TimeDeltaSeconds*3.0;

		if (FlashScale.X >= 1)
			FlashScale = vect(1,1,1);

		CurrentFlashScale = FlashScale;
	}
	else if (SOSStatus == SOS_AnsweringCallFadingOut || SOSStatus == SOS_EndingCallFadingOut)
	{
		FlashScale = CurrentFlashScale;

		if (FlashScale.X <= 0)
		{
			FlashScale = vect(0,0,0);

			if (SOSStatus == SOS_AnsweringCallFadingOut)
			{
				if (SOSInstigator != None)
					SOSInstigator.StartEvents(true);	
				SOSStatus = SOS_AnsweringCallFadingIn;
			}
			else 
			{
				if (SOSInstigator != None)
					SOSInstigator.StopEvents(true);	
				SOSStatus = SOS_EndingCallFadingIn;
				DukeHUD(MyHUD).bHideHUD = false;
			}
		}

		FlashScale -= vect(1,1,1)*Level.TimeDeltaSeconds*3.0;

		if (FlashScale.X <= 0)
			FlashScale = vect(0,0,0);

		CurrentFlashScale = FlashScale;
	}
	// ... JEP

	// Update piss?
	if ( DukePiss != None )
	{
		GetAxes( ViewRotation, X, Y, Z );
		PissRotation = ViewRotation;
		PissRotation.Roll = 0;
		DukePiss.SetRotation( PissRotation );
		DukePiss.SetLocation( Location + BaseEyeHeight*vect(0,0,1) - Z*7 + X*6 );
	}
}

// JEP ... (take over this function while fading in/out for SOS, because this function mucks with the FlashScale values)
function ViewFlash(float DeltaTime)
{
	if (SOSStatus != SOS_Done)
		return;
	
	Super.ViewFlash(DeltaTime);
}
// ... JEP

event UpdateTimers(float DeltaSeconds) 
{
	local bool UpdateFlash;
	local rotator NormalizedVR;
	local sound Thunder;

	Super.UpdateTimers(DeltaSeconds);

	if ( EmpTime > 0.0 )
	{
		EmpTime -= DeltaSeconds;
		UpdateFlash = true;
		if ( (EmpTime < 8.0) && (RebootPhase == 0) )
		{
			RebootPhase = 1;
			UpdateFlash = false;
		}
		if ( EmpTime < 0.0 )
		{
			UpdateFlash = false;
			EmpTime = 0.0;
		}
	}

	if ( PostDegaussFade > 0.0 )
	{
		PostDegaussFade -= DeltaSeconds;
		if ( PostDegaussFade < 0.0 )
			PostDegaussFade = 0.0;
	}

	if ( (FlashTime > 0.0) && UpdateFlash )
	{
		FlashTime -= DeltaSeconds;
		if ( FlashTime < 0.0 )
		{
			FlashTime = 0.4;
			bFlash = !bFlash;
		}
	}

	if ( JetpackTime > 0.0 )
	{
		JetpackTime -= DeltaSeconds;
		if ( JetpackTime < 0.0 )
		{
			JetpackTime = 0.0;
		}
	}

	// Thunder
	if ( bCanHearThunder )
	{
		if ( Level.TimeSeconds > NextThunderTime )
		{
			if ( FRand() > 0.5 )
			{
				Thunder = ThunderFar[Rand(2)];
				if ( HeadRegion.Zone.FarThunderEvent != '' )
					GlobalTrigger( HeadRegion.Zone.FarThunderEvent );
			}
			else
			{
				Thunder = ThunderMed[Rand(2)];
				if ( HeadRegion.Zone.MidThunderEvent != '' )
					GlobalTrigger( HeadRegion.Zone.MidThunderEvent );
			}
			NextThunderTime = Level.TimeSeconds + GetSoundDuration( Thunder ) + 30.0 + 30*FRand();
			PlaySound( Thunder, SLOT_Interface );
		}
	}
	
	// Swallow
	if ( SwallowTime > 0.0 )
	{
		SwallowTime -= DeltaSeconds;
		if ( SwallowTime <= 0.0 )
		{
			SwallowTime = 0.0;
			DukeVoice.DukeSay( PlayerReplicationInfo.VoiceType.default.SwallowSound );
		}
	}

	// Mist
	if ( Mist != None )
		UpdateMist( Mist, DeltaSeconds );
	if ( OldMist != None )
		UpdateMist( OldMist, DeltaSeconds );

	// Rain
	if ( Rain != None )
		UpdateRain( Rain, DeltaSeconds );
	if ( OldRain != None )
		UpdateRain( OldRain, DeltaSeconds );
}

function UpdateMist( SoftParticleSystem InMist, float DeltaSeconds )
{
	local float RegularYaw, MinY, YScale;
	local float RegularPitch, MinZ, ZScale;
	local float MistX, MistY, MistZ;

	InMist.SetRotation( rot(0,0,0) );

	// Normalized rotator components are discontinuous at 32767.
	// Range [-32768, 32767]

	// These numbers are for mist blowing towards normalized 0.

	RegularYaw = Normalize(ViewRotation).Yaw;
	RegularPitch = Normalize(ViewRotation).Pitch;

	// Adjust up/down (Z) position.
	MinZ = -20;
	if ( (RegularPitch >= 0) && (RegularPitch < 16384) )
	{
		// First quad.
		ZScale = RegularPitch / 16384;
		MinY = -25 * (1.0 - ZScale);
	}
	else if ( (RegularPitch >= 16384) && (RegularPitch <= 32767) )
	{
		// Second quad.
		ZScale = 1.0 - ( (RegularPitch-16384) / 16384 );
		MinY = -25 * (1.0 - ZScale);
	}
	else if ( (RegularPitch >= -32768) && (RegularPitch < -16384) )
	{
		// Third quad.
		ZScale = 1.0 + ( (RegularPitch+16384) / 16384 ) * -1.0;
		MinY = -25 + -25 * ZScale;
	}
	else if ( (RegularPitch < 0) && (RegularPitch >= -16384) )
	{
		// Forth quad.
		ZScale = RegularPitch / 16384;
		MinY = -25 + -25 * ZScale;
	}

	// Adjust left/right (Y) position.
	if ( (RegularYaw >= 0) && (RegularYaw < 16384) )
	{
		// First quad.
		YScale = RegularYaw / 16384;
	}
	else if ( (RegularYaw >= 16384) && (RegularYaw <= 32767) )
	{
		// Second quad.
		YScale = 1.0 - ( (RegularYaw-16384) / 16384 );
	}
	else if ( (RegularYaw >= -32768) && (RegularYaw < -16384) )
	{
		// Third quad.
		YScale = 1.0 + ( (RegularYaw+16384) / 16384 );
		YScale *= -1.0;
	}
	else if ( (RegularYaw < 0) && (RegularYaw >= -16384) )
	{
		// Forth quad.
		YScale = RegularYaw / 16384;
	}

	MistX = 77;
	MistY = MinY*YScale;
	MistZ = -29 + MinZ*ZScale;

	InMist.SetLocation( Location - vect(MistX,MistY,MistZ) );
}

function UpdateRain( SoftParticleSystem InRain, float DeltaSeconds )
{
	local vector RainLoc, X, Y, Z;
	local rotator RainRot;

	RainRot = ViewRotation;
	RainRot.Pitch = 0;

	GetAxes( RainRot, X, Y, Z );

	RainLoc = Location + X*300;
	RainLoc.Z += 384;

	InRain.SetLocation( RainLoc );
}


/*-----------------------------------------------------------------------------
	Water HUD Management.
-----------------------------------------------------------------------------*/

simulated function DoAirHud( bool TurnOn )
{
    if ( DukeHUD(MyHUD) != None )
    {
        if ( TurnOn )
            DukeHUD(MyHUD).RegisterAirItem(spawn(class'HUDIndexItem_Air'));
        else
            DukeHUD(MyHUD).RemoveAirItem();
    }
}

simulated function HeadEnteredWater()
{    
	Super.HeadEnteredWater();

    PlaySwimming( Swim_Deep );
    DoAirHud( true );    	
}

simulated function HeadExitedWater()
{
	if ((UsedItem == None) || (!UsedItem.IsA('Rebreather')))
		DoAirHud( false );
	Super.HeadExitedWater();
    PlaySwimming( Swim_Shallow );
}



/*-----------------------------------------------------------------------------
	Duke Voice
-----------------------------------------------------------------------------*/

function ClientPlayPainSound( class<DamageType> DamageType )
{
	local sound PainSound;
	local float SoundPitch;

	// Falling damage pain sounds are handled in event Landed.
	if ( ClassIsChildOf( DamageType, class'FallingDamage' ) )
		return;

	if ( ClassIsChildOf( DamageType, class'DrowningDamage' ) )
	{
		PainSound = PlayerReplicationInfo.VoiceType.default.UnderWaterPain;
		SoundPitch = FRand()*0.15+0.9;
	}
	else
	{
		PainSound = PlayerReplicationInfo.VoiceType.default.PainSounds[rand( PlayerReplicationInfo.VoiceType.default.NumPainSounds )];
		SoundPitch = 1.0;
	}

	// FIXME: Do we really want to broadcast out our pain sounds?  Seems like a waste of bandwidth.  
	// We already have hit notification
	/*
	if ( DukeVoice != None )
	{
		DukeVoice.DukeSay( PainSound );
	}
	*/

	// Just play locally for now
	if ( DrawScale < 0.5 )
		SoundPitch *= 1.5;

	PlayOwnedSound( PainSound, SLOT_Talk, , , , SoundPitch, true );
}

function Killed( Pawn Killer, Pawn Other, class<DamageType> DamageType )
{
	local sound KillSound;

	Super.Killed( Killer, Other, DamageType );
    
    // only auto taunt in single player
    if ( Level.Game.IsA('dnSinglePlayer') && (Level.NetMode == NM_Standalone) )  
    {
    	if ( (FRand() < 0.25) && (Level.TimeSeconds > NextTalkTime) && (Other != None) && (Killer == Self) && (Killer != Other) )
	    {
			if ( ClassIsChildOf(DamageType, class'KungFuDamage') && (FRand() > 0.5) )
				KillSound = PlayerReplicationInfo.VoiceType.default.KungFuKill;
			else if ( DamageType.default.bGibDamage )
				KillSound = PlayerReplicationInfo.VoiceType.default.MessyKillSounds[Rand(PlayerReplicationInfo.VoiceType.default.NumMessyKillSounds)];
			else
			    KillSound = PlayerReplicationInfo.VoiceType.default.KillSounds[Rand(PlayerReplicationInfo.VoiceType.default.NumKillSounds)];
		    NextTalkTime = Level.TimeSeconds + GetSoundDuration(KillSound);
		    DukeVoice.DukeSay(KillSound);
	    }
    }
}

simulated function CheckMirror()
{
	local class<Material> m;

	m = TraceMaterialFromCrosshair( UseDistance );
	if ( (m != None) && (m.default.bIsMirror) && (Level.TimeSeconds > NextTalkTime) )
	{
		NextTalkTime = Level.TimeSeconds + GetSoundDuration(PlayerReplicationInfo.VoiceType.default.MirrorSounds[CurrentMirrorSound]);
		if ( Level.TimeSeconds > NextMirrorEgoTime )
		{
			AddEgo(10);
			NextMirrorEgoTime = Level.TimeSeconds + 300;
		}
		DukeVoice.DukeSay( PlayerReplicationInfo.VoiceType.default.MirrorSounds[CurrentMirrorSound++] );
		if ( CurrentMirrorSound > 4 )
			CurrentMirrorSound = 0;
	}
}

// JEP...
simulated function FootStep()
{
	local dnGlassFragments GlassFragments;

	foreach TouchingActors(class'dnGlassFragments', GlassFragments)
	{
		GlassFragments.PlayRandomFootStepSound(self);
		break;
	}

	Super.FootStep();
}
// ...JEP

/*-----------------------------------------------------------------------------
	End Game Sequences
-----------------------------------------------------------------------------*/

function ShowDeathSequence()
{
	WindowConsole(Player.Console).CancelBootSequence();
	WindowConsole(Player.Console).SetupDeathSequence();
	WindowConsole(Player.Console).bQuickKeyEnable = false;
	WindowConsole(Player.Console).LaunchUWindow();
}

/*-----------------------------------------------------------------------------
	SOS Power Overlays.
	08/09/01 - Brandon modified this code significantly for better
	memory management.
-----------------------------------------------------------------------------*/

simulated event RenderOverlays( canvas Canvas )
{
	local texture Tex;
	local float XL, YL, RotationScale, XPos, YPos;
	local string ZoomString, HelperString;
	local float SunglassesSizeX, SunglassesSizeY;
	local Pawn P;
	local bool bSniperZoomed;
	local int d1, d2, d3, d4, t1, t2;

	local DukeHUD	HUDToUse;
	local float		W, H;
	local string	UseStr;
	
	Super.RenderOverlays( Canvas );

	if ( DrawHand )
		DukesHand.RenderOverlays( Canvas );

	if ( (Weapon != None) && !Weapon.CanDrawSOS() )
		bSniperZoomed = true;

	// JEP ...
	HUDToUse = DukeHUD(MyHUD);

	// Handle SOS Incoming calls
	if ( SOSStatus == SOS_IncomingCall )
	{
		if ( IncomingCallTexture == None )
			IncomingCallTexture = Texture( DynamicLoadObject( "ezphone.vd_answerD", class'Texture' ) );
		Tex = IncomingCallTexture;

		XPos = Canvas.ClipX*0.7;
		YPos = Canvas.ClipY*0.1;

		NextRingTime += Level.TimeDeltaSeconds;
		
		if ( NextRingTime >= 4 )
		{
			if ( PhoneRingOutSound == None )
				PhoneRingOutSound = Sound( DynamicLoadObject( "a_generic.telephone.PhoneRingOut", class'Sound' ) );
			PlaySound( PhoneRingOutSound, SLOT_Misc, 0.5 );
			NextRingTime = 0.0f;
		}

		if ( IncomingCallTime >= 0.25 )
		{
			Canvas.DrawColor = DukeHUD(MyHUD).WhiteColor;
			Canvas.Style = 3;
			Canvas.SetPos( XPos, YPos );
			
			Canvas.DrawTile( Tex, Tex.USize, Tex.VSize, 0, 0, Tex.USize, Tex.VSize );
			
			if ( IncomingCallTime > 0.5 )
				IncomingCallTime = 0;
		}

		if ( HUDToUse != None )
		{
			UseStr = HUDToUse.SpecialKeys[HUDToUse.ESpecialKeys.SK_Use];
			UseStr = "Incoming SOS call - Press '"$UseStr$"' to answer...";

			Canvas.Style = 3;
			Canvas.Font = HUDToUse.MediumFont;
			Canvas.DrawColor = HUDToUse.TextColor;

			Canvas.TextSize( UseStr, W, H );
			Canvas.SetPos( XPos-W*0.5+Tex.USize*0.5f, YPos+Tex.VSize );

			Canvas.DrawText( UseStr );
		}

		IncomingCallTime += Level.TimeDeltaSeconds;
	}
	/*		// Handle Static
	else if (SOSStatus == SOS_AnsweringCallFadingOut || SOSStatus == SOS_AnsweringCall)
	{
		Tex = HeavyVisionStatic[0];
		Canvas.DrawColor = DukeHUD(MyHUD).WhiteColor;
		Canvas.Style = 3;
		Canvas.SetPos(0, 0);
		Canvas.DrawTile(Tex, Canvas.ClipX, Canvas.ClipY, 0, 0, Tex.USize, Tex.VSize);
		
		if (SOSStatus == SOS_AnsweringCall)
		{
			IncomingCallTime += Level.TimeDeltaSeconds;

			if (IncomingCallTime > 1.0)
				SOSStatus = SOS_AnsweringCallFadingOut;
		}
	}
	else if (SOSStatus == SOS_EndingCall || SOSStatus == SOS_EndingCallFadingIn)
	{
		Tex = HeavyVisionStatic[0];
		Canvas.DrawColor = DukeHUD(MyHUD).WhiteColor;
		Canvas.Style = 3;
		Canvas.SetPos(0, 0);
		Canvas.DrawTile(Tex, Canvas.ClipX, Canvas.ClipY, 0, 0, Tex.USize, Tex.VSize);
		
		if (SOSStatus == SOS_EndingCallFadingIn)
		{
			IncomingCallTime += Level.TimeDeltaSeconds;

			if (IncomingCallTime > 1.0)
				SOSStatus = SOS_EndingCallFadingIn;
		}
	}
	*/
	else if ( SOSStatus == SOS_CallInProgress || SOSStatus == SOS_EndingCallFadingOut || SOSStatus == SOS_AnsweringCallFadingIn )
	{
		// Draw the frequency overlay
		Canvas.DrawColor = DukeHUD(MyHUD).HudColor;
		Canvas.Style = 3;
		
		if (OverloadBootLoop == None)
			OverloadBootLoop = SmackerTexture( DynamicLoadObject( OverloadBootLoopString, class'SmackerTexture' ) );
				
		Tex = OverloadBootLoop;
		OverloadBootLoop.pause = false;
		
		Canvas.SetPos( 0, Canvas.ClipY-Tex.VSize);
		Canvas.DrawTile(Tex, Tex.USize, Tex.VSize, 0, 0, Tex.USize, Tex.VSize);

		// Draw Frequency value
		UseStr = SOSFreqString;

		Canvas.Style = 3;
		Canvas.Font = HUDToUse.LargeFont;
		Canvas.DrawColor = HUDToUse.TextColor;

		Canvas.TextSize( UseStr, W, H );
		Canvas.SetPos((Tex.USize-W)*0.5, Tex.VSize*0.80 + (Canvas.ClipY-Tex.VSize));

		Canvas.DrawText( UseStr );
		
		// Draw static
		if ( ZoomVisionSubtleStatic == None )
			ZoomVisionSubtleStatic = Texture( DynamicLoadObject( ZoomVisionSubtleStaticString, class'Texture' ) );
		Tex = ZoomVisionSubtleStatic;

		Canvas.DrawColor = DukeHUD(MyHUD).WhiteColor;
		Canvas.Style = 4;
		Canvas.SetPos( 0, 0 );
		Canvas.DrawTile( Tex, Canvas.ClipX, Canvas.ClipY, 0, 0, Tex.USize, Tex.VSize );
	
		// Glasses (disabled, didn't look good)
		//Player.Console.DrawSunglasses( Canvas );
	}
	// ... JEP

	// Draw the rain overlay.
	if ( bRainOverlay )
	{
		Canvas.DrawColor = DukeHUD(MyHUD).WhiteColor;
		Canvas.Style = 4;
		Canvas.SetPos(0, 0);
		if ( LensWaterHeavy == None )
			LensWaterHeavy = SmackerTexture( DynamicLoadObject( LensWaterHeavyString, class'SmackerTexture' ) );
		Tex = LensWaterHeavy;
		Canvas.DrawTile( Tex, Canvas.ClipX, Canvas.ClipY, 0, 0, Tex.USize, Tex.VSize );
	}

	// If we aren't in zoom, draw our overlay actor.
	if ( CameraStyle != PCS_ZoomMode )
	{
		if ( OverlayActor != None )
		{
			if ( OverlayActor.bIsPawn )
				Canvas.DrawActor( OverlayActor, false, false );
			else
				OverlayActor.RenderOverlays( Canvas );
		}
	}

	// Draw EMP overlay.
	if ( bEMPulsed )
	{
		// Draw the static overlay.
		if ( HeavyVisionStatic[0] == None )
			HeavyVisionStatic[0] = Texture( DynamicLoadObject( HeavyVisionStaticString[0], class'Texture' ) );
		Tex = HeavyVisionStatic[0];
		Canvas.Style = 3;
		Canvas.SetPos(0, 0);
		Canvas.DrawTile( Tex, Canvas.ClipX, Canvas.ClipY, 0, 0, Tex.USize, Tex.VSize );

		Canvas.DrawColor = DukeHUD(MyHUD).HUDColor;

		// Draw the reboot status screen.
		Canvas.Style = 3;
		if ( bGPFStart )
		{
			if ( OverloadGPFStart == None )
				OverloadGPFStart = SmackerTexture( DynamicLoadObject( OverloadGPFStartString, class'SmackerTexture' ) );
			OverloadGPFStart.pause = false;
			Tex = OverloadGPFStart;
			Canvas.SetPos( 4*DukeHUD(MyHUD).HUDScaleX, Canvas.ClipY - (Tex.VSize+4) * DukeHUD(MyHUD).HUDScaleY );
			Canvas.DrawTile( Tex, Tex.USize*DukeHUD(MyHUD).HUDScaleX, Tex.VSize*DukeHUD(MyHUD).HUDScaleY, 0, 0, Tex.USize, Tex.VSize );
			if ( OverloadGPFStart.currentFrame == 5 )
			{
				OverloadGPFStart.pause = true;
				bGPFStart = false;
				RebootPhase = 0;
				FlashTime = 0.4;
				bFlash = true;
			}
		}
		else if ( RebootPhase == 0 )
		{
			if ( OverloadGPFLoop == None )
				OverloadGPFLoop = SmackerTexture( DynamicLoadObject( OverloadGPFLoopString, class'SmackerTexture' ) );
			OverloadGPFLoop.pause = false;
			Tex = OverloadGPFLoop;
			Canvas.SetPos( 4*DukeHUD(MyHUD).HUDScaleX, Canvas.ClipY - (Tex.VSize+4) * DukeHUD(MyHUD).HUDScaleY );
			Canvas.DrawTile( Tex, Tex.USize*DukeHUD(MyHUD).HUDScaleX, Tex.VSize*DukeHUD(MyHUD).HUDScaleY, 0, 0, Tex.USize, Tex.VSize );
			if ( bFlash )
			{
				Canvas.DrawColor.R = 255;
				Canvas.DrawColor.G = 0;
				Canvas.DrawColor.B = 0;
				Canvas.SetPos( 4*DukeHUD(MyHUD).HUDScaleX, Canvas.ClipY - (Tex.VSize-10+4) * DukeHUD(MyHUD).HUDScaleY );
				if ( OverloadOverload == None )
					OverloadOverload = Texture( DynamicLoadObject( OverloadOverloadString, class'Texture' ) );
				Tex = OverloadOverload;
				Canvas.DrawTile( Tex, Tex.USize*DukeHUD(MyHUD).HUDScaleX, Tex.VSize*DukeHUD(MyHUD).HUDScaleY, 0, 0, Tex.USize, Tex.VSize );
			}
		}
		else if ( RebootPhase == 1 )
		{
			if ( OverloadBootStart == None )
				OverloadBootStart = SmackerTexture( DynamicLoadObject( OverloadBootStartString, class'SmackerTexture' ) );
			OverloadBootStart.pause = false;
			Tex = OverloadBootStart;
			Canvas.SetPos( 4*DukeHUD(MyHUD).HUDScaleX, Canvas.ClipY - (Tex.VSize+4)*DukeHUD(MyHUD).HUDScaleY );
			Canvas.DrawTile( Tex, Tex.USize*DukeHUD(MyHUD).HUDScaleX, Tex.VSize*DukeHUD(MyHUD).HUDScaleY, 0, 0, Tex.USize, Tex.VSize );
			if ( OverloadBootStart.currentFrame == 5 )
			{
				OverloadBootStart.pause = true;
				RebootPhase = 2;
				FlashTime = 0.4;
				bFlash = true;
			}
		}
		else if ( RebootPhase == 2 )
		{
			if ( OverloadBootLoop == None )
				OverloadBootLoop = SmackerTexture( DynamicLoadObject( OverloadBootLoopString, class'SmackerTexture' ) );
			OverloadBootLoop.pause = false;
			Tex = OverloadBootLoop;
			Canvas.SetPos( 4*DukeHUD(MyHUD).HUDScaleX, Canvas.ClipY - (Tex.VSize+4) * DukeHUD(MyHUD).HUDScaleY );
			Canvas.DrawTile( Tex, Tex.USize*DukeHUD(MyHUD).HUDScaleX, Tex.VSize*DukeHUD(MyHUD).HUDScaleY, 0, 0, Tex.USize, Tex.VSize );
			if ( bFlash )
			{
				Canvas.DrawColor.R = 255;
				Canvas.DrawColor.G = 0;
				Canvas.DrawColor.B = 0;
			}
			Canvas.SetPos( 4*DukeHUD(MyHUD).HUDScaleX, Canvas.ClipY - (Tex.VSize-10+4)*DukeHUD(MyHUD).HUDScaleY );
			if ( OverloadDegaussing == None )
				OverloadDegaussing = Texture( DynamicLoadObject( OverloadDegaussingString, class'Texture' ) );
			Tex = OverloadDegaussing;
			Canvas.DrawTile( Tex, Tex.USize*DukeHUD(MyHUD).HUDScaleX, Tex.VSize*DukeHUD(MyHUD).HUDScaleY, 0, 0, Tex.USize, Tex.VSize );
			Canvas.Font = font'HUDFont';
			Canvas.DrawColor.R = DukeHUD(MyHUD).HudColor.R;
			Canvas.DrawColor.G = DukeHUD(MyHUD).HudColor.G;
			Canvas.DrawColor.B = DukeHUD(MyHUD).HudColor.B;
			t1 = int(EmpTime);
			if (t1 > 9)
				d1 = int(left(string(t1), 1));
			else
				d1 = 0;
			d2 = int(right(string(t1), 1));
			t2 = int(100*(EmpTime - int(EmpTime)));
			if (t2 > 9)
				d3 = int(left(string(t2), 1));
			else
				d3 = 0;
			d4 = int(right(string(t2), 1));
			Canvas.StrLen("00:00", XL, YL);
			XPos = (OverloadBootLoop.VSize-18+4)*DukeHUD(MyHUD).HUDScaleX-(XL/2);
			YPos = Canvas.ClipY - 34*DukeHUD(MyHUD).HUDScaleY;
			Canvas.SetPos( XPos, YPos );
			Canvas.StrLen( "0", XL, YL );
			Canvas.DrawText( d1$" " );
			XPos += XL;
			Canvas.SetPos( XPos, YPos );
			Canvas.StrLen( "0", XL, YL );
			Canvas.DrawText( d2$" " );
			XPos += XL;
			Canvas.SetPos( XPos, YPos );
			Canvas.StrLen( ":", XL, YL );
			Canvas.DrawText( ":" );
			XPos += XL;
			Canvas.SetPos( XPos, YPos );
			Canvas.StrLen( "0", XL, YL );
			Canvas.DrawText( d3$" " );
			XPos += XL;
			Canvas.SetPos( XPos, YPos );
			Canvas.DrawText( d4 );
		}
		return;
	}
	else if ( bDegauss )
	{
		// Draw the static overlay.
		if ( HeavyVisionStatic[0] == None )
			HeavyVisionStatic[0] = Texture( DynamicLoadObject( HeavyVisionStaticString[0], class'Texture' ) );
		Tex = HeavyVisionStatic[0];
		Canvas.DrawColor = DukeHUD(MyHUD).WhiteColor;
		Canvas.Style = 3;
		Canvas.SetPos(0, 0);
		Canvas.DrawTile(Tex, Canvas.ClipX, Canvas.ClipY, 0, 0, Tex.USize, Tex.VSize);

		// Draw the degaussing overlay.
		Canvas.DrawColor = DukeHUD(MyHUD).WhiteColor;
		Canvas.Style = 4;
		if ( DegaussOverlay == None )
			DegaussOverlay = SmackerTexture( DynamicLoadObject( DegaussOverlayString, class'SmackerTexture' ) );
		Tex = DegaussOverlay;
		Canvas.SetPos( 0, 0 );
		Canvas.DrawTile(Tex, Canvas.ClipX, Canvas.ClipY, 0, 0, Tex.USize, Tex.VSize);
		if ( DegaussOverlay.currentFrame+1 == DegaussOverlay.GetFrameCount() )
		{
			DegaussOverlay.pause = true;
			bDegauss = false;
			PostDegaussFade = 1.0;
		}
	}
	else if ( PostDegaussFade > 0.0 )
	{
		if ( HeavyVisionStatic[0] == None )
			HeavyVisionStatic[0] = Texture( DynamicLoadObject( HeavyVisionStaticString[0], class'Texture' ) );
		Tex = HeavyVisionStatic[0];
		Canvas.DrawColor.R = 255*(PostDegaussFade/1.0);
		Canvas.DrawColor.G = 255*(PostDegaussFade/1.0);
		Canvas.DrawColor.B = 255*(PostDegaussFade/1.0);
		Canvas.Style = 3;
		Canvas.SetPos(0, 0);
		Canvas.DrawTile(Tex, Canvas.ClipX, Canvas.ClipY, 0, 0, Tex.USize, Tex.VSize);
	}

	// Draw Heatvision overlay.
    if ( (CameraStyle == PCS_HeatVision) && !bSniperZoomed )
	{
		if ( HeatVisionOverlay == None )
			HeatVisionOverlay = Texture( DynamicLoadObject( HeatVisionOverlayString, class'Texture' ) );
	    Tex = HeatVisionOverlay;
		if ( Tex == None )
			return;

		// Draw the static.
		if ( ZoomVisionSubtleStatic == None )
			ZoomVisionSubtleStatic = Texture( DynamicLoadObject( ZoomVisionSubtleStaticString, class'Texture' ) );
		Tex = ZoomVisionSubtleStatic;
		Canvas.Style = 4;
		Canvas.SetPos( 0, 0 );
		Canvas.DrawTile( Tex, Canvas.ClipX, Canvas.ClipY, 0, 0, Tex.USize, Tex.VSize );

		// Draw the glow.
		if ( HeatVisionGlow == None )
			HeatVisionGlow = Texture( DynamicLoadObject( HeatVisionGlowString, class'Texture' ) );
		Tex = HeatVisionGlow;
		Canvas.Style = 3;
		Canvas.SetPos(0, 0);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize);
		Canvas.SetPos(Canvas.ClipX/2, 0);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize, , , , true, , true );
		Canvas.SetPos(0, Canvas.ClipY/2);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize, , , , true, , , true );
		Canvas.SetPos(Canvas.ClipX/2, Canvas.ClipY/2);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize, , , , true, , true, true );

		// Draw the compass.
		Canvas.DrawColor = DukeHUD(MyHUD).TextColor;
		DrawCompass(Canvas, 0.5, 630);

		// Draw the overlay.
		Tex = HeatVisionOverlay;
		Canvas.DrawColor = DukeHUD(MyHUD).WhiteColor;
		Canvas.Style = 4;
		Canvas.SetPos(0, 0);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize);
		Canvas.SetPos(Canvas.ClipX/2, 0);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize, , , , true, , true );
		Canvas.SetPos(0, Canvas.ClipY/2);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize, , , , true, , , true );
		Canvas.SetPos(Canvas.ClipX/2, Canvas.ClipY/2);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize, , , , true, , true, true );

		// Draw the helper spam.
		if ( bHelperMessages )
		{
			HelperString = "Press '"$DukeHUD(MyHUD).SpecialKeys[1]$"' to zoom.";
			Canvas.Style = 3;
			Canvas.Font = DukeHUD(MyHUD).MediumFont;
			Canvas.DrawColor = DukeHUD(MyHUD).TextColor;
			Canvas.StrLen( HelperString, XL, YL );
			Canvas.SetPos( Canvas.ClipX - XL - 32*DukeHUD(MyHUD).HUDScaleX, Canvas.ClipY - YL*2 );
			Canvas.DrawText( HelperString, false );
		}
	}

	// Draw Nightvision overlay.
	if ( (CameraStyle == PCS_NightVision) && !bSniperZoomed )
	{
		// Draw the static.
		if ( ZoomVisionSubtleStatic == None )
			ZoomVisionSubtleStatic = Texture( DynamicLoadObject( ZoomVisionSubtleStaticString, class'Texture' ) );
		Tex = ZoomVisionSubtleStatic;
		Canvas.Style = 4;
		Canvas.SetPos(0, 0);
		Canvas.DrawTile(Tex, Canvas.ClipX, Canvas.ClipY, 0, 0, Tex.USize, Tex.VSize);

		// Draw the glow.
		if ( NightVisionGlow == None )
			NightVisionGlow = Texture( DynamicLoadObject( NightVisionGlowString, class'Texture' ) );
		Tex = NightVisionGlow;
		Canvas.Style = 3;
		Canvas.SetPos(0, 0);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize);
		Canvas.SetPos(Canvas.ClipX/2, 0);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize, , , , true, , true );
		Canvas.SetPos(0, Canvas.ClipY/2);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize, , , , true, , , true );
		Canvas.SetPos(Canvas.ClipX/2, Canvas.ClipY/2);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize, , , , true, , true, true );

		// Draw the compass.
		Canvas.DrawColor = DukeHUD(MyHUD).TextColor;
		DrawCompass(Canvas, 0.5, 604);

		// Draw the overlay.
		if ( NightVisionOverlay == None )
			NightVisionOverlay = Texture( DynamicLoadObject( NightVisionOverlayString, class'Texture' ) );
		Tex = NightVisionOverlay;
		Canvas.DrawColor = DukeHUD(MyHUD).WhiteColor;
		Canvas.Style = 4;
		Canvas.SetPos(0, 0);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize);
		Canvas.SetPos(Canvas.ClipX/2, 0);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize, , , , true, , true );
		Canvas.SetPos(0, Canvas.ClipY/2);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize, , , , true, , , true );
		Canvas.SetPos(Canvas.ClipX/2, Canvas.ClipY/2);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize, , , , true, , true, true );

		// Draw the helper spam.
		if ( bHelperMessages )
		{
			HelperString = "Press '"$DukeHUD(MyHUD).SpecialKeys[1]$"' to zoom.";
			Canvas.Style = 3;
			Canvas.Font = DukeHUD(MyHUD).MediumFont;
			Canvas.DrawColor = DukeHUD(MyHUD).TextColor;
			Canvas.StrLen( HelperString, XL, YL );
			Canvas.SetPos( Canvas.ClipX - XL - 32*DukeHUD(MyHUD).HUDScaleX, Canvas.ClipY - YL*2 );
			Canvas.DrawText( HelperString, false );
		}
	}

	// Draw the zoom overlay.
	if ( Level.TimeSeconds - ZoomChangeTime < 0.10 )
	{
		Canvas.Style = 1;
		Tex = texture'WhiteTexture';
		Canvas.DrawColor.R = 0;
		Canvas.DrawColor.G = 0;
		Canvas.DrawColor.B = 0;
		Canvas.SetPos(0, 0);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize);
		Canvas.SetPos(Canvas.ClipX/2, 0);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize, , , , true, , true );
		Canvas.SetPos(0, Canvas.ClipY/2);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize, , , , true, , , true );
		Canvas.SetPos(Canvas.ClipX/2, Canvas.ClipY/2);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize, , , , true, , true, true );
	} 
	else if ( (CameraStyle == PCS_ZoomMode) && !bSniperZoomed )
	{
		Canvas.Font = DukeHUD(MyHUD).MediumFont;
		Canvas.DrawColor = DukeHUD(MyHUD).WhiteColor;

		// Draw the static.
		if ( ZoomVisionSubtleStatic == None )
			ZoomVisionSubtleStatic = Texture( DynamicLoadObject( ZoomVisionSubtleStaticString, class'Texture' ) );
		Tex = ZoomVisionSubtleStatic;
		Canvas.Style = 4;
		Canvas.SetPos(0, 0);
		Canvas.DrawTile(Tex, Canvas.ClipX, Canvas.ClipY, 0, 0, Tex.USize, Tex.VSize);

		// Draw the glow.
		Canvas.Style = 3;
		Tex = ZoomVisionGlow;
		if ( ZoomVisionGlow == None )
			ZoomVisionGlow = Texture( DynamicLoadObject( ZoomVisionGlowString, class'Texture' ) );
		Canvas.SetPos(0, 0);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize);
		Canvas.SetPos(Canvas.ClipX/2, 0);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize, , , , true, , true );
		Canvas.SetPos(0, Canvas.ClipY/2);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize, , , , true, , , true );
		Canvas.SetPos(Canvas.ClipX/2, Canvas.ClipY/2);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize, , , , true, , true, true );

		// Draw the zoom factor.
		Canvas.DrawColor = DukeHUD(MyHUD).TextColor;
		if (ZoomLevel == 1)
			ZoomString = "5.0X";
		else if (ZoomLevel == 2)
			ZoomString = "10.0X";
		Canvas.Style = 1;
		Canvas.StrLen( ZoomString, XL, YL );
		Canvas.SetPos( (Canvas.ClipX - XL)/2, 160*DukeHUD(MyHUD).HUDScaleY );
		Canvas.DrawText( ZoomString, false );

		// Draw the compass.
		Canvas.DrawColor = DukeHUD(MyHUD).TextColor;
		DrawCompass(Canvas, 0.5, 600);

		// Draw the overlay.
		if ( ZoomVisionOverlay == None )
			ZoomVisionOverlay = Texture( DynamicLoadObject( ZoomVisionOverlayString, class'Texture' ) );
		Tex = ZoomVisionOverlay;
		Canvas.DrawColor = DukeHUD(MyHUD).WhiteColor;
		Canvas.Style = 4;
		Canvas.SetPos(0, 0);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize);
		Canvas.SetPos(Canvas.ClipX/2, 0);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize, , , , true, , true );
		Canvas.SetPos(0, Canvas.ClipY/2);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize, , , , true, , , true );
		Canvas.SetPos(Canvas.ClipX/2, Canvas.ClipY/2);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize, , , , true, , true, true );
	}

	Canvas.Style = 1;
}

function DrawCompass(Canvas Canvas, float CompassPosition, float BaseY)
{
	local float XL, YL, SmallYPos, MedYPos, YPos, RotFactor, RotLen, RotOffset;
	local int Yaw;
	local float OldClipX, OldClipY;
	local float OldOriginX, OldOriginY, DrawAdjustX;
	local font SmallFont, MediumFont;

	SmallFont = DukeHUD(MyHUD).SmallFont;
	MediumFont = DukeHUD(MyHUD).MediumFont;

	// Adjust origin.
	OldOriginX = Canvas.OrgX;
	OldOriginY = Canvas.OrgY;
	Canvas.SetOrigin( Canvas.ClipX/2 - 100*DukeHUD(MyHUD).HUDScaleX, Canvas.OrgY );
	DrawAdjustX -= Canvas.ClipX/2 - 100*DukeHUD(MyHUD).HUDScaleX;

	// Adjust clipping region.
	OldClipX = Canvas.ClipX;
	OldClipY = Canvas.ClipY;
	Canvas.SetClip( 200*DukeHUD(MyHUD).HUDScaleX, Canvas.ClipY );

	Yaw = Normalize(ViewRotation).Yaw - Level.North;

	RotLen = 900;
	RotOffset = (1024 + RotLen*2)/2;

	Canvas.Font = MediumFont;
	Canvas.StrLen( "NE", XL, YL );
	MedYPos = (BaseY-YL/2)*DukeHUD(MyHUD).HUDScaleY;

	Canvas.Font = SmallFont;
	Canvas.StrLen( "NE", XL, YL );
	SmallYPos = (BaseY-YL/2)*DukeHUD(MyHUD).HUDScaleY;

	// South
	Canvas.Font = MediumFont;
	RotFactor = Yaw / 65535.0;
	RotFactor += CompassPosition;
	if (RotFactor < 0.5)
		RotFactor += 1.0;
	Canvas.StrLen( "S", XL, YL );
	Canvas.SetPos( (-RotFactor * RotLen + RotOffset + DrawAdjustX) * DukeHUD(MyHUD).HUDScaleX - (XL/2), MedYPos );
	Canvas.DrawText( "S", false, false, true );

	DrawCompassHash(Canvas, 0+4096, RotLen, RotOffset, CompassPosition, SmallYPos, DrawAdjustX);

	// SouthEast
	Canvas.Font = SmallFont;
	RotFactor = (Yaw+8192) / 65535.0;
	RotFactor += CompassPosition;
	if (RotFactor < 0.5)
		RotFactor += 1.0;
	Canvas.StrLen( "SE", XL, YL );
	Canvas.SetPos( (-RotFactor * RotLen + RotOffset + DrawAdjustX) * DukeHUD(MyHUD).HUDScaleX - (XL/2), SmallYPos );
	Canvas.DrawText( "SE", false, false, true );

	DrawCompassHash(Canvas, 8192+4096, RotLen, RotOffset, CompassPosition, SmallYPos, DrawAdjustX);

	// East
	Canvas.Font = MediumFont;
	RotFactor = (Yaw+16384) / 65535.0;
	RotFactor += CompassPosition;
	if (RotFactor < 0.5)
		RotFactor += 1.0;
	Canvas.StrLen( "E", XL, YL );
	Canvas.SetPos( (-RotFactor * RotLen + RotOffset + DrawAdjustX) * DukeHUD(MyHUD).HUDScaleX - (XL/2), MedYPos );
	Canvas.DrawText( "E", false, false, true );

	DrawCompassHash(Canvas, 16384+4096, RotLen, RotOffset, CompassPosition, SmallYPos, DrawAdjustX);

	// NorthEast
	Canvas.Font = SmallFont;
	RotFactor = (Yaw+24576) / 65535.0;
	RotFactor += CompassPosition;
	if (RotFactor < 0.5)
		RotFactor += 1.0;
	Canvas.StrLen( "NE", XL, YL );
	Canvas.SetPos( (-RotFactor * RotLen + RotOffset + DrawAdjustX) * DukeHUD(MyHUD).HUDScaleX - (XL/2), SmallYPos );
	Canvas.DrawText( "NE", false, false, true );

	DrawCompassHash(Canvas, 24576+4096, RotLen, RotOffset, CompassPosition, SmallYPos, DrawAdjustX);

	// North
	Canvas.Font = MediumFont;
	RotFactor = (Yaw+32768) / 65535.0;
	RotFactor += CompassPosition;
	if (RotFactor < 0.5)
		RotFactor += 1.0;
	Canvas.StrLen( "N", XL, YL );
	Canvas.SetPos( (-RotFactor * RotLen + RotOffset + DrawAdjustX) * DukeHUD(MyHUD).HUDScaleX - (XL/2), MedYPos );
	Canvas.DrawText( "N", false, false, true );

	DrawCompassHash(Canvas, 32768+4096, RotLen, RotOffset, CompassPosition, SmallYPos, DrawAdjustX);

	// NorthWest
	Canvas.Font = SmallFont;
	RotFactor = (Yaw+40960) / 65535.0;
	RotFactor += CompassPosition;
	if (RotFactor < 0.5)
		RotFactor += 1.0;
	Canvas.StrLen( "NW", XL, YL );
	Canvas.SetPos( (-RotFactor * RotLen + RotOffset + DrawAdjustX) * DukeHUD(MyHUD).HUDScaleX - (XL/2), SmallYPos );
	Canvas.DrawText( "NW", false, false, true );

	DrawCompassHash(Canvas, 40960+4096, RotLen, RotOffset, CompassPosition, SmallYPos, DrawAdjustX);

	// West
	Canvas.Font = MediumFont;
	RotFactor = (Yaw+49152) / 65535.0;
	RotFactor += CompassPosition;
	if (RotFactor < 0.5)
		RotFactor += 1.0;
	Canvas.StrLen( "W", XL, YL );
	Canvas.SetPos( (-RotFactor * RotLen + RotOffset + DrawAdjustX) * DukeHUD(MyHUD).HUDScaleX - (XL/2), MedYPos );
	Canvas.DrawText( "W", false, false, true );

	DrawCompassHash(Canvas, 49152+4096, RotLen, RotOffset, CompassPosition, SmallYPos, DrawAdjustX);

	// SouthWest
	Canvas.Font = SmallFont;
	RotFactor = (Yaw+57344) / 65535.0;
	RotFactor += CompassPosition;
	if (RotFactor < 0.5)
		RotFactor += 1.0;
	else if (RotFactor > 1.5)
		RotFactor -= 1.0;
	Canvas.StrLen( "SW", XL, YL );
	Canvas.SetPos( (-RotFactor * RotLen + RotOffset + DrawAdjustX) * DukeHUD(MyHUD).HUDScaleX - (XL/2), SmallYPos );
	Canvas.DrawText( "SW", false, false, true );

	DrawCompassHash(Canvas, 57344+4096, RotLen, RotOffset, CompassPosition, SmallYPos, DrawAdjustX);

	Canvas.SetClip( OldClipX, OldClipY );
	Canvas.SetOrigin( OldOriginX, OldOriginY );
}

function DrawCompassHash(Canvas Canvas, float HashPos, float RotLen, float RotOffset, float CompassPosition, float YPos, float DrawAdjustX)
{
	local float RotFactor, XL, YL;
	local int Yaw;

	Yaw = Normalize(ViewRotation).Yaw;

	Canvas.Font = DukeHUD(MyHUD).SmallFont;
	RotFactor = (Yaw+HashPos) / 65535.0;
	RotFactor += CompassPosition;
	if (RotFactor < 0.5)
		RotFactor += 1.0;
	else if (RotFactor > 1.5)
		RotFactor -= 1.0;
	Canvas.StrLen( "|", XL, YL );
	Canvas.SetPos( (-RotFactor * RotLen + RotOffset + DrawAdjustX) * DukeHUD(MyHUD).HUDScaleX - (XL/2), YPos );
	Canvas.DrawText( "|", false, false, true );
}

function bool PlayWAM( Weapon.WAMEntry PlayAnim )
{
    if ( PlayAnim.PlayNone ) // Force a play of None
    {
        switch ( PlayAnim.AnimChan )
        {
            case WAC_All:
                PlayAllAnim( 'None' );
                break;
            case WAC_Top:
                PlayTopAnim( 'None' );
                break;
            case WAC_Bottom:
                PlayBottomAnim( 'None' );
                break;
            case WAC_Special:
                PlaySpecialAnim( 'None' );
                break;
            default:
                break;

        }
        return true;
    }

    if ( PlayAnim.AnimSeq == '' )
    {
		// Noisy debug message.
		//Log( self@"Weapon::PlayWAM: Animation "$PlayAnim.DebugString$" has no AnimSeq set" );
        return false;
    }


    switch ( PlayAnim.AnimChan )
    {
        case WAC_All:
            PlayAllAnim( PlayAnim.AnimSeq, PlayAnim.AnimRate, PlayAnim.AnimTween, PlayAnim.AnimLoop );
            break;
        case WAC_Bottom:
            PlayBottomAnim( PlayAnim.AnimSeq, PlayAnim.AnimRate, PlayAnim.AnimTween, PlayAnim.AnimLoop );
            break;
        case WAC_Top:
            PlayTopAnim( PlayAnim.AnimSeq, PlayAnim.AnimRate, PlayAnim.AnimTween, PlayAnim.AnimLoop );
            break;
        case WAC_Special:
            PlaySpecialAnim( PlayAnim.AnimSeq, PlayAnim.AnimRate, PlayAnim.AnimTween, PlayAnim.AnimLoop );
            break;
        default:
            break;
    }
}

function EnterControlState_Jetpack()
{
	//Log( "EnterControlState_Jetpack" );
	bLaissezFaireBlending	= true;
	JetPackTime				= JetPackMax;
	LastJetpackTime			= Level.TimeSeconds;
	Super.EnterControlState_Jetpack();
	
	// Clear out the all channel
	PlayAllAnim( 'None' );
}

function ExitControlState_Jetpack()
{
	//Log( "ExitControlState_Jetpack" );
	bLaissezFaireBlending	= false;
	JetPackTime				= 0;
	Super.ExitControlState_Jetpack();
}

function ScoreHit()
{
	HitCounter++;
}

// JEP... 

//
//	SOS communication code.  
//	This code takes control over UseDown, and UseUp if Duke has an Incoming call...
//

//===========================================================================
//	UseDown
//===========================================================================
exec function UseDown()
{
	if (SOSStatus == SOS_IncomingCall)			// If we have an Incoming call, answer the call instead
	{
		//BroadcastMessage("Answering call...");
		DukeHUD(MyHUD).bHideHUD = true;
		//SOSStatus = SOS_AnsweringCall;		
		SOSStatus = SOS_AnsweringCallFadingOut;
		IncomingCallTime = 0.0f;
		return;
	}
	else if (SOSStatus != SOS_Done)
		return;

	// Call super by default
	Super.UseDown();
}

//===========================================================================
//	UseUp
//===========================================================================
exec function UseUp()
{
	if (SOSStatus != SOS_Done && bUse == 0)
		return;

	// Call super by default
	Super.UseUp();
}

//===========================================================================
//	JumpDown
//===========================================================================
exec function JumpDown()
{
	if (SOSStatus != SOS_Done && SOSStatus != SOS_IncomingCall)
		return;
	
	Super.JumpDown();
}

//===========================================================================
// SetupIncomingSOSCall
//===========================================================================
function bool SetupIncomingSOSCall(SOSTrigger Trigger, string SOSFreq)
{
	//BroadcastMessage("Setting up Incoming call...");

	if (SOSStatus != SOS_Done)
		return false;			// Already got a call Incoming, let the caller know

	SOSStatus = SOS_IncomingCall;
	SOSInstigator = Trigger;
	IncomingCallTime = 0.0;
	NextRingTime = 3.5;
	SOSFreqString = SOSFreq;

	CurrentFlashScale = FlashScale;

	return true;
}

//===========================================================================
// EndSOSCall
//===========================================================================
function bool EndSOSCall(SOSTrigger Trigger)
{
	if (SOSStatus != SOS_CallInProgress)
		return false;

	if (SOSInstigator != Trigger)
		return false;

	//BroadcastMessage("Engine call...");

	SOSStatus = SOS_EndingCallFadingOut;
	CurrentFlashScale = FlashScale;
	IncomingCallTime = 0.0f;
	
	return true;
}

// ... JEP


//===========================================================================
// EndSpree
//===========================================================================
function EndSpree( PlayerReplicationInfo Killer, PlayerReplicationInfo Other )
{
	if ( ( Killer == Other ) || ( Killer == None ) )
	{
		ReceiveLocalizedMessage( class'dnKillingSpreeMessage', 1, None, Other );
	}
	else
	{
		ReceiveLocalizedMessage( class'dnKillingSpreeMessage', 0, Other, Killer );
	}
}

exec function TestSpree( int Num )
{
	ReceiveLocalizedMessage( class'dnKillingSpreeMessage', Num, PlayerReplicationInfo );	
}

exec function TestFirstBlood()
{
	ReceiveLocalizedMessage( class'dnFirstBloodMessage', 0, PlayerReplicationInfo );	
}

exec function TestDeathMessage()
{
	ReceiveLocalizedMessage( class'dnDeathMessage', 0, PlayerReplicationInfo, PlayerReplicationInfo,, class'MightyFootDamage' );
}

exec function TestDeath( string DamageType )
{
	local class<DamageType> DT;

	DT = class<DamageType>( DynamicLoadObject( DamageType, class'Class' ) );	

	Died( self, DT, Location );
}


//===========================================================================
// Bomb Stuff
//===========================================================================

function PlantBomb()
{
    local vector X,Y,Z, StartLocation;
    local PlantedBomb	bomb;
	local float			ForceScale;
	local rotator		AdjustedAim, TossRotation;
    local vector		newLocation;
	local int Force; 
	local int ZForce;
	local Inventory			InventoryItem;
	local class<Inventory>	InvClass;

	Force	= 200;
	ZForce	= 100;

    GetAxes( ViewRotation,X, Y, Z );
	
    bomb = spawn( class'PlantedBomb',,,Location + X * ( class'PlantedBomb'.default.CollisionRadius * 3 ) );

	if ( bomb == None )
	{
		ReceiveLocalizedMessage( class'dnBombMessage', 5 );
		return;
	}

    AdjustedAim		= AdjustAim( 1000000, bomb.Location, 0, false, false );
	bomb.Velocity	+= Normal( vector( AdjustedAim ) ) * Force * bomb.GetForceScale();
	bomb.Velocity.Z += ZForce * (1.0 - abs(Normal(vector(AdjustedAim)).Z));
	
	bomb.StartCountdown();

	InvClass		= class<Inventory>(DynamicLoadObject( "dnGame.Bomb", class'Class' ));
	InventoryItem	= FindInventoryType( InvClass );
	if ( InventoryItem != None )
	{
		InventoryItem.Destroy();
	}
	
	BroadcastLocalizedMessage( class'dnBombMessage', 0, PlayerReplicationInfo );

	if ( dnTeamGame_Bomb( Level.Game ) != None )
	{
		dnTeamGame_Bomb( Level.Game ).BombPlanted();
	}
}

function ClientStartDefuseBomb( Actor b )
{
	local HUDIndexItem_DefuseBomb bombHUD;

	// Put a defuse message on the player's HUD
	bombHUD = spawn( class'HUDIndexItem_DefuseBomb' );
	DukeHUD( MyHUD ).RegisterBombItem( bombHUD );
	bombHUD.theBomb = PlantedBomb(b);

	PlantedBomb(b).ClientStartDefuse();
}

function ClientStopDefuseBomb( Actor b )
{
	DukeHUD( MyHUD ).RemoveBombItem();
	PlantedBomb(b).ClientStopDefuse();
}

function CheckDropBomb()
{
	local Inventory			InventoryItem;
	local class<Inventory>	InvClass;

	InvClass		= class<Inventory>(DynamicLoadObject( "dnGame.Bomb", class'Class' ));
	InventoryItem	= FindInventoryType( InvClass );
	if ( InventoryItem != None )
	{
		DropBomb();
		InventoryItem.Destroy();
	}
}

function DropBomb()
{
    local vector	X,Y,Z, StartLocation;
	local float		ForceScale;
	local rotator	AdjustedAim, TossRotation;
    local vector	newLocation;
	local int		Force, ZForce; 
    local Bomb		bomb;

	Force	= 200;
	ZForce	= 200;

    GetAxes( ViewRotation,X, Y, Z );
	
    bomb = spawn( class'Bomb' );
    bomb.SetLocation( Location +  X * bomb.CollisionRadius * 2 );    
    AdjustedAim		= AdjustAim( 1000000, bomb.Location, 0, false, false );
	bomb.Velocity	+= Normal( vector( AdjustedAim ) );
	bomb.Velocity.Z += ZForce * (1.0 - abs(Normal(vector(AdjustedAim)).Z));
	BroadcastLocalizedMessage( class'dnBombMessage', 2, PlayerReplicationInfo );
}

exec function SetSpeed(float speed)
{
    GroundSpeed = speed;
    AirSpeed = speed;
}

defaultproperties
{	
    Handedness=-1.000000
    Mesh=c_characters.duke
    bIsHuman=true
    BaseEyeHeight=+00027.000000
    EyeHeight=+00027.000000
    CollisionRadius=+00017.000000
    CollisionHeight=+00039.000000
    Buoyancy=+00099.000000
    bSinglePlayer=true
    Land=Land1
    UnderWaterTime=30
    bCanStrafe=True
    MeleeRange=+00050.000000
    Intelligence=BRAINS_HUMAN
    GroundSpeed=+00320.000000
    AirSpeed=+00320.000000
    AccelRate=+02048.000000
    DrawType=DT_Mesh
    LightBrightness=70
    LightHue=40
    LightSaturation=128
    LightRadius=6
    RotationRate=(Pitch=3072,Yaw=65000,Roll=2048)
    AnimSequence=A_Walk
    bIsMultiSkinned=True
    AirControl=+0.35
    WeaponPriority(0)=MightyFoot
    WeaponPriority(1)=pistol
    WeaponPriority(2)=shotgun
    WeaponPriority(3)=m16
    WeaponPriority(4)=rpg
    WeaponPriority(5)=shrinkray
    AmbientGlow=17
    Tag=DukePlayer
    CarcassType=class'DukePlayerCarcass'

    ExitSplash=sound'a_generic.water.splashout12'
    BigSplash=sound'a_generic.water.splashin01'
    LittleSplash(0)=sound'a_generic.water.splashout05'
    LittleSplash(1)=sound'a_generic.water.splashout22'
    WaterAmbience=sound'a_generic.water.uwbnomask'

    BloodHitDecalName="dnGame.dnBloodHit"
    BloodPuffName="dnParticles.dnBloodFX"

    SOSPowerOnSound=sound'a_inventory.SOS.SOSVisOn'
    SOSPowerOffSound=sound'a_inventory.SOS.SOSVisOff'

    GrabSound=sound'a_generic.whoosh.WhooshGrab1'
    TossSound=sound'a_generic.whoosh.WhooshThrow1'

    GibbySound(0)=sound'a_impact.body.ImpactBody15a'
    GibbySound(1)=sound'a_impact.body.ImpactBody18a'
    GibbySound(2)=sound'a_impact.body.ImpactBody19a'
	
    HitBones(0)=Abdomen
    HitBones(1)=Chest
    HitBones(2)=Head
    HitBones(3)=Pelvis
    HitBones(4)=Bicep_L
    HitBones(5)=Bicep_R
    HitBones(6)=Thigh_L
    HitBones(7)=Thigh_R
    HitBones(8)=Foot_L
    HitBones(9)=Foot_R
    HitBones(10)=Hand_L
    HitBones(11)=Hand_R

    PeripheralVision=1.0

	EMPDegaussSound=sound'dnsweapn.EMP.EMPDegauss'
	EMPStaticSound=sound'dnsweapn.EMP.RadStaticLp05'

	LensWaterLightString="hud_effects.lenswater1BC"
	LensWaterHeavyString="hud_effects.lenswater2BC"
	RainFade=3.0
	AmbientRain=sound'a_ambient.rain.RainLp01'
	AmbientRainGusty=sound'a_ambient.rain.RainGustyLp01'
	ThunderFar(0)=sound'a_ambient.thunder.ThunderFar01'
	ThunderFar(1)=sound'a_ambient.thunder.ThunderFar02'
	ThunderMed(0)=sound'a_ambient.thunder.ThunderMed01'
	ThunderMed(1)=sound'a_ambient.thunder.ThunderMed02'

	HitPackageClass=class'HitPackage_Flesh'
	ImmolationClass="dnGame.dnPawnImmolation"
	ShrinkClass="dnGame.dnPawnShrink"

	PuddleSplashStepEffect=class'dnCharacterFX_Water_FootSplashPuddle'
	SplashStepEffect=class'dnCharacterFX_Water_FootSplash'
	FireStepEffect=class'dnFlameThrowerFX_PersonBurn_Footstep'
	FireStepEffectShrunk=class'dnFlameThrowerFX_Shrunk_PersonBurn_Footstep'
	JetpackMax=0.7
	
	HitNotificationSounds(0)=Sound'dnGame.DukePlayer.HitNotificationSound'
	HitNotificationSounds(1)=Sound'dnGame.DukePlayer.HitNotificationSound'
	HitNotificationSounds(2)=Sound'dnGame.DukePlayer.HitNotificationSound'
	HitNotificationSounds(3)=Sound'dnGame.DukePlayer.HitNotificationSound'	
	HitNotificationNames(0)="Wookie1"
	HitNotificationNames(1)="Wookie2"
	HitNotificationNames(2)="Wookie3"
	HitNotificationNames(3)="Wookie4"
	numHitNotificationNames=8

	ZipperSound=sound'a_dukevoice.DukeLeak.DNZipper04'
	PissSound=sound'a_dukevoice.DukeLeak.DNLeak07'

    ZoomVisionSubtleStaticString="hud_effects.subtledistort1.visionstaticD00"
    ZoomVisionGlowString="hud_effects.zoomglow1BC"
    ZoomVisionOverlayString="hud_effects.zoomblack1BC"

    HeavyVisionStaticString(0)="hud_effects.visionstaticb0"
    HeavyVisionStaticString(1)="hud_effects.visionstaticb1"
    HeavyVisionStaticString(2)="hud_effects.visionstaticb2"
    HeavyVisionStaticString(3)="hud_effects.visionstaticb3"
    HeavyVisionStaticString(4)="hud_effects.visionstaticb4"
    HeavyVisionStaticString(5)="hud_effects.visionstaticb5"
    HeavyVisionStaticString(6)="hud_effects.visionstaticb6"
    HeavyVisionStaticString(7)="hud_effects.visionstaticb7"
    HeavyVisionStaticString(8)="hud_effects.visionstaticb8"
    HeavyVisionStaticString(9)="hud_effects.visionstaticb9"

    OverloadBootStartString="hud_effects.overloadboot_start"
    OverloadBootLoopString="hud_effects.overloadboot_loop"
    OverloadGPFStartString="hud_effects.overloadgpf_start"
    OverloadGPFLoopString="hud_effects.overloadgpf_loop"
    OverloadOverloadString="hud_effects.gpf_overload"
    OverloadDegaussingString="hud_effects.gpf_degaussing"
    DegaussOverlayString="hud_effects.gpf_degauss"

    HeatVisionOverlayString="hud_effects.heatblack1BC"
    HeatVisionGlow="hud_effects.heatglow1BC"
    NightVisionOverlay="hud_effects.nightblack1BC"
    NightVisionGlow="hud_effects.nightglow1BC"

	ChatBeepSound=Sound'a_inventory.SOS.SOSVisOn'

	bTakesDOT=true
    bFlammable=true
    bFreezable=true
	bShrinkable=true
	MyClassName="Basic Player"

    QMenuUse=Sound'a_generic.Menu.QMenuUse1'
}