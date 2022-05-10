//=============================================================================
// dnShrinkWave. (CDH)
// Outer sine wave beam of shrink ray
// Spawner must still set Event for end of beam
//=============================================================================
class dnShrinkWave expands BeamSystem;

defaultproperties
{
    TesselationLevel=8
    MaxAmplitude=3.000000
    MaxFrequency=-0.200000
    BeamColor=(R=79,G=208,B=85)
    BeamEndColor=(R=55,G=193,B=40)
    BeamStartWidth=1.200000
    BeamEndWidth=1.200000
    BeamType=BST_DoubleSineWave
    bHidden=False    
}
