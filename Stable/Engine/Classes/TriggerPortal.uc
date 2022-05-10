//=============================================================================
// TriggerPortal. (NJS)
// Event points to a name.
//=============================================================================
class TriggerPortal expands Triggers;

var TriggerPortal NextTriggerPortal,
				  PreviousTriggerPortal;

var () bool    Enabled;
var () int     X;
var () name    XVariable;
var () int     Y;
var () name    YVariable;
var () int     Width;
var () name    WidthVariable;
var () int     Height;
var () name    HeightVariable;
var () bool    DontDrawIfNoCameraActor;
var () vector  CameraLocation;
var () rotator CameraRotation;
var () int     FOV;
var () name    FOVVariable;
var () bool    ClearZ;
var () bool	   Fullscreen;
var () bool    ScaleFrom640x480;

var () bool    UsePawnViewRot;
var () vector  CameraOffset;

simulated function PostBeginPlay()
{
	// Hook myself up to the trigger portal list:
	PreviousTriggerPortal=none;
	NextTriggerPortal=Level.TriggerPortals;
	Level.TriggerPortals=self;

	super.PostBeginPlay();
}

simulated function Destroyed()
{
	// Remove myself from the trigger portal list:
	if(Level.TriggerPortals==self) Level.TriggerPortals=NextTriggerPortal;
	if(NextTriggerPortal!=none)		{ NextTriggerPortal.PreviousTriggerPortal=PreviousTriggerPortal; }
	if(PreviousTriggerPortal!=none)	{ PreviousTriggerPortal.NextTriggerPortal=NextTriggerPortal; }

	super.Destroyed();
}

function DrawTriggerPortal(Canvas c)
{
	local int newX,newY,newWidth,newHeight;
	local actor CameraActor;
	if(!Enabled) return;

	// Find the camera actor:
	CameraActor=none;
	foreach allactors(class'actor',CameraActor,Event)
	{
		break;
	}

	
	if(CameraActor!=none)
	{
		CameraLocation=CameraActor.Location;
		if(CameraActor.bIsPawn && UsePawnViewRot)
			CameraRotation=Pawn(CameraActor).ViewRotation;
		else
			CameraRotation=CameraActor.Rotation;

	} else if(DontDrawIfNoCameraActor)
		return;

	CameraLocation+=CameraOffset;

	if(FOVVariable!='')	   FOV=GetVariableValue( FOVVariable, Fov);
	if(XVariable!='')	   X=GetVariableValue( XVariable, X);
	if(YVariable!='')	   Y=GetVariableValue( YVariable, Y);
	if(WidthVariable!='')  Width=GetVariableValue( WidthVariable, Width);
	if(HeightVariable!='') Height=GetVariableValue( HeightVariable, Height);
	if(FullScreen)		   { Width=C.ClipX; Height=C.ClipY; }

	if(ScaleFrom640x480)
	{
		newWidth =int(float(Width) /640.0*C.ClipX);
		newHeight=int(float(Height)/480.0*C.ClipY);
		newX =int(float(X)/640.0*C.ClipX);
		newY =int(float(Y)/480.0*C.ClipY);
	} else
	{
		newWidth=Width;
		newHeight=Height;
		newX=X;
		newY=Y;
	}

	c.DrawPortal(newX,newY,newWidth,newHeight,none,CameraLocation,CameraRotation,FOV,ClearZ);
}

function Trigger( actor Other, pawn EventInstigator )
{
	Enabled=!Enabled;
}

defaultProperties
{
	x=0
	y=0
	Width=128
	Height=128
	Enabled=true
	FOV=90
	ClearZ=true
	Fullscreen=true
	ScaleFrom640x480=false
}