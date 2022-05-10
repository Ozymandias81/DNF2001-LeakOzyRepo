//=============================================================================
// TriggerZoneAssign. (NJS)
// 
// When TriggerZoneAssign is triggered, it changes various properties 
// associated with the zone(s) that are identified by 'Event' 
//=============================================================================
class TriggerZoneAssign expands Triggers;

#exec Texture Import File=Textures\zoneinfoassign.pcx Name=S_TriggerZoneAssign Mips=Off Flags=2

var () name SkyZoneTag;
var (WhatToAssign) bool SetbWaterZone;
var () bool bWaterZone;
var (WhatToAssign) bool SetbGravityZone;
var () bool bGravityZone;	
var (WhatToAssign) bool SetZoneGravity;
var () vector ZoneGravity;
var (WhatToAssign) bool SetZoneVelocity;
var () vector ZoneVelocity;
var (WhatToAssign) bool SetZoneGroundFriction;
var () float ZoneGroundFriction;
var (WhatToAssign) bool SetZoneFluidFriction;
var () float ZoneFluidFriction;
var (WhatToAssign) bool SetZoneTerminalVelocity;
var () float ZoneTerminalVelocity;
var (WhatToAssign) bool SetZonePlayerEvent;
var () name ZonePlayerEvent;
var (WhatToAssign) bool SetMaxCarcasses;
var () int MaxCarcasses;
var (WhatToAssign) bool SetbDestructive;
var () bool bDestructive;
var (WhatToAssign) bool SetOtherSideURL;
var () string OtherSideURL;

// ZoneLight Related:
var (WhatToAssign) bool Flush;	// NJS: Hack for testing.
var (WhatToAssign) bool SetAmbientBrightness, SetAmbientHue, SetAmbientSaturation;
var (ZoneLight) byte AmbientBrightness, AmbientHue, AmbientSaturation;
var (WhatToAssign) bool SetClipDistance;
var (ZoneLight) float ClipDistance;
var (WhatToAssign) bool SetTexUPanSpeed, SetTexVPanSpeed;
var (ZoneLight) float TexUPanSpeed, TexVPanSpeed;
var (WhatToAssign) bool SetViewFlash, SetViewFog;
var (ZoneLight) vector ViewFlash, ViewFog;

// Fog stuff:
var (WhatToAssign) bool SetFogColor, SetFogDensity, SetFogDistance, SetFogEnabled;
var (ZoneLight) color FogColor;
var (ZoneLight) byte  FogDistance;
var (ZoneLight) float FogDensity;
var (ZoneLight) float FogMorphTime;
var (ZoneLight) bool  FogEnabled;

// Fog morph variables:
var float ElapsedSeconds;
var zoneinfo useZone;

// DOT stuff
var (DOTAssign) bool SetDOTType;
var (DOTAssign) EDamageOverTime DOT_Type;
var (DOTAssign) bool SetDOTDuration;
var (DOTAssign) float DOT_Duration;
var (DOTAssign) bool SetDOTExitDuration;
var (DOTAssign) float DOT_ExitDuration;
var (DOTAssign) bool SetDOTTime;
var (DOTAssign) float DOT_Time;
var (DOTAssign) bool SetDOTDamage;
var (DOTAssign) float DOT_Damage;
var (DOTAssign) bool ReassignDOT;

function PostBeginPlay()
{
	Disable('Tick');
}

function Tick(float deltaSeconds)
{
	local float alpha;
	if(useZone==none)
	{
		Disable('Tick');
		return;
	}
	
	ElapsedSeconds+=deltaSeconds;
	if(ElapsedSeconds>FogMorphTime) 
	{
		ElapsedSeconds=FogMorphTime;
		Disable('Tick');
	}
	alpha=ElapsedSeconds/FogMorphTime;
	
	if(SetFogColor)
	{
		useZone.fogColor.r=byte(Lerp(alpha,float(useZone.originalFogColor.r),float(FogColor.r)));
		useZone.fogColor.g=byte(Lerp(alpha,float(useZone.originalFogColor.g),float(FogColor.g)));
		useZone.fogColor.b=byte(Lerp(alpha,float(useZone.originalFogColor.b),float(FogColor.b)));
		useZone.fogColor.a=byte(Lerp(alpha,float(useZone.originalFogColor.a),float(FogColor.a)));
	
		if(alpha==1.0)
		{
			useZone.originalFogColor.r=useZone.fogColor.r;
			useZone.originalFogColor.g=useZone.fogColor.g;
			useZone.originalFogColor.b=useZone.fogColor.b;
			useZone.originalFogColor.a=useZone.fogColor.a;
		}
	}
	
	if(SetFogDistance)
	{
		useZone.fogDistance=byte(Lerp(alpha,float(useZone.originalFogDistance),float(FogDistance)));
		if(alpha==1.0)
			useZone.originalFogDistance=useZone.fogDistance;
	}
	
	if(SetFogDensity)
	{		
		useZone.fogDensity=Lerp(alpha,useZone.originalFogDensity,FogDensity);
		if(alpha==1.0)
			useZone.originalFogDensity=useZone.fogDensity;
	}
}

