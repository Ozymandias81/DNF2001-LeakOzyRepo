/*-----------------------------------------------------------------------------
	dnPawnImmolation
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class dnPawnImmolation extends PawnImmolation;

defaultproperties
{
	LimbBones(0)=hand_r
	LimbBones(1)=hand_l
	LimbBones(2)=foot_r
	LimbBones(3)=foot_l
	BodyBone=pelvis
	LimbFlameClass=class'dnParticles.dnFlameThrowerFX_PersonBurn_Limb'
	LimbFlameClassShrunk=class'dnParticles.dnFlameThrowerFX_PersonBurn_Limb'
	BodyFlameClass=class'dnParticles.dnFlameThrowerFX_PersonBurn_Main'
	BodyFlameClassShrunk=class'dnParticles.dnFlameThrowerFX_PersonBurn_Main'
}