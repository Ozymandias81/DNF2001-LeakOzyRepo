class dnBoneRope extends BoneRope;

#exec OBJ LOAD FILE=..\Meshes\c_FX.dmx
#exec OBJ LOAD FILE=..\sounds\a_generic.dfx

defaultproperties
{
    LodMode=LOD_Disabled
    DrawType=DT_Mesh
    Mesh=DukeMesh'c_FX.rope256'    
    m_onOffRopeSound=sound'a_generic.rope.RopeClimb07'
    m_climbSound=sound'a_generic.rope.RopeClimb07'
    m_ropeCreakSounds(0)=sound'a_generic.rope.RopeCreak33'
    m_ropeCreakSounds(1)=sound'a_generic.rope.RopeCreak34'
    m_ropeCreakSounds(2)=sound'a_generic.rope.RopeCreak35'
}
