//=============================================================================
// dnDriveableDecorationTrigger.
// Event is dnDriveableDecoration(s) to trigger.
//=============================================================================
class dnDriveableDecorationTrigger expands Triggers;

//#exec AUDIO IMPORT FILE="Sounds\dot.wav" NAME="DrivingOnTheTruck" 

var () float AddSpeed;
var () float AddVerticalVelocity;
//var sound Truck;

function Trigger( actor Other, pawn EventInstigator )
{
	local dnDriveableDecoration A;
	

	// Make sure event is valid 
	if( Event != '' )
		// Trigger all dnDriveableDecorations with matching triggers 
		foreach AllActors( class 'dnDriveableDecoration', A, Event )		
		{
			//A.AttachedPlayer.PlaySound(Truck);
			if(AddSpeed!=0)
			{
				A.CurrentSpeed+=AddSpeed;
				A.Gear=4;
			}

			if(AddVerticalVelocity!=0)
			{
				A.ForwardVelocity.Z += AddVerticalVelocity;

			}
		}

}

defaultproperties
{
	//Truck=Sound'dnGame.DrivingOnTheTruck'
	AddVerticalVelocity=2000
}