//=============================================================================
// ThighPads.
//=============================================================================
class ThighPads extends TournamentPickup;

#exec MESH IMPORT MESH=ThighPads ANIVFILE=MODELS\ThighPads_a.3d DATAFILE=MODELS\ThighPads_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=ThighPads X=0 Y=0 Z=0
#exec MESH SEQUENCE MESH=ThighPads SEQ=All                      STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ThighPads SEQ=sit                      STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP NEW   MESHMAP=ThighPads MESH=ThighPads
#exec MESHMAP SCALE MESHMAP=ThighPads X=0.04 Y=0.04 Z=0.08
#exec TEXTURE IMPORT NAME=JThighPads_01 FILE=MODELS\ThighPads1.PCX GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=ThighPads NUM=1 TEXTURE=JThighPads_01
#exec MESHMAP SETTEXTURE MESHMAP=ThighPads NUM=2 TEXTURE=JThighPads_01

function bool HandlePickupQuery( inventory Item )
{
	local inventory S;

	if ( item.class == class ) 
	{
		S = Pawn(Owner).FindInventoryType(class'UT_Shieldbelt');	
		if (  S==None )
		{
			if ( Charge<Item.Charge )	
				Charge = Item.Charge;
		}
		else
			Charge = Clamp(S.Default.Charge - S.Charge, Charge, Item.Charge );
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
		if ( PickupMessageClass == None )
			Pawn(Owner).ClientMessage(PickupMessage, 'Pickup');
		else
			Pawn(Owner).ReceiveLocalizedMessage( PickupMessageClass, 0, None, None, Self.Class );
		Item.PlaySound (PickupSound,,2.0);
		Item.SetReSpawn();
		return true;				
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

function inventory SpawnCopy( pawn Other )
{
	local inventory Copy, S;

	Copy = Super.SpawnCopy(Other);
	S = Other.FindInventoryType(class'UT_Shieldbelt');	
	if ( S != None )
	{
		Copy.Charge = Min(Copy.Charge, S.Default.Charge - S.Charge);
		if ( Copy.Charge == 0 )
		{ 
			S.Charge -= 1;
			Copy.Charge = 1;
		}
	}
	return Copy;
}

defaultproperties
{
     bRotatingPickup=True
	 ItemName="Thigh Pads"
     PickupMessage="You got the Thigh Pads."
     PickupViewMesh=Mesh'Botpack.ThighPads'
     PickupViewScale=1.000000
     Charge=50
     ArmorAbsorption=50
     Mesh=Mesh'Botpack.ThighPads'
     DrawScale=1.000000
     CollisionRadius=30.000000
     CollisionHeight=30.000000
     bDisplayableInv=True
     RespawnTime=30.000000
     bIsAnArmor=True
     AbsorptionPriority=7
     MaxDesireability=1.800000
     PickupSound=Sound'Botpack.Pickups.ArmorUT'
     Icon=Texture'UnrealShare.Icons.I_Armor'
     AmbientGlow=64
}