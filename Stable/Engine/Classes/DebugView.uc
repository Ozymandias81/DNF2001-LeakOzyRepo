//=============================================================================
// DebugView. (CDH)
// Display for debugging information.
//=============================================================================
class DebugView expands InfoActor
    transient;

var name WatchTargetClassName;
var int WatchTargetIndex;
var actor WatchTarget;
var int WatchNumProperties;
var string WatchProperties[128];

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    WatchTargetClassName = 'Actor';
    WatchTargetIndex = -1;
    WatchTarget = None;
    WatchNumProperties = 0;
    WatchNext();
}

simulated function PostRender(canvas Canvas)
{
    local int i, posX, posY;
    local string s;
	local vector CamLoc;
	local rotator CamRot;
	local float f;

    posX = 105;
    posY = 5;
    Canvas.Font = Canvas.SmallFont;
    Canvas.SetPos(posX, posY);
    Canvas.Style = ERenderStyle.STY_Normal;
    Canvas.DrawColor.R = 0;
    Canvas.DrawColor.G = 255;
    Canvas.DrawColor.B = 0;
    Canvas.SpaceY = 0;
    
    if (WatchTarget != None)
    {
        Canvas.DrawText("Watches: "$WatchTarget,false);
        Canvas.CurX = posX;
        
        i = 0;
        while (WatchTarget.DebugWatchExtra(self, i, s))
        {
            Canvas.DrawText(s, false);
            Canvas.CurX = posX;
            i++;
        }        
        
        for (i=0;i<WatchNumProperties;i++)
        {
            Canvas.DrawText("  "$WatchProperties[i]$": "$WatchTarget.GetPropertyText(WatchProperties[i]),false);
            Canvas.CurX = posX;
        }

		f = Level.TimeSeconds * pi * 0.25;
		CamLoc = WatchTarget.Location + vect(cos(f)*60.0, -sin(f)*60.0, 30.0);
		CamRot = rotator(Normal(WatchTarget.Location - CamLoc));
		Canvas.SetPos(0, 0);
		Canvas.DrawPortal(0, 0, 100, 100, None, CamLoc, CamRot);
    }
    else
    {
        Canvas.DrawText("No Watch Target",false);
        Canvas.CurX = posX;
    }
}

simulated function SetWatchTarget(actor InTarget)
{
    if (WatchTarget != None)
        WatchTarget.DebugWatchEnd(self);
    WatchTarget = None;
    WatchNumProperties = 0;
    if (InTarget != None)
    {
        WatchTarget = InTarget;
        WatchTarget.DebugWatchBegin(self);
    }
}

simulated function AddWatch(string InPropName)
{
    WatchProperties[WatchNumProperties] = InPropName;
    WatchNumProperties++;
}

exec function Watch(name InClassName)
{
    WatchTargetClassName = InClassName;
    WatchTargetIndex = -1;
    WatchNext();
}

exec function WatchTrace()
{
    local actor targ;

    if (Pawn(Owner)==None)
        return;
    targ = Pawn(Owner).TraceFromCrosshair(1000);
    if (targ==None)
        return;
    WatchTargetClassName = targ.Class.Name;
    WatchTargetIndex = -1;
    SetWatchTarget(targ);
}

exec function WatchNext()
{
    local actor a;
    local int index;

    index = 0;
    foreach AllActors(class'actor', a)
    {
        if (!a.IsA(WatchTargetClassName))
            continue;
        if ((WatchTarget==None) || (index>WatchTargetIndex))
        {
            WatchTargetIndex = index;
            SetWatchTarget(a);
            return;
        }
        index++;
    }
    WatchTargetIndex = -1;
    foreach AllActors(class'actor', a)
    {
        if (!a.IsA(WatchTargetClassName))
            continue;
        WatchTargetIndex = 0;
        SetWatchTarget(a);
        return;
    }
    WatchTargetIndex = -1;
    SetWatchTarget(None);
}

defaultproperties
{
    RemoteRole=ROLE_None
	bHidden=True
}