//=============================================================================
// PressureZone.
//=============================================================================
class PressureZone extends ZoneInfo;

var() float  KillTime;					// How long to kill the player?
var() float  StartFlashScale;			// Fog values for client death sequence
var() Vector StartFlashFog;
var() float  EndFlashScale;
var() Vector EndFlashFog;
var() float  DieFOV;					// Field of view when dead (interpolates)
var() float  DieDrawScale;				// Drawscale when dead
var   float  TimePassed;
var() byte   DieFatness;				// Fatness when dead
var   bool   bTriggered;				// Ensure that it doesn't update until it should
var	  bool	 bScreamed;

function BeginPlay()
{
	Super.BeginPlay();
	Disable('Tick');
	bTriggered = false;
	DieFOV = FClamp( DieFOV, 1, 170 );
	DieFatness = Clamp( DieFatness, 1, 255 );
}

function Trigger( actor Other, pawn EventInstigator )
{
	local Pawn p;

	// The pressure zone has been triggered to kill something

	Instigator = EventInstigator;

	if ( Instigator.IsA('bot') )
	{
		// taunt the victim
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
			if( (P.Region.Zone == self) && (P.Health > 0) )
			{
				Instigator.Target = P;
				Instigator.GotoState('VictoryDance');
			}
	}

	// Engage Tick so that death may be slow and dramatic
	TimePassed = 0;
	bTriggered = true;
	bScreamed = false;
	Disable('Trigger');
	Enable('Tick');
}

function Tick( float DeltaTime )
{
	local float  		ratio, curScale;
	local vector 		curFog;
	local PlayerPawn	pPawn;
	local Pawn P;
	local bool bActive;

	if( !bTriggered ) 
	{
		Disable('Tick');
		return;
	}

	TimePassed += DeltaTime;
	ratio = TimePassed/KillTime;
	if( ratio > 1.0 ) ratio = 1.0;

	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		// Ensure player hasn't been dispatched through other means already (suicide?)
		if( (P.Region.Zone == self) && (P.Health > 0) )
		{
			bActive = true;
				
			// Fatness
			P.Fatness   = byte( 128 + Int( (Float(DieFatness)-128) * ratio ));
			P.DrawScale = 1 + (DieDrawScale-1) * ratio;

			// Maybe scream?
			if( !bScreamed && P.bIsPlayer && (Ratio > 0.2) && (FRand() < 2 * DeltaTime) )
			{
				// Scream now (from the terrible pain)
				bScreamed = true;
				P.PlaySound( P.Die, SLOT_Talk );
			}
		
			// Fog & Field of view
			pPawn = PlayerPawn(P);
			if( pPawn != None )
			{
				curScale = (EndFlashScale-StartFlashScale)*ratio + StartFlashScale;
				curFog   = (EndFlashFog  -StartFlashFog  )*ratio + StartFlashFog;
				pPawn.ClientFlash( curScale, 1000 * curFog );

				pPawn.SetFOVAngle( (DieFOV-pPawn.default.FOVAngle)*ratio + pPawn.default.FOVAngle);
			}
			if ( ratio == 1.0 )
			{	
				Level.Game.SpecialDamageString = DamageString;
				P.GibbedBy(Instigator);
				MakeNormal(P);
			}
		}
	}	
	
	if( !bActive && (TimePassed >= KillTime) )
	{
		Disable('Tick');
		Enable('Trigger');
		bTriggered = false;
	}
}

function MakeNormal(Pawn P)
{
	local PlayerPawn PPawn;
	// set the fatness back to normal
	P.Fatness = P.Default.Fatness;
	P.DrawScale = P.Default.DrawScale;
	PPawn = PlayerPawn(P);
	if( PPawn != None )
		PPawn.SetFOVAngle( PPawn.Default.FOVAngle );
}

// When an actor leaves this zone.
event ActorLeaving( actor Other )
{
	if( Other.bIsPawn )
		MakeNormal(Pawn(Other));
	Super.ActorLeaving(Other);
}

defaultproperties
{
	bStatic=false
	DamageType=SpecialDamage
	DamageString="%o was depressurized by %k."
}
