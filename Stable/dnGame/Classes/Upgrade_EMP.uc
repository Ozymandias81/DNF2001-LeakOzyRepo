/*-----------------------------------------------------------------------------
	Upgrade_EMP
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Upgrade_EMP extends Inventory;
var() int EnergyRequirement ?("Energy Requirement for the EMP");
var() float MaxRadius       ?("Radius of the effect of the EMP");
var() float EMPTime         ?("Amount of time between EMPEvent and unEMPEvent");
var() float RadiusVelocity  ?("Speed in which the radius of the EMP blast grows");

var float currentRadius;
var float TotalTime;

function Activate()
{   
    local PlayerPawn P;
	local EMPulse Pulse;

    P = PlayerPawn(Owner);
   
    //Check to see if we have enough power
    if ( P != None )
    {        
        if (P.Energy < EnergyRequirement) // Not enough power, play negative sound
        {
            PlaySound(Sound'ts01.Duke3D_lsrbmbpt');
//            BroadcastMessage("Error in module EMP_BLAST.DLL at 0xDEAFD00C.");
            return;
        }
        // Remove the Energy from owner
        P.Energy -= EnergyRequirement;

        // Spawn a pulse effect at the owner's origin
        Pulse = spawn(class'EMPulse', Owner, , P.Location);

		Pulse.SetOwner( P );
		Pulse.MaxRadius = MaxRadius;
		Pulse.EMPTime = EMPTime;
		Pulse.RadiusVelocity = RadiusVelocity;
		Pulse.AttachActorToParent( Owner, false, false );

        // Reset current Radius
        Pulse.currentRadius = 0;
        Pulse.TotalTime = 0;
        Enable( 'Tick' );
    }
}


defaultproperties
{
	bCanActivateWhileHandUp=true
    dnInventoryCategory=4
    dnCategoryPriority=3
    Icon=Texture'hud_effects.mitem_emp'
    bActivatable=true
    EnergyRequirement=30
    MaxRadius=300
    RadiusVelocity=600
    EMPTime=10.0
    ItemName="Electromagnetic Pulse"
    RespawnTime=30
    PickupViewScale=4.0
    PickupViewMesh=mesh'c_dukeitems.sos_powercell'
    Mesh=mesh'c_dukeitems.sos_powercell'
}