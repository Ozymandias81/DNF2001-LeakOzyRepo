class Grunt extends HumanNPC;

#exec OBJ LOAD FILE=..\sounds\dnsweapn.dfx
var SniperPoint TestDot;

var bool bIsTurning;
var bool bAnimatePain;
var dnTossedGrenade MyBomb;
var vector RetreatLocation;

var bool		bGottaReload;
var Actor RetreatDestination;
var bool bKneelAtStartup;
var bool bRetreatAtStartup;
var bool bRollLeftOnSpawn;
var bool bRollRightOnSpawn;
var bool bStrafeLeftOnSpawn;
var bool bStrafeRightOnSpawn;
var Actor TempEnemy;
var bool bContinueFireDisabled;
var bool bDodgeSidestepDisabled;
var vector LastSeenLocation;
var bool bCanSayAttackPhrase;
var name RetreatTag;
var() float MaxCoverDistance			?( "Maximum distance a selectable cover point can be (in units) away from me." );
var rotator AYaw1, AYaw2;
var() name InactiveStance, ActiveStance;
const TIMER_Crouch	= 1;
var			CoverSpot			CurrentCoverSpot;
var bool bWaitForOrder;
var( AIStartup ) name	InitialCoverTag;
var( AIStartup ) bool	bUseInitialCoverTag;
var( AIStartup ) bool	bCoverOnAcquisition		?( "I will take cover immediately when enemy first acquired." );

var bool bOneHandedPistol;
var AIFireController	FireController;
var AICoverController	CoverController;

var FocusPoint TestFocus;
var NavigationPoint CurrentCrouchNode;
var bool bRolling, bIntoCrouch;
var byte DodgeLeft, DodgeRight;
var vector TurnDestination;
const MaxCarriedWeapons = 8;
var pawn OrderTarget;
var bool bWaitingForOrder;
var( AI ) name SpecialCoverTag;
var( AI ) bool bCanAltFire;

// SetcallBackTimer( time, true/false, function name )
// EndCallBackTimer()

function EnablePainAnims()
{
	bAnimatePain = true;
}

function SetAutoFireOn()
{
	local float i;

	if( Weapon.IsA( 'Pistol' ) )
		i = 0.5;
	else if( Weapon.IsA( 'Shotgun' ) )
		i = 0.15;
	else if( Weapon.IsA( 'm16' ) )
		i = 0.15;
	
	SetCallBackTimer( i, true, 'AutoFireWeapon' );
}

function SetAutoFireOff()
{
	EndCallBackTimer( 'AutoFireWeapon' );
}

function AutoFireWeapon()
{
	// FIXME: Auto reload weapon (temporary).
	if( Weapon.GottaReload() )
	{
		dnWeapon( Weapon ).AmmoType.AddAmmo( 9999, 0 );
		if( Weapon.IsA( 'Pistol' ) )
			Weapon.AmmoLoaded = 8;
		else
			Weapon.AmmoLoaded = 50;
	}
	bFire = 1;
	dnWeapon( Weapon ).FireAnim.AnimTween = 0.1;
	PlayWeaponFire();
	Weapon.Fire();
}

simulated function PostBeginPlay()
{
	local int i;
	local bool bMounted;
	local class<Weapon> WeapClass;

	// log( self$" 1 Postbeginplay at "$level.timeseconds );
	bCanSayAttackPhrase = true;
	bAnimatePain = true;
	bWeaponNoAnimSound = true;
	bMuffledHearing = true;
	bCanHeadTrack = true;
	bCanTorsoTrack = true;

	if( bSnatched && bAggressiveToPlayer )
	{
		bVisiblySnatched = true;
		SpawnMiniTentacles();
	}
	// log( self$" 2 Postbeginplay at "$level.timeseconds );

	if( self.IsA( 'NPC' ) && MultiSkins[ 0 ] != None )
	{
		if( MultiSkins[ 0 ] == texture'm_characters.MaleHead1ARC' )
			NPCFaceNum = 1;
		else if( MultiSkins[ 0 ] == texture'm_characters.MaleHead2ARC' )
			NPCFaceNum = 2;
		else if( MultiSkins[ 0 ] == texture'm_characters.MaleHead3ARC' )
			NPCFaceNum = 3;
		else if( MultiSkins[ 0 ] == texture'm_characters.MaleHead4ARC' )
			NPCFaceNum = 4;
		else if( MultiSkins[ 0 ] == texture'm_characters.MaleHead5ARC' )
			NPCFaceNum = 5;
	}
	// log( self$" 3 Postbeginplay at "$level.timeseconds );

	bCanSayPinDownPhrase = true;
	SetFacialExpression( FacialExpression );
	if( LegHealthLeft == 0 )
		LegHealthLeft = 1 + Rand( 1 );
	if( LegHealthRight == 0 )
		LegHealthRight = LegHealthLeft;

	if( bShieldUser )
		TimeBetweenStanding = 9;

	bCanEmergencyJump = true;
	SetControlState( CS_Normal );

	// log( self$" 4 Postbeginplay at "$level.timeseconds );

	SetPartsSequences();
	if( bShieldUser )
		CreatureGiveWeapon( class'Pistol', 300, 300 );
//	else if( bSteelSkin )
//		CreatureGiveWeapon( class'RPG', 500, 500 );
	else if( bSniper )
		CreatureGiveWeapon( class<Weapon>( DynamicLoadObject( "dnGame.SniperRifle", class'Class' ) ), 500, 500 );

	else if( !bSteelSkin )
	{
	// log( self$" 5 Postbeginplay at "$level.timeseconds );

		for( i = MaxCarriedWeapons; i >= 0; i-- )
		{
			if( WeaponInfo[ i ].WeaponClass != "" )
			{
				if( Owner != None && Owner.IsA( 'CreatureFactory' ) )
				{
					if( !CreatureFactory( Owner ).bUseMyWeapons )
					{
						WeapClass = class<Weapon>( DynamicLoadObject( WeaponInfo[ i ].WeaponClass, class'Class' ) );
						CreatureGiveWeapon( WeapClass, WeaponInfo[ i ].PrimaryAmmoCount, WeaponInfo[ i ].AltAmmoCount );
					}
				}
				else if( !Owner.IsA( 'AIClimbControl' ) || !AIClimbControl( Owner ).bUseWeaponOverride )
				{
					WeapClass = class<Weapon>( DynamicLoadObject( WeaponInfo[ i ].WeaponClass, class'Class' ) );
					CreatureGiveWeapon( WeapClass, WeaponInfo[ i ].PrimaryAmmoCount, WeaponInfo[ i ].AltAmmoCount );
				}
			}
		}	
	// log( self$" 6 Postbeginplay at "$level.timeseconds );

	}
	if( bShieldUser )
	{
		MyShield = spawn( class'EDFShield', self );
		bMounted = AddMountable( MyShield, false, false );
	}
		// log( self$" 7 Postbeginplay at "$level.timeseconds );
	EstablishCover();

	Super.PostBeginPlay();
}

function EstablishCover()
{
	local CoverSpot C;

	foreach radiusactors( class'CoverSpot', C, 64 )
	{
		CurrentCoverSpot = C;
		CurrentCoverSpot.bOccupied = true;
		break;
	}
}

function AddWeaponFromFactory( class<weapon> NewWeapon, int PrimaryAmmoCount, int AlternateAmmoCount )
{
	if( !bSteelSkin )
		CreatureGiveWeapon( NewWeapon, PrimaryAmmoCount, AlternateAmmoCount );
}

function NotifyFriends()
{
	local Grunt P;
	local actor HitActor;
	local vector HitNormal, HitLocation;
	
	return;

	if( bFixedEnemy )
		return;
	bNotifiedByFriends = true;
	foreach allactors( class'Grunt', P )
	{
		if( P.bAggressiveToPlayer && P != Self && !P.IsInState( 'Sleeping' ) && !P.IsInState( 'SnatchedEffects' ) )
		{
			if( VSize( P.Location - Location ) < 1024 )
			{	
				if( LineOfSightTo( P ) || P.Tag == Tag )
				{
					// // // // log( "*** SETTING "$P$" ENEMY!" );
					P.Enemy = Enemy;
					P.bNotifiedByFriends = true;
					if( P.InitialCoverTag != '' && P.bUseInitialCoverTag )
						P.GotoState( 'Newcover' );
					else
					{
							// log( "GOING TO ATTACKING 2 "$self );
						P.GotoState( 'Attacking' );
					}
				}
			}
		}
	}
}
/*
function float RateSelf( out int bUseAltMode )
00092	{
00093		local float EnemyDist, rating;
00094		local vector EnemyDir;
00095	
00096		if ( AmmoType.AmmoAmount <=0 )
00097			return -2;
00098		if ( Pawn(Owner).Enemy == None )
00099		{
00100			bUseAltMode = 0;
00101			return AIRating;
00102		}
00103		EnemyDir = Pawn(Owner).Enemy.Location - Owner.Location;
00104		EnemyDist = VSize(EnemyDir);
00105		rating = FClamp(AIRating - (EnemyDist - 450) * 0.001, 0.2, AIRating);
00106		if ( Pawn(Owner).Enemy.IsA('StationaryPawn') )
00107		{
00108			bUseAltMode = 0;
00109			return AIRating + 0.3;
00110		}
00111		if ( EnemyDist > 900 )
00112		{
00113			bUseAltMode = 0;
00114			if ( EnemyDist > 2000 )
00115			{
00116				if ( EnemyDist > 3500 )
00117					return 0.2;
00118				return (AIRating - 0.3);
00119			}			
00120			if ( EnemyDir.Z < -0.5 * EnemyDist )
00121			{
00122				bUseAltMode = 1;
00123				return (AIRating - 0.3);
00124			}
00125		}
00126		else if ( (EnemyDist < 750) && (Pawn(Owner).Enemy.Weapon != None) && Pawn(Owner).Enemy.Weapon.bMeleeWeapon )
00127		{
00128			bUseAltMode = 0;
00129			return (AIRating + 0.3);
00130		}
00131		else if ( (EnemyDist < 340) || (EnemyDir.Z > 30) )
00132		{
00133			bUseAltMode = 0;
00134			return (AIRating + 0.2);
00135		}
00136		else
00137			bUseAltMode = int( FRand() < 0.65 );
00138		return rating;
00139	}
00140	
*/
function bool CanAltFire()
{
	local float Distance, Rating;
	
	if( m16( Weapon ) != None )
	{
		Distance = VSize(Location - Enemy.Location);
		if( Distance > 750 )
		{
			broadcastmessage( "ALTFIRE!" );
			return true;
		}

	}
	return false;

}

function bool ShouldAltFireWeapon()
{
	local Weapon w;
	local float dist;
	
	return false;

	if( Target==None )
		return(false);
	dist = VSize( Location - Target.Location );
	

	if( Weapon==None || !ShouldFireWeapon() )
		return( false );

	if( Weapon.IsA( 'm16' ) )
	{
		if( FriendsNearEnemy( 256 ) )
			return(false);
	}
	return(false);
}

function bool SwitchToWeapon(Weapon w)
{
	if( !bReloading )
	{
		bReloading = false;

		if( W != None )
		{
			PendingWeapon = w;
			if (PendingWeapon == Weapon)
				PendingWeapon = None;	
			if( !Weapon.IsA( 'Pistol' ) && bArmless )
			{
				PendingWeapon = None;
				return false;
			}
			if (PendingWeapon == None)
				return(false);
			if (Weapon == None)
				ChangedWeapon();
			if (Weapon != PendingWeapon)
			{
				Weapon.PutDown();
				ChangedWeapon( false );
			}
			LastWeaponSwitchTime = 0;
			return(true);
		}
	}
	return false;
}

function bool CanUseWeapon(Weapon w)
{
	local bool bNoAmmo, bNoAltAmmo;

	if (w==None)
		return(false);
	if( bArmless && !Weapon.IsA( 'Pistol' ) )
		return false;
	
	bNoAmmo = (w.AmmoName!=None);
	if( bNoAmmo && ( w.AmmoType.GetModeAmmo() > 0 ) )
		bNoAmmo = false;
	if( bNoAmmo )// && bNoAltAmmo)
		return( false );
	return( true );
}

function Weapon ChooseBestWeapon()
{
	local Weapon w;
	local float dist;

	if( Enemy==None )
		return( None );

	dist = VSize( Location - Enemy.Location );

	if( bArmless || bShieldUser )
	{
		w = Weapon( FindInventoryType( class'Pistol' ) );
		if( CanUseWeapon( W ) )
			return( W );
		Weapon.PutDown();
		Weapon = None;
		return None;
	}
	else
	{
		if(dist < 200.0 )
		{
			w = Weapon( FindInventoryType( class'shotgun' ) );
			if( CanUseWeapon( w ) )
				return( w );
		}
		w = Weapon( FindInventoryType( class'm16' ) );
		if( CanUseWeapon( w ) )
			return( w );
		w = Weapon( FindInventoryType( class'pistol' ) );

		if( CanUseWeapon( w ) )
			return( w );
		w = Weapon( FindInventoryType( class'shotgun' ) );

		if( CanUseWeapon( w ) )
			return(w);
	}
	return( None );
}

function CreatureGiveWeapon(class<Weapon> wpnClass, int ammoCount, int altAmmoCount)
{
// SetcallBackTimer( time, true/false, function name )
// EndCallBackTimer()

	if (FindInventoryType(wpnClass)==None)
		Level.Game.GiveWeaponTo( self, wpnClass );
	Weapon.bNoAnimSound = true;
	SetCallBackTimer( 0.5, false, 'WeaponSoundOn' );
	if( dnWeapon( Weapon ).IsA( 'Pistol' ) )
	{
		Weapon.AmmoLoaded = 8;
		Weapon.ReloadCount = 8;
	}

	dnWeapon( Weapon ).AmmoType.AddAmmo( 9999, 0 );
}

// This won't work for all of the weapons, fix me.
function WeaponSoundOn()
{
	// // // // // log( WEAPON SOUND ON CALLED" );
	Weapon.bNoAnimSound = false;
	EndCallBackTimer( 'WeaponSoundOn' );
}

function bool CanFireAtEnemy()
{
	local vector HitLocation, HitNormal,X,Y,Z, projStart;
	local actor HitActor;
	
	if( Weapon == None )
		return false;
	GetAxes( Rotation, X, Y, Z );
	projStart = Location + Weapon.CalcDrawOffset() + Weapon.FireOffset.X * X + 1.2 * Weapon.FireOffset.Y * Y + Weapon.FireOffset.Z * Z;
	if( Weapon.bInstantHit )
		HitActor = Trace( HitLocation, HitNormal, Enemy.Location + Enemy.CollisionHeight * vect( 0, 0, 0.7), projStart, true );
	else
		HitActor = Trace( HitLocation, HitNormal, projStart + FMin(280, VSize(Enemy.Location - Location)) * Normal( Enemy.Location + Enemy.CollisionHeight * vect( 0, 0, 0.7 ) - Location ),  projStart, true );

	if( HitActor == Enemy || ( HitActor != None && HitActor.IsA( 'EDFShield' ) ) || ( HitActor != None && HitActor.IsA( 'dnDecoration' ) && dnDecoration( HitActor ).HealthPrefab != HEALTH_NeverBreak ) )
		return true;
	if( (Pawn(HitActor) != None) && ( AttitudeTo( HitActor ) < ATTITUDE_Ignore ) )
		return false;
	if( HitActor != None && HitActor.bBlockActors )
		return false;
	return true;
}

function bool ShouldFireWeapon()
{
	local actor HitActor;
	local vector HitLocation, HitNormal;

	if( bFixedEnemy )
		return true;

	HitActor = trace( HitLocation, HitNormal, Enemy.Location, Location + ( EyeHeight * vect( 0, 0, 1 ) ), true );
	if( HitActor != None && HitActor.IsA( 'HumanNPC' ) && HitActor.Tag != HateTag )
	{
		if( bAtDuckPoint || bAtCoverPoint )
		{
			bAtDuckPoint = false;
			bAtCoverPoint = false;
		}

		bEmergencyDeparture = true;
		return false;
	}
	if( Weapon.IsA( 'RPG' ) && VSize( Location - Enemy.Location ) < 232 )
		return false;
	if( Weapon.IsA( 'RPG' ) && !CanFireAtEnemy() )
		return false;

	if( bShieldUser )
	{
		if( IsShieldBlocking() )
			return false;
	}
	if( bCanFire && bReadyToAttack )
		return true;
}
/*
// Calculates the start and end points for the fire trace, adding optional error values as a mean deviation.
simulated function GetTraceFireSegment( out vector Start, out vector End, out vector BeamStart, optional float HorizError, optional float VertError )
{
	local Pawn PawnOwner;
	local vector X, Y, Z;
	local rotator AdjustedAim;
	local mesh OldMesh;

	PawnOwner = self;
	GetAxes( PawnOwner.ViewRotation, X, Y, Z );
	Start = Location + BaseEyeHeight * vect(0,0,1);
	AdjustedAim = AdjustAim( 1000000, Start, 2*Weapon.AimError, false, false );	
	End = Start + HorizError * (FRand() - 0.5) * Y * 10000 + VertError * (FRand() - 0.5) * Z * 10000;
	X = vector(Weapon.AdjustedAim);
	End += (10000 * X);
	if ( Weapon.MuzzleAnchor != None )
		BeamStart = Weapon.MuzzleAnchor.Location;
}
*/

function FirePipebomb( optional actor DestActor )
{
	local vector X,Y,Z;
	local PipeBomb P;
	local vector Start;
	local rotator AdjustedAim;

	GetAxes( ViewRotation, X, Y, Z );
	Start = Location;// + Weapon.CalcDrawOffset();
	AdjustedAim = AdjustToss( 550, Start, 0.0, false, false );
	MyBomb = Spawn( class'dnTossedGrenade', self,, Start + vector( Rotation ) * 32, AdjustedAim );
	MyBomb.Velocity = Vector(MyBomb.Rotation) * 550;     
	MyBomb.Velocity.z += 150; 
}

function FireWeapon()
{
	local bool bUseAltMode;

//	FirePipeBomb();
	//return;

	if( Weapon!=None )
	{
		if( Enemy != None && LineOfSightTo( Enemy ) )
		{
		//	bUseAltMode = ShouldAltFireWeapon();
			if( bUseAltMode )
			{
				broadcastmessage( "ALT FIRING!" );
				bFire = 0;
				bAltFire = 1;
				Weapon.AltFire();
			}
			else
			{
				bFire = 1;
				bAltFire = 0;
				if( bShieldUser )
					ShieldShotCount++;
				MakeNoise( 1.0 );
				Weapon.Fire();
			}
		}
	}
}

function PlayFiring()
{
}

// Just changed to PendingWeapon.
function ChangedWeapon( optional bool bNoSound )
{
	local int usealt;
	
	if ( Weapon == PendingWeapon )
	{
		if ( Weapon == None && !bArmless )
			SwitchToBestWeapon();
		else if ( Weapon.GetStateName() == 'DownWeapon' ) 
			Weapon.GotoState('Idle');
		PendingWeapon = None;
	}
}

function bool SwitchToBestWeapon()
{
	local float rating;
	local int usealt, favalt;
	local inventory MyFav;

	if( Inventory == None || bMeleeMode )
		return false;

	if( LastWeaponSwitchTime < 5 && !Weapon.IsA( 'Shotgun' ) )
	{
		return false;
	}

	PendingWeapon = Inventory.RecommendWeapon(rating, usealt);
	if( PendingWeapon == None )
		return false;

	if( ( FavoriteWeapon != None ) && ( PendingWeapon.class != FavoriteWeapon ) )
	{
		MyFav = FindInventoryType( FavoriteWeapon );
		if( ( MyFav != None ) && ( Weapon( MyFav ).RateSelf( favalt ) + 0.22 > PendingWeapon.RateSelf( usealt ) ) )
		{
			usealt = favalt;
			PendingWeapon = Weapon( MyFav );
		}
	}
	if( Weapon == None )
		ChangedWeapon();
	else if( Weapon != PendingWeapon )
	{
		LastWeaponSwitchTime = 0;
		Weapon.PutDown();
	}
	if( !PendingWeapon.IsA( 'Pistol' ) && bArmless )
	{
		PendingWeapon = None;
		Weapon.PutDown();
	}
	
	if( Weapon == PendingWeapon && dnWeapon( Weapon ).AmmoType.GetModeAmmo() <= 0 )
	{
		bMeleeMode = true;
		PendingWeapon = None;
		Weapon.PutDown();
		Weapon = None;
	}
	return( usealt > 0 );
}

function ThrowWeapon()
{
	if( Level.NetMode == NM_Client )
		return;
	if( Weapon==None || !Weapon.bCanThrow )
		return;
	Weapon.Velocity = Vector(ViewRotation) * 500 + vect(0,0,220);
	Weapon.bTossedOut = true;
	TossWeapon();
	if ( Weapon == None )
		SwitchToBestWeapon();
}

// Difference between StopFiring() and HaltFiring()? Not sure if either is necessary.
function StopFiring()
{
	bFire = 0;
	bAltFire = 0;
}

function ShootTarget(Actor NewTarget);

function WpnPlayReloadStart();

function WpnPlayReload();

function WpnPlayReloadStop();

function WpnPlayActivate()
{
	// Handle special cases.
	if( Weapon.IsA( 'MightyFoot' ) )
	{
		PlayTopAnim( 'None' );
		return;
	}
	SetUpperBodyState( UB_WeaponUp );
}

function WpnPlayDeactivated()
{
	SetUpperBodyState(UB_WeaponDown);
}

function WpnPlayFireStop()
{
}

function bool EvaluateCoverPoint( NavigationPoint NP )
{
	local float CosAngle, MinCosAngle;
	local vector VectorFromNPCToNP, VectorFromNPCToEnemy;

	if( NP == None || Enemy == None )
		return false;
	VectorFromNPCToNP = NP.Location - Location;
	VectorFromNPCToEnemy = Enemy.Location - Location;

	CosAngle = Normal( Location ) dot Normal( VectorFromNPCToEnemy );

	if( CosAngle < MinCosAngle )
		return true;
	return false;
}

function bool EvaluateCoverSpot( CoverSpot NP )
{
	local float CosAngle, MinCosAngle;
	local vector VectorFromNPCToNP, VectorFromNPCToEnemy;
	local float TempDist;

	MinCosAngle = 0.1;

	if( NP == None || Enemy == None )
		return false;
	VectorFromNPCToNP = NP.Location - Location;

	if( VSize( VectorFromNPCToNP ) > MaxCoverDistance )
		return false;

	VectorFromNPCToEnemy = Enemy.Location - Location;

	CosAngle = Normal( VectorFromNPCToNP ) dot Normal( VectorFromNPCToEnemy );
	// // log( "*** COS ANGLE : "$CosAngle );
	// // log( "Line Of Sight: "$LineOfSightTo( NP ) );
	// // log( "Actor Reachable: "$ActorReachable( NP ) );
	// // log( "FindBest: "$FindBestPathToward( NP, true ) );

	if( CosAngle > 0.39 )
	{
		return false;
	}
	// // log( "Evalute Cover Spot returning true" );
	//if( ( ( LineOfSightTo( NP ) && ActorReachable( NP ) ) || FindBestPathToward( NP, true ) ) )
	if( LineOfSightTo( NP ) && ActorReachable( NP ) && VSize( Location - NP.Location ) <= MaxCoverDistance )
		return true;
	
	else if( FindBestPathToward( NP, true ) )
	{
		TempDist = GetRouteLength();
		if( TempDist <= MaxCoverDistance )
		{
			return true;
		}
		else 
		{
			log( "RouteLength TOO LONG! aborting" );
			return false;
		}

	}
	else
	return false;
}

function bool EvaluateDuckPoint( vector FromLocation )
{
	local actor HitActor;
	local vector HitLocation, HitNormal;

	HitActor = Trace( HitLocation, HitNormal, Enemy.Location, FromLocation, true );
	if( HitActor == Enemy )
		return false;
	else
		return true;
}

function bool IsShieldBlocking()
{
	local name TopSeq;

	TopSeq = GetSequence( 1 );
	if( ( TopSeq != 'T_ShieldHitR' && TopSeq != 'T_ShieldHitL' && TopSeq != 'T_ShieldHitT' && TopSeq != 'T_ShieldHitB' && TopSeq != 'T_ShieldHitM' ) || !MyShield.bCanPlayDamage )
		return false;
	
	if( TopSeq == 'T_ShieldIdle' && MyShield.DamageTimer > 0 )
		return false;
	return true;
}

function WpnPlayAltFire()
{
	SetUpperBodyState(UB_Firing);

	if( ( dnWeapon( Weapon) != None ) && ( dnWeapon( Weapon ).AltFireAnim.AnimSeq != '' ) )
		PlayTopAnim( dnWeapon( Weapon ).AltFireAnim.AnimSeq,,0.5 );
}

// Weapon animation handling:
function WpnPlayFire()
{
	SetUpperBodyState(UB_Firing);

	if( ShouldFireWeapon() )
	{
		if( ( dnWeapon(Weapon) != None ) && ( dnWeapon( Weapon ).FireAnim.AnimSeq != '' ) )
		{
			if( bShieldUser )
			{
				if( GetSequence( 1 ) == 'T_ShieldFire' || GetSequence( 1 ) == 'T_ShieldOutIdle' )
					PlayTopAnim( 'T_ShieldFire',, 0.1, false );
				else
					PlayTopAnim( 'T_ShieldFire',, 0.18, false );
			}
			else
				PlayTopAnim( dnWeapon( Weapon ).GetFireAnim().AnimSeq, dnWeapon( Weapon ).GetFireAnim().AnimRate, 0.1 );
		}
	}
}

state Attacking
{
	function BeginState()
	{
		//if( DebugModeOn() )
		// // // // // log( === Attacking BeginState for "$self );
		ChooseAttackState();
		Enable( 'EnemyNotVisible' );
	}
}

function bool DebugModeOn()
{
//	if( Level.Game.IsA( 'dnSinglePlayer' ) && dnSinglePlayer( Level.Game ).bAIDebugMode )
//		return true;

	return false;
}

