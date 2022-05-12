//=============================================================================
// ShieldBeltEffect.
//=============================================================================
class ShieldBeltEffect extends Effects;

var Texture LowDetailTexture;

simulated function Destroyed()
{
	if ( bHidden && (Owner != None) )
		Owner.SetDefaultDisplayProperties();
	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	if ( !Level.bHighDetailMode && ((Level.NetMode == NM_Standalone) || (Level.NetMode == NM_Client)) )
	{
		Timer();
		bHidden = true;
		SetTimer(1.0, true);
	}
}

simulated function Timer()
{
	bHidden = true;
	Owner.SetDisplayProperties(Owner.Style, LowDetailTexture, false, true);
}

simulated function Tick(float DeltaTime)
{
	if ( (Fatness > Default.Fatness) && (Level.NetMode != NM_DedicatedServer) )
		Fatness = Max(Default.Fatness, Fatness - 130 * DeltaTime );
	if ( Owner != None )
		if ( (bHidden != Owner.bHidden) && (Level.NetMode != NM_DedicatedServer) )
			bHidden = Owner.bHidden;
}

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
	 bOwnerNoSee=True
	 bNetTemporary=false
     DrawType=DT_Mesh
	 bAnimByOwner=True
	 bHidden=False
	 bMeshEnviroMap=True
	 Fatness=157
	 Style=STY_Translucent
     DrawScale=1.00000
	 ScaleGlow=0.5
     AmbientGlow=64
	 bUnlit=true
	 Physics=PHYS_Trailer
	 Texture=Texture'Unrealshare.Belt_fx.GoldShield'
	 LowDetailTexture=Texture'GoldSkin'
	 bTrailerSameRotation=true
}