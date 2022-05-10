class EDFSpeechCoordinator extends Info;

#exec OBJ LOAD FILE=..\sounds\a_edf.dfx

var() sound		Acquisition[ 16 ];
var() sound		Hunting[ 16 ];
var() sound		Idling[ 16 ];
var() sound		Pain[ 16 ];
var() sound		PinDownFire[ 16 ];
var() sound		RangedAttack[ 16 ];
var() sound		Retreating[ 16 ];
var() sound		SeeTeamDeath[ 16 ];
var() sound		GrenadeAlert[ 16 ];
var() sound		CoverPoint[ 16 ];
var() sound		KilledDuke[ 16 ];
var() sound		CoverReached[ 16 ];

var sound LastAcquisitionSound;
var sound LastRangedAttackSound;
var sound LastHuntingSound;
var sound LastPainSound;
var sound LastSeeTeamDeathSound;
var sound LastCoverPointSound;
var sound LastKilledDukeSound;
var sound LastPinDownFireSound;
var sound LastCoverReachedSound;
var sound LastIdlingSound;

var bool bOccupied;
var float VoicePitch;

struct SGruntList
{
	var	  Pawn			Grunt;
	var   sound			LastSoundPlayed;
	var	  float			LastSoundTime;
	var   float			VoicePitch;
	var	  float			DefaultVoicePitch;
};

var SGruntList GruntList[ 32 ];
const TimeBetweenSounds = 6;

function PostBeginPlay()
{
//	log( "---- "$self$" has been created." );
}

function bool IsOccupied()
{
	return bOccupied;
}

function AddGrunt( Pawn aGrunt )
{
	local int i;

	for( i = 0; i <= 31; i++ )
	{
		if( GruntList[ i ].Grunt == None )
		{
			//log( "--- "$self$" inserting Grunt "$aGrunt$" to slot "$i );
			GruntList[ i ].Grunt = aGrunt;
			GruntList[ i ].VoicePitch = RandRange( 0.78, 1.0 );
			GruntList[ i ].DefaultVoicePitch = GruntList[ i ].VoicePitch;
			HumanNPC( aGrunt ).SpeechCoordinator = self;
			break;
		}
	}
}

function RemoveGrunt( EDFGrunts aGrunt )
{
	local int i;

	for( i = 0; i <= 31; i++ )
	{
		if( aGrunt == GruntList[ i ].Grunt )
		{
			GruntList[ i ].Grunt			= None;
			GruntList[ i ].LastSoundPlayed	= None;
			GruntList[ i ].LastSoundTime	= 0;
			GruntList[ i ].VoicePitch		= 0;
			break;
		}
	}
}

function int GetGruntIndex( Pawn aGrunt )
{
	local int i;

	for( i = 0; i <= 31; i++ )
	{
		if( aGrunt == GruntList[ i ].Grunt )
		{
			return i;
		}
	}
}

function RequestSound( Pawn aGrunt, name SoundType )
{
	local int i;
	
	if( Level.Game.IsA( 'dnSinglePlayer' ) && dnSinglePlayer( Level.Game ).bGruntSpeechDisabled )
	{
	//	return;
	}
	if( aGrunt.DrawScale < 0.5 )
		GruntList[ GetGruntIndex( aGrunt ) ].VoicePitch = 1.5;
	else
		GruntList[ GetGruntIndex( aGrunt ) ].VoicePitch = GruntList[ GetGruntIndex( aGrunt ) ].DefaultVoicePitch;

	for( i = 0; i <= 31; i++ )
	{
		if( aGrunt == GruntList[ i ].Grunt )
		{
			//log( "Level.TimeSeconds: "$Level.TimeSeconds );
			//log( "LastSoundTime: "$GruntList[ i ].LastSoundTime );

			if( bOccupied || ( SoundType != 'KilledDuke' && SoundType != 'Pain' && SoundType != 'SeeTeamDeath' && ( Level.TimeSeconds - GruntList[ i ].LastSoundTime ) < TimeBetweenSounds ) )
			{
				//log( "RequestSound aborting." );
				return;
			}
			else
			{
				bOccupied = true;

				//log( "SoundType: "$SoundType );
				if( SoundType == 'Hunting' )
				{
					PlayHuntingSound( aGrunt );
				}
				else if( SoundType == 'CoverPoint' )
				{
					PlayCoverPointSound( aGrunt );
				}
				else if( SoundType == 'CoverReached' )
				{
					PlayCoverReachedSound( aGrunt );
				}

				else if( SoundType == 'Pain' )
				{
					PlayPainSound( aGrunt );
				}
				else if( SoundType == 'Acquisition' ) 
				{
					PlayAcquisitionSound( aGrunt );
				}
				else if( SoundType == 'Hunting' )
				{
					PlayHuntingSound( aGrunt );
				}
				else if( SoundType == 'Idling' )
					PlayIdlingSound( aGrunt );

				else if( SoundType == 'RangedAttack' )
				{
					//log( "Playing RangedAttack sound" );
					PlayRangedAttackSound( aGrunt );
				}
				else if( SoundType == 'SeeTeamDeath' )
				{
					PlaySeeTeamDeathSound( aGrunt );
				}
				else if( SoundType == 'KilledDuke' )
				{
					PlayKilledDukeSound( aGrunt );
				}
				else if( SoundType == 'PinDownFire' ) 
				{
					PlayPinDownFireSound( aGrunt );
				}
			}
			break;
		}
	}
	bOccupied = false;
}

