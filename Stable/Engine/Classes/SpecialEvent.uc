//=============================================================================
// SpecialEvent: Receives trigger messages and does some "special event"
// depending on the state.
//=============================================================================
class SpecialEvent extends Triggers;

#exec Texture Import File=Textures\TrigSpcl.pcx Name=S_SpecialEvent Mips=Off Flags=2

//-----------------------------------------------------------------------------
// Variables.

var() int        Damage;         // For DamagePlayer state.
var() class<DamageType> DamageType;
var() localized  string DamageString;
var() localized  string Message; // For all states.
var() sound      Sound;          // For PlaySoundEffect state.
var() bool       bBroadcast;     // To broadcast the message to all players.
var() bool			bAllBroadcast;  // Broadcast the message to the entire game
var() bool       bPlayerViewRot; // Whether player can rotate the view while pathing.
var() float      TotalFadeTime   ?("Amount of time to fade an ambient sound when turning it off");

var   byte       origSoundVolume; // Original volume of amient sound (for fading).
var   float      FadeTimer;       // Keeps track of amount of time passed since fade started
var   bool       firstTick;

//-----------------------------------------------------------------------------
// Functions.

function Trigger( actor Other, pawn EventInstigator )
{
	local pawn P;
	if( bBroadcast )
		BroadcastMessage(Message, true, 'CriticalEvent'); // Broadcast message to all players.
	else 
	if ( bAllBroadcast )
		BroadcastMessage (Message);
	else if( EventInstigator!=None && len(Message)!=0 )
	{
		// Send message to instigator only.
		EventInstigator.ClientMessage( Message );
	}
}

//-----------------------------------------------------------------------------
// States.

// Just display the message.
state() DisplayMessage
{
}

// Damage the instigator who caused this event.
state() DamageInstigator
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		Global.Trigger( Self, EventInstigator );
		Other.TakeDamage( Damage, EventInstigator, EventInstigator.Location, Vect(0,0,0), DamageType );
	}
}

// Kill the instigator who caused this event.
state() KillInstigator
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		Global.Trigger( Self, EventInstigator );
		if( EventInstigator != None )
			EventInstigator.Died( None, DamageType, EventInstigator.Location );
	}
}

// Play a sound.
state() PlaySoundEffect
{           
	function Trigger( actor Other, pawn EventInstigator )
	{
		Global.Trigger( Self, EventInstigator );
		PlaySound( Sound );
	}
}

// Play a sound.
state() PlayersPlaySoundEffect
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		local pawn P;

		Global.Trigger( Self, EventInstigator );

		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
			if ( P.bIsPlayer && P.IsA('PlayerPawn') )
				PlayerPawn(P).ClientPlaySound(Sound);
	}
}

// Play ambient sound effect 
state() PlayAmbientSoundEffect
{
    function PostBeginPlay()
    {
        Super.PostBeginPlay();
        // No ambient sound for this state when starting
        Sound           = AmbientSound;
        AmbientSound    = none;
        origSoundVolume = SoundVolume;
    }

    function SoundOff()
    {
        AmbientSound = none;
    }

    function SoundOn()
    {
	    AmbientSound = Sound;
    }

    function Tick( float TimeDelta )
    {
        local float f;
        
        if ( !firstTick )
        {
            Disable( 'Tick' );
            firstTick = true;
            return;
        }

        // Fade the volume
        FadeTimer += TimeDelta;

        f = 1.0 - ( FadeTimer / TotalFadeTime );

        if ( f <= 0 )
        {
            // Done fading, reset Sound Volume back to normal
            SoundVolume = origSoundVolume;
            SoundOff();
            FadeTimer = 0;
            Disable( 'Tick' );
        }
        else
        {
            SoundVolume = origSoundVolume * f;  // Fade volume
        }
    }

    function Trigger( actor Other, pawn EventInstigator )
	{
        Global.Trigger( Self, EventInstigator );

        if ( AmbientSound == none )  // Sound is off, turn it on
        {
            SoundOn();
        }
        else
        {
            if ( TotalFadeTime != 0 ) // Reset Timer and enable ticking to do fade
            {
                FadeTimer = 0;  
                Enable( 'Tick' );
            }
            else // Regular toggle
            {
                SoundOff();
            }
        }
	}
}


// Send the player on a spline path through the level.
state() PlayerPath
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		local InterpolationPoint i;
		Global.Trigger( Self, EventInstigator );
		if( EventInstigator!=None && EventInstigator.bIsPlayer && (Level.NetMode == NM_Standalone) )
		{
			foreach AllActors( class 'InterpolationPoint', i, Event )
			{
				//if( i.Position == 0 )
				//{
					EventInstigator.GotoState('');
					EventInstigator.SetCollision(True,false,false);
					EventInstigator.bCollideWorld = False;
					EventInstigator.Target = i;
					EventInstigator.SetPhysics(PHYS_Interpolating);
					EventInstigator.PhysRate = 1.0;
					EventInstigator.PhysAlpha = 0.0;
					EventInstigator.bInterpolating = true;
					EventInstigator.AmbientSound = AmbientSound;
					break;
				//}
			}
		}
	}
}

defaultproperties
{
	Texture=Texture'Engine.S_SpecialEvent'
	DamageType=class'CrushingDamage'
}
