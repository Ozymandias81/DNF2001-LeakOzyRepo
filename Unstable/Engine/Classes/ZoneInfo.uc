//=============================================================================
// ZoneInfo, the built-in Unreal class for defining properties
// of zones.  If you place one ZoneInfo actor in a
// zone you have partioned, the ZoneInfo defines the 
// properties of the zone.
// This is a built-in Unreal class and it shouldn't be modified.
//
// NJS:
// 		Recently added the ability to add Depth based fog to a zone.
// see the descriptions by each of the following variables below for information
// on how to use it:
//		FogColor
//		FogDistance
//		FogDensity
//		FogEnabled
//=============================================================================
class ZoneInfo extends Info
	native
	placeable
	nativereplication;

#exec Texture Import File=Textures\ZoneInfo.pcx Name=S_ZoneInfo Mips=Off Flags=2

//-----------------------------------------------------------------------------
// Zone properties.

var() name   ZoneTag;
var() name   SkyZoneTag;
var() vector ZoneGravity;
var() vector ZoneVelocity;
var() float  ZoneGroundFriction;
var() float  ZoneFluidFriction;
var() float	 ZoneTerminalVelocity;
var() name   ZonePlayerEvent;
var() name   ZonePlayerExitEvent;
var   int    ZonePlayerCount;
var   int	 NumCarcasses;
var(LocationStrings) localized string ZoneName;
var LocationID LocationID;	
var() int	 MaxCarcasses;
var() sound  EntrySound;	//only if waterzone
var() sound  ExitSound;		// only if waterzone
var() class<actor> EntryActor;	// e.g. a splash (only if water zone)
var() class<actor> ExitActor;	// e.g. a splash (only if water zone)
var skyzoneinfo SkyZone; // Optional sky zone containing this zone's sky.
var() float  DefaultVisibilityRadius;

//-----------------------------------------------------------------------------
// Zone flags.

var()		bool   bWaterZone;   // Zone is water-filled.
var(Rain)	bool   bWetZone;
var() const bool   bFogZone;     // Zone is fog-filled.
var() const bool   bKillZone;    // Zone instantly kills those who enter.
var()		bool   bNeutralZone; // Players can't take damage in this zone.
var()		bool   bGravityZone; // Use ZoneGravity.
var()		bool   bDestructive; // Destroys carcasses.
var()		bool   bNoInventory;
var()		bool   bMoveProjectiles;// this velocity zone should impart velocity to projectiles and effects
var()		bool   bBounceVelocity;	// this velocity zone should bounce actors that land in it
var()		bool   bTerrainZone;	// There is terrain in this zone.
var()		bool   bDistanceFog;	// There is distance fog in this zone.

var(Rain)   name   MidThunderEvent;
var(Rain)   name   FarThunderEvent;

//var const array<TerrainInfo> Terrains;

//-----------------------------------------------------------------------------
// Zone light.

var(ZoneLight) byte AmbientBrightness, AmbientHue, AmbientSaturation;

var(ZoneLight) int   FogDistance;	// NJS: Distance to the depth based fog.
var(ZoneLight) color FogColor;		// NJS: Color of the depth based fog.
var(ZoneLight) float FogDensity;	// NJS: Density of the depth based fog.

var int   originalFogDistance;	// NJS: Distance to the depth based fog.
var float originalFogDensity;	// NJS: Density of the depth based fog.
var color originalFogColor;		// NJS: Color of the depth based fog.

var(ZoneLight) bool  FogEnabled;	// NJS: Whether depth based fog is enabled.
var(ZoneLight) float ClipDistance;

var(ZoneLight) const texture EnvironmentMap;
var(ZoneLight) float TexUPanSpeed, TexVPanSpeed;
var(ZoneLight) vector ViewFlash, ViewFog;

//-----------------------------------------------------------------------------
// Reverb.

// Settings.
var(Reverb) bool bReverbZone;
var(Reverb) bool bRaytraceReverb;
var(Reverb) float SpeedOfSound;
var(Reverb) byte MasterGain;
var(Reverb) int  CutoffHz;
var(Reverb) byte Delay[6];
var(Reverb) byte Gain[6];

//-----------------------------------------------------------------------------
// Lens flare.
var(LensFlare) texture LensFlare[12];
var(LensFlare) float LensFlareOffset[12];
var(LensFlare) float LensFlareScale[12];

//-----------------------------------------------------------------------------
// DamageOverTime
// 0	Electrical
// 1	Fire
// 2	Cold
// 3	Poison
// 4	Radiation
// 5	Biochemical
// 6	Water
// 7	Steroids Burnout

var(DamageOverTime) EDamageOverTime DOT_Type;
var(DamageOverTime) float DOT_Duration					?("Total duration of DOT. (-1 for infinity)");
var(DamageOverTime) float DOT_ExitDuration				?("Total duration of DOT when the player leaves the zone.");
var(DamageOverTime) float DOT_Time						?("Frequency of a DOT ping.");
var(DamageOverTime) float DOT_Damage					?("Damage to inflict on a DOT ping.");
var(DamageOverTime) EDamageOverTime TriggerDOTType		?("If you trigger a zone and this isn't DOT_None DOT_Type will be set.");		

//-----------------------------------------------------------------------------
// per-Zone mesh LOD lighting control
 