function PlayPinDownFireSound( Pawn aGrunt )
{
	local int i;

	for( i = 0; i <= 15; i++ )
	{
		if( PinDownFire[ i ] != None && PinDownFire[ i ] != LastPinDownFireSound  )
		{
//			log( "Playing sound "$PinDownFire[ i ] );
//			log( "Last PinDownFireSound was "$LastPinDownFireSound );
			aGrunt.PlaySound( PinDownFire[ i ], SLOT_Talk, aGrunt.SoundDampening * 0.96, true,, GruntList[ GetGruntIndex( aGrunt ) ].VoicePitch, true ); //, SLOT_None, aGrunt.SoundDampening * 0.95, true,,, true );
			GruntList[ GetGruntIndex( aGrunt ) ].LastSoundPlayed = PinDownFire[ i ];
			GruntList[ GetGruntIndex( aGrunt ) ].LastSoundTime = Level.TimeSeconds;
			LastPinDownFireSound = PinDownFire[ i ];
			break;
		}
	}
}

function PlayIdlingSound( Pawn aGrunt )
{
	local int i;
	local int IdlingCount;

	IdlingCount = GetSoundCount( 'Idling' );
	log( "Idling Count is: "$IdlingCount );
	i = Rand( IdlingCount );
	log( "CHOSE: "$Idling[ i ] );

	if( Idling[ i ] != None )
	{
		aGrunt.PlaySound( Idling[ i ], SLOT_TALK, aGrunt.SoundDampening * 0.99, true,, GruntList[ GetGruntIndex( aGrunt ) ].VoicePitch, true );
		GruntList[ GetGruntIndex( aGrunt ) ].LastSoundPlayed = Idling[ i ];
		GruntList[ GetGruntIndex( aGrunt ) ].LastSoundTime = Level.TimeSeconds;
		LastIdlingSound = Idling[ i ];
	}
}

function PlayKilledDukeSound( Pawn aGrunt )
{
	local int i;
	local int KilledDukeCount;

	KilledDukeCount = GetSoundCount( 'KilledDuke' );

	i = Rand( KilledDukeCount );

	if( KilledDuke[ i ] != None )
	{
		aGrunt.PlaySound( KilledDuke[ i ], SLOT_TALK, aGrunt.SoundDampening * 0.99, true,, GruntList[ GetGruntIndex( aGrunt ) ].VoicePitch, true );
		GruntList[ GetGruntIndex( aGrunt ) ].LastSoundPlayed = KilledDuke[ i ];
		GruntList[ GetGruntIndex( aGrunt ) ].LastSoundTime = Level.TimeSeconds;
		LastKilledDukeSound = KilledDuke[ i ];
	}
}


/*function PlayPainSound( Pawn aGrunt )
{
	local int i;

	//log( "PlayPainSound" );
	for( i = 0; i <= 15; i++ )
	{
		if( Pain[ i ] != None && Pain[ i ] != LastPainSound  )
		{
			//log( "Playing sound "$Pain[ i ] );
			aGrunt.PlaySound( Pain[ i ],, aGrunt.SoundDampening * 0.96, true,,GruntList[ GetGruntIndex( aGrunt ) ].VoicePitch, true ); //, SLOT_None, aGrunt.SoundDampening * 0.95, true,, VoicePitch, true );
			GruntList[ GetGruntIndex( aGrunt ) ].LastSoundPlayed = Pain[ i ];
			GruntList[ GetGruntIndex( aGrunt ) ].LastSoundTime = Level.TimeSeconds;
			LastPainSound = Pain[ i ];
			break;
		}
	}
}*/
	
