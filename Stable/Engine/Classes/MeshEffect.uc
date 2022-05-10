//=============================================================================
// MeshEffect. (CDH)
// Base of mesh animation channel effects.
//=============================================================================
class MeshEffect extends InfoActor
    abstract
    native;

#exec Texture Import File=Textures\TriggerGremlin2.pcx Name=S_MeshChannel Mips=Off Flags=2

var() bool bAffectsBones;
var() bool bAffectsVerts;

simulated event EvalBones(int channel, actor a);
simulated event EvalVert(int channel, actor a, out vector v);
simulated function SetInfo(int channel, actor a, MeshEffect inTemplate);

defaultproperties
{
    bHidden=True
    Texture=Texture'Engine.S_MeshChannel'
}
