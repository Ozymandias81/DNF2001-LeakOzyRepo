class UTPlayerWindow extends UMenuPlayerWindow;

function BeginPlay() 
{
	Super.BeginPlay();

	ClientClass = class'UTPlayerClientWindow';
}
