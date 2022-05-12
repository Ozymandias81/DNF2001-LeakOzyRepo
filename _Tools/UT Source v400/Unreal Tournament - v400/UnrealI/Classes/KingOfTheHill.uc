//=============================================================================
// KingOfTheHill.
//=============================================================================
class KingOfTheHill extends DeathMatchGame;

var pawn king;
var localized string KingMessage;

function Killed(pawn killer, pawn Other, name damageType)
{
	Other.AmbientGlow = 0;
	Other.LightType = LT_None;
	Other.DamageScaling = 1.0;
	Other.bUnLit = false;

	if ( (King == Other) || (King == None) )
	{
		if ( (killer == None) || (killer == Other) 
				|| (killer.Health <= 0) )
		{
			if ( (killer == King) && (King == Other) )
				King.PlayerReplicationInfo.Score -= 4;
			King = None;
		} 
		else if ( killer != king )
			CrownNewKing(killer);
	}	
			
	Super.Killed(killer, Other, damageType);
}

function CrownNewKing(pawn newKing)
{
	local Inventory Inv;
	
	King = newKing;
	BroadcastMessage(newKing.PlayerReplicationInfo.PlayerName$KingMessage, true);
	NewKing.health = Max(NewKing.Health, 100);
	NewKing.bUnLit = true; 
	NewKing.PlayerReplicationInfo.Score += 5.0;
	NewKing.DamageScaling = 2.0;
	NewKing.LightEffect=LE_NonIncidence;
	NewKing.LightBrightness=255;
	NewKing.LightHue=0;
	NewKing.LightRadius=10;
	NewKing.LightSaturation=0;
	NewKing.AmbientGlow = 200;
	NewKing.bUnlit = true;
	NewKing.LightType=LT_Steady;
}

defaultproperties
{
     KingMessage=" is the new king of the hill!"
     BeaconName="King"
     GameName="King of the Hill"
}
