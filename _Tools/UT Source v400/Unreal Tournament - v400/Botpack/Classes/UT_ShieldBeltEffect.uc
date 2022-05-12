//=============================================================================
// UT_ShieldBeltEffect.
//=============================================================================
class UT_ShieldBeltEffect extends Effects;

var Texture LowDetailTexture;
var int FatnessOffset;

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
	local int IdealFatness;

	if ( (Level.NetMode == NM_DedicatedServer) || (Owner == None) )
		return;

	IdealFatness = Owner.Fatness; // Convert to int for safety.
	IdealFatness += FatnessOffset;

	if ( Fatness > IdealFatness )
		Fatness = Max(IdealFatness, Fatness - 130 * DeltaTime);
	else
		Fatness = Min(IdealFatness, 255);
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
	 FatnessOffset=29
	 Fatness=157
	 Style=STY_Translucent
     DrawScale=1.00000
	 ScaleGlow=0.5
     AmbientGlow=64
	 bUnlit=true
	 Physics=PHYS_Trailer
	 Texture=FireTexture'UnrealShare.Belt_fx.ShieldBelt.N_Shield'
	 LowDetailTexture=Texture'UnrealShare.Belt_fx.ShieldBelt.newgold'
	 bTrailerSameRotation=true
}