function PlayRangedAttack()
{
	// // // // // log( PLayRANGED ATTACK CALLED" );
	if( VSize( Enemy.Location - Location ) < 96 ) // && MyCombatController != None )
	{
		// // // // log( "CALLING ENCROACHED" );
		ChooseMeleeAttackState();
		return;
	}

	if( ( Enemy == None || Enemy.bDeleteMe ) || ( Enemy.IsA( 'Pawn' ) && Pawn( Enemy ).Health <= 0 ) )
	{
		// // // // // log( Aborting PlayRangedAttack to Idling state" );
		if( !bSteelSkin )
			SpeechCoordinator.RequestSound( self, 'KilledDuke' );
		Enemy = None;
		bForcedAttack = false;
		HeadTrackingActor = None;
		PlayToWaiting( 0.12 );
		GotoState( 'Idling', 'EnemyDead' );
		return;
	}
	else if( CanFireAtEnemy() )
		FireWeapon();
}

function ChooseAttackState( optional name NextLabel, optional bool bWounded )
{
	local float DistanceFromEnemy;
	local bool bDebugMode;

	// log( "== ChooseAttackState 1 for "$self$" from state "$GetStateName() );
	// // // // // log( == MyCombatController: "$MyCombatController$" "$self );
	// // // // // log( bRetreatAtStartup is "$bRetreatAtStartup );

	if( Enemy == None )
	{
		GotoState( 'Idling' );
		return;
	}

	if( bWounded && MyCombatController != None )
	{
		bWounded = false;
		MyCombatController.EncroachedGrunt( CurrentCoverSpot, self, true );
		//// // broadcastmessage( "ENCROACHED!!!!!!" );
		return;
	}
	
	if( NextLabel == '' )
		NextLabel = 'Begin';

	if( bRetreatAtStartup )
	{
		GotoState( 'Retreat' );
		return;
	}

	if( MyCombatController != None && !bKneelAtStartup && !bForcedAttack )
	{
		if( bCamping && !CanSee( Enemy ) )
		{
			// // // // // log( Sending "$self$" to WaitingForEnemy state" );
			 // // log( self$" Going to WaitingForEnemy state 2" );
			GotoState( 'WaitingForEnemy' );
			return;
		}

		// // // // // log( ChooseAttackState 2 for "$self );
		if( !bCoverOnAcquisition )
		{
			if( !MyCombatController.CheckLastOrderTime( self ) )
			{
				// log( "ChooseAttackstate sending "$self$" to AttackM16 state" );
				GotoState( 'AttackM16' );
			}
		}
		if( MyCombatController.CheckLastOrderTime( self ) )
		{
			// // // // // log( ChooseAttackState 3 for "$self$" going to ControlledCombat state." );
			 // // // // log( Going to controlledcombat 1 for "$self );
			
			GotoState( 'ControlledCombat' );
			return;
		}
	}

	DistanceFromEnemy = VSize( Location - Enemy.Location );
	
//	if( InitialCoverTag != '' && bUseInitialCoverTag )
//	{
		//// // // // // log( Going to NewCover 2" );
//		// // // // // log( ChooseAttackState 4 for "$self );
//		GotoState( 'NewCover' );
//		return;
//	}
	if( bCoverOnAcquisition && !bKneelAtStartup )
	{
	//	bCoverOnAcquisition = false;
		// // // // // log( ChooseAttackState 5 for "$self );
		// log( self$" 5 CHOOSEATTACK STATE CALLED FROM STATE "$GetStateName() );
		// log( self$" bCoverOnAcquisition was "$bCoverOnAcquisition );

		if( MyCombatController != None )
		{
			// // // // // log( ChooseAttackState 6 for "$self$" going to ControlledCombat state" );
			 // // log( Going to controlledcombat 2 for "$self );
			GotoState( 'ControlledCombat' );
			return;
		}
		else
		{
		// log( self$" 6 CHOOSEATTACK STATE CALLED FROM STATE "$GetStateName() );

			//// // // // // log( Going to NewCover 3" );
			// // // // // log( ChooseAttackState 7 for "$self$" going to newCover state"  );
			GotoState( 'NewCover' );
			return;
		}
	}
	// // // // // log( ChooseAttackState 8 for "$self );
	// log( self$" 7 CHOOSEATTACK STATE CALLED FROM STATE "$GetStateName() );

	// FIXME 
	if( DistanceFromEnemy <= 64 && !Weapon.IsA( 'Pistol' ) )
	{
		log(" CHOOSE MELEE ATTACK STATE " );
		ChooseMeleeAttackState();
	}
	else if( Weapon.IsA( 'm16' ) )
	{
	// log( self$" 8 CHOOSEATTACK STATE CALLED FROM STATE "$GetStateName() );

		// // // // // log( ChooseAttackState 9 for "$self );
		if( GetPostureState() == PS_Crouching )
			NextLabel = 'AfterFire';

		// log( "ChooseAttackState 10 Going to AttackM16 state for "$self );
		GotoState( 'AttackM16', NextLabel );
	}
	
	else if( Weapon.IsA( 'Pistol' ) )
	{
		// log( self$" 9 CHOOSEATTACK STATE CALLED FROM STATE "$GetStateName() );
		// // // // log( "NEXTLABEL: "$NextLabel );
		// // // // // log( Going to pistol attack state." );
		if( GetPostureState() == PS_Crouching )
			NextLabel = 'AfterFire';

		// // // // log( "GOING TO ATTACK PISTOL NEXT LABEL IS "$Nextlabel );
		if( !bShieldUser )
			GotoState( 'AttackPistol', NextLabel );
		else
			GotoState( 'ShieldAttackPistol', NextLabel );
	}

	else if( Weapon.IsA( 'Shotgun' ) )
	{
		// // // // // log( ChooseAttackState 11 for "$self );
		GotoState( 'AttackShotgun', NextLabel );
	}
		// log( self$" 10 CHOOSEATTACK STATE CALLED FROM STATE "$GetStateName() );

	NextLabel = '';
	// // // log( self$" ChooseAttack state end function" );
}

function ChooseMeleeAttackState()
{
	// log( "ChooseMeleeAttackState called from state "$GetStateName() );
	if( bSnatched )
		GotoState( 'TentacleThrust' );
	else
		GotoState( 'MeleeCombat' );
}


function PlayFightIdle( optional float TweenTime )
{
	if( TweenTime == 0.0 )
		TweenTime = 0.1;

	PlayTopAnim( 'None' );
	PlayAllAnim( 'A_FightIdle',, TweenTime, true );
}

function PlayToWaiting( optional float TweenTime )
{
	local float f;

	// // // // // log( * PlayToWAiting called for "$self );
	
	// // // // log( "PLAYTOWAITING CALLED" );
	if( Enemy == None )
		bWalkMode = true;
	else
		bWalkMode = false;
	// // // // log( "PlayToWAiting 2 for "$self );
	if( Physics == PHYS_Swimming )
	{
		PlayAllAnim( 'A_SwimStroke',, TweenTime, true );
		PlayBottomAnim( 'B_SwimKickFwrd',, TweenTime, true );
	}

	if( GetPostureState() != PS_Crouching )
	{
	// // // // log( "PlayToWAiting 3 for "$self );
		if( GetSequence( 2 ) == 'b_KneelIdle' )
			PlayBottomAnim( 'None' );

	// // // log( self$" PostureState was NOT Crouching" );
		if( Weapon != None )
		{
			if( Enemy == None && !bShieldUser )
				PlayAllAnim( InactiveStance,, TweenTime, true );
			else PlayAllAnim( ActiveStance,, TweenTime, true );
		}
		else PlayAllAnim( InactiveStance,, TweenTime, true );
	}
	else if( GetPostureState() == PS_Crouching )
	{
	// // // // log( "PlayToWAiting 4 for "$self );
		// // // log( self$" PostureState WAS Crouching" );
		// log( self$" ==== PLAYING KNEEL IDLE 1" );
		PlayBottomAnim( 'B_KneelIdle',, TweenTime, true );
	}
	// // // // log( "PlayToWAiting 6 for "$self );
	if( !bShieldUser )
	{
		if( Enemy != None && GetStateName() != 'MeleeCombat' && GetStateName() != 'Acquisition' )
			PlayWeaponIdle( TweenTime );	
	}
	else
		PlayTopAnim( 'T_ShieldIdle',, TweenTime, true );
}

function PlayWeaponFire( optional float TweenTime )
{
	if( TweenTime == 0.0 )
		TweenTime = 0.1;

	if( Weapon.IsA( 'm16' ) )
		PlayTopAnim( 'T_M16Fire', 6.0, TweenTime, false, false, true );
	else if( Weapon.IsA( 'Shotgun' ) )
		PlayTopAnim( 'T_SGFire',, TweenTime, false, false, false );
	else if( Weapon.IsA( 'Pistol' ) )
		PlayTopAnim( 'T_Pistol2HandFire',, TweenTime, false, false, true );
}

function PlayWeaponIdle( optional float TweenTime )
{
	if( TweenTime == 0.0 )
		TweenTime = 0.1;

	if( Weapon.IsA( 'm16' ) )
		PlayTopAnim( 'T_M16Idle',, TweenTime, true );

	else if( Weapon.IsA( 'Pistol' ) )
	{
		if( bShieldUser )
			PlayTopAnim( 'T_ShieldIdle',, TweenTime, true );
		else if( !bOneHandedPistol )
			PlayTopAnim( 'T_Pistol2HandIdle',, TweenTime, true );
		else PlayTopAnim( 'T_PistolIdle',, TweenTime, true );
	}

	else if( Weapon.IsA( 'Shotgun' ) )
		PlayTopAnim( 'T_SGIdle',, TweenTime, true );
}

function SetDodgeDestination()
{
	local vector X, Y, Z, HitLocation, HitNormal;
	local bool bLeft;
	local Actor HitActor;

	GetAxes( Rotation, X, Y, Z );

	// Pick a direction to try to dodge.
	if( FRand() < 0.5 )
	{
		bLeft = true;
		Y *= -1;
	}

	// Check for obstructions, if there are any then try the opposite direction.
	HitActor = Trace( HitLocation, HitNormal, Location + Y * ( 136 ), Location, true );

	if( HitActor != None )
	{
		Y *= -1;
		bLeft = !bLeft;
		HitActor = Trace( HitLocation, HitNormal, Location + Y * ( 136 ), Location, true );
		if( HitActor != None )
		{
			MoveTimer = -1.0;
			// // // log( self$" ChooseAttackState from SetDodgeDestination" );
			ChooseAttackState();
		}
	}

	Destination = Location + Y * ( 172 );
	if( !PointReachable( Destination ) || !CanSeeEnemyFrom( Destination ) )
	{
		NextLabel = 'Begin';
		// // // log( self$" ChooseAttackState from SetDodgeDestination 2" );
		ChooseAttackState();
		return;
	}
	
	PlayTopAnim( 'None' );
	
	if( bLeft )
		PlayAllAnim( 'A_RollLeftA',, 0.12, false );
	else PlayAllAnim( 'A_RollRightA',, 0.12, false );
}

// Reload weapon without playing any animations.
function HiddenReload()
{
	dnWeapon( Weapon ).AmmoLoaded = dnWeapon( Weapon ).ReloadCount;
	
	if( dnWeapon( Weapon ).AltAmmoType == dnWeapon( Weapon ).AmmoType )
		dnWeapon( Weapon ).AltAmmoLoaded = dnWeapon( Weapon ).ReloadCount;

	dnWeapon( Weapon ).AltAmmoLoaded = dnWeapon( Weapon ).AltReloadCount;
}

function SetDodgeDisabled()
{
	bDodgeSidestepDisabled = true;
	SetCallBackTimer( 2.5, false, 'SetDodgeEnabled' );
}

function SetDodgeEnabled()
{
	bDodgeSidestepDisabled = false;
	// // log( "SETCROUCHDISABLED FOR "$self );

}

// Spawn controller that handles the flag that controls crouching frequency.
function SetCrouchDisabled()
{
// SetcallBackTimer( time, true/false, function name )
// EndCallBackTimer()
	bCrouchShiftingDisabled = true;
	SetCallBackTimer( 4.0, false, 'SetCrouchEnabled' );
	// // log( "SETCROUCHENABLED FOR "$self );

}


function SetCrouchEnabled()
{
	bCrouchShiftingDisabled = false;
}

function bool MustTurn( optional actor Target )
{
	if( bKneelAtStartup )
		return false;

	if( Target != None )
		AYaw1 = rotator( Target.Location - Location );
	else
		AYaw1 = DesiredRotation;
	AYaw2 = Rotation;
	AYaw1.Pitch = 0;
	AYaw2.Pitch = 0;
	// was 0.4
	if( VSize( vector( AYaw1 ) - vector( AYaw2 ) ) > 0.3 )
		return true;
	
	return false;
}

function PlayToStanding()
{
	ChangeCollisionHeightToStanding();
	BaseEyeheight = 27;
	EyeHeight = 27;
	bCrouching = false;
	PlayBottomAnim( 'B_KneelUp',, 0.2, false );
	bCrouchShiftingDisabled = true;
	SetCallBackTimer( 4.0, false, 'SetCrouchEnabled' );
}

function PlayToCrouch( optional bool bCrouchLow )
{
	if( bSteelSkin )
		return;

	if( GetPostureState() != PS_Crouching )
	{
		ChangeCollisionHeightToCrouching();
		StopFiring();
		BaseEyeHeight = 0;
		EyeHeight = 0;
		SetPostureState( PS_Crouching );
		if( bCrouchLow )
			PlayAllAnim( 'A_CrchIdle',, 0.35, true );
		else
			PlayBottomAnim( 'B_KneelDown',, 0.1, false );
	}
}

// Right now Showself will only be called if bIsPlayer is true. Octabrain temporarily set to bIsPlayer for testing.
event SeeMonster( actor Seen )
{
	local AIPawn SeenPawn;

	if( Seen.IsA( 'AIPawn' ) )
	{
		if( Seen == Enemy )
		{	
			//// // // // // log( Going to attacK" );
			// // // log( self$" ChooseAttackState from SeeMonster" );
			ChooseAttackState();
		}
	}
}

/*-----------------------------------------------------------------------------
	Startup initial state 
-----------------------------------------------------------------------------*/
auto state StartUp
{
	function BeginState()
	{
		bCanFire = true;
		bCanSpeak = true;
		SetMovementPhysics(); 
		if( Physics == PHYS_Walking )
			SetPhysics( PHYS_Falling );
		bWalkMode = true;
		bShortPains = false;
		GroundSpeed = Default.GroundSpeed * 0.5;
	}

Begin:
	// log( self$" Startup state A at "$Level.TimeSeconds );
//	WaitForLanding();
	// // // // // log( Startup state 1 for "$self );
	PlayToWaiting();
	// log( self$" Startup state at "$Level.TimeSeconds );
	if( bKneelAtStartup )
	{
	// // // // // log( Startup state 2 for "$self );
		bIntoCrouch = true;
		SetPostureState( PS_Crouching );
		bCrouchShiftingDisabled = true;
		PlayToCrouch();
		FinishAnim( 2 );
		bIntoCrouch = false;
		SetCrouchDisabled();
		// log( self$" ==== PLAYING KNEEL IDLE 2" );
		PlayBottomAnim( 'B_KneelIdle',, 0.13, true );
	}
	// log( self$" Startup state 2 at "$Level.TimeSeconds );

	// // // // // log( Startup state 3 for "$self$" bVisiblySnatched is "$bVisiblySnatched );
	if( bVisiblySnatched )
	{
	// // // // // log( Startup state 4 for "$self );
		//Sleep( 1.0 );
		bSnatchedAtStartup = true;
		GotoState( 'SnatchedEffects' );
		bUseSnatchedEffects = false;
		bUseSnatchedEffectsDone = true;
		// log( self$" Startup state 3 at "$Level.TimeSeconds );

		WhatToDoNext( '','' );
	}
	else
	{
		// log( self$" Startup state 4 at "$Level.TimeSeconds );

		// // // // // log( Startup state 5 for "$self );
		WhatToDoNext( '', '' );
	}
}

/*-----------------------------------------------------------------------------
	Idling state.
-----------------------------------------------------------------------------*/
state Idling
{
	ignores HitWall, SeeMonster;

 	function BeginState()
	{
		EnableHeadTracking( true );
		EnableEyeTracking( true );
		Disable( 'SeeMonster' );
		Enable( 'SeePlayer' );
		Disable( 'EnemyNotVisible' );
	}

	function EndState()
	{
		PeripheralVision = -1.0;
	}

	function PlayIdlingAnimation()
	{
		PlayAllAnim( InitialIdlingAnim,, 0.1, true );
	}

	function HearNoise(float Loudness, Actor NoiseMaker)
	{
		local vector OldLastSeenPos;
		
		if( NoiseMaker.IsA( 'HITPACKAGE_Level' ) )
		{
			bCanTorsoTrack = true;
			HeadTrackingActor = NoiseMaker;

			NoiseInstigator = NoiseMaker.Instigator;
			if( NoiseInstigator.IsA( 'PlayerPawn' ) )
			{
				Enemy = NoiseInstigator;
				if( MyCombatController == None )
					GotoState( 'Reacting' );
				else
					GotoState( 'WaitingForEnemy' );
				return;
			}
		}

		if( NoiseMaker.IsA( 'LaserMine' ) && !LaserMine( NoiseMaker ).bNPCsIgnoreMe && Loudness == 0.5 && !LineOfSightTo( NoiseMaker ) )
		{
			SuspiciousActor = NoiseMaker;
			GotoState( 'Investigating' );
			return;
		}

		if( bAggressiveToPlayer && NoiseMaker.IsA( 'PlayerPawn' ) || ( bAggressiveToPlayer && NoiseMaker.Instigator.IsA( 'PlayerPawn' ) ) )
		{
			Enemy = NoiseMaker.Instigator;
			if( Enemy != None )
			{
				// log( "Going to Attacking 5a" );
				GotoState( 'Attacking' );
			}
		}
	}

	function SeePlayer( actor SeenPlayer )
	{
		local float Dist;

		if( !bPatrolled && bPatrolIgnoreSeePlayer )
			return;

		if( bForcedAttack && Enemy != None )
			return;

		// Invisiblilty support.
		if( Pawn( SeenPlayer ) != None && Pawn( SeenPlayer ).Visibility <= 0 )
			return;

		if( bFixedEnemy )
			return;
		
		if( SeenPlayer.IsA( 'PlayerPawn' ) )
		{
			Dist = VSize( Location - SeenPlayer.Location );

			if( bAggressiveToPlayer )
			{
				if( Dist > AggressionDistance )
					return;
				// log( self$" SETTING ENEMY A" );
				Enemy = SeenPlayer;
				GotoState( 'Acquisition' );
				return;
			}
			// Sneaky attacks (only if they cannot be seen). Necessary for Grunts, or not?
			else if( bSnatched && !bAggressiveToPlayer )
			{
				if( Dist <= AggroSnatchDistance )
				{
					if( !PlayerCanSeeMe()  )
					{
						Disable( 'SeePlayer' );
						// log( self$" SETTING ENEMY B" );
						Enemy = SeenPlayer;
						
						NextState = 'Attacking';
						bAggressiveToPlayer = true;
						GotoState( 'SnatchedEffects' );
					}
				}
			}
		}
	}

EnemyDead:
	PlayTopAnim( 'None' );
	if( GetPostureState() == PS_Crouching )
	{		
		bIntoCrouch = true;
		PlayToStanding();
		FinishAnim( 2 );
		PlayBottomAnim( 'None' );
		bIntoCrouch = false;
		SetPostureState( PS_Standing );
		PlayToWaiting( 0.35 );
		PlayWeaponIdle();
		Sleep( 0.15 );
	}
	Goto( 'Begin' );

Acquisition:
	Sleep( 0.15 );
	PlayWeaponIdle( 0.12 );
	// // // log( self$" ChooseAttackState from Idling 1" );
	ChooseAttackState();

StandUp:
	if( GetPostureState() == PS_Crouching && !bKneelAtStartup )
	{
		bIntoCrouch = true;
		PlayToStanding();
		FinishAnim( 2 );

		PlayBottomAnim( 'None' );
		bIntoCrouch = false;
		SetPostureState( PS_Standing );
		PlayToWaiting( 0.35 );
		Sleep( 0.15 );
	}
Begin:
	// // // // // log( Idling state begin label for "$self );
	// log( self$" Idling state 1 at "$level.timeseconds );
	if( GetPostureState() == PS_Crouching && !bKneelAtStartup )
	{
		Goto( 'StandUp' );
	}
//	bKneelAtStartup = false;
	Enable( 'SeePlayer' );

	// log( self$" Idling state 2 at "$level.timeseconds );
	if( HateTag != '' )
	{
		// // log( CALLING TRIGGERHATE for "$self );
		TriggerHate();
	}

	StopMoving();
	PlayToWaiting( 0.2 );
	Disable( 'SeeMonster' );
	// log( self$" Idling state 3 at "$level.timeseconds );
	if( InitialIdlingAnim != '' )
	{	
		PlayIdlingAnimation();
		if( !bReuseIdlingAnim )
			InitialIdlingAnim = '';
	}
	// // // // // log( Idling state begin label 2 for "$self );
	// log( self$" Idling state 4 at "$level.timeseconds );
	if( bFixedEnemy )
	{
		Sleep( 0.15 );
		bFixedEnemy = false;
		// // // // log( GOING TO ATTACKING 4 "$self );
				// log( "Going to Attacking 5b" );
		GotoState( 'Attacking' );
	}

	if( bStrafeRightOnSpawn || bStrafeLeftOnSpawn )
	{
		if( !bSteelSkin && SpeechCoordinator != None )
			SpeechCoordinator.RequestSound( self, 'Hunting' );
		GotoState( 'DodgeSideStep' );
	}
	else if( bRollRightOnSpawn || bRollLeftOnSpawn )
	{
		// log( self$" Going to DodgeRoll state at "$Level.TimeSeconds );
	if( !bSteelSkin && SpeechCoordinator != None )
		SpeechCoordinator.RequestSound( self, 'Hunting' );

		GotoState( 'DodgeRoll' );
	}
	else if( !bPatrolled && !bRetreatAtStartup )
	{
		if( NPCOrders == ORDERS_Patrol )
		{
			// // // log( self$" Going to patrolling state" );
			GotoState( 'Patrolling' );
			bPatrolled = true;
		}
	}

IdleLoop:
	Sleep( 1.0 + Rand( 2 ) );
	if( FRand() < 0.75 )
	{
		if( !bSteelSkin )
			SpeechCoordinator.RequestSound( self, 'Idling' );
	}
	Sleep( 3.0 );
	Goto( 'IdleLoop' );
}

state Reacting
{
	ignores HearNoise, EnemyNotVisible;

Begin:
	Sleep( 0.5 );
	GotoState( 'Acquisition' );
}

/*-----------------------------------------------------------------------------
	Acquisition state. 
-----------------------------------------------------------------------------*/

state Acquisition
{
	ignores SeePlayer, SawEnemy, SeeMonster;

	function BeginState()
	{
		if( Enemy != None )
			HeadTrackingActor = Enemy;
		if( !bSteelSkin )
			SpeechCoordinator.RequestSound( self, 'Acquisition' );
	}

	function Timer( optional int TimerNum )
	{
		// // // log( self$" ChooseAttackState from Acquisition Timer" );

		ChooseAttackState();
	}

Begin:
	StopMoving();
	TurnToward( Enemy );
	PlayToWaiting( 0.12 );
	Sleep( 0.12 );
	PlayWeaponIdle( 0.12 );
//	Sleep( PreAcquisitionDelay );

	if( MyCombatController != None )
	{
		log(" CALLING WARNFRIENDS" );
		MyCombatController.WarnFriends( self, Enemy );
	}

	if( bRetreatAtStartup )
		GotoState( 'Retreat' );

	if( bCoverOnAcquisition && MyCombatController == None )
		GotoState( 'NewCover' );

	if( AcquisitionSound != None )
		PlaySound( AcquisitionSound, SLOT_Talk,,,,,true );

	else
	{
		// // // log( self$" ChooseAttackState From Acquisition 2" );
		ChooseAttackState();
	}
	SetTimer( GetSoundDuration( AcquisitionSound )+ 0.25, false );

	if( AcquisitionTopAnim != 'None' )
		PlayTopAnim( AcquisitionTopAnim,, 0.1, false );

	if( AcquisitionBottomAnim != 'None' )
		PlayBottomAnim( AcquisitionBottomAnim,, 0.1, false );

	if( AcquisitionAllAnim != 'None' )
		PlayAllAnim( AcquisitionAllAnim,, 0.1, bLoopAcquisitionAnim );
}

state Reloading
{
	ignores EnemyNotVisible, SeeMonster;

	function BeginState()
	{
		HeadTrackingActor = None;
		bReloading = true;
	}

	function EndState()
	{
		HeadTrackingActor = Enemy;
		bReloading = false;
	}

	function AnimEndEx( int Channel )
	{
		// // // log( self$" AnimEndEx called for channel "$Channel$" seq was "$GetSequence( Channel ) );

		if( Channel == 1 )
		{
			if( GetSequence( 1 ) == 'T_SGReloadRaise' )
				PlayTopAnim( dnWeapon( Weapon ).ReloadLoopAnim.AnimSeq,, 0.1 );

			else if( GetSequence( 1 ) == 'T_SGReloadLoop' )
			{
				SGReloadCount++;
				if( SGReloadCount < 7 )
					PlayTopAnim( dnWeapon( Weapon ).ReloadLoopAnim.AnimSeq,, 0.1 );
				else
				{
					SGReloadCount = 0;
					PlayTopAnim( dnWeapon( Weapon ).ReloadStopAnim.AnimSeq,, 0.1 );
					GotoState( 'Reloading', 'DoneSGReload' );
				}
			}
		}
	}

DoneSGReload:
	Disable( 'AnimEnd' );
	dnWeapon( Weapon ).ReloadAll( Weapon.AmmoLoaded );//GotoState( 'Reloading' );
	FinishAnim( 1 );
	// // // log( self$" ChooseAttackState From Reloading state 1" );
	ChooseAttackState();
Begin:
	if( MyCombatController != None && !bGottaReload )
	{
		bGottaReload = true;
		MyCombatController.EncroachedGrunt( CurrentCoverSpot, self, true );
	}
	bGottaReload = false;

	if( GetSequence( 2 ) != '' && GetSequence( 2 ) != 'B_KneelIdle' )
		PlayBottomAnim( 'None' );
	if( RegularWeapon() )
	{
		if( !bShieldUser )
			PlayTopAnim(dnWeapon(Weapon).ReloadStartAnim.AnimSeq,,0.1);
		dnWeapon( Weapon ).AmmoType.AddAmmo( 9999, 0 );
		if( !bShieldUser )
			FinishAnim( 1 );
		if( Pistol( Weapon ) != None )
			Weapon.AmmoLoaded = 8;
		else
			Weapon.AmmoLoaded = 50;
		bReloading = false;
		ChooseAttackState( 'AfterFire' );
	}
	else
	{
		//// // // // // log( Reload 5" );
//		Enable( 'AnimEnd' );
//		Enable( 'AnimEndEx' );
//		//// // // // // log( TEst: "$dnWeapon( Weapon ).ReloadStartAnim.AnimSeq );
		PlayTopAnim( dnWeapon( Weapon ).ReloadStartAnim.AnimSeq,, 0.1 );
		FinishAnim( 1 );
		While( SGReloadCount < 7 )
		{
			PlayTopAnim( dnWeapon( Weapon ).ReloadLoopAnim.AnimSeq,, 0.1 );
			FinishAnim( 1 );
			SGReloadCount++;
		}
		SGReloadCount = 0;
		PlayTopAnim( dnWeapon( Weapon ).ReloadStopAnim.AnimSeq,, 0.1 );
		dnWeapon( Weapon ).ReloadAll( Weapon.AmmoLoaded );
		FinishAnim( 1 );
		PlayWeaponIdle( 0.12 );
		Sleep( 0.12 );
		// // // log( self$" ChooseAttackState From Reloading state 2" );
		ChooseAttackState();
	}
}