function int GetSoundCount( name SoundType )
{
	local int i;
	local int Count;

	if( SoundType == 'CoverReached' )
	{
		for( i = 0; i <= 15; i++ )
		{
			if( CoverReached[ i ] != None )
			{
				Count++;
			}
			else
				break;
		}
	}
	else if( SoundType == 'CoverPoint' )
	{
		for( i = 0; i <= 15; i++ )
		{
			if( CoverPoint[ i ] != None )
			{
				Count++;
			}
			else
				break;
		}
	}
	else if( SoundType == 'Pain' )
	{
		for( i = 0; i <= 15; i++ )
		{
			if( Pain[ i ] != None )
			{
				Count++;
			}
			else
				break;
		}
	}
	else if( SoundType == 'Hunting' )
	{
		for( i = 0; i <= 15; i++ )
		{
			log( "Hunting[ "$i$" ] is "$Hunting[ i ] );
			if( Hunting[ i ] != None )
			{
				Count++;
			}
			else
				break;
		}
	}
	else if( SoundType == 'SeeTeamDeath' )
	{
		for( i = 0; i <= 15; i++ )
		{
			if( SeeTeamDeath[ i ] != None )
			{
				Count++;
			}
			else
				break;
		}
	}
	else if( SoundType == 'Idling' )
	{
		for( i = 0; i <= 15; i++ )
		{
			if( Idling[ i ] != None )
			{
				Count++;
			}
			else
				break;
		}
	}
	else if( SoundType == 'KilledDuke' )
	{
		for( i = 0; i <= 15; i++ )
		{
			if( KilledDuke[ i ] != None )
			{
				Count++;
			}
			else
				break;
		}
	}
	else if( SoundType == 'Acquisition' )
	{
		for( i = 0; i <= 15; i++ )
		{
			if( SeeTeamDeath[ i ] != None )
			{
				Count++;
			}
			else
				break;
		}
	}
	else if( SoundType == 'RangedAttack' )
	{
		for( i = 0; i <= 15; i++ )
		{
			log( "* Checking: "$RangedAttack[ i ] );
			if( RangedAttack[ i ] != None )
			{
				Count++;
			}
			else
				break;
		}
	}

	return Count;
}

function PlayHuntingSound( Pawn aGrunt )
{
	local int i;
	local int HuntSoundCount;
	//log( "PlayHuntingSound" );

	HuntSoundCount = GetSoundCount( 'Hunting' );

	i = Rand( HuntSoundCount );

	if( Hunting[ i ] != None )
	{
		aGrunt.PlaySound( Hunting[ i ], SLOT_Talk, aGrunt.SoundDampening * 0.99, true,, GruntList[ GetGruntIndex( aGrunt ) ].VoicePitch, true );
		GruntList[ GetGruntIndex( aGrunt ) ].LastSoundPlayed = Hunting[ i ];
		GruntList[ GetGruntIndex( aGrunt ) ].LastSoundTime = Level.TimeSeconds;
		LastHuntingSound = Hunting[ i ];
	}
}

function PlaySeeTeamDeathSound( Pawn aGrunt )
{
	local int i;
	local int SeeTeamDeathCount;

	SeeTeamDeathCount = GetSoundCount( 'SeeTeamDeath' );

	i = Rand( SeeTeamDeathCount );

	if( SeeTeamDeath[ i ] != None )
	{
		aGrunt.PlaySound( SeeTeamDeath[ i ], SLOT_TALK, aGrunt.SoundDampening * 0.99, true,, GruntList[ GetGruntIndex( aGrunt ) ].VoicePitch, true );
		GruntList[ GetGruntIndex( aGrunt ) ].LastSoundPlayed = SeeTeamDeath[ i ];
		GruntList[ GetGruntIndex( aGrunt ) ].LastSoundTime = Level.TimeSeconds;
		LastSeeTeamDeathSound = SeeTeamDeath[ i ];
	}
}

