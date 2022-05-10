/*-----------------------------------------------------------------------------
	VendSnack
	Author: Brandon Reinhart

	Japanese Snack!!! Yum!
-----------------------------------------------------------------------------*/
class VendSnack extends Inventory
	abstract;

#exec OBJ LOAD FILE=..\Sounds\dnsMaterials.dfx
#exec OBJ LOAD FILE=..\Sounds\a_dukevoice.dfx

var() int HealingAmount;
var bool bDrink;
var sound Drink;
var sound Eat[2];

static function bool CantBuyItem( Pawn Other )
{
	if (Other.Health >= 100)
	{
		Other.ClientMessage("I don't feel hungry.");
		return true;
	} else
		return false;
}

function DoPickup( Actor Other )
{
	local int HealMax;
	local Pawn P;
	local sound EatSound;

	P = Pawn(Other);	
	HealMax = P.default.Health;

	// Add the item's distinctiveness to our own.
	P.AddEgo(HealingAmount, true);

	// Display a pickup message.
	DisplayPickupEvent( Self, Other );

	// Eat it.
	if ( Other.IsA('DukePlayer') )
	{
		if ( bDrink )
			DukePlayer(Other).DukeVoice.DukeSay( Drink );
		else
		{
			if ( FRand() < 0.5 )
				EatSound = Eat[0];
			else
				EatSound = Eat[1];
			DukePlayer(Other).DukeVoice.DukeSay( EatSound );
			if ( Other.IsA('DukePlayer') && (FRand() < 0.25) )
				DukePlayer(Other).SwallowTime = GetSoundDuration( EatSound );
		}
	}

	// Get rid of...SPIDER
	SetRespawn();
}

auto state Pickup
{	
    function bool ValidTouch( actor Other, optional bool bCheckWall )
    {
        return ( Super.ValidTouch(Other,bCheckWall) && Other.bIsRenderActor && (RenderActor(Other).Health < 100) );
    }

	function Touch( actor Other )
	{			
		if ( bDontPickupOnTouch )
			return;

		if ( ValidTouch(Other,true) ) 
			DoPickup(Other);
	}

	function Used( Actor Other, Pawn EventInstigator )
	{
		if ( ValidTouch(Other) )
			DoPickup(Other);
	}
}

defaultproperties
{
 	 PickupIcon=texture'hud_effects.am_rebreath'
     HealingAmount=5
     LodMode=LOD_Disabled
	 ItemLandSound=sound'dnsMaterials.LthrMtlDamp18'
     RespawnTime=30.000000
	 Drink=sound'a_dukevoice.food.Drink09'
	 Eat(0)=sound'a_dukevoice.food.Eat17'
	 Eat(1)=sound'a_dukevoice.food.Eat10'
	 SpawnOnHitClassString="dnParticles.dnBulletFX_FabricSpawner"
}
