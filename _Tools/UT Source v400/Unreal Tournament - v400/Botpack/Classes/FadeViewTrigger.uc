class FadeViewTrigger extends Triggers;

var(ZoneLight) vector ViewFlash, ViewFog;


var() vector TargetFlash;
var() bool bTriggerOnceOnly; 
var() float FadeSeconds;


var vector OldViewFlash;
var bool bTriggered;

event BeginPlay()
{
	Super.BeginPlay();
	bTriggered = False;
	
	Disable('Tick');
}

event Trigger( Actor Other, Pawn EventInstigator )
{
	if(bTriggered && !bTriggerOnceOnly)
	{
		bTriggered = False;
		Region.Zone.ViewFlash = OldViewFlash;
	}
	else
	{
		bTriggered = True;
		OldViewFlash = Region.Zone.ViewFlash;
		Enable('Tick');
	}
}

event Tick(float DeltaTime)
{
	local float X, Y, Z;
	local bool bXDone, bYDone, bZDone;

	if(bTriggered)
	{
		bXDone = False;
		bYDone = False;
		bZDone = False;

		X = Region.Zone.ViewFlash.X;
		Y = Region.Zone.ViewFlash.Y;
		Z = Region.Zone.ViewFlash.Z;

		X = X - (OldViewFlash.X - TargetFlash.X)*(DeltaTime / FadeSeconds);
		Y = Y - (OldViewFlash.Y - TargetFlash.Y)*(DeltaTime / FadeSeconds);
		Z = Z - (OldViewFlash.Z - TargetFlash.Z)*(DeltaTime / FadeSeconds);

		if( X < TargetFlash.X ) { X = TargetFlash.X; bXDone = True; }
		if( Y < TargetFlash.Y ) { Y = TargetFlash.Y; bYDone = True; }
		if( Z < TargetFlash.Z ) { Z = TargetFlash.Z; bZDone = True; }

		Region.Zone.ViewFlash.X = X;
		Region.Zone.ViewFlash.Y = Y;
		Region.Zone.ViewFlash.Z = Z;

		if(bXDone && bYDone && bZDone)
			Disable('Tick');
	}
}

defaultproperties
{
	TargetFlash=(X=-2,Y=-2,Z=-2)
	FadeSeconds=5
}