function AnimEndEx(int Channel)
{
	if (Channel==1)
	{
		GetMeshInstance();
		if (!MeshInstance.MeshChannels[Channel].bAnimLoop)
		{
			if( !bShieldUser )
			PlayTopAnim('None'); // smear top channel
		}
	}
	else if (Channel==2)
	{
		GetMeshInstance();
		if (!MeshInstance.MeshChannels[Channel].bAnimLoop)
			PlayBottomAnim('None'); // smear bottom channel
	}
}

function bool RegularWeapon()
{
	if( Weapon.IsA( 'Shotgun' ) )
		return false;
	
	return true;
}


/*-----------------------------------------------------------------------------
	Attack state and weapon specific attack substates.
-----------------------------------------------------------------------------*/
state Attack
{
	function bool CanRetreat()
	{
		local actor HitActor;
		local vector HitNormal, HitLocation, X, Y, Z;

		GetAxes( rotator( Enemy.Location - Location ), X, Y, Z );
		HitActor = Trace( HitLocation, HitNormal, Location + ( -64 * X ), Location, true );

		if( HitActor != None )
		{
			return false;
		}
		return true;
	}

	function BeginState()
	{ 
		HeadTrackingActor = Enemy;
		dnWeapon( Weapon ).FireAnim.AnimSeq = '';
	}

	function AnimEnd()
	{
		Super.AnimEnd();
	}

	function AnimEndEx( int Channel )
	{
		if( Channel == 0 && GetSequence( 0 ) == 'A_RollRightA' )
		{
			// // // // log( "PLAY WEAPON IDLE 1" );
			PlayWeaponIdle();
		}
		if( Channel == 1 && GetSequence( 0 ) != 'A_RollRightA' )
		{
			// // // // log( "PLAY WEAPON IDLE 2" );
			PlayWeaponIdle();
		}
	}

	function PlayToWaiting( optional float TweenTime )
	{
		if( GetSequence( 2 ) == 'B_StepLeft' || GetSequence( 2 ) == 'B_StepRight' ) 
			PlayBottomAnim( 'None' );
		
		else
		{
			Super.PlayToWaiting( TweenTime );
		}
	}

	function Tick( float DeltaTime )
	{
		local rotator Yaw1, Yaw2;

		if( bIsTurning && !bKneelAtStartup && GetPostureState() != PS_Crouching )
		{
			if( HeadTrackingActor == None )
				HeadTrackingActor = Enemy;

			TurnDestination = HeadTrackingActor.Location;
			
			if( VSize( vector( AYaw1 ) - vector( AYaw2 ) ) > 0.4 )
			{
				if( ( rotator( TurnDestination - Location ) - Rotation).Yaw < 0)
				{
					if( GetSequence( 2 ) != 'B_StepLeft' )
						PlayBottomAnim( 'B_StepLeft', 1.55, 0.2, true );
				}
				else
				{
					if( GetSequence( 2 ) != 'B_StepRight' )
						PlayBottomAnim( 'B_StepRight', 1.55, 0.2, true );
				}
			}
			else if( GetSequence( 2 ) == 'B_StepLeft' || GetSequence( 2 ) == 'B_StepRight' )
				GotoState( GetStateName(), 'DoneTurn' );
		}
		Global.Tick( DeltaTime );
	}

CoverEvaluation:
	if( bAtCoverPoint )
	{
		if( !EvaluateCoverPoint( MyCoverPoint ) )
			GotoState( 'NewCover' );
		if( PostureState == PS_Standing && MyCoverPoint.bExitWhenClose )
		{
			if( VSize( Location - Enemy.Location ) < 72 )
			{
				bAtCoverPoint = false;
				bAtDuckPoint = false;
				// // log( Setting bCoverOn true 1" );
				bCoverOnAcquisition = true;
				GotoState( 'NewCover' );
			}
		}

	}
	if( bAtDuckPoint )
	{
		if( PostureState == PS_Crouching )
		{
			bIntoCrouch = true;
			PlayToStanding();
			FinishAnim( 2 );
			PlayBottomAnim( 'None' );
			bIntoCrouch = true;
			SetPostureState( PS_Standing );
			PlayToWaiting( 0.35 );
			// // // // log( "PLAY WEAPON IDLE 3" );
			PlayWeaponIdle();
		}
		if( !bCrouchShiftingDisabled && PostureState == PS_Crouching )
		{
			bIntoCrouch = true;
			PlayToStanding();
			FinishAnim( 2 );
			PlayBottomAnim( 'None' );
			bIntoCrouch = true;
			SetPostureState( PS_Standing );
			PlayToWaiting( 0.35 );
			// // // // log( "PLAY WEAPON IDLE 4" );
			PlayWeaponIdle();
		}

	}
	if( bAtCoverPoint && MyCoverPoint.bExitOnDistance )
	{
		if( VSize( Location - Enemy.Location ) > MyCoverPoint.ExitDistance )
		{
			bAtCoverPoint = false;
			 // // log( self$" Going to Hunting 6" );
			GotoState( 'Hunting' );
		}
	}
	if( !bFixedPosition && !bAtDuckPoint && FRand() < 0.3 && !bAtCoverPoint )
	{
		bNoPain = true;
		if( PostureState == PS_Crouching )
		{
			bIntoCrouch = true;
			PlayToStanding();
			FinishAnim( 2 );
			PlayBottomAnim( 'None' );
			bIntoCrouch = false;
			SetPostureState( PS_Standing );
			PlayToWaiting( 0.35 );
			// // // // log( "PLAY WEAPON IDLE 5" );
			PlayWeaponIdle();
		}
		GotoState( 'NewCover' );
	}
	// // // log( self$" ChooseAttackState From Attack state 2" );
	ChooseAttackState();
	
StandUp:
	if( GetPostureState() == PS_Crouching && !bKneelAtStartup )
	{
		bIntoCrouch = true;
		PlayToStanding();
		FinishAnim( 2 );
		PlayBottomAnim( 'None' );
		bIntoCrouch = false;
		SetPostureState( PS_Standing );
		PlayToWaiting( 0.35 );
			// // // // log( "PLAY WEAPON IDLE 6" );
		PlayWeaponIdle();
		Sleep( 0.15 );
	}
	// // // log( self$" ChooseAttackState From Attack state 3" );
	ChooseAttackState();

Begin:

}

	function EnableAttackPhrase()
	{
		bCanSayAttackPhrase = true;
	}

	function bool SafeToCrouch()
	{
		local float Dist;

		if( VSize( Location - Enemy.Location ) < 190 )
			return false;

		return true;
	}

/*-----------------------------------------------------------------------------
	Attack state: Pistol 
-----------------------------------------------------------------------------*/
state AttackPistol extends Attack
{
	function SeePlayer( actor Seen )
	{
		if( TempEnemy != None )
		{
			if( Enemy.IsA( 'AITempTarget' ) )
				Enemy.Destroy();

			// log( self$" ENEMY SETTING D" );
			Enemy = Seen;
			Target = Seen;
			TempEnemy = None;
			Disable( 'SeePlayer' );
			Enable( 'EnemyNotVisible' );
		}
		Super.SeePlayer( Seen );
	}


	function Bump( actor Other )
	{
		if( PlayerPawn( Other ) != None )
		{
			// // log( ** ENCROACHED BY "$Other );
			//MyCombatController.EncroachedGrunt( CurrentCoverSpot, self );
			//Disable( 'Bump' );
			ChooseMeleeAttackState();
		}
	}

	function BeginState()
	{
		PlayToWaiting( 0.12 );
		Super.BeginState();
	}

Begin:
	// log( self$" AttackPistol begin Label 1" );
	
	// // // // log( "Pre Calling PlayToWaiting" );

	if( FRand() < 0.25 && !bSteelSkin && bCanSayAttackPhrase )
	{
		SpeechCoordinator.RequestSound( self, 'RangedAttack' );
		bCanSayAttackPhrase = false;
		SetCallBackTimer( 2.0, false, 'EnableAttackPhrase' );
	}
	if( !MustTurn() )
	{
		PlayToWaiting( 0.12 );
	// // // // log( "Post Calling PlayToWaiting" );
			// // // // log( "PLAY WEAPON IDLE 7" );
		PlayWeaponIdle();
	}
	// log( self$" AttackPistol begin Label 2" );

	if( TempEnemy == None )
		Disable( 'SeePlayer' );
	else
		Enable( 'SeePlayer' );

	Enable( 'AnimEnd' );
	RotationRate.Yaw = 75000;
	DesiredRotation = rotator( HeadTrackingActor.Location - Location );
	dnWeapon( Weapon ).FireAnim.AnimSeq = '';

Turning:
	log( self$" Attack Pistol turning label for "$self );
	log( self$" AttackPistol begin Label 3" );

	if( TempEnemy == None )
	{
		Disable( 'SeePlayer' );
		Enable( 'EnemyNotVisible' );
	}
	else
		Enable( 'SeePlayer' );

	if( !IsAnimating( 1 ) )
	{
		StopFiring();	
		if( !IsAnimating( 0 ) )
			PlayToWaiting( 0.12 );
	 // log( "PLAY WEAPON IDLE 8" );
		PlayWeaponIdle( 0.12 );
		Sleep( 1.0 );
	}
	// log( "** MustTurnCheck" );
	DesiredRotation = rotator( HeadTrackingActor.Location - Location );
	if( MustTurn() )
	{
		StopFiring();
	//	Sleep( 0.2 * FRand() );
		bIsTurning = true;
		Sleep( 0.1 );
		Goto( 'Begin' );
	}
	else
		log(" MustTurn is false!" );
	bReadyToAttack = true;
		// log( self$" AttackPistol begin Label 4" );

	if( GetSequence( 1 ) == '' )
	{
			// // // // log( "PLAY WEAPON IDLE 9" );
		PlayWeaponIdle();
		Sleep( 0.5 );
	}

DoneTurn:
		// log( self$" AttackPistol begin Label 5" );

	if( TempEnemy == None )
	{
		Disable( 'SeePlayer' );
		Enable( 'EnemyNotVisible' );
	}
	else
		Enable( 'SeePlayer' );

	StopFiring();
/*	if( !bKneelAtStartup && GetPostureState() == PS_Crouching )
	{
		bIntoCrouch = true;
		broadcastmessage( "PLAYTOSTAND 1" );
		PlayToStanding();
		FinishAnim( 2 );
		bIntoCrouch = false;
		SetPostureState( PS_Standing );

		PlayToWaiting( 0.35 );
		Sleep( 0.15 );
	}*/
	bIsTurning = false;
	Sleep( 0.25 );

Firing:
	// // // log( self$ "Attack pistol firing label for "$self );
		// log( self$" AttackPistol begin Label 6" );
/*	if( VSize( Enemy.Location - Location ) > 600 )
	{
		PlayTopAnim( 'T_ThrowSmall',, 0.1, false );
		FirePipeBomb();
		Sleep( 1.5 );
		ChooseAttackState();
	}
*/
	if( SafeToCrouch() && GetPostureState() != PS_Crouching && !MustTurn( Enemy ) && !bCrouchShiftingDisabled && FRand() < 0.6 )
	{
		TransitionCrouch();
	}
	else if( !bCrouchShiftingDisabled && GetPostureState() == PS_Crouching )
	{
		Goto( 'StandUp' );
	}
	else
	if( !bDodgeSidestepDisabled && FRand() < 0.25 && GetPostureState() != PS_Crouching && !MustTurn( Enemy ) ) //&& VSize( Location - Enemy.Location ) > 256 )
		
	{
		SetDodgeDisabled();
		GotoState( 'DodgeSideStep' );
	}

	if( Weapon.GottaReload() )
	{
		// Necessary or not?
		//if( CurrentCoverSpot == None && MyCombatController.CheckLastOrderTime( self ) )
		//{
		//	 // // // // log( Going to controlledcombat 4 for "$self );
		//	GotoState( 'ControlledCombat' );
		//}
		//else
		//{
			NextState = GetStateName();
			NextLabel = 'AfterFire';
			GotoState( 'Reloading' );
		//}
	}

	if( TempEnemy == None )
	{
		Disable( 'SeePlayer' );
		Enable( 'EnemyNotVisible' );
	}
	else
		Enable( 'SeePlayer' );

	dnWeapon( Weapon ).FireAnim.AnimTween = 0.24;
			// // // // log( "PLAY WEAPON IDLE 10" );
	PlayWeaponIdle();
	Disable( 'AnimEnd' );
	PlayTopAnim( 'T_Pistol2HandFire',, 0.1, false, false, false );
	PlayRangedAttack();
	Weapon.ClientSideEffects( false );
	StopFiring();
	FinishAnim( 1 );
	PlayWeaponIdle( 0.12 );
	Enable( 'AnimEnd' );
	Sleep( 0.1 + ( FRand() * 0.1 ) );

AfterFire:
	// // // log( self$" Attack pistol AfterFire label for "$self );
	// log( self$" AttackPistol begin Label 7" );

	// Handle crouching.
	PlayToWaiting( 0.12 );

	if( GetPostureState() != PS_Crouching && VSize( Enemy.Location - Location ) < 72 )
		ChooseMeleeAttackState();

	if( FRand() < 0.5 && VSize( Location - Enemy.Location ) < 256 && GetPostureState() != PS_Crouching && CanRetreat() )
	{
		GotoState( 'Retreat' );
	}
	else
	if( MyCombatController != None )
	{
		if( FRand() < 0.75 && MyCombatController.CheckLastOrderTime( self ) )
		{
			// // log( self$" == Going to ControlledCombat state from AttackPistol state." );
			 // // // // log( Going to controlledcombat 3 for "$self );
			GotoState( 'ControlledCombat' );
		}
		else
		{
			//Sleep( 0.12 );
			Goto( 'Begin' );
		}
	}
	
	// Handle standing back up if necessary, else continue fire loop.
	if( GetPostureState() == PS_Crouching )
	{
		if( !MustTurn( Enemy ) )
			Goto( 'Firing' );
		else 
			Goto( 'StandUp' );
	}

	Goto( 'Begin' );
}


/*-----------------------------------------------------------------------------
	Attack state: M16 
-----------------------------------------------------------------------------*/
state AttackM16 extends Attack
{
	//ignores SeePlayer;
	function SeePlayer( actor Seen )
	{
		if( TempEnemy != None )
		{
			if( Enemy.IsA( 'AITempTarget' ) )
				Enemy.Destroy();

			// log( self$" SETTING ENEMY E" );
			Enemy = Seen;
			Target = Seen;
			TempEnemy = None;
			Disable( 'SeePlayer' );
			Enable( 'EnemyNotVisible' );
		}
		Super.SeePlayer( Seen );
	}

	function BeginState()
	{
		// // // // // log( AttackM16 BeginState. Enemy is "$Enemy );
	}

	function EndState()
	{
		if( FireController != None )
			FireController.Destroy();
	}

StandUp:
	// log( "StandUp label for "$self );
	if( GetPostureState() == PS_Crouching && !bKneelAtStartup )
	{
		bIntoCrouch = true;
		PlayToStanding();
		FinishAnim( 2 );
		PlayBottomAnim( 'None' );
		bIntoCrouch = false;
		SetPostureState( PS_Standing );
		PlayToWaiting( 0.35 );
			// // // // log( "PLAY WEAPON IDLE 11" );
		PlayWeaponIdle();
		Sleep( 0.15 );
	}
	// // // log( self$" ChooseAttackState From AttackM16 state 1" );
	ChooseAttackState();

DoneTurn:
	// // log( ### PLAYBOTTOM ANIM NONE 2" );
	// log( "DoneTurn label for "$self );
	PlayBottomAnim( 'None' );
	PlayAllAnim( 'A_IdleStandActive',, 0.1, true );
	bIsTurning = false;
Begin:
	// log( "Begin label for "$self );

	if( FRand() < 0.25 && !bSteelSkin && bCanSayAttackPhrase )
	{
	// log( "1 Begin label for "$self );

		SpeechCoordinator.RequestSound( self, 'RangedAttack' );
		bCanSayAttackPhrase = false;
		SetCallBackTimer( 2.0, false, 'EnableAttackPhrase' );
	}
	if( !MustTurn() )
	{
	// log( "2 Begin label for "$self );

		PlayToWaiting( 0.12 );
		PlayWeaponIdle();
	}

	if( TempEnemy == None )
		Disable( 'SeePlayer' );
	else
		Enable( 'SeePlayer' );
		// log( "3 Begin label for "$self$" HeadTrackingActor is: "$HeadTrackingActor );

	PlayWeaponIdle();
	if( TempEnemy == None )
		Enable( 'EnemyNotVisible' );
	if( !IsAnimating( 0 ) )
		PlayToWaiting( 0.12 );
	Enable( 'AnimEnd' );
	RotationRate.Yaw = 75000;
	HeadTrackingActor = Enemy;
	DesiredRotation = rotator( HeadTrackingActor.Location - Location );
	dnWeapon( Weapon ).FireAnim.AnimSeq = '';
	// log( "4 Begin label for "$self );

Turning:
	// // // log( self$" Disable SeePlayer 12 for "$self );
	// log( "TURNING label for "$self );
	if( TempEnemy == None )
	{
		Disable( 'SeePlayer' );
		Enable( 'EnemyNotVisible' );
	}
	else
		Enable( 'SeePlayer' );
	// log( "1 Turn label for "$self );

	if( !IsAnimating( 1 ) )
	{
		StopFiring();	
			// // // // log( "PLAY WEAPON IDLE 13" );
		PlayWeaponIdle( 0.12 );
		Sleep( 1.0 );
	// log( "21 Turn label for "$self );

	}
	if( MustTurn( Enemy ) )
	{
	// log( "3 Turn label for "$self );

		//Sleep( 0.2 * FRand() );
		bIsTurning = true;
		Sleep( 0.1 );
		Goto( 'Begin' );
	}
		// log( "4 Turn label for "$self );

	bReadyToAttack = true;

Firing:
	// log( "Firing 1 for "$self$" Enemy is "$Enemy );
	// // // log( self$" Disable SeePlayer 14 for "$self );
	if( SafeToCrouch() && GetPostureState() != PS_Crouching && !MustTurn( Enemy ) && !bCrouchShiftingDisabled && FRand() < 0.6 )
	{
	// log( "Firing 2 for "$self );
		TransitionCrouch();
	}
	else if( !bKneelAtStartup && !bCrouchShiftingDisabled && GetPostureState() == PS_Crouching )
	{
	// log( "Firing 3 for "$self );
		Goto( 'StandUp' );
	}
	else
	if( !bDodgeSidestepDisabled && FRand() < 0.25 && GetPostureState() != PS_Crouching && !MustTurn( Enemy ) ) //&& VSize( Location - Enemy.Location ) > 256 )
		
	{
	// log( "Firing 4 for "$self );
		// // log( GOING TO DODGEROLL 3" );
		SetDodgeDisabled();
		GotoState( 'DodgeSideStep' );
	}

	if( TempEnemy == None )
	{
	// log( "Firing 5 for "$self );
		Disable( 'SeePlayer' );
		Enable( 'EnemyNotVisible' );
	}
	else
		Enable( 'SeePlayer' );

	//Sleep( 0.11 );
	if( Weapon.GottaReload() )
	{
		//// // // // // log( Weapon GottaReload!" );
		// Necessary or not?
	// log( "Firing 6 for "$self );
		if( CurrentCoverSpot == None && MyCombatController.CheckLastOrderTime( self ) )
		{
			 // // // // log( Going to controlledcombat 4 for "$self );
			GotoState( 'ControlledCombat' );
		}
		else
		{
			NextState = GetStateName();
			NextLabel = 'AfterFire';
			GotoState( 'Reloading' );
		}
	}
		// log( "Firing 7 for "$self );
	dnWeapon( Weapon ).FireAnim.AnimTween = 0.1;
	PlayTopAnim( 'T_M16Fire', 6, 0.1, false, false, true );
	PlayRangedAttack();
	bFire = 0;
		// log( "Firing 8 for "$self );
	if( FRand() < 0.25 )
		Sleep( 0.65 );
	else
		Sleep( 0.13 );

AfterFire:
	// // // log( self$" Attack pistol AfterFire label for "$self );
	// log( self$" AttackPistol begin Label 7" );
	// log( "Firing 11 for "$self );
	// Handle crouching.
	PlayToWaiting( 0.12 );

	if( GetPostureState() != PS_Crouching && VSize( Enemy.Location - Location ) < 72 )
		ChooseMeleeAttackState();
	// log( "Firing 12 for "$self );
	if( FRand() < 0.23 && VSize( Location - Enemy.Location ) < 256 && GetPostureState() != PS_Crouching && CanRetreat() )
	{
		GotoState( 'Retreat' );
	}
	else
	if( MyCombatController != None )
	{
		if( FRand() < 0.75 && MyCombatController.CheckLastOrderTime( self ) )
		{
			// // log( self$" == Going to ControlledCombat state from AttackPistol state." );
			 // // // // log( Going to controlledcombat 3 for "$self );
			GotoState( 'ControlledCombat' );
		}
		else
		{
			//Sleep( 0.12 );
			Goto( 'Begin' );
		}
	}
	
	// Handle standing back up if necessary, else continue fire loop.
	if( GetPostureState() == PS_Crouching )
	{
		if( !MustTurn( Enemy ) )
			Goto( 'Firing' );
		else 
			Goto( 'StandUp' );
	}

	Goto( 'Begin' );
}

/*-----------------------------------------------------------------------------
	Attack state: Shotgun 
-----------------------------------------------------------------------------*/
state AttackShotgun extends Attack
{

Begin:
	Weapon.bInterruptFire = true;
	Enable( 'AnimEnd' );
	RotationRate.Yaw = 80000;
	DesiredRotation = rotator( HeadTrackingActor.Location - Location );
	dnWeapon( Weapon ).FireAnim.AnimSeq = '';
Turning:
	if( GetPostureState() == PS_Crouching )
		Goto( 'AfterFire' );
	if( GetSequence( 1 ) == '' )
	{
		StopFiring();	
		PlayTopAnim( 'T_SGIdle',, 0.12, true );
		Sleep( 1.0 );
	}

	if( MustTurn() )
	{
		StopFiring();
		Sleep( 0.2 * FRand() );
		bIsTurning = true;
		Sleep( 0.1 );
		Goto( 'Begin' );
	}
	bReadyToAttack = true;
	if( GetSequence( 1 ) == '' )
	{
			// // // // log( "PLAY WEAPON IDLE 14" );
		PlayWeaponIdle();
		Sleep( 1.0 );
	}

DoneTurn:
	StopFiring();
	PlayBottomAnim( 'None' );
	PlayAllAnim( 'A_IdleStandActive',, 0.1, true );
	bIsTurning = false;
	Sleep( 0.5 );

Firing:
	if( !MustTurn() )
	{
		dnWeapon( Weapon ).FireAnim.AnimTween = 0.14;
			// // // // log( "PLAY WEAPON IDLE 15" );
		PlayWeaponIdle();
		PlayTopAnim( 'T_SGFire',, 0.1, false, false, false );
		PlayRangedAttack();
		//Weapon.ClientSideEffects( false );
	//	Weapon.AmmoLoaded -= 1;
	//	Sleep( 1.5 );
		// // // log( self$" Trying to Finish anim "$GetSequence( 1 ) );
		Sleep( 1.5 );
		// // // log( self$" Finished sequence." );
			// // // // log( "PLAY WEAPON IDLE 16" );
		PlayWeaponIdle();
		StopFiring();
	}
	if( Weapon.GottaReload() ) 
	{
		StopFiring();
		NextState = GetStateName();
		NextLabel = 'AfterFire';
log( self$" GOING TO RELOADING 3" );
		GotoState( 'Reloading' );
	}

AfterFire:
	// Handle crouching.
	if( !MustTurn( Enemy ) && FRand() < 0.2 && GetPostureState() != PS_Crouching && !bCrouchShiftingDisabled )
	{
		bCrouchShiftingDisabled = true;
		PlayToCrouch();
		FinishAnim( 2 );
		// log( self$" ==== PLAYING KNEEL IDLE 5" );
		PlayBottomAnim( 'B_KneelIdle',, 0.13, true );
	}
	// Handle standing back up if necessary, else continue fire loop.
	if( GetPostureState() == PS_Crouching )
	{
		if( !MustTurn( Enemy ) )
			Goto( 'Firing' );
		else 
		{
			bIntoCrouch = true;
			PlayToStanding();
			FinishAnim( 2 );
			PlayBottomAnim( 'None' );
			bIntoCrouch = false;
			SetPostureState( PS_Standing );
			PlayToWaiting( 0.35 );
			// // // // log( "PLAY WEAPON IDLE 17" );
			PlayWeaponIdle();
			SetCrouchDisabled();
			Sleep( 0.25 );
		}
	}

	// Handle random side-to-side dodging.
	else if( !MustTurn( Enemy ) && FRand() < 0.2 && VSize( Location - Enemy.Location ) > 356 )
	{
		HeadTrackingActor = None;
		Disable( 'AnimEnd' );
		bRotateToDesired = false;
		SetDodgeDestination();
		Sleep( 0.1 );
		StrafeTo( Destination, Enemy.Location, 0.5 );
		FinishAnim( 0 );
		StopMoving();
			// // // // log( "PLAY WEAPON IDLE 18" );
		PlayWeaponIdle();
		PlayToWaiting( 0.14 );
		Sleep( 0.12 );
		Enable( 'AnimEnd' );
		HeadTrackingActor = Enemy;
		bRotateToDesired = true;
		Sleep( 0.25 );
	}
	if( Weapon.GottaReload() ) 
	{
		StopFiring();
		NextState = GetStateName();
		NextLabel = 'AfterFire';
log( self$" GOING TO RELOADING 4" );
		GotoState( 'Reloading' );
	}
	if( FRand() < 0.23 && VSize( Location - Enemy.Location ) < 256 && GetPostureState() != PS_Crouching && CanRetreat() )
	{
		GotoState( 'Retreat' );
	}

	Goto( 'Begin' );
}

