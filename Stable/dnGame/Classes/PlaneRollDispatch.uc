//=============================================================================
// PlaneRollDispatch.
// Defines a plane with itself and two other actors used for reference.
// The "roller" actor should be somewhere on this plane.  The dispatch monitors
// the roller actor for its position relative to its original position and
// determines the relative roll in the plane from the original roll,
// assigning this roll to the PlaneRollDispatch.  The PlaneRollDispatch is at the
// origin, with vectors to the two other plane actors defining the orientation.
// The roll is passed on to any actors with tags matching the dispatch's Event.
//=============================================================================
class PlaneRollDispatch expands Triggers;

var() enum EPlaneRollDispatchComponent
{
    PRD_Pitch,
    PRD_Yaw,
    PRD_Roll
} RollComponent ?("Component to modify in the observers");
var() name RollerTag ?("Actor whose position relative to its initial position determines the roll angle");
var() name PlaneTags[2] ?("Actors used to define the roll plane");
var() bool bNegateRoll ?("Negate the calculated roll prior to adjusting by offset and scale");
var() float RollScale ?("Scale the calculated roll by this multiplier");
var() float RollOffset ?("Added to the roll angle after scaling");
var() bool bConstant ?("Update constantly, false updates only when triggered");
var() bool bMessage ?("Display a message with the roll angle as it's updated");

var actor RollerActor;
var actor PlaneActors[2];
var vector RollerV, PlaneX, PlaneY, PlaneZ;
var float RollOriginal;

function float GetPlaneRoll()
{
    local float a;

    a = atan2(RollerV dot PlaneY, RollerV dot PlaneZ) * 32768.0 / pi;
    a -= RollOriginal;
    if (bNegateRoll)
        a = -a;
    a *= RollScale;
    a += RollOffset;
    return(a);
}

function UpdatePlane()
{    
    local rotator r;
    local vector Ref0, Ref1;

    RollerV = Normal(RollerActor.Location - Location);
    Ref0 = Normal(PlaneActors[0].Location - Location);
    Ref1 = Normal(PlaneActors[1].Location - Location);
    if (abs(Ref0 dot Ref1) > 0.9997)
        return; // cross product would collapse, keep existing plane
    PlaneX = Normal(Ref0 cross Ref1);
    r = rotator(PlaneX);
    GetAxes(r, PlaneX, PlaneY, PlaneZ);
    PlaneX = Normal(PlaneX);
    PlaneY = Normal(PlaneY);
    PlaneZ = Normal(PlaneZ);
}

function SetComponentRoll()
{
    local int angle;
    local actor a;

    angle = int(GetPlaneRoll());
    
    if (bMessage)
        BroadcastMessage("Angle: "$angle);

    switch(RollComponent)
    {
    case PRD_Pitch: SetRotation(rot(angle, Rotation.Yaw, Rotation.Roll)); break;
    case PRD_Yaw: SetRotation(rot(Rotation.Pitch, angle, Rotation.Roll)); break;
    case PRD_Roll: SetRotation(rot(Rotation.Pitch, Rotation.Yaw, angle)); break;
    }

    if (Event != '')
    {
        foreach AllActors(class'actor', a, Event)
        {
            switch(RollComponent)
            {
            case PRD_Pitch: a.SetRotation(rot(angle, Rotation.Yaw, Rotation.Roll)); break;
            case PRD_Yaw: a.SetRotation(rot(Rotation.Pitch, angle, Rotation.Roll)); break;
            case PRD_Roll: a.SetRotation(rot(Rotation.Pitch, Rotation.Yaw, angle)); break;
            }    
        }
    }
}

function PostBeginPlay()
{
    Super.PostBeginPlay();

    RollerActor = FindActorTagged(class'actor', RollerTag);
    PlaneActors[0] = FindActorTagged(class'actor', PlaneTags[0]);
    PlaneActors[1] = FindActorTagged(class'actor', PlaneTags[1]);

    if ((RollerActor==None) || (PlaneActors[0]==None) || (PlaneActors[1]==None))
        Destroy(); // can't work without reference

    UpdatePlane();
    RollOriginal = atan2(RollerV dot PlaneY, RollerV dot PlaneZ) * 32768.0 / pi;
    if (bConstant)
        SetComponentRoll();
}

function Tick(float inDeltaTime)
{
    Super.Tick(inDeltaTime);
    if (bConstant)
    {
        UpdatePlane();
        SetComponentRoll();
    }
}

function Trigger( actor Other, pawn EventInstigator )
{
    UpdatePlane();
    SetComponentRoll();
}

defaultproperties
{
     bHidden=True
     Texture=Texture'Engine.S_LookAtDispatch'
     RollComponent=PRD_Roll
     RollScale=1.000000
     bConstant=True
}
