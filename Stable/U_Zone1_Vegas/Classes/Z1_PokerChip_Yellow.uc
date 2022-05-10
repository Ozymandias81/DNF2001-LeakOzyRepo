//=============================================================================
// Z1_PokerChip_Yellow.					October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_PokerChip_Yellow expands Z1_PokerChip_Black;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     ItemName="$10 Poker Chip"
     Skin=Texture'm_zone1_vegas.LKpchipyelomRC'
}