/*-----------------------------------------------------------------------------
	TakeHit state.

-----------------------------------------------------------------------------*/

state TakeHit 
{
	ignores seeplayer, hearnoise, bump, hitwall;

/*	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> DamageType)
	{
		if( bNPCInvulnerable )
			return;

		Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
	}
*/
	
	function Landed(vector HitNormal)
	{
		if (Velocity.Z < -1.4 * JumpZ)
			MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));
		bJustLanded = true;
	}

	function Timer( optional int TimerNum )
	{
		bReadyToAttack = true;
	}

	function BeginState()
	{
		//bCanTorsoTrack = false;
		if ( (NextState == 'TacticalTest') && (Region.Zone.ZoneGravity.Z > Region.Zone.Default.ZoneGravity.Z) )
			Destination = location;
		HeadTrackingActor = None;
	}
		
	function EndState()
	{
		//bCanTorsoTrack = true;
		if( TestFocus != None )
			TestFocus.Destroy();
		HeadTrackingActor = Enemy;
		if( FireController != None )
			FireController.Destroy();
		//	HeadTrackingActor = Enemy;
	}

Begin:
	// // // log( self$" TakeHit begin label for "$self );
	StopMoving();
	WaitForLanding();
	if( bRetreatAtStartup )
	{
		bRetreatAtStartup = false;
		bRotateToEnemy = false;
		SetAutoFireOff();
	}

	StopFiring();
	bIsTurning = false;

	SpeechCoordinator.RequestSound( self, 'Pain' );
	AimAdjust = 10000;

	if( NextState != 'Reloading' )
		NextState = 'Attacking';
	
	if( IsAnimating( 3 ) )
	{
		FinishAnim( 3 );
		PlaySpecialAnim( 'None' );
	}
	else
		FinishAnim( 0 );

	PlayToWaiting( 0.12 );
	StopMoving();

	if( ShotGun( Weapon ) != None )
	{
		PlayToWaiting( 0.22 );
			// // // // log( "PLAY WEAPON IDLE 19" );
		PlayWeaponIdle( 0.22 );
		Sleep( 0.25 + ( FRand() * 0.2 ) );
	}

	if( bArmless  )
		SwitchToWeapon( ChooseBestWeapon() );

	bAnimatePain = false;
	SetCallBackTimer( 3.5, false, 'EnablePainAnims' );

	AimAdjust = 0;
	//ChooseAttackState( 'Begin', true );
	ChooseAttackState();
}

	function EnableSawEnemy()
	{
		bSawEnemy = false;
	}

/*-----------------------------------------------------------------------------
	Hunting State. 
-----------------------------------------------------------------------------*/
state Hunting
{
	ignores EnemyNotVisible, SeePlayer; 


	/* MayFall() called by engine physics if walking and bCanJump, and
		is about to go off a ledge.  Pawn has opportunity (by setting 
		bCanJump to false) to avoid fall
	*/
/*
	function MayFall()
	{
		bCanJump = true;
		bCanEmergencyJump = false;
		JumpZ = 250;
	}

  
*/
	function Bump(actor Other)
	{
		local vector VelDir, OtherDir;
		local float speed, dist;
		local Pawn P,M;
		local bool bDestinationObstructed, bAmLeader;
		local int num;

		MoveTimer = -1.0;
		PlayToWaiting();
	/*
	speed = VSize(Velocity);
	if ( speed > 1 )
	{
		VelDir = Velocity/speed;
		VelDir.Z = 0;
		OtherDir = Other.Location - Location;
		OtherDir.Z = 0;
		OtherDir = Normal(OtherDir);
		if ( (VelDir Dot OtherDir) > 0.8 )
		{
			if ( Pawn(Other) == None )
			{
				MoveTimer = -1.0;	
				HitWall(-1 * OtherDir, Other);
			} 
			Velocity.X = VelDir.Y;
			Velocity.Y = -1 * VelDir.X;
			Velocity *= FMax(speed, 280);
		}
	} */
//	Disable('Bump');
}

/*	function SeePlayer(Actor SeenPlayer)
	{
		if( bAggressiveToPlayer )
		{
			if(	IsLimping() )
			{
				GotoState( 'Hunting', 'EnemySeen' );
				Disable( 'SeePlayer' );
			}
		}
	}	
*/	
	function MayFall()
	{
		bCanJump = ( ((MoveTarget != None) 
					&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Inventory')))
					|| PointReachable(Destination) );
	}

	function bool CheckBumpAttack(Pawn Other)
	{
		if( Other.bSnatched != bSnatched )
		{
			SetEnemy(Other);
			if ( Enemy == Other )
			{
				bReadyToAttack = true;
				LastSeenTime = Level.TimeSeconds;
				LastSeenPos = Enemy.Location;
				// // // log( self$" ChooseAttackState From Hunting state 1" ); 
				ChooseAttackState();
				return true;
			}
		}
		return false;
	}
	
	function SetFall()
	{
		NextState = 'Hunting'; 
		NextLabel = 'AfterFall';
	}

	event SawEnemy()
	{
		// HERE
//		log( self$" SAW ENEMY "$Enemy$" from Hunting state" );
//		log( self$" bSawEnemy was "$bSawEnemy );
		if( CurrentCoverSpot != None && VSize( Location - CurrentCoverSpot.Location ) > 128 )
		{
			CurrentCoverSpot.bOccupied = false;
		}
//		if( !bSawEnemy )
//		{
			bSawEnemy = true;
			//StopMoving();
			//PlayToWaiting( 0.12 );
			 // // log( self$" Going to Hunting 7" );
//			GotoState( 'Hunting', 'Acquisition' );
			GotoState( 'HuntAcquisition' );
			//			ChooseAttackState();
//		}
	}


	function bool SetEnemy(Actor NewEnemy)
	{
		local float rnd;

		if (Global.SetEnemy(NewEnemy))
		{
			bDevious = false;
			BlockedPath = None;
			rnd = FRand();
			bReadyToAttack = true;
//			DesiredRotation = Rotator(Enemy.Location - Location);
			// // // log( self$" ChooseAttackState From Hunting state 2" );
			ChooseAttackState();
			return true;
		}
		return false;
	} 

	/*function Timer( optional int TimerNum )
	{
		if( TimerNum == 5 )
		{
			MoveTimer = -1.0;
			StopMoving();
			PlayToWaiting();
			GotoState( 'Attacking' );
		}
		else
		{
			bReadyToAttack = true;
			Enable('Bump');
			SetTimer(1.0, false);
		}
	}*/

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('DoorMover')  )
		{
			SpecialPause = 0.45;
			if ( SpecialPause > 0 )
			{
				StopMoving();
				NotifyMovementStateChange( MS_Waiting, MS_Walking );
			}
			SuspiciousActor = Wall;
			GotoState('Hunting', 'SpecialNavig');
			return;
		}
		Focus = Destination;
		if (PickWallAdjust())
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('Hunting', 'AdjustFromWall');
		}
		else
			MoveTimer = -1.0;
	}

	function bool TryToward(inventory Inv, float Weight)
	{
		local bool success; 
		local vector pickdir, collSpec, minDest, HitLocation, HitNormal;
		local Actor HitActor;

		pickdir = Inv.Location - Location;
		if ( Physics == PHYS_Walking )
			pickDir.Z = 0;
		pickDir = Normal(PickDir);

		collSpec.X = CollisionRadius;
		collSpec.Y = CollisionRadius;
		collSpec.Z = FMax(6, CollisionHeight - 18);
		
		minDest = Location + FMin(160.0, 3*CollisionRadius) * pickDir;
		HitActor = Trace(HitLocation, HitNormal, minDest, Location, false, collSpec);
		if (HitActor == None)
		{
			success = (Physics != PHYS_Walking);
			if ( !success )
			{
				collSpec.X = FMin(14, 0.5 * CollisionRadius);
				collSpec.Y = collSpec.X;
				HitActor = Trace(HitLocation, HitNormal, minDest - ( /*18 +*/ MaxStepHeight) * vect(0,0,1), minDest, false, collSpec);
				success = (HitActor != None);
			}
			if ( success )
			{
				MoveTarget = Inv;
				return true;
			}
		}

		return false;
	}

	function PickDestination()
	{
		local inventory Inv, BestInv, SecondInv;
		local float Bestweight, NewWeight, MaxDist, SecondWeight;
		local NavigationPoint path;
		local actor HitActor;
		local vector HitNormal, HitLocation, nextSpot, ViewSpot;
		local float posZ;
		local bool bCanSeeLastSeen;
		local int i;

		// // // log( self$" Pick Destination in hunting for "$self$" 1 " );
		bAvoidLedges = false;
		if ( JumpZ > 0 )
			bCanJump = true;





		if ( ActorReachable(Enemy) )
		{
		// // // log( self$" Pick Destination in hunting for "$self$" 2 " );
			BlockedPath = None;
			if ( (numHuntPaths < 8 + Skill) || (Level.TimeSeconds - LastSeenTime < 15)
				|| ((Normal(Enemy.Location - Location) Dot vector(Rotation)) > -0.5) )
			{
				Destination = Enemy.Location;
				MoveTarget = None;
				numHuntPaths++;
			}
			else
			{
				WhatToDoNext('','');
			}

			return;
		}

		numHuntPaths++;
		ViewSpot = Location + BaseEyeHeight * vect(0,0,1);
		bCanSeeLastSeen = false;
		bCanSeeLastSeen = FastTrace(LastSeenPos, ViewSpot);
		if ( bCanSeeLastSeen )
		{
			bHunting = !FastTrace(LastSeenPos, Enemy.Location);
		}
		else
			bHunting = true;

		bHunting = true;

		if ( /*FRand() < 0.33 &&*/ BlockedPath == None )
		{
			// block the first path visible to the enemy
			if ( FindPathToward(Enemy) != None )

			{
				//// //// // // // // log( FOUND PATH" );
				for ( i=0; i<16; i++ )
				{
					if ( RouteCache[i] == None )
						break;
					if( Pawn( Enemy ).LineOfSightTo(RouteCache[i]) )
					{
						BlockedPath = RouteCache[i];
						break;
					}
				}
			}
		/*	else if ( CanStakeOut() )
			{
				PlayToWaiting();
				GotoState('WaitingForEnemy');
				return;
			}*/
			else
			{
				if( bFixedPosition )
				{
		// // // log( self$" Pick Destination in hunting for "$self$" 3 " );
					SightlessFireTime = 4.0;
					bSightlessFire = true;
					 // // log( self$" Going to WaitingForEnemy state 3" );
							GotoState( 'WaitingForEnemy' );

					return;
				}

			if( bCanEmergencyJump )
			{
				bCanJump = true;
				JumpZ = 250;
				 // // log( self$" Going to Hunting 1" );

				GotoState( 'Hunting' );
				bCanEmergencyJump = false;
			}
			else
			{
				bCanJump = false;
				JumpZ = -1;
				//GotoState( 'WaitingForEnemy' );
				RehuntCount++;
				 // // log( self$" Going to Hunting 2" );
				GotoState( 'Hunting', 'ReHunt'  );
				
//				WhatToDoNext('', '');
			}

			return;
		}
	}

		// control path weights
		ClearPaths();
		//// // // log( self$" Setting BlockedPath: "$BlockedPath$" cost to 15000000" );
		BlockedPath.DrawScale = 2 * BlockedPath.Default.Cost;
		BlockedPath.Cost = 15000000;
		//BlockedPath.ExtraCost = 15000000;
		//RouteCache[ 0 ].Cost = 15000000;
		//RouteCache[ 0 ].ExtraCost = 15000000;
		if ( FindBestPathToward(Enemy, true) )
		{
			// log(" FOUND PATH" );
			return;
		}
		else
			// log(" CANNOT PATH TO ENEMY" );
		MoveTarget = None;
		if ( bFromWall )
		{
			bFromWall = false;
			if ( !PickWallAdjust() )
			{
				//if ( CanStakeOut() )
		// // // log( self$" Pick Destination in hunting for "$self$" 4 " );
			 // // log( self$" Going to WaitingForEnemy state 4" );
				GotoState('WaitingForEnemy');
				//else
				//	WhatToDoNext('', '');
			}
			return;
		}
		if ( LastSeeingPos != vect(1000000,0,0) )
		{
			Destination = LastSeeingPos;
			LastSeeingPos = vect(1000000,0,0);		
			if ( FastTrace(Enemy.Location, ViewSpot) )
			{
				If (VSize(Location - Destination) < 20)
				{
					SetEnemy( Pawn( Enemy ) );
					return;
				}
				return;
			}
		}
		bAvoidLedges = (CollisionRadius > 42);
		posZ = LastSeenPos.Z + CollisionHeight - Enemy.CollisionHeight;
		nextSpot = LastSeenPos - Normal(Enemy.Location - Enemy.OldLocation) * CollisionRadius;
		nextSpot.Z = posZ;
		if ( FastTrace(nextSpot, ViewSpot) )
			Destination = nextSpot;
		else if ( bCanSeeLastSeen )
			Destination = LastSeenPos;
		else
		{
			Destination = LastSeenPos;
			if ( !FastTrace(LastSeenPos, ViewSpot) )
			{
				// check if could adjust and see it
				if ( PickWallAdjust() || FindViewSpot() )
				{
					if ( Physics == PHYS_Falling )
						SetFall();
					else
						GotoState('Hunting', 'AdjustFromWall');
				}
				else if ( VSize(Enemy.Location - Location) < 1200 )
				{
		// // // log( self$" Pick Destination in hunting for "$self$" 5 " );
			 // // log( self$" Going to WaitingForEnemy state 5" );
		GotoState('WaitingForEnemy');
					return;
				}
				else
				{
					WhatToDoNext('Waiting', 'TurnFromWall');
					return;
				}
			}
		}
		LastSeenPos = Enemy.Location;				
	}	

	function bool FindViewSpot()
	{
		local vector X,Y,Z;
		local bool bAlwaysTry;

		GetAxes(Rotation,X,Y,Z);

		// try left and right
		// if frustrated, always move if possible
		bAlwaysTry = bFrustrated;
		bFrustrated = false;
		
		if ( FastTrace(Enemy.Location, Location + 2 * Y * CollisionRadius) )
		{
			Destination = Location + 2.5 * Y * CollisionRadius;
			return true;
		}

		if ( FastTrace(Enemy.Location, Location - 2 * Y * CollisionRadius) )
		{
			Destination = Location - 2.5 * Y * CollisionRadius;
			return true;
		}
		if ( bAlwaysTry )
		{
			if ( FRand() < 0.5 )
				Destination = Location - 2.5 * Y * CollisionRadius;
			else
				Destination = Location - 2.5 * Y * CollisionRadius;
			return true;
		}

		return false;
	}

	function bool CrouchNodeNearby()
	{
		local NavigationPoint P;

		for( P = Level.NavigationPointList; P != None; P = P.NextNavigationPoint )
		{
			if( P.IsA( 'CrouchNode' ) )
			{
				CurrentCrouchNode = P;
				return true;
			}
		}
		return false;
	}

	function BeginState()
	{
		// FIXME: needed?
		if( Enemy != None && Pawn( Enemy ).Visibility <= 0 )
		{
			GotoState( 'WaitingForEnemy' );
		}

		HeadTrackingActor = Enemy;

		//if( Pawn( Enemy ).GetPostureState() == PS_Crouching )
		//{
		//	if( CrouchNodeNearby() )
		//	{	
		//		GotoState( 'CrouchAttack' );
		//		return;
		//	}
		//}

		if( bFixedPosition )
		{
			 // // log( self$" Going to WaitingForEnemy state 6" );
			GotoState( 'WaitingForEnemy' );
		}

		if( bCoverOnAcquisition )
		{
		//	bCoverOnAcquisition = false;
			//// // // // // log( Going to NewCover 9" );
			GotoState( 'NewCover' );
			return;
		}

		if( bAtDuckPoint || bAtCoverPoint )
		{
			if( !MyCoverPoint.bExitOnCantSee )
			{
			 // // log( self$" Going to WaitingForEnemy state 10" );
				GotoState( 'WaitingForEnemy' );
				return;
			}
		}

		SetTimer( 0.25, true, 5 );
		SpecialGoal = None;
		SpecialPause = 0.0;
		bFromWall = false;
		SetAlertness(0.5);
	}

	function EndState()
	{
		if( MyCombatController != None )
		{
	//		MyCombatController.UnsetHunting( self );
		}

		if( Enemy != None )
			HeadTrackingActor = Enemy;

		bSawEnemy = false;
		bAvoidLedges = false;
		bHunting = false;
		if ( JumpZ > 0 )
			bCanJump = true;
		bCanSayPinDownPhrase = true;
	}

CrouchWalk:
	PlayToCrouch();
	FinishAnim( 2 );
	// log( self$" ==== PLAYING KNEEL IDLE 6" );
	PlayBottomAnim( 'B_KneelIdle',, 0.13, true );
	Sleep( 50.0 );

ReHunt:
	Sleep( 0.25 );
	if( RehuntCount < 20 )
	{
		 // // log( self$" Going to Hunting 3" );
		GotoState( 'Hunting' );
	}
	else
	{
					 // // log( self$" Going to WaitingForEnemy state 7" );
					GotoState( 'WaitingForEnemy' );
	}

AdjustFromWall:
	Enable('AnimEnd');
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	if ( MoveTarget != None )
		Goto('SpecialNavig');
	else
		Goto('Follow');

Acquisition:
	// Optional sleep time, else hunt will stop at the moment enemy is sighted. What's best?
	Sleep( 0.1 );
	StopMoving();
	PlayToWaiting( 0.12 );
			// // // // log( "PLAY WEAPON IDLE 20" );
	PlayWeaponIdle( 0.12 );
	Sleep( 0.13 );
	ChooseAttackState();

Begin:
	//bAtCoverPoint = false;
	//bAtDuckPoint = false;
	// Handle standing back up if necessary, else continue fire loop.

	// // // log( self$" ** hunting 1 "$self );
	if( GetPostureState() == PS_Crouching )
	{
			// // // // log( "PLAY WEAPON IDLE 21" );
		PlayWeaponIdle( 0.12 );
		bIntoCrouch = true;
		PlayToStanding();
		FinishAnim( 2 );
		PlayBottomAnim( 'None' );
		bIntoCrouch = false;
		SetPostureState( PS_Standing );
		PlayToWaiting( 0.35 );
		Sleep( 0.15 );
	}
	// // // log( self$" ** hunting 2 "$self );
	if( !bSteelSkin && SpeechCoordinator != None )
		SpeechCoordinator.RequestSound( self, 'Hunting' );
	
	if( getSequence( 1 ) == 'T_WeaponChange2' )
		FinishAnim( 1 );

	bFire = 0;
	numHuntPaths = 0;
	// // // log( self$" ** hunting 3 "$self );
AfterFall:
	NotifyMovementStateChange( MS_Running, MS_Waiting );
	bFromWall = false;

Follow:
	// // // log( self$"** hunting 4 "$self );
	WaitForLanding();

	if( Enemy.Physics != PHYS_Falling )
		PickDestination();
	else
	{
	// // // log( self$"** hunting 5 "$self );
		Sleep( 0.2 );
		Goto( 'Follow' );
	}
SpecialNavig:
	// // // log( self$"** hunting 6 "$self );
	if( bAtCoverPoint || bAtDuckPoint )
	{
		bAtCoverPoint = false;
		bAtDuckPoint = false;

		MyCoverPoint.Taken = false;
	}
	// // // log( self$"** hunting 7 "$self );
	if ( SpecialPause > 0.0 )
	{
		if( !DoorMover( SuspiciousActor ).bLocked && DoorMover( SuspiciousActor ).bKickable )
		{
			//// // // log( self$" trying to kick a door open." );
			Acceleration = vect(0,0,0);
			NotifyMovementStateChange( MS_Waiting, MS_Walking );
			if( NeedToTurn( SuspiciousActor.Location ) )
			{
				StopMoving();
	
				if( ( Normal( vector( Rotation ) cross vect( 0, 0, 1 ) ) dot( Location - Enemy.Location ) ) > 0 )
				{	
					PlayTurnRight();
				}
				else
				{
					PlayTurnLeft();
				}
				TurnTo(SuspiciousActor.Location);
				PlayToWaiting();
			}
			PlayAllAnim( 'A_Kick_Front',, 0.2, false );
			DoorMover( SuspiciousActor ).bKickedOpen = true;
			DoorMover( SuspiciousActor ).Used( self, self );			
			FinishAnim( 0 );
			SpecialPause = 0;
			bFire = 0;
			bAltFire = 0;
		}
		else
		{
			Focus = Destination;
			if (PickWallAdjust())
				GotoState('Roaming', 'AdjustFromWall');
			else
				MoveTimer = -1.0;
		}
	// // // log( self$"** hunting 8 "$self );
		Sleep(SpecialPause);
		SpecialPause = 0.0;
		Enable('AnimEnd');
		Goto('AfterFall');
	}
	NotifyMovementStateChange( MS_Running, MS_Waiting );
	if (MoveTarget == None)
	{
		PlayTopAnim( 'None' );
		PlayToRunning();
		MoveTo(Destination, GetRunSpeed() );
	}
	else
	{
		PlayTopAnim( 'None' );
		PlayToRunning();
		if( bSteelSkin )
			Destination = MoveTarget.Location;
		MoveToward(MoveTarget, GetRunSpeed() );
	}
	// // // log( self$"** hunting 9 "$self );
	Goto('Follow');
}

state HuntAcquisition
{

Begin:
	Sleep( 0.12 );
	StopMoving();
	PlayToWaiting( 0.12 );
	ChooseAttackState();
}

/*-----------------------------------------------------------------------------
	Pain, death, and dying.
-----------------------------------------------------------------------------*/
function TakeDamage(int Damage, Pawn instigatedBy, vector hitlocation, vector momentum, class<DamageType> DamageType)
{
	local int actualDamage;
	local bool bAlreadyDead;
	local EPawnBodyPart BodyPart;
	local MeshInstance Minst;
	local int Bone;

	
	if( bNPCInvulnerable )
	{
		return;
	}

	if( DamageBone != '' )
		BodyPart = GetPartForBone(DamageBone);
/*
	Minst = GetMeshInstance();
	//// //// // // // // log( DAMAGEBONE: "$DamageBone );

	TestFocus = Spawn( class'FocusPoint', self,, Minst.MeshToWorldLocation( Minst.BoneGetTranslate( Minst.BoneFindNamed( DamageBone ), true, false ) ) );
	TestFocus.SetPhysics( PHYS_MovingBrush );
	TestFocus.AttachActorToParent( self, true, true );
	TestFocus.MountType = MOUNT_MeshBone;
	TestFocus.MountMeshItem = DamageBone;
	HeadTrackingActor = TestFocus;
	//// //// // // // // log( New HeadTrackingACtor: "$HeadTrackingActor );
	*/
		/*
	 * COMMENTED OUT BY BRANDON FOR THE VIDEO
	if( InstigatedBy.Weapon.IsA( 'Shotgun' ) && ( Health - Damage <= 0 ) && ( InstigatedBy.Location.Z - Location.Z ) < 3 ) //InstigatedBy.Location.Z <= Location.Z )
	{
		if( !FacingWall() && !InFrontOfWall() )
		{
			bDamagedByShotgun = true;
			ShotgunInstigator = Enemy;
			if( bDamagedByShotgun )
			{
				if( FacingEnemy() )
					PlayAllAnim( 'A_FlyAir_B',, 0.1, true );
				else
				PlayAllAnim( 'A_FlyAir_F',, 0.1, true );
				SetPhysics( PHYS_Falling );
				Velocity.Z = 250;
				//Acceleration = vector( instigatedBy.Rotation ) * 1000;
				Acceleration = Momentum * 1500;
				GotoState( 'ShotgunDam' );
				return;
			}
		}
	}
	*/
	// // // // log( SEQ 0 WAS "$GetSequence( 0 ) );
	
	Super.TakeDamage( Damage, instigatedBy, hitlocation, momentum, damagetype );
	if( bNoPain )
		return;
		
	StopSound( SLOT_Talk );
	if( !bLimpingRight && ( BodyPart == BODYPART_KneeLeft || BodyPart == BODYPART_FootLeft ) )
	{
		if( LegHealthLeft <= 0 )
			bLimpingLeft = true;
		else
			LegHealthLeft -= 1;
	}
	else if( !bLimpingLeft && ( BodyPart == BODYPART_KneeRight || BodyPart == BODYPART_FootRight ) )
	{
		if( LegHealthRight <= 0 )
			bLimpingRight = true;
		else
			LegHealthRight -= 1;
	}
	if( GetStateName() != 'TransitionToCrouch' && GetControlState() != CS_Dead && !bSuffering && !bReloading && GetSequence( 0 ) != 'A_FallingRopeA' && GetSequence( 0 ) != 'A_FallGetUp' )
	{
		if( Enemy == None )
		{
			// log( self$" SETTING ENEMY F" );
			Enemy = instigatedBy;
		}
		//if( !bSnatched && !bAggressiveToPlayer && !bSuffering )
		//{
		//	GotoState( 'Cowering' );
		//	return;
		//}
		if( InstigatedBy != None && !InstigatedBy.IsA( 'HumanNPC' ) )
		{
			//HeadTrackingActor = InstigatedBy;
			// log( self$" SETTING ENEMY G" );

			Enemy = InstigatedBy;
		}
		if( bAnimatePain && !ClassIsChildOf(DamageType, class'EMPDamage') && PlayDamage(BodyPart, bShortPains,, Damage ) )
		{
			NextState = 'TakeHit';
			GotoState( 'TakeHit' );
		}
	}
	DamageBone = '';
}

