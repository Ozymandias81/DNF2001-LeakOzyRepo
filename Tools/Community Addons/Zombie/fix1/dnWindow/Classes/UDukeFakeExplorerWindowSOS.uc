class UDukeFakeExplorerWindowSOS expands UDukeFakeExplorerWindow; 

function Created() 
{
	ClientClass=class'UDukeSOSSC';
	WindowTitle="S.O.S";

	Super.Created();
}

defaultproperties
{
}
