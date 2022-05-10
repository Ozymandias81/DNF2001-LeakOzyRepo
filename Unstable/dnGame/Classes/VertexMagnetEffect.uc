//=============================================================================
// VertexMagnetEffect. (CDH)
// Attracts or repels vertices of a target mesh within the collision radius
//=============================================================================
class VertexMagnetEffect extends MeshEffect;

var() float MagnetForce;
var() float MagnetPulseForce;
var() float MagnetPulseFrequency;

var meshinstance TargetMeshInstance;
var float CurrentMagnetForce;

simulated function SetInfo(int channel, actor a, MeshEffect inTemplate)
{
	local VertexMagnetEffect inf;
	inf = VertexMagnetEffect(inTemplate);
	if (inf == None)
		return;

    SetCollisionSize(inf.CollisionRadius, inf.CollisionHeight);
    SetPhysics(PHYS_None);
    MagnetForce = inf.MagnetForce;
    MagnetPulseForce = inf.MagnetPulseForce;
    MagnetPulseFrequency = inf.MagnetPulseFrequency;
    SetLocation(inf.Location);

    Target = a;
    TargetMeshInstance = a.GetMeshInstance();
    CurrentMagnetForce = CollisionRadius;
}

simulated function Tick(float DeltaSeconds)
{
    TargetMeshInstance = Target.GetMeshInstance();

    CurrentMagnetForce = CollisionRadius*MagnetForce;
    CurrentMagnetForce += CollisionRadius*(MagnetPulseForce*0.5)*(sin(Level.TimeSeconds*PI*MagnetPulseFrequency)+1.0);
}

simulated event EvalVert(int channel, actor a, out vector v)
{
    local vector p;
    local float dist;
    local float force;
	
	p = TargetMeshInstance.MeshToWorldLocation(v, true);
	p -= Location;
    dist = VSize(p);
    if (dist > CollisionRadius)
        return;
    p += Normal(p)*CurrentMagnetForce;
    p += Location;
	v = TargetMeshInstance.WorldToMeshLocation(p, true);
}

defaultproperties
{
    bAffectsVerts=True
    MagnetForce=1.000000
    MagnetPulseForce=1.000000
    MagnetPulseFrequency=1.000000
}