function FearThisSpot(Actor aSpot, optional Pawn Instigator )
{
	local actor HitActor;
	local vector HitNormal, HitLocation;
	
	if( GetPostureState() != PS_Crouching )
	{
		if( Instigator != None )
		{
			if( !Instigator.IsA( 'HumanNPC' ) )
			{
							// log( self$" SETTING ENEMY H" );

				Enemy = Instigator;
			}
		}
		
		Destination = Location + 96 * Normal( Location - aSpot.Location );
		if( !PointReachable( Destination ) )
		{
				// // log( Setting bCoverOn true 2" );
			bCoverOnAcquisition = true;
			GotoState( 'NewCover' );
			return;
		}
		NotifyMovementStateChange( MS_Running, MS_Waiting );
		NextState = GetStateName();
		ThreatLocation = aSpot.Location;
		GotoState('Avoidance' );
	}
}

function Carcass SpawnCarcass( optional class<DamageType> DamageType, optional vector HitLocation, optional vector Momentum )
{
	local Carcass c;
	local CreaturePawnCarcass CPC;

	local SoftParticleSystem a;
	local Tentacle T;
	local meshinstance Minst, CMinst;
	local SnatchActor SA;
	local Weapon CarcassWeapon;

	c = Spawn( CarcassType );

	if( C.IsA( 'dnCarcass' ) )
		dnCarcass( c ).bCanHaveCash = bCanHaveCash;

	if( C != None && C.IsA( 'CreaturePawnCarcass' ) )
		CPC = CreaturePawnCarcass( C );

	if( CPC != None )
	{
		cpc.bHeadBlownOff = bHeadBlownOff;
		cpc.bArmless = bArmless;
		cpc.bEyesShut = bEyesShut;
		cpc.Initfor(self);
		cpc.PrePivot = PrePivot;

		if (cpc.bHeadBlownOff)
		{
			a = cpc.Spawn(class'dnBlood_Fountain1',,,Location + vect(FRand()*10.0 - 5.0, FRand()*10.0 - 5.0, CollisionHeight + FRand()*10.0 - 5.0) );
			a.AttachActorToParent(cpc,true,true);
			a.MountType = MOUNT_MeshBone;
			a.MountMeshItem = 'Neck';
			a.MountOrigin = vect(0,0,0);
			a.MountAngles = rot(0,0,0);
			a.SetPhysics(PHYS_MovingBrush);
			a.SpawnOnBounce = class<actor>(DynamicLoadObject("U_Generic.dnBloodSplatDecal", class'Class', true));
		}

		// Attach any lingering tentacles to the carcass.
		if( MySnatcher != None )
		{
			MySnatcher.SetOwner( cpc );
			MySnatcher.AttachActorToParent( cpc, true, true );
		}

		if( MyMouthTentacle != None )
		{
			MyMouthTentacle.SetOwner( cpc );
			MyMouthTentacle.AttachActorToParent( cpc, true, true );
		}
		if(	MyShoulderTentacle1 != None )
		{
			MyShoulderTentacle1.SetOwner( cpc );
			MyShoulderTentacle1.AttachActorToParent( cpc, true, true );
		}
		if( MyShoulderTentacle2 != None )
		{
			MyShoulderTentacle2.SetOwner( cpc );
			MyShoulderTentacle2.AttachActorToParent( cpc, true, true );
		}
		if( MyTemporaryTentacle != None )
		{
			MyTemporaryTentacle.SetOwner( cpc );
			MyTemporaryTentacle.AttachActorToParent( cpc, true, true );
		}
		if( MiniTentacle1 != None )
		{
			MiniTentacle1.SetOwner( cpc );
			MiniTentacle1.AttachActorToParent( cpc, true, false );
			MiniTentacle1.GotoState( 'Dying' );
		}
		if( MiniTentacle2 != None )
		{
			MiniTentacle2.SetOwner( cpc );
			MiniTentacle2.AttachActorToParent( cpc, true, false );
			MiniTentacle2.GotoState( 'Dying' );
		}
		if( MiniTentacle3 != None )
		{
			MiniTentacle3.SetOwner( cpc );
			MiniTentacle3.AttachActorToParent( cpc, true, false );
			MiniTentacle3.GotoState( 'Dying' );
		}
		if( MiniTentacle4 != None )
		{
			MiniTentacle4.SetOwner( cpc );
			MiniTentacle4.AttachActorToParent( cpc, true, false );
			MiniTentacle4.GotoState( 'Dying' );
		}
		
		if( TentacleBicepR != None )
			AttachTentacleToCarcass( cpc, TentacleBicepR );

		if( TentacleBicepL != None )
			AttachTentacleToCarcass( cpc, TentacleBicepL );

		if( TentacleChest != None )
			AttachTentacleToCarcass( cpc, TentacleChest );
	
		if( TentacleForearmL != None )
			AttachTentacleToCarcass( cpc, TentacleForearmL );
		
		if( TentacleForearmR != None )
			AttachTentacleToCarcass( cpc, TentacleForearmR );
	
		if( TentacleShinR != None )
			AttachTentacleToCarcass( cpc, TentacleShinR );

		if( TentacleShinL != None )
			AttachTentacleToCarcass( cpc, TentacleShinL );
	
		if( TentacleFootL != None )
			AttachTentacleToCarcass( cpc, TentacleFootL );
		
		if( TentacleFootR != None )
			AttachTentacleToCarcass( cpc, TentacleFootR );
	
		if( TentaclePelvis != None )
			AttachTentacleToCarcass( cpc, TentaclePelvis );

		if( bSnatched || bSteelSkin )
			CPC.bNoPupils = true;

		cpc.MeshDecalLink = MeshDecalLink;
	}
	
	Minst = GetMeshInstance();
	CMinst = CPC.GetMeshInstance();
	CMinst.MeshChannels[ 5 ].bAnimFinished = Minst.MeshChannels[ 5 ].bAnimFinished;
	CMinst.MeshChannels[ 5 ].bAnimLoop = false;
	CMinst.MeshChannels[ 5 ].bAnimNotify = Minst.MeshChannels[ 5 ].bAnimNotify;
	CMinst.MeshChannels[ 5 ].bAnimBlendAdditive = Minst.MeshChannels[ 5 ].bAnimBlendAdditive;
	CMinst.MeshChannels[ 5 ].AnimSequence = Minst.MeshChannels[ 5 ].AniMSequence;
	CMinst.MeshChannels[ 5 ].AnimFrame = Minst.MeshChannels[ 5 ].AnimFrame;
	CMinst.MeshChannels[ 5 ].AnimRate = Minst.MeshChannels[ 5 ].AnimRate;
	CMinst.MeshChannels[ 5 ].AnimBlend = Minst.MeshChannels[ 5 ].AnimBlend;
	CMinst.MeshChannels[ 5 ].TweenRate = Minst.MeshChannels[ 5 ].TweenRate;
	CMinst.MeshChannels[ 5 ].AnimLast = Minst.MeshChannels[ 5 ].AnimLast;
	CMinst.MeshChannels[ 5 ].AnimMinRate = Minst.MeshChannels[ 5 ].AnimMinRate;
	CMinst.MeshChannels[ 5 ].OldAnimRate = Minst.MeshChannels[ 5 ].OldAnimRate;
	CMinst.MeshChannels[ 5 ].SimAnim = Minst.MeshChannels[ 5 ].SimAnim;
	CMinst.MeshChannels[ 5 ].MeshEffect = Minst.MeshChannels[ 5 ].MeshEffect;
	
	
	// BRFIXME : The below block of code was causing the IsOverlapping crash. Not 100%, but almost once everytime
	// I'd play the level. A good level to check is "Test3" located in O:\DUKE4\MAP EXAMPLES ... just climb up the
	// ladder and you're on the (new) rooftop. Run about with a shotgun blasting guys. The crash is when they die.

	// Temporarily Disabled

/*	CarcassWeapon = Spawn( Weapon.Class );
	CarcassWeapon.SetOwner( self );
	CarcassWeapon.AttachActorToParent( C, true, true );
	CarcassWeapon.MountMeshItem = 'Weapon';
	CarcassWeapon.MountType = MOUNT_MeshSurface;
	CarcassWeapon.MountOrigin = vect( 0, 0, 6 );
	CarcassWeapon.SetPhysics( PHYS_MovingBrush );*/
	if( bSnatched && Frand() < HeadCreeperOdds )
		SpawnHeadCreeper( CPC );

	return cpc;
}

// Pain animation handling:
function bool PlayDamage(EPawnBodyPart BodyPart, optional bool bShortAnim, optional bool bKnockedDown, optional int Damage )
{
	local name BottomSeq;

	if( GetStateName() == 'Patrolling' && bPatrolIgnoreSeePlayer )
		return false;

	if( GetStateName() != 'Retreat' && ( bNoPain || ( bSteelSkin && Damage < 70 ) || ( !bSteelSkin && Acceleration != vect( 0, 0, 0 ) ) ) ) //|| ( bSteelSkin && Damage < 50 ) )
	{
		return false;
	}
	
	if( Weapon != None && Weapon.IsA( 'Shotgun' ) )
	{
		bFire = 0;
		bAltFire = 0;
	}

	if( GetPostureState() == PS_Crouching || BottomSeq == 'B_KneelIdle' || BottomSeq == 'B_KneelUp' || BottomSeq == 'B_KneelDown' )
	{
		bFire = 0;
		bAltFire = 0;

		if( bShieldUser )
		{
			return true;
		}

		switch(BodyPart)
		{
			case BODYPART_Head: PlaySpecialAnim( 'S_PainHead' ); break;
			case BODYPART_ShoulderRight: PlaySpecialAnim( 'S_PainRShoulder' ); break;
			case BODYPART_ShoulderLeft: PlaySpecialAnim( 'S_PainLShoulder' ); break;
			case BODYPART_HandLeft: PlaySpecialAnim( 'S_PainLShoulder' ); break;
			case BODYPART_HandRight: PlaySpecialAnim( 'S_PainRShoulder' ); break;
			case BODYPART_Chest: PlaySpecialAnim( 'S_PainStomach' ); break;
			default: PlaySpecialAnim( 'S_PainStomach' ); break;
		}
		bNoPain = true;
		return true;
	}

	if( !bShieldUser )
		PlayTopAnim('None');
	PlayBottomAnim('None');

	bShortAnim = true;

	if( bSteelSkin )
	{
		bKnockedBack = true;
		PlayAllAnim( 'A_RobotKnockBack',, 0.1, false );
		return true;
	}

	if( bKnockedDown )
	{
		PlayAllAnim( 'A_KnockDownF_All',, 0.1, false );
		bNoPain = true;
		return true;
	}

	BottomSeq = GetSequence( 2 );
	if( FRand() < 0.03 )
		bShortAnim = false;

	if( bShieldUser )
		bShortAnim = true;
	if (!bShortAnim)
	{
		switch(BodyPart)
		{
			case BODYPART_Head:
				PlayAllAnim('A_PainHeadLONG', 1.25, 0.13, false );
				break;

			case BODYPART_Chest:
				PlayAnim('A_PainChestLONG', 1.25, 0.13 );
				break;
		
			case BODYPART_Stomach: 
				PlayAnim('A_PainStomachLONG', 1.25, 0.13 );
				break;
		
			case BODYPART_Crotch:
				PlayAnim('A_PainBallsLONG', 1.25, 0.13 );
				break;
		
			case BODYPART_ShoulderLeft:
				PlayAnim('A_PainLshlderLONG', 1.25, 0.13 );
				break;
		
			case BODYPART_ShoulderRight: 
				PlayAnim('A_PainRshlderLONG', 1.25, 0.13 ); 
				break;			
		
			case BODYPART_HandLeft: 
				PlayAnim('A_PainLhandLONG', 1.25, 0.13 );
				break;
		
			case BODYPART_HandRight: 
				PlayAnim('A_PainRhandLONG', 1.25, 0.13 ); 
				break;
		
			case BODYPART_KneeLeft:
				PlayAnim('A_PainLkneeLONG', 1.25, 0.13 ); 
				break;
		
			case BODYPART_KneeRight: 
				PlayAnim('A_PainRkneeLONG', 1.25, 0.13 );
				break;
	
			case BODYPART_FootLeft:
				PlayAnim('A_PainLfootLONG', 1.25, 0.13 ); 
				break;
		
			case BODYPART_FootRight:
				PlayAnim('A_PainRfootLONG', 1.25, 0.13 ); 
				break;
		
			case BODYPART_Default: 
				PlayAnim('A_PainStomachLONG', 1.25); 
				break;
		}
	}
	else
	{
		// short animations
		switch(BodyPart)
		{
			case BODYPART_Head: 
				PlayAllAnim('A_PainHeadSHRT',, 0.13, false );
				break;

			case BODYPART_Chest:
				PlayAllAnim('A_PainChestSHRT',, 0.13, false );
	
				if( FRand() < 0.5 && bSnatched && TentacleChest == None && bSnatched )
					TentacleChest = CreateMiniTentacle( vect( 4, 0, 2 ), rot( 20384, 0, 0 ), 'Chest' );
				else if( FRand() < 0.22 && bSnatched && TentacleChest == None )
					TentacleChest = CreateMiniTentacle( vect( 4, 0, -5 ), rot( -20384, 0, 0 ), 'Chest' );
				
				break;
	
			case BODYPART_Stomach:
				if( bShieldUser )
					PlayAllAnim( 'A_PainChestShrt' );
				else PlayAllAnim('A_PainStomachSHRT',, 0.13, false );
			
				if( FRand() < 0.5 && bSnatched && MyTemporaryTentacle == None && Health > 15 )
				{
					MyTemporaryTentacle = CreateTentacle( vect( 3, 0, -10 ), rot( 0, 32768, 32768 ), 'Abdomen' );
					MyTemporaryTentacle.bHidden = false;
					MyTemporaryTentacle.GotoState( 'MAttackA' );
				}
				break;

			case BODYPART_Crotch:
				bFire=0; 
				bAltFire=0; 
				PlayAllAnim('A_PainBallsSHRT',, 0.13, false );
				if( FRand() < 0.5 && bSnatched && TentaclePelvis == None )
					TentaclePelvis = CreateMiniTentacle( vect( 0, 0, -2.5 ), rot( -20384, 0, 0 ), 'Pelvis' );
				break;

	
			case BODYPART_ShoulderLeft:
				PlayAllAnim('A_PainLshlderSHRT',, 0.13, false );

				if( Damage > 8 && FRand() < 0.5 )
				{
					bArmless = true;
					PlayAllAnim( 'A_PainLshlderLONG',, 0.13, false );
					if( !Weapon.IsA( 'Pistol' ) )
						Weapon.PutDown();
				}
				else if( !barmless && FRand() < 0.23 && bSnatched && MyShoulderTentacle2 == None && Health > 15 )
				{
					MyShoulderTentacle2 = CreateTentacle( TentacleOffsets.LeftShoulderOffset, TentacleOffsets.LeftShoulderRotation, 'Chest' );
					MyShoulderTentacle2.GotoState( 'ShoulderDamageTentacle' );
				}
				else if( !bArmless && bSnatched && TentacleBicepL == None )
					TentacleBicepL = CreateMiniTentacle( vect( 2, -2, 0 ), rot( 0, -10384, 0 ), 'Bicep_L' );

				break;
	
			case BODYPART_ShoulderRight:
				PlayAllAnim('A_PainRshlderSHRT',, 0.13, false );
				if( FRand() < 0.23 && bSnatched && MyShoulderTentacle1 == None && Health > 15 )
				{
					MyShoulderTentacle1 = CreateTentacle( TentacleOffsets.RightShoulderOffset, TentacleOffsets.RightShoulderRotation, 'Chest' );
					MyShoulderTentacle1.GotoState( 'ShoulderDamageTentacle' );
				}
	  			else if( TentacleBicepR == None && bSnatched )
					TentacleBicepR = CreateMiniTentacle( vect( 2, 2, 0 ), rot( 0, 10384, 0 ), 'Bicep_R' );
				break;			
		
			case BODYPART_HandLeft:
				if( bShieldUser )
					PlayAllAnim( 'A_PainChestShrt' );
				else PlayAllAnim('A_PainLhandLSHRT',, 0.13, false );

				if(	TentacleForearmL == None && bSnatched )
					TentacleForearmL = CreateMiniTentacle( vect( 0, 0, 0 ), rot( -10000, -12000, 0 ), 'Forearm_L' );
				break;
		
			case BODYPART_HandRight:
				if( bShieldUser )
					PlayAllAnim( 'A_PainChestShrt' );
				else PlayAllAnim('A_PainRhandSHRT',, 0.13, false );
			
				if( TentacleForearmR == None && bSnatched )
					TentacleForearmR = CreateMiniTentacle( vect( 0, 0, 0 ), rot( -10000, 12000, 0 ), 'Forearm_R' );
				break;
		
			case BODYPART_KneeLeft:
				PlayAllAnim('A_PainLkneeSHRT',, 0.13, false );
				if( FRand() < 0.5 && bSnatched && TentacleShinL == None )
					TentacleShinL = CreateMiniTentacle( vect( 0, 0, -1.5 ), rot( -23384, 16384 ), 'Shin_L' );
				break;
		
			case BODYPART_KneeRight: 
				PlayAllAnim('A_PainRkneeSHRT',, 0.13, false );
				if( FRand() < 0.5 && bSnatched && TentacleShinR== None )
					TentacleShinR = CreateMiniTentacle( vect( 0, 0, -1.5 ), rot( -9384, 16384, 0 ), 'Shin_R' );
				break;

			case BODYPART_FootLeft: 
				PlayAllAnim('A_PainLfootSHRT',, 0.13, false );
				if( FRand() < 0.5 && bSnatched && TentacleFootL == None )
					TentacleFootL = CreateMiniTentacle( vect( -1, 0, -5 ), rot( -7000, 0, 0 ), 'Foot_L' );
				break;

			case BODYPART_FootRight:
				PlayAllAnim('A_PainRfootSHRT',, 0.13, false );
				if( FRand() < 0.5 && bSnatched && TentacleFootR == None )
					TentacleFootR = CreateMiniTentacle( vect( -1, 0, -5 ), rot( -7000, 0, 0 ), 'Foot_R' );
				break;

			case BODYPART_Default:
				if( bShieldUser )
					PlayAllAnim( 'A_PainChestShrt' );
				else PlayAllAnim('A_PainStomachSHRT',, 0.13, false );
				if( FRand() < 0.5 && bSnatched && TentacleChest == None && bSnatched )
					TentacleChest = CreateMiniTentacle( vect( 4, 0, 2 ), rot( 20384, 0, 0 ), 'Chest' );
				else if( FRand() < 0.22 && bSnatched && TentacleChest == None )
					TentacleChest = CreateMiniTentacle( vect( 4, 0, -5 ), rot( -20384, 0, 0 ), 'Chest' );
				break;
		}
	}
	bNoPain = true;
	return true;
}


state Approach
{
	function Tick( float DeltaTime )
	{
		local rotator Yaw1, Yaw2;

		if( bIsTurning )
		{
			Destination = HeadTrackingActor.Location;

			if( VSize( vector( AYaw1 ) - vector( AYaw2 ) ) > 0.4 )
			{
				if( ( rotator( Destination - Location ) - Rotation).Yaw < 0)
				{
					if( GetSequence( 2 ) != 'B_StepLeft' )
						PlayBottomAnim( 'B_StepLeft', 1.25, 0.2, true );
				}
				else
				{
					if( GetSequence( 2 ) != 'B_StepRight' )
						PlayBottomAnim( 'B_StepRight', 1.25, 0.2, true );
				}
			}
			else if( GetSequence( 2 ) == 'B_StepLeft' || GetSequence( 2 ) == 'B_StepRight' )
			{
				GotoState( GetStateName(), 'DoneTurn' );
			}
		}
		Super.Tick( DeltaTime );
	}

	function AnimEndEx( int Channel )
	{
		if( Channel == 1 ) 
		{
						// // // // log( "PLAY WEAPON IDLE 22" );
			PlayWeaponIdle();
		}
	}

	function BeginState()
	{
		Enable( 'EnemyNotvisible' );
		HeadTrackingActor = Enemy;
	}

	function vector GetApproachPoint()
	{
		local vector X, Y, Z, CheckPoint, HitNormal, HitLocation;
		local actor HitActor;

		//GetAxes( Rotation, X, Y, Z );
		GetAxes( rotator( Enemy.Location - Location ), X, Y, Z );

		CheckPoint = ( Location + ( 24 * X ) );
		
		HitActor = Trace( HitLocation, HitNormal, Location + ( -64 * X ), Location, true );

		if( HitActor != None )
		{
		// // // log( self$"ChooseAttackState From Approach 1" );
			ChooseAttackState();
			return vect( 0, 0, 0 );
		}

		if( PointReachable( CheckPoint ) && CanSeeEnemyFrom( CheckPoint ) )
		{
			return CheckPoint;
		}
	}

DoneTurn:
	PlayBottomAnim( 'None' );
	PlayAllAnim( 'A_IdleStandActive',, 0.1, true );
	bIsTurning = false;

Begin:
	Enable( 'AnimEnd' );
	if( GetPostureState() == PS_Crouching )
	{
		bIntoCrouch = true;
		PlayToStanding();
		FinishAnim( 2 );
		PlayBottomAnim( 'None' );
		bIntoCrouch = false;
		SetPostureState( PS_Standing );
		PlayToWaiting( 0.35 );
			// // // // log( "PLAY WEAPON IDLE 23" );
		PlayWeaponIdle();
		Sleep( 0.15 );
	}
	if( !IsAnimating( 0 ) )
		PlayToWaiting( 0.12 );

	Enable( 'AnimEnd' );
	RotationRate.Yaw = 80000;
	//DesiredRotation = rotator( HeadTrackingActor.Location - Location );
	dnWeapon( Weapon ).FireAnim.AnimSeq = '';
Turning:
	if( !IsAnimating( 1 ) )
	{
		StopFiring();	
			// // // // log( "PLAY WEAPON IDLE 24" );
		PlayWeaponIdle( 0.12 );
		Sleep( 1.0 );
	}
	if( MustTurn( Enemy ) )
	{
		Sleep( 0.2 * FRand() );
		bIsTurning = true;
		Sleep( 0.1 );
		Goto( 'Begin' );
	}
	bReadyToAttack = true;

BeginRetreat:
PostBegin:
	//dnWeapon( Weapon ).FireAnim.AnimTween = 0.24;
	//PlayTopAnim( 'T_M16Fire',, 0.1, false, false, true );
	//PlayRangedAttack();
	//PlayOwnedSound(sound'dnsWeapn.m16.GunFire053', SLOT_Interface, SoundDampening*0.4 );
	//Weapon.ClientSideEffects( false );
	//Sleep( 0.1 + ( FRand() * 0.1 ) );
	//bRotateToEnemy = true;
	Destination = GetApproachPoint();
	if( GetSequence( 2 ) != 'B_SneakWalkBack' ) 
	{
		PlayBottomAnim( 'B_Walk',, 0.12, true );
			// // // // log( "PLAY WEAPON IDLE 25" );
		PlayWeaponIdle();
	}
	StrafeTo( Destination, Enemy.Location, 0.14 );
	
	//bRotateToEnemy = false;
	if( VSize( Location - Enemy.Location ) > 300 )
	{
		FireController.Destroy();
		// // // log( self$"ChooseAttackState From Approach 2" );
		ChooseAttackState();
	}
	else
		Goto( 'PostBegin' );
}

function Tick( float DeltaTime )
{
	local CoverSpot C;

	InterpolateCollisionHeight();

	Super.Tick( DeltaTime );

}

