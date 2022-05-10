//=============================================================================
// Z1_PokerChipStack_Blue.				October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_PokerChipStack_Blue expands Z1_PokerChipStack_Black;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_PokerChips_Blue'
     MultiSkins(0)=Texture'm_zone1_vegas.LKpchipblueRC'
     MultiSkins(1)=Texture'm_zone1_vegas.LKpchipbluesRC'
     ItemName="$1 Poker Chip Stack"
}