function PlayAcquisitionSound( Pawn aGrunt )
{
	local int i;
	local int AcquisitionCount;

	AcquisitionCount = GetSoundCount( 'Acquisition' );

	i = Rand( AcquisitionCount );

	if( Acquisition[ i ] != None )
	{
		aGrunt.PlaySound( Acquisition[ i ], SLOT_TALK, aGrunt.SoundDampening * 0.99, true,, GruntList[ GetGruntIndex( aGrunt ) ].VoicePitch, true );
		GruntList[ GetGruntIndex( aGrunt ) ].LastSoundPlayed = Acquisition[ i ];
		GruntList[ GetGruntIndex( aGrunt ) ].LastSoundTime = Level.TimeSeconds;
		LastAcquisitionSound = Acquisition[ i ];
	}
}

function PlayCoverReachedSound( Pawn aGrunt )
{
	local int i;
	local int CoverReachedCount;

	CoverReachedCount = GetSoundCount( 'CoverReached' );

	i = Rand( CoverReachedCount );

	if( CoverReached[ i ] != None )
	{
		aGrunt.PlaySound( CoverReached[ i ], SLOT_TALK, aGrunt.SoundDampening * 0.99, true,, GruntList[ GetGruntIndex( aGrunt ) ].VoicePitch, true );
		GruntList[ GetGruntIndex( aGrunt ) ].LastSoundPlayed = CoverReached[ i ];
		GruntList[ GetGruntIndex( aGrunt ) ].LastSoundTime = Level.TimeSeconds;
		LastCoverReachedSound = CoverReached[ i ];
	}
}

function PlayCoverPointSound( Pawn aGrunt )
{
	local int i;
	local int CoverPointCount;

	CoverPointCount = GetSoundCount( 'CoverPoint' );

	i = Rand( CoverPointCount );

	if( CoverPoint[ i ] != None )
	{
		aGrunt.PlaySound( CoverPoint[ i ], SLOT_TALK, aGrunt.SoundDampening * 0.99, true,, GruntList[ GetGruntIndex( aGrunt ) ].VoicePitch, true );
		GruntList[ GetGruntIndex( aGrunt ) ].LastSoundPlayed = CoverPoint[ i ];
		GruntList[ GetGruntIndex( aGrunt ) ].LastSoundTime = Level.TimeSeconds;
		LastCoverPointSound = CoverPoint[ i ];
	}
}	

function PlayPainSound( Pawn aGrunt )
{
	local int i;
	local int PainCount;

	PainCount = GetSoundCount( 'Pain' );

	i = Rand( PainCount );

	if( Pain[ i ] != None )
	{
		aGrunt.PlaySound( Pain[ i ], SLOT_TALK, aGrunt.SoundDampening * 0.99, true,, GruntList[ GetGruntIndex( aGrunt ) ].VoicePitch, true );
		GruntList[ GetGruntIndex( aGrunt ) ].LastSoundPlayed = Pain[ i ];
		GruntList[ GetGruntIndex( aGrunt ) ].LastSoundTime = Level.TimeSeconds;
		LastPainSound = Pain[ i ];
	}
}

function PlayRangedAttackSound( Pawn aGrunt )
{
	local int i;
	local int RangedAttackCount;

	RangedAttackCount = GetSoundCount( 'RangedAttack' );
	
	log( "RangedAttackCount: "$RangedAttackCount );

	i = Rand( RangedAttackCount );

	log( "i: "$i );

	log( "Sound to play is "$RangedAttack[ i ] );

	if( RangedAttack[ i ] != None )
	{
		aGrunt.PlaySound( RangedAttack[ i ], SLOT_TALK, aGrunt.SoundDampening * 0.99, true,, GruntList[ GetGruntIndex( aGrunt ) ].VoicePitch, true );
		GruntList[ GetGruntIndex( aGrunt ) ].LastSoundPlayed = RangedAttack[ i ];
		GruntList[ GetGruntIndex( aGrunt ) ].LastSoundTime = Level.TimeSeconds;
		LastRangedAttackSound = RangedAttack[ i ];
	}
}

auto state SettingUp
{
	function BeginState()
	{
//		SetTimer( 0.2, false );
	}

	function Timer( optional int TimerNum )
	{
		local EDFGrunts Grunt;
		
		foreach allactors( class'EDFGrunts', Grunt )
		{
			//log( "--- "$self$" adding grunt "$Grunt$" to list." );
			AddGrunt( Grunt );
		}
	}
}