state Retreat 
{
	ignores SeePlayer;

	function HitWall( vector HitNormal, Actor HitWall )
	{
		StopMoving();
		PlayToWaiting( 0.12 );
		ChooseAttackState();
	}

	function Bump( actor Other )
	{
		log( self$" === RETREAT BUMP" );
		StopMoving();
		PlayToWaiting( 0.12 );
		ChooseAttackState();
	}


	// SetcallBackTimer( time, true/false, function name )
	// EndCallBackTimer()
	function AutoFireWeapon()
	{
		// FIXME: Auto reload weapon (temporary).
		if( Weapon.GottaReload() )
		{
			GotoState( 'Retreat', 'Reload' );
			EndCallBackTimer( 'AUtoFireWeapon' );
		}
		bFire = 1;
		dnWeapon( Weapon ).FireAnim.AnimTween = 0.1;
		PlayWeaponFire();
		Weapon.Fire();
	}

	function AnimEndEx( int Channel )
	{
		// // // log( self$"ANIMENDEX: "$GetSequence( Channel ) );
		if( Channel == 1 && GetSequence( 0 ) != 'A_RollRightA' )
		{
						// // // // log( "PLAY WEAPON IDLE 26" );
			PlayWeaponIdle();
		}
	}

	function EndState()
	{
		// // // // // log( SETTING AUTO FIRE OFF" );
		EndCallBackTimer( 'EnemyDistanceCheck' );
		SetAutoFireOff();
		MinHitWall = Default.MinHitWall;
	}

	function SetPlayerEnemy()
	{
		local PlayerPawn P;

		foreach allactors( class'PlayerPawn', P )
		{
			// log( self$" SETTING ENEMY L" );

			Enemy = P;
			break;
		}
	}

	function Tick( float DeltaTime )
	{
		local rotator Yaw1, Yaw2;

		if( GetSequence( 0 ) == 'A_SneakWalkBack' && MustTurn( Enemy ) )
		{
			StopMoving();
			PlayToWaiting();
			if( VSize( Location - Enemy.Location ) < 300 )
				GotoState( 'Retreat', 'Begin' );
			else
				ChooseAttackState();
		}
		/*
		else
		if( bIsTurning )
		{
			if( HeadTrackingActor == None )
				HeadTrackingActor = Enemy;

			Destination = HeadTrackingActor.Location;
			
			if( VSize( vector( AYaw1 ) - vector( AYaw2 ) ) > 0.4 )
			{
				if( ( rotator( Destination - Location ) - Rotation).Yaw < 0)
				{
					if( GetSequence( 2 ) != 'B_StepLeft' )
						PlayBottomAnim( 'B_StepLeft', 1.25, 0.2, true );
				}
				else
				{
					if( GetSequence( 2 ) != 'B_StepRight' )
						PlayBottomAnim( 'B_StepRight', 1.25, 0.2, true );
				}
			}
			else if( GetSequence( 2 ) == 'B_StepLeft' || GetSequence( 2 ) == 'B_StepRight' )
				GotoState( GetStateName(), 'DoneTurn' );
		}*/
		Super.Tick( DeltaTime );
	}

//	function AnimEndEx( int Channel )
//	{
//		if( Channel == 1 ) 
//			PlayWeaponIdle();
//	}

	function EnemyDistanceCheck()
	{
		if( VSize( Enemy.Location - Location ) < 135 )
		{
			bRetreatAtStartup = false;
			bRotateToEnemy = false;
			EndCallBackTimer( 'EnemyDistanceCheck' );
			SetAutoFireOff();
			// // // // // log( Going to Idling 1" );
			GotoState( 'Idling' );
		}
	}

			
	function BeginState()
	{
		Enable( 'EnemyNotvisible' );
		HeadTrackingActor = Enemy;
		MinHitWall = 400;
		if( bRetreatAtStartup )
		{
			SetCallBackTimer( 0.15, true, 'EnemyDistanceCheck' );
		}
			// SetcallBackTimer( time, true/false, function name )
// EndCallBackTimer()
		//	if( RetreatTimer > 0.0 )
	//	{
			//SetCallBackTimer( RetreatTimer, false, 'BreakRetreat' );
	//	}
	}

	function BreakRetreat()
	{
		GotoState( 'Patrolling' );
		EndCallBackTimer( 'BreakRetreat' );
	}


	function vector GetRetreatPoint()
	{
		local vector X, Y, Z, CheckPoint, HitNormal, HitLocation;
		local actor HitActor;
		local vector Loc1, Loc2, Loc3, Loc4;
		local AICoverController Temp;
		local vector VectorList[ 3 ];
		local int C;

		GetAxes( rotator( normal( Enemy.Location - Location ) ), X,Y,Z );

		VectorList[ 0 ] = Location + ( ( CollisionRadius ) * Y );
		VectorList[ 1 ] = Location - ( ( CollisionRadius ) * Y );
		VectorList[ 2 ] = Location + ( ( CollisionHeight ) * Z );
		VectorList[ 3 ] = Location - ( ( CollisionHeight ) * Z );

		for( C = 0; C <= 3; C++ )
		{
			HitActor = Trace( HitLocation, HitNormal, VectorList[ C ] + ( -72 * X ), VectorList[ C ], true );
			if( HitActor != None )
			{
				StopMoving();
				PlayToWaiting( 0.12 );
				ChooseAttackState();
				return vect( 0, 0, 0 );
			}
		}
	
//		GetAxes( rotator( normal(  Enemy.Location - Location ) ), X, Y, Z );

		CheckPoint = ( Location + ( -24 * X ) );
		
	//	HitActor = Trace( HitLocation, HitNormal, Location + ( -64 * X ), Location, true );
		
	//	if( HitActor != None )
	//	{
	//		MoveTimer = -1.0;
	//		PlayToWaiting( 0.12 );
	//		ChooseAttackState();
	//		return vect( 0, 0, 0 );
	//	}

		if( PointReachable( CheckPoint ) && CanSeeEnemyFrom( CheckPoint ) )
		{
			return CheckPoint;
		}
	}


	function bool SetRetreatPoint()
	{
		local vector X, Y, Z, CheckPoint, HitNormal, HitLocation;
		local actor HitActor;
		local vector Loc1, Loc2, Loc3, Loc4;
		local AICoverController Temp;
		local vector VectorList[ 4 ];
		local int C;
		local AICoverController Testing;

		log( "SetRetreatPoint 1 for "$self );
		GetAxes( Rotation, X,Y,Z );
		log( "SetRetreatPoint 2 for "$self );
		VectorList[ 0 ] = Location + ( ( CollisionRadius ) * Y );
		VectorList[ 1 ] = Location - ( ( CollisionRadius ) * Y );
		VectorList[ 2 ] = Location + ( ( CollisionHeight ) * Z );
		VectorList[ 3 ] = Location - ( ( CollisionHeight ) * Z );

		for( C = 0; C <= 3; C++ )
		{
			HitActor = Trace( HitLocation, HitNormal, VectorList[ C ] + ( -72 * X ), VectorList[ C ], true );
			if( HitActor != None )
			{
		log( "SetRetreatPoint 3 for "$self );
				StopMoving();
				PlayToWaiting( 0.12 );
				//ChooseAttackState();
				return false;
			}
		}
	
//		GetAxes( rotator( normal(  Enemy.Location - Location ) ), X, Y, Z );

		CheckPoint = ( Location + ( -24 * X ) );

	//	HitActor = Trace( HitLocation, HitNormal, Location + ( -64 * X ), Location, true );
		
	//	if( HitActor != None )
	//	{
	//		MoveTimer = -1.0;
	//		PlayToWaiting( 0.12 );
	//		ChooseAttackState();
	//		return vect( 0, 0, 0 );
	//	}

		if( PointReachable( CheckPoint ) && CanSeeEnemyFrom( CheckPoint ) )
		{
		log( "SetRetreatPoint 4 for "$self );
		log(" New Destination: "$CheckPoint );
		log( "Enemy Location: "$Enemy.Location );
			RetreatLocation = CheckPoint;
			return true;
		}
	}
Reload:
	if( RegularWeapon() )
	{
		Disable( 'AnimEnd' );
		StopFiring();
		PlayTopAnim(dnWeapon(Weapon).ReloadStartAnim.AnimSeq,,0.1);
		dnWeapon( Weapon ).AmmoType.AddAmmo( 9999, 0 );
		FinishAnim( 1 );
		if( Pistol( Weapon ) != None )
			Weapon.AmmoLoaded = 8;
		else
			Weapon.AmmoLoaded = 50;
		bReloading = false;
		Goto( 'Begin' );
	}

DoneTurn:
	log( self$" Retreat DoneTurn Label" );
	PlayBottomAnim( 'None' );
	PlayAllAnim( 'A_IdleStandActive',, 0.1, true );
	bIsTurning = false;

Begin:
	log( self$" Retreat begin label 1" );
	Enable( 'AnimEnd' );
	if( GetPostureState() == PS_Crouching )
	{
	log( self$" Retreat begin label 2" );
		bIntoCrouch = true;
		PlayToStanding();
		FinishAnim( 2 );
		PlayBottomAnim( 'None' );
		bIntoCrouch = false;
		SetPostureState( PS_Standing );
		PlayToWaiting( 0.35 );
		PlayWeaponIdle();
		Sleep( 0.15 );
	}
		log( self$" Retreat begin label 3" );
	if( !IsAnimating( 0 ) )
		PlayToWaiting( 0.12 );
	log( self$" Retreat begin label 4" );
	Enable( 'AnimEnd' );
	RotationRate.Yaw = 80000;
	DesiredRotation = rotator( Enemy.Location - Location );
	dnWeapon( Weapon ).FireAnim.AnimSeq = '';
	log( self$" Retreat begin label 5" );
Turning:
	log( self$" Retreat begin label 6" );
	if( !IsAnimating( 1 ) )
	{
		StopFiring();	
		PlayWeaponIdle( 0.12 );
		Sleep( 1.0 );
	}
	if( MustTurn( Enemy ) )
	{
		Sleep( 0.2 * FRand() );
		bIsTurning = true;
		Sleep( 0.1 );
		Goto( 'Begin' );
	}
	bReadyToAttack = true;
	log( self$" Retreat begin label 7" );
BeginRetreat:
	//FireController = Spawn( class'AIFireController', self );
	//FireController.Target = self;
	if( bFire == 0 )
		SetAutoFireOn();
	//// // // // // log( FIRECONTROLLER: "$FireController );
PostBegin:
	//dnWeapon( Weapon ).FireAnim.AnimTween = 0.24;
	//PlayTopAnim( 'T_M16Fire',, 0.1, false, false, true );
	//PlayRangedAttack();
	//PlayOwnedSound(sound'dnsWeapn.m16.GunFire053', SLOT_Interface, SoundDampening*0.4 );
	//Weapon.ClientSideEffects( false );
	//Sleep( 0.1 + ( FRand() * 0.1 ) );
	//bRotateToEnemy = true;
	if( bRetreatAtStartup )
	{
		Goto( 'RetreatToPoint' );
	}
		log( self$" Retreat begin label 8" );
	//estination = GetRetreatPoint();
	if( !SetRetreatPoint() )
	//if( Destination == vect( 0, 0, 0 ) || ( VSize( Destination - Enemy.Location ) < VSize( Location - Enemy.Location ) ) )
	{
	log( self$" Retreat begin label 9" );
		FinishAnim( 2 );
		PlayToWaiting( 0.12 );
		StopMoving();
		ChooseAttackState();
	}
	else
	{
	log( self$" Retreat begin label 10" );
		//Sleep( 1.0 );
		//TurnTo( Enemy.Location );
		//Goto( 'PostBegin' );

	if( GetSequence( 2 ) != 'A_SneakWalkBack' ) 
		{
			PlayAllAnim( 'A_SneakWalkBack',, 0.12, true );
		}
	//	StrafeTo( RetreatLocation, Enemy.Location, 0.16 );
		RotationRate.Yaw = 0;
		MoveTo( RetreatLocation, 0.16 );
		RotationRate.Yaw = Default.RotationRate.Yaw;

//		TurnTo( Enemy.Location );
		log( self$" Retreat begin label 11" );
		if( VSize( Location - Enemy.Location ) > 300 )
		{
		log( self$" Retreat begin label 12" );

			if( GetSequence( 0 ) == 'A_SneakWalkBack' ) 
			{
		log( self$" Retreat begin label 13" );

				FinishAnim( 0 );
				PlayToWaiting( 0.12 );
			}
		log( self$" Retreat begin label 14" );

			FireController.Destroy();
			log( self$"ChooseAttackState From retreat 3" );
			ChooseAttackState();
		}
		else
		{
					log( self$" Retreat begin label 15" );

			Goto( 'PostBegin' );
		}
	}

RetreatToPoint:
	//SetPlayerEnemy();
	RetreatDestination = FindActorTagged(class'Actor',RetreatTag);
	// // // log( self$" RETREAT DESTINATION IS "$RetreatDestination );
	
	if( !FindBestPathToward( RetreatDestination, true ) )
	{
		// // // // // log( Forced retreat failed." );
		// // // // // log( Going to Idling 2" );
		GotoState( 'Idling' );
	}
	else
	{
		// // // log( self$" Found best path toward "$RetreatDestination );

		if( GetSequence( 2 ) != 'A_SneakWalkBack' ) 
		{
			PlayAllAnim( 'A_SneakWalkBack',, 0.12, true );
		}
		bRotateToEnemy = true;
		//StrafeTo( Destination, Enemy.Location, 0.16 );
		MoveToward( MoveTarget, 0.16 );
		bRotateToEnemy = false;
		if( VSize( Location - RetreatDestination.Location ) > 48 )
			Goto( 'RetreatToPoint' );
		else
		{
			bRetreatAtStartup = false;
			// // // // // log( Going to Idling 3" );
			GotoState( 'Idling' );
		}
	}
}

function CampingTimer()
{
	bCamping = false;
	CurrentCoverSpot.bOccupied = false;
	CurrentCoverSpot.OccupiedBy = none;
	CurrentCoverSpot = None;
	// // // log( Hunting 1a" );
	GotoState( 'Hunting' );
}

function EndContinuedFire()
{
	if( Enemy.IsA( 'AITempTarget' ) )
		Enemy.Destroy();

	// log( self$" SETTING ENEMY P" );

	Enemy = TempEnemy;
	Target = Enemy;
	TempEnemy = None;
	bContinueFireDisabled = true;
	SetCallBackTimer( 5.5, false, 'EnableContinuedFire' );
	ChooseAttackState();
}

function EnableContinuedFire()
{
	bContinueFireDisabled = false;
}

function EnemyNotVisible()
{
	local Name CurrentState;

	if( bRetreatAtStartup )
		return;

	if( TempEnemy != None )
		return;
	CurrentState = GetStateName();

	if( !bContinueFireDisabled && FRand() < 0.23 && ( CurrentState == 'AttackPistol' || CurrentState == 'AttackM16' ) && TempEnemy == None )
	{
		TempEnemy = Enemy;
		Enemy = Spawn( class'AITempTarget',,, LastSeenPos + vect( 0, 0, 32 ) );
		//Enemy.bhidden = false;
		//GotoState( 'AttackM16' );
		Disable( 'EnemyNotVisible' );
		Enable( 'SeePlayer' );
		SetCallbackTimer( 1.5, false, 'EndContinuedFire' );
		bContinueFireDisabled = true;
		ChooseAttackState();
		return;
	}

	if( MyCombatController != None )
	{
		MyCombatController.UnsetHunting( self );

		if( CurrentCoverSpot != None && CurrentCoverSpot.bIgnoreCantSee )
		{
			//// // // // // log( Disabling" );
			if( CoverController == None )
			{
				//CoverController = Spawn( class'AICoverController', self );
				if( !bCamping && CurrentCoverSpot.MaxCampTime > 0.0 )
				{
				//	CoverController.MaxCampTime = CurrentCoverSpot.MaxCampTime;
				//CoverController.Target = self;
// SetcallBackTimer( time, true/false, function name )
// EndCallBackTimer()
					// // // // log( SETTING "$self$" to CAMPING" );
					SetCallBackTimer( CurrentCoverSpot.MaxCampTime, false, 'CampingTimer' );
					bCamping = true;
				}
			}
			Disable( 'EnemyNotVisible' );
			return;
		}
					else if( MyCombatController.SetHunting( self ) )
		{
			GotoState( 'Hunting' );
		}
	}
	//else
	//if( Weapon.GottaReload() )
	//{
	//	GotoState( 'Reloading' );
	//}
	else if( /*GetPostureState() != PS_Crouching && */ !bRolling && !Weapon.GottaReload() && !bIntoCrouch )
	{
		 // // log( self$" Going to Hunting 4" );
		GotoState( 'Hunting' );
	}
}
/*
state CrouchAttack
{
	function SeePlayer( actor Seen )
	{
		GotoState( 'CrouchAttack', 'Firing' );
	}

	function BeginState()
	{
		SetCollisionSize( CollisionRadius, 16 );	
		SetPhysics( PHYS_Falling );
		bHunting = true;
	}

	function EndState()
	{
		PlayAllAnim( 'A_CrchIdle',, 0.1, true );
	}

	function PickDest()
	{
		local ProtonMonitorPoint PMP;

		local int i;
		local bool bSuccess;

		if( CurrentPoint != None )
		{
			for( i = 0; i <= 15; i++ )
			{
				if( CurrentPoint.AccessiblePoints[ i ] != None && CurrentPoint.AccessiblePoints[ i ] != CurrentPoint )
				{
					if( CanSeeEnemyFrom( CurrentPoint.AccessiblePoints[ i ].Location ) && LineOfSightTo( CurrentPoint.AccessiblePoints[ i ] ) )
					{
						CurrentPoint = ProtonMonitorPoint( CurrentPoint.AccessiblePoints[ i ] );
						Destination = CurrentPoint.Location;
						return;
					}
				}
			}
			CurrentPoint = ProtonMonitorPoint( CurrentPoint.GetRandomReachablePoint() );
			Destination = CurrentPoint.Location;
		}
		else
		{
		foreach allactors( class'ProtonMonitorPoint', PMP )
		{
			if( Destination != PMP.Location && PMP != CurrentPoint && CanSeeEnemyFrom( PMP.Location ) )
			{
				CurrentPoint = PMP;
				Destination = PMP.Location;
				break;
			}
		}
		}
	}

	function bool CanSeeEnemyFrom( vector aLocation, optional float NewEyeHeight, optional bool bUseNewEyeHeight )
	{
		local actor HitActor;
		local vector HitNormal, HitLocation, HeightAdjust;

		if( bUseNewEyeHeight )
		{
			HeightAdjust.Z = NewEyeHeight;
		}
		else
			HeightAdjust.Z = BaseEyeHeight;
		HitActor = Trace( HitLocation, HitNormal, Enemy.Location, aLocation + HeightAdjust, true );
		if( HitActor == Enemy )
		{
			return true;
		}
		return false;
	}

	function EnemyNotVisible()
	{
		GotoState( 'CrouchAttack', 'Begin' );
	}
Firing:
	Enable( 'EnemyNotVisible' );
	// log( self$" ==== PLAYING KNEEL IDLE 7" );
	PlayBottomAnim( 'B_KneelIdle',, 0.13, true );
	// // // log( self$"Disable SeePlayer 17 for "$self );
	Disable( 'SeePlayer' );
	Enable( 'EnemyNotVisible' );
	TurnTo( Enemy.Location );
	if( Weapon.GottaReload() )
	{
		NextState = GetStateName();
		NextLabel = 'AfterFire';
		GotoState( 'Reloading' );
	}
	dnWeapon( Weapon ).FireAnim.AnimTween = 0.24;
	PlayRangedAttack();
	PlayOwnedSound(sound'dnsWeapn.m16.GunFire053', SLOT_Interface, SoundDampening*0.4 );
	Weapon.ClientSideEffects( false );
	PlayTopAnim( 'T_M16Fire', 6.0, 0.1, false, false, true );
	Sleep( 0.35 + ( FRand() * 0.1 ) );
	Goto( 'Firing' );

Begin:
	Disable( 'EnemyNotVisible' );
	PlayToCrouch();
	SetPostureState( PS_Crouching );
	FinishAnim( 2 );
	PlayBottomAnim( 'None' );
	PlayAllAnim( 'A_CrchWalk',, 0.12, true );
	MoveTo( CurrentCrouchNode.Location, 0.12 );
Moving:
	PlayAllAnim( 'A_CrchWalk',, 0.12, true );
	PickDest();
	if( Destination != vect( 0, 0, 0 ) )
	{
		MoveTo( Destination, 0.12  );
	}
	StopMoving();
	// log( self$" ==== PLAYING KNEEL IDLE 8" );
	PlayBottomAnim( 'B_KneelIdle',, 0.13, true );
	Sleep( 0.5 );
	Goto( 'MOving' );
}
*/
/*
Begin:
	if( CurrentCrouchNode != None )
	{
	//	PlayToRunning();
	//	MoveTo( CurrentCrouchNode.Location );
		StopMoving();
		//// //// // // // // log( CurrentCrouchNode: "$CurrentCrouchNode );
	
		PlayBottomAnim( 'B_KneelIdle',, 0.13, true );
	}
Moving:
	//ChangeCollisionHeightToCrouching();
	SetCollisionSize( 4, 4 );
	SetPhysics( PHYS_FAlling );
	WaitForLanding();
	PlayToCrouch();
	FinishAnim( 2 );
	PlayBottomAnim( 'None' );
	PlayAllAnim( 'A_CrchWalk',, 0.12, true );
	if( !FindBestPathToward( Enemy, true ) )
	{
		//// //// // // // // log( CANNOT FIND PATH :"$CollisionHeight );
		Sleep( 0.25 );
	}	
	else
	{
		//// //// // // // // log( FOUND PATH TO "$Enemy );
		//// //// // // // // log( FIND PATH SUCCESSFUL" );
		MoveTo( Destination, 0.12 );
	}
	Goto( 'Moving' );
}
*/

state DodgeSideStep
{
	ignores EnemyNotVisible, SeePlayer;

	function HitWall( vector HitNormal, actor Wall )
	{
		StopMoving();
		PlayToWaiting( 0.12 );
		ChooseAttackState();
	}

	function BeginState()
	{
		MinHitWall = 400;
		if( Enemy == None && ( bStrafeLeftOnSpawn || bStrafeRightOnSpawn ) )
			ForceEnemy();
	}

	function ForceEnemy()
	{
		local PlayerPawn P;

		foreach allactors( class'PlayerPawn', P )
		{
			// log( self$" SETTING ENEMY L" );

			Enemy = P;
			HeadTrackingActor = P;
		}
	}

	function bool SetDodgeFireDestination()
	{
		local vector X, Y, Z, HitLocation, HitNormal;
		local bool bLeft;
		local Actor HitActor;

		GetAxes( Rotation, X, Y, Z );
		DodgeLeft = 0;
		DodgeRight = 0;

		if( bStrafeLeftOnSpawn )
		{
			Y *= -1;
			Destination = Location + Y * 75;
			Dodgeleft = 1;
			return true;
		}
		else if( bStrafeRightOnSpawn )
		{
			Destination = Location + Y * 75;
			DodgeRight = 1;
			return true;
		}
		// Pick a direction to try to dodge.
		if( FRand() < 0.5 )
		{
			bLeft = true;
			Y *= -1;
		}
		// Check for obstructions, if there are any then try the opposite direction.
		HitActor = Trace( HitLocation, HitNormal, Location + Y * ( 136 ), Location, true );

		if( HitActor != None )
		{
			Y *= -1;
			bLeft = !bLeft;
			HitActor = Trace( HitLocation, HitNormal, Location + Y * ( 136 ), Location, true );
			if( HitActor != None )
				return false;
		}
	
		Destination = Location + Y * ( 75 );
		if( !PointReachable( Destination ) )
			return false;
		
		if( bLeft )
		{
//			PlayBottomAnim( 'B_DodgeLeftA', 1.35, 0.2, false );
//			PlayWeaponIdle();
			DodgeLeft = 1;
		}
		else
		{
//			PlayBottomAnim( 'B_DodgeRightA', 1.5, 0.2, false );
//			PlayWeaponIdle();
			DodgeRight = 1;
		}
		return true;
	}
	
	function EndState()
	{
		MinHitWall = 400;
		SetAutoFireOff();
		if( CurrentCoverSpot != None )
		{
			if( VSize( CurrentCoverSpot.Location - Location ) > 128 )
			{
				CurrentCoverSpot.bOccupied = false;
				CurrentCoverSpot.OccupiedBy = none;
				CurrentCoverSpot = None;
			}
		}
	}

Begin:
	Enable( 'AnimEnd' );
	
	if( GetSequence( 2 ) == 'B_KneelIdle' || GetPostureState() == PS_Crouching )
	{
		bIntoCrouch = true;
		PlayToStanding();
		FinishAnim( 2 );
		PlayBottomAnim( 'None' );
		bIntoCrouch = false;
		SetPostureState( PS_Standing );
		PlayToWaiting( 0.35 );
		Sleep( 0.15 );
		TurnToward( Enemy );
	}

	DesiredRotation.Yaw = Rotation.Yaw;
	RotationRate.Yaw = 0;
	
	if( SetDodgeFireDestination() )
	{
		//HeadTrackingActor = None;
		bCanTorsoTrack = true;
		PlayWeaponIdle();
		//// // // // // log( DODGING" );
		if( DodgeRight == 1 )
			PlayBottomAnim( 'B_DodgeRightA', 1.35, 0.2, false );
		else
			PlayBottomAnim( 'B_DodgeLeftA', 1.5, 0.2, false );
		Sleep( 0.1 );
		//FireController = Spawn( class'AIFireController', self );
		//FireController.Target = self;
		//// // // // // log( STRAFING" );
		if( bFire == 0 && !bShieldUser )
			SetAutoFireOn();
		StrafeTo( Destination, ( Location + vector( Rotation ) * 32 ), 0.5 );
		FinishAnim( 2 );
		PlayBottomAnim( 'None' );

		//// // // // // log( DONE STRAFING" );
		//FireController.Destroy();
		StopMoving();
		PlayToWaiting( 0.14 );
		SetAutoFireOff();
		PlayWeaponIdle();
		HeadTrackingActor = Enemy;
		bRotateToDesired = true;
		Sleep( 0.25 );
	}
	RotationRate.Yaw = Default.RotationRate.Yaw;
	ChooseAttackState( 'AfterFire' );
}

state DodgeRoll
{
	ignores EnemyNotVisible, SeePlayer;

	function ForceRollDodgeDestination()
	{
		local vector X, Y, Z, HitLocation, HitNormal;
		local bool bLeft;
		local Actor HitActor;

		GetAxes( Rotation, X, Y, Z );

		if( bRollLeftOnSpawn )
			Y *= -1;
		Destination = Location + Y * ( 190 );
	}

	function bool SetRollDodgeDestination()
	{
		local vector X, Y, Z, HitLocation, HitNormal;
		local bool bLeft;
		local Actor HitActor;

		GetAxes( Rotation, X, Y, Z );
	
		DodgeLeft = 0;
		DodgeRight = 0;

		if( bRollLeftOnSpawn )
		{
			Y *= -1;
			Destination = Location + Y * 190;
			DodgeLeft = 1;
			return true;
		}
		else if( bRollRightOnSpawn )
		{
			Destination = Location + Y * 190;
			DodgeRight = 1;
			return true;
		}

		// Pick a direction to try to dodge.
		if( FRand() < 0.5 )
		{
			bLeft = true;
			Y *= -1;
		}

		// Check for obstructions, if there are any then try the opposite direction.
		HitActor = Trace( HitLocation, HitNormal, Location + Y * ( 200 ), Location, true );

		if( HitActor != None )
		{
			Y *= -1;
			bLeft = !bLeft;
			HitActor = Trace( HitLocation, HitNormal, Location + Y * ( 200 ), Location, true );
			if( HitActor != None )
			{
				MoveTimer = -1.0;
				return false;
			}
		}
	
		Destination = Location + Y * ( 190 );
		if( !CanSeeEnemyFrom( Location + Y * 190 ) )
		{
			MoveTimer = -1.0;
			return false;
		}

		if( !PointReachable( Destination ) || !CanSeeEnemyFrom( Destination ) )
			return false;

		PlayTopAnim( 'None' );
	
		if( bLeft )
			DodgeLeft = 1;
		else
			DodgeRight = 1;
		return true;
	}	

	function BeginState()
	{
		if( Enemy == None && ( bRollLeftOnSpawn || bRollRightOnSpawn ) )
			ForceEnemy();
	}

	function ForceEnemy()
	{
		local PlayerPawn P;

		foreach allactors( class'PlayerPawn', P )
		{
			// log( self$" SETTING ENEMY P" );

			Enemy = P;
			HeadTrackingActor = P;
		}
	}

Begin:
	StopFiring();
	//// // // // // log( Dodge Roll state entered. AI Fire Controller is : "$FireController );
	if( GetSequence( 2 ) == 'B_KneelIdle' || GetPostureState() == PS_Crouching )
	{
		bIntoCrouch = true;
		PlayToStanding();
		FinishAnim( 2 );
		PlayBottomAnim( 'None' );
		bIntoCrouch = false;
		SetPostureState( PS_Standing );
		PlayToWaiting( 0.35 );
		Sleep( 0.15 );
		TurnToward( Enemy );
	}
	
	if( SetRollDodgeDestination() )
	{
		// log( self$" at DodgeRoll state at "$Level.TimeSeconds );
		RotationRate.Yaw = 0;
		bRollLeftOnSpawn = false;
		bRollRightOnSpawn = false;
		PlayTopAnim( 'None' );
		if( DodgeRight == 1 )
			PlayAllAnim( 'A_RollRightA',, 0.17, false );
		else
			PlayAllAnim( 'A_RollLeftA',, 0.17, false );
		bRolling = true;
		HeadTrackingActor = None;
		Disable( 'AnimEnd' );
		bRotateToDesired = false;
		StopFiring();
		Sleep( 0.14 );
		StrafeTo( Destination, Enemy.Location, 1.0 );
		FinishAnim( 0 );
		PlayWeaponIdle();	
		bCrouchShiftingDisabled = true;
		SetCrouchDisabled();
		SetPostureState( PS_Crouching );
		// // log( B_KNEEL IDLE 16" );
		PlayBottomAnim( 'B_KneelIdle',, 0.13, true );
		StopMoving();
		Enable( 'AnimEnd' );
		HeadTrackingActor = Enemy;
		bRotateToDesired = true;
		Sleep( 0.25 );
		bRolling = false;
		RotationRate.Yaw = Default.RotationRate.Yaw;
	}
	ChooseAttackState( 'AfterFire' );
}

