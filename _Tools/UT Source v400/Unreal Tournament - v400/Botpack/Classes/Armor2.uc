//=============================================================================
// Armor2 powerup.
//=============================================================================
class Armor2 extends TournamentPickup;

#exec MESH IMPORT MESH=Armor2M ANIVFILE=MODELS\armor2_a.3D DATAFILE=MODELS\armor2_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Armor2M X=0 Y=0 Z=0 YAW=0
#exec MESH SEQUENCE MESH=Armor2M SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jarmor2 FILE=MODELS\armor3.PCX GROUP="Skins" LODSET=2
#exec MESHMAP SCALE MESHMAP=Armor2M X=0.06 Y=0.06 Z=0.12
#exec MESHMAP SETTEXTURE MESHMAP=Armor2M NUM=1 TEXTURE=Jarmor2 
#exec AUDIO IMPORT FILE="Sounds\Pickups\ARMOURUT.WAV" NAME="ArmorUT" GROUP="Pickups"

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
     bDisplayableInv=True
     PickupMessage="You got the Body Armor."
     RespawnTime=30.000000
     PickupViewMesh=Mesh'Botpack.Armor2M'
     Charge=100
     ArmorAbsorption=75
     bIsAnArmor=True
     AbsorptionPriority=7
     MaxDesireability=2.000000
     PickupSound=Sound'Botpack.Pickups.ArmorUT'
     Mesh=Mesh'Botpack.Armor2M'
     AmbientGlow=64
     CollisionHeight=11.000000
	 ItemName="Body Armor"
	 PickupViewScale=1.0
}
