//=============================================================================
// Puppet. (CDH)
// Base class of all Puppets, which manipulate the skeleton of their
// owner actor if they're skeletal-based.  Note that virtually every function
// in puppets is marked simulated.
//=============================================================================
class Puppet expands InfoActor
	abstract
    obsolete;

#exec Texture Import File=Textures\TriggerPuppet1.pcx Name=S_TriggerPuppet1 Mips=Off Flags=2
#exec Texture Import File=Textures\TriggerPuppet2.pcx Name=S_TriggerPuppet2 Mips=Off Flags=2

//struct PuppetBone
//{
//    var() EActorBone BoneType;
//    var() bool bLeftBone, bRightBone;
//};

var() name PuppetChainTag;
var puppet PuppetChain;
var() int PuppetPriority;
var actor PuppetDynamicOwner;
var() float PuppetDuration;

defaultproperties
{
     bHidden=True
     SoundVolume=0
	 Texture=Texture'Engine.S_TriggerPuppet2'
}