defaultproperties
{
     Acquisition(0)=Sound'a_edf.Acquisition.EDF_ISeeHim'
     Acquisition(1)=Sound'a_edf.Acquisition.EDF_TargetAcquired'
     Acquisition(2)=Sound'a_edf.Acquisition.EDF_OpenFire'
     Acquisition(3)=Sound'a_edf.Acquisition.EDF_EngagingEnemy'
	 Acquisition(4)=Sound'a_edf.Idling.EDF_YouHearSomething'
	 
	 Idling(0)=Sound'a_edf.Idling.EDF_LockAndLoadPeople'
	 Idling(1)=Sound'a_edf.Idling.EDF_AreaSecure'
	 //Idling(2)=Sound'a_edf.Idling.EDF_YouHearSomething'
	 Idling(2)=Sound'a_edf.Idling.EDF_StayFrosty'
	 Idling(3)=Sound'a_edf.Idling.EDF_SectorSecure'

	 RangedAttack(0)=Sound'a_edf.RangedAttack.EDF_HesMine'
	 RangedAttack(1)=Sound'a_edf.RangedAttack.EDF_ShortControlledBursts'
     //RangedAttack(2)=Sound'a_edf.RangedAttack.EDF_LayDownSupressingFire'
	 RangedAttack(2)=Sound'a_edf.RangedAttack.EDF_PinHimDown'
	 RangedAttack(3)=Sound'a_edf.RangedAttack.EDF_SprayTheArea'
	 RangedAttack(4)=Sound'a_edf.RangedAttack.EDF_CheckThatCrossFire'
	 RangedAttack(5)=Sound'a_edf.RangedAttack.EDF_ReturnFire'
	
	 Hunting(0)=Sound'a_edf.Hunting.EDF_ImGoingIn'
	 Hunting(1)=Sound'a_edf.Hunting.EDF_MoveUpMoveUp'
     Hunting(2)=Sound'a_edf.Hunting.EDF_CoverMe'
	 Hunting(3)=Sound'a_edf.Hunting.EDF_RequestingCoverFire'

	 Pain(0)=Sound'a_edf.Pain.EDF_Scream03'
	 Pain(1)=Sound'a_edf.Pain.EDF_Scream04'
	 Pain(2)=Sound'a_edf.Pain.EDF_UnderAttack'
	 Pain(3)=Sound'a_edf.Pain.EDF_ImHit'
	 Pain(4)=Sound'a_edf.Pain.EDF_TakingHostileFire'
	 
	 SeeTeamDeath(0)=Sound'a_edf.SeeTeamDeath.EDF_Casualties'
	 SeeTeamDeath(1)=Sound'a_edf.SeeTeamDeath.EDF_ManDown'
	 SeeTeamDeath(2)=Sound'a_edf.SeeTeamDeath.EDF_WeNeedBackup'
	 SeeTeamDeath(3)=Sound'a_edf.SeeTeamDeath.EDF_Medic'
	 SeeTeamDeath(4)=Sound'a_edf.SeeTeamDeath.EDF_SendBackup'
	 //CoverPoint(0)=Sound'a_edf.CoverPoint.EDF_DiggingIn'
	 //CoverPoint(1)=Sound'a_edf.CoverPoint.EDF_HoldPosition'
	 CoverPoint(0)=Sound'a_edf.CoverPoint.EDF_HeadingForCover'
	 CoverPoint(1)=Sound'a_edf.CoverPoint.EDF_TakeCover'
	 CoverPoint(2)=Sound'a_edf.CoverPoint.EDF_FallBackFallBack'
	 CoverReached(0)=Sound'a_edf.CoverPoint.EDF_DiggingIn'
	 CoverReached(1)=Sound'a_edf.CoverPoint.EDF_HoldPosition'
	 CoverReached(2)=Sound'a_edf.CoverPoint.EDF_ImClear'

	 KilledDuke(0)=Sound'a_edf.KilledDuke.EDF_TargetNeutralized'
	 KilledDuke(1)=Sound'a_edf.KilledDuke.EDF_AreaSecure'
	 PinDownFire(0)=Sound'a_edf.PinDownFire.EDF_SprayTheArea'
	 PinDownFire(1)=Sound'a_edf.PinDownFire.EDF_PinHimDown'
	 PinDownFire(2)=Sound'a_edf.PinDownFire.EDF_LayDownSupressingFire'
}