// the number of lights applied to the actor mesh is interpolated between the following
// properties, as a function of the MeshPolyCount for the previous frame.
var() byte MinLightCount; // minimum number of lights to use (when MaxLightingPolyCount is exceeded)
var() byte MaxLightCount; // maximum number of lights to use (when MeshPolyCount drops below MinLightingPolyCount)
var() int MinLightingPolyCount;
var() int MaxLightingPolyCount;
// (NOTE: the default LOD properties (below) have no effect on the mesh lighting behavior)
//LEGEND:end

//=============================================================================
// Network replication.

replication
{
	reliable if( Role==ROLE_Authority )
		ZoneGravity, ZoneVelocity, 
		// ZoneTerminalVelocity,
		// ZoneGroundFriction, ZoneFluidFriction,
		AmbientBrightness, AmbientHue, AmbientSaturation,
		TexUPanSpeed, TexVPanSpeed,
		// ViewFlash, ViewFog, // Not replicated because vectors replicated with elements rounded to integers
		bReverbZone,
		FogColor;
}

//=============================================================================
// Iterator functions.

// Iterate through all actors in this zone.
native(308) final iterator function ZoneActors( class<actor> BaseClass, out actor Actor );

//LEGEND:begin -- moved out of PreBeginPlay() to allow overriding
//=============================================================================
simulated function LinkToSkybox()
{
	local skyzoneinfo TempSkyZone;

	if(SkyZoneTag=='')
	{
		// SkyZone.
		foreach AllActors( class 'SkyZoneInfo', TempSkyZone, '' )
		{
			SkyZone = TempSkyZone;
			break;
		}
		/*
		 * High detail skyzone search logic.
		foreach AllActors( class 'SkyZoneInfo', TempSkyZone, '' )
			if( TempSkyZone.bHighDetail == Level.bHighDetailMode )
			{
				SkyZone = TempSkyZone;
				break;
			}
		 */
	} else
	{
		foreach AllActors( class 'SkyZoneInfo', TempSkyZone, SkyZoneTag )
		{
			SkyZone=TempSkyZone;
			break;
		}
	}
}
//LEGEND:end

//=============================================================================
// Engine notification functions.

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// call overridable function to link this ZoneInfo actor to a skybox
	LinkToSkybox();

	originalFogColor=FogColor;					
	originalFogDistance=FogDistance;	
	originalFogDensity=FogDensity;		
}

function Trigger( actor Other, pawn EventInstigator )
{
	// turn zone damage on and off
	if ( TriggerDOTType == DOT_None )
		DOT_Type = TriggerDOTType;
}

// When an actor enters this zone.
event ActorEntered( actor Other )
{
	local actor A;
	local vector AddVelocity;

	if ( bNoInventory && Other.IsA('Inventory') && (Other.Owner == None) )
	{
		Other.LifeSpan = 1.5;
		return;
	}

	if ( Pawn(Other) != None )
	{
		if (DOT_Type != DOT_None)
			Pawn(Other).AddDOT( DOT_Type, DOT_Duration, DOT_Time, DOT_Damage, None );
	}

	if( PlayerPawn(Other)!=None )
	{
		if( ++ZonePlayerCount==1 && ZonePlayerEvent!='' )
			foreach AllActors( class 'Actor', A, ZonePlayerEvent )
				A.Trigger( Self, Pawn(Other) );
	}

	if ( bMoveProjectiles && (ZoneVelocity != vect(0,0,0)) )
	{
		if ( Other.Physics == PHYS_Projectile )
			Other.Velocity += ZoneVelocity;
		else if ( Other.IsA('Effects') && (Other.Physics == PHYS_None) )
		{
			Other.SetPhysics(PHYS_Projectile);
			Other.Velocity += ZoneVelocity;
		}
	}
}

// When an actor leaves this zone.
event ActorLeaving( actor Other )
{
	local actor A;

	if ( Pawn(Other) != None )
	{
		if (DOT_Type != DOT_None)
			Pawn(Other).AddDOT( DOT_Type, DOT_ExitDuration, DOT_Time, DOT_Damage, None );
	}

	if( PlayerPawn(Other)!=None )
		if( --ZonePlayerCount==0 && ZonePlayerExitEvent!='' )
			foreach AllActors( class 'Actor', A, ZonePlayerExitEvent )
				A.Trigger( Self, Pawn(Other) );
}

// NJS:
// Tells this zone that it has been altered in such a way that it should notify
// it's contained actors.
function ZoneAltered()
{
	local actor a;
	foreach ZoneActors( class'actor', a )
	{
		a.ZoneChange(self);
	}
}

defaultproperties
{
     ZoneGravity=(Z=-950.000000)
     ZoneGroundFriction=8.000000
     ZoneFluidFriction=1.200000
     ZoneTerminalVelocity=2500.000000
     MaxCarcasses=3
     bMoveProjectiles=True
     AmbientSaturation=255
     TexUPanSpeed=1.000000
     TexVPanSpeed=1.000000
     SpeedOfSound=8000.000000
     MasterGain=100
     CutoffHz=6000
     Delay(0)=20
     Delay(1)=34
     Gain(0)=150
     Gain(1)=70
     DOT_Type=DOT_None
     DOT_Duration=-100.000000
     DOT_ExitDuration=10.000000
     DOT_Damage=1.000000
     MinLightCount=6
     MaxLightCount=6
     MinLightingPolyCount=1000
     MaxLightingPolyCount=5000
     bStatic=True
     bNoDelete=True
     bAlwaysRelevant=True
     NetUpdateFrequency=4.000000
     Texture=Texture'Engine.S_ZoneInfo'
}
