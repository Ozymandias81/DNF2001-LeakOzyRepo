/*-----------------------------------------------------------------------------
	ShrinkRayBeamAnchor
-----------------------------------------------------------------------------*/
class ShrinkRayBeamAnchor extends BeamAnchor;

var int BeamEffectImpulse, OldBeamEffectImpulse;

replication
{
	reliable if ( Role==ROLE_Authority )
		BeamEffectImpulse;
}

// Spawn the effect in post begin play, which is called when
// we are created after becoming relevant.
simulated function PostBeginPlay()
{
	if ( BeamEffectImpulse == 1 )
		CreateChargeEffect();
	else if ( BeamEffectImpulse == 2 )
		CreateBeamEffect();

	Super.PostBeginPlay();
}

// Destroy the beam effect if we are destroyed,
// which would happen when the weapon is destroyed
// or we become not-relevant.
simulated function Destroyed()
{
	DestroyBeamEffect();

	Super.Destroyed();
}

// Check to see if our beam effect changed.
simulated function Tick( float Delta )
{
	if ( Level.NetMode == NM_DedicatedServer )
		return;

	if ( BeamEffectImpulse != OldBeamEffectImpulse )
	{
		switch ( BeamEffectImpulse )
		{
			case 0: // Off
				DestroyBeamEffect();
				break;
			case 1: // Charge
				CreateChargeEffect();
				break;
			case 2: // Fire
				CreateBeamEffect();
				break;
			case 3: // Pawn hit.
				CreatePawnHitEffect();
				break;
			case 4: // Normal hit.
				CreateNormalHitEffect();
				break;
		}
		OldBeamEffectImpulse = BeamEffectImpulse;
	}
}

// Create the beam charge effect.
simulated function CreateChargeEffect()
{
	Shrinkray(Owner).SpawnChargeEffectThird();
}

// Create the beam effect.
simulated function CreateBeamEffect()
{
	Shrinkray(Owner).DestroyChargeEffectThird();
	Shrinkray(Owner).SpawnExpendEffectThird();
	Shrinkray(Owner).SpawnBeamEffectThird( Self );
}

// Destroy the beam effect.
simulated function DestroyBeamEffect()
{
	Shrinkray(Owner).DestroyChargeEffectThird();
	Shrinkray(Owner).DestroyExpendEffectThird();
	Shrinkray(Owner).DestroyBeamEffectThird();
	Shrinkray(Owner).DestroyHitEffects( false );
}

// We hit a pawn.
simulated function CreatePawnHitEffect()
{
	if ( Shrinkray(Owner).BeamEffectThird == None )
		CreateBeamEffect(); // We may have skipped this if the message was overwritten in same frame.
	Shrinkray(Owner).SpawnPawnHitEffects( Self );
}

// We hit a wall.
simulated function CreateNormalHitEffect()
{
	Shrinkray(Owner).SpawnNormalHitEffects( Self );
}

defaultproperties
{
	bAlwaysRelevant=true
	bIgnoreBList=true
	bDontSimulateMotion=true
}