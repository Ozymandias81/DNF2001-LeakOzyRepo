//=============================================================================
//	BreakableGlass
//	Author: John Pollard
//=============================================================================
class BreakableGlass expands RenderActor
	native;

var() float				GlassSizeX;
var() float				GlassSizeY;
var() texture			GlassTexture1;
var() texture			GlassTexture2;
var() texture			GlassTexture3;

var() sound				GlassSound1;
var() sound				GlassSound2;
var() sound				GlassSound3;
var() sound				GlassSound4;

var() float				ParticleSize;
var() int				InitialBreakCount;

var() float				FallPerSecond1;
var() float				FallPerSecond2;

var() float				TotalBreakPercent1;
var() float				TotalBreakPercent2;

var() bool				bGlassTranslucent;
var() bool				bGlassModulated;
var() bool				bGlassMasked;
var() bool				bTwoSided;

var() float				BounceScale;
var() float				RotateScale;

var() float				ParticleLife;

var() float				UShift;
var() float				VShift;
var() float				UScale;
var() float				VScale;

var() bool				bGlassRespawn;
var() float				GlassRespawnTime;

var() float				ParticlesToStayPercent;

var() bool				bRandomTextureRotation;
var() bool				bGlassEnviroMap;

// INTERNAL USE ONLY
var int					GlassVersion;

var transient int		GlassParticles;
var transient int		NumGlassParticles;
var transient int		CurGlassParticle;

var transient int		GlassBreakCount;
var transient float		GlassTime;

var transient int		GlassPrimitive;

var transient int		UserData;			// For future expansion

replication
{
	reliable if ( Role == ROLE_Authority )
		GlassSizeX, GlassSizeY, GlassTexture1, GlassTexture2, GlassTexture3, GlassSound1,
		GlassSound2, GlassSound3, GlassSound4, ParticleSize, InitialBreakCount,
		FallPerSecond1, FallPerSecond2, TotalBreakPercent1, TotalBreakPercent2,
		bGlassTranslucent, bGlassModulated, bGlassMasked, bTwoSided, BounceScale,
		RotateScale, ParticleLife, UShift, VShift, UScale, VScale, bGlassRespawn,
		GlassRespawnTime, ParticlesToStayPercent;
}

//=============================================================================
// Native functions
//=============================================================================
native simulated final function BreakGlass(vector Location, optional bool DirForce, optional float DirForceScale);
native simulated final function BreakGlassDir(vector Location, vector Dir, float DirForceScale);
native simulated final function BreakGlassXY(float x, float y);
native simulated final function GetParticleBox(out vector Min, out vector Max);
native simulated final function InternalTick(float DeltaTime);

simulated event GlassCracked();			// Called from internal code when the glass has been cracked
simulated event GlassShattered();			// Called from internal code when the glass has been fully shattered
simulated event GlassRespawned();			// Called from internal code when glass is respawned (as a result of bGlassRespawn being set)

// Used to spawn a client safe network break effect.
simulated function ReplicateBreakGlass( vector BreakLocation, optional bool DirForce, optional float DirForceScale )
{
	local HitPackage_Glass hpg;

	if ( Role == ROLE_Authority )
	{
		hpg = spawn( class'HitPackage_Glass', Self,, BreakLocation );
		hpg.DirForce = DirForce;
		hpg.DirForceScale = DirForceScale;
		hpg.Deliver();
	}
}

// Used to spawn a client safe network break effect with extended directional information.
simulated function ReplicateBreakGlassDir( vector BreakLocation, vector Dir, float DirForceScale )
{
	local HitPackage_GlassDir hpg;

	if ( Role == ROLE_Authority )
	{
		hpg = spawn( class'HitPackage_GlassDir', Self,, BreakLocation );
		hpg.DirX = Dir.X;
		hpg.DirY = Dir.Y;
		hpg.DirZ = Dir.Z;
		hpg.DirForceScale = DirForceScale;
		hpg.Deliver();
	}
}

//=============================================================================
//	Tick
//=============================================================================
simulated function Tick(float DeltaTime)
{
	InternalTick(DeltaTime);
	Super.Tick(DeltaTime);
}

//=============================================================================
//	defaultproperties
//=============================================================================
defaultproperties
{
	GlassSizeX=128.0f
	GlassSizeY=128.0f

	GlassTexture1=None
	GlassTexture2=None
	GlassTexture3=None

	GlassSound1=None
	GlassSound2=None

	ParticleSize=25.0f
	InitialBreakCount=5

	FallPerSecond1=50.0f
	FallPerSecond2=130.0f

	TotalBreakPercent1=0.10f
	TotalBreakPercent2=0.55f

	bGlassTranslucent=false
	bGlassModulated=false
	bGlassMasked=false
	bTwoSided=true

	BounceScale=1.3f
	RotateScale=1.0f

	ParticleLife=10.0

	ParticlesToStayPercent=0.7f

	UShift=0.0f
	VShift=0.0f
	UScale=1.0f
	VScale=1.0f

	bRandomTextureRotation=true;
	bGlassEnviroMap=true;

	bBlockPlayers=true;
	bProjTarget=true;
	bCollideActors=true;
	CollisionRadius=30.0
	CollisionHeight=30.0

	GlassVersion=1

	bStasis=false
    bStatic=false

	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
	HitPackageClass=class'HitPackage_Glass'
}