/*-----------------------------------------------------------------------------
	Tentacle attack state: Primary melee attack state for snatched humans...
-----------------------------------------------------------------------------*/
state TentacleThrust
{
	ignores SeePlayer;

	function TentAbort()
	{
		local float Dist;

		if( VSize( Location - Enemy.Location ) > 112 )
		{
			PlayToWaiting( 0.12 );
			MyMOuthTentacle.Destroy();
			MyMouthTentacle = None;
			GotoState( 'TentacleThrust', 'Ending' );
		}
	}

	function bool EvalLipSync()
	{
		return false;
	}

	function bool EvalBlink()
	{
		return false;
	}

	
/*function TakeDamage(int Damage, Pawn InstigatedBy, vector HitLocation,
					vector Momentum, class<DamageType> DamageType)
{
	local EPawnBodyPart BodyPart;
	local bool bWasHealthy;
	
	Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);

	BodyPart = GetPartForBone( DamageBone );

	if( IsInState( 'TentacleThrust' ) )
	{
		PlayDamage( BodyPart, bShortPains, true, Damage );
	}
	else
	{
		PlayDamage(BodyPart, bShortPains,, Damage );
	}

	if( !bSnatched && !bAggressiveToPlayer )
	{
		GotoState( 'Cowering' );
	}

}
*/
	function BeginState()
	{
		local MeshInstance Minst;
		local int Bone;
		local Vector V, X;

		local Pawn P;

		OldEnemy = Enemy;
		SetEnemy( None );
		bFire = 0;
	}

Begin:
	StopMoving();
	StopFiring();
	if( GetPostureState() == PS_Crouching )
	{
		PlayWeaponIdle( 0.12 );
		bIntoCrouch = true;
		PlayToStanding();
		FinishAnim( 2 );
		PlayBottomAnim( 'None' );
		bIntoCrouch = false;
		SetPostureState( PS_Standing );
		PlayToWaiting( 0.35 );
		Sleep( 0.15 );
	}

	if( MyMouthTentacle != None )
		MyMouthTentacle.Destroy();

	if( GetSequence( 0 ) != 'A_KnockDownF_All' )
	{
		if( MyMouthTentacle == None )
		{
			if( FRand() < 0.4 )
			{	
				TentacleAttackType = TENTACLE_Thrust;
				MyMouthTentacle = CreateTentacle( TentacleOffsets.MouthOffset, TentacleOffsets.MouthRotation, 'Lip_U' );
			}
			else
			{
				TentacleAttackType = TENTACLE_Slash;
				MyMouthTentacle = CreateTentacle( TentacleOffsets.MouthOffset, TentacleOffsets.MouthRotation, 'Lip_U' );
			}
		}
		if( MyShoulderTentacle1 == None && FRand() < 0.25 )
		{
			MyShoulderTentacle1 = CreateTentacle( TentacleOffsets.RightShoulderOffset, TentacleOffsets.RightShoulderRotation, 'Chest' );
			MyShoulderTentacle1.GotoState( 'ShoulderTentacle' );
		}
		if( MyShoulderTentacle2 == None && FRand() < 0.25 )
		{
			MyShoulderTentacle2 = CreateTentacle( TentacleOffsets.LeftShoulderOffset, TentacleOffsets.LeftShoulderRotation, 'Chest' );
			MyShoulderTentacle2.GotoState( 'ShoulderTentacle' );
		}

		HeadTrackingActor = OldEnemy;
		HeadTracking.DesiredWeight = 34.0;
		HeadTracking.WeightRate = 24.0;
		TurnTo(OldEnemy.Location);
		PlayToWaiting();
		bFire = 0;
		bAltFire = 0;
		Sleep( 0.1 );
		PlayTopAnim( 'None' );
		PlayBottomAnim( 'none' );
		DesiredRotation = rotator( OldEnemy.Location - Location );
		DesiredRotation.Pitch = 0;

		if( Physics != PHYS_Swimming )
		{
			if( TentacleAttackType == TENTACLE_Thrust ) 
				PlayAllAnim( 'A_Tentacle_Attck3', 1.0, 0.1, false );
			else if( TentacleAttackType == TENTACLE_Slash )
				PlayAllAnim( 'A_TentAttackMSwipeA', 1.0, 0.1, false );
		}

		MyMouthTentacle.bHidden = false;
		if( GetSequence( 0 ) == 'A_Tentacle_Attck3' )
		{
			MyMouthTentacle.bNewAttack = false;
			MyMouthTentacle.GotoState( 'MAttackA' );
		}
		else
		{
			MyMouthTentacle.bNewAttack = true;
			MyMouthTentacle.GotoState( 'MAttackA' );
		}
		if( Physics != PHYS_Swimming )
			FinishAnim( 0 );
		MyMouthTentacle.Destroy();
		MyMouthTentacle = None;
		SetEnemy( OldEnemy );
		PlayToWaiting();
	}
	// TEMPORARY
Ending:
	Sleep( 0.15 );
	// // // log( self$" ChooseAttackState From TentacleThrust 1" );
	ChooseAttackState();
}

/*-----------------------------------------------------------------------------
	Melee combat state: Handles punching and kicking...
-----------------------------------------------------------------------------*/
state MeleeCombat expands Attack
{
	ignores Bump, SeePlayer;

	function PlayMeleeCombatPunch()
	{
		local float Decision;
		local float TweenTime;

		Decision = Rand( 3 );
		HeadTrackingActor = Enemy;

		if( Physics == PHYS_Swimming )
			TweenTime = 0.22;
		else
			TweenTime = 0.1;

		if( bShieldUser )
		{
			PlayTopAnim( 'None' );
			PlayAllAnim( 'A_ShieldBash',, TweenTime, false );
			return;
		}
		
		if( Physics != PHYS_Swimming )
		{
			if( Decision == 0 )
				PlayTopAnim( 'T_Punch1',, TweenTime, false );
			else if( Decision == 1 )
				PlayTopAnim( 'T_Punch2',, TweenTime, false );
			else if( Decision == 2 )
				PlayTopAnim( 'T_Punch4',, TweenTime, false );
			else 
				PlayTopAnim( 'T_Punch1',, TweenTime, false );
		}
		else
			PlayBottomAnim( 'B_SwimKickWade',, 0.22, true );
	}

	function PlayMeleeCombatKick()
	{
		PlayAllAnim( 'A_Kick_Front',, 0.2, false );
	}
	
	function AnimEndEx( int Channel )
	{}

	function bool EnemyWithinRange()
	{
		local float Dist;

		Dist = VSize( Location - Enemy.Location );

		if( Dist < 96 )
			return true;
		
		return false;
	}

Begin:
	TurnToward( Enemy );

Fighting:
	if( !bShieldUser )
		PlayFightIdle();

	//if( EnemyWithinRange() )
	//{	
		if( FRand() < 0.75 && !bArmless )
		{
			PlayMeleeCombatPunch();
			if( bShieldUser )
				FinishAnim( 0 );
			else
				FinishAnim( 1 );
		}
		else if( Physics != PHYS_Swimming )
		{
			PlayMeleeCombatKick();
			FinishAnim( 0 );
		}
		if( !bShieldUser )
		{
			PlayFightIdle();
		}
		Sleep( 0.2 );
		Goto( 'Begin' );
	//}
	//else
	//{
	//	StopMoving();
	//	PlayToWaiting( 0.12 );
	//	PlayWeaponIdle( 0.12 );
	//	Sleep( 0.12 );
	//	ChooseAttackState();	
//	}
}

/*-----------------------------------------------------------------------------
	Snatched effects state: Handles iterations if different snatched effects
							face/body skins until "fully" snatched and small
							tentacles protruding from bodies/faces...
-----------------------------------------------------------------------------*/
state SnatchedEffects
{
	ignores SeePlayer, Bump, EnemyNotVisible, HearNoise;

	function BeginState()
	{
		local MeshDecal a;
		local MeshInstance Minst;
		local int bone;

		bCanTorsoTrack = false;

		if( self.IsA( 'EDFGrunts' ) )
			bUseSnatchedEffects = true;

		if( MyShoulderTentacle2 == None )
		{
			MyShoulderTentacle2 = CreateTentacle( TentacleOffsets.LeftShoulderOffset, TentacleOffsets.LeftShoulderRotation, 'Chest' );
			MyShoulderTentacle2.GotoState( 'ShoulderDamageTentacle' );
		}

		if( MyShoulderTentacle1 == None )
		{
			MyShoulderTentacle1 = CreateTentacle( TentacleOffsets.RightShoulderOffset, TentacleOffsets.RightShoulderRotation, 'Chest' );
			MyShoulderTentacle1.GotoState( 'ShoulderDamageTentacle' );
		}

		if( MiniTentacle1 == None && Mesh != DukeMesh'EDF1' && Mesh != DukeMesh'EDF2' && Mesh != DukeMesh'EDF2Desert' && Mesh != DukeMesh'EDF3' && Mesh != DukeMesh'EDF3Desert' 
			&& Mesh != DukeMesh'EDF6' && Mesh != DukeMesh'EDF6Desert' )
		{
			MiniTentacle1 = Spawn( class'TentacleSmall', self );
			MiniTentacle1.AttachActorToParent( self, true, true );
			MiniTentacle1.MountAngles.Pitch = -20384;
			MiniTentacle1.MountAngles.Yaw = 16384;
			MiniTentacle1.MountOrigin.Y = -0.3;
			MiniTentacle1.MountOrigin.Z = -1.5;
			MiniTentacle1.MountType = MOUNT_MeshBone;
			MiniTentacle1.MountMeshItem = 'Pupil_L';
			MiniTentacle1.bHidden = false;
			Minst = GetMeshInstance();
			Bone = Minst.BoneFindNamed( 'Pupil_L' );
			Spawn( class'dnParticles.dnBloodFX', self,, Minst.MeshToWorldLocation( Minst.BoneGetTranslate( Bone, true, false ) ), Minst.MeshToWorldRotation( Minst.BoneGetRotate( Bone ) ) * -1 );
		}
		if( MiniTentacle2 == None )
		{
			MiniTentacle2 = Spawn( class'TentacleSmall', self );
			MiniTentacle2.AttachActorToParent( self, true, true );
			MiniTentacle2.MountAngles.Pitch = -20384;
			MiniTentacle2.MountAngles.Yaw = 16384;
			MiniTentacle2.MountOrigin.X = 2.000000;
			MiniTentacle2.MountOrigin.Y = 2.000000;
			MiniTentacle2.MountOrigin.Z = -2.000000;
			MiniTentacle2.MountAngles.Pitch = -12384;
			MinITentacle2.MountAngles.Yaw=19384;
			MiniTentacle2.MountType = MOUNT_MeshBone;
			MiniTentacle2.MountMeshItem = 'Neck';
			MiniTentacle2.bHidden = false;
		}
		if( MiniTentacle3 == None )
		{
			MiniTentacle3 = Spawn( class'TentacleSmall', self );
			MiniTentacle3.AttachActorToParent( self, true, true );
			MiniTentacle3.MountAngles.Pitch = -20384;
			MiniTentacle3.MountAngles.Yaw = 16384;
			MiniTentacle3.MountOrigin.X = 2.000000;
			MiniTentacle3.MountOrigin.Y = -2.000000;
			MiniTentacle3.MountOrigin.Z = -2.000000;
			MiniTentacle3.MountAngles.Pitch = -20384;
			MinITentacle3.MountAngles.Yaw=19384;
			MiniTentacle3.MountType = MOUNT_MeshBone;
			MiniTentacle3.MountMeshItem = 'Neck';
			MiniTentacle3.bHidden = false;
		}
		if( MiniTentacle4 == None && Mesh != DukeMesh'EDF1' && Mesh != DukeMesh'EDF1Desert' && Mesh != DukeMesh'EDF2' && Mesh != DukeMesh'EDF2Desert' && Mesh != DukeMesh'EDF3' && Mesh != DukeMesh'EDF3Desert' 
			&& Mesh != DukeMesh'EDF6' && Mesh != DukeMesh'EDF6Desert' )
		{
			MiniTentacle4 = Spawn( class'TentacleSmall', self );
			MiniTentacle4.AttachActorToParent( self, true, true );
			MiniTentacle4.MountAngles.Pitch = -20384;
			MiniTentacle4.MountAngles.Yaw = 16384;
			MiniTentacle4.MountOrigin.Y = 0.300000;
			MiniTentacle4.MountOrigin.Z = -1.500000;
			MiniTentacle4.MountAngles.Pitch = -12384;
			MinITentacle4.MountAngles.Yaw=16384;
			MiniTentacle4.MountType = MOUNT_MeshBone;
			MiniTentacle4.MountMeshItem = 'Pupil_R';
			MiniTentacle4.bHidden = false;
		}
		if( MiniTentacle1 != None )
			MiniTentacle1.GotoState( 'Swinging' );
		if( MiniTentacle2 != None )
			MiniTentacle2.GotoState( 'Swinging' );
		if( MiniTentacle3 != None )
			MiniTentacle3.GotoState( 'Swinging' );
		if( MiniTentacle4 != None )
			MiniTentacle4.GotoState( 'Swinging' );
	}

	function Timer( optional int TimerNum )
	{
	}


Begin:
	StopMoving();
	bSnatched = true;
	SetSnatchedFace( 3 );
	SetSnatchedParts( 3 );
	
	if( bHateWhenSnatched )
	{
		HateTag = 'DukePlayer';
		TriggerHate();
	}
	else if( bSnatchedAtStartup )
		WhatToDoNext( '','' );
	else
		GotoState( NextState );
}

/*-----------------------------------------------------------------------------
	Cover state:			Handles grunts seeking cover.
-----------------------------------------------------------------------------*/
state NewCover
{
	ignores EnemyNotVisible, SeePlayer;

	function NavigationPoint GetClosestEmergencyPoint( optional float MinDistance )
	{
		local NavigationPoint NP, ClosestNP;
		local actor HitActor;
		local vector HitNormal, HitLocation;

		foreach allactors( class'NavigationPoint', NP )
		{
			if( !NP.Taken )
			{
				if( ClosestNP == None )
				{
					if( VSize( Location - NP.Location ) > MinDistance && NavigationPointFree( NP ) )
						ClosestNP = NP;
				}
				else
				{
					if( VSize( NP.Location - Location ) < VSize( ClosestNP.Location - Location ) && NavigationPointFree( NP ) )
					{
						if( VSize( Location - ClosestNP.Location ) > MinDistance )
							ClosestNP = NP;
					}
				}	
			}
		}
		if( ClosestNP != None )
		{
			ClosestNP.Taken = true;
			return ClosestNP;
		}
		else
			return None;
	}

	function SeePlayer( actor SeenPlayer )
	{}

	function BeginState()
	{
		////// // // // // log( --- "$self$" entered NewCover state." );
	}

	function NavigationPoint GetClosestCoverPoint( optional float MinDistance )
	{
		local NavigationPoint NP, ClosestNP;
		local actor HitActor;
		local vector HitNormal, HitLocation;

		foreach allactors( class'NavigationPoint', NP )
		{
			if( !NP.Taken )
			{
				if( NP.bCoverPoint || NP.bDuckPoint )
				{
					if( ClosestNP == None )
					{
						if( VSize( Location - NP.Location ) > MinDistance && NavigationPointFree( NP ) )
							ClosestNP = NP;
					}
					else
					{
						if( VSize( NP.Location - Location ) < VSize( ClosestNP.Location - Location ) && NavigationPointFree( NP ) )
						{
							if( VSize( Location - ClosestNP.Location ) > MinDistance )
								ClosestNP = NP;
						}
					}	
				}
			}
		}
		if( ClosestNP != None )
		{
			ClosestNP.Taken = true;
			return ClosestNP;
		}
		else
			return None;
	}

	function NavigationPoint GetInitialCoverPoint()
	{
		local NavigationPoint NP;
		local Actor HitActor;
		local vector HitNormal, HitLocation;

		foreach allactors( class'NavigationPoint', NP, InitialCoverTag )
		{
			return NP;
		}
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if( Physics == PHYS_Falling )
		{
			return;
		}
		
		if( Wall.IsA( 'Mover' ) && Mover( Wall ).HandleDoor( self ) )
		{
			if( SpecialPause > 0 )
			{
				Acceleration = vect( 0,0,0 );
			}
			//GotoState( 'Patrolling', 'SpecialNavig' );
			return;
		}

		Focus = Destination;
		if( PickWallAdjust() )
		{
						//// // // // // log( Going to NewCover 10" );
			GotoState( 'NewCover', 'AdjustFromWall' );
		}
		else
		{
			MyCoverPoint = none;
			ChooseAttackState();
		}
	}

	function NavigationPoint FindCoverPoint()
	{
		local float MinCosAngle, CosANgle, DistanceBetweenActors;
		local NavigationPoint NP;
		local vector VectorFromNPCToNP, VectorFromNPCToEnemy;
		local float MaxRadiusToConsider;
		local float MinRadiusToConsider;
		local NavigationPoint BestActor;

		MaxRadiusToConsider = 1024;
		MinRadiusToConsider = 96;
		MinCosAngle = 0.1;

		//// // // // // log( Searching for coverpoint." );
		for( NP = Level.NavigationPointList; NP != None; NP = NP.NextNavigationPoint )
		{
			//// // // // // log( Checking: "$NP );

			if( NP.bCoverPoint && NP.ExtraCost <= 200 && !NP.Taken )
			{
				//// log( NP$" passed test 1" );
				DistanceBetweenActors = VSize( NP.Location - Location );

				if( DistanceBetweenActors <= MaxRadiusToConsider && DistanceBetweenActors >= MinRadiusToConsider )
				{
				//// log( NP$" passed test 2" );
					VectorFromNPCToNP = NP.Location - Location;
					VectorFromNPCToEnemy = Enemy.Location - Location;

					if( !NP.Taken && ActorReachable( NP ) )
					{
				//// log( NP$" passed test 3" );
						if( NP.bDuckPoint && NP.bCoverPoint && NP.ExtraCost <= 200 && !NP.Taken && EvaluateDuckPoint( NP.Location ) )
						{	
				//// log( NP$" passed test 4" );
							if( VSize( VectorFromNPCToEnemy ) > 72 )
							{
				//// log( NP$" passed test 5" );
								NP.Taken = true;
								return NP;
							}
						}

						CosAngle = Normal( VectorFromNPCToNP ) dot Normal( VectorFromNPCToEnemy );

						if( CosAngle < MinCosAngle || NP.bDuckPoint )
						{
				//// log( NP$" passed test 6" );
							if( NavigationPointFree( NP ) )
							{
				//// log( NP$" passed test 7" );
								MinCosAngle = CosAngle;
								BestActor = NP;
								BestActor.Taken = true;
							}
						}
					}
				}
			}
		}
		//// // // // // log( FindCoverPoint returning "$BestActor );
		return BestActor;
	}

	function bool NavigationPointFree( navigationPoint NP )
	{
		local actor A;

		foreach NP.radiusactors( class'Actor', A, 72 )
		{
			if( ( A.IsA( 'Pawn' ) && Pawn( A ) != Self ) && !NP.Taken )
			{
				return false;
			}
		}
		return true;
	}

	function NavigationPoint GetCoverPoint()
	{
		local NavigationPoint NP;
		
		foreach radiusactors( class'NavigationPoint', NP, 3000 )
		{
			if( NP != None && !NP.Taken && NP.bCoverPoint )
			{
				if( VSize( NP.Location - Enemy.Location ) > VSize( Enemy.Location - Location ) )
				{
					return NP;
				}
			}
		}
	}

Begin:
	StopFiring();
	StopMoving();
	if( GetPostureState() == PS_Crouching )
	{
		PlayWeaponIdle( 0.12 );
		bIntoCrouch = true;
		PlayToStanding();
		FinishAnim( 2 );
		PlayBottomAnim( 'None' );
		bIntoCrouch = false;
		SetPostureState( PS_Standing );
		PlayToWaiting( 0.35 );
		Sleep( 0.15 );
	}
	else
		PlayToWaiting();

	if( bCoverOnAcquisition )
	{
		bCoverOnAcquisition = false;
		MyCoverPoint = GetClosestCoverPoint( 2 );
	}
	else if( !bUseInitialCoverTag )
		MyCoverPoint = FindCoverPoint();
	else
	{
		MyCoverpoint = GetInitialCoverPoint();
		////// // // log( self$" My initial coverpoint is now: "$MyCoverPoint );
		bUseInitialCoverTag = false;
		if( MyCoverPoint == None )
			ChooseAttackState();
	}

	if( MyCoverPoint == None )
	{
		ChooseAttackState();
	}
	
	else Destination = MyCoverPoint.Location;

Moving:
	if( bAtCoverPoint || bAtDuckPoint )
	{
		bAtCoverPoint = false;
		bAtDuckPoint = false;
		MyCoverPoint.Taken = false;
	}
	if( LineOfSightTo( MyCoverPoint ) && ActorReachable( MyCoverPoint ) )
	{
		PlayToRunning();
		MoveToward( MyCoverPoint, GetRunSpeed() );
		if( VSize( Location - MyCoverPoint.Location ) < MyCoverPoint.OffsetDistance )
		{
			StopMoving();
			PlayToWaiting();
			TurnToward( Enemy );
			Sleep( FRand() );
			Goto( 'CoverReached' );
		}
	}
	else
	{
		if( MyCoverPoint == None )
		{
			ChooseAttackState();
		}
		if( !FindBestPathToward( MyCoverPoint, true ) )
				ChooseAttackState();
		else
		{
			PlayToRunning();
			MoveTo( Destination, GetRunSpeed() );
			if( VSize( Location - MyCoverPoint.Location ) < MyCoverPoint.OffsetDistance )
			{
				StopMoving();
				PlayToWaiting();
				Sleep( FRand() );
				Goto( 'CoverReached' );
			}
			else
				Goto( 'Moving' );
		}
	}
	Goto( 'Moving' );

SpecialNavig:
	NotifyMovementStateChange( MS_Running, MS_Waiting );
	if (MoveTarget == None)
		MoveTo(Destination, GetRunSpeed() );
	else
		MoveToward(MoveTarget, GetRunSpeed() );
	Goto('Moving');

AdjustFromWall:
	PlayToRunning();
	MoveTo( Destination, GetRunSpeed() );
	Destination = Focus; 
	if( MoveTarget != None )
		Goto( 'SpecialNavig' );
	else
		Goto('Moving');

CoverReached:
	if( myCoverPoint.bSnipePoint && bSniper )
		GotoState( 'Sniping' );
	else if( myCoverPoint.bDuckPoint )
	{
		bAtDuckPoint = true;
	}
	else
		bAtCoverPoint = true;

	TurnToward( Enemy );

	if( !bSteelSkin )
		SpeechCoordinator.RequestSound( self, 'CoverPoint' );

	ChooseAttackState();
}

/*-----------------------------------------------------------------------------
	WaitingForEnemy State. 
-----------------------------------------------------------------------------*/
state WaitingForEnemy
{
	ignores EnemyNotVisible;

	function SeePlayer( actor SeenPlayer )
	{
		if( bForcedAttack && Enemy != None )
			return;

		if( bFixedEnemy )
			return;

		if( SeenPlayer == Enemy || ( Enemy == None ) )
		{
			// log( self$" SETTING ENEMY Z" );

			Enemy = SeenPlayer;
			ChooseAttackState();
		}
	}

	function EndState()
	{
		bCanSayPinDownPhrase = true;
		//Disable( 'funct' );
	}

	function BeginState()
	{
		//Enable( 'SawEnemy' );
		Enable( 'SeePlayer' );
		if( Enemy.IsA( 'AIPawn' ) )
		{
			Disable( 'SeeMonster' );
		}
	}

	function SawEnemy()
	{
			// log( self$" SAW ENEMY 2"$Enemy );

		//if( bFixedEnemy )
		// // // log( self$" SawEnemy for "$self$" called" );
		// // // // log( GOING TO ATTACKING 1 "$self );
		log( self$" GOING TO ATTACKING STATE 1" );
		GotoState( 'Attacking' );
	}

HandleCover:
	if( bAtCoverpoint )
	{
		if( PostureState == PS_Crouching && !bFixedPosition && !bAtDuckPoint )
		{
			PlayWeaponIdle( 0.12 );
			bIntoCrouch = true;
			PlayToStanding();
			FinishAnim( 2 );
			PlayBottomAnim( 'None' );
			bIntoCrouch = false;
			SetPostureState( PS_Standing );
			PlayToWaiting( 0.35 );
			Sleep( 0.15 );
		}
		Enable( 'SeePlayer' );
		
EvaluateCoverDist:
	if( PostureState == PS_Standing && MyCoverPoint.bExitOnDistance )
	{
		if( VSize( Location - Enemy.Location ) > MyCoverPoint.ExitDistance )
		{
			bAtDuckPoint = false;
			bAtCoverPoint = false;
				 // // log( self$" Going to Hunting 5" );
			GotoState( 'Hunting' );
		}
	}
	if( PostureState == PS_Standing && MyCoverPoint.bExitWhenClose )
	{
		if( VSize( Location - Enemy.Location ) < 72 )
		{
			bAtCoverPoint = false;
			bAtDuckPoint = false;
				// // log( Setting bCoverOn true 3" );
			bCoverOnAcquisition = true;
			//// // // // // log( Going to NewCover 1" );
			GotoState( 'NewCover' );
		}
	} 
	Sleep( 1.5 );
	Goto( 'EvaluateCoverDist' );
	}
Begin:
	/*if( bSightlessFire )
	{
		if( FRand() < 0.33 && !bSteelSkin && bCanSayPinDownPhrase )
		{
			SpeechCoordinator.RequestSound( self, 'PinDownFire' );
			bCanSayPinDownPhrase = false;
		}

		bReadyToAttack = true;
		bCanFire = true;
		bFire = 1;
		PlayRangedAttack();
		Sleep( FRand() * 0.2 );
		Goto( 'Begin' );
	}*/
	PlayWeaponIdle();
	StopMoving();
	StopFiring();
	if( bAtCoverPoint )
		Goto( 'HandleCover' );
}

