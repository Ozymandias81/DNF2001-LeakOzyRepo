//=============================================================================
// dnShrinkLightning. (CDH)
// Outer lightning bolts for shrink ray
// Spawner must still set Event for end of beam
//=============================================================================
class dnShrinkLightning expands BeamSystem;

defaultproperties
{
    TesselationLevel=5
    MaxAmplitude=30.000000
    MaxFrequency=0.200000
    Noise=0.010000
    BeamColor=(R=150,G=254,B=209)
    BeamEndColor=(R=92,G=165,B=252)
    BeamStartWidth=1.000000
    BeamEndWidth=1.000000
    BeamType=BST_RandomWalk
    bHidden=False    
}
