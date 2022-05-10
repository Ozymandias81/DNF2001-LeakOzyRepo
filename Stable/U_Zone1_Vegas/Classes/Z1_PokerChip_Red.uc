//=============================================================================
// Z1_PokerChip_Red. 					October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_PokerChip_Red expands Z1_PokerChip_Black;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     ItemName="$5 Poker Chip"
     Skin=Texture'm_zone1_vegas.LKpchipredmRC'
}