function Trigger(actor Other, pawn EventInstigator)
{
	local ZoneInfo 	  	Z;
	local WarpZoneInfo	WZ;
	local Skyzoneinfo 	T, SkyZone; 
	local PlayerPawn P;
	local Pawn Pn;
			
	if(Event!='')
	{
		// Find the skyzone to assign to if applicable.
		if(SkyZoneTag!='')
		{
			SkyZone=none;
			
			// Find the first applicable skyzone.
			foreach allactors(class'SkyZoneInfo',T,SkyZoneTag)
			{
				SkyZone=T;
				break;
			}
		}

		// Assign each related zone:
		foreach allactors(class'ZoneInfo',Z, Event)
		{
			if(SkyZoneTag!='')			Z.SkyZone=SkyZone;
			if(SetbWaterZone)			{ Z.bWaterZone=bWaterZone; Z.ZoneAltered(); }
			if(SetbGravityZone) 		Z.bGravityZone=bGravityZone;
			if(SetZoneGravity)  		Z.ZoneGravity=ZoneGravity;
			if(SetZoneVelocity) 		Z.ZoneVelocity=ZoneVelocity;
			if(SetZoneGroundFriction) 	Z.ZoneGroundFriction=ZoneGroundFriction;
			if(SetZoneFluidFriction)  	Z.ZoneFluidFriction=ZoneFluidFriction;
			if(SetZoneTerminalVelocity) Z.ZoneTerminalVelocity=ZoneTerminalVelocity;
			if(SetZonePlayerEvent)		Z.ZonePlayerEvent=ZonePlayerEvent;
			if(SetMaxCarcasses)			Z.MaxCarcasses=MaxCarcasses;
			if(SetbDestructive) 		Z.bDestructive=bDestructive;
			if(SetAmbientBrightness)	Z.AmbientBrightness=AmbientBrightness;
			if(SetAmbientHue)			Z.AmbientHue=AmbientHue;
			if(SetAmbientSaturation)	Z.AmbientSaturation=AmbientSaturation;
			if(SetClipDistance)			Z.ClipDistance=ClipDistance;
			if(SetTexUPanSpeed)			Z.TexUPanSpeed=TexUPanSpeed;
			if(SetTexVPanSpeed)			Z.TexVPanSpeed=TexVPanSpeed;	
			if(SetViewFlash)			Z.ViewFlash=ViewFlash;
			if(SetViewFog)				Z.ViewFog=ViewFog;
			if(SetDOTType)				Z.DOT_Type = DOT_Type;
			if(SetDOTDuration)			Z.DOT_Duration = DOT_Duration;
			if(SetDOTExitDuration)		Z.DOT_ExitDuration = DOT_ExitDuration;
			if(SetDOTTime)				Z.DOT_Time = DOT_Time;
			if(SetDOTDamage)			Z.DOT_Damage = DOT_Damage;
			if(ReassignDOT)
			{
				foreach Z.ZoneActors( class'Pawn', Pn )
				{
					if ( Z.DOT_Type != DOT_None )
						Pn.AddDOT( Z.DOT_Type, Z.DOT_Duration, Z.DOT_Time, Z.DOT_Damage, None );
				}
			}
			
			if(!bool(FogMorphTime))
			{
				if(SetFogColor)				Z.FogColor=FogColor;
				if(SetFogDensity)			Z.FogDensity=FogDensity;
				if(SetFogDistance)			Z.FogDistance=FogDistance;
				if(SetFogEnabled)			Z.FogEnabled=FogEnabled;
			} else
			{
				useZone=z;
				ElapsedSeconds=0;
				Enable('Tick');
			}
		}

		// Assign each related warpzone:
		foreach allactors(class'WarpZoneInfo',WZ, Event)
		{
			if(SetOtherSideURL)			WZ.OtherSideURL=OtherSideURL;
		}

		// Hacky test:
		if(Flush)
		{
			foreach allactors(class'PlayerPawn',P)
			{
				P.ConsoleCommand("FLUSH");
			}
		}

	}
}

defaultproperties
{
     Texture=Texture'Engine.S_TriggerZoneAssign'
}