function bool PathClear()
{
	local int i;

	return true;
}

function Destroyed()
{
	if( Weapon.IsA( 'Pistol' ) )
		Weapon.ReloadCount = Default.Weapon.ReloadCount;

	if( CurrentCoverSpot != None )
	{
		CurrentCoverSpot.bOccupied = false;
		CurrentCoverSpot.OccupiedBy = None;
	}
	Super.Destroyed();
}

state ControlledCombat
{
	ignores SeePlayer, SeeMonster;

	
	/*
		// // // log( self$" hitwall!" );
		if (PickWallAdjust())
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('ControlledCombat', 'AdjustFromWall');
		}
		else
		{
			PlayToWaiting( 0.12 );
			MoveTimer = -1.0;
		}

	}

	function Bump( actor Other )
	{
		// // // log( self$" bumped! "$Other );
	}
*/
	function bool CanDirectlyReach( actor ReachActor )
	{
	local vector HitLocation,HitNormal;
	local actor HitActor;

	// // // // // log( CanDirectly Reach 1 ReachActor is "$ReachActor );
	HitActor = Trace( HitLocation, HitNormal, ReachActor.Location, Location, true );
	return false;
}
	function AnimEndEx( int Channel )
	{
	}

	function Bump( actor Other )
	{
		log( self$" CONTROLLED COMBAT BUMPED : "$Other );
		StopMoving();
		PlayToWaiting( 0.12 );
		ChooseAttackState();
	}

	function HitWall( vector HitNormal, actor Wall )
	{
		log( self$" HITWALL " );
		StopMoving();
		PlayToWaiting( 0.12 );
		ChooseAttackState();
	}

	function BeginState()
	{
		// // log( self$" entered controlled combat state." );
		
		HeadTrackingActor = None;
		bCanTorsoTrack = false;
	}
Stand:
	bIntoCrouch = true;
	PlayToStanding();
	FinishAnim( 2 );
	PlayBottomAnim( 'None' );
	bIntoCrouch = false;
	SetPostureState( PS_Standing );
	PlayToWaiting( 0.35 );
	Sleep( 0.15 );
	ChooseAttackState();
	
Crouch:
	// // // // // log( Startup state 2 for "$self );
	// // // // log( Crouching called for "$self );
	bIntoCrouch = true;
	SetPostureState( PS_Crouching );
	bCrouchShiftingDisabled = true;
	PlayToCrouch();
	FinishAnim( 2 );
	bIntoCrouch = false;
	SetCrouchDisabled();
		// log( self$" ==== PLAYING KNEEL IDLE 10" );
	PlayBottomAnim( 'B_KneelIdle',, 0.13, true );
	// // // // log( Crouching done for "$self );
	ChooseAttackState();
	
AdjustFromWall:
	//StrafeTo(Destination, Focus); 
	Destination = Focus; 
	StrafeTo(Destination, Focus );
	// log( self$" Going to MoveToPoint A" );
	Goto('MoveToPoint');

MoveToPoint:
	 log( self$" Move To Point label for "$self$" to spot "$CurrentCoverSpot );
	if( !bSteelSkin )
		SpeechCoordinator.RequestSound( self, 'CoverPoint' );

	if( GetPostureState() == PS_Crouching )
	{
		bIntoCrouch = true;
		PlayToStanding();
		FinishAnim( 2 );
		PlayBottomAnim( 'None' );
		bIntoCrouch = false;
		SetPostureState( PS_Standing );
		PlayToWaiting( 0.35 );
		Sleep( 0.15 );
	}

	if( bWaitForOrder )
	{
	    if( Enemy != None )
			TurnToward( Enemy );

		log( self$" bWaitForOrder loop for "$self );
		sleep( 0.5 );
		bWaitForOrder = false;
	}
	  // // log( "Dist Check: "$VSize( CurrentCoverSpot.Location - Location ) );
	// // log( "Line of sight check: "$LineOfSightTo( CurrentCoverSpot ) );
	// // log( "CanReach check: "$CanDirectlyReach( CurrentCoverSpot ) );
	// // log( "Peripheral Vision: "$PeripheralVision );
	if( VSize( CurrentCoverSpot.Location - Location ) > 32 && !ActorReachable( CurrentCoverSpot ) )
	{
		if( !FindBestPathToward( CurrentCoverSpot, true ) )
		{
			PlayToWaiting();
			// // log( "Cannot find a path!" );
			GotoState( 'WaitingForEnemy' );
		}
		else
		{
			PlayToRunning();
			// // log( "Found a path!" );
			 // // log( "Destination: "$Destination );
			// // log( "Location   : "$Location );
			//MoveTo( Destination - 64 * Normal( Location - Destination ), GetRunSpeed() );
			CurrentCoverSpot.bOccupied = true;
			CurrentCoverSpot.OccupiedBy = self;
			MoveTo( Destination, GetRunSpeed() );
		}
	}
else
{ 
	CurrentCoverSpot.bOccupied = true;
	CurrentCoverSpot.OccupiedBy = self;
DirectlyReach:	
	   log( self$" Directly reach label for "$self );
	if( VSize( CurrentCoverSpot.Location - Location ) > 32 )
	{
		 log( self$" MoveToPoint 4 for "$self );
		 // // // // log( Moving to spot via directly reach "$self );
		PlayTopAnim( 'None' );
		PlayToRunning();
		MoveTo( Location - 64 * Normal( Location - CurrentCoverSpot.Location), GetRunSpeed() );
	}
	else if( VSize( CurrentCoverSpot.Location - Location ) <= 32 ) 
	{
		 // // log( MoveToPoint 5 for "$self );
		 // // // // log( Cover point reached, going to CoverReached "$self );
		Goto( 'CoverReached' );
	}
	 // // log( moveToPoint 6 for "$self );
	 // // log( Looping movement, going back to moveToPoint" );
}
// log( self$" Going to moveTopoint B Dist is "$VSize( Location - CurrentCoverSpot.Location ) );	
if( VSize( Location - CurrentCoverSpot.Location ) < 32 )
{
	// // log( Going to CoverReached" );
	Goto( 'CoverReached' );
}
else
{
	// // log( Looping to MoveToPoint" );
	Goto( 'MoveToPoint' );
}

Begin:
	  //// // log( Combat Control state Begin label for "$self );
	 // // // log( bwaitForOrder for "$self$" is "$bWaitForOrder );


//	PlayTopAnim( 'None' );
	// // log( Controlled state begin 1: "$self );
	if( !MyCombatController.bSleeping )
	{
		// // // // log( AICombatController awake, calling CombatDecision" );
		// // log( Controlled state begin 2."$self );

		MyCombatController.CombatDecision( self );
		if( CurrentCoverSpot != None )
		{
			// // log( Controlled state begin 3."$self );

			//// // // // // log( Combat decision failed for "$self$", going back to AttackM16 state." );
			// // // // // log( ChooseAttackState From ControlledCombat 1" );
			ChooseAttackState();
		}
	}
	else
	{
		// // log( Controlled state begin 4."$self );

		//// // // // // log( Aborting to attack state" );
		// BIG HACK FIX ME
		Sleep( 0.25 );
		// // // log( self$" ChooseAttackState From ControlledCombat 2" );
		ChooseAttackState();
	}
	ChooseAttackState();

CoverReached:
	// log( self$" Cover Reached for "$self$" at "$CurrentCoverSpot );
	//if( CoverController == None )
	//{

	if( bGottaReload )
	{
		StopMoving();
		TurnToward( Enemy );
		PlayToWaiting( 0.12 );
		GotoState( 'Reloading' );
	}
	// log( self$" Reached CurrentCoverSpot "$currentCoverSpot$" log maxCampTime is "$CurrentCoverSpot.MaxCampTime );
	if( CurrentCoverSpot.MaxCampTime > 0.0 )
	{
		// // // // log( Setting CampTimer for "$self );
		SetCallBackTimer( CurrentCoverSpot.MaxCampTime, false, 'CampingTimer' );
	//	// // // // log( SETTING bCamping to true for "$self );
		bCamping = true;		// // // log( self$" bCamping set to true for "$self );
	}
	StopMoving();
	PlayToWaiting( 0.12 );

	TurnToward( Enemy );
	if( !bSteelSkin )
		SpeechCoordinator.RequestSound( self, 'CoverReached' );

	// // // log( self$" ChooseAttackState From ControlledCombat 4" );
	ChooseAttackState();
}


state GiveOrder
{
	ignores EnemyNotVisible, SeePlayer, SeeMonster;

	function BeginSTate()
	{
		//// // // // // log( GiveOrder state entered by "$self );
	}

Begin:
	//// // // // // log( GiveOrder 1 for "$self );
	StopMoving();
	bFire = 0;
	Weapon.GotoState( 'Idle' );
	PlayToWaiting( 0.12 );
	//// // // // // log( GiveOrder 2 for "$self );

	HeadTrackingActor = OrderTarget;
//	TurnTo( HeadTrackingActor.Location );
	//// // // // // log( GiveOrder 3 for "$self );
	PlayTopAnim( 'T_HandS_Advance',, 0.12, false, true );
	FinishAnim( 1 );
	//// // // // // log( GiveOrder 4 for "$self );
	Grunt( OrderTarget ).bWaitForOrder = false;
	HeadTrackingActor = Enemy;
	//// // // // // log( GiveOrder 5 for "$self );

	PlayToWaiting( 0.14 );
	PlayWeaponIdle();
	Sleep( 0.12 );
	//// // // // // log( GiveOrder 6 for "$self );
	//GotoState( 'AttackM16' );
	ChooseAttackState();
}

	function CoverSpot GetClosestCoverSpot( optional float MinDistance )
	{
		local CoverSpot NP, ClosestNP;
		local actor HitActor;
		local vector HitNormal, HitLocation;

		foreach allactors( class'CoverSpot', NP )
		{
			//	if( NP.bCoverPoint || NP.bDuckPoint )
			//	{

			if( CoverTag == NP.Tag  )
			{
				if( ClosestNP == None )
				{
					if( VSize( Location - NP.Location ) > MinDistance )
						ClosestNP = NP;
				}
				else
				{
					if( VSize( NP.Location - Location ) < VSize( ClosestNP.Location - Location ) )
					{
						if( VSize( Location - ClosestNP.Location ) > MinDistance )
							ClosestNP = NP;
					}
				}	
			}
		}
		if( ClosestNP != None )
		{
			return ClosestNP;
		}
		else
			return None;
	}

function Died( pawn Killer, class<DamageType> DamageType, vector HitLocation, optional vector Momentum )
{
//	WarnFriendsOnDeath();

	if( MyCombatController != None )
		MyCombatController.UnsetHunting( self );

	if( CurrentCoverSpot != None )
	{
		// log( self$" DIED! Unsetting currentcoverspot: "$CurrentCoverSpot );
		CurrentCoverSpot.bOccupied = false;
		CurrentCoverSpot.OccupiedBy = none;
	}
	Super.Died( Killer, DamageType, HitLocation );
}

function PlayAllAnim(name Sequence, optional float Rate, optional float TweenTime, optional bool bLooping)
{
	// // // broadcastmesssage( self$" PLAY ALL ANIM: "$Sequence );
	// log( self$" PLAY ALL ANIM: "$Sequence );

	GetMeshInstance();
	if (MeshInstance==None)
		return;

	if ((MeshInstance.MeshChannels[0].AnimSequence == Sequence)
	 && ((Sequence=='None') || (IsAnimating(0))))
		return; // already playing
	
	if (Rate == 0.0) Rate = 1.0; // default
	if (TweenTime == 0.0) TweenTime = -1.0; // default

	if (bLooping)
		LoopAnim(Sequence, Rate, TweenTime);
	else
		PlayAnim(Sequence, Rate, TweenTime);
}

function PlayBottomAnim(name Sequence, optional float Rate, optional float TweenTime, optional bool bLooping, optional bool bNoCallAnimEx )
{
	// // // broadcastmesssage( self$" PLAY BOTTOM ANIM: "$Sequence );
	// log( self$" PLAY BOTTOM ANIM: "$Sequence$" STATE: "$GetStateName() );

	GetMeshInstance();

	if (MeshInstance==None)
		return;
	if ((MeshInstance.MeshChannels[2].AnimSequence == Sequence)
	 && ((Sequence=='None') || (IsAnimating(2))))
		return; // already playing

	if (Sequence=='None')
	{
		DesiredBottomAnimBlend = 1.0;
		BottomAnimBlend = 0.0;
		if (TweenTime == 0.0)
			BottomAnimBlendRate = 5.0;
		else
			BottomAnimBlendRate = 0.5 / TweenTime;
		        

		return; // don't actually play the none anim, we want to shut off the channel gradually, the ticking will set it to none later
	}
	else if (MeshInstance.MeshChannels[2].AnimSequence=='None')
	{
		DesiredBottomAnimBlend = 0.0;
		BottomAnimBlend = 1.0;
		if (TweenTime == 0.0)
			BottomAnimBlendRate = 5.0;
		else
			BottomAnimBlendRate = 0.5 / TweenTime;
	}
	else
	{
		BottomAnimBlend = 0.0;
		DesiredBottomAnimBlend = 0.0;
		BottomAnimBlendRate = 1.0;
	}
	
	if (Rate == 0.0) Rate = 1.0; // default
	if (TweenTime == 0.0) TweenTime = -1.0; // default

	if (bLooping)
		LoopAnim(Sequence, Rate, TweenTime, , 2);
	else
		PlayAnim(Sequence, Rate, TweenTime, 2);
}


function PlayTopAnim(name Sequence, optional float Rate, optional float TweenTime, optional bool bLooping, optional bool bNoCallAnimEx, optional bool bCanInterrupt )
{
	// // // broadcastmesssage( self$" PLAY TOP ANIM: "$Sequence );
	// log( self$" PLAY TOP ANIM: "$Sequence );

	GetMeshInstance();
	if (MeshInstance==None)
		return;
	
	if ((MeshInstance.MeshChannels[2].AnimSequence == Sequence)
	 && ((Sequence=='None') || (IsAnimating(2))))

	if ((MeshInstance.MeshChannels[ 1 ].AnimSequence == Sequence) && ((Sequence == 'None') || (IsAnimating( 1 ))) && !bCanInterrupt)
		return; // already playing
	
	if (Sequence=='None')
	{
		if ( bLaissezFaireBlending )
		{
			MeshInstance.MeshChannels[1].AnimSequence	= 'None';
			MeshInstance.MeshChannels[1].AnimBlend		= 1.0;

		}
		else
		{
			DesiredTopAnimBlend = 1.0;
			TopAnimBlend = 0.0;
			if (TweenTime == 0.0)
				TopAnimBlendRate = 5.0;
			else
				TopAnimBlendRate = 0.5 / TweenTime;
        
		}
		return; // don't actually play the none anim, we want to shut off the channel gradually, the ticking will set it to none later
	}
	else if (MeshInstance.MeshChannels[1].AnimSequence=='None')
	{
		DesiredTopAnimBlend = 0.0;
		TopAnimBlend = 1.0;
		if (TweenTime == 0.0)
			TopAnimBlendRate = 5.0;
		else
			TopAnimBlendRate = 0.5 / TweenTime;
	}
	else
	{
		TopAnimBlend = 0.0;
		DesiredTopAnimBlend = 0.0;
		TopAnimBlendRate = 1.0;
	}

	if (Rate == 0.0) Rate = 1.0; // default
	if (TweenTime == 0.0) TweenTime = -1.0; // default

	if (bLooping)
		LoopAnim(Sequence, Rate, TweenTime, , 1);
	else
		PlayAnim(Sequence, Rate, TweenTime, 1);
}

function TransitionCrouch()
{
	NextState = GetStateName();

	GotoState( 'TransitionToCrouch' );
}

state TransitionToCrouch
{
	function BeginState()
	{
		log( self$" entered TransitionToCrouch state" );
		StopMoving();
	}

Begin:
	StopMoving();
	bIntoCrouch = true;
	PlayToCrouch();
	FinishAnim( 2 );
	bIntoCrouch = false;
	SetCrouchDisabled();
	PlayBottomAnim( 'B_KneelIdle',, 0.13, true );
	GotoState( NextState );
}

function float GetRouteLength()
{
	local int i;
	local float TempDist;
	local float AccumulatedDist;
	local Actor LastRouteCache;

	for( i = 0; i <= 15; i++ )
	{
		if( RouteCache[ i ] != None )
		{
			if( LastRouteCache == None )
			{
				TempDist = VSize( RouteCache[ i ].Location - Location );
				AccumulatedDist = TempDist;
				//log( "Dist from "$self$" to point "$RouteCache[i]$" is "$AccumulatedDist );
			}
			else
			{
				AccumulatedDist += VSize( RouteCache[ i ].Location - LastRouteCache.Location );
				//log( "Dist from "$LastRouteCache$" to "$RouteCache[ i ]$" is "$VSize( RouteCache[ i ].Location - LastRouteCache.Location ));
				//log(" Overall Dist is now "$AccumulatedDist );
			}
			LastRouteCache = RouteCache[ i ];
		}
	}
	AccumulatedDist += VSize( LastRouteCache.Location - Destination );
	//log( "== GetRouteLength returning "$AccumulatedDist );
	return AccumulatedDist;
}

/*-----------------------------------------------------------------------------
	Attack state: Pistol 
-----------------------------------------------------------------------------*/
state ShieldAttackPistol extends Attack
{
	function SeePlayer( actor Seen )
	{
		if( TempEnemy != None )
		{
			if( Enemy.IsA( 'AITempTarget' ) )
				Enemy.Destroy();

			// log( self$" ENEMY SETTING D" );
			Enemy = Seen;
			Target = Seen;
			TempEnemy = None;
			Disable( 'SeePlayer' );
			Enable( 'EnemyNotVisible' );
		}
		Super.SeePlayer( Seen );
	}


	function Bump( actor Other )
	{
		if( PlayerPawn( Other ) != None )
		{
			// // log( ** ENCROACHED BY "$Other );
			//MyCombatController.EncroachedGrunt( CurrentCoverSpot, self );
			//Disable( 'Bump' );
			ChooseMeleeAttackState();
		}
	}

	function BeginState()
	{
		PlayToWaiting( 0.12 );
		Super.BeginState();
	}

Begin:
	// log( self$" AttackPistol begin Label 1" );
	
	// // // // log( "Pre Calling PlayToWaiting" );
	if( FRand() < 0.25 && !bSteelSkin && bCanSayAttackPhrase )
	{
		SpeechCoordinator.RequestSound( self, 'RangedAttack' );
		bCanSayAttackPhrase = false;
		SetCallBackTimer( 2.0, false, 'EnableAttackPhrase' );
	}
	if( !MustTurn() )
	{
		PlayToWaiting( 0.12 );
	// // // // log( "Post Calling PlayToWaiting" );
			// // // // log( "PLAY WEAPON IDLE 7" );
		PlayWeaponIdle();
	}
	// log( self$" AttackPistol begin Label 2" );

	if( TempEnemy == None )
		Disable( 'SeePlayer' );
	else
		Enable( 'SeePlayer' );

	Enable( 'AnimEnd' );
	RotationRate.Yaw = 75000;
	DesiredRotation = rotator( HeadTrackingActor.Location - Location );
	dnWeapon( Weapon ).FireAnim.AnimSeq = '';

Turning:
	if( TempEnemy == None )
	{
		Disable( 'SeePlayer' );
		Enable( 'EnemyNotVisible' );
	}
	else
		Enable( 'SeePlayer' );

	if( !IsAnimating( 1 ) )
	{
		StopFiring();	
		if( !IsAnimating( 0 ) )
			PlayToWaiting( 0.12 );
	 // log( "PLAY WEAPON IDLE 8" );
		PlayWeaponIdle( 0.12 );
		Sleep( 1.0 );
	}
	// log( "** MustTurnCheck" );
	DesiredRotation = rotator( HeadTrackingActor.Location - Location );
	if( MustTurn() )
	{
		StopFiring();
	//	Sleep( 0.2 * FRand() );
		bIsTurning = true;
		Sleep( 0.1 );
		Goto( 'Begin' );
	}
	else
		log(" MustTurn is false!" );
	bReadyToAttack = true;
		// log( self$" AttackPistol begin Label 4" );

	if( GetSequence( 1 ) == '' )
	{
			// // // // log( "PLAY WEAPON IDLE 9" );
		PlayWeaponIdle();
		Sleep( 0.5 );
	}

DoneTurn:
		// log( self$" AttackPistol begin Label 5" );

	if( TempEnemy == None )
	{
		Disable( 'SeePlayer' );
		Enable( 'EnemyNotVisible' );
	}
	else
		Enable( 'SeePlayer' );

	StopFiring();
/*	if( !bKneelAtStartup && GetPostureState() == PS_Crouching )
	{
		bIntoCrouch = true;
		broadcastmessage( "PLAYTOSTAND 1" );
		PlayToStanding();
		FinishAnim( 2 );
		bIntoCrouch = false;
		SetPostureState( PS_Standing );

		PlayToWaiting( 0.35 );
		Sleep( 0.15 );
	}*/
	bIsTurning = false;
	Sleep( 0.25 );

Firing:
	// // // log( self$ "Attack pistol firing label for "$self );
		// log( self$" AttackPistol begin Label 6" );
	if( SafeToCrouch() && GetPostureState() != PS_Crouching && !MustTurn( Enemy ) && !bCrouchShiftingDisabled && FRand() < 0.6 )
	{
		TransitionCrouch();
	}
//lse if( GetPostureState() == PS_Crouching )
//
//if( MustTurn( Enemy ) && FRand() < 0.5 )
//	Goto( 'StandUp' );
//
	else if( !bCrouchShiftingDisabled && GetPostureState() == PS_Crouching )
	{
		Goto( 'StandUp' );
	}
	else
	if( !bDodgeSidestepDisabled && FRand() < 0.25 && GetPostureState() != PS_Crouching && !MustTurn( Enemy ) ) //&& VSize( Location - Enemy.Location ) > 256 )
		
	{
		// // log( GOING TO DODGEROLL 3" );
		SetDodgeDisabled();
		GotoState( 'DodgeSideStep' );
	}

	if( Weapon.GottaReload() )
	{
		// Necessary or not?
		//if( CurrentCoverSpot == None && MyCombatController.CheckLastOrderTime( self ) )
		//{
		//	 // // // // log( Going to controlledcombat 4 for "$self );
		//	GotoState( 'ControlledCombat' );
		//}
		//else
		//{
			NextState = GetStateName();
			NextLabel = 'AfterFire';
			GotoState( 'Reloading' );
		//}
	}

	if( TempEnemy == None )
	{
		Disable( 'SeePlayer' );
		Enable( 'EnemyNotVisible' );
	}
	else
		Enable( 'SeePlayer' );

	dnWeapon( Weapon ).FireAnim.AnimTween = 0.24;
			// // // // log( "PLAY WEAPON IDLE 10" );
	PlayWeaponIdle();
	Disable( 'AnimEnd' );
	PlayTopAnim( 'T_ShieldFireIn',, 0.1, true );
	FinishAnim( 1 );
ShieldFireLoop:
	MyShield.bProjTarget = false;
	PlayTopAnim( 'T_ShieldFire',, 0.12, false, false, false );
	PlayRangedAttack();
	Weapon.ClientSideEffects( false );
	StopFiring();
	FinishAnim( 1 );
	MyShield.bProjTarget = true;
	if( FRand() < 0.5 )
	{
		PlayTopAnim( 'T_ShieldOutIdle',, 0.12, true );
		Sleep( 0.1 + ( FRand() * 0.1 ) );
		Goto( 'ShieldFireLoop' );
	}
	PlayTopAnim( 'T_ShieldFireOut',, 0.12, false );

	FinishAnim( 1 );

	PlayWeaponIdle( 0.12 );
	Enable( 'AnimEnd' );
	Sleep( 0.1 + ( FRand() * 0.1 ) );

AfterFire:
	// // // log( self$" Attack pistol AfterFire label for "$self );
	// log( self$" AttackPistol begin Label 7" );

	// Handle crouching.
	PlayToWaiting( 0.12 );

	if( GetPostureState() != PS_Crouching && VSize( Enemy.Location - Location ) < 72 )
		ChooseMeleeAttackState();

	if( FRand() < 0.5 && VSize( Location - Enemy.Location ) < 256 && GetPostureState() != PS_Crouching && CanRetreat() )
	{
		GotoState( 'Retreat' );
	}
	else
	if( MyCombatController != None )
	{
		if( FRand() < 0.75 && MyCombatController.CheckLastOrderTime( self ) )
		{
			// // log( self$" == Going to ControlledCombat state from AttackPistol state." );
			 // // // // log( Going to controlledcombat 3 for "$self );
			GotoState( 'ControlledCombat' );
		}
		else
		{
			//Sleep( 0.12 );
			Goto( 'Begin' );
		}
	}
	
	// Handle standing back up if necessary, else continue fire loop.
	if( GetPostureState() == PS_Crouching )
	{
		if( !MustTurn( Enemy ) )
			Goto( 'Firing' );
		else 
			Goto( 'StandUp' );
	}

	Goto( 'Begin' );
}


DefaultProperties
{
	bIgnorebList=true
  	bAggressiveToPlayer=true
    AggressionDistance=1024
    bSnatched=false
    PreAcquisitionDelay=0.150000
    InactiveStance=A_IdleStandInactive
    ActiveStance=A_IdleStandActive
    bNoHeightMod=true
    HeadTracking=(RotationRate=(Pitch=40000,Yaw=40000),RotationConstraints=(Pitch=6000,Yaw=12000))
    bVisiblySnatched=false
    VisibilityRadius=90000
    bWeaponsActive=true
	MaxCoverDistance=700
    bCanAltFire=true
    bShadowCast=true
	bShadowReceive=true
}