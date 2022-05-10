/*-----------------------------------------------------------------------------
	EMPulse
	Author: EVERYBODY!!
-----------------------------------------------------------------------------*/
class EMPulse extends Effects;

#exec OBJ LOAD FILE=..\Meshes\c_generic.dmx

var() float				InitialScaleRate;
var() float				ScaleAccel;
var   float				ScaleRate;
var() float				InitialScale;
var() float				FinalScale;
var() float             EndTime;
var() byte				EndLightRadius;

var dnWeaponFX_EmpSphere MySphere;
var dnEMPShockFX_SparkBeamA MyBeam;
var float currentRadius;
var bool bFirstTick;
var float TotalTime;
var float MaxRadius;
var float EMPTime;
var float RadiusVelocity;

var float	TimeToDie;
var byte	OriginalBrightness;

#exec OBJ LOAD FILE=..\Sounds\dnsWeapn.dfx

function PostBeginPlay()
{
	TimeToDie = LifeSpan;
	OriginalBrightness = LightBrightness;

	Enable( 'Tick' );
	if( Radiusvelocity == 0 )
	{
		MaxRadius=256;
		RadiusVelocity=600;
		EMPTime=10.0;
	}
//	PlaySound( Sound'dnsWeapn.EMP.EMPPulse1', SLOT_None );
}

function Tick( float DeltaTime )
{   
    local LaserMine    LM;
	local dnDecoration D;
	local Actor   P;
	local Pawn         aPawn;
	local RenderActor        A;

    // When a tick happens, then we should increase our radius of effect and 
	// pulse anything that has not already been pulsed    
    currentRadius += DeltaTime * RadiusVelocity;
	TotalTime += DeltaTime;
	//BroadcastMessage( "Rad:"$currentRadius$"Time:"$TotalTime );
    // Get owner
	if( bFirstTick )
	{
		bFirstTick = false;
		return;
	}
	P = Owner;
    if ( currentRadius >= MaxRadius )
	{
        currentRadius = MaxRadius;
	}

	foreach RadiusActors( class'RenderActor', A, currentRadius, P.Location )
	{
		if ( LaserMine( A ) != None || dnDecoration( A ) != None || ( Pawn( A ) != None ) )
		{
			if ( A.IsA( 'EDFHeavyWeps' ) ) 
			{
				if ( !Owner.IsA( 'EDFHeavyWeps' ) )
				{
					if ( !A.bEMPulsed )
					{
						A.EMPBlast( EMPTime, Pawn( P ) );
					}
				}
			}
			else if ( !A.bEMPulsed && (A != Owner) )
			{
				A.EMPBlast( EMPTime, Pawn( P ) );
			}
		}
	}
}

state Exploding
{
	simulated function BeginState()
	{
		MySphere = spawn( class'dnWeaponFX_EMPSphere',, NameForString( ""$Name$"Sphere" ) );
		MySphere.AttachActorToParent( Self, false, false );
//		MyBeam = Spawn( class'dnEMPShockFX_SparkBeamA', self,,Location );
		MyBeam = Spawn( class'dnEMPShockFX_SparkBeamA');
		MyBeam.AttachActorToParent( Self, false, false );
		MyBeam.Event = NameForString( ""$Name$"SphereTargets" );
		MyBeam.ResetDestinationActors();

		SetSize( InitialScale );
		ScaleRate = InitialScaleRate;
//		PlaySound( EffectSound1 );
	}

	simulated function Tick( float Delta )
	{
		Global.Tick( Delta );
		LightBrightness = OriginalBrightness - ((TotalTime / TimeToDie) * OriginalBrightness);
		ScaleRate += ScaleAccel * Delta;
		SetSize( DrawScale + ScaleRate * Delta );

		if ( DrawScale >= FinalScale )
		{
			SetSize( FinalScale );
		}
	}
}

simulated function SetSize( float NewRadius )
{
	DrawScale = default.DrawScale * NewRadius;
	//ProjCollisionRadius = default.ProjCollisionRadius * Scalar;
	LightRadius = byte( float(EndLightRadius) * (DrawScale - InitialScale) / (FinalScale - InitialScale) );
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
//	LifeSpan=0
	DrawType=DT_Mesh
	bUnlit=true
	bAlwaysRelevant=true
    Mesh=None
	Skin=None
	EndLightRadius=25
    InitialScale=0.100000
    FinalScale=40.000000
    InitialScaleRate=80.000000
    ScaleAccel=-20.000000
	InitialState=Exploding
	Physics=PHYS_MovingBrush
	Style=STY_Translucent
    LightType=LT_Steady
    LightEffect=LE_Shell
    LightBrightness=255
    LightHue=150
    LightSaturation=128
	LightRadius=0
	LifeSpan=1.1
}