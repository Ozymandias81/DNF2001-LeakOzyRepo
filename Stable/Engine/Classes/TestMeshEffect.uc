//=============================================================================
// TestMeshEffect. (CDH)
// Used for testing, do not use for anything with an expected result.
//=============================================================================
class TestMeshEffect extends MeshEffect;

/* Vertex warpy electroshock test
function EvalVert(int channel, actor a, out vector v)
{
    v += Normal(v) * (sin(level.TimeSeconds + (v dot v)) * 2.0);
}
*/

/* Body look test */
simulated function EvalBones(int channel, actor a)
{
    local int bone;
    local MeshInstance minst;
	local rotator r;
	local float f;
	local playerpawn p, guy;
    minst = a.GetMeshInstance();
    if (minst==None)
        return;

	foreach AllActors(class'PlayerPawn', p)
	{
		guy = p;
		break;
	}

	bone = minst.BoneFindNamed('Abdomen');
	if (bone==0)
		return;
	r = guy.ViewRotation;
    r = Normalize(r);
	r.Pitch = r.Pitch * 0.375;
	r.Yaw = r.Yaw * 0.375;
	r.Pitch += 16384;
	minst.BoneSetRotate(bone, r, true);

	bone = minst.BoneFindNamed('Chest');
	if (bone==0)
		return;
	r = guy.ViewRotation;
    r = Normalize(r);
	r.Pitch = r.Pitch * 0.75;
	r.Yaw = r.Yaw * 0.75;
	r.Pitch += 16384;
	minst.BoneSetRotate(bone, r, true);

    bone = minst.BoneFindNamed('Head');
	if (bone==0)
		return;	
	r = guy.ViewRotation;
	r.Pitch += 16384;
	
	minst.BoneSetRotate(bone, r, true);
}
/* */

/* Shrinky test
simulated function EvalBones(int channel, actor a)
{
    local int bone;
    local MeshInstance minst;
	local float f, t;
    local vector s;
    minst = a.GetMeshInstance();
    if (minst==None)
        return;

    bone = minst.BoneFindNamed('Neck');
	if (bone!=0)
	{
		s = minst.BoneGetScale(bone, false, true);
		f = 0.5;
		s.x *= f; s.y *= f; s.z *= f;
		minst.BoneSetScale(bone, s, false);
	}
	
    bone = minst.BoneFindNamed('Bicep_R');
	if (bone!=0)
	{
		s = minst.BoneGetScale(bone, false, true);
		f = 0.5;
		s.x *= f; s.y *= f; s.z *= f;
		minst.BoneSetScale(bone, s, false);
	}

    bone = minst.BoneFindNamed('Bicep_L');
	if (bone!=0)
	{
		s = minst.BoneGetScale(bone, false, true);
		f = 0.5;
		s.x *= f; s.y *= f; s.z *= f;
		minst.BoneSetScale(bone, s, false);
	}
}
*/

defaultproperties
{
    bAffectsBones=True
    bAffectsVerts=False
}
