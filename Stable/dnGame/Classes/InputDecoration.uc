/*-----------------------------------------------------------------------------
	InputDecoration, a touchscreen based input decoration.
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class InputDecoration extends dnDecoration;

#exec OBJ LOAD FILE=..\Textures\ShieldFX.dtx
#exec OBJ LOAD FILE=..\Textures\powerpuzzle1.dtx
#exec OBJ LOAD FILE=..\Textures\modelfx.dtx

var TextureCanvas			CanvasTexture;
var TextureCanvas			ScreenCanvas;
var int						ScreenSurface;
var SmackerTexture			ScreenSaver;
var SmackerTexture			BlankScreen;
var SmackerTexture			HitTexture;
var StaticTexture			StaticScreen;
var Texture					PowerOffSkin;
var float					ScreenX, ScreenY;
var InputDecorationTrigger	ActivateSaverTrigger;
var int						SaverViewCount;

var() float					SaverActivateRadius;
var() float					SaverActivateHeight;

var actor					Shield;
var bool					bShield;

var bool					bDisrupted;
var bool					bTranslucentHand;

var() bool					bPowerOff;

var float					CloseTime;

var PlayerPawn				TouchPawn;

simulated function PostBeginPlay()
{
	local texture TempTex;

	ScreenCanvas = CanvasTexture;

	ActivateSaverTrigger = spawn(class'InputDecorationTrigger', Self, , Location);
	ActivateSaverTrigger.MyInputDeco = Self;
	ActivateSaverTrigger.SetCollisionSize(SaverActivateRadius, SaverActivateHeight);

	ScreenSaver = SmackerTexture(MeshGetTexture(ScreenSurface));
	MultiSkins[ScreenSurface] = ScreenSaver;

	HitTexture = ScreenSaver;

	if ( bPowerOff && (PowerOffSkin != None) )
	{
		MultiSkins[0] = PowerOffSkin;
		MultiSkins[ScreenSurface] = BlankScreen;
	}

	SaverDeactivated();
}

function Trigger( actor Other, pawn EventInstigator )
{
	if (bPowerOff)
	{
		bPowerOff = false;
		ScreenSaver.pause = false;
		MultiSkins[ScreenSurface] = ScreenSaver;
	}
}

simulated event Used( Actor Other, Pawn EventInstigator )
{
	local vector PointUV;
	local texture HitMeshTexture;
	local actor HitActor;

	if (bDisrupted || bPowerOff)
		return;

	HitActor = EventInstigator.TraceFromCrosshairMesh( EventInstigator.UseDistance,,,,,,HitMeshTexture, PointUV );
	if (HitMeshTexture == HitTexture)
		ScreenTouched( EventInstigator, PointUV.X*ScreenX, PointUV.Y*ScreenY );
}

simulated function ScreenTouched( Pawn Other, float X, float Y )
{
	if (bDisrupted || bPowerOff)
		return;
}

simulated function ActivateSaver()
{
	SaverViewCount++;
	if (SaverViewCount != 0)
		SaverActivated();
}

simulated function SaverActivated()
{
	ScreenSaver.pause = false;
}

simulated function DeactivateSaver()
{
	SaverViewCount--;
	if (SaverViewCount == 0)
		SaverDeactivated();
}

simulated function SaverDeactivated()
{
	ScreenSaver.pause = true;
}

simulated function Timer(optional int TimerNum)
{
    if (TimerNum == 3) // EMP Done
    {
		bExaminable = default.bExaminable;
        bEMPulsed = false;
		bDisrupted = false;
        GlobalTrigger(EMPunEvent);
		MultiSkins[ScreenSurface] = ScreenSaver;
    } else if (TimerNum == 1)
	    DestroyShield();
}

simulated function Tick( float Delta )
{
	// Check close time.
	if ( CloseTime > 0.0 )
	{
		CloseTime -= Delta;
		if ( CloseTime < 0.0 )
			CloseDecoration( TouchPawn );
	}

	Super.Tick( Delta );
}

simulated function DestroyShield()
{
    if (Shield != none)
    {
        Shield.Destroy();
        Shield = none;
    }
}

simulated function CreateShield()
{
	if (bDisrupted || bEMPulsed)
		return;

    if (Shield == none)
    {
        Shield = spawn(class'Effects',self,,Location,Rotation);
        Shield.SetCollisionSize(CollisionRadius, CollisionHeight*1.02);
        Shield.SetCollision(false, false, false);
        Shield.bProjTarget = false;
        Shield.SetPhysics(PHYS_Rotating);
        Shield.DrawType = DT_Mesh;
		Shield.Style = STY_Translucent;
        Shield.Mesh = Mesh;
		Shield.Texture = texture'ShieldFX.ShieldLightning';
		Shield.bMeshEnviroMap = true;
        Shield.DrawScale = 1.02;
		Shield.ScaleGlow = 50;
        Shield.bMeshLowerByCollision=bMeshLowerByCollision;
        Shield.MeshLowerHeight=0.0;
    }
}

simulated function Destroyed()
{
	DestroyShield();
    Super.Destroyed();
}

function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	if ( bShield )
		CreateShield();
	SetTimer( 1.0, false, 1 );
}

simulated function EMPBlast( float EMPtime, optional Pawn Instigator )
{
	if (bPowerOff)
		return;

	Super.EMPBlast( EMPtime, Instigator );
	bExaminable = false;
	bDisrupted = true;

	MultiSkins[ScreenSurface] = StaticScreen;
}

simulated function Examine( Actor Other )
{
	Super.Examine( Other );

	if ( Other.bIsPawn )
		ScreenTouched( Pawn(Other), 0, 0 );

	if ( Other.IsA('DukePlayer') )
		DukePlayer(Other).Hand_BringUp( false, false, bTranslucentHand );

	CloseTime = 0.0;
}

simulated function UnExamine( Actor Other )
{
	Super.UnExamine( Other );

	if (Other.IsA('DukePlayer'))
		DukePlayer(Other).Hand_PutDown();

	CloseTime = 2.0;
}

simulated function CloseDecoration( Actor Other )
{
}

defaultproperties
{
	ScreenX=256
	ScreenY=256
	SaverViewCount=0
	SaverActivateRadius=200
	SaverActivateHeight=30

	bExaminable=true
	bPushable=false
	bUseTriggered=true
	Grabbable=false
	Physics=PHYS_None
	bShield=true
	bPowerOff=false

	bBlockPlayers=false

	BlankScreen=texturecanvas'powerpuzzle1.ppuzzle_screen3'
	StaticScreen=statictexture'modelfx.tvstatic'

	bDontReplicateSkin=true
	bDontReplicateMesh=true

	bShadowReceive=false
}