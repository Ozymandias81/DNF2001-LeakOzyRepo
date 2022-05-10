//=============================================================================
//	dnBreakableGlass
//	Author: John Pollard
//=============================================================================
class dnBreakableGlass expands BreakableGlass;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Sounds\a_impact.dfx

// Event stuff
var() name			UsedEvent					?("Event triggered when glass is used.");
var() int			UsedEventCount				?("Number of times the UsedEvent trigger can be used (0 = infinite).");
var() name			CrackedEvent				?("Event triggered when glass is cracked.");
var() int			CrackedEventCount			?("Number of times the CrackedEvent trigger can be used (0 = infinite).");
var() name			ShatteredEvent				?("Event triggered when glass is shattered.");
var() int			ShatteredEventCount			?("Number of times the ShatteredEvent trigger can be used (0 = infinite).");
var() name			RespawnedEvent				?("Event triggered when glass is respawned.");
var() int			RespawnedEventCount			?("Number of times the RespawnedEvent trigger can be used (0 = infinite).");

// Trigger stuff
var() bool			bBreakOnTrigger				?("Whether or not you want the glass to break when triggered.");
var() int			BreakOnTriggerCount			?("How many times the glass can be broken via trigger (0 = infinite)");
var() bool			bDirForce;
var() float			ForceScale;

var() name			TriggerEvent				?("Event triggered when glass is triggered.");
var() int			TriggerEventCount			?("Number of times the TriggerEvent trigger can be used (0 = infinite).");

var() bool			bDebug						?("If set to true, debug info will be printed to the console for special events.");

var dnGlassFragments	Fragments;
var vector				OldMin, OldMax;

//=============================================================================
//	PostBeginPlay
//=============================================================================
simulated function PostBeginPlay()
{
	if ( UsedEvent != '' )
		bUseTriggered = true;
	else
		bUseTriggered = false;

	Super.PostBeginPlay();
}

//=============================================================================
//	DoEvent
//=============================================================================
simulated function DoEvent(out name EventName, out int EventCount)
{
	local string TestStr;

	TestStr = string(EventName);

	if (EventName != '')
	{
		GlobalTrigger(EventName);

		if (bDebug)
			BroadcastMessage(self@": Doing event: "@EventName@","@EventCount);

		if (EventCount > 0)
		{
			EventCount--;
			if (EventCount == 0)
				EventName = '';
		}
	}
}

//=============================================================================
//	Used
//=============================================================================
simulated function Used( actor Other, Pawn EventInstigator )
{
	if (bDebug)
		BroadcastMessage(self@": Used");

	DoEvent(UsedEvent, UsedEventCount);
}

//=============================================================================
//	GlassCracked
//=============================================================================
simulated function GlassCracked()
{
	if (bDebug)
		BroadcastMessage(self@": Cracked");

	DoEvent(CrackedEvent, CrackedEventCount);
}

//=============================================================================
//	GlassShattered
//=============================================================================
simulated function GlassShattered()
{
	if (bDebug)
		BroadcastMessage(self@": Shattered");

	DoEvent(ShatteredEvent, ShatteredEventCount);

	if (Fragments == None)
		Fragments = Spawn(class'dnGlassFragments');
}

//=============================================================================
//	LooseVectorCmp
//=============================================================================
simulated function bool LooseVectorCmp(vector v1, vector v2, float Epsilon)
{
	if (abs(v1.X - v2.X) > Epsilon)
		return false;
	if (abs(v1.Y - v2.Y) > Epsilon)
		return false;
	if (abs(v1.Z - v2.Z) > Epsilon)
		return false;

	return true;
}

//=============================================================================
//	Tick
//=============================================================================
simulated function Tick(float DeltaTime)
{
	local vector	Min, Max, Center;
	local float		Radius, Height;

	if (Fragments != None)
	{
		if (NumGlassParticles == 0)
		{
			//BroadCastMessage(self@": Done");
			Fragments.Destroy();
			Fragments = None;
		}
		else
		{
			GetParticleBox(Min, Max);

			if (!LooseVectorCmp(Min,OldMin, 3.0f) || LooseVectorCmp(Max,OldMax, 3.0f))
			{
				//BroadCastMessage(self@": Updating particle box");
				
				// Remember old box so we only re-compute when needed
				OldMin = Min;
				OldMax = Max;

				// Get Center, Radius, and Height
				Center = (Min+Max)*0.5f;
				Height = abs(Max.Z - Center.Z);
				if (Height < 5)
					Height = 5;
				Max.Z = 0.0f;
				Min.Z = 0.0f;
				Radius = VSize(Max-Min)*0.5f;

				// Update Fragments collison info with this data
				Fragments.SetCollisionSize(Radius, Height);
				Fragments.SetLocation(Center);
			}
		}
	}

	Super.Tick(DeltaTime);
}

//=============================================================================
//	GlassRespawned
//=============================================================================
simulated function GlassRespawned()
{
	if (bDebug)
		BroadcastMessage(self@": Respawned");

	DoEvent(RespawnedEvent, RespawnedEventCount);
}

//================================================================================
//	Trigger
//================================================================================
simulated function Trigger(actor Other, pawn EventInstigator)
{
	if (bBreakOnTrigger)
	{
		if (bDebug)
			BroadcastMessage(self@": Triggered");

		ReplicateBreakGlass( Other.Location, bDirForce, ForceScale );
		
		if (BreakOnTriggerCount > 0)
		{
			BreakOnTriggerCount--;
			if (BreakOnTriggerCount == 0)
				bBreakOnTrigger = false;
		}
	}

	DoEvent(TriggerEvent, TriggerEventCount);
}

//=============================================================================
//	defaultproperties
//=============================================================================
defaultproperties
{
	GlassSizeX=128.0f
	GlassSizeY=64.0f

	GlassTexture1=texture't_generic.Glass.BrokenGlass1RC'
	GlassTexture2=texture't_generic.Glass.BrokenGlass2RC'
	GlassTexture3=texture't_generic.Glass.BrokenGlass3RC'

	GlassSound1=Sound'a_impact.Glass.GlassHit01'
	GlassSound2=Sound'a_impact.Glass.GlassBreak01'
	GlassSound3=Sound'a_impact.Glass.GlassBreak02'
	GlassSound4=Sound'a_impact.Glass.GlassBreak03'

	ParticleSize=25.0f
	InitialBreakCount=5

	FallPerSecond1=50.0f
	FallPerSecond2=130.0f

	TotalBreakPercent1=0.10f
	TotalBreakPercent2=0.55f

	bGlassTranslucent=true
	bGlassModulated=false
	bGlassMasked=false
	bTwoSided=true

	bBlockPlayers=true
	bBlockActors=true
	bProjTarget=true
	bCollideActors=true
	
	bEdShouldSnap=true
	
	CollisionRadius=40.0
	CollisionHeight=40.0
 
    LightDetail=LTD_Normal
	bUnlit=false

	ScaleGlow=0.1
	AmbientGlow=0.1
	
	bUseTriggered=true
}
