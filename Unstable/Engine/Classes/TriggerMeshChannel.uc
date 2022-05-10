//=============================================================================
// TriggerMeshChannel. (CDH)
// Sets mesh animation channel data for actors referenced by "Event".
//=============================================================================
class TriggerMeshChannel expands Triggers;

#exec Texture Import File=Textures\TriggerGremlin1.pcx Name=S_TriggerMeshChannel Mips=Off Flags=2

var() int ChannelIndex ?("Channel index to affect, 0 through 15");

var() bool bSequenceLoop ?("True to loop a sequence, false if not.\nOnly used if SequenceName isn't None");
var() bool bSequenceBlendAdditive ?("True to use additive blending on a sequence, rarely needed.\nOnly used if SequenceName isn't None");
var() name SequenceName ?("Sequence name to play on the given ChannelIndex, None if using a mesh effect");
var() float SequenceRate ?("Rate multiplier for playing a sequence, 1.0 is normal speed\nOnly used if SequenceName isn't None");
var() float SequenceTweenTime ?("Time in seconds to tween to the sequence, 0.0 snaps by default\nOnly used if SequenceName isn't None");
var() float SequenceMinRate ?("Minimum rate to loop sequence when using velocity-scaled animations\nOnly used if SequenceName isn't None");
var() float SequenceBlend ?("Amount to blend in state of previous channel, between 0.0 and 1.0 (0.0 overwrites entirely, by default)\nOnly used if SequenceName isn't None");

var() class<MeshEffect> MeshEffectClass ?("Subclass of MeshEffect to spawn on the channel, None if a sequence is being played instead of an effect");
var() name MeshEffectTemplateTag ?("Template of the given MeshEffect subclass, passes its values onto the spawned effect.  None uses effect's default values");
var MeshEffect MeshEffectTemplateActor;

function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (MeshEffectClass != None)
        MeshEffectTemplateActor = MeshEffect(FindActorTagged(class'MeshEffect', MeshEffectTemplateTag));
}

function SetChannelInfo(actor Other)
{
	local MeshEffect meff;
	local MeshInstance minst;

	// make sure channel is valid
	if ((ChannelIndex < 0) || (ChannelIndex >= 16))
		return;
	
	// get mesh instance for channel data
	minst = Other.GetMeshInstance();
	if (minst==None)
		return;
	
    // if there's an existing mesh effect on the channel, wipe it out
    if (minst.MeshChannels[ChannelIndex].MeshEffect != None)
        minst.MeshChannels[ChannelIndex].MeshEffect.Destroy();
    minst.MeshChannels[ChannelIndex].MeshEffect = None;
    if (ChannelIndex==0)
        Other.MeshEffect = None;

	if (MeshEffectClass != None) // if this is an effect, spawn it
	{
		meff = Spawn(MeshEffectClass);
		minst.MeshChannels[ChannelIndex].MeshEffect = meff;
		if (ChannelIndex==0)
			Other.MeshEffect = meff;
        meff.SetInfo(ChannelIndex, Other, MeshEffectTemplateActor);
	}
	else if (SequenceName != 'None') // otherwise, if there's a sequence, play it
	{
		if (ChannelIndex==0)
		{
			Other.bAnimBlendAdditive = bSequenceBlendAdditive;
			Other.AnimBlend = SequenceBlend;
		}
		minst.MeshChannels[ChannelIndex].bAnimBlendAdditive = bSequenceBlendAdditive;
		minst.MeshChannels[ChannelIndex].AnimBlend = SequenceBlend;
		if (!bSequenceLoop)
			Other.PlayAnim(SequenceName, SequenceRate, SequenceTweenTime, ChannelIndex);
		else
			Other.LoopAnim(SequenceName, SequenceRate, SequenceTweenTime, SequenceMinRate, ChannelIndex);
	}
	else // no effect and no sequence, blank out the channel
	{
		minst.MeshChannels[ChannelIndex].AnimSequence = 'None';
		if (ChannelIndex==0)
			Other.AnimSequence = 'None';
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
    local actor a;

    if (Event=='')
        return;
	foreach AllActors(class'Actor', a, Event)
		SetChannelInfo(a);
}

defaultproperties
{
    Texture=Texture'Engine.S_TriggerMeshChannel'
    SequenceRate=1.000000
}
